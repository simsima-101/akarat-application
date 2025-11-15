import 'dart:async';
import 'dart:convert';

import 'package:Akarat/model/fdetailmodel.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/full_map_screen.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../services/api_service.dart';
import '../utils/shared_preference_manager.dart';
import 'about_agent.dart';
import 'filter_list.dart';
import 'htmlEpandableText.dart';

class Featured_Detail extends StatefulWidget {
  const Featured_Detail({super.key, required this.data});
  final String data;

  @override
  State<Featured_Detail> createState() => _Featured_DetailState();
}

class _Featured_DetailState extends State<Featured_Detail> {
  String phoneCallNumber(String rawNumber) {
    return rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  String safeSubstring(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength);
  }

  Featured_DetailModel? featuredDetailModel;
  int pageIndex = 0;

  String whatsAppNumber(String rawNumber) {
    return rawNumber.replaceAll(RegExp(r'\D'), '');
  }

  // ===== permit_response parsed data =====
  Map<String, dynamic>? _permitJson;
  Map<String, dynamic>? _permitResult;
  Map<String, dynamic>? _permitProperty;

  String? _cleanStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  /// Parse regulatory_info.permit_response (map or string)
  void _parsePermitResponse() {
    try {
      final reg = featuredDetailModel?.data?.property?.regulatoryInfo;
      if (reg == null) return;

      final raw = reg.permitResponse;
      if (raw == null) return;

      dynamic decoded;
      if (raw is String) {
        final cleaned = _cleanStr(raw);
        if (cleaned == null) return;
        decoded = jsonDecode(cleaned);
      } else if (raw is Map<String, dynamic>) {
        decoded = raw;
      } else {
        return;
      }

      _permitJson = decoded as Map<String, dynamic>;
      final result = decoded['result'];

      if (result is List && result.isNotEmpty) {
        final first = result.first;
        if (first is Map<String, dynamic>) {
          _permitResult = first;
          final prop = first['property'];
          if (prop is Map<String, dynamic>) {
            _permitProperty = prop;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ permit_response parse error: $e');
    }
  }

  // ===== Field-level getters (permit_response FIRST, then outer, else null) =====

  String? get _displayProject {
    final fromPermit = _cleanStr(_permitResult?['project']);
    if (fromPermit != null) return fromPermit;

    return _cleanStr(featuredDetailModel?.data?.property?.project);
  }

  String? get _displayDeveloper {
    final fromPermit = _cleanStr(_permitResult?['authorityNameEn']);
    if (fromPermit != null) return fromPermit;

    return _cleanStr(featuredDetailModel?.data?.property?.developer);
  }

  String? get _displayPropertyType {
    final fromPermit = _cleanStr(_permitProperty?['propertyTypeNameEn']);
    if (fromPermit != null) return fromPermit;

    return _cleanStr(featuredDetailModel?.data?.property?.propertyType);
  }

  String? get _displayDeliveryDate {
    final fromPermit = _cleanStr(_permitResult?['endDate']);
    if (fromPermit != null) return fromPermit;

    return _cleanStr(featuredDetailModel?.data?.property?.deliveryDate);
  }

  String? get _displayZoneName {
    final fromPermit = _cleanStr(_permitProperty?['zoneNameEn']);
    if (fromPermit != null) return fromPermit;

    return _cleanStr(featuredDetailModel?.data?.property?.zoneName);
  }

  String? get _displayReference {
    final fromPermit = _cleanStr(_permitResult?['listingNumber']);
    if (fromPermit != null) return fromPermit;

    return _cleanStr(featuredDetailModel?.data?.property?.reference);
  }

  List<Widget> _buildProjectInfoRows() {
    final List<Widget> rows = [];

    void addRow(String label, String? value) {
      final v = _cleanStr(value);
      if (v == null) return;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  '$label:',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  v,
                  style: const TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    addRow('Project', _displayProject);
    addRow('Developer', _displayDeveloper);
    addRow('Property Type', _displayPropertyType);
    addRow('Delivery Date', _displayDeliveryDate);
    addRow('Zone', _displayZoneName);
    addRow('Reference', _displayReference);

    return rows;
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

  bool isDataRead = false;
  String token = '';
  String email = '';
  String result = '';
  SharedPreferencesManager prefManager = SharedPreferencesManager();

  void readData() async {
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
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    readData();
    fetchProducts(widget.data);
  }

  Future<void> fetchProducts(String data) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedKey = 'cached_property_$data';
    final cachedTimeKey = 'cached_time_$data';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cachedTimeKey) ?? 0;

    // Step 1: Use cache immediately if available
    final cached = prefs.getString(cachedKey);
    if (cached != null) {
      final cachedJson = jsonDecode(cached);
      final model = Featured_DetailModel.fromJson(cachedJson);
      setState(() => featuredDetailModel = model);

      _parsePermitResponse();
    }

    // Step 2: if cache still fresh (6 hours), stop here
    if (now - lastFetched < Duration(hours: 6).inMilliseconds &&
        cached != null) {
      debugPrint('✅ Loaded from cache (fresh)');
      return;
    }

    // Step 3: Fetch from API (new endpoint)
    final url = ApiService.buildUri('properties/$data');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final parsedModel = Featured_DetailModel.fromJson(jsonData);

        prefs.setString(cachedKey, response.body);
        prefs.setInt(cachedTimeKey, now);

        if (!mounted) return;
        setState(() => featuredDetailModel = parsedModel);

        _parsePermitResponse();
      } else {
        debugPrint('❌ API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🚨 Unexpected error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);

    if (featuredDetailModel == null) {
      return Scaffold(
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerCard(),
        ),
      );
    }

    final property = featuredDetailModel!.data!.property!;
    final latStr = property.latitude;
    final lngStr = property.longitude;
    final double latitude = double.tryParse(latStr ?? '') ?? 25.0657;
    final double longitude = double.tryParse(lngStr ?? '') ?? 55.2030;

    final projectInfoRows = _buildProjectInfoRows();

    // ===== NEW: build QR widget from base64 (permit_info.qr) =====
    Widget qrWidget = const SizedBox.shrink();
    try {
      final permitInfo = property.permitInfo;
      final qrStr = permitInfo?.qr;
      final url = permitInfo?.url;

      if (qrStr != null && qrStr.trim().isNotEmpty) {
        // Safe for both raw base64 and data:image/...;base64,xxxx
        final String base64Part =
        qrStr.contains(',') ? qrStr.split(',').last.trim() : qrStr.trim();

        final bytes = base64Decode(base64Part);

        qrWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'RERA QR Code',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                if (url == null ||
                    url.trim().isEmpty ||
                    url.toLowerCase() == 'null') {
                  return; // just show QR, no link
                }
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not launch the QR link'),
                    ),
                  );
                }
              },
              child: Image.memory(
                bytes,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ],
        );
      }
    } catch (e) {
      debugPrint('⚠️ QR decode error: $e');
      qrWidget = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30.0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.red),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFFFFF),
          iconTheme: const IconThemeData(color: Colors.red),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // ==== IMAGES ====
            Container(
              height: screenSize.height * 0.55,
              margin: const EdgeInsets.all(0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                itemCount: property.media?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final imageUrl = property.media![index].originalUrl.toString();

                  return GestureDetector(
                    onTap: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "ImagePreview",
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder:
                            (context, animation, secondaryAnimation) {
                          PageController controller =
                          PageController(initialPage: index);
                          return Scaffold(
                            backgroundColor: Colors.black,
                            body: SafeArea(
                              child: Stack(
                                children: [
                                  PageView.builder(
                                    controller: controller,
                                    itemCount: property.media?.length ?? 0,
                                    itemBuilder: (context, pageIndex) {
                                      final previewUrl = property
                                          .media![pageIndex].originalUrl
                                          .toString();
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
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
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

            // ==== LOCATION + VERIFIED ====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Row(
                children: [
                  Text(
                    property.location.toString(),
                    style: const TextStyle(letterSpacing: 0.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 0.0),
                    child: Container(
                      width: 90,
                      height: 28,
                      padding:
                      const EdgeInsets.only(top: 2, left: 5, right: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.5, 1.5),
                            blurRadius: 0.5,
                            spreadRadius: 0.5,
                          ),
                          BoxShadow(
                            color: Colors.green,
                            offset: Offset(0.5, 0.5),
                            blurRadius: 0.5,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 0),
                            child: Icon(
                              Icons.verified_user,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 1),
                            child: Text(
                              "VERIFIED",
                              style: TextStyle(
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                  fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ==== PRICE ====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Row(
                children: [
                  Text(
                    property.price.toString(),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    "  AED",
                    style: TextStyle(fontSize: 19, letterSpacing: 0.5),
                  ),
                  Text(
                    "/${property.paymentPeriod}",
                    style:
                    const TextStyle(fontSize: 16, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ==== BEDS / BATHS / AREA ====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Row(
                children: [
                  Image.asset("assets/images/bed.png", height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Text(
                      '${property.bedrooms}  beds',
                      style: const TextStyle(
                          fontSize: 14, letterSpacing: 0.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Image.asset("assets/images/bath.png", height: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Text(
                      '${property.bathrooms}  baths',
                      style: const TextStyle(
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child:
                    Image.asset("assets/images/messure.png", height: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Text(
                      '${property.squareFeet}  sqft',
                      style: const TextStyle(
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ==== TITLE ====
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      property.title ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ==== DESCRIPTION ====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: HtmlExpandableText(
                htmlContent: safeSubstring(
                  (property.description ?? '').replaceAll('\r\n', '<br>'),
                  200,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ==== POSTED ON ====
            Row(
              children: [
                const Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text(
                    "Posted On:",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  property.postedOn.toString(),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ==== PROPERTY DETAILS ====
            const Row(
              children: [
                Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text(
                    "Property Details",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                // removed invalid `spacing` parameter
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/Residential-test.png",
                        height: 17,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        property.propertyType.toString(),
                        style: const TextStyle(
                            fontSize: 15, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset("assets/images/bed.png", height: 17),
                      const SizedBox(width: 6),
                      Text(
                        '${property.bedrooms} beds',
                        style: const TextStyle(
                            fontSize: 15, letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 12),
                      Image.asset("assets/images/bath.png", height: 17),
                      const SizedBox(width: 6),
                      Text(
                        '${property.bathrooms} baths',
                        style: const TextStyle(
                            fontSize: 15, letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 12),
                      Image.asset("assets/images/messure.png", height: 17),
                      const SizedBox(width: 6),
                      Text(
                        '${property.squareFeet} sqft',
                        style: const TextStyle(
                            fontSize: 15, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ==== AMENITIES ====
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Amenities",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 360;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: property.amenities?.length ?? 0,
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen ? 1 : 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: isSmallScreen ? 4.5 : 5,
                  ),
                  itemBuilder: (context, index) {
                    final amenity = property.amenities![index];
                    return Row(
                      children: [
                        Image.network(
                          amenity.icon ?? '',
                          width: 18,
                          height: 18,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                            Icons.broken_image,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            amenity.title ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
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

            // ==== PROJECT INFORMATION ====
            if (projectInfoRows.isNotEmpty) ...[
              const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 0, horizontal: 15),
                    child: Text(
                      "Project Information",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: projectInfoRows,
                ),
              ),
            ],

            const SizedBox(height: 5),

            // ==== STATIC DEMO CARD ====
            Container(
              height: screenSize.height * 0.17,
              margin: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150,
                    width: 170,
                    child: Image.asset(
                      "assets/images/image3.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(1, 1),
                                blurRadius: 1,
                                spreadRadius: 0.3,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Completed",
                            style: TextStyle(
                              letterSpacing: 0.5,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "MAG Property Development",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            String agentId =
                            property.agentId.toString();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AboutAgent(data: agentId),
                              ),
                            );
                          },
                          child: Container(
                            height: screenSize.height * 0.04,
                            width: screenSize.width * 0.4,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(8.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.red,
                                  offset: Offset(0.5, 0.5),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                              ],
                            ),
                            child: const Text(
                              "View All Project Details",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
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

            // ==== LOCATION & NEARBY ====
            const Row(
              children: [
                Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text(
                    "Location & nearby",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              height: screenSize.height * 0.3,
              margin: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(15.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.3, 0.3),
                    blurRadius: 0.3,
                    spreadRadius: 0.3,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  property.address?.toString() ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 28,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      textStyle:
                                      const TextStyle(fontSize: 12),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MyGoogleMapWidget(
                                                latitude: latitude,
                                                longitude: longitude,
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "View on map",
                                    ),
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

            // ==== PROVIDED BY ====
            const Row(
              children: [
                Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text(
                    "Provided by",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Column(
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadiusDirectional.circular(60.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 0.1,
                          spreadRadius: 0.1,
                        ),
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: CachedNetworkImage(
                      imageUrl:
                      (property.agentImage?.isNotEmpty ?? false)
                          ? property.agentImage!
                          : 'https://via.placeholder.com/100',
                      fit: BoxFit.cover,
                      height: 100,
                      placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                      const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      property.agent.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding:
                        EdgeInsets.only(top: 5, left: 80),
                        child: SizedBox(),
                      ),
                      Padding(
                        padding:
                        EdgeInsets.only(top: 5, left: 5),
                        child: Row(
                          children: [
                            Icon(Icons.star,
                                color: Color(0xFFFBC02D)),
                            Icon(Icons.star,
                                color: Color(0xFFFBC02D)),
                            Icon(Icons.star,
                                color: Color(0xFFFBC02D)),
                            Icon(Icons.star,
                                color: Color(0xFFFBC02D)),
                            Icon(Icons.star,
                                color: Color(0xFFFBC02D)),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                        EdgeInsets.only(top: 5, left: 5),
                        child: Text("ratings"),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding:
                        EdgeInsets.only(top: 5, left: 50),
                        child: Text("Response time"),
                      ),
                      Padding(
                        padding:
                        EdgeInsets.only(top: 5, left: 50),
                        child: Text("within 5 minutes"),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding:
                        EdgeInsets.only(top: 5, left: 50),
                        child: Text("Closed Deals"),
                      ),
                      Padding(
                        padding:
                        EdgeInsets.only(top: 5, left: 63),
                        child: Text("17"),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      String agentId = property.agentId.toString();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AboutAgent(data: agentId),
                        ),
                      );
                    },
                    child: Container(
                      height: 35,
                      width: screenSize.width * 0.5,
                      margin: const EdgeInsets.only(
                          left: 15, right: 10, top: 15),
                      padding: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadiusDirectional.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.red,
                            offset: Offset(0.5, 0.5),
                            blurRadius: 0.5,
                            spreadRadius: 0.3,
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: const Text(
                        "See Agents Properties",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 0.5,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ===== Regulatory Info + QR =====
            Container(
              width: double.infinity,
              margin:
              const EdgeInsets.only(left: 18, right: 14, top: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.5, 0.5),
                    blurRadius: 0.5,
                    spreadRadius: 0.3,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Regulatory Information",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    "DLD Permit Number",
                    property.regulatoryInfo?.dldPermitNumber
                        ?.toString() ??
                        '',
                  ),
                  _buildInfoRow(
                    "DED",
                    property.regulatoryInfo?.ded?.toString() ?? '',
                  ),
                  _buildInfoRow(
                    "RERA",
                    property.regulatoryInfo?.rera?.toString() ?? '',
                  ),
                  _buildInfoRow(
                    "BRN",
                    property.regulatoryInfo?.brn?.toString() ?? '',
                  ),
                  const SizedBox(height: 5),
                  Center(child: qrWidget),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ===== Recommended Properties =====
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                featuredDetailModel?.data?.recommended?.length ?? 0,
                itemBuilder: (context, index) {
                  final recProperty =
                  featuredDetailModel!.data!.recommended![index];

                  final imageUrl =
                  (recProperty.media?.isNotEmpty ?? false)
                      ? recProperty.media!.first.originalUrl
                      .toString()
                      : '';

                  return Container(
                    width: 210,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: GestureDetector(
                        onTap: () {
                          final id = recProperty.id.toString();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Featured_Detail(data: id),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  const BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                    imageUrl,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    height: 120,
                                    width: double.infinity,
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(
                                        Icons
                                            .image_not_supported,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${recProperty.price} AED",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.bed,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                          "${recProperty.bedrooms ?? 0} beds"),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.square_foot,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                          "${recProperty.squareFeet ?? ''} sqft"),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recProperty.location ?? "",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
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
            child: Text(
              "$title:",
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: ImageIcon(
                AssetImage("assets/images/home.png"),
                size: 25,
                color: Colors.red,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 18),
            height: 35,
            width: 35,
            padding: const EdgeInsets.only(top: 2),
            decoration: _iconBoxDecoration(),
            child: GestureDetector(
              onTap: () async {
                final phone = phoneCallNumber(
                  featuredDetailModel?.data?.property?.phoneNumber ?? '',
                );

                if (phone.isNotEmpty) {
                  final telUrl = 'tel:$phone';
                  if (await canLaunchUrlString(telUrl)) {
                    await launchUrlString(
                      telUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                }
              },
              child: const Icon(
                Icons.call_outlined,
                color: Colors.red,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 1),
            height: 35,
            width: 35,
            padding: const EdgeInsets.only(top: 2),
            decoration: _iconBoxDecoration(),
            child: GestureDetector(
              onTap: () async {
                final phoneRaw =
                    featuredDetailModel?.data?.property?.whatsapp ?? '';
                final phone = whatsAppNumber(phoneRaw);

                final message = Uri.encodeComponent("Hello");
                final waUrl =
                Uri.parse("https://wa.me/$phone?text=$message");

                if (await canLaunchUrl(waUrl)) {
                  try {
                    final launched = await launchUrl(
                      waUrl,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!launched) {
                      debugPrint("❌ Could not launch WhatsApp");
                    }
                  } catch (e) {
                    debugPrint("❌ Exception: $e");
                  }
                } else {
                  debugPrint(
                      "❌ WhatsApp not available or URL not supported");
                }
              },
              child: Image.asset(
                "assets/images/whats.png",
                height: 20,
              ),
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => My_Account(),
                ),
              );
            },
            icon: pageIndex == 3
                ? const Icon(
              Icons.dehaze,
              color: Colors.red,
              size: 35,
            )
                : const Icon(
              Icons.dehaze_outlined,
              color: Colors.red,
              size: 35,
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
