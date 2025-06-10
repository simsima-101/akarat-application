  import 'package:carousel_slider/carousel_slider.dart';
  import 'package:Akarat/screen/home.dart';
  import 'package:Akarat/screen/my_account.dart';
  import 'package:Akarat/screen/profile_login.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';

  import '../utils/fav_login.dart';
  import '../utils/fav_logout.dart';
  import '../utils/shared_preference_manager.dart';

  class About_Us extends StatefulWidget {

    About_Us({super.key,});
    @override
    State<About_Us> createState() => _About_UsState();
  }
  class _About_UsState extends State<About_Us> {

    int pageIndex = 0;

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
      return   WillPopScope(
          child:  Scaffold(
              backgroundColor: Colors.white,
              bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
              appBar: AppBar(
                title: const Text(
                    "About Us", style: TextStyle(color: Colors.black,
                fontWeight: FontWeight.bold)),
                centerTitle: true,
                backgroundColor: Color(0xFFFFFFFF),
                iconTheme: const IconThemeData(color: Colors.red),
                elevation: 1,
              ),

              body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //Slider
                        ListView(
                          padding: const EdgeInsets.only(top: 8),
                          shrinkWrap: true,
                          children: [
                            CarouselSlider(
                              items: [
                                //1st Image of Slider
                                Container(
                                  margin: EdgeInsets.all(0.0),
                                  width: screenSize.width*0.9,
                                  height: screenSize.height*0.2,
                                  color: Colors.grey,
                                  child: Image.asset("assets/images/banner1.png",fit: BoxFit.fill,),
                                ),
                                Container(
                                  margin: EdgeInsets.all(0.0),
                                  width: screenSize.width*0.9,
                                  height: screenSize.height*0.2,
                                  color: Colors.grey,
                                  child: Image.asset("assets/images/banner2.png",fit: BoxFit.fill,),
                                ),
                                Container(
                                  margin: EdgeInsets.all(0.0),
                                  width: screenSize.width*0.9,
                                  height: screenSize.height*0.2,
                                  color: Colors.grey,
                                  child: Image.asset("assets/images/banner3.png",fit: BoxFit.fill,),
                                ),

                              ],
                              //Slider Container properties
                              options: CarouselOptions(
                                height: screenSize.height*0.2,
                                enlargeCenterPage: true,
                                autoPlay: true,
                                aspectRatio: 16 / 9,
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enableInfiniteScroll: true,
                                autoPlayAnimationDuration: Duration(milliseconds: 800),
                                viewportFraction: 0.9,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text("Akarat.com",style: TextStyle(
                            fontSize: 25,fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),textAlign: TextAlign.center,),
                        ),
                        const SizedBox(height: 6),
                        Text("Welcome to Akarat.com, your trusted real estate partner in the UAE. "
                                  "We specialize in connecting buyers, sellers, and investors with the best property "
                                  "opportunities across the region.",style: TextStyle(
                                  fontSize: 16,letterSpacing: 0.4
                              ),),
                        const SizedBox(height: 6),
                        Text("At Akarat.com, we blend cutting-edge technology with "
                                    "deep market expertise to provide a seamless property search experience. Whether you're "
                                    "looking for residential, commercial, or investment properties, our platform offers verified "
                                    "listings, real-time market insights, and expert guidance to help you make informed decisions."
                                  ,style: TextStyle(
                                      fontSize: 16,letterSpacing: 0.5
                                  ),),
                        const SizedBox(height: 6),
                        Text("Our mission is to simplify real estate transactions with transparency, efficiency, "
                                    "and innovation. With a team of experienced professionals and a commitment to excellence, "
                                    "we strive to be the go-to real estate portal for individuals and businesses alike."
                                  ,style: TextStyle(
                                      fontSize: 16,letterSpacing: 0.5
                                  ),),
                        const SizedBox(height: 6),
                        Text(
                          "Start your real estate journey with Akarat.com today!",style: TextStyle(
                                    fontSize: 16
                                ),),
                            ],
                          ),
                  )
          ),
          onWillPop: () async {
            Navigator.of(context).pop(true);
            return true;
          },
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
  }