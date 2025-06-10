import 'dart:convert';

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
import '../model/agencypropertiesmodel.dart';
import '../secure_storage.dart';
import '../services/api_service.dart';
import '../utils/shared_preference_manager.dart';
import 'favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';




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
  final SharedPreferencesManager prefManager = SharedPreferencesManager();

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // ✅ Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Optional: Clear token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Method to read data from shared preferences
  void readData() async {
    token = await prefManager.readStringFromPref() ?? '';
    email = await prefManager.readStringFromPrefemail() ?? '';
    result = await prefManager.readStringFromPrefresult() ?? '';
    setState(() {
      isDataRead = true;
    });
  }

  @override
  void initState() {
    readData();
    super.initState();
  }
  Future<List<Property>> fetchSavedProperties() async {
    try {
      final response = await http.get(
        Uri.parse('https://akarat.com/api/saved-property-list?page=1'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = json.decode(response.body);

        // ✅ Safely navigate to responseJson['data']['data']
        final List<dynamic> propertiesJsonList = responseJson['data']?['data'] ?? [];

        print('Fetched ${propertiesJsonList.length} properties');

        // ✅ Map the list to your Property model
        List<Property> properties = propertiesJsonList
            .map((item) => Property.fromJson(item))
            .toList();

        return properties;
      } else {
        throw Exception('Failed to fetch properties: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching saved properties: $e');
      return []; // ✅ Return empty list instead of rethrowing to avoid crash
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
                  const SizedBox(height: 35,),
                  Container(
                    height: screenSize.height*0.22,
                    // color: Colors.grey,
                    color: Color(0xFFF5F5F5),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 30, top: 8, bottom: 0),
                              height: screenSize.height * 0.11,
                              width: screenSize.width * 0.25,
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300, // grey background for Play Store safe
                                borderRadius: BorderRadius.circular(60.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: const Offset(0.0, 0.0),
                                    blurRadius: 0.1,
                                    spreadRadius: 0.1,
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: const Offset(0.0, 0.0),
                                    blurRadius: 0.0,
                                    spreadRadius: 0.0,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/avatar.png",
                                    fit: BoxFit.cover,
                                    height: screenSize.height * 0.06,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Coming Soon",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
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
                                        Expanded(
                                          child: SizedBox(
                                            height: 28, // ⬅️ Reduced height for the Logout button
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  String? token = await SecureStorage.getToken();
                                                  if (token != null) {
                                                    await ApiService.logoutUser(token);
                                                    await SecureStorage.deleteToken();
                                                    Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(builder: (_) => const LoginPage()),
                                                          (route) => false,
                                                    );
                                                  } else {
                                                    throw Exception("No token found.");
                                                  }
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text("Logout failed: $e")),
                                                  );
                                                }
                                              },



                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                                ),
                                                padding: EdgeInsets.zero, // Removes extra padding
                                              ),
                                              child: Text(
                                                "Logout",
                                                style: TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ distributes space correctly
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/home.png", height: 25),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0), // consistent spacing from right edge
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                setState(() {
                  if (token == '') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Profile_Login()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
                  }
                });
              },
              icon: pageIndex == 3
                  ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                  : const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
            ),
          ),
        ],
      ),

    );
  }

  logoutAPI(String token) {}
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