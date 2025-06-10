import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/fav_login.dart';
import '../utils/fav_logout.dart';

class TermsCondition extends StatefulWidget {
  TermsCondition({super.key,});


  @override
  State<StatefulWidget> createState() => new _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {

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

    // Inside build method or initState
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // ✅ Matches AppBar
        statusBarIconBrightness: Brightness.dark, // black icons for white bg
      ),
    );

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea(child: buildMyNavBar(context),),
        appBar: AppBar(
          title: const Text(
              "Terms and Conditions", style: TextStyle(color: Colors.black,
              fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.red),
          elevation: 1,
        ),

        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 20),

                  const Text("Terms and Conditions",style: TextStyle(
                    fontWeight: FontWeight.bold,fontSize: 20,
                    letterSpacing: 0.5,
                  )),

                  const SizedBox(height: 6),
                  const Text(
                    "Introduction",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Welcome to the Akarat website. By accessing or using our website, you agree to comply with and be bound by the following terms and conditions. Please review them carefully. If you do not agree to these terms and conditions, you should not use this website.",
                  style: TextStyle(fontSize: 16,letterSpacing: 0.4),),

                  const SizedBox(height: 16),
                  const Text(
                    "Use of Website",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                      "1. Eligibility: You must be at least 18 years of age to use this website. By using this website, you represent and warrant that you are at least 18 years old."
                      ,style: TextStyle(fontSize: 16,letterSpacing: 0.4),),
                  const SizedBox(height: 6),
                  const Text(
                      "2. License: Akarat grants you a limited, non-exclusive, "
                          "non-transferable, and revocable license to use our website"
                          " for personal, non-commercial use.",style: TextStyle(fontSize: 16,letterSpacing: 0.4),),

                  const SizedBox(height: 16),
                  const Text(
                    "Intellectual Property",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "1.Ownership:All content, features, and functionality "
                        "(including but not limited to text, graphics, logos, images, and software) "
                        "on this website are the exclusive property of Akarat and are protected by"
                        " international copyright, trademark, patent, trade secret, and other intellectual"
                        " property or proprietary rights laws.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.4),),
                  const SizedBox(height: 6),
                  const Text(
                    "2.Restrictions:You may not copy, "
                        "reproduce, distribute, republish, download, display, post, "
                        "or transmit any part of this website in any form or by any means "
                        "without the prior written consent of Akarat",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.4
                  ),),

                  const SizedBox(height: 16),
                  const Text(
                      "User Responsibilities",
                      style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold
                  ) ),
                  const SizedBox(height: 6),
                  const Text(
                    "1.Prohibited Activities:You agree not to use the website for any "
                        "unlawful purpose or in any way that could harm or disable the website. This includes,"
                        " but is not limited to, unauthorized access to the website, distributing viruses, or "
                        "engaging in any activity that interferes with the proper functioning of the website"
                    ,style: TextStyle(
                      fontSize: 16,letterSpacing: 0.4
                  ),),
                  const SizedBox(height: 6),
                  const Text(
                    "2.Account Security:If you create an account on our website, you are "
                        "responsible for maintaining the confidentiality of your account and password and "
                        "for restricting access to your computer. You agree to accept responsibility for all "
                        "activities that occur under your account or password.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.4
                  ),),

                  const SizedBox(height: 16),
                  const Text(
                      "Third-Party Links",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      )),
                  const SizedBox(height: 6),
                  const Text(
                    "Our website may contain links to third-party websites or services that "
                        "are not owned or controlled by Akarat We have no control over, and assume no responsibility "
                        "for, the content, privacy policies, or practices of any third-party websites or services. "
                        "You further acknowledge and agree that Akarat shall not be responsible or liable, directly or "
                        "indirectly, for any damage or loss caused or alleged to be caused by or in connection with the use "
                        "of or reliance on any such content, goods, or services available on or through any such websites or"
                        "services.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.4
                  ),),
                  const SizedBox(height: 16),
                  const Text(
                      "Limitation of Liability",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      )),
                  const SizedBox(height: 6),
                  const Text(
                    "To the maximum extent permitted by applicable law, Akarat "
                        "assumes no liability or responsibility for any:"
                    ,style: TextStyle(
                      fontSize: 16,letterSpacing: 0.4
                  ),),
                  const SizedBox(height: 6),
                  const Text(
                    "1. Errors, mistakes, or inaccuracies of content;",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.4
                  ),),
                  const SizedBox(height: 6),
                  const Text(
                    "2. Personal injury or property damage, of any nature whatsoever,"
                        " resulting from your access to and use of our website;",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.4
                  ),),const SizedBox(height: 6),
                  const Text(
                    "3. Any unauthorized access to or use of our secure servers "
                        "and/or any and all personal information stored therein.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.4
                  ),),
                  const SizedBox(height: 16),
                  const Text(
                      "Changes to These Terms",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      )),
                  const SizedBox(height: 6),
                  const Text(
                    "Akarat reserves the right to modify or replace these Terms "
                        "and Conditions at any time. It is your responsibility to check this "
                        "page periodically for changes. Your continued use of or access to the website"
                        " following the posting of any changes constitutes acceptance of those changes."
                    ,style: TextStyle(
                      fontSize: 16,letterSpacing: 0.4
                  ),),
                  const SizedBox(height: 16),
                  const Text(
                      "Governing Law",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold
                      )),
                  const SizedBox(height: 6),
                  const Text(
                    "These terms shall be governed and construed in accordance with"
                        " the laws of the United Arab Emirates, without regard to its conflict "
                        "of law provisions. ",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.4
                  ),),
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