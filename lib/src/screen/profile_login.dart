// import 'package:Akarat/screen/about_us.dart';
// import 'package:Akarat/screen/advertising.dart';
// import 'package:Akarat/screen/blog.dart';
// import 'package:Akarat/screen/cookies.dart';
// import 'package:Akarat/screen/favorite.dart';
// import 'package:Akarat/screen/findagent.dart';
// import 'package:Akarat/screen/home.dart';
// import 'package:Akarat/screen/login.dart';
// import 'package:Akarat/screen/privacy.dart';
// import 'package:Akarat/screen/support.dart';
// import 'package:Akarat/screen/terms_condition.dart';
// import 'package:flutter/material.dart';
//
// import '../secure_storage.dart';
// import '../utils/shared_preference_manager.dart';
// import 'login_page.dart';
// import 'my_account.dart';
// import 'settingstile.dart';
//
// void main(){
//   runApp(const Profile_Login());
//
// }
//
// class Profile_Login extends StatelessWidget {
//   const Profile_Login({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Profile_LoginDemo(),
//     );
//   }
// }
// class Profile_LoginDemo extends StatefulWidget {
//   @override
//   _Profile_LoginDemoState createState() => _Profile_LoginDemoState();
// }
// class _Profile_LoginDemoState extends State<Profile_LoginDemo> {
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
//   Widget build(BuildContext context) {
//     Size screenSize = MediaQuery.sizeOf(context);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             const SizedBox(height: 30),
//
//             const SizedBox(height: 10),
//             // Subscription Offer Box
//             // Container(
//             //   width: screenSize.width * 0.8,
//             //   margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             //   padding: const EdgeInsets.all(12),
//             //   decoration: BoxDecoration(
//             //     color: Colors.white,
//             //     boxShadow: [
//             //       BoxShadow(
//             //         color: Colors.grey.withOpacity(0.5),
//             //         offset: const Offset(4, 4),
//             //         blurRadius: 8,
//             //         spreadRadius: 2,
//             //       ),
//             //       BoxShadow(
//             //         color: Colors.white.withOpacity(0.8),
//             //         offset: const Offset(-4, -4),
//             //         blurRadius: 8,
//             //         spreadRadius: 2,
//             //       ),
//             //     ],
//             //     borderRadius: BorderRadius.circular(10),
//             //   ),
//             //   child: Column(
//             //     children: [
//             //       const Text("Hurry!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.red)),
//             //       const SizedBox(height: 5),
//             //       const Text("Enjoy a FREE Subscription for all of 2025",
//             //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
//             //       const SizedBox(height: 10),
//             //       ElevatedButton(
//             //         onPressed: () {
//             //           Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
//             //         },
//             //         style: ElevatedButton.styleFrom(
//             //           backgroundColor: Colors.black,
//             //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             //         ),
//             //         child: const Text("Sign up Now!", style: TextStyle(color: Colors.white, fontSize: 14)),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             const SizedBox(height: 10),
//             // Settings Options
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 children: [
//                   _settingsTile("Find My Agent", "assets/images/find-my-agent.png", () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => FindAgentDemo()));
//                   }),
//                   _settingsTile("Favorites", "assets/images/favourites.png", () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => Favorite()));
//                   }),
//                   _settingsTile("About Us", "assets/images/about.png", () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => About_Us()));
//                   }),
//                   // _settingsTile("Blogs", "assets/images/blog.png", () {
//                   //   Navigator.push(context, MaterialPageRoute(builder: (context) => Blog()));
//                   // }),
//                   // _settingsTile("Advertising", "assets/images/advertise.png", () {
//                   //   Navigator.push(context, MaterialPageRoute(builder: (context) => Advertising()));
//                   // }),
//                   _settingsTile("Support", "assets/images/support.png", () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => Support()));
//                   }),
//                   _settingsTile("Privacy Policy", "assets/images/privacy-policy.png", () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => Privacy()));
//                   }),
//                   _settingsTile("Terms And Conditions", "assets/images/terms-and-conditions.png", () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => TermsCondition()));
//                   }),
//                   // _settingsTile("Cookies", "assets/images/cookies.png", () {
//                   //   Navigator.push(context, MaterialPageRoute(builder: (context) => Cookies()));
//                   // }),
//                   // ✅ Here is the new Logout option:
//                   _settingsTile("Logout", "", () {
//                     SecureStorage.deleteToken();  // optional: clears token
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (_) => LoginPage()),
//                           (route) => false,
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _circularIconButton(String asset, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 35,
//         width: 35,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.4),
//               blurRadius: 3,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(7),
//           child: Image.asset(asset, fit: BoxFit.contain),
//         ),
//       ),
//     );
//   }
//
//   BoxDecoration _avatarBoxDecoration() {
//     return BoxDecoration(
//       shape: BoxShape.circle,
//       color: Colors.white,
//       boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.3),
//           blurRadius: 3,
//           offset: const Offset(0, 1),
//         ),
//       ],
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
//
// Widget _settingsTile(String title, String iconPath, VoidCallback onTap) {
//   return Column(
//     children: [
//       GestureDetector(
//         onTap: onTap,
//         child: ListTile(
//           leading: iconPath.isNotEmpty
//               ? Image.asset(iconPath, width: 28)
//               : null,
//           title: Text(title, style: const TextStyle(fontSize: 16)),
//           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//         ),
//       ),
//       const Divider(height: 1),
//     ],
//   );
// }
