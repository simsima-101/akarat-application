// import 'package:Akarat/screen/home.dart';
// import 'package:Akarat/screen/my_account.dart';
// import 'package:Akarat/screen/profile_login.dart';
// import 'package:Akarat/utils/shared_preference_manager.dart';
// import 'package:flutter/material.dart';
//
// import '../utils/fav_login.dart';
// import '../utils/fav_logout.dart';
//
// class Cookies extends StatefulWidget {
//   Cookies({super.key,});
//
//
//   @override
//   State<StatefulWidget> createState() => new _CookiesState();
// }
//
// class _CookiesState extends State<Cookies> {
//
//   int pageIndex = 0;
//   String token = '';
//   String email = '';
//   String result = '';
//   bool isDataRead = false;
//   // Create an object of SharedPreferencesManager class
//   SharedPreferencesManager prefManager = SharedPreferencesManager();
//   // Method to read data from shared preferences
//   void readData() async {
//     token = await prefManager.readStringFromPref();
//     email = await prefManager.readStringFromPrefemail();
//     result = await prefManager.readStringFromPrefresult();
//     setState(() {
//       isDataRead = true;
//     });
//   }
//
//   @override
//   void initState() {
//     readData();
//     super.initState();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     Size screenSize = MediaQuery.sizeOf(context);
//     return Scaffold(
//         backgroundColor: Colors.white,
//         bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
//         appBar: AppBar(
//           title: const Text(
//               "Cookie Policy", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//           centerTitle: true,
//           backgroundColor: Colors.white,
//           iconTheme: const IconThemeData(color: Colors.red),
//           elevation: 1,
//         ),
//         body: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Center(
//                     //color: Colors.grey,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(3.0),
//                           child: Image.asset("assets/images/app_icon.png",height: 22,alignment: Alignment.center,),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(3.0),
//                           child: Image.asset("assets/images/logo-text.png",height: 22,alignment: Alignment.center,),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text("Cookie Policy",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,fontSize: 20,
//                         letterSpacing: 0.5,
//                       ),textAlign: TextAlign.left,),
//                   const SizedBox(height: 16),
//                   Text("Introduction",
//                       style: TextStyle(
//                           fontSize: 17,
//                           letterSpacing: 0.5,
//                           fontWeight: FontWeight.bold
//                       ),textAlign: TextAlign.left,),
//                   const SizedBox(height: 6),
//                   Text("At Akarat, we use cookies to enhance your browsing experience "
//                         "on our website. This Cookie Policy explains what cookies are, how we use them,"
//                         " and your choices regarding their use.",style: TextStyle(
//                         fontSize: 15.5,letterSpacing: 0.4
//                     ),),
//       const SizedBox(height: 16),
//       Text("What Are Cookies?",
//                       style: TextStyle(
//                           fontSize: 17,
//                           letterSpacing: 0.5,
//                           fontWeight: FontWeight.bold
//                       ),textAlign: TextAlign.left,),
//       const SizedBox(height: 6),
//       Text("Cookies are small text files that are placed on your "
//                               "device by websites you visit. They are widely used to make websites"
//                               " work more efficiently, as well as to provide information to the website "
//                               "owners.",style: TextStyle(
//                               fontSize: 16,letterSpacing: 0.5
//                           ),),
//       const SizedBox(height: 16),
//       Text("How We Use Cookies ",
//                       style: TextStyle(
//                           fontSize: 17,
//                           letterSpacing: 0.5,
//                           fontWeight: FontWeight.bold
//                       ),textAlign: TextAlign.left,),
//       const SizedBox(height: 6),
//       Text("We use cookies for various purposes, including:",style: TextStyle(
//                               fontSize: 16,letterSpacing: 0.5
//                           ),),
//       const SizedBox(height: 6),
//       Text("1.Essential Cookies:These cookies are necessary for the website "
//                               "to function properly. They enable you to navigate the site and use its features,"
//                               " such as accessing secure areas of the website.",style: TextStyle(
//                               fontSize: 16,letterSpacing: 0.5
//                           ),),
//       const SizedBox(height: 6),
//       Text("2.Performance Cookies:These cookies collect information about how "
//                               "visitors use our website, such as which pages are visited most often. This helps"
//                               " us improve how our website works and enhance the user experience.",style: TextStyle(
//                               fontSize: 16,letterSpacing: 0.5
//                           ),),
//       const SizedBox(height: 6),
//       Text("3.Functionality Cookies:These cookies allow our website to remember"
//                               " choices you make (such as your username, language, or the region you are in)"
//                               " and provide enhanced, more personalized features.",style: TextStyle(
//                               fontSize: 16,letterSpacing: 0.5
//                           ),),
//       const SizedBox(height: 6),
//       Text("4.Targeting/Advertising Cookies:These cookies are used to deliver"
//                               " adverts more relevant to you and your interests. They are also used to limit"
//                               " the number of times you see an advertisement and help measure the effectiveness"
//                               " of advertising campaigns.",style: TextStyle(
//                               fontSize: 16,letterSpacing: 0.5
//                           ),),
//       const SizedBox(height: 16),
//       Text("Third-Party Cookies",
//                       style: TextStyle(
//                           fontSize: 17,
//                           letterSpacing: 0.5,
//                           fontWeight: FontWeight.bold
//                       ),textAlign: TextAlign.left,),
//       const SizedBox(height: 6),
//       Text("In addition to our own cookies, we may also use various third-party "
//                               "cookies to report usage statistics of the website and deliver advertisements on "
//                               "and through the website.",style: TextStyle(
//                               fontSize: 16,letterSpacing: 0.5
//                           ),),
//       const SizedBox(height: 16),
//       Text("Your Choices Regarding Cookies",
//                       style: TextStyle(
//                           fontSize: 17,
//                           letterSpacing: 0.5,
//                           fontWeight: FontWeight.bold
//                       ),textAlign: TextAlign.left,),
//       const SizedBox(height: 6),
//       Text("You have the right to decide whether to accept or reject cookies."
//                               " You can set your web browser to refuse cookies or to alert you when cookies"
//                               " are being sent. However, if you choose to refuse cookies, you may not be able "
//                               "to use some portions of our website.",style: TextStyle(
//                               fontSize: 16,letterSpacing: 0.5
//                           ),),
//       const SizedBox(height: 16),
//       Text("Managing Cookies",
//                       style: TextStyle(
//                           fontSize: 17,
//                           letterSpacing: 0.5,
//                           fontWeight: FontWeight.bold
//                       ),textAlign: TextAlign.left,),
//       const SizedBox(height: 6),
//       Text("Most web browsers allow you to control cookies through their settings"
//                               " preferences.",style: TextStyle(
//                               fontSize: 16,letterSpacing: 0.5
//                           ),),
//       const SizedBox(height: 16),
//       Text("Changes to This Cookie Policy",
//                       style: TextStyle(
//                           fontSize: 17,
//                           letterSpacing: 0.5,
//                           fontWeight: FontWeight.bold
//                       ),textAlign: TextAlign.left,),
//       const SizedBox(height: 6),
//       Text("We may update our Cookie Policy from time to time to reflect "
//                               "changes in our practices or for other operational, legal, or regulatory reasons. "
//                               "We encourage you to periodically review this page for the latest information on our "
//                               "cookie practices.",style: TextStyle(
//                               fontSize: 16,letterSpacing: 0.5
//                           ),),
//
//                 ]
//             )
//         )
//     );
//   }
//   Container buildMyNavBar(BuildContext context) {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ distributes space correctly
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           GestureDetector(
//             onTap: () async {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
//             },
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Image.asset("assets/images/home.png", height: 25),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(right: 20.0), // consistent spacing from right edge
//             child: IconButton(
//               enableFeedback: false,
//               onPressed: () {
//                 setState(() {
//                   if (token == '') {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => Profile_Login()));
//                   } else {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
//                   }
//                 });
//               },
//               icon: pageIndex == 3
//                   ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
//                   : const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
//             ),
//           ),
//         ],
//       ),
//
//     );
//   }
// }