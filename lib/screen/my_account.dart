import 'package:Akarat/screen/about_us.dart';
import 'package:Akarat/screen/advertising.dart';
import 'package:Akarat/screen/blog.dart';
import 'package:Akarat/screen/cookies.dart';
import 'package:Akarat/screen/findagent.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/privacy.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/settingstile.dart';
import 'package:Akarat/screen/support.dart';
import 'package:Akarat/screen/terms_condition.dart';
import 'package:Akarat/utils/fav_login.dart';
import 'package:Akarat/utils/fav_logout.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/shared_preference_manager.dart';
import 'favorite.dart';


class My_Account extends StatefulWidget {
   My_Account({super.key,}) ;
  // LoginModel arguments;


   // RegisterModel arguments;
   @override
   State<My_Account> createState() => _My_AccountState();
}
class _My_AccountState extends State<My_Account> {
  int pageIndex = 0;
  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;
  bool isDataSaved = true;
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

  Future<void> logoutAPI(String token) async {
    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Logout successful");

        // Clear stored preferences
        await prefManager.addStringToPref("");
        await prefManager.addStringToPrefemail("");
        await prefManager.addStringToPrefresult("");

        if (mounted) {
          setState(() {
            isDataSaved = false;
            isDataRead = false;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Profile_Login()),
          );
        }
      } else {
        debugPrint("❌ Logout failed: ${response.statusCode}");
        throw Exception("Logout failed");
      }
    } catch (e) {
      debugPrint("❌ Exception during logout: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  const SizedBox(height: 10,),
                  Container(
                    height: screenSize.height*0.22,
                  // color: Colors.grey,
                    color: Color(0xFFF5F5F5),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 20,top: 30,bottom: 0),
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
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
                        });
                      },
                              child: Image.asset("assets/images/ar-left.png",
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,),
                    ),
                            ),
                            Padding(padding: const EdgeInsets.only(left: 20,top: 30),
                            // child: Text(result,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                            child: Text("My Account",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                            ) ,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 30,top: 8,bottom: 0),
                              height: screenSize.height*0.11,
                              width: screenSize.width*0.25,
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
                              child: Image.asset("assets/images/avatar.png",
                                fit: BoxFit.fill,height: 10,),
                            ),
                            Container(
                                margin: const EdgeInsets.only(left: 15,top: 5),
                                height: screenSize.height*0.13,
                                width: screenSize.width*0.4,
                                 //color: Colors.grey,
                                padding: const EdgeInsets.only(left: 15,top: 10),
                                child:   Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(padding: const EdgeInsets.only(top: 0,left: 0,right: 0),
                                          child: Text(result,style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),textAlign: TextAlign.left,),
                                        ),
                                        Text("")
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Padding(padding: const EdgeInsets.only(top: 0,left: 0,right: 0),
                                          child: Text(email,style: TextStyle(
                                            fontSize: 12,
                                            // fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),textAlign: TextAlign.left,),
                                        ),
                                        Text("")

                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Padding(padding: const EdgeInsets.only(top: 2,left: 0,right: 0),
                                          child: ElevatedButton(onPressed: (){
                                            logoutAPI(token);
                                           // Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                                          },style:
                                          ElevatedButton.styleFrom(backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(8)),),),
                                              child: Text("Logout",style: TextStyle(color: Colors.white,fontSize: 12),)),
                                        ),
                                        Text("")

                                      ],
                                    ),
                                  ],
                                )
                            ),

                          ],
                        ),
                      ],
                    ),

                  ),
                  const SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _settingsTile("Find My Agent", "assets/images/find-my-agent.png", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FindAgent()));
                        }),
                        _settingsTile("Favorites", "assets/images/favourites.png", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Favorite()));
                        }),
                        _settingsTile("About Us", "assets/images/about.png", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => About_Us()));
                        }),
                        _settingsTile("Blogs", "assets/images/blog.png", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Blog()));
                        }),
                        _settingsTile("Advertising", "assets/images/advertise.png", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Advertising()));
                        }),
                        _settingsTile("Support", "assets/images/support.png", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Support()));
                        }),
                        _settingsTile("Privacy Policy", "assets/images/privacy-policy.png", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Privacy()));
                        }),
                        _settingsTile("Terms And Conditions", "assets/images/terms-and-conditions.png", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TermsCondition()));
                        }),
                        _settingsTile("Cookies", "assets/images/cookies.png", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Cookies()));
                        }),
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
              child: Image.asset("assets/images/home.png",height: 25,)),
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
Widget _settingsTile(String title, String iconPath, VoidCallback onTap) {
  return Column(
    children: [
      GestureDetector(
        onTap: onTap,
        child: ListTile(
          leading: Image.asset(iconPath, width: 28),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
      const Divider(height: 1),
    ],
  );
}