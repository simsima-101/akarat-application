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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  const SizedBox(height: 10,),
                  Container(
                    height: screenSize.height*0.219,
                    color: Color(0xFFF5F5F5),
                    child: Column(

                      children: [
                        Row(
                          spacing:screenSize.width*0.7,
                          children: [
                              GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                                },
                              child: Container(
                              margin: const EdgeInsets.only(left: 20,top: 20,bottom: 0),
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
                              margin: const EdgeInsets.only(left: 0,top: 20,bottom: 0),
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
                              child: Image.asset("assets/images/share.png",
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,),
                            ),
                          ],
                        ),
                       Row(
                         children: [
                           Container(
                             margin: const EdgeInsets.only(left: 70,top: 0,bottom: 40),
                             height: screenSize.height*0.08,
                             width: screenSize.width*0.18,
                             padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                             decoration: BoxDecoration(
                               borderRadius: BorderRadiusDirectional.circular(90.0),
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
                             child: Image.asset("assets/images/app_icon.png",
                               width: 15,
                               height: 15,
                               fit: BoxFit.contain,),
                           ),
                           Container(
                             margin: const EdgeInsets.only(left: 15),
                             height: screenSize.height*0.15,
                             width: screenSize.width*0.45,
                             // color: Colors.grey,
                             padding: const EdgeInsets.only(left: 0,top: 0),
                             child:   Column(
                                 children: [
                                   Row(
                                     children: [
                                       Padding(padding: const EdgeInsets.only(top: 0,left: 2,right: 0),
                                         child: Text("Hi there,",style: TextStyle(
                                           fontSize: 22,
                                           fontWeight: FontWeight.bold,
                                           letterSpacing: 0.5,
                                         ),textAlign: TextAlign.left,),
                                       ),
                                       Text("")
                                     ],
                                   ),
                                   Row(
                                     children: [
                                       Expanded(
                                         child: Padding(
                                           padding: const EdgeInsets.only(top: 1),
                                           child: Text(
                                             "Sign in for a more personalized experience.",
                                             style: TextStyle(
                                               fontSize: 12,
                                               letterSpacing: 0.5,
                                             ),
                                             textAlign: TextAlign.left,
                                             overflow: TextOverflow.ellipsis, // optional
                                             maxLines: 2, // optional
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                   Row(
                                     children: [
                                       Padding(padding: const EdgeInsets.only(top: 0,left: 0,right: 8),
                                       child: ElevatedButton(onPressed: (){
                                         Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                                       },style:
                                       ElevatedButton.styleFrom(backgroundColor: Colors.blue,
                                         shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(8)),),),
                                           child: Text("Login or Signup",style: TextStyle(color: Colors.white,fontSize: 11),)),
                                       ),
                                       Text("")
                                     ],
                                   ),
                                 ],
                               )
                           ),

                         ],
                       )
                      ],
                    ),

                  ),
                  Container(
                   height: screenSize.height*0.16,
                   width: screenSize.width*0.8,
                   margin: const EdgeInsets.only(left: 20,top: 14,right: 20),
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
                ]
            )
        )
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