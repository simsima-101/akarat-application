import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../secure_storage.dart';
import '../services/favorite_service.dart';
import '../utils/fav_login.dart';
import '../utils/fav_logout.dart';
import 'login.dart';

class Privacy extends StatefulWidget {
  Privacy({super.key,});


  @override
  State<StatefulWidget> createState() => new _PrivacyState();
}

class _PrivacyState extends State<Privacy> {

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
        appBar: AppBar(
          title: const Text(
              "Privacy Policy", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.red),
          elevation: 1,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
          Text("Privacy Policy",
            style: TextStyle(
            fontWeight: FontWeight.bold,fontSize: 20,
            letterSpacing: 0.5,
          ),textAlign: TextAlign.left,),
          const SizedBox(height: 6),
           Text("Introduction",
              style: TextStyle(
                fontSize: 17,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold
              ),textAlign: TextAlign.left,),
          const SizedBox(height: 6),
          Text("Welcome to Akarat We value your privacy and are committed "
                "to protecting your personal information. This Privacy Policy explains how "
                "we collect, use, disclose, and safeguard your information when you visit our website.",style: TextStyle(
              fontSize: 15.5,letterSpacing: 0.4
            ),),
          const SizedBox(height: 16),
          Text("Information We Collect",
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold
              ),textAlign: TextAlign.left,),
      const SizedBox(height: 6),
          Text("1.Personal Data:We may collect personally identifiable information, "
                      "such as your name, email address, phone number, and other contact information "
                      "that you voluntarily provide to us.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
      const SizedBox(height: 6),
                Text("2.Usage Data: We may also collect information on how our website is accessed "
                          "and used. This data may include your IP address, browser type, pages visited, "
                          "and the time and date of your visit.How We Use Your Information",style: TextStyle(
                          fontSize: 16,letterSpacing: 0.5
                      ),),
          const SizedBox(height: 16),
           Text("How We Use Your Information ",
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold
              ),textAlign: TextAlign.left,),
          const SizedBox(height: 6),
           Text("1.To Provide and Maintain Our Service:To ensure our website "
                      "functions correctly and to provide you with the services you request.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
      const SizedBox(height: 6),
               Text("2.To Communicate with You:To respond to your inquiries, "
                      "send you updates, and provide customer support.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
      const SizedBox(height: 6),
      Text("3.To Improve Our Website:To understand how users interact with our website "
                      "and to improve our services.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
      const SizedBox(height: 6),
      Text("4.To Send Promotional Materials:With your consent, "
                      "we may send you newsletters, marketing, or promotional materials that may be "
                      "of interest to you.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
          const SizedBox(height: 16),
          Text("Disclosure of Your Information",
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold
              ),textAlign: TextAlign.left,),
          const SizedBox(height: 6),
          Text("1.Service Providers:We may employ third-party companies and individuals to "
                      "facilitate our website, provide services on our behalf, or assist us in analyzing how our website "
                      "is used. These third parties have access to your personal information only to perform "
                      "these tasks on our behalf and are obligated not to disclose or use it for any other purpose.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
      const SizedBox(height: 6),
      Text("2.Legal Requirements:We may disclose your personal information if required "
                      "to do so by law or in response to valid requests by public authorities.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),

          const SizedBox(height: 16),
          Text("Security of Your Information",
              style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold
              ),textAlign: TextAlign.left,),
      const SizedBox(height: 6),
      Text("We use administrative, technical, and physical security measures "
                      "to protect your personal information. While we strive to use commercially acceptable "
                      "means to protect your personal data, we cannot guarantee its absolute security.Your Data"
                      " Protection Rights",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
      const SizedBox(height: 6),
      Text("Depending on your location, you may have the following rights "
                      "regarding your personal information:",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
      const SizedBox(height: 6),
      Text("1.AccessThe right to request copies of your personal data.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),
      const SizedBox(height: 6),
      Text("2.RectificationThe right to request that we correct any information "
                      "you believe is inaccurate or complete information you believe.",style: TextStyle(
                      fontSize: 16,letterSpacing: 0.5
                  ),),

          const SizedBox(height: 16),
          Text("Account Deletion",
            style: TextStyle(
                fontSize: 17,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 6),
          Text("You have the right to delete your account and all associated data at any time. "
              "This can be done within the app by going to 'My Account' and tapping 'Delete Your Account'. "
              "Once deleted, your personal data will be permanently removed from our systems.",
            style: TextStyle(fontSize: 16, letterSpacing: 0.5),
          ),

          const SizedBox(height: 16),
          Text("Tracking and Cookies",
            style: TextStyle(
                fontSize: 17,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 6),
          Text("We do not use cookies, advertising trackers, or App Tracking Transparency (ATT) technology in this app.",
            style: TextStyle(fontSize: 16, letterSpacing: 0.5),
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Home())),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/home.png", height: 25),
            ),
          ),

          IconButton(
            enableFeedback: false,
            onPressed: () async {
              final token = await SecureStorage.getToken();

              if (token == null || token.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white, // white container
                    title: const Text("Login Required", style: TextStyle(color: Colors.black)),
                    content: const Text("Please login to access favorites.", style: TextStyle(color: Colors.black)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red), // red text
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginDemo()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.red), // red text
                        ),
                      ),
                    ],
                  ),
                );
              }
              else {
                // ✅ Logged in – go to favorites
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Fav_Logout()),
                ).then((_) async {
                  // 🔁 Re-sync when coming back
                  final updatedFavorites = await FavoriteService.fetchApiFavorites(token);
                  setState(() {
                    FavoriteService.loggedInFavorites = updatedFavorites;
                  });
                });

              }
            },
            icon: pageIndex == 2
                ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                : const Icon(Icons.favorite_border_outlined, color: Colors.red, size: 30),
          ),



          IconButton(
            tooltip: "Email",
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
            onPressed: () async {
              final Uri emailUri = Uri.parse(
                'mailto:info@akarat.com?subject=Property%20Inquiry&body=Hi,%20I%20saw%20your%20agent%20profile%20on%20Akarat.',
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white, // White dialog container
                    title: const Text(
                      'Email not available',
                      style: TextStyle(color: Colors.black), // Title in black
                    ),
                    content: const Text(
                      'No email app is configured on this device. Please add a mail account first.',
                      style: TextStyle(color: Colors.black), // Content in black
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Colors.red), // Red "OK" text
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
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