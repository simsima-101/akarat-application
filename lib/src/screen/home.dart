
import 'dart:async';

import 'dart:convert';


import 'package:Akarat/src/core/utils/secure_storage.dart';

import 'package:Akarat/src/core/utils/session_manager.dart';
import 'package:Akarat/src/screen/shimmer.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../l10n/app_localizations.dart';
import '../core/services/api_service.dart';


import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/property/data/datasources/favorite_remote_datasource.dart';
import 'package:Akarat/src/features/property/data/models/featuredmodel.dart' as featured;
import '../features/property/data/models/fdetailmodel.dart' as agencyProps;
import '../features/property/data/models/location_model.dart';
import '../features/property/data/models/search_model.dart' as search;

import '../features/property/data/models/toggle_model.dart';
import '../features/property/presentation/bloc/favorite_bloc.dart';
import '../features/property/presentation/bloc/favorite_event.dart';
import '../features/property/presentation/bloc/favorite_state.dart';


import '../features/property/presentation/bloc/filter_bloc.dart';
import '../features/property/presentation/bloc/location_picker_bloc.dart';
import '../utils/fav_logout.dart';
import '../utils/shared_preference_manager.dart';
import 'ContactFormScreen.dart';
import 'featured_detail.dart';
import 'filter.dart' as filter;
import 'filter_list.dart';



import '../features/agency/data/models/agency_properties_model.dart' as agencyProps;


// Remove any duplicate imports of agency_properties_model.dart

import 'location_picker_screen.dart'; // ←←← THIS LINE WAS MISSING!


import 'login.dart';
import 'my_account.dart';
import 'new_projects.dart';


import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/property/presentation/bloc/properties_bloc.dart';
import '../common/widgets/property_card.dart'; // Your reusable card

import '../features/property/data/models/property_model.dart';

import '../features/property/data/models/featuredmodel.dart' as featured;
import '../features/property/data/models/property_model.dart'; // ← Unified Property class
import '../common/widgets/property_card.dart';

extension AppLocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
// ←←← ADD THIS EXTENSION HERE (after imports, before Home class) ←←←

extension FeaturedDataToProperty on featured.Data {
  Property toProperty() {
    return Property(
      id: id?.toString() ?? '0',
      title: title ?? 'No title',
      price: price ?? 'Price on request',
      location: location ?? address ?? 'Dubai, UAE',
      bedrooms: bedrooms ?? 0,
      bathrooms: bathrooms ?? 0,
      squareFeet: squareFeet ?? displaySize ?? 'N/A',
      // ← No 'description' field in featured.Data → use safe default
      description: 'Beautiful property listed on Akarat.', // or leave empty if not needed
      image: media?.isNotEmpty == true ? media!.first.originalUrl ?? '' : '',
      media: media ?? [],
      // ← No 'agent' field → only agentName exists
      agent: agentName ?? 'Agent',
      agentImage: agentImage,
      phoneNumber: phoneNumber,
      whatsapp: whatsapp,
      postedOn: postedOn,
      agencyLogo: agencyLogo,
    );
  }
}


class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeDemo(),
    );
  }
}


class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _FixedHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_FixedHeaderDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        child != oldDelegate.child;
  }
}

class HomeDemo extends StatefulWidget {
  const HomeDemo({super.key});

  @override
  State<HomeDemo> createState() => _MyHomePageState();
}

String selectedSort = "Newest";

class _MyHomePageState extends State<HomeDemo> {
  final ScrollController _scrollController = ScrollController();

  List<agencyProps.Property> properties = [];





  void checkCurrentBuildVersion() {
    String version = const String.fromEnvironment('FLUTTER_BUILD_NAME', defaultValue: 'unknown');
    String buildNumber = const String.fromEnvironment('FLUTTER_BUILD_NUMBER', defaultValue: 'unknown');

    print("Current Version: $version");
    print("Current Build Number: $buildNumber");
  }

  String purpose = '';
  String propertyType = ''; // <— add this


  // ←←← ADD THIS FUNCTION INSIDE _MyHomePageState class ←←←
  String _formatAgentName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'Agent';
    }

    // Split name by spaces and remove empty parts
    List<String> parts = fullName.trim().split(RegExp(r'\s+'));

    // Return only first two names
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    } else if (parts.isNotEmpty) {
      return parts[0]; // only one name
    } else {
      return 'Agent';
    }
  }

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


  int _safePropertyId(dynamic id) {
    if (id == null) return 0;
    if (id is int) return id;
    if (id is String) {
      return int.tryParse(id) ?? 0;
    }
    return 0;
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

  List<featured.Data> projectList = [];

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





  Widget _buildCategoryCard({
    required String imagePath,
    required String title,
    required Size screenSize,
    double fontSize = 11,
  }) {
    return GestureDetector(
      child: Container(
        width: screenSize.width * 0.29,
        height: screenSize.height * 0.11,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.8),
              offset: const Offset(7, 7),
              blurRadius: 8,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-4, -4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 35),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                title,
                style: TextStyle(
                  height: 1.2,
                  letterSpacing: 0.5,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> markAsContacted(int propertyId, {required String contactType}) async {
    if (propertyId <= 0) return false;

    await SessionManager().restore();
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
        debugPrint("Successfully marked property $propertyId as contacted via $contactType");
        return true;
      } else {
        debugPrint("Failed to mark contacted: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception marking contacted: $e");
      return false;
    }
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
  List<agencyProps.Property> savedProperties = [];

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
      final List<agencyProps.Property> properties =
      (await ApiService.getSavedProperties(token)).cast<agencyProps.Property>();
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
  @override
  void initState() {
    super.initState();

    // Print app version and build number
    String version = const String.fromEnvironment('FLUTTER_BUILD_NAME', defaultValue: 'unknown');
    String buildNumber = const String.fromEnvironment('FLUTTER_BUILD_NUMBER', defaultValue: 'unknown');

    print("🔍 Current app version: $version");
    print("🔍 Current build number: $buildNumber");

    // Set initial sorting
    selectedSort = "Newest";
    _currentSortKey = "newest";

    // Load featured properties on first launch
    getFeaturedProperties(forceRefresh: true);

    // Optional: Manually trigger a fresh favorites load if you want to ensure latest data
    // (Normally not needed because FavoriteBloc already loads on app start via main.dart)
    // Remove or comment out if you don't want double-loading
    // context.read<FavoriteBloc>().add(LoadFavorites());

    // Infinite scroll listener for pagination
    _scrollController.addListener(() {
      const double threshold = 200.0;
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
        body: Column(
          children: [
            // ==================== FIXED HEADER: Logo + Search Bar ====================
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: [
                  const SizedBox(height: 5),

                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          image: DecorationImage(image: AssetImage('assets/images/app_icon.png')),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        height: 80,
                        width: 120,
                        decoration: const BoxDecoration(
                          image: DecorationImage(image: AssetImage('assets/images/logo-text.png')),
                        ),
                      ),
                    ],
                  ),

                  // Search Bar - Exact match to your original
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
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
                                  const Icon(Icons.search, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      focusNode: _focusNode,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        hintText: "Search for a locality, area or city",
                                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                        border: InputBorder.none,
                                      ),
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<LocationPickerBloc>(),
                                            child: const FractionallySizedBox(
                                              heightFactor: 0.95,
                                              child: LocationPickerScreen(),
                                            ),
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
                ],
              ),
            ),

            // ==================== SCROLLABLE CONTENT BELOW ====================
            Expanded(
              child: featuredModel == null
                  ? const Center(child: ShimmerCard())
                  : RefreshIndicator(
                onRefresh: () async {
                  nextPageUrl = null;
                  featuredModel = null;
                  getFeaturedProperties(forceRefresh: true);
                },
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: (featuredModel?.data?.length ?? 0) +
                      (nextPageUrl != null ? 1 : 0) +
                      1,
                  itemBuilder: (context, index) {
                    final properties = featuredModel?.data ?? [];

                    // Static content at index 0
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Location Suggestions
                          if (locationSuggestions.isNotEmpty)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              height: 220,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6))
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
                                      endIndent: 12),
                                  itemBuilder: (context, i) {
                                    final loc = locationSuggestions[i]
                                        .location!;
                                    return InkWell(
                                      onTap: () {
                                        _searchController.text = loc;
                                        setState(() =>
                                        locationSuggestions = []);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.location_on_outlined,
                                                color: Colors.redAccent,
                                                size: 22),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(loc,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight
                                                          .w500)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                          // Category Row 1 - EXACT SAME HEIGHT AND STYLE
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterBloc>().add(
                                        const SetHomeCategory(0));
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (_) =>
                                            filter.Filter(data: "Rent")));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Container(
                                      width: screenSize.width * 0.29,
                                      height: screenSize.height * 0.11,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                  0.8),
                                              offset: const Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                          BoxShadow(
                                              color: Colors.white.withOpacity(
                                                  0.8),
                                              offset: const Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                        ],
                                        borderRadius: BorderRadius.circular(
                                            12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          Image.asset(
                                              "assets/images/ak-rent-red.png",
                                              height: 35),
                                          const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text("Property For Rent",
                                                style: TextStyle(fontSize: 11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    height: 1.2)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Buy
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterBloc>().add(
                                        SetHomeCategory(1));
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (_) =>
                                            filter.Filter(data: "Buy")));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Container(
                                      width: screenSize.width * 0.29,
                                      height: screenSize.height * 0.11,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                  0.8),
                                              offset: const Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                          BoxShadow(
                                              color: Colors.white.withOpacity(
                                                  0.8),
                                              offset: const Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                        ],
                                        borderRadius: BorderRadius.circular(
                                            12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          Image.asset(
                                              "assets/images/ak-sale.png",
                                              height: 35),
                                          const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text("Property For Sale",
                                                style: TextStyle(fontSize: 11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    height: 1.2)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Off-Plan
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterBloc>().add(
                                        SetHomeCategory(2));
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (_) =>
                                            filter.Filter(data: "Buy",
                                                optionType: 'offplan')));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Container(
                                      width: screenSize.width * 0.3,
                                      height: screenSize.height * 0.11,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                  0.8),
                                              offset: const Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                          BoxShadow(
                                              color: Colors.white.withOpacity(
                                                  0.8),
                                              offset: const Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                        ],
                                        borderRadius: BorderRadius.circular(
                                            12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          Image.asset(
                                              "assets/images/ak-off-plan.png",
                                              height: 35),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 5),
                                            child: Text("Off-Plan-Properties",
                                                style: TextStyle(fontSize: 10,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    height: 1.2)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // === CATEGORY ROW 2 ===
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Row(
                              children: [
                                // Commercial
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterBloc>().add(
                                        SetHomeCategory(3));
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (_) =>
                                            filter.Filter(data: "Rent",
                                                propertyType: 1)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Container(
                                      width: screenSize.width * 0.29,
                                      height: screenSize.height * 0.11,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                  0.8),
                                              offset: const Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                          BoxShadow(
                                              color: Colors.white.withOpacity(
                                                  0.8),
                                              offset: const Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                        ],
                                        borderRadius: BorderRadius.circular(
                                            12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          Image.asset(
                                              "assets/images/commercial_new.png",
                                              height: 35),
                                          const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text("Commercial",
                                                style: TextStyle(fontSize: 11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    height: 1.2)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Villas
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterBloc>().add(
                                        const SetHomeCategory(4));
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (_) =>
                                            filter.Filter(data: "Rent",
                                                propertyType: 0,
                                                propertyCategoryType: 'Villa')));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Container(
                                      width: screenSize.width * 0.3,
                                      height: screenSize.height * 0.11,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                  0.8),
                                              offset: const Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                          BoxShadow(
                                              color: Colors.white.withOpacity(
                                                  0.8),
                                              offset: const Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                        ],
                                        borderRadius: BorderRadius.circular(
                                            12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          Image.asset(
                                              "assets/images/villa-new.png",
                                              height: 35),
                                          const Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Text("Villas",
                                                style: TextStyle(fontSize: 11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    height: 1.2)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Apartment
                                GestureDetector(
                                  onTap: () {
                                    context.read<FilterBloc>().add(
                                        SetHomeCategory(5));
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (_) =>
                                            filter.Filter(data: "Rent",
                                                propertyType: 0,
                                                propertyCategoryType: 'Apartment')));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Container(
                                      width: screenSize.width * 0.3,
                                      height: screenSize.height * 0.11,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                  0.8),
                                              offset: const Offset(7, 7),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                          BoxShadow(
                                              color: Colors.white.withOpacity(
                                                  0.8),
                                              offset: const Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2),
                                        ],
                                        borderRadius: BorderRadius.circular(
                                            12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          Image.asset(
                                              "assets/images/apartment.png",
                                              height: 35),
                                          const Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Text("Apartment",
                                                style: TextStyle(fontSize: 11,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    height: 1.2)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Banner - New Projects (perfect padding & size adjustment)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            // Outer padding (top/bottom added for spacing)
                            child: GestureDetector(
                              onTap: () =>
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => NewProjectsScreen())),
                              child: Container(
                                width: double.infinity,
                                height: 150, // Comfortable height
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        offset: const Offset(4, 4),
                                        blurRadius: 8,
                                        spreadRadius: 2),
                                    BoxShadow(
                                        color: Colors.white.withOpacity(0.8),
                                        offset: const Offset(-4, -4),
                                        blurRadius: 8,
                                        spreadRadius: 2),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Left: Text section with generous padding
                                    Expanded(
                                      flex: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 16, 8, 16),
                                        // Left-heavy padding for text
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              "New Projects",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Discover more about the UAE real estate market",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                              softWrap: true,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Right: Image section with balanced padding
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        // Even padding around image
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              10),
                                          child: Image.asset(
                                            'assets/images/banner1.jpg',
                                            fit: BoxFit.cover,
                                            height: double.infinity,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Properties Count + Sort
                          Container(
                            margin: const EdgeInsets.only(
                                top: 20, left: 5, right: 15),
                            height: screenSize.height * 0.05,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                      "${featuredModel?.totalProperties ??
                                          0} Properties",
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 15)),
                                ),
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
                                      .white,
                                  // Needed to style the container inside
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
                                                .white,
                                            // 👈 Your dropdown background
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: sortOptions.map((
                                                option) {
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
                                            selectedSort),
                                        // 👉 No TextStyle here
                                        const Icon(Icons.arrow_drop_down,
                                            size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),
                        ],
                      );
                    }

                    final int propertyIndex = index - 1;

                    if (propertyIndex < properties.length) {
                      final featured.Data dataItem = properties[propertyIndex];
                      final Property property = dataItem.toProperty(); // ← Now works!

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: PropertyCard(item: property),
                      );
                    }

                    // Loading indicator at the end
                    if (propertyIndex == properties.length &&
                        nextPageUrl != null) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }


                    return const SizedBox.shrink();
                  },),),),],),
      ),



      //),
    );
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