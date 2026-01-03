// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../core/utils/secure_storage.dart'; // Adjust path if needed
// import '../features/property/presentation/bloc/favorite_bloc.dart';
// import '../features/property/presentation/bloc/favorite_event.dart';
// import '../utils/fav_logout.dart';
// import 'ContactFormScreen.dart';
// import 'home.dart';
//
// import 'my_account.dart';
// import 'login.dart';
//
// // Optional: Your contact dialog function
// import 'home.dart'; // if showHomeContactDialog is defined here
//
// class MainTabScreen extends StatefulWidget {
//   final int initialIndex;  // ← NEW: Allows opening on specific tab
//
//   const MainTabScreen({super.key, this.initialIndex = 0}); // Default to Home (tab 0)
//
//   @override
//   State<MainTabScreen> createState() => _MainTabScreenState();
// }
//
// class _MainTabScreenState extends State<MainTabScreen> {
//   late int _selectedIndex;
//
//   final List<Widget> _screens = [
//     const Home(),                    // Tab 0
//     const Fav_Logout(),              // Tab 1 - Favorites
//     const Scaffold(body: Center(child: Text("Contact Page"))), // Tab 2
//     const My_Account(),              // Tab 3 - Account
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.initialIndex;  // Start on the requested tab
//   }
//
//   void _onTabSelected(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: _buildNavBar(context),
//     );
//   }
//
//   Widget _buildNavBar(BuildContext context) {
//     return Container(
//       height: 50,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Home
//           GestureDetector(
//             onTap: () => _onTabSelected(0),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Image.asset(
//                 "assets/images/home.png",
//                 height: 25,
//                 color: _selectedIndex == 0 ? const Color(0xFFE01E26) : Colors.grey,
//               ),
//             ),
//           ),
//
//           // Favorites
//           IconButton(
//             enableFeedback: false,
//             onPressed: () async {
//               final token = await SecureStorage.getToken();
//
//               if (token == null || token.isEmpty) {
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     backgroundColor: Colors.white,
//                     title: const Text("Login Required", style: TextStyle(color: Colors.black)),
//                     content: const Text("Please login to access favorites.", style: TextStyle(color: Colors.black)),
//                     actions: [
//                       TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.red))),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
//                         },
//                         child: const Text("Login", style: TextStyle(color: Colors.red)),
//                       ),
//                     ],
//                   ),
//                 );
//               } else {
//                 _onTabSelected(1);
//                 context.read<FavoriteBloc>().add(LoadFavorites()); // Refresh
//               }
//             },
//             icon: _selectedIndex == 1
//                 ? const Icon(Icons.favorite, color: Color(0xFFE01E26), size: 30)
//                 : const Icon(Icons.favorite_border_outlined, color: Color(0xFFE01E26), size: 30),
//           ),
//
//           // Contact / Email
//           IconButton(
//             icon: const Icon(Icons.email_outlined, color: Color(0xFFE01E26), size: 28),
//             onPressed: () {
//               _onTabSelected(2);
//               showHomeContactDialog(context); // Your function
//             },
//           ),
//
//           // Account
//           Padding(
//             padding: const EdgeInsets.only(right: 20.0),
//             child: IconButton(
//               enableFeedback: false,
//               onPressed: () => _onTabSelected(3),
//               icon: _selectedIndex == 3
//                   ? const Icon(Icons.dehaze, color: Color(0xFFE01E26), size: 35)
//                   : const Icon(Icons.dehaze_outlined, color: Color(0xFFE01E26), size: 35),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }