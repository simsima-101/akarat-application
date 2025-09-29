// lib/screen/new_project_detail.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ⬇️ Your existing widgets/utilities (same as Product_Detail)
import 'package:Akarat/screen/shimmer.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/full_map_screen.dart';
import 'package:Akarat/screen/about_agent.dart';
import 'package:Akarat/utils/whatsapp_button.dart';
import 'htmlEpandableText.dart';

class NewProjectDetail extends StatefulWidget {
  final String id;
  const NewProjectDetail({super.key, required this.id});

  @override
  State<NewProjectDetail> createState() => _NewProjectDetailState();
}

class _NewProjectDetailState extends State<NewProjectDetail> {
  Map<String, dynamic>? payload; // raw json
  bool loading = true;
  String? error;

  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;

  int pageIndex = 0;

  // ========= Phone helpers (match your Product_Detail behavior) =========
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

  // =================== Lifecycle ===================
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    _fetchDetail(widget.id);
  }

  // =================== Networking with cache ===================
  Future<void> _fetchDetail(String id) async {
    setState(() {
      loading = true;
      error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'newproj_$id';
    final cacheTimeKey = 'newproj_time_$id';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // Try fresh cache first (<= 6 hours)
    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        try {
          payload = jsonDecode(cached) as Map<String, dynamic>;
          setState(() => loading = false);
          // still refresh in background? (skip to match Product_Detail behavior)
          return;
        } catch (_) {}
      }
    }

    // Fetch from API
    final url = Uri.parse('https://akarat.com/api/new-projects/$id');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
        payload = jsonMap;

        // cache
        await prefs.setString(cacheKey, jsonEncode(jsonMap));
        await prefs.setInt(cacheTimeKey, now);

        if (!mounted) return;
        setState(() => loading = false);
      } else {
        setState(() {
          error = 'Server error: ${res.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error: $e';
        loading = false;
      });
    }
  }

  // =================== JSON helpers (defensive) ===================
  Map<String, dynamic>? get _data {
    final d = payload?['data'];
    return (d is Map<String, dynamic>) ? d : null;
  }

  Map<String, dynamic>? get _prop {
    // API may put fields directly under data OR under data.property
    final d = _data;
    if (d == null) return null;
    if (d['property'] is Map<String, dynamic>) return d['property'];
    return d;
  }

  List<dynamic> get _media {
    final p = _prop;
    if (p == null) return const [];
    final m = p['media'];
    return (m is List) ? m : const [];
  }

  List<dynamic> get _amenities {
    final p = _prop;
    if (p == null) return const [];
    final a = p['amenities'];
    return (a is List) ? a : const [];
  }

  Map<String, dynamic>? get _reg {
    final p = _prop;
    if (p == null) return null;
    final r = p['regulatory_info'] ?? p['regulatoryInfo'];
    return (r is Map<String, dynamic>) ? r : null;
  }

  List<dynamic> get _qrList {
    final p = _prop;
    if (p == null) return const [];
    final q = p['qr'];
    return (q is List) ? q : const [];
  }

  // recommended projects: try a few likely keys
  List<dynamic> get _recommended {
    final p = _prop;
    if (p == null) return const [];
    final r = p['recommended'] ?? p['recommended_projects'] ?? p['recommendedProperties'];
    return (r is List) ? r : const [];
  }

  String? get _qrLink {
    final p = _prop;
    final l = p?['qr_link'] ?? p?['qrLink'];
    return (l is String && l.isNotEmpty) ? l : null;
  }

  String _s(dynamic v) => v == null ? '' : v.toString();

  // coordinates
  double get _lat {
    final s = _s(_prop?['latitude']);
    final v = double.tryParse(s);
    return v ?? 25.0657; // Dubai fallback
  }
  double get _lng {
    final s = _s(_prop?['longitude']);
    final v = double.tryParse(s);
    return v ?? 55.2030;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    if (loading) {
      return Scaffold(
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (_, __) => const ShimmerCard(),
        ),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Detail')),
        body: Center(child: Text(error!)),
      );
    }
    if (_prop == null) {
      return const Scaffold(
        body: Center(child: Text('No data')),
      );
    }

    // Extract common fields (mirror Product_Detail names as much as possible)
    final title         = _s(_prop?['title']);
    final price         = _s(_prop?['price']);
    final paymentPeriod = _s(_prop?['payment_period'] ?? _prop?['paymentPeriod']);
    final location      = _s(_prop?['location']);
    final bedrooms      = _s(_prop?['bedrooms']);
    final bathrooms     = _s(_prop?['bathrooms']);
    final sqft          = _s(_prop?['square_feet'] ?? _prop?['squareFeet']);
    final postedOn      = _s(_prop?['posted_on']   ?? _prop?['postedOn']);
    final description   = _s(_prop?['description']);
    final propertyType  = _s(_prop?['property_type'] ?? _prop?['propertyType']);
    final projectName   = _s(_prop?['project']);
    final deliveryDate  = _s(_prop?['delivery_date'] ?? _prop?['deliveryDate']);
    final developer     = _s(_prop?['developer']);
    final address       = _s(_prop?['address']);
    final phoneNumber   = _s(_prop?['phone_number'] ?? _prop?['phoneNumber']);
    final whatsapp      = _s(_prop?['whatsapp']);
    final agent         = _s(_prop?['agent']);
    final agentId       = _s(_prop?['agent_id'] ?? _prop?['agentId']);
    final agentImage    = _s(_prop?['agent_image'] ?? _prop?['agentImage']);
    final closedDeals   = _s(_prop?['closed_deals'] ?? _prop?['closedDeals']);

    final dld = _s(_reg?['dld_permit_number'] ?? _reg?['dldPermitNumber']);
    final ded = _s(_reg?['ded']);
    final rera = _s(_reg?['rera']);
    final brn = _s(_reg?['brn']);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(child: _buildBottomBar(context, phoneNumber, whatsapp)),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30),
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
          children: [
            // ====== Media gallery (like your Product_Detail) ======
            Container(
              height: screenSize.height * 0.55,
              margin: EdgeInsets.zero,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                itemCount: _media.length,
                itemBuilder: (context, index) {
                  final imageUrl = _s(_media[index]['original_url'] ?? _media[index]['originalUrl']);
                  if (imageUrl.isEmpty) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "ImagePreview",
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          final controller = PageController(initialPage: index);
                          return Scaffold(
                            backgroundColor: Colors.black,
                            body: SafeArea(
                              child: Stack(
                                children: [
                                  PageView.builder(
                                    controller: controller,
                                    itemCount: _media.length,
                                    itemBuilder: (context, pageIndex) {
                                      final preview = _s(_media[pageIndex]['original_url'] ?? _media[pageIndex]['originalUrl']);
                                      return InteractiveViewer(
                                        child: CachedNetworkImage(imageUrl: preview, fit: BoxFit.contain),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 20, right: 20,
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
                      child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // ====== Header row (location + VERIFIED badge) ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(location, style: const TextStyle(letterSpacing: 0.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    width: 90, height: 28,
                    padding: const EdgeInsets.only(top: 2, left: 5, right: 0),
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
                        SizedBox(width: 2),
                        Text("VERIFIED", style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ====== Price row ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Text(price, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const Text("  AED", style: TextStyle(fontSize: 19, letterSpacing: 0.5)),
                  Text(paymentPeriod.isNotEmpty ? "/$paymentPeriod" : "", style: const TextStyle(fontSize: 16, letterSpacing: 0.5)),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ====== Beds / Baths / Sqft ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Image.asset("assets/images/bed.png", height: 20),
                  const SizedBox(width: 3),
                  Text('$bedrooms  beds', style: const TextStyle(fontSize: 14, letterSpacing: 0.5)),
                  const SizedBox(width: 15),
                  Image.asset("assets/images/bath.png", height: 20),
                  const SizedBox(width: 3),
                  Text('$bathrooms  baths', style: const TextStyle(fontSize: 14, letterSpacing: 0.5)),
                  const SizedBox(width: 15),
                  Image.asset("assets/images/messure.png", height: 20),
                  const SizedBox(width: 3),
                  Text('$sqft  sqft', style: const TextStyle(fontSize: 14, letterSpacing: 0.5)),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ====== Title ======
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      overflow: TextOverflow.ellipsis, maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // ====== HTML Expandable Description ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: HtmlExpandableText(
                htmlContent: description.replaceAll('\r\n', '<br>'),
              ),
            ),

            const SizedBox(height: 10),

            // ====== Posted on ======
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text("Posted On:", style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
                ),
                Text(postedOn),
              ],
            ),

            const SizedBox(height: 15),

            // ====== Property Details ======
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text("Property Details", style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
                ),
                Text(""),
              ],
            ),
            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset("assets/images/Residential__1.png", height: 17),
                      const SizedBox(width: 6),
                      Text(propertyType, style: const TextStyle(fontSize: 15, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset("assets/images/bed.png", height: 17),
                      const SizedBox(width: 6),
                      Text('$bedrooms beds', style: const TextStyle(fontSize: 15, letterSpacing: 0.5)),
                      const SizedBox(width: 12),
                      Image.asset("assets/images/bath.png", height: 17),
                      const SizedBox(width: 6),
                      Text('$bathrooms baths', style: const TextStyle(fontSize: 15, letterSpacing: 0.5)),
                      const SizedBox(width: 12),
                      Image.asset("assets/images/messure.png", height: 17),
                      const SizedBox(width: 6),
                      Text('$sqft sqft', style: const TextStyle(fontSize: 15, letterSpacing: 0.5)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ====== Amenities ======
            Container(
              height: 30, width: 200,
              margin: const EdgeInsets.only(left: 20, right: 200, top: 10, bottom: 0),
              child: const Text("Amenities", style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),

            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 360;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _amenities.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmall ? 1 : 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: isSmall ? 4.5 : 5,
                  ),
                  itemBuilder: (_, i) {
                    final a = _amenities[i] as Map<String, dynamic>? ?? {};
                    final icon = _s(a['icon']);
                    final title = _s(a['title']);
                    return Row(
                      children: [
                        if (icon.isNotEmpty)
                          Image.network(icon, width: 18, height: 18,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 18),
                          )
                        else const Icon(Icons.broken_image, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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

            // ====== Project Information ======
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text("Project Information", style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
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
                  // column 1
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Project"),
                      const SizedBox(height: 4),
                      Text(projectName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      const Text("Delivery Date"),
                      const SizedBox(height: 4),
                      Text(deliveryDate, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // column 2
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Developer"),
                      const SizedBox(height: 4),
                      Text(developer, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      const Text("Property Type"),
                      const SizedBox(height: 4),
                      Text(propertyType, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ====== Developer card + "View All Project Details" ======
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150, width: 170,
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
                            boxShadow: const [BoxShadow(color: Colors.grey, offset: Offset(1,1), blurRadius: 1, spreadRadius: 0.3)],
                          ),
                          alignment: Alignment.center,
                          child: const Text("Completed", style: TextStyle(letterSpacing: 0.5, color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(height: 8),
                        Text(developer, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            final id = agentId.isEmpty ? '0' : agentId;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AboutAgent(data: id)));
                          },
                          child: Container(
                            height: screenSize.height * 0.04,
                            width: screenSize.width * 0.4,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: const [BoxShadow(color: Colors.red, offset: Offset(0.5,0.5), blurRadius: 0.3, spreadRadius: 0.3)],
                            ),
                            child: const Text("View All Project Details", textAlign: TextAlign.center,
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

            // ====== Map card ======
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text("Location & nearby", style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
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
                  BoxShadow(color: Colors.white, offset: Offset(0,0), blurRadius: 0, spreadRadius: 0),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(target: LatLng(_lat, _lng), zoom: 12),
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
                                Text(address, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 28,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12), textStyle: const TextStyle(fontSize: 12)),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => MyGoogleMapWidget(latitude: _lat, longitude: _lng),
                                      ));
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

            // ====== Provided by (Agent) ======
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text("Provided by", style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
                ),
                Text(""),
              ],
            ),
            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Container(
                    height: 110, width: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(60.0),
                      boxShadow: const [
                        BoxShadow(color: Colors.grey, offset: Offset(0,0), blurRadius: 0.1, spreadRadius: 0.1),
                        BoxShadow(color: Colors.white, offset: Offset(0,0), blurRadius: 0, spreadRadius: 0),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: (agentImage.isNotEmpty)
                          ? CachedNetworkImage(imageUrl: agentImage, fit: BoxFit.cover)
                          : const ColoredBox(color: Colors.black12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(agent, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  Row(
                    children: const [
                      SizedBox(width: 80),
                      Icon(Icons.star, color: Color(0xFFFBC02D)),
                      Icon(Icons.star, color: Color(0xFFFBC02D)),
                      Icon(Icons.star, color: Color(0xFFFBC02D)),
                      Icon(Icons.star, color: Color(0xFFFBC02D)),
                      Icon(Icons.star, color: Color(0xFFFBC02D)),
                      SizedBox(width: 5),
                      Text("ratings"),
                    ],
                  ),
                  Row(
                    children: const [
                      SizedBox(width: 50),
                      Text("Response time"),
                      SizedBox(width: 50),
                      Text("within 5 minutes"),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 50),
                      const Text("Closed Deals"),
                      const SizedBox(width: 63),
                      Text(closedDeals),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      final id = agentId.isEmpty ? '0' : agentId;
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AboutAgent(data: id)));
                    },
                    child: Container(
                      height: 35,
                      width: screenSize.width * 0.5,
                      margin: const EdgeInsets.only(left: 15, right: 10, top: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadiusDirectional.circular(8.0),
                        boxShadow: const [BoxShadow(color: Colors.red, offset: Offset(0.5,0.5), blurRadius: 0.5, spreadRadius: 0.3)],
                      ),
                      child: const Text("See Agents Properties",
                        style: TextStyle(letterSpacing: 0.5, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ====== Regulatory Information ======
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 18, right: 14, top: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(color: Colors.grey, offset: Offset(0.5,0.5), blurRadius: 0.5, spreadRadius: 0.3),
                  BoxShadow(color: Colors.white, offset: Offset(0,0), blurRadius: 0, spreadRadius: 0),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Regulatory Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  _infoRow("DLD Permit Number:", dld),
                  _infoRow("DED", ded),
                  _infoRow("RERA", rera),
                  _infoRow("BRN", brn),
                  const SizedBox(height: 5),
                  // QR list (tap opens qrLink)
                  Center(
                    child: Column(
                      children: [
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: _qrList.length,
                          itemBuilder: (_, i) {
                            final item = _qrList[i] as Map<String, dynamic>? ?? {};
                            final img = _s(item['qr_url'] ?? item['qrUrl']);
                            if (img.isEmpty) return const SizedBox.shrink();
                            return GestureDetector(
                              onTap: () async {
                                final link = _qrLink;
                                if (link != null) {
                                  final uri = Uri.parse(link);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch the QR link')));
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: CachedNetworkImage(imageUrl: img, height: 120, fit: BoxFit.contain),
                              ),
                            );
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

            // ====== Recommended Projects ======
            Container(
              height: 30, width: double.infinity,
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: const Text("Recommended Properties", style: TextStyle(fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recommended.length,
                itemBuilder: (_, i) {
                  final r = _recommended[i] as Map<String, dynamic>? ?? {};
                  final rid = _s(r['id']);
                  final rprice = _s(r['price']);
                  final rbeds  = _s(r['bedrooms']);
                  final rsqft  = _s(r['square_feet'] ?? r['squareFeet']);
                  final rloc   = _s(r['location']);
                  final rmedia = (r['media'] is List) ? (r['media'] as List) : const [];
                  final rimg   = rmedia.isNotEmpty
                      ? _s((rmedia.first as Map<String, dynamic>)['original_url'] ?? (rmedia.first as Map<String, dynamic>)['originalUrl'])
                      : "";

                  return Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      child: GestureDetector(
                        onTap: () {
                          if (rid.isEmpty) return;
                          Navigator.push(context, MaterialPageRoute(builder: (_) => NewProjectDetail(id: rid)));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              child: (rimg.isNotEmpty)
                                  ? Image.network(rimg, height: 120, width: double.infinity, fit: BoxFit.cover)
                                  : Container(height: 120, width: double.infinity, color: Colors.grey.shade300,
                                  child: const Center(child: Icon(Icons.image_not_supported))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("$rprice AED", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.bed, size: 16, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text("$rbeds beds"),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.square_foot, size: 16, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text("$rsqft sqft"),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(rloc, style: const TextStyle(fontSize: 12, color: Colors.black),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
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

  // ====== common little widgets ======
  Widget _infoRow(String title, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text("$title:", style: const TextStyle(fontSize: 13, letterSpacing: 0.5))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, letterSpacing: 0.5))),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, String phoneRaw, String waRaw) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Home())),
              child: Image.asset("assets/images/home.png", height: 22)),
          // Call button (uses tel:+971…)
          Container(
            margin: const EdgeInsets.only(left: 40),
            height: 35, width: 35,
            padding: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.circular(20.0),
              boxShadow: const [
                BoxShadow(color: Colors.grey, offset: Offset(0.5, 0.5), blurRadius: 1, spreadRadius: 0.5),
                BoxShadow(color: Colors.white, offset: Offset(0, 0), blurRadius: 0, spreadRadius: 0),
              ],
            ),
            child: GestureDetector(
              onTap: () async {
                final tel = 'tel:${phoneCallNumber(phoneRaw)}';
                try {
                  final launched = await launchUrlString(tel, mode: LaunchMode.externalApplication);
                  if (!launched) debugPrint("❌ Could not launch dialer");
                } catch (e) {
                  debugPrint("❌ Exception: $e");
                }
              },
              child: const Icon(Icons.call_outlined, color: Colors.red),
            ),
          ),
          // WhatsApp button
          Container(
            margin: const EdgeInsets.only(left: 1),
            height: 35, width: 35,
            padding: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.circular(20.0),
              boxShadow: const [
                BoxShadow(color: Colors.grey, offset: Offset(0.5, 0.5), blurRadius: 1, spreadRadius: 0.5),
                BoxShadow(color: Colors.white, offset: Offset(0, 0), blurRadius: 0, spreadRadius: 0),
              ],
            ),
            child: GestureDetector(
              onTap: () async {
                final phone = whatsAppNumber(waRaw);
                final message = Uri.encodeComponent("Hello");
                final waUrl = Uri.parse("https://wa.me/$phone?text=$message");
                if (await canLaunchUrl(waUrl)) {
                  try {
                    final launched = await launchUrl(waUrl, mode: LaunchMode.externalApplication);
                    if (!launched) debugPrint("❌ Could not launch WhatsApp");
                  } catch (e) {
                    debugPrint("❌ Exception: $e");
                  }
                } else {
                  debugPrint("❌ WhatsApp not available or URL not supported");
                }
              },
              child: Image.asset("assets/images/whats.png", height: 20),
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (_) => My_Account()));
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
