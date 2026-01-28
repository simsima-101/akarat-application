import 'dart:async';
import 'dart:convert';

import 'package:Akarat/src/features/property/data/models/property_model.dart';
import 'package:Akarat/src/screen/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../device_id.dart';
import '../common/widgets/property_card.dart';
import '../core/services/api_service.dart';
import '../core/utils/secure_storage.dart';
import '../features/agency/data/models/agent_detaill.dart';
import '../features/agency/data/models/agent_properties_model.dart';
import '../features/agent/presentation/bloc/agent_enquiry_bloc.dart';
import '../features/agent/presentation/bloc/agent_enquiry_event.dart';
import '../features/property/data/datasources/favorite_remote_datasource.dart';
import '../utils/shared_preference_manager.dart';
import '../widgets/read_more_text.dart';
import 'ContactFormScreen.dart';

class AboutAgent extends StatefulWidget {
  const AboutAgent({
    super.key,
    required this.data,
    this.initialTabIndex = 0,
  });
  final String data;
  final int initialTabIndex;
  @override
  State<AboutAgent> createState() => _AboutAgentState();
}

class _AboutAgentState extends State<AboutAgent> {
  AgentDetail? agentDetail;
  int pageIndex = 0;
  int _currentImageIndex = 0;

  bool isFavorited = false;
  int? property_id;

  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;

  int _safePropertyId(dynamic id) {
    if (id == null) return 0;
    if (id is int) return id;
    if (id is String) {
      return int.tryParse(id) ?? 0;
    }
    return 0;
  }

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

  // ──────────────────────────────────────────────────────────────
  //  ADD THESE TWO FUNCTIONS HERE (before _showEmailAgentDialog)
  // ──────────────────────────────────────────────────────────────

  /// Same beautiful chip style as the Agency screen
  Widget _buildInfoChip(String iconPath, String? value) {
    if (value == null ||
        value.trim().isEmpty ||
        value.trim() == "0" ||
        value.trim() == "null") {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(iconPath, width: 18, height: 18),
        const SizedBox(width: 6),
        Text(
          value.trim(),
          style: const TextStyle(
              fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  /// Works perfectly with your real model → uses 'Data' class (not Property)

  /// CORRECTED & WORKING: propertySizeSqft has HIGHEST priority
  String? getDisplaySize(Data property) {
    String? rawSize;

    // STEP 1: First priority — propertySizeSqft (even if it's String, int, or null)
    if (property.propertySizeSqft != null) {
      final value = property.propertySizeSqft.toString().trim();
      if (value.isNotEmpty && value != "0" && value != "null") {
        rawSize = value;
        // We found a valid value → STOP HERE, don't check square_feet
      }
    }

    // STEP 2: Only if propertySizeSqft is missing or invalid → check square_feet
    if (rawSize == null && property.squareFeet != null) {
      final value = property.squareFeet!.trim();
      if (value.isNotEmpty && value != "0" && value != "null") {
        rawSize = value;
      }
    }

    // STEP 3: Both are null/0 → hide the field completely
    if (rawSize == null) return null;

    final double? size = double.tryParse(rawSize);
    if (size == null || size <= 0) return null;

    final formatted = size.toInt().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );

    return "$formatted sqft";
  }

  // FIXED EMAIL DIALOG FOR AGENT SCREEN - USING BLOC
  Future<void> _showEmailAgentDialog() async {
    if (agentDetail == null) return;

    final String agentName = agentDetail!.name ?? 'the agent';

    String initialLocalPhone = '';
    final existingPhone = agentDetail!.phone ?? '';
    if (existingPhone.isNotEmpty) {
      String digits = existingPhone.replaceAll(RegExp(r'\D'), '');
      if (digits.startsWith('971')) digits = digits.substring(3);
      if (digits.startsWith('0')) digits = digits.substring(1);
      initialLocalPhone = digits;
    }

    final String initialMessage =
        'Hi $agentName,\nI saw your profile on Akarat and would like to discuss properties or services. Please contact me.\nThank you!';

    await showEmailAgentDialog(
      context,
      subtitle: "Contact $agentName",
      initialMessage: initialMessage,
      initialPhone: initialLocalPhone,
      onSubmit: ({
        required String name,
        required String email,
        required String phone,
        required String message,
      }) async {
        // Clean phone number
        String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
        if (cleanPhone.startsWith('971')) {
          cleanPhone = cleanPhone.substring(3);
        }

        final deviceId = await getDeviceId();
        final int agentId = int.tryParse(widget.data) ?? 0;

        // Dispatch event to Bloc
        context.read<AgentEnquiryBloc>().add(
              SendAgentEnquiry(
                agentId: agentId,
                name: name,
                email: email,
                phone: cleanPhone,
                message: message.isEmpty ? '-' : message,
                deviceId: deviceId,
                token: token.isNotEmpty ? token : null,
              ),
            );

        // Close dialog immediately for better UX
        if (mounted) {
          Navigator.pop(context);

          // Optional: Show temporary "sending" message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sending message...'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.blue,
            ),
          );
        }
      },
    );
  }

  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  @override
  @override
  void initState() {
    super.initState();

    final String agentId = widget.data;

    // ONE-TIME: Clear any old corrupted agent detail cache (run once, then you can remove these lines)
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('agent_detail_$agentId');
      prefs.remove('agent_detail_time_$agentId');
      debugPrint("Old agent cache cleared for ID: $agentId");
    });

    // Clear old agent properties cache (you already had this — keep it)
    clearAgentPropertiesCache(agentId).then((_) {
      getFilesApi(agentId, loadMore: false);
    });

    // Load the agent detail (this now works perfectly with your real API)
    fetchProducts(agentId);

    // Load first page of properties
    getFilesApi(agentId, loadMore: false);

    // Other setups
    readData();
    _loadFavorites();

    // Search listener
    _searchController.addListener(_onSearchChanged);

    // Infinite scroll for properties
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore &&
          !isLoading) {
        getFilesApi(agentId, loadMore: true);
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

    // Check cache first
    final cachedTime = prefs.getInt(cacheTimeKey);
    final isCacheValid = cachedTime != null &&
        (now - cachedTime) < Duration(hours: 6).inMilliseconds;

    if (isCacheValid) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        try {
          final jsonMap = jsonDecode(cached);
          setState(() {
            agentDetail = AgentDetail.fromJson(jsonMap);
          });
          debugPrint("Agent loaded from cache");
          return;
        } catch (e) {
          debugPrint("Cache corrupted, clearing...: $e");
          await prefs.remove(cacheKey);
          await prefs.remove(cacheTimeKey);
        }
      }
    }

    try {
      // final uri = ApiService.buildUri('agent/$data');
      // final response = await http.get(uri);

      final response = await ApiService.get(
        'agent/$data',
      ).timeout(const Duration(seconds: 25));

      debugPrint("Agent API Status: ${response.statusCode}");

      if (response.statusCode != 200) {
        debugPrint("API failed: ${response.statusCode}");
        return;
      }

      final responseData = json.decode(response.body);
      Map<String, dynamic> agentData;

      // Handle both possible response structures
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          // Paginated response structure
          final dataWrapper = responseData['data'];
          if (dataWrapper is Map<String, dynamic> &&
              dataWrapper.containsKey('data')) {
            final agentList = dataWrapper['data'] as List?;
            if (agentList != null && agentList.isNotEmpty) {
              agentData = agentList.first as Map<String, dynamic>;
              debugPrint("Extracted agent from paginated response");
            } else {
              debugPrint("No agent found in paginated response");
              return;
            }
          } else {
            // Direct data object
            agentData = dataWrapper as Map<String, dynamic>;
            debugPrint("Using direct data object from response");
          }
        } else {
          // Direct agent object without any wrapper
          agentData = responseData;
          debugPrint("Using direct agent object from response");
        }
      } else {
        debugPrint("Unexpected response type: ${responseData.runtimeType}");
        return;
      }

      final agent = AgentDetail.fromJson(agentData);

      // Cache the individual agent data
      await prefs.setString(cacheKey, jsonEncode(agentData));
      await prefs.setInt(cacheTimeKey, now);

      if (mounted) {
        setState(() {
          agentDetail = agent;
        });
      }

      debugPrint("Agent loaded successfully");
    } catch (e, stack) {
      debugPrint("Exception in fetchProducts: $e");
      debugPrint(stack.toString());
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
    // final uri = ApiService.buildUri('filters?search=$query'
    //     '&amenities='
    //     '&property_type='
    //     '&furnished_status='
    //     '&bedrooms='
    //     '&min_price='
    //     '&max_price='
    //     '&payment_period='
    //     '&min_square_feet='
    //     '&max_square_feet='
    //     '&bathrooms='
    //     '&purpose=');

    try {
      // final response = await http.get(uri);

      final response = await ApiService.get(
        'filters',
        query: {
          'search': query,
          'amenities': '',
          'property_type': '',
          'furnished_status': '',
          'bedrooms': '',
          'min_price': '',
          'max_price': '',
          'payment_period': '',
          'min_square_feet': '',
          'max_square_feet': '',
          'bathrooms': '',
          'purpose': '',
        },
      ).timeout(const Duration(seconds: 25)); // 15s timeout – safe & reasonable

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

    try {
      // final uri =
      //     ApiService.buildUri('agent/properties/$user?page=$currentPage');
      // final response = await http.get(uri);

      final response = await ApiService.get(
        'agent/properties/$user',
        query: {
          'page': currentPage.toString(),
        },
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if the response contains an error about saved properties
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          final message = responseData['message'] as String?;
          if (message != null && message.contains('created_at')) {
            debugPrint("Server error with saved properties: $message");
            // Continue without saved properties or show empty list
            if (mounted) {
              setState(() {
                agentProperties = AgentProperties(
                  data: [], // Empty properties list
                  links: null,
                  meta: null,
                );
              });
            }
            isLoading = false;
            return;
          }
        }

        if (responseData['data'] != null) {
          final model = AgentProperties.fromJson(responseData['data']);

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

          // Cache the data
          if (!loadMore) {
            final prefs = await SharedPreferences.getInstance();
            final cacheKey = 'agent_properties_$user';
            final cacheTimeKey = 'agent_properties_time_$user';
            await prefs.setString(cacheKey, jsonEncode(responseData['data']));
            await prefs.setInt(
                cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
          }
        }
      } else {
        debugPrint("API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception in getFilesApi: $e");
    }

    isLoading = false;
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

      /// ====== BOTTOM BAR (Email / Call / WhatsApp) ======
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // EMAIL
              Expanded(
                child: GestureDetector(
                  onTap: () => showHomeContactDialog(context),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined,
                            size: 20, color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          'Email',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // CALL
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final phone = phoneCallNumber(agentDetail?.phone ?? '');
                    if (phone.isNotEmpty) {
                      final telUrl = 'tel:$phone';
                      if (await canLaunchUrlString(telUrl)) {
                        await launchUrlString(telUrl,
                            mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.call_outlined, size: 20, color: Colors.red),
                        SizedBox(width: 6),
                        Text(
                          'Call',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // WHATSAPP
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final phoneRaw =
                        agentDetail?.whatsapp ?? agentDetail?.phone ?? '';
                    final phone = whatsAppNumber(phoneRaw);
                    if (phone.isEmpty) return;

                    final message = Uri.encodeComponent("Hello");
                    final waUrl =
                        Uri.parse("https://wa.me/$phone?text=$message");

                    if (await canLaunchUrl(waUrl)) {
                      await launchUrl(waUrl,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/whats.png", height: 20),
                        const SizedBox(width: 6),
                        const Text(
                          'WhatsApp',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: DefaultTabController(
        length: 3,
        initialIndex: widget.initialTabIndex,
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

            // // --- TAGS ROW ---
            // Container(
            //   height: screenSize.height * 0.04,
            //   margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            //   child: ListView(
            //     scrollDirection: Axis.horizontal,
            //     children: [
            //       buildTag("Prime Agent", Icons.check_circle, Colors.blueAccent,
            //           Colors.white),
            //       buildTag("Quality Listener", Icons.stars, Color(0xFFEAD893),
            //           Colors.black),
            //       // buildTag("Responsive Broker", Icons.call_outlined, Colors.white, Colors.black, border: true),
            //     ],
            //   ),
            // ),

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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
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
                                agentDetail!.about != null &&
                                        agentDetail!.about!.trim().isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: ReadMoreText(
                                          agentDetail!.about ?? '',
                                          trimMode: TrimMode.line,
                                          trimLines: 4,
                                          trimCollapsedText: ' Read more',
                                          trimExpandedText: ' Read less',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              letterSpacing: 0.5),
                                          moreStyle: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue,
                                              letterSpacing: 0.5,
                                              fontWeight: FontWeight.w600),
                                          lessStyle: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue,
                                              letterSpacing: 0.5,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Text(
                                          "No description available",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                if (agentDetail?.expertise != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
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
                                if ((agentDetail?.serviceAreas
                                        ?.toString()
                                        .trim()
                                        .isNotEmpty ??
                                    false))
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: ReadMoreText(
                                            agentDetail!.serviceAreas
                                                    ?.toString() ??
                                                '',
                                            trimMode: TrimMode.line,
                                            trimLines: 4,
                                            trimCollapsedText: ' Read more',
                                            trimExpandedText: ' Read less',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                letterSpacing: 0.5),
                                            moreStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.blue,
                                                letterSpacing: 0.5,
                                                fontWeight: FontWeight.w600),
                                            lessStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.blue,
                                                letterSpacing: 0.5,
                                                fontWeight: FontWeight.w600),
                                          )),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Language(s)",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${agentDetail!.languages}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
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
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "BRN",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          Chip(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "${agentDetail!.brokerRegisterationNumber}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Gap(5),
                                                const Icon(Icons.verified,
                                                    size: 20,
                                                    color: Colors.green),
                                              ],
                                            ),
                                            backgroundColor:
                                                Colors.grey.shade200,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 35),
                      // ),
                    ],
                  ),

                  //------------------------- Agent Property -----------------------------------
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Expanded(
                          child: agentProperties == null
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 10),
                                  itemCount: agentProperties!.data!.length +
                                      (isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index ==
                                        agentProperties!.data!.length) {
                                      return const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    }

                                    final Data item =
                                        agentProperties!.data![index];
                                    final Property property = item.toProperty();

                                    // ← CLEAN, REUSABLE, BEAUTIFUL CARD
                                    return PropertyCard(item: property);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                  //------------------------- Agent Reviews ----------------------------------
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
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
                          const SizedBox(
                              height: 40), // Space before "Coming Soon"

                          // Centered "Coming Soon" message
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.rate_review_outlined,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Coming Soon",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Agent reviews will be available here soon",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                              height: 100), // Extra bottom space (optional)
                        ],
                      ),
                    ),
                  ),
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
}
