// import 'package:Akarat/screen/create_password.dart';
// import 'package:Akarat/screen/login.dart';
// import 'package:Akarat/screen/profile_login.dart';
// import 'package:Akarat/utils/Validator.dart';
// import 'package:flutter/material.dart';
// import 'package:Akarat/services/api_service.dart';
// import 'package:Akarat/secure_storage.dart';
// import 'package:Akarat/screen/home.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import 'forgot_password.dart';
//
// // ... your imports ...
//
//
// void main() {
//   runApp(const LoginPage());
// }
//
// class LoginPage extends StatelessWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LoginPageDemo(),
//     );
//   }
// }
//
// class LoginPageDemo extends StatefulWidget {
//   @override
//   _LoginPageDemoState createState() => _LoginPageDemoState();
// }
//
// class _LoginPageDemoState extends State<LoginPageDemo> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   final _formKey = GlobalKey<FormState>();
//   bool _showClose = true;
//
//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Column(children: <Widget>[
//           const SizedBox(height: 30),
//           // Stack(
//           //   children: [
//           //     Align(
//           //       alignment: Alignment.topRight,
//           //       child: Padding(
//           //         padding: const EdgeInsets.only(top: 0, right: 16),
//           //         child: GestureDetector(
//           //           // onTap: () {
//           //           //   setState(() => _showClose = false);
//           //           //   Navigator.push(context,
//           //           //       MaterialPageRoute(builder: (_) => Profile_Login()));
//           //           // },
//           //           child: AnimatedScale(
//           //             scale: _showClose ? 1.0 : 0.0,
//           //             duration: const Duration(milliseconds: 1000),
//           //             curve: Curves.easeInOut,
//           //             child: Container(
//           //               padding: const EdgeInsets.all(10),
//           //               decoration: BoxDecoration(
//           //                 color: Colors.white,
//           //                 shape: BoxShape.circle,
//           //                 boxShadow: const [
//           //                   BoxShadow(
//           //                     color: Colors.black12,
//           //                     blurRadius: 6,
//           //                     offset: Offset(2, 2),
//           //                   ),
//           //                 ],
//           //               ),
//           //               child: Image.asset(
//           //                 "assets/images/close1.png",
//           //                 height: 18,
//           //                 width: 18,
//           //               ),
//           //             ),
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //   ],
//           // ),
//           Padding(
//             padding: const EdgeInsets.only(top: 100.0),
//             child: Center(
//               child: SizedBox(
//                   width: 150,
//                   height: 55,
//                   child: Image.asset('assets/images/app_icon.png')),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 0),
//             child: Center(
//               child: SizedBox(
//                   width: 150,
//                   height: 40,
//                   child: Image.asset('assets/images/logo-text.png')),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 25.0, left: 20, right: 20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10.0),
//                       color: const Color(0xFFF5F5F5),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.grey,
//                           offset: Offset(0.0, 0.0),
//                           blurRadius: 0.1,
//                           spreadRadius: 0.1,
//                         ),
//                         BoxShadow(
//                           color: Colors.white,
//                           offset: Offset(0.0, 0.0),
//                           blurRadius: 0.0,
//                           spreadRadius: 0.0,
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         const Text(
//                           "Create an account",
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 10),
//
//                         // Google Button (currently UI only)
//                         // Container(
//                         //   width: screenSize.width * 0.8,
//                         //   height: 50,
//                         //   decoration: BoxDecoration(
//                         //     color: Colors.grey.shade300, // grey background
//                         //     borderRadius: BorderRadius.circular(10.0),
//                         //     boxShadow: [
//                         //       BoxShadow(
//                         //         color: Colors.grey.withOpacity(0.3),
//                         //         offset: const Offset(2, 2),
//                         //         blurRadius: 4,
//                         //         spreadRadius: 1,
//                         //       ),
//                         //     ],
//                         //   ),
//                         //   child: Padding(
//                         //     padding: const EdgeInsets.symmetric(horizontal: 16.0), // reduced padding
//                         //     child: Row(
//                         //       mainAxisAlignment: MainAxisAlignment.center, // center content
//                         //       children: [
//                         //         Image.asset(
//                         //           "assets/images/gi.webp",
//                         //           height: 22, // slightly smaller
//                         //           color: Colors.grey, // optional: tint image to grey
//                         //         ),
//                         //         const SizedBox(width:2),
//                         //         Flexible(
//                         //           child: Text(
//                         //             "Continue with Google(Coming Soon)", // mark disabled
//                         //             style: TextStyle(
//                         //               fontSize: 8, // smaller font to prevent overflow
//                         //               fontWeight: FontWeight.bold,
//                         //               color: Colors.grey.shade700,
//                         //             ),
//                         //             overflow: TextOverflow.ellipsis, // safe if text still too long
//                         //           ),
//                         //         ),
//                         //       ],
//                         //     ),
//                         //   ),
//                         // ),
//
//
//
//                         // const SizedBox(height: 10),
//                         // const Text("or",
//                         //     style: TextStyle(color: Colors.grey, fontSize: 17)),
//                         const SizedBox(height: 10),
//
//                         // Email Field
//                         Container(
//                           width: screenSize.width * 0.85,
//                           decoration: _boxDecoration(),
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: TextFormField(
//                             controller: emailController,
//                             keyboardType: TextInputType.emailAddress,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                               hintText: 'Email',
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your email';
//                               }
//                               if (!RegExp(
//                                   r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                                   .hasMatch(value)) {
//                                 return 'Invalid email format';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//
//                         const SizedBox(height: 10),
//
//                         // Password Field
//                         Container(
//                           width: screenSize.width * 0.85,
//                           decoration: _boxDecoration(),
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: TextFormField(
//                             controller: passwordController,
//                             obscureText: true,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                               hintText: 'Password',
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your password';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//
//                         // FORGOT PASSWORD LINK (Right aligned, below password field)
//                         Container(
//                           width: screenSize.width * 0.85,
//                           padding: const EdgeInsets.only(top: 4, right: 0),
//                           alignment: Alignment.centerRight,
//                           child: InkWell(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => ForgotPasswordScreen(), // <-- Replace with your forgot password screen
//                                 ),
//                               );
//                             },
//                             child: const Text(
//                               "Forgot password?",
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//
//                               ),
//                               textAlign: TextAlign.right,
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 15),
//
//                         // Continue Button
//                         SizedBox(
//                           width: screenSize.width * 0.85,
//                           height: 50,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFEEEEEE),
//                               elevation: 1,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 _login();
//                               }
//                             },
//                             child: const Text("Continue",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Already have an account?",
//                           style: TextStyle(
//                               color: Color(0xFF424242), fontSize: 13)),
//                       const SizedBox(width: 4),
//                       InkWell(
//                         onTap: () {
//                           Navigator.push(context,
//                               MaterialPageRoute(builder: (_) => Login()));
//                         },
//                         child: const Text("Login Here",
//                             style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black)),
//                       )
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
//
//   BoxDecoration _boxDecoration() {
//     return BoxDecoration(
//       color: const Color(0xFFF5F5F5),
//       borderRadius: BorderRadius.circular(10),
//       boxShadow: const [
//         BoxShadow(
//           color: Colors.grey,
//           offset: Offset(0, 0),
//           blurRadius: 0.1,
//           spreadRadius: 0.1,
//         ),
//         BoxShadow(
//           color: Colors.white,
//           offset: Offset(0, 0),
//           blurRadius: 0,
//           spreadRadius: 0,
//         ),
//       ],
//     );
//   }
//
//   void _login() async {
//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();
//
//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Email and password cannot be empty")),
//       );
//       return;
//     }
//
//     try {
//       final response =
//       await ApiService.loginUser(email: email, password: password);
//       final token = response['token'];
//
//       if (token != null) {
//         // Save token securely for future API requests
//         await SecureStorage.writeToken(token);
//
//         // Navigate to home screen replacing the current one
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => Home()),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Login failed: Invalid credentials")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Login error: $e")),
//       );
//     }
//   }
// }