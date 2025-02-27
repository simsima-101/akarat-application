import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drawerdemo/model/api2model.dart';
import 'package:drawerdemo/screen/home.dart';
import 'package:drawerdemo/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../model/productmodel.dart';


class Product_Detail extends StatefulWidget {
  const Product_Detail({super.key, required this.data});
  final String data;
  @override
  State<Product_Detail> createState() => _Product_DetailState();
}
class _Product_DetailState extends State<Product_Detail> {
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

      debugPrint("productModels title_after: ${productModels!.title}");

    } else {
      // Handle error if needed
    }
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
        bottomNavigationBar: buildMyNavBar(context),
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Stack(
                    // alignment: Alignment.topCenter,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          // color: Color(0xFFEEEEEE),
                          child:   Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 10,top: 5,bottom: 0),
                                height: 35,
                                width: 35,
                                padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusDirectional.circular(20.0),
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
                                child: Image.asset("assets/images/ar-left.png",
                                  width: 15,
                                  height: 15,
                                  fit: BoxFit.contain,),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 220,top: 5,bottom: 0,),
                                height: 35,
                                width: 35,
                                padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusDirectional.circular(20.0),
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
                                child: Image.asset("assets/images/lov.png",
                                  width: 15,
                                  height: 15,
                                  fit: BoxFit.contain,),
                                //child: Image(image: Image.asset("assets/images/share.png")),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 5,top: 5,bottom: 0,),
                                height: 35,
                                width: 35,
                                padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusDirectional.circular(20.0),
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
                                child: Image.asset("assets/images/forward.png",
                                  width: 15,
                                  height: 15,
                                  fit: BoxFit.contain,),
                                //child: Image(image: Image.asset("assets/images/share.png")),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 5,top: 5,bottom: 0,),
                                height: 35,
                                width: 35,
                                padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusDirectional.circular(20.0),
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
                                child: Image.asset("assets/images/arrow_right.png",
                                  width: 15,
                                  height: 15,
                                  fit: BoxFit.contain,),
                                //child: Image(image: Image.asset("assets/images/share.png")),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      height: 550,
                      margin: const EdgeInsets.only(left: 0,right: 0,top: 0),
                      child:  ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: <Widget>[
                            Image.asset("assets/images/image 2.png",fit: BoxFit.fill,),
                            Image.asset("assets/images/image 2.png",fit: BoxFit.fill,),
                            Image.asset("assets/images/image 2.png",fit: BoxFit.fill,),
                            Image.asset("assets/images/image 2.png",fit: BoxFit.fill,),
                            Image.asset("assets/images/image 2.png",fit: BoxFit.fill,),
                            Image.asset("assets/images/image 2.png",fit: BoxFit.fill,),
                            Image.asset("assets/images/image 2.png",fit: BoxFit.fill,),
                          ]
                      )
                  ) ,
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(left: 20,top: 10,right: 10,bottom: 0),
                    // color: Colors.grey,
                    child: Row(
                      children: [
                        //  Text(productModels!.title),
                        Text("Townhouse",style: TextStyle(
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
                  Padding(padding: const EdgeInsets.only(left: 20,right: 0,top: 10,bottom: 0),
                      child:Row(
                        children: [
                          Text(productModels!.price.toString(),style: TextStyle(
                              fontSize: 25,fontWeight: FontWeight.bold,letterSpacing: 0.5
                          ),),
                          Text("  AED",style: TextStyle(
                              fontSize: 19,letterSpacing: 0.5
                          ),),
                        ],
                      )
                  ),
                  Padding(padding: const EdgeInsets.only(left: 20,right: 0,top: 5,bottom: 0),
                      child:Row(
                        children: [
                          Text("Est.Mortgage:",style: TextStyle(
                              fontSize: 14,letterSpacing: 0.5
                          ),),
                          Text("  12,750",style: TextStyle(
                              fontSize: 19,letterSpacing: 0.5,fontWeight: FontWeight.bold
                          ),),
                          Text("  AED/month",style: TextStyle(
                            fontSize: 17,letterSpacing: 0.5,
                          ),),
                        ],
                      )
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 20,top: 5,right: 10),
                      height: 40,
                      // color: Colors.grey,
                      child:Row(
                        children: [
                          Image.asset("assets/images/bed.png",height: 20,),
                          Text(" "+ productModels!.bedrooms.toString()+" beds   ",style: TextStyle(
                              fontSize: 14,letterSpacing: 0.5
                          ),),
                          Image.asset("assets/images/bath.png",height: 20),
                          Text(" "+ productModels!.bathrooms.toString()+" baths   ",style: TextStyle(
                            fontSize: 14,letterSpacing: 0.5,
                          ),),
                          Image.asset("assets/images/messure.png",height: 20),
                          Text(" "+ productModels!.squareFeet.toString()+" sqft",style: TextStyle(
                            fontSize: 14,letterSpacing: 0.5,
                          ),),
                        ],
                      )
                  ),
                  Container(
                    height: screenSize.height*0.08,
                    // color: Colors.grey,
                    padding: const EdgeInsets.only(left: 20,right: 0,top: 1,bottom: 0),
                    child:
                    Text(productModels!.title.toString(),style: TextStyle(
                        fontSize: 25,fontWeight: FontWeight.bold,letterSpacing: 0.5
                    ),),

                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5,left: 15,right: 10),
                    child: Container(
                      width: double.infinity,
                      height: screenSize.height*0.3,
                       //color: Colors.grey,
                      margin: const EdgeInsets.only(left: 5,top: 5),
                      child: Text(productModels!.description.toString(),
                        textAlign: TextAlign.left,style: TextStyle(
                            letterSpacing: 0.2,fontWeight: FontWeight.bold,color: Colors.black87
                        ),),
                    ),
                  ),
                  Container(
                    height: screenSize.height*0.05,
                    width: screenSize.width*0.9,
                    margin: const EdgeInsets.only(left: 20,right: 20,top: 10),
                    padding: const EdgeInsets.only(top: 8),
                    // color: Colors.grey,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red,
                          offset: const Offset(
                            0.0,
                            0.0,
                          ),
                          blurRadius: 0.0,
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
                    child: Text("Show Full Description",textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,fontSize: 17,letterSpacing: 0.5
                      ),),
                  ),
                  Padding(padding: const EdgeInsets.only(left: 20,right: 0,top: 20,bottom: 0),
                      child:Row(
                        children: [
                          Text("Posted On:",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                          ),),
                          Text(productModels!.postedOn.toString(),style: TextStyle(
                            fontSize: 14,letterSpacing: 0.5,
                          ),),
                        ],
                      )
                  ),
                  Container(
                    height: 30,
                    width: 200,
                    // color: Colors.grey,
                    margin: const EdgeInsets.only(left: 20,right: 200,top: 20,bottom: 0),
                    child:Text("Property Details",style: TextStyle(
                        fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                    ),),
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 20,top: 0,right: 10),
                      height: 30,
                      // color: Colors.grey,
                      child:Row(
                        children: [
                          Image.asset("assets/images/Residential__1.png",height: 15,),
                          Text("  Apartment   ",style: TextStyle(
                              fontSize: 14,letterSpacing: 0.5
                          ),),
                          Image.asset("assets/images/bed.png",height: 15,),
                          Text("  2 beds   ",style: TextStyle(
                              fontSize: 14,letterSpacing: 0.5
                          ),),
                          Image.asset("assets/images/bath.png",height: 15),
                          Text(" 3 baths   ",style: TextStyle(
                            fontSize: 14,letterSpacing: 0.5,
                          ),),
                          Image.asset("assets/images/messure.png",height: 15),
                          Text(" 1410 sqft",style: TextStyle(
                            fontSize: 14,letterSpacing: 0.5,
                          ),),
                        ],
                      )
                  ),
                  Container(
                    height: 30,
                    width: 200,
                    // color: Colors.grey,
                    margin: const EdgeInsets.only(left: 20,right: 200,top: 10,bottom: 0),
                    child:Text("Amnesties",style: TextStyle(
                        fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                    ),),
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 15,top: 0,right: 1),
                      padding: const EdgeInsets.only(top: 5),
                      height: 60,
                      // color: Colors.grey,
                      child:Column(
                        spacing: 10,
                        children: [
                          Row(
                            children: [
                              Image.asset("assets/images/Residential__1.png",height: 13,),
                              Text(" Swimming Pool ",style: TextStyle(
                                  fontSize: 12,letterSpacing: 0.5
                              ),),
                              Image.asset("assets/images/bed.png",height: 13,),
                              Text(" Balcony/Terrace ",style: TextStyle(
                                  fontSize: 12,letterSpacing: 0.5
                              ),),
                              Image.asset("assets/images/bath.png",height: 13),
                              Text(" Barbeque Area ",style: TextStyle(
                                fontSize: 12,letterSpacing: 0.5,
                              ),),
                            ],
                          ),
                          Row(
                            //spacing: 10,
                            children: [
                              Image.asset("assets/images/Residential__1.png",height: 13,),
                              Text(" Elevators ",style: TextStyle(
                                  fontSize: 12,letterSpacing: 0.5
                              ),),
                              Image.asset("assets/images/bed.png",height: 13,),
                              Text(" Gym ",style: TextStyle(
                                  fontSize: 12,letterSpacing: 0.5
                              ),),
                              Image.asset("assets/images/bath.png",height: 13),
                              Text("Parking Space ",style: TextStyle(
                                fontSize: 12,letterSpacing: 0.5,
                              ),),
                              Image.asset("assets/images/messure.png",height: 13),
                              Text("Pet Allowed ",style: TextStyle(
                                fontSize: 12,letterSpacing: 0.5,
                              ),),
                              Image.asset("assets/images/messure.png",height: 13),
                              Text("Security ",style: TextStyle(
                                fontSize: 12,letterSpacing: 0.5,
                              ),),
                            ],
                          )
                        ],
                      )

                  ),
                  Container(
                    height: screenSize.height*0.05,
                    width: screenSize.width*0.9,
                    margin: const EdgeInsets.only(left: 20,right: 20,top: 15),
                    padding: const EdgeInsets.only(top: 8),
                    // color: Colors.grey,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red,
                          offset: const Offset(
                            0.0,
                            0.0,
                          ),
                          blurRadius: 0.0,
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
                    child: Text("Show All Amenities(8) ",textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,fontSize: 17,letterSpacing: 0.5
                      ),),
                  ),
                  Container(
                    height: 30,
                    width: 200,
                    // color: Colors.grey,
                    margin: const EdgeInsets.only(left: 20,right: 200,top: 15,bottom: 0),
                    child:Text("Project Information",style: TextStyle(
                        fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                    ),),
                  ),
                  Container(
                    height: 80,
                    margin: const EdgeInsets.only(left: 20,right: 20,top: 10),
                    // color: Colors.grey,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text("Project            "),
                            Text("Mag eye          ",style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                            Text("Delivery Date  "),
                            Text("25th Jan 2025",style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),)
                          ],
                        ),
                        Padding(padding: const EdgeInsets.only(left: 70),
                          child:  Column(
                            children: [
                              Text("Developer                               "),
                              Text("MAG Property Development",style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                              Text("Property type                         "),
                              Text("Townhouse,Apartment         ",style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),)
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    height: screenSize.height*0.17,
                    margin: const EdgeInsets.only(left: 20,right: 20,top: 20),
                     color: Colors.grey,
                    child: Row(
                      spacing: 1,
                      children: [
                        SizedBox(
                          height: 150,
                          width: 170,
                          child:   Image.asset("assets/images/image3.png",height: 100,
                            fit: BoxFit.fill,),
                        ),

                        Column(
                          children: [
                            Container(
                                height: 25,
                                margin: const EdgeInsets.only(top: 30,left: 0,right: 55),
                                padding: const EdgeInsets.only(top: 4,left: 5,right: 0),
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
                                child:
                                Padding(padding: const EdgeInsets.only(left: 1),
                                    child:   Text("Completed    ",style: TextStyle(
                                        letterSpacing: 0.5,color: Colors.white,fontSize: 12
                                    ),textAlign: TextAlign.center,)
                                )
                            ),
                            Padding(padding: const EdgeInsets.only(top: 10),
                              child: Text("       MAG Property Development        ",style: TextStyle(
                                  fontSize: 10,fontWeight: FontWeight.bold
                              ),),
                            ),
                            Container(
                              height: 30,
                              width: 145,
                              margin: const EdgeInsets.only(left: 15,right: 10,top: 15),
                              padding: const EdgeInsets.only(top: 8),
                              // color: Colors.grey,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red,
                                    offset: const Offset(
                                      0.0,
                                      0.0,
                                    ),
                                    blurRadius: 0.0,
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
                              child: Text("View All Project Details",textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: 0.5,fontSize: 11,fontWeight: FontWeight.bold
                                ),),
                            ),
                          ],
                        )

                      ],
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 200,
                    // color: Colors.grey,
                    margin: const EdgeInsets.only(left: 20,right: 200,top: 15,bottom: 0),
                    child:Text("Location & nearby",style: TextStyle(
                        fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                    ),),
                  ),
                  Container(
                    height: 130,
                    margin: const EdgeInsets.only(top: 15,left: 20,right: 20),
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
                  ),
                  Container(
                    height: 30,
                    width: 200,
                    // color: Colors.grey,
                    margin: const EdgeInsets.only(left: 20,right: 200,top: 20,bottom: 0),
                    child:Text("Provided by",style: TextStyle(
                        fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                    ),),
                  ),
                  Container(
                    height: 270,
                    margin: const EdgeInsets.only(left: 20,top: 15,right: 20),
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
                            imageUrl: (productModels!.media),
                            fit: BoxFit.cover,
                            height: 100,
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(top: 10),
                          child: Text(productModels!.agent.name.toString(),style: TextStyle(
                              fontWeight: FontWeight.bold,letterSpacing: 0.5
                          ),),
                        ),
                        Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(top: 5,left: 80),
                              child: Text(productModels!.agent.rating.toString()),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 5,left: 5),
                              child: Row(
                                children: [
                                  Icon(Icons.star,color: Colors.yellowAccent,),
                                  Icon(Icons.star,color: Colors.yellowAccent,),
                                  Icon(Icons.star,color: Colors.yellowAccent,),
                                  Icon(Icons.star,color: Colors.yellowAccent,),
                                  Icon(Icons.star,color: Colors.yellowAccent,),
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
                        Container(
                          height: 35,
                          width: 220,
                          margin: const EdgeInsets.only(left: 15,right: 10,top: 15),
                          padding: const EdgeInsets.only(top: 8),
                          // color: Colors.grey,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusDirectional.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red,
                                offset: const Offset(
                                  0.0,
                                  0.0,
                                ),
                                blurRadius: 0.0,
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
                          child: Text("See Agents Properties(16)",textAlign: TextAlign.center,
                            style: TextStyle(
                                letterSpacing: 0.5,fontSize: 13,fontWeight: FontWeight.bold
                            ),),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: screenSize.height*0.3,
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 18,right: 14,top: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: const Offset(
                            0.0,
                            0.0,
                          ),
                          blurRadius: 0.0,
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
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.only(left: 0,top: 5,right: 160),
                          child: Text("Regulatory Information  ",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                          ),textAlign: TextAlign.left,),
                        ),
                        Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(left: 5,top: 5),
                              child: Text("Reference:",style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 65,top: 5),
                              child: Text(productModels!.regulatoryInfo.reference.toString(),style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 10,top: 5),
                              child: Text("Listed:",style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 10,top: 5),
                              child: Text(productModels!.regulatoryInfo.listed.toString(),style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(left: 5,top: 5),
                              child: Text("Brocker License:",style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 27,top: 5),
                              child: Text(productModels!.regulatoryInfo.brokerLicense.toString(),style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 15,top: 5),
                              child: Text("Agent Licence:",style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 10,top: 5),
                              child: Text(productModels!.regulatoryInfo.agentLicense.toString(),style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),

                          ],
                        ),
                        Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(left: 5,top: 5),
                              child: Text("OLD Permit Number:",style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 1,top: 5),
                              child: Text(productModels!.regulatoryInfo.dldPermitNumber.toString(),style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),

                          ],
                        ),
                        Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(left: 5,top: 5),
                              child: Text("Zone Name:",style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 1,top: 5),
                              child: Text(productModels!.regulatoryInfo.zoneName.toString(),overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13,
                                ),),),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 90,
                          width: 110,
                          color: Colors.grey,
                        ),
                        Padding(padding: const EdgeInsets.only(top: 10),
                          child: Text("OLD Permit Number",style: TextStyle(fontWeight: FontWeight.bold),),)
                      ],
                    ),
                  ),
                  Container(
                    height: 30,
                    width: double.infinity,
                    // color: Colors.grey,
                    margin: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 0),
                    child:Text("Recommended Properties",style: TextStyle(
                        fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                    ),),
                  ),
                  /*Padding(padding: const EdgeInsets.only(top: 10,left: 20,right: 0),
                    child: Container(
                      margin: const EdgeInsets.only(left: 0,top: 0,right: 0),
                      height: 200,
                      child: ListView(
                        padding: const EdgeInsets.only(right: 10),
                        scrollDirection: Axis.horizontal,
                        children: [
                      Card(
                        color: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0,top: 1,right: 5),
                        child: Column(
                          children: [
                            AspectRatio(
                                aspectRatio: 1.5,
                            child: Image.asset("assets/images/image 1.png",
                              fit: BoxFit.cover,
                              height: 100,),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 5),
                              child: ListTile(
                                title: Text("AED 134677",style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 18,height: 1.4
                                ),),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(padding: const EdgeInsets.only(left: 1,right: 5,top: 0),
                                  child:  Image.asset("assets/images/map.png",height: 14,),
                                ),
                                Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                  child: Text("sdfghjkgsdfghjxcvbnmdfghj",style: TextStyle(
                                      fontWeight: FontWeight.bold,fontSize: 13,height: 1.4,
                                      overflow: TextOverflow.visible
                                  ),),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ),
                      )
                        ],
                      ),
                    ),
                  ),*/

                  SizedBox(height: 100,)
                ]
            )
        )
    );
  }
  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
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

              Navigator.push(context, MaterialPageRoute(builder: (context)=> MyApp()));

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
              child: Icon(Icons.call_outlined,color: Colors.red,)
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
              child: Icon(Icons.call_outlined,color: Colors.green,)

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
              child: Icon(Icons.mail,color: Colors.red,)

          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {

              Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));

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