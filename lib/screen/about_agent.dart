import 'dart:async';
import 'dart:convert';

import 'package:Akarat/model/agentdetaill.dart';
import 'package:Akarat/model/agentpropertiesmodel.dart';
import 'package:Akarat/providers/favorite_provider.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/togglemodel.dart';
import '../secure_storage.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../utils/shared_preference_manager.dart';
import '../widgets/read_more_text.dart';
import 'featured_detail.dart';

class AboutAgent extends StatefulWidget {
  const AboutAgent({super.key, required this.data});
  final String data;
  @override
  State<AboutAgent> createState() => _AboutAgentState();
}

class _AboutAgentState extends State<AboutAgent> {
  AgentDetail? agentDetail;
  int pageIndex = 0;
  final int _currentImageIndex = 0;

  bool isFavorited = false;
  int? property_id;

  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;

  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFavoritesFromService(); // ✅ New method
  }

  Future<void> _syncFavoritesFromService() async {
    final token = await SecureStorage.getToken();

    if (token != null && token.isNotEmpty) {
      final updatedFavorites = await FavoriteService.fetchApiFavorites(token);
      setState(() {
        FavoriteService.loggedInFavorites = updatedFavorites;
      });
    }
  }

  // lib/utils/phone_utils.dart

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

  Future<void> clearAgentPropertiesCache(String user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('agent_properties_$user');
    await prefs.remove('agent_properties_time_$user');
    debugPrint("🧹 Cleared old agent_properties cache");
  }

  // Method to read data from shared preferences
  void readData() async {
    token = await prefManager.readStringFromPref();
    email = await prefManager.readStringFromPrefemail();
    result = await prefManager.readStringFromPrefresult();
    setState(() {
      isDataRead = true;
    });
  }

  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  @override
  void initState() {
    super.initState();

    final String agentId = widget.data;

    // 🧹 Clear old corrupted cache first
    clearAgentPropertiesCache(agentId).then((_) {
      // ⏬ Load agent properties after cache is cleared
      getFilesApi(agentId, loadMore: false);
    });
    fetchProducts(widget.data); // Initial data fetch
    getFilesApi(widget.data,
        loadMore: false); // Load first page of agent properties
    readData(); // Other setups
    _loadFavorites();
    _searchController.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          hasMore &&
          !isLoading) {
        getFilesApi(widget.data, loadMore: true); // Load next page
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _callSearchApi(query);
      }
    });
  }

  AgentProperties? agentProperties;

  Future<void> fetchProducts(String data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'agent_detail_$data';
    final cacheTimeKey = 'agent_detail_time_$data';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // ⏱ If cache is valid (within 6 hours)
    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final cachedModel = AgentDetail.fromJson(jsonData);
        setState(() {
          agentDetail = cachedModel;
        });
        debugPrint("✅ Loaded agent from cache");
        return;
      }
    }

    // 🛰 API fallback
    try {
      final uri = ApiService.buildUri('agent/$data');
      final response = await http.get(uri);

      debugPrint("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint("API Response: $jsonData");

        final parsedModel = AgentDetail.fromJson(jsonData);

        await prefs.setString(cacheKey, jsonEncode(jsonData));
        await prefs.setInt(cacheTimeKey, now);

        if (mounted) {
          setState(() {
            agentDetail = parsedModel;
          });
        }

        debugPrint("📦 Agent service areas: ${agentDetail?.serviceAreas}");
      } else {
        debugPrint("❌ API Error Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception while fetching agent: $e");
    }
  }

  Future<void> _callSearchApi(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'search_result_$query';
    final cacheTimeKey = 'search_result_time_$query';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // ⏱ 1 hour cache validity
    if (now - lastFetched < Duration(hours: 1).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final cachedModel = AgentProperties.fromJson(jsonData);
        setState(() {
          agentProperties = cachedModel;
        });
        debugPrint("✅ Loaded search result from cache");
        return;
      }
    }

    // 🔍 Fetch from API
    final uri = ApiService.buildUri(
        'filters?search=$query'
            '&amenities='
            '&property_type='
            '&furnished_status='
            '&bedrooms='
            '&min_price='
            '&max_price='
            '&payment_period='
            '&min_square_feet='
            '&max_square_feet='
            '&bathrooms='
            '&purpose='
    );


    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feature = AgentProperties.fromJson(data);

        await prefs.setString(cacheKey, jsonEncode(data));
        await prefs.setInt(cacheTimeKey, now);

        setState(() {
          agentProperties = feature;
        });

        debugPrint("✅ API search loaded & cached");
      } else {
        debugPrint("❌ API failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception in search: $e");
    }
  }

  Future<void> getFilesApi(String user, {bool loadMore = false}) async {
    if (isLoading) return;

    isLoading = true;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'agent_properties_$user';
    final cacheTimeKey = 'agent_properties_time_$user';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    final uri = ApiService.buildUri('agent/properties/$user?page=$currentPage');


    // ✅ Load from cache if valid and not loading more
    if (!loadMore && now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
          final jsonData = jsonDecode(cachedData);
          final model = AgentProperties.fromJson(jsonData);
          setState(() {
            agentProperties = model;
            hasMore =
                (model.meta?.currentPage ?? 1) < (model.meta?.lastPage ?? 1);
            if (hasMore) {
              currentPage = (model.meta?.currentPage ?? 1) + 1;
            }
          });
          debugPrint("📦 Loaded agent properties from cache");
          isLoading = false;
          return;
        } catch (e) {
          debugPrint("⚠️ Cache parsing failed: $e");
        }
      }
    }

    // ✅ Make HTTP call
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['data'] != null) {
          final model = AgentProperties.fromJson(jsonData['data']);

          setState(() {
            if (loadMore) {
              final oldData = agentProperties?.data ?? [];
              final newData = model.data ?? [];
              agentProperties = AgentProperties(
                data: [...oldData, ...newData],
                links: model.links,
                meta: model.meta,
              );
            } else {
              agentProperties = model;
            }

            hasMore =
                (model.meta?.currentPage ?? 1) < (model.meta?.lastPage ?? 1);
            if (hasMore) {
              currentPage = (model.meta?.currentPage ?? 1) + 1;
            }
          });

          // ✅ Save to cache
          if (!loadMore) {
            await prefs.setString(cacheKey, jsonEncode(jsonData['data']));
            await prefs.setInt(cacheTimeKey, now);
            debugPrint("✅ Cached agent properties");
          }
        } else {
          debugPrint("❌ Missing 'data' field in response");
        }
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception in getFilesApi: $e");
    }

    isLoading = false;
  }

  ToggleModel? toggleModel;

  Future<bool> toggledApi(String token, int propertyId) async {
    try {
      final uri = ApiService.buildUri('toggle-saved-property');
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "property_id": propertyId,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        toggleModel = ToggleModel.fromJson(jsonData);
        print("✅ Toggle favorite successful");
        return true; // ✅ success
      } else {
        print("❌ Toggle failed with status ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('❌ Exception during toggle: $e');
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
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favorite_properties') ?? [];
    setState(() {
      favoriteProperties = savedFavorites.map(int.parse).toSet();
    });
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_properties',
        favoriteProperties.map((id) => id.toString()).toList());
  }

  final TextEditingController _searchController = TextEditingController();

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);

    // 👉 This check must be OUTSIDE the "if (agentDetail == null)"
    String imageUrl = agentDetail?.image?.toString().trim() ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://akarat.com$imageUrl';
    }

    bool isValidImage = imageUrl.isNotEmpty &&
        imageUrl.toLowerCase() != 'n/a' &&
        imageUrl.toLowerCase() != 'null';
    // &&
    // imageUrl.toLowerCase().contains('.jpg') &&
    // !imageUrl.toLowerCase().contains('default-image.jpg');

    // ✅ Now check if agentDetail is null
    if (agentDetail == null) {
      return Scaffold(
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerCard(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEEEEE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => FindAgentDemo()),
            // );
          },
        ),
      ),
      // bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // --- TOP STACK ---
            Stack(
              children: [
                // Background header bar
                Container(
                  height: screenSize.height * 0.12,
                  width: double.infinity,
                  color: const Color(0xFFEEEEEE),
                ),

                // 🔙 Clean Back Button (no circle container)
                // Positioned(
                //   top: 35,
                //   left: 8,
                //   child: IconButton(
                //     icon: const Icon(Icons.arrow_back,
                //         color: Colors.red, size: 26),
                //     padding: const EdgeInsets.all(12), // Ensures large tap area
                //     constraints:
                //         const BoxConstraints(), // Removes default 48x48 min size if needed
                //     onPressed: () {
                //       Navigator.pop(context);
                //     },
                //   ),
                // ),

                // Big Avatar
                Positioned(
                  left: 20,
                  top: 0,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(65),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.5, 0.5),
                          blurRadius: 1.0,
                          spreadRadius: 1.0,
                        ),
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 0.5,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: isValidImage
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/images/profile.png')
                      as ImageProvider,
                    ),
                  ),
                ),
              ],
            ),

            // --- AGENT NAME ROW (only once) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      agentDetail!.name.toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // --- TAGS ROW ---
            Container(
              height: screenSize.height * 0.04,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  buildTag("Prime Agent", Icons.check_circle, Colors.blueAccent,
                      Colors.white),
                  buildTag("Quality Listener", Icons.stars, Color(0xFFEAD893),
                      Colors.black),
                  // buildTag("Responsive Broker", Icons.call_outlined, Colors.white, Colors.black, border: true),
                ],
              ),
            ),

            // --- TAB BAR ---
            TabBar(
              padding: const EdgeInsets.only(top: 10, left: 0, right: 10),
              labelPadding: const EdgeInsets.symmetric(horizontal: 0),
              splashFactory: NoSplash.splashFactory,
              indicatorWeight: 1.0,
              labelColor: Colors.lightBlueAccent,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              tabAlignment: TabAlignment.center,
              tabs: [
                Container(
                  margin: const EdgeInsets.only(left: 0),
                  width: screenSize.width * 0.25,
                  height: screenSize.height * 0.039,
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(4, 4),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('About', textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: screenSize.width * 0.25,
                  height: screenSize.height * 0.039,
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(4, 4),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Properties', textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: screenSize.width * 0.25,
                  height: screenSize.height * 0.039,
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(4, 4),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Review', textAlign: TextAlign.center),
                ),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  //------------------------- Agent About -----------------------------------

                  Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              top: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: const Text(
                                    "About",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    children: const [
                                      Text(
                                        "Language(s)",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(""),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${agentDetail!.languages}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const Text(""),
                                    ],
                                  ),
                                ),

                                if (agentDetail?.expertise != null)
                                  Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Row(
                                          children: const [
                                            Text(
                                              "Expertise",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            Text(""),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Text(
                                          agentDetail!.expertise.toString(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                if ((agentDetail?.serviceAreas?.toString().trim().isNotEmpty ?? false))
                                  Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Row(
                                          children: const [
                                            Text(
                                              "Services Area",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            Text(""),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: ReadMoreText(
                                          agentDetail!.serviceAreas?.toString() ?? '',
                                          trimMode: TrimMode.line,
                                          trimLines: 4,
                                          trimCollapsedText: ' Read more',
                                          trimExpandedText: ' Read less',
                                          style: const TextStyle(fontSize: 15, color: Colors.black, letterSpacing: 0.5),
                                          moreStyle: const TextStyle(fontSize: 15, color: Colors.blue, letterSpacing: 0.5, fontWeight: FontWeight.w600),
                                          lessStyle: const TextStyle(fontSize: 15, color: Colors.blue, letterSpacing: 0.5, fontWeight: FontWeight.w600),
                                        )

                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    children: const [
                                      Text(
                                        "Description",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(""),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),

                                agentDetail!.about != null && agentDetail!.about!.trim().isNotEmpty
                                    ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: ReadMoreText(
                                    agentDetail!.about ?? '',
                                    trimMode: TrimMode.line,
                                    trimLines: 4,
                                    trimCollapsedText: ' Read more',
                                    trimExpandedText: ' Read less',
                                    style: const TextStyle(fontSize: 15, color: Colors.black, letterSpacing: 0.5),
                                    moreStyle: const TextStyle(fontSize: 15, color: Colors.blue, letterSpacing: 0.5, fontWeight: FontWeight.w600),
                                    lessStyle: const TextStyle(fontSize: 15, color: Colors.blue, letterSpacing: 0.5, fontWeight: FontWeight.w600),
                                  ),

                                )
                                    : const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Text(
                                    "No description available",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    children: const [
                                      Text(
                                        "BRN",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(""),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        agentDetail!.brokerRegisterationNumber.toString(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const Text(""),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    children: const [
                                      Text(
                                        "Experience",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(""),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "${agentDetail!.experience} Years",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const Text(""),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 35),
                        child: buildMyNavBar(context),
                      ),
                    ],
                  ),

                  //------------------------- Agent Property -----------------------------------
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 5),
                          child: Row(children: const []),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: agentProperties == null
                                ? const Center(child: CircularProgressIndicator())
                                : ListView.builder(
                              padding: const EdgeInsets.all(0),
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: agentProperties!.data!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final item = agentProperties!.data![index];
                                final property = agentProperties!.data![index];
                                bool isFavorited = favoriteProperties.contains(property.id);

                                return GestureDetector(
                                  onTap: () {
                                    String id = property.id.toString();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Featured_Detail(data: id),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    child: Card(
                                      color: Colors.white,
                                      shadowColor: Colors.white,
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    // 🖼️ Image Carousel
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: AspectRatio(
                                                        aspectRatio: 1.5,
                                                        child: PageView.builder(
                                                          itemCount: property.media?.length ?? 0,
                                                          scrollDirection: Axis.horizontal,
                                                          controller: _pageController,
                                                          onPageChanged: (_) {},
                                                          itemBuilder: (context, imgIndex) {
                                                            final imageUrl = property.media![imgIndex].originalUrl ?? '';
                                                            return CachedNetworkImage(
                                                              imageUrl: imageUrl,
                                                              fit: BoxFit.cover,
                                                              placeholder: (context, url) => const Center(
                                                                child: CircularProgressIndicator(),
                                                              ),
                                                              errorWidget: (context, url, error) =>
                                                              const Icon(Icons.error),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),

                                                    // 🔘 Dot Indicator
                                                    Positioned(
                                                      bottom: 12,
                                                      left: 0,
                                                      right: 0,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: List.generate(
                                                          item.media?.length ?? 0,
                                                              (index) {
                                                            final distance =
                                                            (index - _currentImageIndex).abs();
                                                            double scale;
                                                            double opacity;

                                                            if (distance == 0) {
                                                              scale = 1.2;
                                                              opacity = 1.0;
                                                            } else if (distance == 1) {
                                                              scale = 1.0;
                                                              opacity = 0.7;
                                                            } else if (distance == 2) {
                                                              scale = 0.8;
                                                              opacity = 0.5;
                                                            } else {
                                                              scale = 0.5;
                                                              opacity = 0.0;
                                                            }

                                                            return AnimatedOpacity(
                                                              duration: const Duration(milliseconds: 300),
                                                              opacity: opacity,
                                                              child: SizedBox(
                                                                width: 12,
                                                                height: 12,
                                                                child: Center(
                                                                  child: Container(
                                                                    width: 8 * scale,
                                                                    height: 8 * scale,
                                                                    decoration: const BoxDecoration(
                                                                      color: Colors.white,
                                                                      shape: BoxShape.circle,
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
                                                    Positioned(
                                                      top: 10,
                                                      right: 10,
                                                      child: Consumer<FavoriteProvider>(
                                                        builder: (context, favProvider, _) {
                                                          final propertyId = int.tryParse(
                                                              property.id?.toString() ?? '') ??
                                                              0;

                                                          final isSaved =
                                                          favProvider.isFavorite(propertyId);

                                                          return Material(
                                                            color: Colors.white,
                                                            shape: const CircleBorder(),
                                                            elevation: 4,
                                                            child: IconButton(
                                                              icon: Icon(
                                                                isSaved
                                                                    ? Icons.favorite
                                                                    : Icons.favorite_border,
                                                                color: isSaved ? Colors.red : Colors.grey,
                                                              ),
                                                              onPressed: () async {
                                                                final token =
                                                                await SecureStorage.getToken();

                                                                if (token == null || token.isEmpty) {
                                                                  // 🔒 Show login-required dialog
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (ctx) => Dialog(
                                                                      backgroundColor: Colors.transparent,
                                                                      insetPadding: EdgeInsets.zero,
                                                                      child: Container(
                                                                        height: 70,
                                                                        margin: const EdgeInsets.only(
                                                                            bottom: 80, left: 20, right: 20),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.red,
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                        ),
                                                                        child: Stack(
                                                                          clipBehavior: Clip.none,
                                                                          children: [
                                                                            Positioned(
                                                                              top: -14,
                                                                              right: -10,
                                                                              child: IconButton(
                                                                                icon: const Icon(Icons.close,
                                                                                    color: Colors.white, size: 20),
                                                                                onPressed: () =>
                                                                                    Navigator.of(ctx).pop(),
                                                                                padding: EdgeInsets.zero,
                                                                                constraints:
                                                                                const BoxConstraints(),
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

                                                                // ✅ Use the provider's API method
                                                                final pid = property.id;
                                                                if (pid == null) {
                                                                  debugPrint(
                                                                      '⚠️ property.id is null; cannot toggle favorite.');
                                                                  return;
                                                                }

                                                                final ok =
                                                                await favProvider
                                                                    .toggleFavoriteWithApi(
                                                                    pid, token, context);

                                                                if (!ok) {
                                                                  // ignore: use_build_context_synchronously
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(
                                                                        content: Text(
                                                                            "Failed to update favorite.")),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),

                                                    // 👤 Agent Badge
                                                    Positioned(
                                                      bottom: -30,
                                                      left: 10,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          String id = property.id.toString();
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Featured_Detail(data: id),
                                                            ),
                                                          );
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 28,
                                                              backgroundImage: (property.agentImage !=
                                                                  null &&
                                                                  property.agentImage!.isNotEmpty)
                                                                  ? CachedNetworkImageProvider(
                                                                  property.agentImage!)
                                                                  : const AssetImage(
                                                                  "assets/images/dummy.jpg")
                                                              as ImageProvider,
                                                            ),
                                                            const SizedBox(height: 6),
                                                            Transform.translate(
                                                              offset: const Offset(-5, 0),
                                                              child: const Text(
                                                                "AGENT",
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: Color(0xFF1A73E9),
                                                                  letterSpacing: 0.5,
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
                                                const SizedBox(height: 15),

                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 0, right: 0, top: 4, bottom: 4),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      // Agent Name
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: Text(
                                                            property.agentName ?? 'Agent',
                                                            style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.black,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),

                                                      // Listed text + agency logo
                                                      Row(
                                                        children: [
                                                          if (property.postedOn != null &&
                                                              property.postedOn!.isNotEmpty)
                                                            Text(
                                                              'Listed ${property.postedOn}',
                                                              style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors.grey,
                                                              ),
                                                            ),
                                                          const SizedBox(width: 4),
                                                          if (property.agencyLogo != null &&
                                                              property.agencyLogo!.isNotEmpty)
                                                            Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Container(
                                                                height: 30,
                                                                width: 60,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(4),
                                                                  image: DecorationImage(
                                                                    image:
                                                                    CachedNetworkImageProvider(
                                                                        property.agencyLogo!),
                                                                    fit: BoxFit.contain,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 5),

                                                const Divider(
                                                  color: Colors.grey,
                                                  thickness: 0.3,
                                                  height: 6,
                                                ),

                                                const SizedBox(height: 8),

                                                Padding(
                                                  padding: const EdgeInsets.only(top: 5),
                                                  child: ListTile(
                                                    title: Text(
                                                      property.title.toString(),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                    subtitle: Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Text(
                                                        '${property.price} AED',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 22,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          left: 10, right: 5, top: 0),
                                                      child: Image.asset("assets/images/map.png",
                                                          height: 14),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          left: 0, right: 0, top: 0),
                                                      child: Text(
                                                        property.location.toString(),
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          height: 1.4,
                                                          overflow: TextOverflow.visible,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: Row(
                                                    children: [
                                                      Image.asset("assets/images/bed.png",
                                                          height: 13),
                                                      const SizedBox(width: 5),
                                                      Text(property.bedrooms.toString()),
                                                      const SizedBox(width: 10),
                                                      Image.asset("assets/images/bath.png",
                                                          height: 13),
                                                      const SizedBox(width: 5),
                                                      Text(property.bathrooms.toString()),
                                                      const SizedBox(width: 10),
                                                      Image.asset("assets/images/messure.png",
                                                          height: 13),
                                                      const SizedBox(width: 5),
                                                      Text(property.squareFeet ?? '-'),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 15),
                                                Row(
                                                  children: [
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: () async {
                                                          String phone =
                                                              'tel:${item.phoneNumber}';
                                                          try {
                                                            final bool launched =
                                                            await launchUrlString(
                                                              phone,
                                                              mode: LaunchMode.externalApplication,
                                                            );
                                                            if (!launched) {
                                                              // ignore: avoid_print
                                                              print("❌ Could not launch dialer");
                                                            }
                                                          } catch (e) {
                                                            // ignore: avoid_print
                                                            print("❌ Exception: $e");
                                                          }
                                                        },
                                                        icon: const Icon(Icons.call,
                                                            color: Colors.red),
                                                        label: const Text("Call",
                                                            style: TextStyle(color: Colors.black)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.grey[100],
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          elevation: 2,
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 10),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: () async {
                                                          final rawNumber = property.whatsapp ??
                                                              property.phoneNumber ??
                                                              '';
                                                          final phone = whatsAppNumber(rawNumber);

                                                          if (phone.isEmpty) {
                                                            // ignore: use_build_context_synchronously
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      "No WhatsApp number available")),
                                                            );
                                                            return;
                                                          }

                                                          final message =
                                                          Uri.encodeComponent("Hello");
                                                          final url = Uri.parse(
                                                              "https://wa.me/$phone?text=$message");

                                                          if (await canLaunchUrl(url)) {
                                                            try {
                                                              await launchUrl(url,
                                                                  mode: LaunchMode.externalApplication);
                                                            } catch (e) {
                                                              // ignore: avoid_print
                                                              print("❌ Exception: $e");
                                                            }
                                                          } else {
                                                            // ignore: use_build_context_synchronously
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                  content:
                                                                  Text("Cannot open WhatsApp")),
                                                            );
                                                          }
                                                        },
                                                        icon: Image.asset("assets/images/whats.png",
                                                            height: 20),
                                                        label: const Text("WhatsApp",
                                                            style: TextStyle(color: Colors.black)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.grey[100],
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          elevation: 2,
                                                          padding: const EdgeInsets.symmetric(
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //------------------------- Agent Reviews ----------------------------------
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Reviews",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 6,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Avatar initials
                                    Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            offset: const Offset(0.5, 0.5),
                                            blurRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        "DM",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        "Bilsay Citak",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.star, color: Colors.amber),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "In the realm of real estate, Ben Caballero's name is synonymous with unparalleled success, particularly in the new homes market.",
                                  style: TextStyle(fontSize: 14, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget helper for tags
  Widget buildTag(String label, IconData icon, Color bgColor, Color textColor,
      {bool border = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: border ? Border.all(color: Colors.grey) : null,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                offset: const Offset(0, 2),
                blurRadius: 4),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: textColor, fontSize: 12))
          ],
        ),
      ),
    );
  }

  Widget _buildTagContainer({required String text, required String iconPath}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.red,
              offset: Offset(0.3, 0.5),
              blurRadius: 0.5,
              spreadRadius: 0.8,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(0.5, 0.5),
              blurRadius: 0.5,
              spreadRadius: 0.5,
            ),
          ],
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                letterSpacing: 0.5,
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 5),
            Image.asset(
              iconPath,
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final phone = phoneCallNumber(agentDetail?.phone ?? '');
                if (phone.isNotEmpty) {
                  final telUrl = 'tel:$phone';
                  if (await canLaunchUrlString(telUrl)) {
                    await launchUrlString(telUrl, mode: LaunchMode.externalApplication);
                  }
                }
              },
              icon: const Center(
                child: Icon(Icons.call, color: Colors.red, size: 22),
              ),
              label: const Text("Call", style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final phoneRaw = agentDetail?.whatsapp ?? '';
                final phone = whatsAppNumber(phoneRaw); // 971XXXXXXXXX

                final message = Uri.encodeComponent("Hello");
                final waUrl = Uri.parse("https://wa.me/$phone?text=$message");

                if (await canLaunchUrl(waUrl)) {
                  try {
                    final launched = await launchUrl(
                      waUrl,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!launched) {
                      // ignore: avoid_print
                      print("❌ Could not launch WhatsApp");
                    }
                  } catch (e) {
                    // ignore: avoid_print
                    print("❌ Exception: $e");
                  }
                } else {
                  // ignore: avoid_print
                  print("❌ WhatsApp not available or URL not supported");
                }
              },
              icon: Image.asset("assets/images/whats.png", height: 20),
              label: const Text("WhatsApp", style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
