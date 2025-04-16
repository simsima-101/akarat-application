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


class My_Account extends StatefulWidget {
   My_Account({super.key,}) ;
  // LoginModel arguments;


   // RegisterModel arguments;
   @override
   State<My_Account> createState() => _My_AccountState();
}
class _My_AccountState extends State<My_Account> {
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



  Future<void> logoutAPI(data) async {
    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/logout'),
        headers: <String, String>{'Authorization':'Bearer $data',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        print("logout Succesfully");
        prefManager.addStringToPref("");
        prefManager.addStringToPrefemail("");
        prefManager.addStringToPrefresult("");
        setState(() {
          isDataSaved = false;
          isDataRead = false;
        });
       /* isDataSaved
            ? const Text('Data Saved!')
            : const Text('Data Not Saved!');
        // Call the addStringToPref method and pass the string value
        prefManager.addStringToPref("");
        prefManager.addStringToPrefemail("");
        prefManager.addStringToPrefresult("");
        setState(() {
          isDataSaved = false;
        });*/

        Navigator.push(context, MaterialPageRoute(builder: (context) => Profile_Login()));
      } else {
        throw Exception("logout failed");

      }
    } catch (e) {
      setState(() {
        print('Error: $e');
      });
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
                            if(isDataRead == true){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Fav_Login()));
                            }
                            else{
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Fav_Logout()));

                            }
                            //  Navigator.push(context, MaterialPageRoute(builder: (context)=> Favorite()));
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
                 /* Container(
                    // color: Colors.grey,
                    height: screenSize.height*0.55,
                    margin:const EdgeInsets.only(left: 20,right: 20,top: 0),
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> FindAgent()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                            height: screenSize.height*0.045,

                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 15),
                                  child: Image.asset("assets/images/find-my-agent.png",height: 22,),
                                ),

                                SizedBox(
                                  width: screenSize.width*0.13,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 0),
                                  child: Text("Find My Agent",style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.29,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 15),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            if(isDataRead == true){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Fav_Login()));
                            }
                            else{
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Fav_Logout()));

                            }
                          //  Navigator.push(context, MaterialPageRoute(builder: (context)=> Favorite()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                            height: screenSize.height*0.045,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 15),
                                  child: Image.asset("assets/images/favourites.png",height: 22,),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 12),
                                  child: Text("Favorites",style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.38,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 15),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            //Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                            height: screenSize.height*0.045,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 15),
                                  child: Image.asset("assets/images/cities.png",height: 25,),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 12),
                                  child: Text("City",style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.43,
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Text("UAE",style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),)
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 3),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                ),
                              ],
                            ),
                          ),

                        ),
                        GestureDetector(
                          onTap: (){
                            //Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                            height: screenSize.height*0.045,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 15),
                                  child: Image.asset("assets/images/languages.png",height: 25,),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 12),
                                  child: Text("Languages",style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.26,
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Text("English",style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),)
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 3),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> About_Us()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                            height: screenSize.height*0.045,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 15),
                                  child: Image.asset("assets/images/app_icon.png",height: 25,),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 12),
                                  child: Text("About Us",style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.38,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 15),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> Blog()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                            height: screenSize.height*0.045,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 15),
                                  child: Image.asset("assets/images/blog.png",height: 25,),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.13,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 0),
                                  child: Text("Blogs",style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.44,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 15),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> Advertising()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                            height: screenSize.height*0.045,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 15),
                                  child: Image.asset("assets/images/advertise.png",height: 25,),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.13,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 0),
                                  child: Text("Advertising",style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.35,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 12),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> Support()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                            height: screenSize.height*0.045,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 15),
                                  child: Image.asset("assets/images/support.png",height: 25,),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.13,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 0),
                                  child: Text("Support",style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.4,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 15),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> Privacy()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                            height: screenSize.height*0.045,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 15),
                                  child: Image.asset("assets/images/privacy-policy.png",height: 22,),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.12,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 0),
                                  child: Text("Privacy Policy",style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.31,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 15),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> TermsCondition()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                            height: screenSize.height*0.045,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 15),
                                  child: Image.asset("assets/images/terms-and-conditions.png",height: 25,),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.12,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 0),
                                  child: Text("Terms And Conditions",style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.17,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 15),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> Cookies()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                            height: screenSize.height*0.045,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 12),
                                  child: Image.asset("assets/images/cookies.png",height: 25,),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.12,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 0),
                                  child: Text("Cookies",style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.39,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 20),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),*/

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