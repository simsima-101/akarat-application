import 'package:Akarat/screen/about_us.dart';
import 'package:Akarat/screen/advertising.dart';
import 'package:Akarat/screen/blog.dart';
import 'package:Akarat/screen/cookies.dart';
import 'package:Akarat/screen/favorite.dart';
import 'package:Akarat/screen/findagent.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/privacy.dart';
import 'package:Akarat/screen/support.dart';
import 'package:Akarat/screen/terms_condition.dart';
import 'package:flutter/material.dart';

import '../utils/shared_preference_manager.dart';
import 'my_account.dart';
import 'settingstile.dart';

void main(){
  runApp(const Profile_Login());

}

class Profile_Login extends StatelessWidget {
  const Profile_Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Profile_LoginDemo(),
    );
  }
}
class Profile_LoginDemo extends StatefulWidget {
  @override
  _Profile_LoginDemoState createState() => _Profile_LoginDemoState();
}
class _Profile_LoginDemoState extends State<Profile_LoginDemo> {

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
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  const SizedBox(height: 1,),
                  Container(
                    height: screenSize.height * 0.23,
                    color: const Color(0xFFF5F5F5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar with back and share buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _circularIconButton("assets/images/ar-left.png", () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                              }),
                              _circularIconButton("assets/images/share.png", () {
                                // Share action
                              }),
                            ],
                          ),
                        ),

                        // Welcome Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                          child: Row(
                            children: [
                              // App Icon
                              Container(
                                height: screenSize.height * 0.08,
                                width: screenSize.width * 0.18,
                                decoration: _avatarBoxDecoration(),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Image.asset("assets/images/app_icon.png", fit: BoxFit.contain),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Text & Button
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Hi there,",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "Sign in for a more personalized experience.",
                                      style: TextStyle(fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text("Login or Signup", style: TextStyle(fontSize: 11, color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                   height: screenSize.height*0.16,
                   width: screenSize.width*0.8,
                   margin: const EdgeInsets.only(left: 20,top: 10,right: 20),
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
                       Padding(
                         padding: const EdgeInsets.all(0.0),
                         child: Text("Enjoy a FREE Subscription for all of 2025",style: TextStyle(
                             fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black
                         ),),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(5.0),
                         child: ElevatedButton(onPressed: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                         },style:
                         ElevatedButton.styleFrom(backgroundColor: Colors.black,
                           shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(8)),),),
                             child: Text("Sign up Now!",style: TextStyle(color: Colors.white,fontSize: 14),)),
                       ),
                     ],
                   ),
                 ),

            Container(
                height: screenSize.height * 0.9,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      GestureDetector(
                        child: SettingsTile(
                          title: "Find My Agent",
                          iconPath: "assets/images/find-my-agent.png",
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> FindAgent()));
                        },
                      ),
                      GestureDetector(
                        child: const SettingsTile(
                          title: "Favorites",
                          iconPath: "assets/images/favourites.png",
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Favorite()));
                        },
                      ),
                      const SettingsTile(
                        title: "City",
                        iconPath: "assets/images/cities.png",
                        trailingText: "UAE",
                      ),
                      const SettingsTile(
                        title: "Languages",
                        iconPath: "assets/images/languages.png",
                        trailingText: "English",
                      ),
                      GestureDetector(
                        child: const SettingsTile(
                          title: "About Us",
                          iconPath: "assets/images/about.png",
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> About_Us()));
                        },
                      ),
                      GestureDetector(
                        child: const SettingsTile(
                          title: "Blogs",
                          iconPath: "assets/images/blog.png",
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Blog()));
                        },
                      ),
                      GestureDetector(
                        child: const SettingsTile(
                          title: "Advertising",
                          iconPath: "assets/images/advertise.png",
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Advertising()));
                        },
                      ),
                      GestureDetector(
                        child: const SettingsTile(
                          title: "Support",
                          iconPath: "assets/images/support.png",
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Support()));
                        },
                      ),
                      GestureDetector(
                        child: const SettingsTile(
                          title: "Privacy Policy",
                          iconPath: "assets/images/privacy-policy.png",
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Privacy()));
                        },
                      ),
                      GestureDetector(
                        child: const SettingsTile(
                          title: "Terms And Conditions",
                          iconPath: "assets/images/terms-and-conditions.png",
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> TermsCondition()));
                        },
                      ),
                      GestureDetector(
                        child: const SettingsTile(
                          title: "Cookies",
                          iconPath: "assets/images/cookies.png",
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Cookies()));
                        },
                      ),
                    ],
                  ),
                ),
            ),
                ]
            )
        )
    );
  }
  Widget _circularIconButton(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );
  }

  BoxDecoration _avatarBoxDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
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