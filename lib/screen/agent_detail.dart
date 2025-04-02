import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../model/productmodel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class Agent_Detail extends StatefulWidget {
  const Agent_Detail({super.key, required this.data});
  final String data;
  @override
  State<Agent_Detail> createState() => _Agent_DetailState();
}
class _Agent_DetailState extends State<Agent_Detail> {
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
                              GestureDetector(
                                onTap: (){
                                 // Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                     // AboutAgent(data:productModels!.data!.id.toString())));
                                },
                                child: Container(
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
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 320,top: 5,bottom: 0,),
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
                              /*Container(
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
                              ),*/
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      height: screenSize.height*0.5,
                      margin: const EdgeInsets.only(left: 0,right: 0,top: 0),
                      child:  ListView.builder(
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
                  ) ,
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(left: 20,top: 10,right: 10,bottom: 0),
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
                  Padding(padding: const EdgeInsets.only(left: 20,right: 0,top: 10,bottom: 0),
                      child:Row(
                        children: [
                          Text(productModels!.data!.price.toString(),style: TextStyle(
                              fontSize: 25,fontWeight: FontWeight.bold,letterSpacing: 0.5
                          ),),
                          Text("  AED",style: TextStyle(
                              fontSize: 19,letterSpacing: 0.5
                          ),),
                        ],
                      )
                  ),
                  /* Padding(
                      padding: const EdgeInsets.only(left: 20,right: 0,top: 5,bottom: 0),
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
                  ),*/
                  Container(
                      margin: const EdgeInsets.only(left: 20,top: 5,right: 10),
                      height: 40,
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
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Image.asset("assets/images/bath.png",height: 20),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text('${productModels!.data!.bathrooms}  baths',style: TextStyle(
                              fontSize: 14,letterSpacing: 0.5,
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
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
                  Container(
                    height: screenSize.height*0.08,
                    // color: Colors.grey,
                    padding: const EdgeInsets.only(left: 20,right: 0,top: 1,bottom: 0),
                    child:
                    Text(productModels!.data!.title.toString(),style: TextStyle(
                        fontSize: 25,fontWeight: FontWeight.bold,letterSpacing: 0.5
                    ),),

                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5,left: 15,right: 10),
                    child: Container(
                        width: double.infinity,
                        height: screenSize.height*0.2,
                        //color: Colors.grey,
                        margin: const EdgeInsets.only(left: 5,top: 5),
                        child:  ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: <Widget>[
                              Text(productModels!.data!.description.toString(),
                                textAlign: TextAlign.left,style: TextStyle(
                                    letterSpacing: 0.2,fontWeight: FontWeight.bold,color: Colors.black87
                                ),),
                            ]
                        )

                    ),
                  ),
                  /* Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
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
                  ),*/
                  Padding(
                      padding: const EdgeInsets.only(left: 20,right: 0,top: 20,bottom: 0),
                      child:Row(
                        spacing: 5,
                        children: [
                          Text("Posted On:",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                          ),),
                          Text(productModels!.data!.postedOn.toString(),style: TextStyle(
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
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(productModels!.data!.propertyType.toString(),style: TextStyle(
                                fontSize: 14,letterSpacing: 0.5
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Image.asset("assets/images/bed.png",height: 15,),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('${productModels!.data!.bedrooms} beds',style: TextStyle(
                                fontSize: 14,letterSpacing: 0.5
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Image.asset("assets/images/bath.png",height: 15),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('${productModels!.data!.bathrooms} baths',style: TextStyle(
                              fontSize: 14,letterSpacing: 0.5,
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Image.asset("assets/images/messure.png",height: 15),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('${productModels!.data!.squareFeet} sqft',style: TextStyle(
                              fontSize: 14,letterSpacing: 0.5,
                            ),),
                          ),
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
                      margin: const EdgeInsets.only(left: 20,top: 0,right: 1),
                      padding: const EdgeInsets.only(top: 5),
                      height: screenSize.height*0.11,
                      // color: Colors.grey,
                      child:Column(
                        spacing: 15,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              Image.asset("assets/images/Residential__1.png",height: 15,),
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Text(" Swimming Pool ",style: TextStyle(
                                    fontSize: 14,letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Image.asset("assets/images/bed.png",height: 15,),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Text(" Balcony/Terrace ",style: TextStyle(
                                    fontSize: 14,letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Image.asset("assets/images/bed.png",height: 15,),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Text(" Gym ",style: TextStyle(
                                    fontSize: 14,letterSpacing: 0.5
                                ),),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              Image.asset("assets/images/bath.png",height: 15),
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Text(" Barbeque Area ",style: TextStyle(
                                  fontSize: 14,letterSpacing: 0.5,
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Image.asset("assets/images/Residential__1.png",height: 15,),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Text(" Elevators ",style: TextStyle(
                                    fontSize: 14,letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Image.asset("assets/images/bath.png",height: 15),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Text("Parking Space ",style: TextStyle(
                                  fontSize: 14,letterSpacing: 0.5,
                                ),),
                              ),
                            ],
                          ),


                          Row(
                            spacing: 5,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Image.asset("assets/images/messure.png",height: 15),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Text("Pet Allowed ",style: TextStyle(
                                  fontSize: 14,letterSpacing: 0.5,
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Image.asset("assets/images/messure.png",height: 15),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Text("Security ",style: TextStyle(
                                  fontSize: 14,letterSpacing: 0.5,
                                ),),
                              ),
                            ],
                          ),
                        ],
                      )

                  ),
                  /*  Container(
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
                  ),*/
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
                    height: screenSize.height*0.12,
                    margin: const EdgeInsets.only(left: 10,right: 5,top: 10),
                    // color: Colors.grey,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text("Project            "),
                            Row(
                              spacing: 5,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0,right: 27),
                                  child: Text(productModels!.data!.project.toString(),style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                Text("")
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text("Delivery Date  "),
                            ),
                            Row(
                              spacing: 5,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:10,top: 4.0,right: 27),
                                  child: Text(productModels!.data!.deliveryDate.toString(),style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),textAlign: TextAlign.left,),
                                ),
                                Text("  "),

                              ],
                            )
                          ],
                        ),
                        Padding(padding: const EdgeInsets.only(left: 70),
                          child:  Column(
                            children: [
                              Text("Developer                               "),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(productModels!.data!.developer.toString(),style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text("Property type                         "),
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0,right: 10),
                                    child: Text(productModels!.data!.propertyType.toString(),style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                  Text("     "),
                                  Text("     "),
                                  Text("     "),
                                  Text("      "),
                                ],
                              )
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    height: screenSize.height*0.17,
                    margin: const EdgeInsets.only(left: 20,right: 20,top: 20),
                    // color: Colors.grey,
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
                              child: Text(productModels!.data!.developer.toString(),style: TextStyle(
                                  fontSize: 12,fontWeight: FontWeight.bold
                              ),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: screenSize.height*0.04,
                                width: screenSize.width*0.4,
                                // margin: const EdgeInsets.only(left: 15,right: 10,top: 15),
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
                                child: Text("View All Project Details",textAlign: TextAlign.center,
                                  style: TextStyle(
                                      letterSpacing: 0.5,fontSize: 11,fontWeight: FontWeight.bold
                                  ),),
                              ),
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
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(25.0657, 55.2030), // Updated
                            initialZoom: 13.0, // Updated
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
                                  child: Icon(Icons.location_pin, color: Colors.red, size: 40), // Fixed
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 20,
                          left: 60,
                          right: 60,
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "AAA Residence, JVC District 13,\nJumeirah Village Circle (JVC), Dubai",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  // SizedBox(height: 4),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Implement map navigation
                                    },
                                    child: Text("View on map"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(left: 5,top: 5,right: 0),
                              child: Text("Regulatory Information  ",style: TextStyle(
                                  fontSize: 16,letterSpacing: 0.5,fontWeight: FontWeight.bold
                              ),textAlign: TextAlign.left,),
                            ),
                            Text("")
                          ],
                        ),
                        Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(left: 5,top: 5),
                              child: Text("Reference:",style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 65,top: 5),
                              child: Text(productModels!.data!.regulatoryInfo!.reference.toString(),style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 10,top: 5),
                              child: Text("Listed:",style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 10,top: 5),
                              child: Text(productModels!.data!.regulatoryInfo!.listed.toString(),style: TextStyle(
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
                              child: Text(productModels!.data!.regulatoryInfo!.brokerLicense.toString(),style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 15,top: 5),
                              child: Text("Agent Licence:",style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13
                              ),),),
                            Padding(padding: const EdgeInsets.only(left: 10,top: 5),
                              child: Text(productModels!.data!.regulatoryInfo!.agentLicense.toString(),style: TextStyle(
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
                              child: Text(productModels!.data!.regulatoryInfo!.dldPermitNumber.toString(),style: TextStyle(
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
                              child: Text(productModels!.data!.regulatoryInfo!.zoneName.toString(),overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  letterSpacing: 0.5,fontSize: 13,
                                ),),),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: screenSize.height*0.1,
                          width: 110,
                          // color: Colors.grey,
                          child: Image.asset("assets/images/dld.png",fit: BoxFit.fill,),
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
                  SizedBox(
                    height: 250, // Adjust height based on card size
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: productModels?.data?.recommendedProperties?.length ?? 0,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 200, // Adjust width for horizontal layout
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                      child: Image.network(
                                        productModels!.data!.recommendedProperties![index].media![index].originalUrl.toString(),
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Icon(Icons.favorite_border, color: Colors.red),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productModels!.data!.recommendedProperties![index].price.toString()
                                        ,style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.bed, size: 16, color: Colors.red),
                                          SizedBox(width: 4),
                                          Text("${productModels!.data!.recommendedProperties![index].bedrooms} beds"),
                                          SizedBox(width: 8),
                                          Icon(Icons.square_foot, size: 16, color: Colors.red),
                                          SizedBox(width: 4),
                                          Text("${productModels!.data!.recommendedProperties![index].squareFeet} sqft"),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${productModels!.data!.recommendedProperties![index].location} ",
                                        style: TextStyle(fontSize: 12, color: Colors.black),
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
                    height: 10,
                  )
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
              child: Image.asset("assets/images/whats.png",height: 20,)

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