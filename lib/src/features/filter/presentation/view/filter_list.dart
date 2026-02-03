import 'dart:convert';

import 'package:Akarat/src/common/widgets/property_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../providers/favorite_provider.dart';
import '../../../../providers/filter_provider.dart';
import '../../../../screen/ContactFormScreen.dart';
import '../../../../screen/CreateAlertScreen.dart';
import '../../../../screen/home.dart';
import '../../../../screen/login.dart';
import '../../../../screen/my_account.dart';
import '../../../../screen/shimmer.dart';
import '../../../../utils/fav_logout.dart';
import '../../../../utils/shared_preference_manager.dart';
import '../../../property/data/datasources/favorite_remote_datasource.dart';
import '../../data/model/filtermodel.dart';

class FliterList extends StatefulWidget {
  const FliterList({
    super.key,
  });

  @override
  _FliterListState createState() => _FliterListState();
}

class _FliterListState extends State<FliterList> {
  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;

  bool _alertCreated = false;

  bool get isLoggedIn => token.isNotEmpty;

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  final List<int> yValues = [
    5000,
    3000,
    9000,
    7000,
    10000,
    1500,
    4000,
  ];

  late List<Data> chartData;

  int _safePropertyId(dynamic id) {
    if (id == null) return 0;
    if (id is int) return id;
    if (id is String) {
      return int.tryParse(id) ?? 0;
    }
    return 0;
  }

  void toggleSavedAtIndex(int index) {
    final filterProvider = context.read<FilterProvider>();

    final property = filterProvider.filterModel?.data![index];

    // Default null to false before toggling
    final currentSaved = property?.saved ?? false;
    final newSaved = !currentSaved;

    setState(() {
      property?.saved = newSaved;

      if (newSaved) {
        FavoriteService.loggedInFavorites.add(int.parse(property!.id!));
      } else {
        FavoriteService.loggedInFavorites.remove(property!.id!);
      }
    });
  }

  Future<bool> markAsContacted(int propertyId,
      {required String contactType}) async {
    if (propertyId <= 0) return false;

    await SessionManager().restore(); // Important: restores token if needed
    final token = SessionManager().token ?? await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      debugPrint("No token – cannot mark as contacted");
      return false;
    }

    try {
      final response = await http.post(
        ApiService.buildUri('property-contact'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "property_id": propertyId,
          "contact_type": contactType, // "call" or "whatsapp"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(
            "Successfully marked property $propertyId as contacted via $contactType");
        return true;
      } else {
        debugPrint(
            "Failed to mark contacted: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception marking contacted: $e");
      return false;
    }
  }

  String phoneCallNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (input.startsWith('+971')) return input;
    if (input.startsWith('00971')) return '+971${input.substring(5)}';
    if (input.startsWith('971')) return '+971${input.substring(3)}';
    if (input.startsWith('0') && input.length == 10) {
      return '+971${input.substring(1)}';
    }
    if (input.length == 9) return '+971$input';
    return input; // fallback
  }

  String whatsAppNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d]'), '');
    if (input.startsWith('971')) return input;
    if (input.startsWith('00971')) return input.substring(2);
    if (input.startsWith('+971')) return input.substring(1);
    if (input.startsWith('0') && input.length == 10) {
      return '971${input.substring(1)}';
    }
    if (input.length == 9) return '971$input';
    return input; // fallback
  }

  Future<void> _onCreateAlert() async {
    if (!isLoggedIn) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -14,
                  right: -10,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Login required to create alerts.',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(ctx).pushNamed('/login');
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            decorationThickness: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    final filterProvider = context.read<FilterProvider>();

    // Navigate to CreateAlertScreen and wait for result
    final initialPurpose = filterProvider.purpose;

    final initialPropertyTypeCategory = filterProvider.property_type;

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAlertScreen(
          initialPurpose: initialPurpose,
          initialPropertyType: initialPropertyTypeCategory,
        ),
      ),
    );

    // Optionally refresh saved alerts / show toast if user saved one
    if (saved == true) {
      // e.g., ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert saved')));
    }

    if (!mounted) return;

    if (saved == true) {
      setState(() => _alertCreated = true);

      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar(); // optional
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Alert created'),
          duration: Duration(milliseconds: 1200),
        ),
      );
    }
  }

  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();
  // Method to read data from shared preferences
  Future<void> readData() async {
    token = await prefManager.readStringFromPref();
    email = await prefManager.readStringFromPrefemail();
    result = await prefManager.readStringFromPrefresult();
    setState(() {
      isDataRead = true;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        chartData = List.generate(
          96,
          (index) => Data(
              500 + index * 100.0, yValues[index % yValues.length].toDouble()),
        );
        final filterProvider = context.read<FilterProvider>();

        _scrollController.addListener(() {
          const threshold = 200.0;
          final position = _scrollController.position;
          if (position.pixels >= position.maxScrollExtent - threshold) {
            if (!filterProvider.isFilterListFilterModelLoading &&
                filterProvider.nextPageUrl != null &&
                filterProvider.nextPageUrl!.isNotEmpty) {
              debugPrint("🟢 Triggering loadMore: $filterProvider.nextPageUrl");
              filterProvider.updateFilterCount(context, loadMore: true);
            }
          }
        });

        _loadLoginToken();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorites(); // ✅ Re-load favorites to keep UI in sync
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLoginToken() async {
    try {
      // 🔐 Load login token and user info
      token = await SecureStorage.getToken() ?? '';
      email = await prefManager.readStringFromPrefemail();
      result = await prefManager.readStringFromPrefresult();

      // ❤️ Load saved favorites
      await _loadFavorites();
    } catch (e) {
      debugPrint("🚨 Error in _loadLoginToken(): $e");
    }
  }

  Future<bool> toggledApi(
      BuildContext context, String token, int propertyId) async {
    if (propertyId <= 0) {
      debugPrint('⚠️ Invalid propertyId: $propertyId');
      return false;
    }
    if (token.isEmpty) {
      debugPrint('⚠️ Empty token; user not logged in.');
      return false;
    }
    try {
      final ok = await context.read<FavoriteProvider>().toggleFavoriteWithApi(
          propertyId, token, context); // 👈 single source of truth

      return ok;
    } catch (e) {
      debugPrint('🚨 toggledApi wrapper error: $e');
      return false;
    }
  }

  Set<int> favoriteProperties = {}; // Stores favorite property IDs

  void toggleFavorite(int propertyId) async {
    setState(() {
      if (favoriteProperties.contains(propertyId)) {
        favoriteProperties.remove(propertyId); // Remove from favorites
      } else {
        favoriteProperties.add(propertyId); // Add to favorites
      }
    });
    await _saveFavorites();
  }

  // Load saved favorites from SharedPreferences
  // ✅ Load favorites and update FavoriteService
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favorite_properties') ?? [];
    setState(() {
      favoriteProperties = savedFavorites.map(int.parse).toSet();
      FavoriteService.loggedInFavorites = favoriteProperties;
    });
  }

// ✅ Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorite_properties',
      favoriteProperties.map((id) => id.toString()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⏳ Wait for shared pref login token before rendering UI
    // if (!isDataRead) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }

    // Still allow shimmer if loading API after login read
    // if (_isLoading) {
    //   return Scaffold(
    //     body: ListView.builder(
    //       itemCount: 5,
    //       itemBuilder: (context, index) => const ShimmerCard(),
    //     ),
    //   );
    // }

    Size screenSize = MediaQuery.sizeOf(context);
    return Consumer<FilterProvider>(builder: (context, filterProvider, _) {
      return Scaffold(
        bottomNavigationBar: SafeArea(
          child: buildMyNavBar(context),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Scroll content
            Column(children: <Widget>[
              const SizedBox(height: 10),
              Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Buttn
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20), // ✅ Move margin outside
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior:
                                  Clip.hardEdge, // ✅ Needed for proper tap area
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () async {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Home(),
                                      ));
                                  // Navigator.pop(context);
                                  // FocusScope.of(context).unfocus();
                                  // final result =
                                  // await Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => Filter(
                                  //         data: (purpose.isEmpty
                                  //             ? selectedPurposeText
                                  //             : purpose)),
                                  //   ),
                                  // );
                                  //
                                  // if (result != null) {
                                  //   // Optionally update anything with result
                                  //   print("Returned: $result");
                                  // }
                                },
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: _iconBoxDecoration(),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    "assets/images/ar-left.png",
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Consumer<FilterProvider>(
                                builder: (context, resetState, _) {
                                  final canReset = resetState.hasChanges;

                                  return TextButton(
                                    onPressed: canReset
                                        ? resetState.isResetLoading
                                            ? null
                                            : () async {
                                                await resetState.resetAll(
                                                    context,
                                                    isUpdate: true);
                                                resetState
                                                    .captureInitialSnapshot(); // NEW SNAPSHOT
                                                _scrollController.jumpTo(0);
                                              }
                                        : null,
                                    child: resetState.isResetLoading
                                        ? CupertinoActivityIndicator(
                                            radius: 13,
                                          )
                                        : Text(
                                            "Reset",
                                            style: TextStyle(
                                              color: canReset
                                                  ? Colors.red
                                                  : Colors.grey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  );
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              //filter
              Padding(
                padding:
                    const EdgeInsets.only(left: 0, right: 3, top: 5, bottom: 5),
                child: SizedBox(
                  // margin: const EdgeInsets.symmetric(vertical: 1),
                  height: 50,
                  // color: Colors.grey,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      //text
                      Padding(
                        padding: const EdgeInsets.only(left: 13),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => Filter(data: "Rent")));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 0.0),
                            child: Center(
                              child: Row(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 2, right: 8),
                                      child: Image.asset(
                                        "assets/images/filter.png",
                                        height: 17,
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 1.0, right: 10),
                                    child: Text(
                                      'Filters',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // BUY OR RENT
                      GestureDetector(
                        onTap: () {
                          filterProvider.setSelectedFilterListProductLocally(
                              filterProvider.selectedproduct!);

                          filterProvider.setSelectedFilterListCompletionStatus(
                              index: filterProvider.selectedCompletion);

                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            isScrollControlled: true,
                            builder: (context) {
                              return Consumer<FilterProvider>(
                                  builder: (context, purposeState, _) {
                                return Container(
                                  height:
                                      purposeState.filterListSelectedProduct ==
                                              0
                                          ? screenSize.height * 0.38
                                          : screenSize.height * 0.3,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration:
                                      const BoxDecoration(color: Colors.white),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      const Text("Purpose",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      const Text("Choose your purpose"),
                                      const SizedBox(height: 10),

                                      // Purpose list
                                      SizedBox(
                                        height: 50,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              purposeState.product.length,
                                          itemBuilder: (context, index) {
                                            bool isSelected = purposeState
                                                    .filterListSelectedProduct ==
                                                index;
                                            return GestureDetector(
                                              onTap: () {
                                                purposeState
                                                    .setSelectedFilterListProductLocally(
                                                        index);
                                                // selectedproduct = index;
                                                // purpose = _product[index];
                                                // selectedPurposeText =
                                                //     _product[index];
                                                //
                                                // // refresh available property types for the new purpose (and location if set)
                                                // await propertyApi(purpose,
                                                //     location:
                                                //         selectedLocation);
                                                //
                                                // // reset selection only if you want to neutralize cross-purpose types
                                                // setState(() {
                                                //   selectedtype = null;
                                                //   property_type =
                                                //       'All Residential'; // UI label only; query removes it
                                                // });

                                                // Navigator.pop(context);
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.blueAccent
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 2)),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    purposeState.product[index],
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      if (purposeState
                                              .filterListSelectedProduct ==
                                          0) ...[
                                        const SizedBox(height: 1),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Completion Status',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 15),

                                            // Pills row (scrollable if needed)
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: List.generate(
                                                    filterProvider.completion
                                                        .length, (i) {
                                                  final bool isSelected =
                                                      filterProvider
                                                              .filterListSelectedCompletion ==
                                                          i;

                                                  return GestureDetector(
                                                    onTap: () async {
                                                      await filterProvider
                                                          .setSelectedFilterListCompletionStatus(
                                                        index: i,
                                                      );
                                                    },
                                                    child: Container(
                                                      // auto width based on label
                                                      constraints:
                                                          const BoxConstraints(
                                                              minHeight: 34),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFFF5F4F9)
                                                            : Colors.white,
                                                        border: Border.all(
                                                          color: isSelected
                                                              ? Colors.black
                                                              : const Color(
                                                                  0xFFE6E4EE),
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.15),
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                            blurRadius: 4,
                                                            spreadRadius: 0,
                                                          ),
                                                          BoxShadow(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.9),
                                                            offset:
                                                                const Offset(
                                                                    -2, -2),
                                                            blurRadius: 6,
                                                            spreadRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        filterProvider
                                                            .completion[i],
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          letterSpacing: 0.2,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],

                                      const SizedBox(height: 20),

                                      // Show Results button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            // <-- add async here
                                            // await _resetPagingAndFetch();

                                            await purposeState
                                                .setSelectedProductType(
                                              context,
                                              purposeState
                                                  .filterListSelectedProduct!,
                                            );

                                            await filterProvider
                                                .setSelectedCompletionStatus(
                                              context,
                                              index: filterProvider
                                                  .filterListSelectedCompletion,
                                            );

                                            purposeState
                                                .updateFilterCount(context);

                                            _scrollController.jumpTo(0);

                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          child: const Text(
                                            "Showing Results",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 3, bottom: 3, right: 10),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 40,
                              maxHeight: 40,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(width: 1),
                              borderRadius:
                                  BorderRadiusDirectional.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(0.3, 0.3),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                filterProvider
                                    .purpose, // Show current selected text here
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),

                      //PROPERTY TYPE
                      GestureDetector(
                        onTap: () async {
                          await filterProvider
                              .setSelectedFilterListPropertyType(
                                  index: filterProvider.selectedPropType);

                          filterProvider.setSelectedFilterListPropertyCategory(
                            filterProvider.selectedtype,
                          );

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (context) {
                              return Consumer<FilterProvider>(
                                  builder: (context, propertyTypeState, _) {
                                return Container(
                                  height: filterProvider
                                              .filterListSelectedPropType ==
                                          null
                                      ? 250
                                      : screenSize.height * 0.38,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 20),
                                  decoration:
                                      const BoxDecoration(color: Colors.white),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Property Type",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5),
                                      ),
                                      const SizedBox(height: 15),
                                      if (filterProvider
                                              .filterListSelectedPropType ==
                                          null) ...[Gap(5)],

                                      Row(
                                        children: [
                                          const SizedBox(width: 12),

                                          // Residential
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                await propertyTypeState
                                                    .setSelectedFilterListPropertyType(
                                                        index: 0);
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 150),
                                                height: 40,
                                                alignment: Alignment.center,
                                                margin: const EdgeInsets.only(
                                                    right: 8),
                                                decoration: BoxDecoration(
                                                  // selected: subtle gray gradient; unselected: white
                                                  gradient: propertyTypeState
                                                              .filterListSelectedPropType ==
                                                          0
                                                      ? const LinearGradient(
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                          colors: [
                                                            Color(0xFFF5F4F9),
                                                            Color(0xFFEFEFF3)
                                                          ],
                                                        )
                                                      : null,
                                                  color: propertyTypeState
                                                              .filterListSelectedPropType ==
                                                          0
                                                      ? null
                                                      : Colors.white,
                                                  border: Border.all(
                                                    color: propertyTypeState
                                                                .filterListSelectedPropType ==
                                                            0
                                                        ? Colors.black
                                                        : Color(0xFFE6E4EE),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.06),
                                                      offset:
                                                          const Offset(0, 3),
                                                      blurRadius: 6,
                                                      spreadRadius: 0,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                      offset:
                                                          const Offset(-2, -2),
                                                      blurRadius: 6,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: const Text(
                                                  'Residential',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Commercial
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                await propertyTypeState
                                                    .setSelectedFilterListPropertyType(
                                                  index: 1,
                                                );
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 150),
                                                height: 40,
                                                alignment: Alignment.center,
                                                margin: const EdgeInsets.only(
                                                    left: 8, right: 12),
                                                decoration: BoxDecoration(
                                                  gradient: propertyTypeState
                                                              .filterListSelectedPropType ==
                                                          1
                                                      ? const LinearGradient(
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                          colors: [
                                                            Color(0xFFF5F4F9),
                                                            Color(0xFFEFEFF3)
                                                          ],
                                                        )
                                                      : null,
                                                  color: propertyTypeState
                                                              .filterListSelectedPropType ==
                                                          1
                                                      ? null
                                                      : Colors.white,
                                                  border: Border.all(
                                                    color: propertyTypeState
                                                                .filterListSelectedPropType ==
                                                            1
                                                        ? Colors.black
                                                        : Color(0xFFE6E4EE),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.06),
                                                      offset:
                                                          const Offset(0, 3),
                                                      blurRadius: 6,
                                                      spreadRadius: 0,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                      offset:
                                                          const Offset(-2, -2),
                                                      blurRadius: 6,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: const Text(
                                                  'Commercial',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (filterProvider
                                              .filterListSelectedPropType ==
                                          null) ...[Gap(20)],

                                      if (filterProvider
                                              .filterListSelectedPropType !=
                                          null) ...[
                                        const SizedBox(height: 15),

                                        // Property Type Cards
                                        SizedBox(
                                          height: screenSize.height * 0.12,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: propertyTypeState
                                                    .filterListPropertyTypeModel
                                                    ?.data
                                                    ?.length ??
                                                0,
                                            itemBuilder: (context, index) {
                                              final item = propertyTypeState
                                                  .filterListPropertyTypeModel!
                                                  .data![index];
                                              final isSelected = propertyTypeState
                                                      .filterListSelectedType ==
                                                  index;

                                              return GestureDetector(
                                                onTap: () async {
                                                  propertyTypeState
                                                      .setSelectedFilterListPropertyCategory(
                                                          index);
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFFEEEEEE)
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 0),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.network(
                                                        item.icon.toString(),
                                                        height: 35,
                                                      ),
                                                      // CachedNetworkImage(
                                                      //   imageUrl:
                                                      //       item.icon.toString(),
                                                      //   height: 35,
                                                      //   placeholder: (context,
                                                      //           url) =>
                                                      //       const CupertinoActivityIndicator(
                                                      //     radius: 14,
                                                      //   ),
                                                      //   errorWidget: (context,
                                                      //           url, error) =>
                                                      //       const Icon(
                                                      //           Icons.error,
                                                      //           size: 35),
                                                      // ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        item.name.toString(),
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color: isSelected
                                                              ? Colors.black
                                                              : Colors.black87,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 10),

                                      // Confirm Button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await propertyTypeState
                                                .setSelectedPropertyType(
                                                    context,
                                                    index: propertyTypeState
                                                        .filterListSelectedPropType);

                                            if (propertyTypeState
                                                    .filterListSelectedType !=
                                                null) {
                                              await propertyTypeState
                                                  .setSelectedPropertyCategoryType(
                                                context,
                                                index: propertyTypeState
                                                    .filterListSelectedType!,
                                              );
                                            }
                                            propertyTypeState
                                                .updateFilterCount(context);

                                            _scrollController.jumpTo(0);

                                            // await _resetPagingAndFetch();
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                          ),
                                          child: const Text(
                                            "Showing Results",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (filterProvider
                                              .filterListSelectedPropType ==
                                          null) ...[Gap(15)],
                                    ],
                                  ),
                                );
                              });
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 3, bottom: 3, right: 10),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 40, // SAME as Price Range
                              maxHeight: 40,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12), // SAME as Price Range
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(width: 1),
                              borderRadius:
                                  BorderRadiusDirectional.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(0.3, 0.3),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                (filterProvider.property_type.trim().isEmpty
                                    ? filterProvider.selectedPropType == null
                                        ? 'Property Type'
                                        : filterProvider.selectedPropType == 0
                                            ? 'Residential'
                                            : 'Commercial'
                                    : filterProvider.property_type.trim()),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),

                      //Price Range
                      GestureDetector(
                        onTap: () {
                          String min = filterProvider.min_price;
                          String max = filterProvider.max_price;
                          if (min.isNotEmpty && max.isNotEmpty) {
                            double _minPrice = double.parse(min);
                            double _maxPrice = double.parse(max);

                            filterProvider.setSelectedFilterRangePriceRange(
                                minPrice: _minPrice, maxPrice: _maxPrice);
                          } else {
                            filterProvider.setSelectedFilterRangePriceRange(
                                minPrice: 500, maxPrice: 300000);
                          }

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (context) {
                              return Consumer<FilterProvider>(
                                  builder: (context, priceRangeState, _) {
                                return Container(
                                  height: screenSize.height * 0.38,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 20),
                                  decoration:
                                      const BoxDecoration(color: Colors.white),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: const Text(
                                          "Price range",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _rangeDisplayBox(priceRangeState
                                                .filterListValues.start
                                                .toStringAsFixed(0)),
                                            const Text("to",
                                                style: TextStyle(fontSize: 15)),
                                            _rangeDisplayBox(priceRangeState
                                                .filterListValues.end
                                                .toStringAsFixed(0)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: SfRangeSelectorTheme(
                                          data: SfRangeSelectorThemeData(
                                            tooltipBackgroundColor:
                                                Colors.black,
                                            tooltipTextStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          child: SfRangeSelector(
                                            min: 500,
                                            max: 300000,
                                            interval: 10000,
                                            activeColor:
                                                const Color(0xFF2575D4),
                                            inactiveColor:
                                                const Color(0x80F1EEEE),
                                            enableTooltip: true,
                                            shouldAlwaysShowTooltip: true,
                                            initialValues: priceRangeState
                                                .filterListValues,
                                            tooltipTextFormatterCallback:
                                                (actualValue, _) =>
                                                    'AED ${actualValue.toInt()}',
                                            onChanged: (value) {
                                              // setModalState(() {
                                              double roundedMin =
                                                  ((value.start / 100).round() *
                                                          100)
                                                      .toDouble();
                                              double roundedMax =
                                                  ((value.end / 100).round() *
                                                          100)
                                                      .toDouble();

                                              // priceRangeState.filterListValues =
                                              //     SfRangeValues(
                                              //         roundedMin, roundedMax);
                                              //
                                              // min_price =
                                              //     roundedMin.toStringAsFixed(0);
                                              // max_price =
                                              //     roundedMax.toStringAsFixed(0);

                                              filterProvider
                                                  .setSelectedFilterRangePriceRange(
                                                minPrice: roundedMin,
                                                maxPrice: roundedMax,
                                              );
                                              // });

                                              // Trigger light haptic feedback on slide
                                              HapticFeedback.selectionClick();
                                            },
                                            child: SizedBox(
                                              height: 60,
                                              width: double.infinity,
                                              child: SfCartesianChart(
                                                backgroundColor:
                                                    Colors.transparent,
                                                plotAreaBorderColor:
                                                    Colors.transparent,
                                                margin: const EdgeInsets.all(0),
                                                primaryXAxis: NumericAxis(
                                                    minimum: 500,
                                                    maximum: 10000,
                                                    isVisible: false),
                                                primaryYAxis: NumericAxis(
                                                    isVisible: false),
                                                plotAreaBorderWidth: 0,
                                                plotAreaBackgroundColor:
                                                    Colors.transparent,
                                                series: <ColumnSeries<Data,
                                                    double>>[
                                                  ColumnSeries<Data, double>(
                                                    dataSource: chartData,
                                                    xValueMapper:
                                                        (Data sales, _) =>
                                                            sales.x,
                                                    yValueMapper:
                                                        (Data sales, _) =>
                                                            sales.y,
                                                    pointColorMapper: (_, __) =>
                                                        const Color.fromARGB(
                                                            255, 37, 117, 212),
                                                    animationDuration: 0,
                                                    borderWidth: 0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 45,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // await _resetPagingAndFetch();

                                              double finalMinPrice =
                                                  double.parse(filterProvider
                                                      .filterList_Min_price);
                                              double finalMaxPrice =
                                                  double.parse(filterProvider
                                                      .filterList_Max_price);

                                              // filterProvider
                                              //     .setSelectedFilterRangePriceRange(
                                              //         minPrice: finalMinPrice,
                                              //         maxPrice: finalMaxPrice);

                                              setState(() {
                                                filterProvider.values =
                                                    SfRangeValues(finalMinPrice,
                                                        finalMaxPrice);

                                                filterProvider
                                                    .priceRangeController
                                                    .start = finalMinPrice;
                                                filterProvider
                                                    .priceRangeController
                                                    .end = finalMaxPrice;

                                                filterProvider.min_price =
                                                    finalMinPrice
                                                        .toStringAsFixed(0);
                                                filterProvider.max_price =
                                                    finalMaxPrice
                                                        .toStringAsFixed(0);

                                                // ✅ Force update min only if not currently editing, or if value actually changed
                                                if (!filterProvider
                                                        .isMinTyping ||
                                                    filterProvider
                                                            .minPriceController
                                                            .text !=
                                                        finalMinPrice
                                                            .toStringAsFixed(
                                                                0)) {
                                                  filterProvider
                                                          .minPriceController
                                                          .text =
                                                      finalMinPrice
                                                          .toStringAsFixed(0);
                                                }

                                                if (!filterProvider
                                                        .isMaxTyping ||
                                                    filterProvider
                                                            .maxPriceController
                                                            .text !=
                                                        finalMaxPrice
                                                            .toStringAsFixed(
                                                                0)) {
                                                  filterProvider
                                                          .maxPriceController
                                                          .text =
                                                      finalMaxPrice
                                                          .toStringAsFixed(0);
                                                }
                                              });

                                              await filterProvider
                                                  .updateFilterCount(context);

                                              _scrollController.jumpTo(0);

                                              Navigator.pop(
                                                  context); // Close the bottom sheet after showing result
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                            ),
                                            child: const Text(
                                              "Showing Results",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 3, bottom: 3, right: 10),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 40,
                              maxHeight: 40,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(width: 1),
                              borderRadius:
                                  BorderRadiusDirectional.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(0.3, 0.3),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Text(
                                "Price Range",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),

                      ////// AREA / SIZE ////////

                      GestureDetector(
                        onTap: () {
                          String minArea = filterProvider.min_sqrfeet;
                          String maxArea = filterProvider.max_sqrfeet;
                          if (minArea.isNotEmpty && maxArea.isNotEmpty) {
                            double _minArea = double.parse(minArea);
                            double _maxArea = double.parse(maxArea);

                            filterProvider.setSelectedFilterListAreaSize(
                                minSqrFeet: _minArea, maxSqrFeet: _maxArea);
                          } else {
                            filterProvider.setSelectedFilterListAreaSize(
                                minSqrFeet: 0.0, maxSqrFeet: 10000.0);
                          }

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (context) {
                              return Consumer<FilterProvider>(
                                  builder: (context, areaSizeState, _) {
                                return Container(
                                  height: screenSize.height * 0.38,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 20),
                                  decoration:
                                      const BoxDecoration(color: Colors.white),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: const Text(
                                          "Area Range",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _rangeDisplayBox(areaSizeState
                                                .filterListValuesArea.start
                                                .toStringAsFixed(0)),
                                            const Text("to",
                                                style: TextStyle(fontSize: 15)),
                                            _rangeDisplayBox(areaSizeState
                                                .filterListValuesArea.end
                                                .toStringAsFixed(0)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: SfRangeSelectorTheme(
                                          data: SfRangeSelectorThemeData(
                                            tooltipBackgroundColor:
                                                Colors.black,
                                            tooltipTextStyle: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          child: SfRangeSelector(
                                            min: 0,
                                            max: 10000,
                                            interval: 1000,
                                            initialValues: areaSizeState
                                                .filterListValuesArea,
                                            enableTooltip: true,
                                            shouldAlwaysShowTooltip: true,
                                            activeColor:
                                                const Color(0xFF2575D4),
                                            inactiveColor:
                                                const Color(0x80F1EEEE),
                                            // controller:
                                            //     areaSizeState.areaRangeController,
                                            onChanged: (value) async {
                                              // await filterProvider
                                              //     .setSelectedAreaRange(context,
                                              //         value: value);

                                              double roundedMin =
                                                  ((value.start / 100).round() *
                                                          100)
                                                      .toDouble();
                                              double roundedMax =
                                                  ((value.end / 100).round() *
                                                          100)
                                                      .toDouble();

                                              areaSizeState
                                                  .setSelectedFilterListAreaSize(
                                                minSqrFeet: roundedMin,
                                                maxSqrFeet: roundedMax,
                                              );
                                              // Trigger light haptic feedback on slide
                                              HapticFeedback.selectionClick();
                                            },
                                            child: SizedBox(
                                              height: 70,
                                              width: double.infinity,
                                              child: SfCartesianChart(
                                                plotAreaBorderColor:
                                                    Colors.transparent,
                                                margin: const EdgeInsets.all(0),
                                                primaryXAxis: NumericAxis(
                                                    minimum: 0,
                                                    maximum: 10000,
                                                    isVisible: false),
                                                primaryYAxis: NumericAxis(
                                                    isVisible: false),
                                                plotAreaBorderWidth: 0,
                                                plotAreaBackgroundColor:
                                                    Colors.transparent,
                                                series: <ColumnSeries<Dataarea,
                                                    double>>[
                                                  ColumnSeries<Dataarea,
                                                      double>(
                                                    dataSource: areaSizeState
                                                        .chartDataarea,
                                                    selectionBehavior:
                                                        SelectionBehavior(
                                                      unselectedOpacity: 0,
                                                      selectedOpacity: 0,
                                                      unselectedColor:
                                                          Colors.transparent,
                                                      // selectionController:
                                                      // areaSizeState
                                                      //     .rangeControllerarea,
                                                    ),
                                                    xValueMapper:
                                                        (Dataarea sales,
                                                                int index) =>
                                                            sales.x,
                                                    yValueMapper:
                                                        (Dataarea sales,
                                                                int index) =>
                                                            sales.y,
                                                    pointColorMapper: (Dataarea
                                                                sales,
                                                            int index) =>
                                                        const Color.fromARGB(
                                                            255, 37, 117, 212),
                                                    dashArray: const <double>[
                                                      5,
                                                      3
                                                    ],
                                                    animationDuration: 0,
                                                    borderWidth: 0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 45,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // await _resetPagingAndFetch();

                                              double finalMinSqrFeet =
                                                  double.parse(filterProvider
                                                      .filterList_Min_sqr_feet);
                                              double finalMaxSqrFeet =
                                                  double.parse(filterProvider
                                                      .filterList_Max_sqr_feet);

                                              // filterProvider
                                              //     .setSelectedFilterRangePriceRange(
                                              //         minPrice: finalMinPrice,
                                              //         maxPrice: finalMaxPrice);

                                              setState(() {
                                                filterProvider
                                                    .areaRangeController
                                                    .start = finalMinSqrFeet;
                                                filterProvider
                                                    .areaRangeController
                                                    .end = finalMaxSqrFeet;
                                                filterProvider
                                                        .filterListValuesArea =
                                                    SfRangeValues(
                                                        finalMinSqrFeet,
                                                        finalMaxSqrFeet);
                                                filterProvider.min_sqrfeet =
                                                    finalMinSqrFeet
                                                        .toStringAsFixed(0);
                                                filterProvider.max_sqrfeet =
                                                    finalMaxSqrFeet
                                                        .toStringAsFixed(0);

                                                // ✅ Force update min only if not currently editing, or if value actually changed
                                                if (!filterProvider
                                                        .isMinAreaTyping ||
                                                    filterProvider
                                                            .minAreaController
                                                            .text !=
                                                        finalMinSqrFeet
                                                            .toStringAsFixed(
                                                                0)) {
                                                  filterProvider
                                                          .minAreaController
                                                          .text =
                                                      finalMinSqrFeet
                                                          .toStringAsFixed(0);
                                                }

                                                if (!filterProvider
                                                        .isMaxAreaTyping ||
                                                    filterProvider
                                                            .maxAreaController
                                                            .text !=
                                                        finalMaxSqrFeet
                                                            .toStringAsFixed(
                                                                0)) {
                                                  filterProvider
                                                          .maxAreaController
                                                          .text =
                                                      finalMaxSqrFeet
                                                          .toStringAsFixed(0);
                                                }
                                              });

                                              await filterProvider
                                                  .updateFilterCount(context);

                                              _scrollController.jumpTo(0);

                                              Navigator.pop(
                                                  context); // Close the bottom sheet after showing result
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                            ),
                                            child: const Text(
                                              "Showing Results",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 3, bottom: 3, right: 10),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 40,
                              maxHeight: 40,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(width: 1),
                              borderRadius:
                                  BorderRadiusDirectional.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(0.3, 0.3),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Text(
                                "Area",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),

                      //BEDROOM
                      GestureDetector(
                        onTap: () {
                          filterProvider.selectedFilterListBedroomsList =
                              List.from(filterProvider.selectedBedrooms);

                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            isScrollControlled: true,
                            builder: (context) {
                              return Consumer<FilterProvider>(
                                  builder: (context, bedroomState, _) {
                                return Container(
                                  height: screenSize.height * 0.3,
                                  width: double.infinity,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 40.0, left: 20, bottom: 0),
                                            child: Text(
                                              "Bedrooms",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Bedroom list
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, left: 15, right: 10),
                                        child: SizedBox(
                                          height: 60,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics: const ScrollPhysics(),
                                            itemCount:
                                                bedroomState.bedroomList.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              final isSelected = bedroomState
                                                  .selectedFilterListBedroomsList
                                                  .contains(bedroomState
                                                      .bedroomList[index]);
                                              return GestureDetector(
                                                onTap: () async {
                                                  bedroomState
                                                      .setSelectedFilterListBedrooms(
                                                          index: index);
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Colors.blueAccent
                                                        : Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        offset: Offset(0, 2),
                                                        blurRadius: 4,
                                                        spreadRadius: 0,
                                                      ),
                                                      BoxShadow(
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                        offset: Offset(-4, -4),
                                                        blurRadius: 8,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      bedroomState
                                                          .bedroomList[index],
                                                      style: TextStyle(
                                                        color: isSelected
                                                            ? Colors.white
                                                            : Colors.black,
                                                        letterSpacing: 0.5,
                                                        fontSize: 18,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // Show Results button
                                      GestureDetector(
                                        onTap: () async {
                                          filterProvider.selectedBedrooms =
                                              List.from(filterProvider
                                                  .selectedFilterListBedroomsList);

                                          await filterProvider
                                              .updateFilterCount(context);

                                          _scrollController.jumpTo(0);

                                          // await _resetPagingAndFetch();

                                          Navigator.pop(
                                              context); // ✅ Close BottomSheet after API call
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 25.0,
                                              left: 15,
                                              bottom: 15,
                                              right: 15),
                                          child: Container(
                                            width: screenSize.width * 0.9,
                                            height: 45,
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadiusDirectional
                                                      .circular(6.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset:
                                                      const Offset(0.3, 0.3),
                                                  blurRadius: 0.3,
                                                  spreadRadius: 0.3,
                                                ),
                                                BoxShadow(
                                                  color: Colors.white,
                                                  offset:
                                                      const Offset(0.0, 0.0),
                                                  blurRadius: 0.0,
                                                  spreadRadius: 0.0,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              "Showing Results",
                                              style: TextStyle(
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 3, bottom: 3, right: 10),
                          child: Container(
                            width: 90,
                            height: 10,
                            padding: const EdgeInsets.only(left: 0, top: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(width: 1),
                              borderRadius:
                                  BorderRadiusDirectional.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(0.3, 0.3),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                            ),
                            child: Text(
                              " Bedroom", // add 1 space in front for same alignment as " Bathroom"
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      //bathroom
                      GestureDetector(
                        onTap: () {
                          filterProvider.selectedFilterListBathroomsList =
                              List.from(filterProvider.selectedBathrooms);

                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            isScrollControlled: true,
                            builder: (context) {
                              return Consumer<FilterProvider>(
                                builder:
                                    (BuildContext context, bathRoomState, _) {
                                  return Container(
                                    height: screenSize.height * 0.3,
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 40.0,
                                                  left: 20,
                                                  bottom: 0),
                                              // child:  Text(bedroom,
                                              child: Text(
                                                "Bathrooms",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, left: 17, right: 10),
                                            child: Container(
                                              //color: Colors.grey,
                                              // width: 60,
                                              alignment: Alignment.topLeft,
                                              height: 60,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                physics: const ScrollPhysics(),
                                                itemCount: bathRoomState
                                                    .bathroomList.length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  final isSelected = bathRoomState
                                                      .selectedFilterListBathroomsList
                                                      .contains(bathRoomState
                                                          .bathroomList[index]);
                                                  // Colors.grey;
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      bathRoomState
                                                          .setSelectedFilterListBathrooms(
                                                              index: index);
                                                    },
                                                    child: Container(
                                                      // color: selectedIndex == index ? Colors.amber : Colors.transparent,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5,
                                                              top: 5,
                                                              bottom: 5),
                                                      width:
                                                          50, // ✅ smaller fixed width (you can adjust)
                                                      height: 20,
                                                      // width: screenSize.width * 0.25,
                                                      // height: 20,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0,
                                                              left: 15,
                                                              right: 15),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? Colors.blueAccent
                                                            : Colors.white,
                                                        // color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            offset:
                                                                Offset(4, 4),
                                                            blurRadius: 8,
                                                            spreadRadius: 2,
                                                          ),
                                                          BoxShadow(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.8),
                                                            offset:
                                                                Offset(-4, -4),
                                                            blurRadius: 8,
                                                            spreadRadius: 2,
                                                          ),
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          filterProvider
                                                                  .bathroomList[
                                                              index],
                                                          style: TextStyle(
                                                            color: isSelected
                                                                ? Colors.white
                                                                : Colors.black,
                                                            letterSpacing: 0.5,
                                                            fontSize: 15,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )),
                                        GestureDetector(
                                          onTap: () async {
                                            filterProvider.selectedBathrooms =
                                                List.from(filterProvider
                                                    .selectedFilterListBathroomsList);

                                            await filterProvider
                                                .updateFilterCount(context);

                                            _scrollController.jumpTo(0);

                                            // await _resetPagingAndFetch();

                                            Navigator.pop(
                                                context); // ✅ Close BottomSheet after API call
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 25.0,
                                                left: 15,
                                                bottom: 15,
                                                right: 15),
                                            child: Container(
                                              // color: Colors.red,
                                              width: screenSize.width * 0.9,
                                              height: 45,
                                              // color: Colors.red,
                                              padding: const EdgeInsets.only(
                                                  top: 10, left: 0),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadiusDirectional
                                                        .circular(6.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: const Offset(
                                                      0.3,
                                                      0.3,
                                                    ),
                                                    blurRadius: 0.3,
                                                    spreadRadius: 0.3,
                                                  ), //BoxShadow
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    offset:
                                                        const Offset(0.0, 0.0),
                                                    blurRadius: 0.0,
                                                    spreadRadius: 0.0,
                                                  ), //BoxShadow
                                                ],
                                              ),
                                              child: Text(
                                                "Showing Results",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 3, bottom: 3, right: 10),
                          child: Container(
                            width: 90,
                            height: 10,
                            padding: const EdgeInsets.only(left: 0, top: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 1,
                              ),
                              borderRadius:
                                  BorderRadiusDirectional.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(
                                    0.3,
                                    0.3,
                                  ),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ), //BoxShadow
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ), //BoxShadow
                              ],
                            ),
                            child: Text(
                              " Bathroom",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                    top: 5, left: 16, right: 15, bottom: 8),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${filterProvider.displayedFilterResultCount} Properties',
                        style: TextStyle(
                            fontSize: 14.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    PopupMenuButton<String>(
                      elevation: 0,
                      // onSelected: (value) {
                      //   // setState(() {
                      //   //   selectedSort = value;
                      //   //   // 🔁 Call your sorting/filter logic here
                      //   // });
                      // },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      offset: const Offset(0, 35),
                      color:
                          Colors.white, // Needed to style the container inside
                      itemBuilder: (context) {
                        final List<String> sortOptions =
                            filterProvider.ftypeList;

                        return [
                          PopupMenuItem<String>(
                            enabled: false,
                            padding: EdgeInsets.zero,
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color:
                                    Colors.white, // 👈 Your dropdown background
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: sortOptions.map((option) {
                                  return InkWell(
                                    onTap: () async {
                                      Navigator.pop(context);

                                      final selectedFurnishedType =
                                          filterProvider.ftypeList
                                              .indexOf(option);

                                      await filterProvider
                                          .setSelectedFurnishedType(
                                        context,
                                        index: selectedFurnishedType,
                                      );
                                      await filterProvider
                                          .updateFilterCount(context);

                                      _scrollController.jumpTo(0);
                                    },
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                option,
                                                style: const TextStyle(
                                                    color: Colors
                                                        .black), // 👈 Black text
                                              ),
                                              if (sortOptions[filterProvider
                                                          .selectedIndex ??
                                                      0] ==
                                                  option)
                                                const Icon(Icons.check,
                                                    color: Colors.green,
                                                    size: 18),
                                            ],
                                          ),
                                        ),
                                        if (option != sortOptions.last)
                                          const Divider(
                                              height: 1,
                                              thickness: 0.5,
                                              color: Colors.grey),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ];
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/filter.png",
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(filterProvider
                                .ftypeList[filterProvider.selectedIndex ?? 0]
                                .toString()), // 👉 No TextStyle here
                            const Icon(Icons.arrow_drop_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //filters
              // Padding(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              //     child: Container(
              //       alignment: Alignment.topLeft,
              //       height: 50,
              //       child: ListView.builder(
              //         scrollDirection: Axis.horizontal,
              //         physics: const ScrollPhysics(),
              //         itemCount: filterProvider.ftypeList.length,
              //         shrinkWrap: true,
              //         itemBuilder: (context, index) {
              //           // Colors.grey;
              //           return Container(
              //             margin: const EdgeInsets.all(5),
              //             padding: const EdgeInsets.only(
              //                 top: 0, left: 15, right: 15),
              //             decoration: BoxDecoration(
              //               color: filterProvider.selectedIndex == index
              //                   ? Colors.blueAccent
              //                   : Colors.white, // Change color if selected
              //               // color: Colors.white,
              //               boxShadow: [
              //                 BoxShadow(
              //                   color: Colors.grey.withOpacity(0.5),
              //                   offset: Offset(0, 2),
              //                   blurRadius: 4,
              //                   spreadRadius: 0,
              //                 ),
              //                 BoxShadow(
              //                   color: Colors.white.withOpacity(0.8),
              //                   offset: Offset(-4, -4),
              //                   blurRadius: 8,
              //                   spreadRadius: 2,
              //                 ),
              //               ],
              //               borderRadius: BorderRadius.circular(8),
              //             ),
              //             child: GestureDetector(
              //               onTap: () async {
              //                 await filterProvider.setSelectedFurnishedType(
              //                   context,
              //                   index: index,
              //                 );
              //                 await filterProvider.updateFilterCount(context);
              //               },
              //               child: Center(
              //                 child: Text(
              //                   filterProvider.ftypeList[index],
              //                   style: TextStyle(
              //                     color: filterProvider.selectedIndex == index
              //                         ? Colors.white
              //                         : Colors.black,
              //                     letterSpacing: 0.5,
              //                     fontSize: 14,
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                   textAlign: TextAlign.center,
              //                 ),
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //     )),

              filterProvider.isFilterListFilterModelLoading &&
                      filterProvider.filterModel == null
                  ? Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 8),
                        itemCount: 5,
                        shrinkWrap: true,
                        // physics:
                        //     const NeverScrollableScrollPhysics(), // ✅ make it non-scrollable
                        itemBuilder: (context, index) => const ShimmerCard(),
                      ),
                    )
                  : (filterProvider.filterModel?.data == null ||
                          filterProvider.filterModel!.data!.isEmpty)
                      ? Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            child: Center(
                              child: Text(
                                "Property Not Found",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 0),
                            scrollDirection: Axis.vertical,
                            // physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            // 👇 add one extra "row" for the loading spinner when fetching more
                            itemCount: (filterProvider
                                        .filterModel?.data?.length ??
                                    0) +
                                (filterProvider.nextPageUrl != null ? 1 : 0),

                            itemBuilder: (context, index) {
                              final items =
                                  filterProvider.filterModel?.data ?? [];

                              // 🔄 Show loader at end if next page exists
                              if (index == items.length &&
                                  filterProvider.nextPageUrl != null) {
                                return Center(
                                    child: const CircularProgressIndicator());
                              } else if (index == items.length &&
                                  filterProvider.nextPageUrl == null) {
                                return const SizedBox
                                    .shrink(); // Nothing more to show
                              }

                              // 🔐 Safety check (extra)
                              if (index >= items.length)
                                return const SizedBox.shrink();

                              final property = items[index];

                              return PropertyCard(item: property);

//                               return Padding(
//                                 padding: const EdgeInsets.only(
//                                   left: 5,
//                                   right: 5,
//                                   top: 3,
//                                   bottom: 8,
//                                 ),
//                                 child: Card(
//                                   elevation: 20,
//                                   shadowColor: Colors.white,
//                                   color: Colors.white,
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => Featured_Detail(
//                                               data: property.id.toString()),
//                                         ),
//                                       );
//                                     },
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 5.0, top: 1, right: 5),
//                                       child: Column(
//                                         children: [
//                                           Column(
//                                             children: [
//                                               Stack(
//                                                 clipBehavior: Clip.none,
//                                                 // ✅ Allows the overlap outside the Stack
//                                                 children: [
//                                                   // 🖼️ Property Image Carousel with Rounded Corners
//                                                   ClipRRect(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             12),
//                                                     child: AspectRatio(
//                                                       aspectRatio: 1.4,
//                                                       child: PageView.builder(
//                                                         controller:
//                                                             _pageController,
//                                                         scrollDirection:
//                                                             Axis.horizontal,
//                                                         itemCount: property
//                                                                 .media
//                                                                 ?.length ??
//                                                             0,
//                                                         onPageChanged: (index) {
//                                                           setState(() {
//                                                             _currentImageIndex =
//                                                                 index;
//                                                           });
//                                                         },
//                                                         itemBuilder: (context,
//                                                             imgIndex) {
//                                                           return CachedNetworkImage(
//                                                             imageUrl: property
//                                                                 .media![
//                                                                     imgIndex]
//                                                                 .originalUrl
//                                                                 .toString(),
//                                                             fit: BoxFit.cover,
//                                                             placeholder: (context,
//                                                                     url) =>
//                                                                 Shimmer
//                                                                     .fromColors(
//                                                               baseColor: Colors
//                                                                   .grey
//                                                                   .shade300,
//                                                               highlightColor:
//                                                                   Colors.grey
//                                                                       .shade100,
//                                                               child: Container(
//                                                                 width: double
//                                                                     .infinity,
//                                                                 height: 200,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                             ),
//                                                           );
//                                                         },
//                                                       ),
//                                                     ),
//                                                   ),
//
//                                                   // ⚪ Image Indicator Dots
//                                                   Positioned(
//                                                     bottom: 12,
//                                                     left: 0,
//                                                     right: 0,
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .center,
//                                                       children: List.generate(
//                                                         property.media
//                                                                 ?.length ??
//                                                             0,
//                                                         (index) {
//                                                           final distance = (index -
//                                                                   _currentImageIndex)
//                                                               .abs();
//                                                           double scale;
//                                                           double opacity;
//
//                                                           if (distance == 0) {
//                                                             scale = 1.2;
//                                                             opacity = 1.0;
//                                                           } else if (distance ==
//                                                               1) {
//                                                             scale = 1.0;
//                                                             opacity = 0.7;
//                                                           } else if (distance ==
//                                                               2) {
//                                                             scale = 0.8;
//                                                             opacity = 0.5;
//                                                           } else {
//                                                             scale = 0.5;
//                                                             opacity = 0.0;
//                                                           }
//
//                                                           return AnimatedOpacity(
//                                                             duration: Duration(
//                                                                 milliseconds:
//                                                                     300),
//                                                             opacity: opacity,
//                                                             child: SizedBox(
//                                                               width: 12,
//                                                               // fixed size for layout stability
//                                                               height: 12,
//                                                               child: Center(
//                                                                 child:
//                                                                     Container(
//                                                                   width:
//                                                                       8 * scale,
//                                                                   height:
//                                                                       8 * scale,
//                                                                   decoration:
//                                                                       BoxDecoration(
//                                                                     color: Colors
//                                                                         .white,
//                                                                     shape: BoxShape
//                                                                         .circle,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           );
//                                                         },
//                                                       ),
//                                                     ),
//                                                   ),
//
//                                                   // ❤️ Favorite Icon
//                                                   // ❤️ Favorite Icon
//
//                                                   // ❤️ Favorite Icon
//                                                   Positioned(
//                                                     top: 10,
//                                                     right: 10,
//                                                     child: Material(
//                                                       color: Colors.white,
//                                                       shape:
//                                                           const CircleBorder(),
//                                                       elevation: 4,
//                                                       child: Consumer<
//                                                           FavoriteProvider>(
//                                                         builder: (context,
//                                                             favProvider, _) {
//                                                           final isLoggedIn =
//                                                               token.isNotEmpty;
//                                                           final isFav = isLoggedIn &&
//                                                               favProvider
//                                                                   .isFavorite(
//                                                                       property
//                                                                           .id!); // ✅ Only true for logged-in users
//
//                                                           // debugPrint("fav length :${favProvider.fav}");
//
//                                                           return IconButton(
//                                                             icon: Icon(
//                                                               isFav
//                                                                   ? Icons
//                                                                       .favorite
//                                                                   : Icons
//                                                                       .favorite_border,
//                                                               color: isFav
//                                                                   ? Colors.red
//                                                                   : Colors
//                                                                       .grey, // ✅ Grey for logged-out users
//                                                               size: 20,
//                                                             ),
//                                                             onPressed:
//                                                                 () async {
//                                                               if (!isLoggedIn) {
//                                                                 // 🔒 Show login prompt
//                                                                 showDialog(
//                                                                   context:
//                                                                       context,
//                                                                   builder:
//                                                                       (ctx) =>
//                                                                           Dialog(
//                                                                     backgroundColor:
//                                                                         Colors
//                                                                             .transparent,
//                                                                     insetPadding:
//                                                                         EdgeInsets
//                                                                             .zero,
//                                                                     child:
//                                                                         Container(
//                                                                       height:
//                                                                           70,
//                                                                       margin: const EdgeInsets
//                                                                           .only(
//                                                                           bottom:
//                                                                               80,
//                                                                           left:
//                                                                               20,
//                                                                           right:
//                                                                               20),
//                                                                       decoration:
//                                                                           BoxDecoration(
//                                                                         color: Colors
//                                                                             .red,
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(10),
//                                                                       ),
//                                                                       child:
//                                                                           Stack(
//                                                                         clipBehavior:
//                                                                             Clip.none,
//                                                                         children: [
//                                                                           Positioned(
//                                                                             top:
//                                                                                 -14,
//                                                                             right:
//                                                                                 -10,
//                                                                             child:
//                                                                                 Material(
//                                                                               color: Colors.transparent,
//                                                                               child: IconButton(
//                                                                                 icon: const Icon(Icons.close, color: Colors.white, size: 20),
//                                                                                 onPressed: () => Navigator.of(ctx).pop(),
//                                                                                 padding: EdgeInsets.zero,
//                                                                                 constraints: const BoxConstraints(),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                           Positioned(
//                                                                             left:
//                                                                                 16,
//                                                                             right:
//                                                                                 16,
//                                                                             bottom:
//                                                                                 12,
//                                                                             child:
//                                                                                 Row(
//                                                                               children: [
//                                                                                 const Expanded(
//                                                                                   child: Text(
//                                                                                     'Login required to add favorites.',
//                                                                                     style: TextStyle(color: Colors.white, fontSize: 13),
//                                                                                   ),
//                                                                                 ),
//                                                                                 const SizedBox(width: 12),
//                                                                                 GestureDetector(
//                                                                                   onTap: () {
//                                                                                     Navigator.of(ctx).pop();
//                                                                                     Navigator.of(ctx).pushNamed('/login');
//                                                                                   },
//                                                                                   child: const Text(
//                                                                                     'Login',
//                                                                                     style: TextStyle(
//                                                                                       color: Colors.white,
//                                                                                       fontWeight: FontWeight.bold,
//                                                                                       decoration: TextDecoration.underline,
//                                                                                       decorationColor: Colors.white,
//                                                                                       decorationThickness: 1.5,
//                                                                                     ),
//                                                                                   ),
//                                                                                 ),
//                                                                               ],
//                                                                             ),
//                                                                           ),
//                                                                         ],
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 );
//                                                                 return;
//                                                               }
//
//                                                               // ✅ Use Provider's API-integrated method
//                                                               final success = await favProvider
//                                                                   .toggleFavoriteWithApi(
//                                                                       property
//                                                                           .id!,
//                                                                       token,
//                                                                       context);
//
//                                                               if (!success) {
//                                                                 ScaffoldMessenger.of(
//                                                                         context)
//                                                                     .showSnackBar(
//                                                                   const SnackBar(
//                                                                       content: Text(
//                                                                           "Failed to update favorite.")),
//                                                                 );
//                                                               }
//                                                             },
//                                                           );
//                                                         },
//                                                       ),
//                                                     ),
//                                                   ),
//
//                                                   // 👈 returns an empty widget when not logged in
//
//                                                   // 👈 Return nothing if not logged in
//
//                                                   // 🧑‍💼 Overlapping Agent Profile Image
//                                                   // 🧑‍💼 Overlapping Agent Profile Image
//                                                   // 🧑‍💼 Agent Profile with Navigation to Featured_Detail
//                                                   // 🟢 Positioned Circle Avatar (left: 10)
//                                                   Positioned(
//                                                     bottom: -30,
//                                                     left: 10,
//                                                     child: GestureDetector(
//                                                       onTap: () {
//                                                         Navigator.push(
//                                                           context,
//                                                           MaterialPageRoute(
//                                                             builder: (context) =>
//                                                                 Featured_Detail(
//                                                                     data: property
//                                                                         .id
//                                                                         .toString()),
//                                                           ),
//                                                         );
//                                                       },
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           CircleAvatar(
//                                                             radius: 28,
//                                                             backgroundImage: (property
//                                                                             .agentImage !=
//                                                                         null &&
//                                                                     property
//                                                                         .agentImage!
//                                                                         .isNotEmpty)
//                                                                 ? CachedNetworkImageProvider(
//                                                                     property
//                                                                         .agentImage!)
//                                                                 : const AssetImage(
//                                                                         "assets/images/dummy.jpg")
//                                                                     as ImageProvider,
//                                                           ),
//                                                           const SizedBox(
//                                                               height: 6),
//                                                           Transform.translate(
//                                                             offset: const Offset(
//                                                                 -5,
//                                                                 0), // shift 4 pixels to the left
//                                                             child: Text(
//                                                               "AGENT",
//                                                               style: TextStyle(
//                                                                 fontSize: 12,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w500,
//                                                                 color: Color(
//                                                                     0xFF1A73E9),
//                                                                 letterSpacing:
//                                                                     0.5,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//
//                                               // 🔽 Spacer so that the overlapping image is not clipped
//                                               const SizedBox(height: 15),
//
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 0,
//                                                     right: 0,
//                                                     top: 4,
//                                                     bottom: 4),
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.center,
//                                                   children: [
//                                                     // Agent Name
//                                                     Expanded(
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .only(left: 10),
//                                                         child: Text(
//                                                           property.agentName ??
//                                                               'Agent',
//                                                           style:
//                                                               const TextStyle(
//                                                             fontSize: 15,
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             color: Colors.black,
//                                                           ),
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                         ),
//                                                       ),
//                                                     ),
//
//                                                     // Listed text + agency logo
//                                                     Row(
//                                                       children: [
//                                                         if (property.postedOn !=
//                                                                 null &&
//                                                             property.postedOn!
//                                                                 .isNotEmpty)
//                                                           Text(
//                                                             'Listed ${property.postedOn}',
//                                                             style:
//                                                                 const TextStyle(
//                                                               fontSize: 13,
//                                                               color:
//                                                                   Colors.grey,
//                                                             ),
//                                                           ),
//                                                         const SizedBox(
//                                                             width: 4),
//                                                         if (property.agencyLogo !=
//                                                                 null &&
//                                                             property.agencyLogo!
//                                                                 .isNotEmpty)
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: Container(
//                                                               height: 30,
//                                                               width: 60,
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             4),
//                                                                 image:
//                                                                     DecorationImage(
//                                                                   image: CachedNetworkImageProvider(
//                                                                       property
//                                                                           .agencyLogo!),
//                                                                   fit: BoxFit
//                                                                       .contain,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//
//                                               SizedBox(
//                                                 height: 5,
//                                               ),
//
// // 👇 Divider line here
//                                               const Divider(
//                                                 thickness: 0.3,
//                                                 color: Colors.grey,
//                                                 height: 6,
//                                               ),
//                                             ],
//                                           ),
//                                           Padding(
//                                             padding:
//                                                 const EdgeInsets.only(top: 5),
//                                             child: ListTile(
//                                               title: Text(
//                                                 property.title.toString(),
//                                                 style: TextStyle(
//                                                     fontSize: 16, height: 1.4),
//                                               ),
//                                               subtitle: Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     top: 8.0),
//                                                 child: Text(
//                                                   '${property.price} AED',
//                                                   style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 22,
//                                                       height: 1.4),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           Row(
//                                             children: [
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 10, right: 5, top: 0),
//                                                 child: Image.asset(
//                                                     "assets/images/map.png",
//                                                     height: 14),
//                                               ),
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 0, right: 0, top: 0),
//                                                 child: Text(
//                                                   property.location.toString(),
//                                                   style: TextStyle(
//                                                       fontSize: 13,
//                                                       height: 1.4,
//                                                       overflow:
//                                                           TextOverflow.visible),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: 8),
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 8.0),
//                                             child: Row(
//                                               children: [
//                                                 // === BEDS: Only show if > 0 ===
//                                                 if ((property.bedrooms ?? 0) >
//                                                     0) ...[
//                                                   Image.asset(
//                                                       "assets/images/bed.png",
//                                                       height: 13),
//                                                   const SizedBox(width: 5),
//                                                   Text(
//                                                     '${property.bedrooms}',
//                                                     style: const TextStyle(
//                                                         fontSize: 14,
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                                   ),
//                                                   const SizedBox(
//                                                       width:
//                                                           15), // spacing between bed & bath
//                                                 ],
//
//                                                 // === BATHS: Only show if > 0 ===
//                                                 if ((property.bathrooms ?? 0) >
//                                                     0) ...[
//                                                   Image.asset(
//                                                       "assets/images/bath.png",
//                                                       height: 13),
//                                                   const SizedBox(width: 5),
//                                                   Text(
//                                                     '${property.bathrooms}',
//                                                     style: const TextStyle(
//                                                         fontSize: 14,
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                                   ),
//                                                   const SizedBox(width: 15),
//                                                 ],
//
//                                                 // === SIZE: Only show if valid (you already have this logic — keep it!)
//                                                 if (property.displaySize
//                                                         .isNotEmpty &&
//                                                     property.displaySize !=
//                                                         '0 sqft') ...[
//                                                   Image.asset(
//                                                       "assets/images/messure.png",
//                                                       height: 13),
//                                                   const SizedBox(width: 5),
//                                                   Text(
//                                                     property.displaySize,
//                                                     style: const TextStyle(
//                                                         fontSize: 14,
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                                   ),
//                                                 ],
//                                               ],
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             height: 10,
//                                           ),
//                                           Row(
//                                             children: [
//                                               const SizedBox(width: 10),
//                                               Expanded(
//                                                 child: ElevatedButton.icon(
//                                                   onPressed: () async {
//                                                     final propertyId =
//                                                         _safePropertyId(
//                                                             property.id);
//
//                                                     // Mark as contacted (CALL)
//                                                     final success =
//                                                         await markAsContacted(
//                                                             propertyId,
//                                                             contactType:
//                                                                 "call");
//
//                                                     if (success && mounted) {
//                                                       ScaffoldMessenger.of(
//                                                               context)
//                                                           .showSnackBar(
//                                                         const SnackBar(
//                                                           content: Text(
//                                                               "Added to contacted properties"),
//                                                           backgroundColor:
//                                                               Colors.green,
//                                                           duration: Duration(
//                                                               seconds: 2),
//                                                         ),
//                                                       );
//                                                     }
//
//                                                     String phone =
//                                                         'tel:${phoneCallNumber(property.phoneNumber ?? '')}';
//                                                     if (await canLaunchUrlString(
//                                                         phone)) {
//                                                       await launchUrlString(
//                                                           phone,
//                                                           mode: LaunchMode
//                                                               .externalApplication);
//                                                     }
//                                                   },
//                                                   icon: const Icon(Icons.call,
//                                                       color: Colors.red),
//                                                   label: const Text("Call",
//                                                       style: TextStyle(
//                                                           color: Colors.black)),
//                                                   style:
//                                                       ElevatedButton.styleFrom(
//                                                     backgroundColor:
//                                                         Colors.grey[100],
//                                                     shape:
//                                                         RoundedRectangleBorder(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         10)),
//                                                     elevation: 2,
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                         vertical: 12),
//                                                   ),
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 10),
//                                               Expanded(
//                                                 child: ElevatedButton.icon(
//                                                   onPressed: () async {
//                                                     final propertyId =
//                                                         _safePropertyId(
//                                                             property.id);
//
//                                                     // Mark as contacted (WHATSAPP)
//                                                     final success =
//                                                         await markAsContacted(
//                                                             propertyId,
//                                                             contactType:
//                                                                 "whatsapp");
//
//                                                     if (success && mounted) {
//                                                       ScaffoldMessenger.of(
//                                                               context)
//                                                           .showSnackBar(
//                                                         const SnackBar(
//                                                           content: Text(
//                                                               "Added to contacted properties"),
//                                                           backgroundColor:
//                                                               Colors.green,
//                                                           duration: Duration(
//                                                               seconds: 2),
//                                                         ),
//                                                       );
//                                                     }
//
//                                                     final phone =
//                                                         whatsAppNumber(
//                                                             property.whatsapp ??
//                                                                 '');
//                                                     final message =
//                                                         Uri.encodeComponent(
//                                                             "Hi, I'm interested in your property: ${property.title}");
//                                                     final url = Uri.parse(
//                                                         "https://wa.me/$phone?text=$message");
//
//                                                     if (await canLaunchUrl(
//                                                         url)) {
//                                                       await launchUrl(url,
//                                                           mode: LaunchMode
//                                                               .externalApplication);
//                                                     } else {
//                                                       ScaffoldMessenger.of(
//                                                               context)
//                                                           .showSnackBar(
//                                                         const SnackBar(
//                                                             content: Text(
//                                                                 "WhatsApp not installed")),
//                                                       );
//                                                     }
//                                                   },
//                                                   icon: Image.asset(
//                                                       "assets/images/whats.png",
//                                                       height: 20),
//                                                   label: const Text("WhatsApp",
//                                                       style: TextStyle(
//                                                           color: Colors.black)),
//                                                   style:
//                                                       ElevatedButton.styleFrom(
//                                                     backgroundColor:
//                                                         Colors.grey[100],
//                                                     shape:
//                                                         RoundedRectangleBorder(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         10)),
//                                                     elevation: 2,
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                         vertical: 12),
//                                                   ),
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 10),
//                                             ],
//                                           ),
//                                           const SizedBox(height: 10),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
                            },
                          ),
                        )
            ]),

            Positioned.fill(
              bottom: 30,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                    width: 180, // <-- reduce width here
                    child: CreateAlertButton(
                      disabled: _alertCreated, // true after saving the alert
                      onTap: _onCreateAlert, // normal handler
                    )),
              ),
            )
          ],
        ),
      );
    });
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // ✅ distributes space correctly
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Home())),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Image(
                  image: AssetImage("assets/images/home.png"), height: 25),
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () async {
              final token = await SecureStorage.getToken();

              if (token == null || token.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white, // white container
                    title: const Text("Login Required",
                        style: TextStyle(color: Colors.black)),
                    content: const Text("Please login to access favorites.",
                        style: TextStyle(color: Colors.black)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginDemo()));
                        },
                        child: const Text("Login",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              } else {
                // ✅ Logged in – go to favorites
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Fav_Logout()),
                ).then((_) async {
                  // 🔁 Re-sync when coming back
                  final updatedFavorites =
                      await FavoriteService.fetchApiFavorites(token);
                  if (mounted) {
                    setState(() {
                      FavoriteService.loggedInFavorites = updatedFavorites;
                    });
                  }
                });
              }
            },
            icon: const Icon(Icons.favorite_border_outlined,
                color: Colors.red, size: 30),
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
            onPressed: () => showHomeContactDialog(context),
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 20.0), // consistent spacing from right edge
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const My_Account()));
              },
              icon: const Icon(Icons.dehaze_outlined,
                  color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _iconBoxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.3),
        blurRadius: 2,
        spreadRadius: 0.1,
        offset: const Offset(0, 1),
      ),
      const BoxShadow(
        color: Colors.white,
        offset: Offset(0.0, 0.0),
        blurRadius: 0.0,
        spreadRadius: 0.0,
      ),
    ],
  );
}

Widget _rangeDisplayBox(String value) {
  return Container(
    width: 100,
    height: 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          offset: const Offset(0.5, 0.5),
          blurRadius: 2,
        ),
      ],
    ),
    child: Text(value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  );
}

class CreateAlertButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool disabled;

  const CreateAlertButton({
    super.key,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // keep the same visuals always
    const gradient = LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [Color(0xFFFFA3A3), Color(0xFFFFFFFF)],
    );

    return AbsorbPointer(
      // blocks taps but keeps semantics hit-test for parent
      absorbing: disabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          // don't trigger ripple when disabled
          onTap: disabled ? null : onTap,
          splashColor: disabled ? Colors.transparent : null,
          highlightColor: disabled ? Colors.transparent : null,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.red, width: 1),
              gradient: gradient,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/bell-red.png',
                  height: 18,
                  width: 18,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.notifications_none,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Create Alert',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SwitchExample extends StatefulWidget {
  const SwitchExample({super.key});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: light,
      activeColor: Colors.blue,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          light = value;
        });
      },
    );
  }
}

class Data {
  final double x, y;
  Data(this.x, this.y);
}

String whatsAppNumber(String number) {
  number = number.replaceAll(RegExp(r'\D'), '');
  if (number.startsWith('0')) {
    number = number.substring(1);
  }
  if (!number.startsWith('971')) {
    number = '971$number';
  }
  return number;
}
