import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:flutter/material.dart';

import '../utils/fav_login.dart';
import '../utils/fav_logout.dart';

class Advertising extends StatefulWidget {
  Advertising({super.key,});


  @override
  State<StatefulWidget> createState() => new _AdvertisingState();
}

class _AdvertisingState extends State<Advertising> {

  int pageIndex = 0;
  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

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
  void initState() {
    readData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
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
                              children: [
                                GestureDetector(
                                onTap: (){
                                  setState(() {
                                    if(token == ''){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
                                    }
                                    else{
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

                                    }
                                  });
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
                                  child: Text("Advertise",style: TextStyle(
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
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
                    height: screenSize.height*0.06,
                    width: screenSize.width*0.38,
                    //color: Colors.grey,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Image.asset("assets/images/app_icon.png",height: 22,alignment: Alignment.center,),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Image.asset("assets/images/logo-text.png",height: 22,alignment: Alignment.center,),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 5),
                    height: screenSize.height*0.04,
                    width: screenSize.width*0.9,
                    //color: Colors.grey,
                    child: Text("Advertise?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,fontSize: 25,
                        letterSpacing: 0.5,
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    height: screenSize.height*0.21,
                    width: screenSize.width*0.9,
                    margin: const EdgeInsets.only(left: 20,top: 15,right: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset: Offset(4, 4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          offset: Offset(-4, -4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text("Hurry!",style: TextStyle(
                              fontWeight: FontWeight.bold,fontSize: 25,color: Colors.red
                          ),),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Text("Enjoy a  ",style: TextStyle(
                                  fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black
                              ),textAlign: TextAlign.center,),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Text("FREE  ",style: TextStyle(
                                  fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue
                              ),textAlign: TextAlign.center,),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text("Subscription for all of   ",style: TextStyle(
                                  fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black
                              ),textAlign: TextAlign.center,),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Text("2025!  ",style: TextStyle(
                                  fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue
                              ),textAlign: TextAlign.center,),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: ElevatedButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                          },style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(8)),),),
                              child: Text("Sign up Now!",style: TextStyle(color: Colors.white,fontSize: 17),)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 20),
                    height: screenSize.height*0.03,
                    width: screenSize.width*0.9,
                    // color: Colors.grey,
                    child: Text("Akarat Membership Plans",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.05,
                    width: screenSize.width*0.9,
                    // color: Colors.grey,
                    child: Text("Find the Perfect Plan to Grow Your Real Estate Business!",style: TextStyle(
                        fontSize: 15.5,letterSpacing: 0.5
                    ),),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
                    height: screenSize.height*0.03,
                    width: screenSize.width*0.9,
                    // color: Colors.grey,
                    child: Text("Why Choose Akarat Membership?",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.18,
                    width: screenSize.width*0.9,
                    // color: Colors.grey,
                    child: Text("With Akarat, you gain access to a powerful platform that connects your "
                        "listings to thousands of property seekers across the UAE. Whether you're just starting "
                        "or looking to scale, our membership plans are designed to meet your business needs."
                      ,style: TextStyle(
                        fontSize: 15.5,letterSpacing: 0.5
                    ),),
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
              padding: const EdgeInsets.only(top: 0,right: 5,bottom: 5),
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
            child: IconButton(
                padding: EdgeInsets.only(left: 5,top: 7),
                onPressed: (){
                  setState(() {
                    if(token == ''){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> Fav_Logout()));
                    }
                    else if(token.isNotEmpty){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> Fav_Login()));
                    }
                  });
                }, icon: Icon(Icons.favorite_border,color: Colors.red,)
            ),
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

              if(token == ''){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
              }
              else{
                Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

              }

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