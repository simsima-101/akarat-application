// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:Akarat/screen/home.dart';
// import 'package:Akarat/utils/fav_logout.dart';
// import 'package:Akarat/screen/my_account.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//
//
//
//   // ✅ Public helper to change tab from any screen
//   static void changeTab(BuildContext context, int index) {
//     final state = context.findAncestorStateOfType<_MainScreenState>();
//     state?.setState(() => state._currentIndex = index);
//   }
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;
//
//   final List<Widget> _screens = [
//     const Home(),
//     const Fav_Logout(),
//     const SizedBox(), // Email is not a screen (will open mail app)
//     const My_Account(),
//   ];
//
//   void _onTabTapped(int index) async {
//     if (index == 2) {
//       // Open email client instead of changing tab
//       final Uri emailUri = Uri.parse('mailto:info@akarat.com?subject=Property%20Inquiry');
//       if (await canLaunchUrl(emailUri)) {
//         await launchUrl(emailUri);
//       }
//       return; // Don't change tab
//     }
//     setState(() => _currentIndex = index);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onTabTapped,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.red,
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
//           BottomNavigationBarItem(icon: Icon(Icons.email_outlined), label: "Email"),
//           BottomNavigationBarItem(icon: Icon(Icons.dehaze), label: "Account"),
//         ],
//       ),
//     );
//   }
// }
