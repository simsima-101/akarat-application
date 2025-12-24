import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Akarat/src/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/property/data/models/product_model.dart';
import '../core/services/api_service.dart';
import '../utils/shared_preference_manager.dart';
import 'about_agent.dart';
import 'full_map_screen.dart';
import 'home.dart';
import 'htmlEpandableText.dart';
import 'my_account.dart';

class Agency_Detail extends StatefulWidget {
  const Agency_Detail({super.key, required this.data});
  final String data;

  @override
  State<Agency_Detail> createState() => _Agency_DetailState();
}

class _Agency_DetailState extends State<Agency_Detail> {
  int pageIndex = 0;
  ProductModel? productModels;

  // Validate-listing (DLD) result
  String? _qrImageUrl; // image to show
  String? _qrLink;     // link to open when tapped
  bool _isValidating = false;

  // For phone calls: Always output in +971... format
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

  Future<void> _callValidateListing({
    required String permitNumber,
    required String listingId,
  }) async {
    setState(() => _isValidating = true);

    final uri = ApiService.buildUri(
      'validate-listing/$permitNumber/$listingId',
      query: {'isGenerateQrCode': 'true'},
    );

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(resp.body);
        final data = (jsonBody['data'] as Map?) ?? jsonBody;

        final qrUrl  = (data['qr_url'] ?? data['qrImage'] ?? data['qr_image'] ?? data['qr'])?.toString();
        final qrLink = (data['qrLink'] ?? data['link'])?.toString();

        if (mounted) {
          setState(() {
            _qrImageUrl = (qrUrl ?? '').isNotEmpty ? qrUrl : _qrImageUrl;
            _qrLink     = (qrLink ?? '').isNotEmpty ? qrLink : _qrLink;
          });
        }
      } else {
        debugPrint('❌ validate-listing failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      debugPrint('🚨 validate-listing error: $e');
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  Future<bool> toggledApi(String token, int id) async {

    final url = ApiService.buildUri('toggle-saved-property');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {'property_id': id.toString()},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Toggle API failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Toggle API exception: $e');
      return false;
    }
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    fetchProducts(widget.data);
    super.initState();
  }

  Future<void> fetchProducts(String data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'product_cache_$data';
    final cacheTimeKey = 'product_cache_time_$data';

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // ✅ Use cache if it's less than 6 hours old
    if (now - lastFetched < const Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final cachedModel = ProductModel.fromJson(jsonData);
        if (mounted) {
          setState(() => productModels = cachedModel);
        }
        debugPrint("📦 Loaded product from cache");

        // Also try validate-listing with cached data if we can
        final permitNumber = (cachedModel.data?.regulatoryInfo?.dldPermitNumber ?? '').toString().trim();
        final listingId = (cachedModel.data?.id ?? widget.data).toString();
        if (permitNumber.isNotEmpty && listingId.isNotEmpty) {
          _callValidateListing(permitNumber: permitNumber, listingId: listingId);
        }
        return;
      }
    }

    try {
      final response = await http
          .get(ApiService.buildUri('properties/$data'))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final parsedModel = ProductModel.fromJson(jsonData);

        // 🗂 Save to cache
        await prefs.setString(cacheKey, jsonEncode(jsonData));
        await prefs.setInt(cacheTimeKey, now);

        if (!mounted) return;
        setState(() => productModels = parsedModel);
        debugPrint("✅ Fetched fresh product data");

        // ✅ After property is set, trigger Validate Listing call
        try {
          final permitNumber =
          (parsedModel.data?.regulatoryInfo?.dldPermitNumber ?? '').toString().trim();

          // ⛳️ No listingId on your Data model → use property id (or widget.data)
          final listingId = (parsedModel.data?.id ?? widget.data).toString();

          if (permitNumber.isNotEmpty && listingId.isNotEmpty) {
            _callValidateListing(
              permitNumber: permitNumber,
              listingId: listingId,
            );
          } else {
            debugPrint('ℹ️ Missing permit/id; skipping validate-listing call.');
          }
        } catch (e) {
          debugPrint('validate-listing param error: $e');
        }
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("⏳ Request timed out.");
    } on SocketException {
      debugPrint("📡 No Internet.");
    } catch (e) {
      debugPrint("🚨 Error in fetchProducts: $e");
    }
  }

  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;

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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if (productModels == null) {
      return Scaffold(
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerCard(),
        ),
      );
    }

    final latStr = productModels!.data?.latitude;
    final lngStr = productModels!.data?.longitude;

    // Default fallback if parsing fails or null
    final double latitude = double.tryParse(latStr ?? '') ?? 25.0657;
    final double longitude = double.tryParse(lngStr ?? '') ?? 55.2030;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30.0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.red),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFFFFF),
          iconTheme: const IconThemeData(color: Colors.red),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Images
            Container(
              height: screenSize.height * 0.55,
              margin: const EdgeInsets.all(0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                itemCount: productModels?.data?.media?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final imageUrl = productModels!.data!.media![index].originalUrl.toString();

                  return GestureDetector(
                    onTap: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "ImagePreview",
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          PageController controller = PageController(initialPage: index);
                          return Scaffold(
                            backgroundColor: Colors.black,
                            body: SafeArea(
                              child: Stack(
                                children: [
                                  PageView.builder(
                                    controller: controller,
                                    itemCount: productModels?.data?.media?.length ?? 0,
                                    itemBuilder: (context, pageIndex) {
                                      final previewUrl = productModels!.data!.media![pageIndex].originalUrl.toString();
                                      return InteractiveViewer(
                                        child: CachedNetworkImage(
                                          imageUrl: previewUrl,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 20,
                                    right: 20,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // Location + Verified
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Row(
                children: [
                  Text(
                    productModels!.data!.location.toString(),
                    style: const TextStyle(letterSpacing: 0.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Container(
                      width: 90,
                      height: 28,
                      padding: const EdgeInsets.only(top: 2, left: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(8.0),
                        boxShadow: const [
                          BoxShadow(color: Colors.grey, offset: Offset(1.5, 1.5), blurRadius: 0.5, spreadRadius: 0.5),
                          BoxShadow(color: Colors.green, offset: Offset(0.5, 0.5), blurRadius: 0.5, spreadRadius: 0.5),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user, color: Colors.white),
                          SizedBox(width: 4),
                          Text("VERIFIED", style: TextStyle(letterSpacing: 0.5, color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // Price
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Row(
                children: [
                  Text(
                    productModels!.data!.price.toString(),
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const Text("  AED", style: TextStyle(fontSize: 19, letterSpacing: 0.5)),
                  Text("/${productModels!.data!.paymentPeriod}",
                      style: const TextStyle(fontSize: 16, letterSpacing: 0.5)),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // Specs row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Row(
                children: [
                  Image.asset("assets/images/bed.png", height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Text('${productModels!.data!.bedrooms}  beds',
                        style: const TextStyle(fontSize: 14, letterSpacing: 0.5)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Image.asset("assets/images/bath.png", height: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Text('${productModels!.data!.bathrooms}  baths',
                        style: const TextStyle(fontSize: 14, letterSpacing: 0.5)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Image.asset("assets/images/messure.png", height: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Text('${productModels!.data!.squareFeet}  sqft',
                        style: const TextStyle(fontSize: 14, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Title
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      productModels!.data!.title.toString(),
                      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(),
              ],
            ),

            const SizedBox(height: 10),

            // Description (HTML)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: HtmlExpandableText(
                htmlContent: productModels!.data!.description.toString().replaceAll('\r\n', '<br>'),
              ),
            ),

            const SizedBox(height: 10),

            // Posted On
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text("Posted On:",
                      style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
                ),
                Text(productModels!.data!.postedOn.toString())
              ],
            ),

            const SizedBox(height: 15),

            // Property Details
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text("Property Details",
                      style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
                ),
                Text(""),
              ],
            ),

            const SizedBox(height: 15),

            // Property type + specs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset("assets/images/Residential__1.png", height: 17),
                      const SizedBox(width: 6),
                      Text(
                        productModels!.data!.propertyType.toString(),
                        style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
                      ),
                      const Text(""),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset("assets/images/bed.png", height: 17),
                      const SizedBox(width: 6),
                      Text('${productModels!.data!.bedrooms} beds',
                          style: const TextStyle(fontSize: 15, letterSpacing: 0.5)),
                      const SizedBox(width: 12),
                      Image.asset("assets/images/bath.png", height: 17),
                      const SizedBox(width: 6),
                      Text('${productModels!.data!.bathrooms} baths',
                          style: const TextStyle(fontSize: 15, letterSpacing: 0.5)),
                      const SizedBox(width: 12),
                      Image.asset("assets/images/messure.png", height: 17),
                      const SizedBox(width: 6),
                      Text('${productModels!.data!.squareFeet} sqft',
                          style: const TextStyle(fontSize: 15, letterSpacing: 0.5)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // Amenities
            Container(
              height: 30,
              width: 200,
              margin: const EdgeInsets.only(left: 20, right: 200, top: 10, bottom: 0),
              child: const Text("Amnesties",
                  style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),

            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 360;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productModels?.data?.amenities?.length ?? 0,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen ? 1 : 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: isSmallScreen ? 4.5 : 5,
                  ),
                  itemBuilder: (context, index) {
                    final amenity = productModels!.data!.amenities![index];
                    return Row(
                      children: [
                        Image.network(
                          amenity.icon ?? '',
                          width: 18,
                          height: 18,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            amenity.title ?? '',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 15),

            // Project Information
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text("Project Information",
                      style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
                ),
                Text(""),
              ],
            ),
            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Project"),
                      const SizedBox(height: 4),
                      Text(productModels!.data!.project.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      const Text("Delivery Date"),
                      const SizedBox(height: 4),
                      Text(productModels!.data!.deliveryDate.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Second column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Developer"),
                      const SizedBox(height: 4),
                      Text(productModels!.data!.developer.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      const Text("Property Type"),
                      const SizedBox(height: 4),
                      Text(productModels!.data!.propertyType.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Provided by / Agent
            Container(
              height: screenSize.height * 0.17,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150,
                    width: 170,
                    child: Image.asset("assets/images/image3.png", fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: const [
                              BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 1, spreadRadius: 0.3),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Completed",
                            style: TextStyle(letterSpacing: 0.5, color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("MAG Property Development",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            String agentId = productModels!.data!.agentId.toString();
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => AboutAgent(data: agentId)));
                          },
                          child: Container(
                            height: screenSize.height * 0.04,
                            width: screenSize.width * 0.4,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: const [
                                BoxShadow(color: Colors.red, offset: Offset(0.5, 0.5), blurRadius: 0.3, spreadRadius: 0.3),
                              ],
                            ),
                            child: const Text(
                              "View All Project Details",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Location & nearby
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text("Location & nearby",
                      style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
                ),
                Text(""),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              height: screenSize.height * 0.3,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(15.0),
                boxShadow: const [
                  BoxShadow(color: Colors.grey, offset: Offset(0.3, 0.3), blurRadius: 0.3, spreadRadius: 0.3),
                  BoxShadow(color: Colors.white, offset: Offset(0.0, 0.0), blurRadius: 0.0, spreadRadius: 0.0),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(latitude, longitude),
                        zoom: 12,
                      ),
                      zoomControlsEnabled: false,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  productModels!.data!.address.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 28,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MyGoogleMapWidget(
                                            latitude: latitude,
                                            longitude: longitude,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("View on map"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Provided by / Agent card
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text("Provided by",
                      style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
                ),
                Text(""),
              ],
            ),
            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Column(
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    padding: const EdgeInsets.only(top: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(60.0),
                      boxShadow: const [
                        BoxShadow(color: Colors.grey, offset: Offset(0.0, 0.0), blurRadius: 0.1, spreadRadius: 0.1),
                        BoxShadow(color: Colors.white, offset: Offset(0.0, 0.0), blurRadius: 0.0, spreadRadius: 0.0),
                      ],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: productModels!.data!.agentImage?.isNotEmpty == true
                          ? productModels!.data!.agentImage!
                          : 'https://via.placeholder.com/100',
                      fit: BoxFit.cover,
                      height: 100,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      productModels!.data!.agent.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                  Row(
                    children: const [
                      Padding(padding: EdgeInsets.only(top: 5, left: 80)),
                      Padding(
                        padding: EdgeInsets.only(top: 5, left: 5),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Color(0xFFFBC02D)),
                            Icon(Icons.star, color: Color(0xFFFBC02D)),
                            Icon(Icons.star, color: Color(0xFFFBC02D)),
                            Icon(Icons.star, color: Color(0xFFFBC02D)),
                            Icon(Icons.star, color: Color(0xFFFBC02D)),
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 5, left: 5), child: Text("ratings")),
                    ],
                  ),
                  Row(
                    children: const [
                      Padding(padding: EdgeInsets.only(top: 5, left: 50), child: Text("Response time")),
                      Padding(padding: EdgeInsets.only(top: 5, left: 50), child: Text("within 5 minutes")),
                    ],
                  ),
                  Row(
                    children: const [
                      Padding(padding: EdgeInsets.only(top: 5, left: 50), child: Text("Closed Deals")),
                      Padding(padding: EdgeInsets.only(top: 5, left: 63), child: Text("17")),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      String agentId = productModels!.data!.agentId.toString();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutAgent(data: agentId)),
                      );
                    },
                    child: Container(
                      height: 35,
                      width: screenSize.width * 0.5,
                      margin: const EdgeInsets.only(left: 15, right: 10, top: 15),
                      padding: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(8.0),
                        boxShadow: const [
                          BoxShadow(color: Colors.red, offset: Offset(0.5, 0.5), blurRadius: 0.5, spreadRadius: 0.3),
                          BoxShadow(color: Colors.white, offset: Offset(0.0, 0.0), blurRadius: 0.0, spreadRadius: 0.0),
                        ],
                      ),
                      child: const Text(
                        "See Agents Properties",
                        textAlign: TextAlign.center,
                        style: TextStyle(letterSpacing: 0.5, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // Regulatory Information (with live QR preferred)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 18, right: 14, top: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(color: Colors.grey, offset: Offset(0.5, 0.5), blurRadius: 0.5, spreadRadius: 0.3),
                  BoxShadow(color: Colors.white, offset: Offset(0.0, 0.0), blurRadius: 0.0, spreadRadius: 0.0),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Regulatory Information",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 10),

                  _buildInfoRow("DLD Permit Number:",
                      productModels!.data!.regulatoryInfo!.dldPermitNumber.toString()),
                  _buildInfoRow("DED", productModels!.data!.regulatoryInfo!.ded.toString()),
                  _buildInfoRow("RERA", productModels!.data!.regulatoryInfo!.rera.toString()),
                  _buildInfoRow("BRN", productModels!.data!.regulatoryInfo!.brn.toString()),

                  const SizedBox(height: 5),

                  Center(
                    child: Column(
                      children: [
                        Builder(
                          builder: (context) {
                            // Prefer validate-listing result
                            final liveImg = _qrImageUrl;
                            final liveLink = _qrLink;

                            if ((liveImg != null && liveImg.isNotEmpty) ||
                                (liveLink != null && liveLink.isNotEmpty)) {
                              return GestureDetector(
                                onTap: () async {
                                  if (liveLink != null && liveLink.isNotEmpty) {
                                    final Uri url = Uri.parse(liveLink);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Could not launch the QR link')),
                                      );
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: liveImg ?? '',
                                    height: 120,
                                    fit: BoxFit.contain,
                                    errorWidget: (_, __, ___) => const Icon(Icons.qr_code_2, size: 72),
                                  ),
                                ),
                              );
                            }

                            // Fallback to property payload QR list
                            final qrList = productModels?.data?.qr ?? [];
                            if (qrList.isNotEmpty) {
                              final qrItem = qrList.first;
                              final imageUrl = qrItem.qrUrl;
                              final qrLink = productModels?.data?.qrLink;

                              return GestureDetector(
                                onTap: () async {
                                  if (qrLink != null && qrLink.isNotEmpty) {
                                    final Uri url = Uri.parse(qrLink);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Could not launch the QR link')),
                                      );
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl ?? '',
                                    height: 120,
                                    fit: BoxFit.contain,
                                    errorWidget: (_, __, ___) => const Icon(Icons.qr_code_2, size: 72),
                                  ),
                                ),
                              );
                            }

                            if (_isValidating) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: SizedBox(
                                  height: 120,
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 6),
                        const Text("DLD Permit Number", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // Recommended Properties
            Container(
              height: 30,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
              child: const Text("Recommended Properties",
                  style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productModels?.data?.recommendedProperties?.length ?? 0,
                itemBuilder: (context, index) {
                  final property = productModels!.data!.recommendedProperties![index];
                  final imageUrl = (property.media?.isNotEmpty ?? false)
                      ? property.media!.first.originalUrl.toString()
                      : "";

                  return Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      child: GestureDetector(
                        onTap: () {
                          String id = property.id.toString();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Agency_Detail(data: id)),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover)
                                  : Container(
                                height: 120,
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                child: const Center(child: Icon(Icons.image_not_supported)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${property.price} AED",
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.bed, size: 16, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text("${property.bedrooms} beds"),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.square_foot, size: 16, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text("${property.squareFeet} sqft"),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    property.location ?? "",
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text("$title:", style: const TextStyle(fontSize: 13, letterSpacing: 0.5)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Home())),
              child: Image.asset("assets/images/home.png", height: 25)),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                if (token == '') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const My_Account()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const My_Account()));
                }
              });
            },
            icon: pageIndex == 3
                ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                : const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
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
      BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 2, spreadRadius: 0.1, offset: const Offset(0, 1)),
      const BoxShadow(color: Colors.white, offset: Offset(0.0, 0.0), blurRadius: 0.0, spreadRadius: 0.0),
    ],
  );
}
