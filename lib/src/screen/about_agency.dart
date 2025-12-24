import 'dart:async';
import 'dart:convert';

import 'package:Akarat/src/screen/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Not url_launcher_string


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../device_id.dart';
import '../core/utils/secure_storage.dart';

import '../features/agency/data/models/agency_agent_model.dart';
import '../features/agency/data/models/agency_detail_model.dart';
import '../features/agency/data/models/agency_properties_model.dart' as propertyModel;
import '../features/property/data/models/toggle_model.dart';
import '../providers/email_enquiry_provider.dart';

import '../core/services/api_service.dart';
import '../core/utils/session_manager.dart';
import '../utils/fav_logout.dart';
import '../utils/shared_preference_manager.dart';
import '../widgets/read_more_text.dart';
import 'ContactFormScreen.dart';
import 'about_agent.dart';
import 'featured_detail.dart';
import 'home.dart';
import 'login.dart';
import 'my_account.dart';

// Force HTTPS so iOS hardware doesn't block http:// images/redirects
String secureUrl(String? url) {
  if (url == null) return '';
  return url.startsWith('http://')
      ? url.replaceFirst('http://', 'https://')
      : url;
}

class About_Agency extends StatefulWidget {
  const About_Agency({super.key, required this.data});
  final String data;

  @override
  State<About_Agency> createState() => _About_AgencyState();
}

class _About_AgencyState extends State<About_Agency> {
  AgencyDetailmodel? agencyDetailmodel;
  int pageIndex = 0;
  bool isFavorited = false;
  int? property_id;
  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;
  bool isAgentsLoading = true;
  bool _agencyLoading = true;
  String? _agencyError;

  // Shared prefs manager
  SharedPreferencesManager prefManager = SharedPreferencesManager();

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();


  int _safePropertyId(dynamic id) {
    if (id == null) return 0;
    if (id is int) return id;
    if (id is String) {
      return int.tryParse(id) ?? 0;
    }
    return 0;
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

  // Reuse your existing phone formatting functions (add if not already present)
  String phoneCallNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (input.startsWith('+971')) return input;
    if (input.startsWith('00971')) return '+971${input.substring(5)}';
    if (input.startsWith('971')) return '+971${input.substring(3)}';
    if (input.startsWith('0') && input.length == 10) return '+971${input.substring(1)}';
    if (input.length == 9) return '+971$input';
    return input;
  }

  String whatsAppNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d]'), '');
    if (input.startsWith('971')) return input;
    if (input.startsWith('00971')) return input.substring(2);
    if (input.startsWith('+971')) return input.substring(1);
    if (input.startsWith('0') && input.length == 10) return '971${input.substring(1)}';
    if (input.length == 9) return '971$input';
    return input;
  }

// API CALL: Send email inquiry to company
  // API CALL: Send email inquiry to company (using the beautiful dialog)
  Future<void> _sendCompanyEmailInquiry() async {
    if (agencyDetailmodel == null) return;

    final String companyName = agencyDetailmodel!.name ?? 'the agency';
    final int companyId = int.tryParse(widget.data) ?? 0;
    if (companyId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid agency ID")),
      );
      return;
    }

    // Extract local phone (without +971)
    String initialLocalPhone = '';
    final existingPhone = agencyDetailmodel!.phone ?? '';
    if (existingPhone.isNotEmpty) {
      String digits = existingPhone.replaceAll(RegExp(r'\D'), '');
      if (digits.startsWith('971')) digits = digits.substring(3);
      if (digits.startsWith('0')) digits = digits.substring(1);
      initialLocalPhone = digits;
    }

    final String defaultMessage =
        'Hi $companyName,\nI found your agency on Akarat and I’m interested in your properties and services. Please contact me.\nThank you!';

    await showEmailAgentDialog(
      context,
      subtitle: "Contact $companyName",
      initialMessage: defaultMessage,
      initialPhone: initialLocalPhone,
      onSubmit: ({
        required String name,
        required String email,
        required String phone,
        required String message,
      }) async {
        // Clean phone to local format (9 digits)
        String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
        if (cleanPhone.startsWith('971')) {
          cleanPhone = cleanPhone.substring(3);
        }

        final deviceId = await getDeviceId();
        final emailProvider = Provider.of<EmailEnquiryProvider>(context, listen: false);

        final bool success = await emailProvider.sendCompanyEmail(
          companyId: companyId,
          name: name,
          email: email,
          phone: cleanPhone,
          message: message.isEmpty ? "-" : message,
          deviceId: deviceId,
          token: token.isNotEmpty ? token : null,
        );

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(emailProvider.lastMessage ?? "Message sent successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Close dialog
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(emailProvider.lastError ?? "Failed to send message"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
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
  bool isLoadingMore = false;
  bool hasMoreData = true;
  List<propertyModel.Property> allProperties = [];
  propertyModel.AgencyPropertiesResponseModel? agencyPropertiesModel;
  final ScrollController _scrollController = ScrollController();

  AgencyAgentsModel? agencyAgentsModel;
  ToggleModel? toggleModel;

  int _currentImageIndex = 0;

  Set<int> favoriteProperties = {}; // Stores favorite property IDs

  @override
  void initState() {
    super.initState();
    _loadAgencyDetails();
    getAgentsApi(widget.data);
    readData();
    _loadFavorites();

    getFilesApi(widget.data); // Load page 1
    _scrollController.addListener(() {
      // debug logs
      print("📍 Scroll position: ${_scrollController.position.pixels}");
      print("📍 Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMoreData) {
        print("🚀 Triggering next page fetch");
        getFilesApi(widget.data);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _locationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAgencyDetails() async {
    if (mounted) {
      setState(() {
        _agencyLoading = true;
        _agencyError = null;
      });
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedKey = 'agency_details_${widget.data}';
    final cachedTimeKey = 'cached_time_agency_${widget.data}';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cachedTimeKey) ?? 0;

    try {
      // ✅ Use cache if within 6 hours
      if (now - lastFetched < const Duration(hours: 6).inMilliseconds) {
        final cachedData = prefs.getString(cachedKey);
        if (cachedData != null) {
          final jsonData = json.decode(cachedData);
          final model = AgencyDetailmodel.fromJson(jsonData);
          if (!mounted) return;
          setState(() {
            agencyDetailmodel = model;
            _agencyLoading = false;
          });
          return;
        }
      }

      // 🌐 Fallback to API
      final uri = ApiService.buildUri('company/${widget.data}');

      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final parsedModel = AgencyDetailmodel.fromJson(jsonData);

        await prefs.setString(cachedKey, json.encode(jsonData));
        await prefs.setInt(cachedTimeKey, now);

        if (!mounted) return;
        setState(() {
          agencyDetailmodel = parsedModel;
          _agencyLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _agencyError = 'API ${response.statusCode}';
          _agencyLoading = false;
        });
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _agencyError = 'timeout';
        _agencyLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _agencyError = '$e';
        _agencyLoading = false;
      });
    }
  }

  Future<void> getFilesApi(String user) async {
    if (isLoadingMore || !hasMoreData) {
      print(
          "⛔ Skipped fetch: isLoadingMore = $isLoadingMore, hasMoreData = $hasMoreData");
      return;
    }

    print("🔍 getFilesApi called for agency: $user, page: $currentPage");

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'agency_props_${user}_page_$currentPage';
    final cacheTimeKey = 'agency_props_time_${user}_page_$currentPage';

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // ⏱ Use cache if within 6 hours
    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      print("📦 Cache is fresh for page $currentPage");

      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        print("📦 Using cached data for key: $cacheKey");

        final jsonData = jsonDecode(cachedData);
        final feature =
        propertyModel.AgencyPropertiesResponseModel.fromJson(jsonData);

        final newProperties = feature.data?.data ?? [];
        final meta = feature.data?.meta;

        print("📦 Cached properties count: ${newProperties.length}");

        setState(() {
          allProperties.addAll(newProperties);
          if (meta != null &&
              meta.currentPage != null &&
              meta.lastPage != null) {
            if (meta.currentPage! >= meta.lastPage!) {
              hasMoreData = false;
            } else {
              currentPage = meta.currentPage! + 1;
            }
          } else {
            hasMoreData = false;
          }
          isLoadingMore = false;
        });

        print("✅ Loaded agency properties from cache (page $currentPage)");
        print(
            "📃 Total allProperties count after cache: ${allProperties.length}");
        return;
      } else {
        print("⚠️ Cache expected but not found for key: $cacheKey");
      }
    } else {
      print("⏱ Cache is expired or not present for page $currentPage");
    }

    // 🛰️ Fallback: API fetch
    setState(() => isLoadingMore = true);
    try {
      final uri = ApiService.buildUri('company/properties/$user?page=$currentPage');


      print("🌐 Calling API: $uri");

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 12));

      print("📄 API Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feature =
        propertyModel.AgencyPropertiesResponseModel.fromJson(data);
        final newProperties = feature.data?.data ?? [];
        final meta = feature.data?.meta;

        print("📊 API properties count: ${newProperties.length}");

        await prefs.setString(cacheKey, jsonEncode(data));
        await prefs.setInt(cacheTimeKey, now);

        setState(() {
          allProperties.addAll(newProperties);
          if (meta != null &&
              meta.currentPage != null &&
              meta.lastPage != null) {
            if (meta.currentPage! >= meta.lastPage!) {
              hasMoreData = false;
            } else {
              currentPage = meta.currentPage! + 1;
            }
          } else {
            hasMoreData = false;
          }
          isLoadingMore = false;
        });

        print("✅ API properties loaded & cached (page $currentPage)");
        print("📃 Total allProperties count after API: ${allProperties.length}");
      } else {
        print("❌ Failed: status code ${response.statusCode}");
        setState(() => isLoadingMore = false);
      }
    } catch (e) {
      print("❌ Error fetching properties: $e");
      setState(() => isLoadingMore = false);
    }
    catch (e) {
      print("❌ Error fetching properties: $e");
      setState(() => isLoadingMore = false);
    }
  }

  Future<void> getAgentsApi(String user) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'agency_agents_$user';
    final cacheTimeKey = 'agency_agents_time_$user';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    try {
      // Use cache if fresh
      if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
        final cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          final jsonData = json.decode(cachedData);
          setState(() {
            agencyAgentsModel = AgencyAgentsModel.fromJson(jsonData);
            isAgentsLoading = false;
          });
          return;
        }
      }

      final uri = ApiService.buildUri('company/agents/$user');

      final response =
      await http.get(uri).timeout(const Duration(seconds: 12));
      debugPrint('Agents status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString(cacheKey, json.encode(data));
        await prefs.setInt(cacheTimeKey, now);
        setState(() {
          agencyAgentsModel = AgencyAgentsModel.fromJson(data);
          isAgentsLoading = false;
        });
      } else {
        debugPrint(
            "❌ Agents API failed: ${response.statusCode} / ${response.body}");
        setState(() => isAgentsLoading = false);
      }
    } on TimeoutException catch (e) {
      debugPrint("⏱️ Agents timeout: $e");
      setState(() => isAgentsLoading = false);
    } catch (e) {
      debugPrint("🚨 Agents exception: $e");
      setState(() => isAgentsLoading = false);
    }
  }

  Future<void> toggledApi(token, propertyId) async {
    try {
      final uri = ApiService.buildUri('toggle-saved-property');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "property_id": propertyId,
        }),
      );


      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        toggleModel = ToggleModel.fromJson(jsonData);
        debugPrint("✅ Property toggled successfully");
      } else {
        debugPrint("❌ Toggle failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Toggle error: $e");
    }
  }

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


  // ──────────────────────────────────────────────────────────────
  //  ADD THESE 3 FUNCTIONS HERE (inside _About_AgencyState class)
  // ──────────────────────────────────────────────────────────────

  // ────────────────────── FINAL VERSION – WORKS WITH YOUR MODEL ──────────────────────

  // ────────────────────── NEW CHIP STYLE – SAME AS YOUR OTHER SCREENS ──────────────────────
  Widget _buildInfoChip(String iconPath, String? value) {
    // Hide completely if null, empty, "0", or "null"
    if (value == null || value.trim().isEmpty || value.trim() == "0" || value.trim() == "null") {
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
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String? getDisplaySize(propertyModel.Property property) {
    String? rawSize;

    // Priority 1: propertySizeSqft (first priority)
    if (property.propertySizeSqft != null) {
      final value = property.propertySizeSqft.toString().trim();
      if (value.isNotEmpty && value != "0" && value != "null") {
        rawSize = value;
      }
    }

    // Priority 2: fallback to square_feet only if first one is missing or invalid
    if (rawSize == null && property.squareFeet != null) {
      final value = property.squareFeet.toString().trim();
      if (value.isNotEmpty && value != "0" && value != "null") {
        rawSize = value;
      }
    }

    // If both are null, empty, or zero → hide the size completely
    if (rawSize == null) return null;

    final double? size = double.tryParse(rawSize);
    if (size == null || size <= 0) return null;

    // Format number with commas: 11000 → 11,000
    final formattedSize = size.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
    );

    return "$formattedSize sqft";
  }


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);

    // NEW: Agency loading state
    if (_agencyLoading) {
      return Scaffold(
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (_, __) => const ShimmerCard(),
        ),
      );
    }

    if (agencyDetailmodel == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load agency'),
              if (_agencyError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _agencyError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadAgencyDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      /// ====== BOTTOM BAR (Email / Call / WhatsApp) ======
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // EMAIL - Fixed: uses correct method
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
                        Icon(Icons.email_outlined, size: 20, color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          'Email',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // CALL - Fixed: uses agencyDetailmodel
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final phoneRaw = agencyDetailmodel?.phone?.trim() ?? '';
                    if (phoneRaw.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Phone number not available")),
                      );
                      return;
                    }

                    final phone = phoneCallNumber(phoneRaw);
                    final uri = Uri(scheme: 'tel', path: phone);

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // WHATSAPP - Fixed: uses agencyDetailmodel + fallback
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final whatsappRaw = agencyDetailmodel?.whatsapp?.trim();
                    final phoneRaw = whatsappRaw?.isNotEmpty == true
                        ? whatsappRaw!
                        : (agencyDetailmodel?.phone?.trim() ?? '');

                    if (phoneRaw.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("WhatsApp number not available")),
                      );
                      return;
                    }

                    final phone = whatsAppNumber(phoneRaw);
                    if (phone.isEmpty || phone.length < 9) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid WhatsApp number")),
                      );
                      return;
                    }

                    final message = Uri.encodeComponent(
                        "Hello, I found your agency on Akarat and would like to connect.");
                    final uri = Uri.parse("https://wa.me/$phone?text=$message");

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("WhatsApp is not installed")),
                      );
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
                        Image.asset(
                          "assets/images/whats.png",
                          height: 20,
                          errorBuilder: (_, __, ___) => const Icon(Icons.message, size: 20, color: Colors.green),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'WhatsApp',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
        length: 4,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            Container(
              height: screenSize.height * 0.22,
              color: const Color(0xFFF5F5F5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        // currently just spacing
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    child: Padding(
                      padding:
                      const EdgeInsets.only(top: 30, bottom: 4),
                      child: Container(
                        height: screenSize.height * 0.12,
                        width: screenSize.width * 0.91,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.grey.withOpacity(0.5),
                              offset: const Offset(4, 4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color:
                              Colors.white.withOpacity(0.8),
                              offset: const Offset(-4, -4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            /// Logo
                            SizedBox(
                              width: screenSize.width * 0.29,
                              height: screenSize.height * 0.12,
                              child: Align(
                                alignment: Alignment.center,
                                child: CachedNetworkImage(
                                  imageUrl: secureUrl(
                                      agencyDetailmodel?.image),
                                  height:
                                  screenSize.height * 0.08,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    agencyDetailmodel!.name
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow:
                                    TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets
                                        .symmetric(
                                        horizontal: 8,
                                        vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey
                                              .withOpacity(0.5),
                                          offset:
                                          const Offset(4, 4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: Colors.white
                                              .withOpacity(0.8),
                                          offset:
                                          const Offset(-4, -4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                      borderRadius:
                                      BorderRadius.circular(
                                          6),
                                    ),
                                    child: Text(
                                      "${agencyDetailmodel!.propertiesCount} Properties",
                                      textAlign:
                                      TextAlign.center,
                                      style: const TextStyle(
                                        letterSpacing: 0.5,
                                        color:
                                        Colors.blueAccent,
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
                  ),
                ],
              ),
            ),
            TabBar(
              padding:
              const EdgeInsets.only(top: 15, left: 0, right: 0),
              labelPadding:
              const EdgeInsets.symmetric(horizontal: 0),
              splashFactory: NoSplash.splashFactory,
              indicatorWeight: 1.0,
              labelColor: Colors.lightBlueAccent,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              tabAlignment: TabAlignment.center,
              tabs: [
                _tabItem('About'),
                _tabItem('Properties'),
                _tabItem('Agents'),
                _tabItem('Review'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ABOUT TAB
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10.0),
                            child: Row(
                              children: const [
                                Text(
                                  "About  ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                          ),

                          // DESCRIPTION
                          if (agencyDetailmodel?.description !=
                              null)
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Description ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                (agencyDetailmodel!
                                    .description !=
                                    null &&
                                    agencyDetailmodel!
                                        .description!
                                        .trim()
                                        .isNotEmpty)
                                    ? Padding(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                      horizontal:
                                      10.0),
                                  child: ReadMoreText(
                                    agencyDetailmodel!
                                        .description!,
                                    trimMode:
                                    TrimMode.line,
                                    trimLines: 4,
                                    trimCollapsedText:
                                    ' Read more',
                                    trimExpandedText:
                                    ' Read less',
                                    style:
                                    const TextStyle(
                                      fontSize: 15,
                                      color:
                                      Colors.black,
                                      letterSpacing:
                                      0.5,
                                    ),
                                    moreStyle:
                                    const TextStyle(
                                      fontSize: 15,
                                      color:
                                      Colors.blue,
                                      letterSpacing:
                                      0.5,
                                      fontWeight:
                                      FontWeight
                                          .w600,
                                    ),
                                    lessStyle:
                                    const TextStyle(
                                      fontSize: 15,
                                      color:
                                      Colors.blue,
                                      letterSpacing:
                                      0.5,
                                      fontWeight:
                                      FontWeight
                                          .w600,
                                    ),
                                  ),
                                )
                                    : const Padding(
                                  padding:
                                  EdgeInsets
                                      .symmetric(
                                      horizontal:
                                      15.0),
                                  child: Text(
                                    "No description available",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                      Colors.black54,
                                      fontStyle:
                                      FontStyle
                                          .italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 12),
                          // SERVICE AREAS
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10.0),
                            child: Row(
                              children: const [
                                Text(
                                  "Service Areas",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10.0),
                            child: Row(
                              children: const [
                                Text(
                                  "Meydan City, Al Marjan Island, Dubailand",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),
                          // PROPERTY TYPE
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10.0),
                            child: Row(
                              children: const [
                                Text(
                                  "Property Type",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10.0),
                            child: Row(
                              children: const [
                                Text(
                                  "Villas, Townhouses, Apartments",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),
                          // DED
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10.0),
                            child: Row(
                              children: const [
                                Text(
                                  "DED",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10.0),
                            child: Row(
                              children: [
                                Text(
                                  agencyDetailmodel!.ded
                                      .toString(),
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
                          // RERA
                          // Padding(
                          //   padding:
                          //   const EdgeInsets.symmetric(
                          //       horizontal: 10.0),
                          //   child: Row(
                          //     children: const [
                          //       Text(
                          //         "RERA",
                          //         style: TextStyle(
                          //           fontSize: 16,
                          //           color: Colors.grey,
                          //           letterSpacing: 0.5,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // const SizedBox(height: 5),
                          // Padding(
                          //   padding:
                          //   const EdgeInsets.symmetric(
                          //       horizontal: 10.0),
                          //   child: Row(
                          //     children: [
                          //       Text(
                          //         agencyDetailmodel!.rera
                          //             .toString(),
                          //         style: const TextStyle(
                          //           fontSize: 15,
                          //           color: Colors.black,
                          //           letterSpacing: 0.5,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // PROPERTIES TAB
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 0, right: 0, top: 15),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(0),
                              controller: _scrollController,
                              itemCount: allProperties.length +
                                  (isLoadingMore ? 1 : 0),
                              physics:
                              const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if (index ==
                                    allProperties.length) {
                                  return const Center(
                                    child: Padding(
                                      padding:
                                      EdgeInsets.all(10.0),
                                      child:
                                      CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final property =
                                allProperties[index];
                                bool isFavorited =
                                favoriteProperties
                                    .contains(
                                    property.id);

                                return GestureDetector(
                                  onTap: () {
                                    String id = property.id
                                        .toString();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Featured_Detail(
                                                data: id),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.only(
                                        bottom: 15),
                                    child: Card(
                                      color: Colors.white,
                                      borderOnForeground:
                                      true,
                                      shadowColor:
                                      Colors.white,
                                      elevation: 10,
                                      child: Padding(
                                        padding:
                                        const EdgeInsets
                                            .only(
                                          left: 5.0,
                                          top: 0,
                                          right: 5,
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                              const EdgeInsets
                                                  .only(
                                                top: 0.0,
                                              ),
                                              child:
                                              ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                                child: Stack(
                                                  children: [
                                                    AspectRatio(
                                                      aspectRatio:
                                                      1.6,
                                                      child: ListView
                                                          .builder(
                                                        scrollDirection:
                                                        Axis.horizontal,
                                                        itemCount: property.media?.length ??
                                                            0,
                                                        itemBuilder:
                                                            (context,
                                                            mediaIndex) {
                                                          return CachedNetworkImage(
                                                            imageUrl:
                                                            secureUrl(property.media![mediaIndex].originalUrl),
                                                            fit:
                                                            BoxFit.fill,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    // indicator dots
                                                    Positioned(
                                                      bottom:
                                                      12,
                                                      left:
                                                      0,
                                                      right:
                                                      0,
                                                      child:
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children:
                                                        List.generate(
                                                          property.media?.length ?? 0,
                                                              (index) {
                                                            final distance = (index - _currentImageIndex).abs();
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
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(
                                                top: 5,
                                              ),
                                              child: ListTile(
                                                title:
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                    top: 5.0,
                                                    bottom:
                                                    5,
                                                  ),
                                                  child:
                                                  Text(
                                                    property.title.toString(),
                                                    style:
                                                    const TextStyle(
                                                      fontSize: 16,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                                subtitle:
                                                Text(
                                                  '${property.price} AED',
                                                  style:
                                                  const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // LOCATION + SPECS ROW (clean & no overflow)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Location
                                                  Row(
                                                    children: [
                                                      Image.asset("assets/images/map.png", height: 14),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          property.location ?? '',
                                                          style: const TextStyle(fontSize: 13),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),

                                                  // Beds • Baths • Size (same style as your other screens)
                                                  Row(
                                                    children: [
                                                      _buildInfoChip("assets/images/bed.png", property.bedrooms),
                                                      if (property.bedrooms != null && property.bedrooms != "0") const SizedBox(width: 15),
                                                      _buildInfoChip("assets/images/bath.png", property.bathrooms),
                                                      if (property.bathrooms != null && property.bathrooms != "0") const SizedBox(width: 15),
                                                      _buildInfoChip("assets/images/messure.png", getDisplaySize(property)),
                                                    ]
                                                        .where((widget) => widget is! SizedBox || (widget as SizedBox).width != null)
                                                        .toList(),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(height: 12),
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

                  // AGENTS TAB
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(
                      builder: (context) {
                        if (isAgentsLoading) {
                          return const Center(
                              child:
                              CircularProgressIndicator());
                        }

                        final agents =
                            agencyAgentsModel?.data ?? const [];

                        if (agents.isEmpty) {
                          return const Center(
                              child: Text('No agents found'));
                        }

                        final String agencyLogo =
                        secureUrl(agencyDetailmodel?.image);
                        final bool isValidLogo =
                            agencyLogo.isNotEmpty;

                        return ListView.separated(
                          physics:
                          const AlwaysScrollableScrollPhysics(),
                          itemCount: agents.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final agent = agents[index];

                            final String imageUrl =
                            secureUrl(agent.image);
                            final bool isValidImage =
                                imageUrl.isNotEmpty;

                            return GestureDetector(
                              onTap: () {
                                final id =
                                    agent.id?.toString() ?? '';
                                if (id.isEmpty) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AboutAgent(
                                          data: id,
                                        ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 6.0,
                                ),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 6,
                                  shadowColor:
                                  Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        10),
                                  ),
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.all(
                                        10.0),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor:
                                          Colors.grey
                                              .shade200,
                                          backgroundImage: isValidImage
                                              ? NetworkImage(
                                              imageUrl)
                                              : const AssetImage(
                                            'assets/images/profile.png',
                                          )
                                          as ImageProvider,
                                        ),
                                        const SizedBox(
                                            width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                agent.name ??
                                                    '',
                                                style:
                                                const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  letterSpacing:
                                                  0.5,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                  height: 4),
                                              Text(
                                                "${(agent.sale ?? 0) + (agent.rent ?? 0)} Properties",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF3A7CED),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                  height: 4),
                                              Text(
                                                "Speaks: ${agent.languages?.isNotEmpty == true ? agent.languages : 'N/A'}",
                                                style:
                                                const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors
                                                      .black54,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                  height: 8),
                                              Row(
                                                children: [
                                                  _pill(
                                                      "${agent.sale ?? 0} Sale"),
                                                  const SizedBox(
                                                      width:
                                                      10),
                                                  _pill(
                                                      "${agent.rent ?? 0} Rent"),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height: 6),
                                              if (agent.bio
                                                  ?.trim()
                                                  .isNotEmpty ==
                                                  true)
                                                Text(
                                                  agent.bio!
                                                      .trim(),
                                                  style:
                                                  const TextStyle(
                                                    fontSize:
                                                    11,
                                                    color: Colors
                                                        .black45,
                                                    fontStyle:
                                                    FontStyle
                                                        .italic,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (isValidLogo)
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                left:
                                                6.0),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  6),
                                              child:
                                              Image.network(
                                                agencyLogo,
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit
                                                    .cover,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // REVIEWS TAB
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Text(
                            "Reviews",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 50), // Nice spacing

                          // Centered "Coming Soon" Section
                          Center(
                            child: Column(
                              children: [
                                // Optional: Add a subtle icon
                                Icon(
                                  Icons.rate_review_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 24),

                                // Main Text
                                Text(
                                  "Coming Soon",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                    letterSpacing: 0.5,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Subtitle
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40),
                                  child: Text(
                                    "Agent reviews and ratings will be available here soon. Stay tuned!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Optional: Add a little decorative line or dot
                                Container(
                                  width: 80,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Extra bottom space so it doesn't stick to the bottom
                          const SizedBox(height: 100),
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

  Widget _tabItem(String label) {
    return Container(
      margin: const EdgeInsets.only(left: 5),
      width: 80,
      height: 40,
      padding: const EdgeInsets.only(top: 9),
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
      ),
    );
  }





}

// Small label used in the Agents cards
Widget _pill(String text) => Container(
  width: 55,
  height: 20,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: Colors.white),
    boxShadow: const [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 2,
        offset: Offset(0, 0),
      ),
    ],
  ),
  child: Center(
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Color(0xFF3A7CED),
      ),
    ),
  ),
);

Widget _buildTagContainer(
    {required String text,
      required String iconPath}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
        horizontal: 3.0, vertical: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(8.0),
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

