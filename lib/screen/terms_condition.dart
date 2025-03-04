import 'dart:async';

import 'package:drawerdemo/screen/home.dart';
import 'package:drawerdemo/screen/profile_login.dart';
import 'package:flutter/material.dart';

class TermsCondition extends StatefulWidget {
  TermsCondition({super.key,});


  @override
  State<StatefulWidget> createState() => new _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {

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
        bottomNavigationBar: buildMyNavBar(context),
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
                          padding: EdgeInsets.only(top: 28),
                          child: Container(
                            height: screenSize.height*0.07,
                            width: double.infinity,
                            // color: Color(0xFFEEEEEE),
                            child:   Row(
                              children: [GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Profile_Login()));
                                },
                                child:   Container(
                                  margin: const EdgeInsets.only(left: 10,top: 0,bottom: 0),
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
                                  width: screenSize.width*0.15,
                                ),
                                Padding(padding: const EdgeInsets.all(5.0),
                                  child: Text("Terms and Conditions",style: TextStyle(
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
                    child: Text("Terms and Conditions",
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
                    height: screenSize.height*0.16,
                    width: screenSize.width*0.9,
                    // color: Colors.grey,
                    child: Text("Welcome to the Akarat website. By accessing or using our "
                        "website, you agree to comply with and be bound by the following "
                        "terms and conditions. Please review them carefully. If you do not "
                        "agree to these terms and conditions, you should not use this website.",style: TextStyle(
                        fontSize: 15.5,letterSpacing: 0.5
                    ),),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 0),
                    height: screenSize.height*0.03,
                    width: screenSize.width*0.9,
                    // color: Colors.grey,
                    child: Text("Use of Website",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.25,
                    width: screenSize.width*0.9,
                   // color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("1.Eligibility:You must be at least 18 years of age "
                              "to use this website. By using this website, you represent and warrant "
                              "that you are at least 18 years old.",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("2.License:Akarat grants you a limited, non-exclusive, "
                              "non-transferable, and revocable license to use our website for personal, "
                              "non-commercial use.",style: TextStyle(
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
                    child: Text("Intellectual Property ",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: screenSize.height*0.38,
                    width: screenSize.width*0.9,
                    // color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("1.Ownership:All content, features, and functionality "
                              "(including but not limited to text, graphics, logos, images, and software) "
                              "on this website are the exclusive property of Akarat and are protected by"
                              " international copyright, trademark, patent, trade secret, and other intellectual"
                              " property or proprietary rights laws.",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("2.Restrictions:You may not copy, "
                              "reproduce, distribute, republish, download, display, post, "
                              "or transmit any part of this website in any form or by any means "
                              "without the prior written consent of Akarat",style: TextStyle(
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
                    child: Text("User Responsibilities",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.44,
                    width: screenSize.width*0.9,
                   // color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("1.Prohibited Activities:You agree not to use the website for any "
                              "unlawful purpose or in any way that could harm or disable the website. This includes,"
                              " but is not limited to, unauthorized access to the website, distributing viruses, or "
                              "engaging in any activity that interferes with the proper functioning of the website"
                            ,style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("2.Account Security:If you create an account on our website, you are "
                              "responsible for maintaining the confidentiality of your account and password and "
                              "for restricting access to your computer. You agree to accept responsibility for all "
                              "activities that occur under your account or password.",style: TextStyle(
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
                    child: Text("Third-Party Links",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.38,
                    width: screenSize.width*0.9,
                    //color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Our website may contain links to third-party websites or services that "
                              "are not owned or controlled by Akarat We have no control over, and assume no responsibility "
                              "for, the content, privacy policies, or practices of any third-party websites or services. "
                              "You further acknowledge and agree that Akarat shall not be responsible or liable, directly or "
                              "indirectly, for any damage or loss caused or alleged to be caused by or in connection with the use "
                              "of or reliance on any such content, goods, or services available on or through any such websites or"
                              "services.",style: TextStyle(
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
                    child: Text("Limitation of Liability",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.37,
                    width: screenSize.width*0.9,
                    // color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("To the maximum extent permitted by applicable law, Akarat "
                              "assumes no liability or responsibility for any:"
                            ,style: TextStyle(
                                fontSize: 16,letterSpacing: 0.5
                            ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("1. Errors, mistakes, or inaccuracies of content;",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("2. Personal injury or property damage, of any nature whatsoever,"
                              " resulting from your access to and use of our website;",style: TextStyle(
                              fontSize: 16,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("3. Any unauthorized access to or use of our secure servers "
                              "and/or any and all personal information stored therein.",style: TextStyle(
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
                    child: Text("Changes to These Terms",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: screenSize.height*0.21,
                    width: screenSize.width*0.9,
                    //color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Akarat reserves the right to modify or replace these Terms "
                              "and Conditions at any time. It is your responsibility to check this "
                              "page periodically for changes. Your continued use of or access to the website"
                              " following the posting of any changes constitutes acceptance of those changes."
                            ,style: TextStyle(
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
                    child: Text("Governing Law",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: screenSize.height*0.13,
                    width: screenSize.width*0.9,
                   // color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("These terms shall be governed and construed in accordance with"
                              " the laws of the United Arab Emirates, without regard to its conflict "
                              "of law provisions. ",style: TextStyle(
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

              //   Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));

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