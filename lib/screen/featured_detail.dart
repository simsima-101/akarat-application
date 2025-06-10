import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Akarat/model/fdetailmodel.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/full_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/featuredmodel.dart';
import '../utils/shared_preference_manager.dart';
import 'about_agent.dart';
import 'agent_detail.dart';
import 'htmlEpandableText.dart';
import 'package:Akarat/utils/whatsapp_button.dart';

class Featured_Detail extends StatefulWidget {
  const Featured_Detail({super.key, required this.data});
  final String data;
  @override
  State<Featured_Detail> createState() => _Featured_DetailState();
}
class _Featured_DetailState extends State<Featured_Detail> {



  String safeSubstring(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength);
    }
  }

  Featured_DetailModel? featuredDetailModel;

  int pageIndex = 0;


  String formatWhatsAppNumber(String rawNumber) {
    String phone = rawNumber.replaceAll(RegExp(r'\D'), ''); // remove non-digits → keeps only numbers
    return phone; // no adding anything
  }











  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    fetchProducts(widget.data);
  }


  bool isDataRead = false;
  String token = '';
  String email = '';
  String result = '';
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

    }

    // Step 2: Check if cache is still valid (6 hours)
    if (now - lastFetched < Duration(hours: 6).inMilliseconds && cached != null) {
      debugPrint("✅ Loaded from cache (fresh)");
      return;
    }

    // Step 3: Fetch from API if cache is stale or missing
    final url = Uri.parse('https://akarat.com/api/featured-properties/$data');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final parsedModel = Featured_DetailModel.fromJson(jsonData);

        // Update cache and timestamp
        prefs.setString(cachedKey, response.body);
        prefs.setInt(cachedTimeKey, now);

        if (!mounted) return;
        setState(() => featuredDetailModel = parsedModel);
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Unexpected error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if (featuredDetailModel == null) {
      return Scaffold(
          body: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerCard(),) // Show loading state
      );
    }

    final latStr = featuredDetailModel!.data?.property?.latitude;
    final lngStr = featuredDetailModel!.data?.property?.longitude;

// Default fallback if parsing fails or null
    final double latitude = double.tryParse(latStr ?? '') ?? 25.0657;
    final double longitude = double.tryParse(lngStr ?? '') ?? 55.2030;


    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.red),
              onPressed: ()async {
                setState(() {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
                });
              },
            ),
            centerTitle: true,
            backgroundColor: Color(0xFFFFFFFF),
            iconTheme: const IconThemeData(color: Colors.red),
            // elevation: 1,
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Container(
                    height: screenSize.height * 0.55,
                    margin: const EdgeInsets.all(0),
                    child:  ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const ScrollPhysics(),
                      itemCount: featuredDetailModel?.data?.property?.media?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {

                        final imageUrl = featuredDetailModel!.data!.property!
                            .media![index].originalUrl.toString();

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
                                          itemCount: featuredDetailModel?.data?.property?.media?.length ?? 0,
                                          itemBuilder: (context, pageIndex) {
                                            final previewUrl = featuredDetailModel!.data!.property!
                                                .media![pageIndex].originalUrl.toString();
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
                                            onPressed: () {
                                              Navigator.of(context).pop(); // closes the full screen
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
                  /*Stack(
                    children: [
                      // Image list behind

                      // Top bar over images
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back Button
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  print("BACK TAPPED!");
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  height: 35,
                                  width: 35,
                                  padding: const EdgeInsets.all(7),
                                  decoration: _iconBoxDecoration(),
                                  child: Image.asset(
                                    "assets/images/ar-left.png",
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),


                              // Like Button
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                height: 35,
                                width: 35,
                                padding: const EdgeInsets.all(7),
                                decoration: _iconBoxDecoration(),
                                child: Image.asset(
                                  "assets/images/lov.png",
                                  width: 15,
                                  height: 15,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),*/
                  SizedBox(height: 25,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                    // color: Colors.grey,
                    child: Row(
                      children: [
                        //  Text(productModels!.title),
                        Text(featuredDetailModel!.data!.property!
                            .location.toString(),style: TextStyle(
                          // Text("Townhouse",style: TextStyle(
                            letterSpacing: 0.5
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 0.0, top: 0, bottom: 0),
                          child: Container(
                            width: 90,
                            height: 28,
                            padding: const EdgeInsets.only(top: 2,left: 5,right: 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadiusDirectional.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(
                                    1.5,
                                    1.5,
                                  ),
                                  blurRadius: 0.5,
                                  spreadRadius: 0.5,
                                ), //BoxShadow
                                BoxShadow(
                                  color: Colors.green,
                                  offset: const Offset(0.5, 0.5),
                                  blurRadius: 0.5,
                                  spreadRadius: 0.5,
                                ), //BoxShadow
                              ],
                            ),
                            child: Row(
                              children: [
                                Padding(padding: const EdgeInsets.only(left: 0),
                                    child:   Icon(Icons.verified_user,color: Colors.white,)
                                ),
                                Padding(padding: const EdgeInsets.only(left: 1),
                                    child:   Text("VERIFIED",style: TextStyle(
                                        letterSpacing: 0.5,color: Colors.white,fontSize: 12
                                    ),textAlign: TextAlign.center,)
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                      child:Row(
                        children: [
                          Text(featuredDetailModel!.data!.property!
                              .price.toString(),style: TextStyle(
                              fontSize: 25,fontWeight: FontWeight.bold,letterSpacing: 0.5
                          ),),
                          Text("  AED",style: TextStyle(
                              fontSize: 19,letterSpacing: 0.5
                          ),),
                          Text("/${featuredDetailModel!.data!.property!
                              .paymentPeriod}",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5
                          ),),
                        ],
                      )
                  ),
                  SizedBox(height: 5,),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                      // color: Colors.grey,
                      child:Row(
                        children: [
                          Image.asset("assets/images/bed.png",height: 20,),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text('${featuredDetailModel!.data!.property!
                                .bedrooms}  beds',style: TextStyle(
                                fontSize: 14,letterSpacing: 0.5
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Image.asset("assets/images/bath.png",height: 20),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text('${featuredDetailModel!.data!.property!
                                .bathrooms}  baths',style: TextStyle(
                              fontSize: 14,letterSpacing: 0.5,
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Image.asset("assets/images/messure.png",height: 20),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text('${featuredDetailModel!.data!.property!
                                .squareFeet}  sqft',style: TextStyle(
                              fontSize: 14,letterSpacing: 0.5,
                            ),),
                          ),
                        ],
                      )
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            featuredDetailModel!.data!.property!
                                .title.toString(),
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const SizedBox(), // or remove this if not needed
                    ],
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: HtmlExpandableText(
                      htmlContent: safeSubstring(
                        featuredDetailModel!.data!.property!
                            .description.toString().replaceAll('\r\n', '<br>'),
                        200, // max 200 characters to avoid crash
                      ),
                    ),

                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                        child: Text("Posted On:",style: TextStyle(
                            fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Text(featuredDetailModel!.data!.property!
                          .postedOn.toString())
                    ],
                  ),
                  SizedBox(height: 15,),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                        child:Text("Property Details",style: TextStyle(
                            fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Text("")
                    ],
                  ),
                  SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Column(
                      spacing: 5,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset("assets/images/Residential-test.png", height: 17,),
                            const SizedBox(width: 6),
                            Text(
                              featuredDetailModel!.data!.property!
                                  .propertyType.toString(),
                              style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                            Text("")
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Image.asset("assets/images/bed.png", height: 17),
                            const SizedBox(width: 6),
                            Text(
                              '${featuredDetailModel!.data!.property!
                                  .bedrooms} beds',
                              style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 12),
                            Image.asset("assets/images/bath.png", height: 17),
                            const SizedBox(width: 6),
                            Text(
                              '${featuredDetailModel!.data!.property!
                                  .bathrooms} baths',
                              style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 12),
                            Image.asset("assets/images/messure.png", height: 17),
                            const SizedBox(width: 6),
                            Text(
                              '${featuredDetailModel!.data!.property!
                                  .squareFeet} sqft',
                              style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 15,),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text("Amenities",style: TextStyle(
                            fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Text("")
                    ],
                  ),
                  SizedBox(height: 5,),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 360;
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: featuredDetailModel?.data?.property?.amenities?.length ?? 0,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isSmallScreen ? 1 : 2, // 1 column for small screens
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: isSmallScreen ? 4.5 : 5,
                        ),
                        itemBuilder: (context, index) {
                          final amenity = featuredDetailModel!.data!.property!
                              .amenities![index];
                          return Row(
                            children: [
                              Image.network(
                                amenity.icon ?? '',
                                width: 18,
                                height: 18,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 18),
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
                  SizedBox(height: 15,),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                        child:Text("Project Information",style: TextStyle(
                            fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Text("")
                    ],
                  ),
                  SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Project"),
                            SizedBox(height: 4),
                            Text("Mag Eye", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text("Delivery Date"),
                            SizedBox(height: 4),
                            Text("25th Jan 2025", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Developer"),
                            SizedBox(height: 4),
                            Text("MAG Property Development", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text("Property Type"),
                            SizedBox(height: 4),
                            Text("Townhouse, Apartment", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  Container(
                    height: screenSize.height * 0.17,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                              SizedBox(height: 15,),
                              Container(
                                height: 30,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: [
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
                                  String agentId = featuredDetailModel!.data!.property!.agentId.toString();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AboutAgent(data: agentId)),
                                  );
                                },
                                child: Container(
                                  height: screenSize.height * 0.04,
                                  width: screenSize.width * 0.4,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
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
                  SizedBox(height: 15,),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                        child:Text("Location & nearby",style: TextStyle(
                            fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Text("")
                    ],
                  ),
                  SizedBox(height: 10,),
                  Container(
                    height: screenSize.height*0.3,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(15.0),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          // Google Map instead of FlutterMap
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(latitude, longitude), // Dubai
                              zoom: 12,
                            ),
                            /* markers: {
                              Marker(
                                markerId: MarkerId('main'),
                                position: LatLng(latitude, longitude),
                                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                              ),
                            },*/
                            zoomControlsEnabled: false,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                          ),

                          // Bottom overlay card
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
                                        featuredDetailModel!.data!.property!
                                            .address.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                        child:Text("Provided by",style: TextStyle(
                            fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                        ),),
                      ),
                      Text("")
                    ],
                  ),
                  SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                    // color: Colors.grey,
                    child: Column(
                      children: [
                        Container(
                          //margin: const EdgeInsets.only(left: 65,top: 8,bottom: 0),
                          height: 110,
                          width: 110,
                          padding: const EdgeInsets.only(top: 0,left: 0,right: 0,bottom: 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusDirectional.circular(60.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: const Offset(
                                  0.0,
                                  0.0,
                                ),
                                blurRadius: 0.1,
                                spreadRadius: 0.1,
                              ), //BoxShadow
                              BoxShadow(
                                color: Colors.white,
                                offset: const Offset(0.0, 0.0),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ), //BoxShadow
                            ],
                          ),
                          child: CachedNetworkImage(
                            imageUrl: featuredDetailModel!.data!.property!
                                .agentImage?.isNotEmpty == true
                                ? featuredDetailModel!.data!.property!
                                .agentImage!
                                : 'https://via.placeholder.com/100', // fallback image
                            fit: BoxFit.cover,
                            height: 100,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.person, size: 60, color: Colors.grey),
                          ),

                        ),
                        Padding(padding: const EdgeInsets.only(top: 10),
                          child: Text(featuredDetailModel!.data!.property!
                              .agent.toString(),style: TextStyle(
                              fontWeight: FontWeight.bold,letterSpacing: 0.5
                          ),),
                        ),
                        Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(top: 5,left: 80),
                              // child: Text(productModels!.agent.rating.toString()),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 5,left: 5),
                              child: Row(
                                children: [
                                  Icon(Icons.star,color: Color(0xFFFBC02D),),
                                  Icon(Icons.star,color: Color(0xFFFBC02D),),
                                  Icon(Icons.star,color: Color(0xFFFBC02D),),
                                  Icon(Icons.star,color: Color(0xFFFBC02D),),
                                  Icon(Icons.star,color: Color(0xFFFBC02D),),
                                ],
                              ),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 5,left: 5),
                              child: Text("ratings"),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(top: 5,left: 50),
                              child: Text("Response time"),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 5,left: 50),
                              child: Text("within 5 minutes"),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(top: 5,left: 50),
                              child: Text("Closed Deals"),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 5,left: 63),
                              child: Text("17"),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            String agentId = featuredDetailModel!.data!.property!.agentId.toString();
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red,
                                  offset: const Offset(0.5, 0.5),
                                  blurRadius: 0.5,
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
                  SizedBox(height: 5,),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 18, right: 14, top: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 10),

                        // Info Rows
                        _buildInfoRow("DLD Permit Number:",
                            featuredDetailModel!.data!.property!
                                .regulatoryInfo!.dldPermitNumber.toString()
                        ),
                        _buildInfoRow("DED",
                            featuredDetailModel!.data!.property!
                                .regulatoryInfo!.ded.toString()
                        ),
                        _buildInfoRow("RERA",
                            featuredDetailModel!.data!.property!
                                .regulatoryInfo!.rera.toString()
                        ),
                        _buildInfoRow("BRN",
                            featuredDetailModel!.data!.property!
                                .regulatoryInfo!.brn.toString()
                        ),

                        const SizedBox(height: 5),

                        // Logo and label
                        Center(
                          child: Column(
                            children: [
                              ListView.builder(
                                padding: const EdgeInsets.all(0),
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: featuredDetailModel?.data?.property?.qr?.length ?? 0,
                                itemBuilder: (BuildContext context, int index) {
                                  final qrItem = featuredDetailModel!.data!.property!
                                      .qr![index];
                                  final imageUrl = qrItem.qrUrl;
                                  final qrLink = featuredDetailModel!.data!.property!
                                      .qrLink; // <-- this is the actual link to open

                                  return GestureDetector(
                                    onTap: () async {
                                      if (qrLink != null && qrLink.isNotEmpty) {
                                        final Uri url = Uri.parse(qrLink);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Could not launch the QR link')),
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
                                      ),
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
                  SizedBox(height: 5,),
                  // Container(
                  //   height: 30,
                  //   width: double.infinity,
                  //   // color: Colors.grey,
                  //   margin: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 0),
                  //   child:Text("Recommended Properties",style: TextStyle(
                  //       fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                  //   ),),
                  // ),

                  const SizedBox(height: 5),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20),
                  //   child: SingleChildScrollView(
                  //     scrollDirection: Axis.horizontal,
                  //     child: Row(
                  //       children: [
                  //         // First Container
                  //         Padding(
                  //           padding: const EdgeInsets.all(8),
                  //           child: Container(
                  //             width: 150, // Fixed width to match the reference
                  //             height: 160, // Fixed height to match the reference
                  //             decoration: BoxDecoration(
                  //               color: Color(0xFFFFFFFF),
                  //               // Same as your first container
                  //               borderRadius: const BorderRadius.only(
                  //                 bottomLeft: Radius.circular(10),
                  //                 bottomRight: Radius.circular(10),
                  //               ), // Match radius
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                   color: Colors.black26,
                  //                   offset: Offset(0, 4), // Bottom shadow only
                  //                   blurRadius: 12,
                  //                   spreadRadius: 0,
                  //                 ),
                  //               ],
                  //             ),
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Stack(
                  //                   children: [
                  //                     Image.asset(
                  //                       'assets/images/photo1.png',
                  //                       height: 75,
                  //                       width: 150,
                  //                       fit: BoxFit.cover,
                  //                     ),
                  //                     Positioned(
                  //                       top: 4,
                  //                       left: 4,
                  //                       child: Row(
                  //                         children: [
                  //                           Container(
                  //                             height: 18, // ⬅️ Match approx. 11.21px with visual padding
                  //                             padding: const EdgeInsets.symmetric(horizontal: 6),
                  //                             decoration: BoxDecoration(
                  //                               color: const Color(0xFF23BD9F),
                  //                               borderRadius: BorderRadius.circular(5), // ⬅️ Match 5px radius
                  //                             ),
                  //                             child: Row(
                  //                               mainAxisSize: MainAxisSize.min,
                  //                               crossAxisAlignment: CrossAxisAlignment.center,
                  //                               children: [
                  //                                 Image.asset(
                  //                                   'assets/images/verified-white 1.png',
                  //                                   width: 10,  // ⬅️ Slightly larger than 5.82 for clarity
                  //                                   height: 10,
                  //                                 ),
                  //                                 const SizedBox(width: 3),
                  //                                 const Text(
                  //                                   'TrueCheck',
                  //                                   style: TextStyle(
                  //                                     fontSize: 9, // ⬅️ Balanced height for text (6.5px target)
                  //                                     color: Colors.white,
                  //                                     fontWeight: FontWeight.w500,
                  //                                   ),
                  //                                 ),
                  //                               ],
                  //                             ),
                  //                           ),
                  //
                  //                           SizedBox(width: 55),
                  //
                  //                           Image.asset(
                  //                             'assets/images/lov.png',
                  //                             width: 9,  // Based on 8.92px
                  //                             height: 8, // Based on 7.57px
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //
                  //                   ],
                  //                 ),
                  //
                  //                 const SizedBox(height: 8),
                  //                 const Padding(
                  //                   padding: EdgeInsets.only(left: 8),
                  //                   child: Row(
                  //                     crossAxisAlignment: CrossAxisAlignment.end,
                  //                     children: [
                  //                       Text(
                  //                         "AED ",
                  //                         style: TextStyle(
                  //                           fontSize: 12,
                  //                           fontWeight: FontWeight.w500,
                  //                           color: Colors.black,
                  //                         ),
                  //                       ),
                  //                       Text(
                  //                         "130,000",
                  //                         style: TextStyle(
                  //                           fontSize: 15,
                  //                           fontWeight: FontWeight.bold,
                  //                           color: Colors.black,
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //                 const SizedBox(height: 6),
                  //                 Padding(
                  //                   padding: const EdgeInsets.only(left: 8),
                  //                   child: Row(
                  //                     children: [
                  //                       Image.asset('assets/images/bed.png', width: 14, height: 14),
                  //                       const SizedBox(width: 4),
                  //                       const Text("2 Beds", style: TextStyle(fontSize: 12)),
                  //                       const SizedBox(width: 10),
                  //                       Image.asset('assets/images/messure.png', width: 14, height: 14),
                  //                       const SizedBox(width: 4),
                  //                       const Text("1410 ft", style: TextStyle(fontSize: 12)),
                  //                     ],
                  //                   ),
                  //                 ),
                  //                 const SizedBox(height: 6),
                  //                 Padding(
                  //                   padding: const EdgeInsets.only(left: 8),
                  //                   child: Row(
                  //                     children: [
                  //                       Image.asset('assets/images/map.png', width: 14, height: 14),
                  //                       const SizedBox(width: 4),
                  //                       const Text("Jumeira, Dubai", style: TextStyle(fontSize: 12)),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //
                  //
                  //
                  //         const SizedBox(width: 30),
                  //
                  //         // Second Container (same as first)
                  //         Padding(
                  //           padding: const EdgeInsets.all(8),
                  //           child: Container(
                  //             width: 150, // Fixed width to match the reference
                  //             height: 160, // Fixed height to match the reference
                  //             decoration: BoxDecoration(
                  //               color: Color(0xFFFFFFFF),// Same as your first container
                  //               borderRadius: const BorderRadius.only(
                  //                 bottomLeft: Radius.circular(10),
                  //                 bottomRight: Radius.circular(10),
                  //               ),// Match radius
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                   color: Colors.black26,
                  //                   offset: Offset(0, 4), // Bottom shadow only
                  //                   blurRadius: 12,
                  //                   spreadRadius: 0,
                  //                 ),
                  //               ],
                  //             ),
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Stack(
                  //                   children: [
                  //                     Image.asset(
                  //                       'assets/images/photo1.png',
                  //                       height: 75,
                  //                       width: 150,
                  //                       fit: BoxFit.cover,
                  //                     ),
                  //                     Positioned(
                  //                       top: 4,
                  //                       left: 4,
                  //                       child: Row(
                  //                         children: [
                  //                           Container(
                  //                             height: 18, // ⬅️ Match approx. 11.21px with visual padding
                  //                             padding: const EdgeInsets.symmetric(horizontal: 6),
                  //                             decoration: BoxDecoration(
                  //                               color: const Color(0xFF23BD9F),
                  //                               borderRadius: BorderRadius.circular(5), // ⬅️ Match 5px radius
                  //                             ),
                  //                             child: Row(
                  //                               mainAxisSize: MainAxisSize.min,
                  //                               crossAxisAlignment: CrossAxisAlignment.center,
                  //                               children: [
                  //                                 Image.asset(
                  //                                   'assets/images/verified-white 1.png',
                  //                                   width: 10,  // ⬅️ Slightly larger than 5.82 for clarity
                  //                                   height: 10,
                  //                                 ),
                  //                                 const SizedBox(width: 3),
                  //                                 const Text(
                  //                                   'TrueCheck',
                  //                                   style: TextStyle(
                  //                                     fontSize: 9, // ⬅️ Balanced height for text (6.5px target)
                  //                                     color: Colors.white,
                  //                                     fontWeight: FontWeight.w500,
                  //                                   ),
                  //                                 ),
                  //                               ],
                  //                             ),
                  //
                  //
                  //                           ),
                  //                           SizedBox(width: 55),
                  //
                  //                           Image.asset(
                  //                             'assets/images/lov.png',
                  //                             width: 9,  // Based on 8.92px
                  //                             height: 8, // Based on 7.57px
                  //                           ),
                  //                         ],
                  //
                  //
                  //                       ),
                  //                     ),
                  //
                  //                   ],
                  //                 ),
                  //
                  //
                  //
                  //                 const SizedBox(height: 8),
                  //                 const Padding(
                  //                   padding: EdgeInsets.only(left: 8),
                  //                   child: Row(
                  //                     crossAxisAlignment: CrossAxisAlignment.end,
                  //                     children: [
                  //                       Text(
                  //                         "AED ",
                  //                         style: TextStyle(
                  //                           fontSize: 12,
                  //                           fontWeight: FontWeight.w500,
                  //                           color: Colors.black,
                  //                         ),
                  //                       ),
                  //                       Text(
                  //                         "130,000",
                  //                         style: TextStyle(
                  //                           fontSize: 15,
                  //                           fontWeight: FontWeight.bold,
                  //                           color: Colors.black,
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //                 const SizedBox(height: 6),
                  //                 Padding(
                  //                   padding: const EdgeInsets.only(left: 8),
                  //                   child: Row(
                  //                     children: [
                  //                       Image.asset('assets/images/bed.png', width: 14, height: 14),
                  //                       const SizedBox(width: 4),
                  //                       const Text("2 Beds", style: TextStyle(fontSize: 12)),
                  //                       const SizedBox(width: 10),
                  //                       Image.asset('assets/images/messure.png', width: 14, height: 14),
                  //                       const SizedBox(width: 4),
                  //                       const Text("1410 ft", style: TextStyle(fontSize: 12)),
                  //                     ],
                  //                   ),
                  //                 ),
                  //                 const SizedBox(height: 6),
                  //                 Padding(
                  //                   padding: const EdgeInsets.only(left: 8),
                  //                   child: Row(
                  //                     children: [
                  //                       Image.asset('assets/images/map.png', width: 14, height: 14),
                  //                       const SizedBox(width: 4),
                  //                       const Text("Jumeira, Dubai", style: TextStyle(fontSize: 12)),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //
                  //
                  //
                  //
                  //
                  //
                  //       ],
                  //     ),
                  //   ),
                  // ),





                  SizedBox(
                    height: 240, // 210 works perfectly for your current card content
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredDetailModel?.data?.recommended?.length ?? 0,
                      itemBuilder: (context, index) {
                        final property = featuredDetailModel!.data!.recommended![index];
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
                              onTap: () async {
                                String id = property.id.toString();
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    Featured_Detail(data: id)));
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
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
                                          child: const Center(child: Icon(Icons.image_not_supported)),
                                        ),
                                      ),
                                      const Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Icon(Icons.favorite_border, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${property.price} AED",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
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
                  SizedBox(
                    height: 10,)
                ]
            )
        )
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // GestureDetector(
          //   onTap: () async {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
          //   },
          //   child: Row(
          //     children: [
          //       Stack(
          //         clipBehavior: Clip.none,
          //         children: [
          //           Image.asset(
          //             "assets/images/agent45.png",
          //             width: 34.46,
          //             height: 34.46,
          //             fit: BoxFit.contain,
          //           ),
          //           Positioned(
          //             top: -2,
          //             right: -4,
          //             child: Image.asset(
          //               "assets/images/verified-green 1.png",
          //               width: 6.63,
          //               height: 8.11,
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(width: 8), // Space between the two images
          //       Column(
          //         mainAxisSize: MainAxisSize.min,
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Padding(
          //             padding: const EdgeInsets.only(bottom: 0.5), // 🎯 perfect match for Figma gap
          //             child: Image.asset(
          //               "assets/images/Mahateer Abbasi.png",
          //               width: 80,     // as per your latest size
          //               height: 12,
          //               fit: BoxFit.contain,
          //             ),
          //           ),
          //           Row(
          //             children: [
          //               Image.asset(
          //                 "assets/images/1star 1.png",
          //                 width: 11.43,
          //                 height: 10.85,
          //                 fit: BoxFit.contain,
          //               ),
          //
          //               SizedBox(width: 2,),
          //
          //               Image.asset(
          //                 "assets/images/5.0.png",
          //                 width: 12,
          //                 height: 10,
          //                 fit: BoxFit.contain,
          //               )
          //
          //             ],
          //
          //
          //           ),
          //         ],
          //       ),
          //
          //
          //     ],
          //   ),
          // ),



          Container(
              margin: const EdgeInsets.only(left: 40),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: const Offset(
                      0.5,
                      0.5,
                    ),
                    blurRadius: 1.0,
                    spreadRadius: 0.5,
                  ), //BoxShadow
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ), //BoxShadow
                ],
              ),
              child:GestureDetector(
                  onTap:  () async {
                    String phone = 'tel:${featuredDetailModel!.data!.property!
                        .phoneNumber}';
                    try {
                      final bool launched = await launchUrlString(
                        phone,
                        mode: LaunchMode.externalApplication, // ✅ Force external
                      );
                      if (!launched) {
                        print("❌ Could not launch dialer");
                      }
                    } catch (e) {
                      print("❌ Exception: $e");
                    }

                  },
                  child: Icon(Icons.call_outlined,color: Colors.red,))
          ),

    //       Container(
    //         margin: const EdgeInsets.only(left: 1),
    //         height: 35,
    //         width: 35,
    //         padding: const EdgeInsets.only(top: 2),
    //         decoration: BoxDecoration(
    //           borderRadius: BorderRadiusDirectional.circular(20.0),
    //           boxShadow: [
    //             BoxShadow(
    //               color: Colors.grey,
    //               offset: const Offset(0.5, 0.5),
    //               blurRadius: 1.0,
    //               spreadRadius: 0.5,
    //             ),
    //             BoxShadow(
    //               color: Colors.white,
    //               offset: const Offset(0.0, 0.0),
    //               blurRadius: 0.0,
    //               spreadRadius: 0.0,
    //             ),
    //           ],
    //         ),
    // child: GestureDetector(
    // onTap: () async {
    // String rawPhone = featuredDetailModel!.data!.property!.whatsapp ?? '';
    //
    // // Clean full number:
    // String phone = rawPhone
    //     .replaceAll(RegExp(r'[^\d+]'), '')  // Remove unwanted characters
    //     .replaceFirst('+', '');             // Remove leading "+"
    //
    // final message = Uri.encodeComponent("Hello");
    // final url = Uri.parse("https://wa.me/$phone?text=$message");
    //
    // print("WhatsApp link: $url");
    //
    // if (await canLaunchUrl(url)) {
    // try {
    // final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    // if (!launched) {
    // print("❌ Could not launch WhatsApp");
    // }
    // } catch (e) {
    // print("❌ Exception: $e");
    // }
    // } else {
    // print("❌ WhatsApp not available or URL not supported");
    // }
    // },
    // child: Image.asset("assets/images/whats.png", height: 20),
    // ),
    //
    // ),
    //
    //       Container(
    //           margin: const EdgeInsets.only(left: 1,right: 40),
    //           height: 35,
    //           width: 35,
    //           padding: const EdgeInsets.only(top: 2),
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadiusDirectional.circular(20.0),
    //             boxShadow: [
    //               BoxShadow(
    //                 color: Colors.grey,
    //                 offset: const Offset(
    //                   0.5,
    //                   0.5,
    //                 ),
    //                 blurRadius: 1.0,
    //                 spreadRadius: 0.5,
    //               ), //BoxShadow
    //               BoxShadow(
    //                 color: Colors.white,
    //                 offset: const Offset(0.0, 0.0),
    //                 blurRadius: 0.0,
    //                 spreadRadius: 0.0,
    //               ), //BoxShadow
    //             ],
    //           ),
    //           child:  GestureDetector(
    //               onTap: () async {
    //                 final Uri emailUri = Uri(
    //                   scheme: 'mailto',
    //                   path: '${featuredDetailModel!.data!.property!
    //                       .email}', // Replace with actual email
    //                   query: 'subject=Property Inquiry&body=Hi, I saw your property on Akarat.',
    //                 );
    //
    //                 if (await canLaunchUrl(emailUri)) {
    //                   await launchUrl(emailUri);
    //                 } else {
    //                   throw 'Could not launch $emailUri';
    //                 }
    //               },
    //               child: Icon(Icons.mail,color: Colors.red,))
    //
    //       ),


          SizedBox(
            width: 40, // or any appropriate width
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                setState(() {
                  if (token == '') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Profile_Login()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
                  }
                });
              },
              icon: pageIndex == 3
                  ? const Icon(
                Icons.dehaze,
                color: Colors.red,
                size: 30, // reduce from 35 to 30
              )
                  : const Icon(
                Icons.dehaze_outlined,
                color: Colors.red,
                size: 30, // reduce from 35 to 30
              ),
            ),
          )
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