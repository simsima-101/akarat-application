import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/utils/fav_login.dart';
import 'package:Akarat/utils/fav_logout.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/shared_preference_manager.dart';
import 'my_account.dart';

class Favorite extends StatefulWidget {
  final dynamic productData; // Accept product data (Map or model)

  Favorite({super.key, this.productData});


  @override
  State<Favorite> createState() => new _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  int pageIndex = 0;
  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;

  SharedPreferencesManager prefManager = SharedPreferencesManager();

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
    super.initState();
    readData();
    loadToken();

    if (widget.productData != null) {
      print("Received product: ${widget.productData}");
    }
  }

  void loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);

    if (!isDataRead) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (token.isEmpty) {
      return Fav_Logout();
    }

    if (token.isNotEmpty) {
      return Fav_Login();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('Something went wrong')),
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
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
}
