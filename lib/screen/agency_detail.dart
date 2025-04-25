import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Akarat/screen/about_agency.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../model/productmodel.dart';
import '../utils/shared_preference_manager.dart';
import 'full_map_screen.dart';
import 'htmlEpandableText.dart';
import 'my_account.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;


class Agency_Detail extends StatefulWidget {
  const Agency_Detail({super.key, required this.data});
  final String data;
  @override
  State<Agency_Detail> createState() => _Agency_DetailState();
}
class _Agency_DetailState extends State<Agency_Detail> {
  int pageIndex = 0;
  ProductModel? productModels;
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    fetchProducts(widget.data);
  }

  Future<void> fetchProducts(String data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'product_cache_$data';
    final cacheTimeKey = 'product_cache_time_$data';

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // ✅ Use cache if it's less than 6 hours old
    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final cachedModel = ProductModel.fromJson(jsonData);
        setState(() {
          productModels = cachedModel;
        });
        debugPrint("📦 Loaded product from cache");
        return;
      }
    }

    try {
      final response = await http
          .get(Uri.parse('https://akarat.com/api/properties/$data'))
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
            itemBuilder: (context, index) => const ShimmerCard(),) // Show loading state
      );
    }

    final latStr = productModels!.data?.latitude;
    final lngStr = productModels!.data?.longitude;

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
              onPressed: () => Navigator.of(context).pop(),
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
                  // Image list behind
                  Container(
                    height: screenSize.height * 0.55,
                    margin: const EdgeInsets.all(0),
                    child:  ListView.builder(
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
                  SizedBox(height: 25,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                    // color: Colors.grey,
                    child: Row(
                      children: [
                        //  Text(productModels!.title),
                        Text(productModels!.data!.location.toString(),style: TextStyle(
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
                          Text(productModels!.data!.price.toString(),style: TextStyle(
                              fontSize: 25,fontWeight: FontWeight.bold,letterSpacing: 0.5
                          ),),
                          Text("  AED",style: TextStyle(
                              fontSize: 19,letterSpacing: 0.5
                          ),),
                          Text("/${productModels!.data!.paymentPeriod}",style: TextStyle(
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
                            child: Text('${productModels!.data!.bedrooms}  beds',style: TextStyle(
                                fontSize: 14,letterSpacing: 0.5
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Image.asset("assets/images/bath.png",height: 20),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text('${productModels!.data!.bathrooms}  baths',style: TextStyle(
                              fontSize: 14,letterSpacing: 0.5,
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Image.asset("assets/images/messure.png",height: 20),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text('${productModels!.data!.squareFeet}  sqft',style: TextStyle(
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
                            productModels!.data!.title.toString(),
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
                      htmlContent: productModels!.data!.description.toString().replaceAll('\r\n', '<br>'),
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
                      Text(productModels!.data!.postedOn.toString())
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
                              '${productModels!.data!.bedrooms} beds',
                              style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 12),
                            Image.asset("assets/images/bath.png", height: 17),
                            const SizedBox(width: 6),
                            Text(
                              '${productModels!.data!.bathrooms} baths',
                              style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 12),
                            Image.asset("assets/images/messure.png", height: 17),
                            const SizedBox(width: 6),
                            Text(
                              '${productModels!.data!.squareFeet} sqft',
                              style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  Container(
                    height: 30,
                    width: 200,
                    // color: Colors.grey,
                    margin: const EdgeInsets.only(left: 20,right: 200,top: 10,bottom: 0),
                    child:Text("Amnesties",style: TextStyle(
                        fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                    ),),
                  ),
                  SizedBox(height: 5,),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 360;
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: productModels?.data?.amenities?.length ?? 0,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isSmallScreen ? 1 : 2, // 1 column for small screens
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
                  Container(
                    height: screenSize.height * 0.122,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:  [
                            Text("Project"),
                            SizedBox(height: 4),
                            Text(productModels!.data!.project.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text("Delivery Date"),
                            SizedBox(height: 4),
                            Text(productModels!.data!.deliveryDate.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:  [
                            Text("Developer"),
                            SizedBox(height: 4),
                            Text(productModels!.data!.developer.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text("Property Type"),
                            SizedBox(height: 4),
                            Text(productModels!.data!.propertyType.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
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
                              Text(
                                productModels!.data!.developer.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
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
                    // Inside your widget:
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
                                        productModels!.data!.address.toString(),
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
                          child: CachedNetworkImage( // this is to fetch the image
                            imageUrl: (productModels!.data!.agentImage.toString()),
                            fit: BoxFit.cover,
                            height: 100,
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(top: 10),
                          child: Text(productModels!.data!.agent.toString(),style: TextStyle(
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
                              child: Text(productModels!.data!.closedDeals.toString()),
                            ),
                          ],
                        ),
                        Container(
                          height: 35,
                          width: screenSize.width*0.5,
                          margin: const EdgeInsets.only(left: 15,right: 10,top: 15),
                          padding: const EdgeInsets.only(top: 8),
                          // color: Colors.grey,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusDirectional.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red,
                                offset: const Offset(
                                  0.5,
                                  0.5,
                                ),
                                blurRadius: 0.5,
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
                          child: Text("See Agents Properties",textAlign: TextAlign.center,
                            style: TextStyle(
                                letterSpacing: 0.5,fontSize: 13,fontWeight: FontWeight.bold
                            ),),
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
                            productModels!.data!.regulatoryInfo!.dldPermitNumber.toString()
                        ),
                        _buildInfoRow("DED",
                            productModels!.data!.regulatoryInfo!.ded.toString()
                        ),
                        _buildInfoRow("RERA",
                            productModels!.data!.regulatoryInfo!.rera.toString()
                        ),
                        _buildInfoRow("BRN",
                            productModels!.data!.regulatoryInfo!.brn.toString()
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
                                itemCount: productModels?.data?.qr?.length ?? 0,
                                itemBuilder: (BuildContext context, int index) {
                                  final qrItem = productModels!.data!.qr![index];
                                  final imageUrl = qrItem.qrUrl;
                                  final qrLink = productModels!.data!.qrLink; // <-- this is the actual link to open

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
                  Container(
                    height: 30,
                    width: double.infinity,
                    // color: Colors.grey,
                    margin: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 0),
                    child:Text("Recommended Properties",style: TextStyle(
                        fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                    ),),
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
                              onTap: ()async{
                                String id = property.id.toString();
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    Agency_Detail(data: id)));
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
                    height: 10,),
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
          GestureDetector(
              onTap: ()async{
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
              },
              child: Image.asset("assets/images/home.png",height: 22,)),
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
              child: GestureDetector(
                  onTap:  () async {
                    String phone = 'tel:${productModels!.data!.phoneNumber}';
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

          Container(
              margin: const EdgeInsets.only(left: 1),
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
              child: GestureDetector(
                  onTap: () async {
                    final phone = productModels!.data!.whatsapp; // without plus
                    final message = Uri.encodeComponent("Hello");
                    // final url = Uri.parse("https://api.whatsapp.com/send/?phone=971503440250&text=Hello");
                    // final url = Uri.parse("https://wa.me/?text=hello");
                    final url = Uri.parse("https://api.whatsapp.com/send/?phone=%2B$phone&text&type=phone_number&app_absent=0");

                    if (await canLaunchUrl(url)) {
                      try {
                        final launched = await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication, // 💥 critical on Android 15
                        );

                        if (!launched) {
                          print("❌ Could not launch WhatsApp");
                        }
                      } catch (e) {
                        print("❌ Exception: $e");
                      }
                    } else {
                      print("❌ WhatsApp not available or URL not supported");
                    }
                  },
                  child: Image.asset("assets/images/whats.png",height: 20,))

          ),
          Container(
              margin: const EdgeInsets.only(left: 1,right: 40),
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
              child: GestureDetector(
                  onTap: () async {
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: '${productModels!.data!.email}', // Replace with actual email
                      query: 'subject=Property Inquiry&body=Hi, I saw your property on Akarat.',
                    );

                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    } else {
                      throw 'Could not launch $emailUri';
                    }
                  },
                  child: Icon(Icons.mail,color: Colors.red,))

          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {

              setState(() {
                if(token == ''){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
                }
                else{
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

                }
              });

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