import 'package:drawerdemo/screen/home.dart';
import 'package:drawerdemo/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main(){
  runApp(const Property_Detail());
}
class Property_Detail extends StatelessWidget {
  const Property_Detail( {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Property_DetailDemo(),
    );
  }
}

class Property_DetailDemo extends StatefulWidget {
  @override
  _Property_DetailDemoState createState() => _Property_DetailDemoState();
}
class _Property_DetailDemoState extends State<Property_DetailDemo> {
  int pageIndex = 0;

  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        child: Container(
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
                  Padding(padding: const EdgeInsets.only(top: 23,left: 15,right: 0),
                  child: Container(
                    width: double.infinity,
                    height: 30,
                   // color: Colors.grey,
                    margin: const EdgeInsets.only(left: 5,top: 5),
                    child: Text("Sky Edition at Sea heaven",textAlign: TextAlign.left,style: TextStyle(
                      fontSize: 23,fontWeight: FontWeight.bold,letterSpacing: 0.5
                    ),),
                  ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10,left: 15,right: 0),
                    child: Container(
                      width: double.infinity,
                      height: 30,
                      //color: Colors.grey,
                      margin: const EdgeInsets.only(left: 5,top: 1),
                      child: Row(
                        children: [
                          Text("Launch prize",
                            textAlign: TextAlign.left,style: TextStyle(
                                letterSpacing: 0.5,fontSize: 15,fontWeight: FontWeight.bold
                            ),),
                          Text(" AED 12,750",
                            textAlign: TextAlign.left,style: TextStyle(
                                letterSpacing: 0.5,fontSize: 18,fontWeight: FontWeight.bold
                            ),),
                        ],
                      )

                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5,left: 15,right: 0),
                    child: Container(
                      width: double.infinity,
                      height: 100,
                     // color: Colors.grey,
                      margin: const EdgeInsets.only(left: 5,top: 5),
                      child: Text("Azco Real Estate is thrilled to offer this spacious 2 "
                          "Bedroom Apartment in AAA Residence located in Jumeirah"
                          "village Circle,for rent. Offer this Spacious 2 Bedroom Apartment in AAA Residence located in "
                          "Jumeirah village Circle,for rent.",
                        textAlign: TextAlign.left,style: TextStyle(
                          letterSpacing: 0.2,fontWeight: FontWeight.bold,color: Colors.black87
                      ),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15,left: 15,right: 15),
                    child: Container(
                      width: 500,
                      height: 130,
                      margin: const EdgeInsets.only(left: 5,top: 5),
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
                      child: Row(
                        children: [
                          Padding(padding: const EdgeInsets.only(left: 40,right: 0,top: 0,bottom: 0),
                          child: Container(
                            margin: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                            width: 100,
                            height: 50,
                            //color: Colors.grey,
                            child: Column(
                              children: [
                                Text("SOBHA",style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,letterSpacing: 0.5
                                ),textAlign: TextAlign.center,),
                                Text("REALITY",style: TextStyle(
                                    fontSize: 7,
                                    letterSpacing: 0.5,height: 0.5,fontWeight: FontWeight.bold
                                ),textAlign: TextAlign.center,),
                              ],
                            ),
                          ),
                          ),
                          Padding(padding: const EdgeInsets.only(left: 35,right: 10,top: 0,bottom: 0),
                            child: Container(
                              margin: const EdgeInsets.only(left:1,right: 10,top: 5,bottom: 5),
                              width: 120,
                              height: 80,
                             // color: Colors.grey,
                              child: Column(
                                children: [
                                  Text("Developer",style: TextStyle(
                                      fontSize: 15,letterSpacing: 0.5
                                  ),textAlign: TextAlign.center,),
                                  Text("Sobha Reality",style: TextStyle(
                                      fontSize: 18,
                                      letterSpacing: 0.5,fontWeight: FontWeight.bold
                                  ),textAlign: TextAlign.center,),
                                  Text("View Developer Details",style: TextStyle(
                                      fontSize: 10,color: Colors.blue,height: 1.8,
                                      letterSpacing: 0.5,
                                  ),textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left:0,right: 205,top: 15,bottom: 0),
                    width: 150,
                    height: 270,
                   // color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.only(left: 0,top: 5),
                          child: Text("Key Information",style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 18,
                            letterSpacing: 0.5,
                          ),textAlign: TextAlign.left,),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 0,top: 5,right: 63),
                          child: Text("Delivery date",style: TextStyle(
                            letterSpacing: 0.5,color: Colors.grey,fontSize: 12,
                          ),textAlign: TextAlign.left,),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 0,top: 5,right: 32),
                          child: Text("December 2026",style: TextStyle(
                            letterSpacing: 0.5,fontWeight: FontWeight.bold,
                          ),textAlign: TextAlign.left,),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 5,top: 5,right: 60),
                          child: Text("Property Type",style: TextStyle(
                            letterSpacing: 0.5,color: Colors.grey,fontSize: 12,
                          ),textAlign: TextAlign.left,),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 0,top: 5,right: 67),
                          child: Text("Apartment",style: TextStyle(
                            letterSpacing: 0.5,fontWeight: FontWeight.bold
                          ),textAlign: TextAlign.left,),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 0,top: 5,right: 60),
                          child: Text("Payment Plan",style: TextStyle(
                            letterSpacing: 0.5,color: Colors.grey,fontSize: 12,
                          ),textAlign: TextAlign.left,),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 0,top: 5,right: 115),
                          child: Text("Yes",style: TextStyle(
                            letterSpacing: 0.5,fontWeight: FontWeight.bold,
                          ),textAlign: TextAlign.left,),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 0,top: 5,right: 43),
                          child: Text("Government Fee",style: TextStyle(
                            letterSpacing: 0.5,color: Colors.grey,fontSize: 12,
                          ),textAlign: TextAlign.left,),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 0,top: 5,right: 115),
                          child: Text("4%",style: TextStyle(
                            letterSpacing: 0.5,fontWeight: FontWeight.bold,
                          ),textAlign: TextAlign.left,),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 0,top: 20,right: 20),
                          child: Text("Payment Plan",style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 18,
                            letterSpacing: 0.5,
                          ),textAlign: TextAlign.left,),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5,left: 15,right: 15),
                    child: Container(
                      width: 500,
                      height: 130,
                      margin: const EdgeInsets.only(left: 5,top: 5),
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
                            color: Color(0xFFEEEEEE),
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ],
                      ),
                            child: Container(
                              margin: const EdgeInsets.only(left: 100,right: 100,top: 32,bottom: 32),
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                             // color: Colors.grey,
                              child: Column(
                                children: [
                                  Text("20%",style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,letterSpacing: 0.5
                                  ),textAlign: TextAlign.center,),
                                  Text("Down Payment",style: TextStyle(
                                      fontSize: 13,
                                      letterSpacing: 0.5,height: 1.0,
                                      //fontWeight: FontWeight.bold
                                  ),textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                         // ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10,left: 15,right: 15),
                    child: Container(
                      width: 500,
                      height: 130,
                      margin: const EdgeInsets.only(left: 5,top: 5),
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
                            color: Color(0xFFEEEEEE),
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 100,right: 100,top: 32,bottom: 32),
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        // color: Colors.grey,
                        child: Column(
                          children: [
                            Text("60%",style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,letterSpacing: 0.5
                            ),textAlign: TextAlign.center,),
                            Text("During Construction",style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 0.5,height: 1.0,
                              //fontWeight: FontWeight.bold
                            ),textAlign: TextAlign.center,),
                          ],
                        ),
                      ),
                      // ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10,left: 15,right: 15),
                    child: Container(
                      width: 500,
                      height: 130,
                      margin: const EdgeInsets.only(left: 5,top: 5),
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
                            color: Color(0xFFEEEEEE),
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 100,right: 100,top: 32,bottom: 32),
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        // color: Colors.grey,
                        child: Column(
                          children: [
                            Text("20%",style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,letterSpacing: 0.5
                            ),textAlign: TextAlign.center,),
                            Text("On Handover",style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 0.5,height: 1.0,
                              //fontWeight: FontWeight.bold
                            ),textAlign: TextAlign.center,),
                          ],
                        ),
                      ),
                      // ),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 20,left: 0,right: 210),
                  child: Text("Project Timeline",style: TextStyle(
                    fontWeight: FontWeight.bold,fontSize: 18,
                    letterSpacing: 0.5,
                  ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    width: double.infinity,
                    height: 220,
                    margin: const EdgeInsets.only(left: 20,top: 20,right: 20,bottom: 0),
                   // color: Colors.grey,
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
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.only(top: 20),
                            child: Text("Project Announcement")
                        ),
                        Padding(padding: const EdgeInsets.only(top: 10),
                            child: Text("01.01.2025",style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),)
                        ),
                        Padding(padding: const EdgeInsets.only(top: 15),
                            child: Text("Construction Started")
                        ),
                        Padding(padding: const EdgeInsets.only(top: 10),
                            child: Text("21.01.2025",style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),)
                        ),
                        Padding(padding: const EdgeInsets.only(top: 15),
                            child: Text("Expected Completion")
                        ),
                        Padding(padding: const EdgeInsets.only(top: 10,bottom: 10),
                            child: Text("21.01.2025",style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),)
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 20,left: 0,right: 170),
                    child: Text("Units from Developer",style: TextStyle(
                      fontWeight: FontWeight.bold,fontSize: 18,
                      letterSpacing: 0.5,
                    ),textAlign: TextAlign.left,),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 5,left: 0,right: 270),
                    child: Text("Apartments",style: TextStyle(
                      letterSpacing: 0.5,
                    ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    width: double.infinity,
                    height: 100,
                    padding: const EdgeInsets.only(left: 2,top: 0,right: 2),
                    margin: const EdgeInsets.only(left: 18,top: 18,right: 20),
                   // color: Colors.grey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 220,
                              padding: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.circular(10.0),
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
                              child: Row(
                                children: [
                                  Padding(padding: const EdgeInsets.only(left: 10),
                                  child: Text("3 beds",style: TextStyle(
                                    color: Colors.black
                                  ),),
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 135,right: 5),
                                    child: Icon(Icons.arrow_forward_ios_rounded,color: Colors.red,size: 15,)
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 120,
                              margin: const EdgeInsets.only(left: 10,right: 0),
                              padding: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.circular(8.0),
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
                              child: Row(
                                children: [
                                  Padding(padding: const EdgeInsets.only(left: 25,right: 5),
                                      child: Icon(Icons.call,color: Colors.red,size: 15,)
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 1),
                                    child: Text("Call?",style: TextStyle(
                                        color: Colors.black
                                    ),),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 220,
                              margin: const EdgeInsets.only(top: 15),
                              padding: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.circular(10.0),
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
                              child: Row(
                                children: [
                                  Padding(padding: const EdgeInsets.only(left: 10),
                                    child: Text("4 beds",style: TextStyle(
                                        color: Colors.black
                                    ),),
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 135,right: 5),
                                      child: Icon(Icons.arrow_forward_ios_rounded,color: Colors.red,size: 15,)
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 120,
                              margin: const EdgeInsets.only(left: 10,right: 0,top: 15),
                              padding: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.circular(8.0),
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
                              child: Row(
                                children: [
                                  Padding(padding: const EdgeInsets.only(left: 25,right: 5),
                                      child: Icon(Icons.call,color: Colors.red,size: 15,)
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 1),
                                    child: Text("Call?",style: TextStyle(
                                        color: Colors.black
                                    ),),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15,left: 15,right: 0),
                    child: Container(
                      width: double.infinity,
                      height: 25,
                      //color: Colors.grey,
                      margin: const EdgeInsets.only(left: 5,top: 5),
                      child: Text("About the Project",
                        textAlign: TextAlign.left,style: TextStyle(
                            letterSpacing: 0.5,fontSize: 18,fontWeight: FontWeight.bold
                        ),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 1,left: 15,right: 0),
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      // color: Colors.grey,
                      margin: const EdgeInsets.only(left: 5,top: 5),
                      child: Text("Azco Real Estate is thrilled to offer this spacious 2 "
                          "Bedroom Apartment in AAA Residence located in Jumeirah"
                          "village Circle,for rent. Offer this Spacious 2 Bedroom Apartment in AAA Residence located in "
                          "Jumeirah village Circle,for rent.",
                        textAlign: TextAlign.left,style: TextStyle(
                            letterSpacing: 0.2,fontWeight: FontWeight.bold,color: Colors.black87
                        ),),
                    ),
                  ),
                  SizedBox(
                    height: 100,
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
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> MyApp()));
              });
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
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
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
class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

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
  const Page2({Key? key}) : super(key: key);

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
  const Page3({Key? key}) : super(key: key);

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
  const Page4({Key? key}) : super(key: key);

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