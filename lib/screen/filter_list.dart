import 'package:Akarat/providers/filter_provider.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../providers/favorite_provider.dart';
import '../secure_storage.dart';
import '../services/favorite_service.dart';
import '../utils/fav_logout.dart';
import '../utils/shared_preference_manager.dart';
import 'CreateAlertScreen.dart';
import 'featured_detail.dart';
import 'home.dart';
import 'login.dart';
import 'my_account.dart';

class FliterList extends StatefulWidget {

  final String selectedPurpose;      // Add this parameter
  final String selectedPropertyType; // Add this parameter
  const FliterList({
    super.key,
    this.selectedPurpose = '',        // Default value provided
    this.selectedPropertyType = '', // Default value provided


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

// WhatsApp sanitizer: always outputs 971XXXXXXXXX (no plus)
  String whatsAppNumber(String input) {
    // Remove all non-digit characters
    input = input.replaceAll(RegExp(r'[^\d]'), '');

    // Remove leading zeros
    if (input.startsWith('0')) {
      input = input.substring(1);
    }

    // Remove duplicated country code if already present
    if (input.startsWith('971971')) {
      input = input.replaceFirst('971971', '971');
    }

    // Ensure starts with UAE code
    if (input.startsWith('971')) {
      return input;
    }

    // Add UAE prefix if missing
    return '971$input';
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
        FavoriteService.loggedInFavorites.add(property!.id!);
      } else {
        FavoriteService.loggedInFavorites.remove(property!.id!);
      }
    });
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

    final initialPropertyType = filterProvider.property_type;

    final availableTypes = (filterProvider.propertyTypeModel?.data ?? const [])
        .map((e) =>
            (e.name ?? '').trim()) // prefer e.slug if your API expects slugs
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAlertScreen(
          initialPurpose: initialPurpose,
          initialPropertyType: initialPropertyType,
          availablePropertyTypes: availableTypes,
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
        // final filterProvider = context.read<FilterProvider>();

        _scrollController.addListener(() {
          if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300) {
            // _fetchMore();
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
                                                await resetState
                                                    .resetAll(context);
                                                resetState
                                                    .captureInitialSnapshot(); // NEW SNAPSHOT
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

              //Searchbar
              // Responsive universal search bar
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //   child: Container(
              //     width: double.infinity,
              //     height: 55,
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(30),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.grey.withOpacity(0.2),
              //           blurRadius: 6,
              //           offset: Offset(0, 3),
              //         ),
              //       ],
              //     ),
              //     child: Row(
              //       children: [
              //         Expanded(
              //           child: Container(
              //             margin: const EdgeInsets.symmetric(horizontal: 8),
              //             decoration: BoxDecoration(
              //               border: Border.all(color: Colors.red.shade200),
              //               borderRadius: BorderRadius.circular(30),
              //             ),
              //             padding: const EdgeInsets.symmetric(horizontal: 12),
              //             height: 45,
              //             child: Row(
              //               children: [
              //                 Icon(Icons.search, color: Colors.red),
              //                 const SizedBox(width: 10),
              //                 Expanded(
              //                   child: TextField(
              //                     controller: _searchController,
              //                     decoration: InputDecoration(
              //                       hintText: "Search for a locality, area or city",
              //                       hintStyle: TextStyle(
              //                         color: Colors.grey,
              //                         fontSize: 14,
              //                       ),
              //                       border: InputBorder.none,
              //                     ),
              //                   ),
              //                 ),
              //
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              //filter
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 15, bottom: 5),
                child: SizedBox(
                  // margin: const EdgeInsets.symmetric(vertical: 1),
                  height: 50,
                  // color: Colors.grey,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      //text
                      GestureDetector(
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
                      // BUY OR RENT
                      GestureDetector(
                        onTap: () {
                          filterProvider.setSelectedFilterListProductLocally(
                              filterProvider.selectedproduct!);
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
                                  height: screenSize.height * 0.3,
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

                                      // Availability list
                                      // SizedBox(
                                      //   height: 50,
                                      //   child: ListView.builder(
                                      //     scrollDirection: Axis.horizontal,
                                      //     itemCount: propertyTypeModel
                                      //             ?.availability?.length ??
                                      //         0,
                                      //     itemBuilder: (context, index) {
                                      //       bool isSelected =
                                      //           selectedrent == index;
                                      //       final label = propertyTypeModel!
                                      //           .availability![index]
                                      //           .toString();
                                      //       return GestureDetector(
                                      //         onTap: () async {
                                      //           // setModalState(() {
                                      //           selectedrent = index;
                                      //           rent = label;
                                      //           // });
                                      //
                                      //           await _resetPagingAndFetch();
                                      //
                                      //           Navigator.pop(context);
                                      //         },
                                      //         child: Container(
                                      //           margin: const EdgeInsets.only(
                                      //               right: 10),
                                      //           padding: const EdgeInsets
                                      //               .symmetric(
                                      //               horizontal: 14,
                                      //               vertical: 10),
                                      //           decoration: BoxDecoration(
                                      //             color: isSelected
                                      //                 ? Colors.blueAccent
                                      //                 : Colors.white,
                                      //             borderRadius:
                                      //                 BorderRadius.circular(
                                      //                     6),
                                      //             boxShadow: [
                                      //               BoxShadow(
                                      //                   color: Colors.grey
                                      //                       .withOpacity(0.3),
                                      //                   blurRadius: 4,
                                      //                   offset: const Offset(
                                      //                       0, 2)),
                                      //             ],
                                      //           ),
                                      //           child: Center(
                                      //             child: Text(
                                      //               label,
                                      //               style: TextStyle(
                                      //                 color: isSelected
                                      //                     ? Colors.white
                                      //                     : Colors.black,
                                      //                 fontWeight:
                                      //                     FontWeight.bold,
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       );
                                      //     },
                                      //   ),
                                      // ),

                                      const SizedBox(height: 10),

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
                            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                                  height: screenSize.height * 0.35,
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? const Color(0xFFEEEEEE)
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CachedNetworkImage(
                                                      imageUrl:
                                                          item.icon.toString(),
                                                      height: 35,
                                                      placeholder: (context,
                                                              url) =>
                                                          const CupertinoActivityIndicator(
                                                        radius: 14,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error,
                                                              size: 35),
                                                    ),
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
                                horizontal: 14), // SAME as Price Range
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
                                    ? filterProvider
                                                .filterListSelectedPropType ==
                                            0
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
                                      horizontal: 20, vertical: 20),
                                  decoration:
                                      const BoxDecoration(color: Colors.white),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Price range",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
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
                                      const SizedBox(height: 16),
                                      SfRangeSelectorTheme(
                                        data: SfRangeSelectorThemeData(
                                          tooltipBackgroundColor: Colors.black,
                                          tooltipTextStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        child: SfRangeSelector(
                                          min: 500,
                                          max: 300000,
                                          interval: 10000,
                                          activeColor: const Color(0xFF2575D4),
                                          inactiveColor:
                                              const Color(0x80F1EEEE),
                                          enableTooltip: true,
                                          shouldAlwaysShowTooltip: true,
                                          initialValues:
                                              priceRangeState.filterListValues,
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
                                              primaryYAxis:
                                                  NumericAxis(isVisible: false),
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
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 45,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            // await _resetPagingAndFetch();

                                            double finalMinPrice = double.parse(
                                                filterProvider
                                                    .filterList_Min_price);
                                            double finalMaxPrice = double.parse(
                                                filterProvider
                                                    .filterList_Max_price);

                                            // filterProvider
                                            //     .setSelectedFilterRangePriceRange(
                                            //         minPrice: finalMinPrice,
                                            //         maxPrice: finalMaxPrice);

                                            setState(() {
                                              filterProvider.values =
                                                  SfRangeValues(finalMinPrice,
                                                      finalMaxPrice);
                                              filterProvider.min_price =
                                                  finalMinPrice
                                                      .toStringAsFixed(0);
                                              filterProvider.max_price =
                                                  finalMaxPrice
                                                      .toStringAsFixed(0);

                                              // ✅ Force update min only if not currently editing, or if value actually changed
                                              if (!filterProvider.isMinTyping ||
                                                  filterProvider
                                                          .minPriceController
                                                          .text !=
                                                      finalMinPrice
                                                          .toStringAsFixed(0)) {
                                                filterProvider
                                                        .minPriceController
                                                        .text =
                                                    finalMinPrice
                                                        .toStringAsFixed(0);
                                              }

                                              if (!filterProvider.isMaxTyping ||
                                                  filterProvider
                                                          .maxPriceController
                                                          .text !=
                                                      finalMaxPrice
                                                          .toStringAsFixed(0)) {
                                                filterProvider
                                                        .maxPriceController
                                                        .text =
                                                    finalMaxPrice
                                                        .toStringAsFixed(0);
                                              }
                                            });

                                            await filterProvider
                                                .updateFilterCount(context);

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
                            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                                      horizontal: 20, vertical: 20),
                                  decoration:
                                      const BoxDecoration(color: Colors.white),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Area Range",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
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
                                      const SizedBox(height: 16),
                                      SfRangeSelectorTheme(
                                        data: SfRangeSelectorThemeData(
                                          tooltipBackgroundColor: Colors.black,
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
                                          activeColor: const Color(0xFF2575D4),
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
                                              primaryYAxis:
                                                  NumericAxis(isVisible: false),
                                              plotAreaBorderWidth: 0,
                                              plotAreaBackgroundColor:
                                                  Colors.transparent,
                                              series: <ColumnSeries<Dataarea,
                                                  double>>[
                                                ColumnSeries<Dataarea, double>(
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
                                                  xValueMapper: (Dataarea sales,
                                                          int index) =>
                                                      sales.x,
                                                  yValueMapper: (Dataarea sales,
                                                          int index) =>
                                                      sales.y,
                                                  pointColorMapper:
                                                      (Dataarea sales,
                                                              int index) =>
                                                          const Color.fromARGB(
                                                              255,
                                                              37,
                                                              117,
                                                              212),
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
                                      const SizedBox(height: 20),
                                      SizedBox(
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
                                                      .filterListValuesArea =
                                                  SfRangeValues(finalMinSqrFeet,
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
                                                          .toStringAsFixed(0)) {
                                                filterProvider.minAreaController
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
                                                          .toStringAsFixed(0)) {
                                                filterProvider.maxAreaController
                                                        .text =
                                                    finalMaxSqrFeet
                                                        .toStringAsFixed(0);
                                              }
                                            });

                                            await filterProvider
                                                .updateFilterCount(context);

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
                            padding: const EdgeInsets.symmetric(horizontal: 14),
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

              //filter
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Container(
                    alignment: Alignment.topLeft,
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const ScrollPhysics(),
                      itemCount: filterProvider.ftypeList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // Colors.grey;
                        return Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.only(
                              top: 0, left: 15, right: 15),
                          decoration: BoxDecoration(
                            color: filterProvider.selectedIndex == index
                                ? Colors.blueAccent
                                : Colors.white, // Change color if selected
                            // color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                offset: Offset(-4, -4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              await filterProvider.setSelectedFurnishedType(
                                context,
                                index: index,
                              );
                            },
                            child: Center(
                              child: Text(
                                filterProvider.ftypeList[index],
                                style: TextStyle(
                                  color: filterProvider.selectedIndex == index
                                      ? Colors.white
                                      : Colors.black,
                                  letterSpacing: 0.5,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )),

              filterProvider.isFilterListFilterModelLoading
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
                            padding: const EdgeInsets.all(0),
                            scrollDirection: Axis.vertical,
                            // physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            // 👇 add one extra "row" for the loading spinner when fetching more
                            itemCount:
                                (filterProvider.filterModel?.data?.length ??
                                        0) +
                                    0,
                            // (_isFetchingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              final items =
                                  filterProvider.filterModel?.data ?? [];

                              // 👇 if we're fetching more and this is the extra last row, show a spinner
                              // if (index == items.length) {
                              //   return const Padding(
                              //     padding: EdgeInsets.symmetric(vertical: 16),
                              //     child: Center(
                              //         child: CircularProgressIndicator()),
                              //   );
                              // }

                              final property = items[index];

                              final bool isFavorited =
                                  favoriteProperties.contains(property.id);
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 20,
                                  shadowColor: Colors.white,
                                  color: Colors.white,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Featured_Detail(
                                              data: property.id.toString()),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, top: 1, right: 5),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Stack(
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1.5,
                                                  child: CachedNetworkImage(
                                                    imageUrl: property
                                                            .media!.isNotEmpty
                                                        ? property.media![0]
                                                            .originalUrl
                                                            .toString()
                                                        : 'https://via.placeholder.com/300x200?text=No+Image',
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                    placeholder: (context,
                                                            url) =>
                                                        const CupertinoActivityIndicator(
                                                      radius: 14,
                                                    ),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error,
                                                            size: 100),
                                                  ),
                                                ),

                                                /// ❤️ Positioned Favorite Icon
                                                Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: Material(
                                                    color: Colors.white,
                                                    shape: const CircleBorder(),
                                                    elevation: 4,
                                                    child: Consumer<
                                                        FavoriteProvider>(
                                                      builder: (context,
                                                          favProvider, _) {
                                                        final isLoggedIn =
                                                            token.isNotEmpty;
                                                        final isFav = isLoggedIn &&
                                                            favProvider.isFavorite(
                                                                property
                                                                    .id!); // ✅ Only true for logged-in users

                                                        return IconButton(
                                                            icon: Icon(
                                                              isFav
                                                                  ? Icons
                                                                      .favorite
                                                                  : Icons
                                                                      .favorite_border,
                                                              color: isFav
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .grey, // ✅ Grey for logged-out users
                                                              size: 20,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              if (!isLoggedIn) {
                                                                // 🔒 Show login prompt
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (ctx) =>
                                                                          Dialog(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    insetPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          70,
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              80,
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              20),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .red,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          Stack(
                                                                        clipBehavior:
                                                                            Clip.none,
                                                                        children: [
                                                                          Positioned(
                                                                            top:
                                                                                -14,
                                                                            right:
                                                                                -10,
                                                                            child:
                                                                                Material(
                                                                              color: Colors.transparent,
                                                                              child: IconButton(
                                                                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                                                                onPressed: () => Navigator.of(ctx).pop(),
                                                                                padding: EdgeInsets.zero,
                                                                                constraints: const BoxConstraints(),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Positioned(
                                                                            left:
                                                                                16,
                                                                            right:
                                                                                16,
                                                                            bottom:
                                                                                12,
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                const Expanded(
                                                                                  child: Text(
                                                                                    'Login required to add favorites.',
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

                                                              final propertyId =
                                                                  property.id;
                                                              if (propertyId ==
                                                                  null) {
                                                                debugPrint(
                                                                    '⚠️ property.id is null; cannot toggle favorite.');
                                                                return;
                                                              }

                                                              // ✅ Use Provider's API-integrated method (optimistic + revert handled inside)
                                                              final success =
                                                                  await favProvider
                                                                      .toggleFavoriteWithApi(
                                                                          propertyId,
                                                                          token,
                                                                          context);

                                                              // OPTIONAL (usually not needed): force-refresh from server after a successful toggle
                                                              // if (success) {
                                                              //   await context.read<FavoriteProvider>().fetchFavoritesFromApi(token);
                                                              // }

                                                              if (!success) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          "Failed to update favorite.")),
                                                                );
                                                              }
                                                            });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: ListTile(
                                              title: Text(
                                                property.title.toString(),
                                                style: TextStyle(
                                                    fontSize: 16, height: 1.4),
                                              ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  '${property.price} AED',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 22,
                                                      height: 1.4),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 5, top: 0),
                                                child: Image.asset(
                                                    "assets/images/map.png",
                                                    height: 14),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0, right: 0, top: 0),
                                                child: Text(
                                                  property.location.toString(),
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      height: 1.4,
                                                      overflow:
                                                          TextOverflow.visible),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                    "assets/images/bed.png",
                                                    height: 13),
                                                SizedBox(width: 5),
                                                Text(property.bedrooms
                                                    .toString()),
                                                SizedBox(width: 10),
                                                Image.asset(
                                                    "assets/images/bath.png",
                                                    height: 13),
                                                SizedBox(width: 5),
                                                Text(property.bathrooms
                                                    .toString()),
                                                SizedBox(width: 10),
                                                Image.asset(
                                                    "assets/images/messure.png",
                                                    height: 13),
                                                SizedBox(width: 5),
                                                Text(property.squareFeet
                                                    .toString()),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    String phone =
                                                        'tel:${property.phoneNumber}';
                                                    try {
                                                      final bool launched =
                                                          await launchUrlString(
                                                        phone,
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                      if (!launched)
                                                        print(
                                                            "❌ Could not launch dialer");
                                                    } catch (e) {
                                                      print("❌ Exception: $e");
                                                    }
                                                  },
                                                  icon: const Icon(Icons.call,
                                                      color: Colors.red),
                                                  label: const Text("Call",
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey[100],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    elevation: 2,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final rawNumber = property
                                                            .whatsapp ??
                                                        property.phoneNumber ??
                                                        '';
                                                    final phone =
                                                        whatsAppNumber(
                                                            rawNumber);

                                                    if (phone.isEmpty) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                "No WhatsApp number available")),
                                                      );
                                                      return;
                                                    }

                                                    final message =
                                                        Uri.encodeComponent(
                                                            "Hello");
                                                    final url = Uri.parse(
                                                        "https://wa.me/$phone?text=$message");

                                                    if (await canLaunchUrl(
                                                        url)) {
                                                      try {
                                                        await launchUrl(url,
                                                            mode: LaunchMode
                                                                .externalApplication);
                                                      } catch (e) {
                                                        print(
                                                            "❌ Exception: $e");
                                                      }
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                "Cannot open WhatsApp")),
                                                      );
                                                    }
                                                  },
                                                  icon: Image.asset(
                                                      "assets/images/whats.png",
                                                      height: 20),
                                                  label: const Text("WhatsApp",
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey[100],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    elevation: 2,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
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
            tooltip: "Email",
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
            onPressed: () async {
              final Uri emailUri = Uri.parse(
                'mailto:info@akarat.com?subject=Property%20Inquiry&body=Hi,%20I%20saw%20your%20agent%20profile%20on%20Akarat.',
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Email not available',
                        style: TextStyle(color: Colors.black)),
                    content: const Text(
                      'No email app is configured on this device. Please add a mail account first.',
                      style: TextStyle(color: Colors.black),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
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
