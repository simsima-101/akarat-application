import 'dart:async';

import 'package:drawerdemo/screen/home.dart';
import 'package:drawerdemo/screen/profile_login.dart';
import 'package:flutter/material.dart';

class Support extends StatefulWidget {
  Support({super.key,});


  @override
  State<StatefulWidget> createState() => new _SupportState();
}

class _SupportState extends State<Support> {

  int pageIndex = 0;
  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: buildMyNavBar(context),
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Container(
                    height: screenSize.height*0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(2.0),
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
                      ],),
                    child:  Stack(
                      // alignment: Alignment.topCenter,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 25),
                          child: Container(
                            height: screenSize.height*0.07,
                            width: double.infinity,
                            // color: Color(0xFFEEEEEE),
                            child:   Row(
                              children: [GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Profile_Login()));
                                },
                                child:   Container(
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
                                  child: Image.asset("assets/images/ar-left.png",
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.contain,),
                                ),
                              ),
                                SizedBox(
                                  width: screenSize.width*0.23,
                                ),
                                Padding(padding: const EdgeInsets.all(8.0),
                                  child: Text("Contact Us",style: TextStyle(
                                      fontWeight: FontWeight.bold,fontSize: 20
                                  ),),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 25),
                    height: screenSize.height*0.05,
                    width: screenSize.width*0.9,
                   // color: Colors.grey,
                    child: Text("Ask us anything?",textAlign: TextAlign.left
                      ,style: TextStyle(
                      fontSize: 25,fontWeight: FontWeight.bold,letterSpacing: 0.5

                    ),),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
                   // color: Colors.grey,
                    height: screenSize.height*0.75,
                    width: screenSize.width*0.9,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,right: 300,top: 8,bottom: 8),
                          child: Text("Name",textAlign: TextAlign.left,style: TextStyle(
                            fontSize: 15,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
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
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,right: 240,top: 8,bottom: 8),
                          child: Text("Email Address",textAlign: TextAlign.left,style: TextStyle(
                              fontSize: 15,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
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
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,right: 240,top: 8,bottom: 8),
                          child: Text("Phone Number",textAlign: TextAlign.left,style: TextStyle(
                              fontSize: 15,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
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
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,right: 280,top: 8,bottom: 8),
                          child: Text("Subject",textAlign: TextAlign.left,style: TextStyle(
                              fontSize: 15,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
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
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,right: 280,top: 8,bottom: 8),
                          child: Text("Message",textAlign: TextAlign.left,style: TextStyle(
                              fontSize: 15,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
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
                            child: TextField(
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Container(
                          width: screenSize.width*0.9,
                          height: screenSize.height*0.1,
                          child: Padding(padding: const EdgeInsets.only(top: 40,left: 10,right: 20),
                            child: ElevatedButton(
                                onPressed: (){
                             // Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                            },style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius:  BorderRadius.all(
                                    Radius.circular(8)),),),
                                child: Text("Send Email",
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 15),)),
                          ),
                        ),
                      ],
                    ),
                  ),
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
              child: Icon(Icons.favorite_border,color: Colors.red,)
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
              child: Icon(Icons.add_location_rounded,color: Colors.red,)

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
              child: Icon(Icons.chat,color: Colors.red,)

          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {

              //   Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));

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