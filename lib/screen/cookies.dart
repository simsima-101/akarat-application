import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:flutter/material.dart';

import '../utils/fav_login.dart';
import '../utils/fav_logout.dart';

class Cookies extends StatefulWidget {
  Cookies({super.key,});


  @override
  State<StatefulWidget> createState() => new _CookiesState();
}

class _CookiesState extends State<Cookies> {

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
                                  });                                },
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
                                  child: Text("Cookie Policy",style: TextStyle(
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
                    child: Text("Cookie Policy",
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
                    height: screenSize.height*0.11,
                    width: screenSize.width*0.9,
                     //color: Colors.grey,
                    child: Text("At Akarat, we use cookies to enhance your browsing experience "
                        "on our website. This Cookie Policy explains what cookies are, how we use them,"
                        " and your choices regarding their use.",style: TextStyle(
                        fontSize: 15.5,letterSpacing: 0.5
                    ),),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 0),
                    height: screenSize.height*0.03,
                    width: screenSize.width*0.9,
                    // color: Colors.grey,
                    child: Text("What Are Cookies?",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.2,
                    width: screenSize.width*0.9,
                    //color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Cookies are small text files that are placed on your "
                              "device by websites you visit. They are widely used to make websites"
                              " work more efficiently, as well as to provide information to the website "
                              "owners.",style: TextStyle(
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
                    child: Text("How We Use Cookies ",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.85,
                    width: screenSize.width*0.9,
                     //color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("We use cookies for various purposes, including:",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("1.Essential Cookies:These cookies are necessary for the website "
                              "to function properly. They enable you to navigate the site and use its features,"
                              " such as accessing secure areas of the website.",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("2.Performance Cookies:These cookies collect information about how "
                              "visitors use our website, such as which pages are visited most often. This helps"
                              " us improve how our website works and enhance the user experience.",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("3.Functionality Cookies:These cookies allow our website to remember"
                              " choices you make (such as your username, language, or the region you are in)"
                              " and provide enhanced, more personalized features.",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("4.Targeting/Advertising Cookies:These cookies are used to deliver"
                              " adverts more relevant to you and your interests. They are also used to limit"
                              " the number of times you see an advertisement and help measure the effectiveness"
                              " of advertising campaigns.",style: TextStyle(
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
                    child: Text("Third-Party Cookies",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.17,
                    width: screenSize.width*0.9,
                    //color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("In addition to our own cookies, we may also use various third-party "
                              "cookies to report usage statistics of the website and deliver advertisements on "
                              "and through the website.",style: TextStyle(
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
                    child: Text("Your Choices Regarding Cookies",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.22,
                    width: screenSize.width*0.9,
                    //color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("You have the right to decide whether to accept or reject cookies."
                              " You can set your web browser to refuse cookies or to alert you when cookies"
                              " are being sent. However, if you choose to refuse cookies, you may not be able "
                              "to use some portions of our website.",style: TextStyle(
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
                    child: Text("Managing Cookies",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.12,
                    width: screenSize.width*0.9,
                    //color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Most web browsers allow you to control cookies through their settings"
                              " preferences.",style: TextStyle(
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
                    child: Text("Changes to This Cookie Policy",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.23,
                    width: screenSize.width*0.9,
                    //color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("We may update our Cookie Policy from time to time to reflect "
                              "changes in our practices or for other operational, legal, or regulatory reasons. "
                              "We encourage you to periodically review this page for the latest information on our "
                              "cookie practices.",style: TextStyle(
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