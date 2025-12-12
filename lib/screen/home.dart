import 'dart:async';
import 'dart:convert';

import 'package:Akarat/model/featuredmodel.dart' as featured;
import 'package:Akarat/model/filtermodel.dart' as filterModel;
import 'package:Akarat/model/location_model.dart';
import 'package:Akarat/model/propertymodel.dart' as propertyModel;
import 'package:Akarat/model/searchmodel.dart' as search;
import 'package:Akarat/model/togglemodel.dart';
import 'package:Akarat/providers/filter_provider.dart';
import 'package:Akarat/screen/featured_detail.dart';
import 'package:Akarat/screen/filter.dart' as filter;
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/new_projects.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:Akarat/secure_storage.dart';
import 'package:Akarat/services/api_service.dart';
import 'package:Akarat/utils/fav_logout.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../providers/favorite_provider.dart';
import '../services/favorite_service.dart';
import 'ContactFormScreen.dart';
import 'location_picker_screen.dart'; // ←←← THIS LINE WAS MISSING!

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyHomePageState();
}

String selectedSort = "Newest";

class _MyHomePageState extends State<Home> {
  final ScrollController _scrollController = ScrollController();

  void checkCurrentBuildVersion() {
    String version = const String.fromEnvironment('FLUTTER_BUILD_NAME',
        defaultValue: 'unknown');
    String buildNumber = const String.fromEnvironment('FLUTTER_BUILD_NUMBER',
        defaultValue: 'unknown');

    print("Current Version: $version");
    print("Current Build Number: $buildNumber");
  }

  String purpose = '';
  String propertyType = ''; // <— add this

  // Persist the selected API sort across requests/pages
  String _currentSortKey =
      'newest'; // 'featured' | 'newest' | 'price_asc' | 'price_desc'

  List<featured.Data> _mergeDedupFeatured(
    List<featured.Data> a,
    List<featured.Data> b,
  ) {
    final map = <int, featured.Data>{};
    for (final p in [...a, ...b]) {
      final id = int.tryParse(p.id?.toString() ?? '') ?? -1;
      if (id != -1) map[id] = p; // later item wins (fresh data)
    }
    return map.values.toList();
  }

  void _applyClientSortIfNeeded(List<featured.Data> list) {
    if (_currentSortKey == 'newest') {
      int idOf(featured.Data d) => int.tryParse(d.id?.toString() ?? '') ?? 0;
      list.sort((a, b) => idOf(b).compareTo(idOf(a))); // newest first (id DESC)

      // If you have a createdAt field, prefer it:
      // int ts(featured.Data d) =>
      //   DateTime.tryParse(d.createdAt ?? '')?.millisecondsSinceEpoch
      //     ?? int.tryParse(d.id?.toString() ?? '') ?? 0;
      // list.sort((a, b) => ts(b).compareTo(ts(a)));
    }

    // Optional guard for price sorting if backend slips:
    // if (_currentSortKey == 'price_asc' || _currentSortKey == 'price_desc') {
    //   num priceOf(featured.Data d) =>
    //       num.tryParse('${d.price}'.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    //   list.sort((a, b) => _currentSortKey == 'price_asc'
    //       ? priceOf(a).compareTo(priceOf(b))
    //       : priceOf(b).compareTo(priceOf(a)));
    // }
  }

  final Map<String, String> sortMap = {
    "Featured": "featured",
    "Newest": "newest",
    "Price (low)": "price_asc",
    "Price (high)": "price_desc",
  };

  List<filterModel.Data> projectList = [];

  List<LocationModel> locationSuggestions = [];

  bool isSearching = false;

  String? nextPageUrl;

  String? selectedSortKey; // holds current sort_by value

  String token = '';

  // For phone calls: Always output in +971... format
  // Phone sanitizer: always outputs +971XXXXXXXXX
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

  // WhatsApp sanitizer: always outputs 971XXXXXXXXX (no plus)
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

  Future<void> fetchLocationSuggestions(String query) async {
    String url = query.isEmpty
        ? ApiService.buildUri('locations').toString()
        : ApiService.buildUri('locations', query: {'q': query}).toString();

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          // Only take location name from each item
          locationSuggestions =
              data.map((item) => LocationModel.fromJson(item)).toList();
        });
      } else {
        print('❌ Failed to load suggestions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error while fetching locations: $e');
    }
  }

  bool loadingSavedProperties = true;
  List<Property> savedProperties = [];

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  void fetchProperties(String sortBy) async {
    final url = ApiService.buildUri('properties?sort_by=$sortBy');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Parse and update your property list model here
        setState(() {
          // update your property list model from API
        });
      } else {
        print('Failed to load properties');
      }
    } catch (e) {
      print('Error fetching properties: $e');
    }
  }

  @override
  Future<void> _fetchSavedProperties() async {
    final savedToken = await SecureStorage.getToken(); // ✅ Correct

    if (savedToken == null) {
      print('User not logged in. Skipping saved properties fetch.');
      return; // ✅ Just return, don't navigate to Login
    }

    setState(() {
      token = savedToken;
      loadingSavedProperties = true;
    });

    try {
      final List<Property> properties =
          (await ApiService.getSavedProperties(token)).cast<Property>();
      setState(() {
        savedProperties = properties;
      });
    } catch (e) {
      print('Error fetching saved properties: $e');
    } finally {
      setState(() {
        loadingSavedProperties = false;
      });
    }
  }

  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  int pageIndex = 0;
  String? authToken;
  String email = '';
  String result = '';

  bool isFavorited = false;
  final TextEditingController _searchController = TextEditingController();
  List<Property> searchResults = [];
  String location = '';

  String _token = '';
  bool _loadingToken = true;

  // ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  featured.FeaturedModel? featuredModel;

  search.SearchModel? searchModel;
  ToggleModel? toggleModel;
  bool isDataRead = false;
  int? property_id;

  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();
  // Method to read data from shared preferences
  void readData() async {
    token = await prefManager.readStringFromPref();
    email = await prefManager.readStringFromPrefemail();
    result = await prefManager.readStringFromPrefresult();
    setState(() {
      isDataRead = true;
    });
  }

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    String version = const String.fromEnvironment('FLUTTER_BUILD_NAME',
        defaultValue: 'unknown');
    String buildNumber = const String.fromEnvironment('FLUTTER_BUILD_NUMBER',
        defaultValue: 'unknown');

    print("🔍 Current app version: $version");
    print("🔍 Current build number: $buildNumber");

    // Load token once, then fetch saved properties if logged in
    _loadToken().then((_) {
      if (_token.isNotEmpty) {
        _fetchSavedProperties();
      }
    });

    selectedSort = "Newest";
    _currentSortKey = "newest";

    // Initial data load
    getFeaturedProperties(forceRefresh: true);

    // 1. Load full property details from server (images, price, etc.)
    context.read<FavoriteProvider>().fetchSavedProperties();

// 2. Also do a fast sync of favorite IDs from provider (in case user added from another screen)
    context.read<FavoriteProvider>().syncFromServer(merge: false);

    // Infinite scroll listener
    _scrollController.addListener(() {
      const threshold = 200.0;
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent - threshold) {
        if (!isLoading && nextPageUrl != null && nextPageUrl!.isNotEmpty) {
          debugPrint("🟢 Triggering loadMore: $nextPageUrl");
          getFeaturedProperties(loadMore: true);
        }
      }
    });
  }

  /// Loads the token from SecureStorage and updates state.
  /// Keep this as a CLASS METHOD (not nested inside initState).
  Future<void> _loadToken() async {
    final t = await SecureStorage.getToken();
    if (!mounted) return;
    setState(() {
      _token = t ?? '';
      token = _token; // keep both in sync if other code still reads `token`
      _loadingToken = false;
    });
  }

  void initToken() async {
    token = await getToken(); // ✅ fetch token from secure storage
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Are you sure?'),
            content: Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'No',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Yes',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> toggledApi(String token, int propertyId) async {
    final url = ApiService.buildUri('toggle-saved-property');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"property_id": propertyId}),
      );

      if (response.statusCode == 200) {
        print("✅ Favorite toggled successfully");
        return true;
      } else {
        print("❌ Failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("🚨 Error in toggledApi: $e");
      return false;
    }
  }

  Future<void> getFeaturedProperties({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (isLoading) return;

    // Stop if no more pages on loadMore
    if (loadMore && (nextPageUrl == null || nextPageUrl!.isEmpty)) {
      debugPrint("🔴 No more pages to load.");
      return;
    }

    setState(() => isLoading = true);

    Uri uri;

    // Build URL to ALWAYS include sort_by
    if (loadMore) {
      // Derive next page from meta; don't trust links.next because it may drop sort
      final meta = featuredModel?.meta;
      final current = meta?.currentPage ?? 1;
      final last = meta?.lastPage ?? 1;

      if (current >= last) {
        setState(() => isLoading = false);
        debugPrint("🔴 Already at last page.");
        return;
      }

      final nextPage = current + 1;
      uri = ApiService.buildUri(
        'properties',
        query: {
          'page': '$nextPage',
          'sort_by': _currentSortKey,
        },
      );
    } else {
      // Initial load or refresh
      uri = ApiService.buildUri(
        'properties',
        query: {
          'page': '1',
          'sort_by': _currentSortKey,
        },
      );
    }

    try {
      debugPrint("📡 Fetching URL: $uri");

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = featured.FeaturedResponseModel.fromJson(jsonData);

        final List<featured.Data> incoming =
            model.data?.data ?? <featured.Data>[];
        final List<featured.Data> currentList = loadMore
            ? (featuredModel?.data ?? <featured.Data>[])
            : <featured.Data>[];

        // Merge + de-dupe by id
        final merged = _mergeDedupFeatured(currentList, incoming);

        // Optional client-side enforcement for "newest"
        _applyClientSortIfNeeded(merged);

        setState(() {
          featuredModel = featured.FeaturedModel(
            data: merged,
            links: model.data?.links,
            meta: model.data?.meta,
            totalProperties: model.data?.totalProperties,
          );

          // Compute a safe nextPageUrl that preserves sort_by
          final m = model.data?.meta;
          if (m != null) {
            final cur = m.currentPage ?? 1;
            final last = m.lastPage ?? 1;
            nextPageUrl = (cur < last)
                ? ApiService.buildUri(
                    'properties',
                    query: {
                      'page': '${cur + 1}',
                      'sort_by': _currentSortKey,
                    },
                  ).toString()
                : null;
          } else {
            nextPageUrl = null;
          }

          debugPrint("✅ Next Page URL: $nextPageUrl");
          debugPrint("📦 Total loaded: ${featuredModel?.data?.length}");
        });
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Fetch error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 2 : 3;

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          // appBar: AppBar(),
          bottomNavigationBar: SafeArea(
            child: buildMyNavBar(context),
          ),
          //body: pages[pageIndex],
          backgroundColor: Colors.white,
          body:
              // SingleChildScrollView(
              // child:
              Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo 1
                  Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(top: 25, left: 0),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/app_icon.png'),
                      ),
                    ),
                  ),

                  //logo2
                  Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(top: 25),
                    height: 80,
                    width: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/logo-text.png'),
                      ),
                    ),
                  ),
                ],
              ),
              //Searchbar
              // Responsive universal search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 45,
                          child: Row(
                            children: [
                              // ← replace your plain Icon with this:
                              IconButton(
                                icon: Icon(Icons.search, color: Colors.red),
                                onPressed: null,
                              ),

                              Expanded(
                                child: TextField(
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
                                    hintText:
                                        "Search for a locality, area or city",
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    context.read<FilterProvider>()
                                      ..setInitialHomeCategory(1)
                                      ..resetAll(
                                        context,
                                        isUpdate: false,
                                      );
                                    purpose = "Rent";
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => filter.Filter(
                                                  data: purpose,
                                                )));

                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) =>
                                          const FractionallySizedBox(
                                        heightFactor: 0.95,
                                        child: LocationPickerScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (locationSuggestions.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  height: 220,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: locationSuggestions.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 0,
                        thickness: 0.5,
                        indent: 12,
                        endIndent: 12,
                        color: Color(0xFFE0E0E0),
                      ),
                      itemBuilder: (context, index) {
                        final loc = locationSuggestions[index].location!;
                        return InkWell(
                          onTap: () {
                            _searchController.text = loc;
                            // FocusScope.of(context).unfocus(); // close keyboard
                            setState(() {
                              locationSuggestions = [];
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    color: Colors.redAccent, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    loc,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // if (locationSuggestions.isNotEmpty)
              //   Container(
              //     height: 200,
              //     margin: const EdgeInsets.symmetric(horizontal: 16),
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(8),
              //       boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6)],
              //     ),
              //     child: ListView.builder(
              //       itemCount: locationSuggestions.length,
              //       itemBuilder: (context, index) {
              //         final loc = locationSuggestions[index];
              //         return ListTile(
              //           title: Text(loc),
              //           onTap: () {
              //             _searchController.text = loc;
              //             // fetchPropertiesForLocation(loc);
              //             setState(() {
              //               locationSuggestions = [];
              //             });
              //           },
              //         );
              //       },
              //     ),
              //   ),

              if (isSearching)
                Center(child: CircularProgressIndicator())
              else if (searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (_, i) {
                      final propertyModel.Property p =
                          searchResults[i] as propertyModel.Property;

                      return ListTile(
                        leading: (p.media?.isNotEmpty ?? false)
                            ? Image.network(
                                p.media!.first.originalUrl ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(
                                width: 50), // keeps layout stable when no image

                        // FULL TITLE – no truncation
                        title: Text(
                          p.title ?? 'No Title',
                          maxLines:
                              3, // allow up to 3 lines (or any number you want)
                          overflow: TextOverflow
                              .visible, // important: removes the "…" dots
                          softWrap: true, // wraps naturally
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        subtitle: Text(
                          '${p.price ?? ''} AED • ${p.location ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 13),
                        ),

                        isThreeLine:
                            true, // tells Flutter the tile can have 3+ lines

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  Featured_Detail(data: p.id.toString()),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              else
                // …your existing featured-properties / grid code…

                //images gridview
                //   Expanded(
                // child: SingleChildScrollView(
                //  child:
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await getFeaturedProperties(forceRefresh: true);
                    },
                    child: ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: [
                          // 🔽 ALL YOUR CATEGORY UI HERE
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              children: [
                                // Rent
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterProvider>()
                                      ..setInitialHomeCategory(0)
                                      ..resetAll(
                                        context,
                                        isUpdate: false,
                                      );
                                    purpose = "Rent";
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                filter.Filter(data: purpose)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    /*padding: const EdgeInsets.only(
                                        left: 17.0, right: 10.0, top: 10, bottom: 0),
                                                  */
                                    child: Container(
                                        width: screenSize.width * 0.29,
                                        height: screenSize.height * 0.11,
                                        padding: const EdgeInsets.only(top: 0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.8),
                                              offset: Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              offset: Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/images/ak-rent-red.png",
                                              height: 35,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text(
                                                "Property For Rent",
                                                style: TextStyle(
                                                    height: 1.2,
                                                    letterSpacing: 0.5,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                                //logo2
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterProvider>()
                                      ..setInitialHomeCategory(1)
                                      ..resetAll(
                                        context,
                                        isUpdate: false,
                                      );
                                    purpose = "Buy";
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => filter.Filter(
                                                  data: purpose,
                                                )));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    /* padding: const EdgeInsets.only(
                                        left: 5.0, right: 10.0, top: 10.0, bottom: 0),*/
                                    child: Container(
                                        width: screenSize.width * 0.29,
                                        height: screenSize.height * 0.11,
                                        padding: const EdgeInsets.only(top: 0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.8),
                                              offset: Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              offset: Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/images/ak-sale.png",
                                              height: 35,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text(
                                                "Property For Sale",
                                                style: TextStyle(
                                                    height: 1.2,
                                                    letterSpacing: 0.5,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                                //logo2
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterProvider>()
                                      ..setInitialHomeCategory(2)
                                      ..resetAll(
                                        context,
                                        isUpdate: false,
                                      );
                                    purpose = "Buy";
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => filter.Filter(
                                                  data: purpose,
                                                  optionType: 'offplan',
                                                )));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    /*padding: const EdgeInsets.only(
                                        left: 5.0, right: 10.0, top: 10.0, bottom: 0),*/
                                    child: Container(
                                        width: screenSize.width * 0.3,
                                        height: screenSize.height * 0.11,
                                        padding: const EdgeInsets.only(top: 0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.8),
                                              offset: Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              offset: Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2.0),
                                              child: Image.asset(
                                                "assets/images/ak-off-plan.png",
                                                height: 35,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text(
                                                "Off-Plan-Properties",
                                                style: TextStyle(
                                                    height: 1.2,
                                                    letterSpacing: 0.5,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Row(
                              children: [
                                //logo 1
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterProvider>()
                                      ..setInitialHomeCategory(3)
                                      ..resetAll(
                                        context,
                                        isUpdate: false,
                                      );
                                    purpose = "Rent";
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => filter.Filter(
                                                  data: purpose,
                                                  propertyType: 1,
                                                )));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    /* padding: const EdgeInsets.only(
        left: 17.0, right: 10.0, top: 8, bottom: 0),*/
                                    child: Container(
                                        width: screenSize.width * 0.29,
                                        height: screenSize.height * 0.11,
                                        padding: const EdgeInsets.only(top: 0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.8),
                                              offset: Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              offset: Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2.0),
                                              child: Image.asset(
                                                "assets/images/commercial_new.png",
                                                height: 35,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text(
                                                "Commercial",
                                                style: TextStyle(
                                                    height: 1.2,
                                                    letterSpacing: 0.5,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                                //logo2
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterProvider>()
                                      ..setInitialHomeCategory(4)
                                      ..resetAll(
                                        context,
                                        isUpdate: false,
                                      );
                                    purpose = "Rent";
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => filter.Filter(
                                                  data: purpose,
                                                  propertyCategoryType:
                                                      'Villa Compound',
                                                )));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    /*padding: const EdgeInsets.only(
        left: 5.0, right: 5.0, top: 8, bottom: 0),*/
                                    child: Container(
                                        width: screenSize.width * 0.3,
                                        height: screenSize.height * 0.11,
                                        padding: const EdgeInsets.only(top: 0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.8),
                                              offset: Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              offset: Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2.0),
                                              child: Image.asset(
                                                "assets/images/villa-new.png",
                                                height: 35,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Text(
                                                "Villas",
                                                style: TextStyle(
                                                    height: 1.2,
                                                    letterSpacing: 0.5,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                                //logo2
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterProvider>()
                                      ..setInitialHomeCategory(5)
                                      ..resetAll(
                                        context,
                                        isUpdate: false,
                                      );
                                    purpose = "Rent";
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => filter.Filter(
                                                  data: purpose,
                                                  propertyType: 0,
                                                  propertyCategoryType:
                                                      'Apartment',
                                                )));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    /*padding: const EdgeInsets.only(
                                        left: 5.0, right: 5.0, top: 8, bottom: 0),*/
                                    child: Container(
                                        width: screenSize.width * 0.3,
                                        height: screenSize.height * 0.11,
                                        padding: const EdgeInsets.only(top: 0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.8),
                                              offset: Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              offset: Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2.0),
                                              child: Image.asset(
                                                "assets/images/apartment.png",
                                                height: 35,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Text(
                                                "Apartment",
                                                style: TextStyle(
                                                    height: 1.2,
                                                    letterSpacing: 0.5,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //banner
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 10.0, top: 20.0, bottom: 0),
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => New_Projects()));
                              },
                              child: Container(
                                width: screenSize.width * 1.0,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      offset: Offset(4, 4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      offset: Offset(-4, -4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  /* mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,*/
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 00, right: 0),
                                        child: Container(
                                          width: screenSize.width * 0.4,
                                          height: 100,
                                          // color: Colors.grey,
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 10, right: 5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "New Projects            ",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.left,
                                              ),
                                              Text(
                                                "Discover more about the UAE "
                                                "real estate market",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                                softWrap: true,
                                              )
                                            ],
                                          ),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0.0, right: 0),
                                      child: Container(
                                          height: screenSize.height * 0.15,
                                          width: screenSize.width * 0.5,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          // color: Colors.grey,
                                          child: Image.asset(
                                            'assets/images/banner1.jpg',
                                            fit: BoxFit.contain,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          //  Text
                          Container(
                            margin: const EdgeInsets.only(
                                top: 20, left: 5, right: 15),
                            height: screenSize.height * 0.05,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left: Property count
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                    "${featuredModel?.totalProperties ?? 0} Properties",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),

                                // Right: Dropdown (Featured)
                                PopupMenuButton<String>(
                                  elevation: 0,
                                  onSelected: (value) {
                                    setState(() {
                                      selectedSort = value;
                                      // 🔁 Call your sorting/filter logic here
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  offset: const Offset(0, 35),
                                  color: Colors
                                      .white, // Needed to style the container inside
                                  itemBuilder: (context) {
                                    final List<String> sortOptions = [
                                      "Featured",
                                      "Newest",
                                      "Price (low)",
                                      "Price (high)",
                                    ];

                                    return [
                                      PopupMenuItem<String>(
                                        enabled: false,
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          width: 200,
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .white, // 👈 Your dropdown background
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: sortOptions.map((option) {
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  final selectedKey =
                                                      sortMap[option]!;
                                                  setState(() {
                                                    selectedSort =
                                                        option; // for UI label
                                                    selectedSortKey =
                                                        selectedKey; // keep if you use elsewhere
                                                    _currentSortKey =
                                                        selectedKey; // <-- persist for pagination
                                                    featuredModel =
                                                        null; // clear existing data
                                                    nextPageUrl =
                                                        null; // reset pagination
                                                  });
                                                  getFeaturedProperties(
                                                      forceRefresh:
                                                          true); // will use _currentSortKey
                                                  _scrollController.jumpTo(0);
                                                },
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 12),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            option,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black), // 👈 Black text
                                                          ),
                                                          if (selectedSort ==
                                                              option)
                                                            const Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .green,
                                                                size: 18),
                                                        ],
                                                      ),
                                                    ),
                                                    if (option !=
                                                        sortOptions.last)
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
                                        Text(
                                            selectedSort), // 👉 No TextStyle here
                                        const Icon(Icons.arrow_drop_down,
                                            size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          featuredModel == null
                              ? const Center(child: ShimmerCard())
                              :

                              //Expanded(
                              // child:
                              /*Expanded(
                                          child:*/
                              ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: NeverScrollableScrollPhysics(),

                                  // 👈 only if inside a parent scrollable view
                                  itemCount:
                                      (featuredModel?.data?.length ?? 0) +
                                          (nextPageUrl != null ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    final properties =
                                        featuredModel?.data ?? [];

                                    // 🔄 Show loader at end if next page exists
                                    if (index == properties.length &&
                                        nextPageUrl != null) {
                                      //  return const CircularProgressIndicator(); previous code
                                      return Center(
                                          child:
                                              const CircularProgressIndicator());
                                    } else if (index == properties.length &&
                                        nextPageUrl == null) {
                                      return const SizedBox
                                          .shrink(); // Nothing more to show
                                    }

                                    // 🔐 Safety check (extra)
                                    if (index >= properties.length)
                                      return const SizedBox.shrink();

                                    final item = properties[index];

                                    return GestureDetector(
                                      onTap: () {
                                        String id = item.id.toString();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Featured_Detail(data: id),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        child: Card(
                                          color: Colors.white,
                                          shadowColor: Colors.white,
                                          elevation: 10,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Stack(
                                                        clipBehavior: Clip.none,
                                                        // ✅ Allows the overlap outside the Stack
                                                        children: [
                                                          // 🖼️ Property Image Carousel with Rounded Corners
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            child: AspectRatio(
                                                              aspectRatio: 1.4,
                                                              child: PageView
                                                                  .builder(
                                                                controller:
                                                                    _pageController,
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemCount: item
                                                                        .media
                                                                        ?.length ??
                                                                    0,
                                                                onPageChanged:
                                                                    (index) {
                                                                  setState(() {
                                                                    _currentImageIndex =
                                                                        index;
                                                                  });
                                                                },
                                                                itemBuilder:
                                                                    (context,
                                                                        imgIndex) {
                                                                  return CachedNetworkImage(
                                                                    imageUrl: item
                                                                        .media![
                                                                            imgIndex]
                                                                        .originalUrl
                                                                        .toString(),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),

                                                          // ⚪ Image Indicator Dots
                                                          Positioned(
                                                            bottom: 12,
                                                            left: 0,
                                                            right: 0,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children:
                                                                  List.generate(
                                                                item.media
                                                                        ?.length ??
                                                                    0,
                                                                (index) {
                                                                  final distance =
                                                                      (index -
                                                                              _currentImageIndex)
                                                                          .abs();
                                                                  double scale;
                                                                  double
                                                                      opacity;

                                                                  if (distance ==
                                                                      0) {
                                                                    scale = 1.2;
                                                                    opacity =
                                                                        1.0;
                                                                  } else if (distance ==
                                                                      1) {
                                                                    scale = 1.0;
                                                                    opacity =
                                                                        0.7;
                                                                  } else if (distance ==
                                                                      2) {
                                                                    scale = 0.8;
                                                                    opacity =
                                                                        0.5;
                                                                  } else {
                                                                    scale = 0.5;
                                                                    opacity =
                                                                        0.0;
                                                                  }

                                                                  return AnimatedOpacity(
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            300),
                                                                    opacity:
                                                                        opacity,
                                                                    child:
                                                                        SizedBox(
                                                                      width: 12,
                                                                      // fixed size for layout stability
                                                                      height:
                                                                          12,
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              8 * scale,
                                                                          height:
                                                                              8 * scale,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),

                                                          // ❤️ Favorite Icon
                                                          // ❤️ Favorite Icon

                                                          // ❤️ Favorite Icon
                                                          Positioned(
                                                            top: 10,
                                                            right: 10,
                                                            child: Material(
                                                              color:
                                                                  Colors.white,
                                                              shape:
                                                                  const CircleBorder(),
                                                              elevation: 4,
                                                              child: Consumer<
                                                                  FavoriteProvider>(
                                                                builder: (context,
                                                                    favProvider,
                                                                    _) {
                                                                  final isLoggedIn =
                                                                      token
                                                                          .isNotEmpty;
                                                                  final isFav =
                                                                      isLoggedIn &&
                                                                          favProvider
                                                                              .isFavorite(item.id!); // ✅ Only true for logged-in users

                                                                  // debugPrint("fav length :${favProvider.fav}");

                                                                  return IconButton(
                                                                    icon: Icon(
                                                                      isFav
                                                                          ? Icons
                                                                              .favorite
                                                                          : Icons
                                                                              .favorite_border,
                                                                      color: isFav
                                                                          ? Colors
                                                                              .red
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
                                                                          builder: (ctx) =>
                                                                              Dialog(
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            insetPadding:
                                                                                EdgeInsets.zero,
                                                                            child:
                                                                                Container(
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
                                                                                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
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

                                                                      // ✅ Use Provider's API-integrated method
                                                                      final success = await favProvider.toggleFavoriteWithApi(
                                                                          item.id!,
                                                                          token,
                                                                          context);

                                                                      if (!success) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                              content: Text("Failed to update favorite.")),
                                                                        );
                                                                      }
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),

                                                          // 👈 returns an empty widget when not logged in

                                                          // 👈 Return nothing if not logged in

                                                          // 🧑‍💼 Overlapping Agent Profile Image
                                                          // 🧑‍💼 Overlapping Agent Profile Image
                                                          // 🧑‍💼 Agent Profile with Navigation to Featured_Detail
                                                          // 🟢 Positioned Circle Avatar (left: 10)
                                                          Positioned(
                                                            bottom: -30,
                                                            left: 10,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => Featured_Detail(
                                                                        data: item
                                                                            .id
                                                                            .toString()),
                                                                  ),
                                                                );
                                                              },
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  CircleAvatar(
                                                                    radius: 28,
                                                                    backgroundImage: (item.agentImage !=
                                                                                null &&
                                                                            item
                                                                                .agentImage!.isNotEmpty)
                                                                        ? CachedNetworkImageProvider(item
                                                                            .agentImage!)
                                                                        : const AssetImage("assets/images/dummy.jpg")
                                                                            as ImageProvider,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          6),
                                                                  Transform
                                                                      .translate(
                                                                    offset: const Offset(
                                                                        -5,
                                                                        0), // shift 4 pixels to the left
                                                                    child: Text(
                                                                      "AGENT",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: Color(
                                                                            0xFF1A73E9),
                                                                        letterSpacing:
                                                                            0.5,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      // 🔽 Spacer so that the overlapping image is not clipped
                                                      const SizedBox(
                                                          height: 15),

                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 0,
                                                                right: 0,
                                                                top: 4,
                                                                bottom: 4),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            // Agent Name
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                child: Text(
                                                                  item.agentName ??
                                                                      'Agent',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ),

                                                            // Listed text + agency logo
                                                            Row(
                                                              children: [
                                                                if (item.postedOn !=
                                                                        null &&
                                                                    item.postedOn!
                                                                        .isNotEmpty)
                                                                  Text(
                                                                    'Listed ${item.postedOn}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                const SizedBox(
                                                                    width: 4),
                                                                if (item.agencyLogo !=
                                                                        null &&
                                                                    item.agencyLogo!
                                                                        .isNotEmpty)
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          30,
                                                                      width: 60,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(4),
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              CachedNetworkImageProvider(item.agencyLogo!),
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      SizedBox(
                                                        height: 5,
                                                      ),

// 👇 Divider line here
                                                      const Divider(
                                                        thickness: 0.3,
                                                        color: Colors.grey,
                                                        height: 6,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                    item.title.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      height: 1.4,
                                                    ),
                                                    maxLines:
                                                        3, // Allow up to 3 lines
                                                    overflow: TextOverflow
                                                        .ellipsis, // Only show "..." if more than 3 lines
                                                    softWrap:
                                                        true, // Important: wrap text naturally
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    '${item.price} AED',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                          "assets/images/map.png",
                                                          height: 14),
                                                      SizedBox(width: 5),
                                                      Expanded(
                                                        child: Text(
                                                          item.location
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      // === BEDS: Show only if bedrooms > 0 ===
                                                      if (item.bedrooms !=
                                                              null &&
                                                          item.bedrooms! >
                                                              0) ...[
                                                        Image.asset(
                                                            "assets/images/bed.png",
                                                            height: 14),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          "${item.bedrooms}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13),
                                                        ),
                                                      ],

                                                      // === BATHS: Show only if bathrooms > 0 and add spacing only if beds were shown ===
                                                      if (item.bathrooms !=
                                                              null &&
                                                          item.bathrooms! >
                                                              0) ...[
                                                        if (item.bedrooms !=
                                                                null &&
                                                            item.bedrooms! > 0)
                                                          const SizedBox(
                                                              width: 12),
                                                        Image.asset(
                                                            "assets/images/bath.png",
                                                            height: 14),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          "${item.bathrooms}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13),
                                                        ),
                                                      ],

                                                      // === SIZE: Show only if displaySize is not empty ===
                                                      if (item.displaySize
                                                          .isNotEmpty) ...[
                                                        // Add spacing only if at least one of beds/baths was shown
                                                        if ((item.bedrooms !=
                                                                    null &&
                                                                item.bedrooms! >
                                                                    0) ||
                                                            (item.bathrooms !=
                                                                    null &&
                                                                item.bathrooms! >
                                                                    0))
                                                          const SizedBox(
                                                              width: 12),
                                                        Image.asset(
                                                            "assets/images/messure.png",
                                                            height: 14),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          item.displaySize,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13),
                                                        ),

                                                        // DLD Badge — only when actual DLD size is used
                                                        if (item.dldPermitInfo
                                                                    ?.propertySize !=
                                                                null &&
                                                            num.tryParse(item
                                                                    .dldPermitInfo!
                                                                    .propertySize!
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            r'[^0-9.]'),
                                                                        '')) !=
                                                                null &&
                                                            num.tryParse(item
                                                                    .dldPermitInfo!
                                                                    .propertySize!
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            r'[^0-9.]'),
                                                                        ''))! >
                                                                0)
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 6),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .verified,
                                                                    color: Colors
                                                                        .blue,
                                                                    size: 14),
                                                                Text(
                                                                  " DLD",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .blue,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ],
                                                  ),
                                                  /* SizedBox(height: 15),
                                                                                              Row(
                                                                                                children: [
                                                                                                  Image.asset("assets/images/Flooring.png", height: 20),
                                                                                                  SizedBox(width: 5),
                                                                                                  Text(item.bedrooms.toString()),
                                                                                                  SizedBox(width: 10),
                                                                                                  Image.asset("assets/images/
                                                                                                  Central_Heating.png", height: 20),
                                                                                                  SizedBox(width: 5),
                                                                                                  Text(item.bathrooms.toString()),
                                                                                                  SizedBox(width: 10),
                                                                                                  Image.asset("assets/images/Barbeque_Area.png", height: 20),
                                                                                                  SizedBox(width: 5),
                                                                                                  Text(item.squareFeet.toString()),
                                                                                                ],
                                                                                              ),*/
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            ElevatedButton.icon(
                                                          onPressed: () async {
                                                            // Use the correct sanitizer for call (international format with +)
                                                            String phone =
                                                                'tel:${phoneCallNumber(item.phoneNumber ?? '')}';
                                                            try {
                                                              final bool
                                                                  launched =
                                                                  await launchUrlString(
                                                                phone,
                                                                mode: LaunchMode
                                                                    .externalApplication,
                                                              );
                                                              if (!launched) {
                                                                print(
                                                                    "❌ Could not launch dialer");
                                                              }
                                                            } catch (e) {
                                                              print(
                                                                  "❌ Exception: $e");
                                                            }
                                                          },
                                                          icon: const Icon(
                                                              Icons.call,
                                                              color:
                                                                  Colors.red),
                                                          label: const Text(
                                                              "Call",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[100],
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            elevation: 2,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child:
                                                            ElevatedButton.icon(
                                                          onPressed: () async {
                                                            final phone =
                                                                whatsAppNumber(
                                                                    item.whatsapp ??
                                                                        '');
                                                            final message = Uri
                                                                .encodeComponent(
                                                                    "Hello"); // you can change message
                                                            final url = Uri.parse(
                                                                "https://wa.me/$phone?text=$message");
                                                            if (await canLaunchUrl(
                                                                url)) {
                                                              try {
                                                                final launched =
                                                                    await launchUrl(
                                                                        url,
                                                                        mode: LaunchMode
                                                                            .externalApplication);
                                                                if (!launched) {
                                                                  print(
                                                                      "❌ Could not launch WhatsApp");
                                                                }
                                                              } catch (e) {
                                                                print(
                                                                    "❌ Exception: $e");
                                                              }
                                                            } else {
                                                              print(
                                                                  "❌ WhatsApp not available");
                                                            }
                                                          },
                                                          icon: Image.asset(
                                                              "assets/images/whats.png",
                                                              height: 20),
                                                          label: const Text(
                                                              "WhatsApp",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[100],
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            elevation: 2,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                        ]),
                  ),
                )
            ],
          ),
          //),
        ));
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
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
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/home.png", height: 25),
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
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red), // red text
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginDemo()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.red), // red text
                        ),
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
                  setState(() {
                    FavoriteService.loggedInFavorites = updatedFavorites;
                  });
                });
              }
            },
            icon: pageIndex == 2
                ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                : const Icon(Icons.favorite_border_outlined,
                    color: Colors.red, size: 30),
          ),

          // IconButton(
          //   tooltip: "Email",
          //   icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
          //   onPressed: () async {
          //     final Uri emailUri = Uri.parse(
          //       'mailto:info@akarat.com?subject=Property%20Inquiry&body=Hi,%20I%20saw%20your%20agent%20profile%20on%20Akarat.',
          //     );
          //
          //     if (await canLaunchUrl(emailUri)) {
          //       await launchUrl(emailUri);
          //     } else {
          //       showDialog(
          //         context: context,
          //         builder: (context) => AlertDialog(
          //           backgroundColor: Colors.white, // White dialog container
          //           title: const Text(
          //             'Email not available',
          //             style: TextStyle(color: Colors.black), // Title in black
          //           ),
          //           content: const Text(
          //             'No email app is configured on this device. Please add a mail account first.',
          //             style: TextStyle(color: Colors.black), // Content in black
          //           ),
          //           actions: [
          //             TextButton(
          //               onPressed: () => Navigator.pop(context),
          //               child: const Text(
          //                 'OK',
          //                 style: TextStyle(color: Colors.red), // Red "OK" text
          //               ),
          //             ),
          //           ],
          //         ),
          //       );
          //     }
          //   },
          // ),

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
                setState(() {
                  if (token == '') {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => My_Account()));
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => My_Account()));
                  }
                });
              },
              icon: pageIndex == 3
                  ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                  : const Icon(Icons.dehaze_outlined,
                      color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}
