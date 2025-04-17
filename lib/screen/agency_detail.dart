import 'dart:convert';
import 'package:Akarat/screen/about_agency.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../model/productmodel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../utils/shared_preference_manager.dart';
import 'my_account.dart';


class Agency_Detail extends StatefulWidget {
  const Agency_Detail({super.key, required this.data});
  final String data;
  @override
  State<Agency_Detail> createState() => _Agency_DetailState();
}
class _Agency_DetailState extends State<Agency_Detail> {
  int pageIndex = 0;
  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];
  ProductModel? productModels;
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    fetchProducts(widget.data);
  }

  Future<void> fetchProducts(data) async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://akarat.com/api/properties/$data'));
    Map<String,dynamic> jsonData=json.decode(response.body);
    debugPrint("Status Code: ${response.statusCode}");
    if (response.statusCode == 200) {
      debugPrint("API Response: ${jsonData.toString()}");
      debugPrint("API 200: ");
      ProductModel parsedModel = ProductModel.fromJson(jsonData);
      debugPrint("Parsed ProductModel: ${parsedModel.toString()}");
      setState(() {
        debugPrint("API setState: ");
        String title = jsonData['title'] ?? 'No title';
        debugPrint("API title: $title");
        productModels = parsedModel;

      });

      debugPrint("productModels title_after: ${productModels!.data!.title.toString()}");

    } else {
      // Handle error if needed
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
        body: Center(child: CircularProgressIndicator()), // Show loading state
      );
    }
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back Button
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                height: 35,
                                width: 35,
                                padding: const EdgeInsets.all(7),
                                decoration: _iconBoxDecoration(),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => About_Agency(data: productModels!.data!.agencyId.toString(),)));
                                  },
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
                  ),
                  Container(
                      height: screenSize.height*0.55,
                      margin: const EdgeInsets.only(left: 0,right: 0,top: 0),
                      child:  ListView.builder(
                        padding: const EdgeInsets.all(0),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const ScrollPhysics(),
                        itemCount: productModels?.data?.media?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          return CachedNetworkImage( // this is to fetch the image
                            imageUrl: (productModels!.data!.media![index].originalUrl.toString()),
                            //fit: BoxFit.cover,
                            // height: 100,
                          );
                        },

                      )
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
                    padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                    child:  Text(productModels!.data!.description.toString(),
                      textAlign: TextAlign.left,style: TextStyle(
                          letterSpacing: 0.4,color: Colors.black87
                      ),),

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset("assets/images/Residential__1.png", height: 17),
                            const SizedBox(width: 3),
                            const Text(
                              " Swimming Pool ",
                              style: TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 20),
                            Image.asset("assets/images/bed.png", height: 17),
                            const SizedBox(width: 3),
                            const Text(
                              " Balcony/Terrace ",
                              style: TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset("assets/images/bath.png", height: 17),
                            const SizedBox(width: 3),
                            const Text(
                              " Barbeque Area ",
                              style: TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 20),
                            Image.asset("assets/images/Residential__1.png", height: 17),
                            const SizedBox(width: 3),
                            const Text(
                              " Elevators ",
                              style: TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),

                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const SizedBox(width: 3),
                            Image.asset("assets/images/messure.png", height: 17),
                            const SizedBox(width: 3),
                            const Text(
                              "Pet Allowed ",
                              style: TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 45),
                            Image.asset("assets/images/messure.png", height: 17),
                            const SizedBox(width: 3),
                            const Text(
                              "Security ",
                              style: TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 20), // Padding at the end
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const SizedBox(width: 3),
                            Image.asset("assets/images/bed.png", height: 17),
                            const SizedBox(width: 3),
                            const Text(
                              " Gym ",
                              style: TextStyle(fontSize: 15, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 85),
                            Image.asset("assets/images/bath.png", height: 17),
                            const SizedBox(width: 3),
                            const Text(
                              "Parking Space ",
                              style: TextStyle(fontSize: 15, letterSpacing: 0.5),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(25.0657, 55.2030),
                              initialZoom: 13.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c'],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(25.0657, 55.2030),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                                  ),
                                ],
                              ),
                            ],
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
                                      const Text(
                                        "AAA Residence, JVC District 13,\nJumeirah Village Circle (JVC), Dubai",
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
                                            // Handle navigation logic here
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
                                //scrollDirection: Axis.vertical,
                                physics: const ScrollPhysics(),
                                itemCount: productModels?.data?.qr?.length ?? 0,
                                itemBuilder: (BuildContext context, int index) {
                                  return  CachedNetworkImage(imageUrl:productModels!.data!.qr![index].qrUrl.toString() ,
                                    height: 120,);
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
                  /* Container(
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Side: Title + Info
                        Expanded(
                          flex: 3,
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
                              Wrap(
                                spacing: 20,
                                runSpacing: 8,
                                children: const [
                                  Text("Reference:", style: TextStyle(fontSize: 13, letterSpacing: 0.5)),
                                  Text("Listed:", style: TextStyle(fontSize: 13, letterSpacing: 0.5)),
                                  Text("Broker License:", style: TextStyle(fontSize: 13, letterSpacing: 0.5)),
                                  Text("Agent License:", style: TextStyle(fontSize: 13, letterSpacing: 0.5)),
                                  Text("OLD Permit Number:", style: TextStyle(fontSize: 13, letterSpacing: 0.5)),
                                  Text("Zone Name:", style: TextStyle(fontSize: 13, letterSpacing: 0.5)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Right Side: DLD Image
                        Column(
                         // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                              child: Image.asset(
                                "assets/images/dld.png",
                                height: screenSize.height * 0.1,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 6),
                              Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                              child: const Text(
                                "OLD Permit Number",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),*/
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
      height: 40,
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
          IconButton(
            enableFeedback: false,
            onPressed: () {

              Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));

            },
            icon: pageIndex == 0
                ? const Icon(
              Icons.home_filled,
              color: Colors.red,
              size: 35,
            )
                : const Icon(
              Icons.home_outlined,
              color: Colors.red,
              size: 35,
            ),
          ),
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
class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 1",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 2",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 3",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 4",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}