import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:flutter/material.dart';
import '../utils/fav_login.dart';
import '../utils/fav_logout.dart';

class Privacy extends StatefulWidget {
  Privacy({super.key,});


  @override
  State<StatefulWidget> createState() => new _PrivacyState();
}

class _PrivacyState extends State<Privacy> {

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
                      children: [GestureDetector(
                        onTap: (){
                          setState(() {
                            if(token == ''){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
                            }
                            else{
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

                            }
                          });                        },
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
                          child: Text("Privacy Policy",style: TextStyle(
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
            child: Text("Privacy Policy",
            style: TextStyle(
            fontWeight: FontWeight.bold,fontSize: 20,
            letterSpacing: 0.5,
          ),textAlign: TextAlign.left,),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10,right: 10,top: 0),
            height: screenSize.height*0.03,
            width: screenSize.width*0.9,
           // color: Colors.grey,
            child: Text("Introduction",
              style: TextStyle(
                fontSize: 17,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold
              ),textAlign: TextAlign.left,),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: screenSize.height*0.14,
            width: screenSize.width*0.9,
           // color: Colors.grey,
            child: Text("Welcome to Akarat We value your privacy and are committed "
                "to protecting your personal information. This Privacy Policy explains how "
                "we collect, use, disclose, and safeguard your information when you visit our website.",style: TextStyle(
              fontSize: 15.5,letterSpacing: 0.5
            ),),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10,right: 10,top: 0),
            height: screenSize.height*0.03,
            width: screenSize.width*0.9,
            // color: Colors.grey,
            child: Text("Information We Collect",
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold
              ),textAlign: TextAlign.left,),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: screenSize.height*0.36,
            width: screenSize.width*0.9,
             //color: Colors.grey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("1.Personal Data:We may collect personally identifiable information, "
                      "such as your name, email address, phone number, and other contact information "
                      "that you voluntarily provide to us.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
                ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("2.Usage Data: We may also collect information on how our website is accessed "
                          "and used. This data may include your IP address, browser type, pages visited, "
                          "and the time and date of your visit.How We Use Your Information",style: TextStyle(
                          fontSize: 16,letterSpacing: 0.5
                      ),),
                    ),
              ],
            ),),
          Container(
            margin: const EdgeInsets.only(left: 10,right: 10,top: 0),
            height: screenSize.height*0.03,
            width: screenSize.width*0.9,
            // color: Colors.grey,
            child: Text("How We Use Your Information ",
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold
              ),textAlign: TextAlign.left,),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: screenSize.height*0.49,
            width: screenSize.width*0.9,
           // color: Colors.grey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("1.To Provide and Maintain Our Service:To ensure our website "
                      "functions correctly and to provide you with the services you request.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("2.To Communicate with You:To respond to your inquiries, "
                      "send you updates, and provide customer support.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("3.To Improve Our Website:To understand how users interact with our website "
                      "and to improve our services.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("4.To Send Promotional Materials:With your consent, "
                      "we may send you newsletters, marketing, or promotional materials that may be "
                      "of interest to you.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
                ),
              ],
            ),),
          Container(
            margin: const EdgeInsets.only(left: 10,right: 10,top: 0),
            height: screenSize.height*0.03,
            width: screenSize.width*0.9,
            // color: Colors.grey,
            child: Text("Disclosure of Your Information",
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold
              ),textAlign: TextAlign.left,),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: screenSize.height*0.415,
            width: screenSize.width*0.9,
            //color: Colors.grey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("1.Service Providers:We may employ third-party companies and individuals to "
                      "facilitate our website, provide services on our behalf, or assist us in analyzing how our website "
                      "is used. These third parties have access to your personal information only to perform "
                      "these tasks on our behalf and are obligated not to disclose or use it for any other purpose.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("2.Legal Requirements:We may disclose your personal information if required "
                      "to do so by law or in response to valid requests by public authorities.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
                ),
              ],
            ),),
          Container(
            margin: const EdgeInsets.only(left: 10,right: 10,top: 0),
            height: screenSize.height*0.03,
            width: screenSize.width*0.9,
            // color: Colors.grey,
            child: Text("Security of Your Information",
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold
              ),textAlign: TextAlign.left,),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: screenSize.height*0.54,
            width: screenSize.width*0.9,
            //color: Colors.grey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("We use administrative, technical, and physical security measures "
                      "to protect your personal information. While we strive to use commercially acceptable "
                      "means to protect your personal data, we cannot guarantee its absolute security.Your Data"
                      " Protection Rights",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Depending on your location, you may have the following rights "
                      "regarding your personal information:",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("1.AccessThe right to request copies of your personal data.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("2.RectificationThe right to request that we correct any information "
                      "you believe is inaccurate or complete information you believe.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
                ),
              ],
            ),),
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