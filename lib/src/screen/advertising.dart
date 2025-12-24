// import 'package:Akarat/screen/home.dart';
// import 'package:Akarat/screen/login.dart';
// import 'package:Akarat/screen/my_account.dart';
// import 'package:Akarat/screen/profile_login.dart';
// import 'package:Akarat/utils/shared_preference_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:Akarat/screen/register_screen.dart';
//
// import '../utils/fav_login.dart';
// import '../utils/fav_logout.dart';
//
// class Advertising extends StatefulWidget {
//   Advertising({super.key,});
//
//
//   @override
//   State<StatefulWidget> createState() => new _AdvertisingState();
// }
//
// class _AdvertisingState extends State<Advertising> {
//
//   int pageIndex = 0;
//
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
//   @override
//   void initState() {
//     readData();
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     Size screenSize = MediaQuery.sizeOf(context);
//     return Scaffold(
//         backgroundColor: Colors.white,
//         bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
//         appBar: AppBar(
//           title: const Text(
//               "Advertise", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//           centerTitle: true,
//           backgroundColor: Colors.white,
//           iconTheme: const IconThemeData(color: Colors.red),
//           elevation: 1,
//         ),
//         body: SingleChildScrollView(
//             child: Column(
//                 children: <Widget>[
//                   Container(
//                     margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
//                     height: screenSize.height*0.06,
//                     width: screenSize.width*0.38,
//                     //color: Colors.grey,
//                     child: Row(
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
//                   Container(
//                     margin: const EdgeInsets.only(left: 10,right: 10,top: 5),
//                     height: screenSize.height*0.04,
//                     width: screenSize.width*0.9,
//                     //color: Colors.grey,
//                     child: Text("Advertise?",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,fontSize: 25,
//                         letterSpacing: 0.5,
//                       ),textAlign: TextAlign.left,),
//                   ),
//                   Container(
//                     height: screenSize.height*0.21,
//                     width: screenSize.width*0.9,
//                     margin: const EdgeInsets.only(left: 20,top: 15,right: 20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           offset: Offset(4, 4),
//                           blurRadius: 8,
//                           spreadRadius: 2,
//                         ),
//                         BoxShadow(
//                           color: Colors.white.withOpacity(0.8),
//                           offset: Offset(-4, -4),
//                           blurRadius: 8,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: Text("Hurry!",style: TextStyle(
//                               fontWeight: FontWeight.bold,fontSize: 25,color: Colors.red
//                           ),),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(0.0),
//                               child: Text("Enjoy a  ",style: TextStyle(
//                                   fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black
//                               ),textAlign: TextAlign.center,),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(0.0),
//                               child: Text("FREE  ",style: TextStyle(
//                                   fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue
//                               ),textAlign: TextAlign.center,),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(3.0),
//                               child: Text("Subscription for all of   ",style: TextStyle(
//                                   fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black
//                               ),textAlign: TextAlign.center,),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(0.0),
//                               child: Text("2025!  ",style: TextStyle(
//                                   fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue
//                               ),textAlign: TextAlign.center,),
//                             ),
//                           ],
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(0.0),
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.black,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
//                             ),
//                             child: Text("Sign up Now!", style: TextStyle(color: Colors.white, fontSize: 17)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(left: 10,right: 10,top: 20),
//                     height: screenSize.height*0.03,
//                     width: screenSize.width*0.9,
//                     // color: Colors.grey,
//                     child: Text("Akarat Membership Plans",
//                       style: TextStyle(
//                           fontSize: 17,
//                           letterSpacing: 0.5,
//                           fontWeight: FontWeight.bold
//                       ),textAlign: TextAlign.left,),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(top: 10),
//                     height: screenSize.height*0.05,
//                     width: screenSize.width*0.9,
//                     // color: Colors.grey,
//                     child: Text("Find the Perfect Plan to Grow Your Real Estate Business!",style: TextStyle(
//                         fontSize: 15.5,letterSpacing: 0.5
//                     ),),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
//                     height: screenSize.height*0.03,
//                     width: screenSize.width*0.9,
//                     // color: Colors.grey,
//                     child: Text("Why Choose Akarat Membership?",
//                       style: TextStyle(
//                           fontSize: 17,
//                           letterSpacing: 0.5,
//                           fontWeight: FontWeight.bold
//                       ),textAlign: TextAlign.left,),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(top: 10),
//                     height: screenSize.height*0.18,
//                     width: screenSize.width*0.9,
//                     // color: Colors.grey,
//                     child: Text("With Akarat, you gain access to a powerful platform that connects your "
//                         "listings to thousands of property seekers across the UAE. Whether you're just starting "
//                         "or looking to scale, our membership plans are designed to meet your business needs."
//                       ,style: TextStyle(
//                         fontSize: 15.5,letterSpacing: 0.5
//                     ),),
//                   ),
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