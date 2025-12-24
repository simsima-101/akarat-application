// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../secure_storage.dart';
// import '../screen/home.dart';
// import '../screen/login.dart';
//
// import '../utils/fav_logout.dart';
// import 'my_account.dart';
//
// class MyNavBar extends StatelessWidget {
//   const MyNavBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 60,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           // Home
//           GestureDetector(
//             onTap: () => Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const Home()),
//             ),
//             child: Image.asset("assets/images/home.png", height: 28),
//           ),
//           // Favorites
//           IconButton(
//             onPressed: () async {
//               final token = await SecureStorage.getToken();
//               if (token == null || token.isEmpty) {
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginDemo()));
//               } else {
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => const Fav_Logout()));
//               }
//             },
//             icon: const Icon(Icons.favorite_border, color: Colors.red, size: 30),
//           ),
//           // Email
//           IconButton(
//             icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
//             onPressed: () async {
//               final Uri emailUri = Uri.parse('mailto:info@akarat.com');
//               if (await canLaunchUrl(emailUri)) await launchUrl(emailUri);
//             },
//           ),
//           // Menu
//           IconButton(
//             icon: const Icon(Icons.dehaze, color: Colors.red, size: 35),
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const My_Account()),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
