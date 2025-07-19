import 'dart:convert';

import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/forgot_password.dart'; // <-- Add this import
import 'package:shared_preferences/shared_preferences.dart';

import '../secure_storage.dart';
import '../services/favorite_service.dart';
import 'secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/services/api_service.dart';
import 'package:Akarat/screen/home.dart';

import 'package:http/http.dart' as http;

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoginDemo();
  }
}

class LoginDemo extends StatefulWidget {
  const LoginDemo({Key? key}) : super(key: key);

  @override
  State<LoginDemo> createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool showClose = true;
  bool obscurePassword = true;

  String? errorMessage;


  // void _handleGoogleSignIn() async {
  //   try {
  //     final GoogleSignIn _googleSignIn = GoogleSignIn();
  //     final GoogleSignInAccount? account = await _googleSignIn.signIn();
  //
  //     if (account != null) {
  //       final GoogleSignInAuthentication auth = await account.authentication;
  //       final accessToken = auth.accessToken;
  //
  //       if (accessToken != null) {
  //         final response = await http.post(
  //           Uri.parse('https://akarat.com/api/auth/google-login'),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode({'access_token': accessToken}),
  //         );
  //
  //         final result = jsonDecode(response.body);
  //         if (response.statusCode == 200 && result['token'] != null) {
  //           final token = result['token'];
  //           await SecureStorage.writeToken(token);
  //
  //           // Optional: Save user info
  //           if (result.containsKey('user') && result['user']['name'] != null) {
  //             final prefs = await SharedPreferences.getInstance();
  //             await prefs.setString('user_name', result['user']['name']);
  //           }
  //
  //           // Fetch favorites
  //           final apiFavorites = await FavoriteService.fetchApiFavorites(token);
  //           await FavoriteService.saveFavorites({});
  //           FavoriteService.loggedInFavorites = apiFavorites;
  //
  //           if (!mounted) return;
  //           Navigator.of(context).pushAndRemoveUntil(
  //             MaterialPageRoute(builder: (_) => const Home()),
  //                 (route) => false,
  //           );
  //         } else {
  //           showCustomMessage(result['message'] ?? 'Google login failed');
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Google Sign-In error: $e');
  //     showCustomMessage('Google login failed. Please try again.');
  //   }
  // }




  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showCustomMessage(String message, {Color bgColor = Colors.redAccent}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 80,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => entry.remove(),
                )
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlay.mounted) entry.remove();
    });
  }

  void _login() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null; // clear previous error
    });

    try {
      final result = await ApiService.loginUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (result is Map<String, dynamic>) {
        if (result.containsKey('token') && result['token'] != null) {
          final token = result['token'];
          await SecureStorage.writeToken(token);

          // ✅ Save user name to SharedPreferences
          if (result.containsKey('user') && result['user']['name'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_name', result['user']['name']);
          }

          // ✅ 1. Fetch and optionally cache logged-in favorites
          final apiFavorites = await FavoriteService.fetchApiFavorites(token);

          // ✅ 2. Optional: Clear guest favorites
          await FavoriteService.saveFavorites({});

          // ✅ 3. Store fetched favorites globally (optional)
          FavoriteService.loggedInFavorites = apiFavorites;

          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const Home()),
                (route) => false,
          );
        }

        else {
          // Extract server error message
          String error = 'Unable to login. An unexpected error occurred. Please try logging in again.';
          if (result.containsKey('message')) {
            error = result['message'];
          } else if (result.containsKey('errors')) {
            final errors = result['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstKey = errors.keys.first;
              final firstError = errors[firstKey];
              if (firstError is List && firstError.isNotEmpty) {
                error = firstError.first;
              }
            }
          }

          setState(() {
            errorMessage = error;
          });

          return;
        }
      } else {
        setState(() {
          errorMessage = 'Unexpected response from server';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Unable to login. An unexpected error occurred. Please try logging in again.';
      });

      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) setState(() => errorMessage = null);
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Close button
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const Home()),
                                  (route) => false,
                            );
                          },
                          child: const Icon(Icons.close, size: 28, color: Colors.black),
                        ),
                      ),
                    ),

                    // ✅ Adjust this value to control the gap
                    const SizedBox(height: 60), // Try 50, 100, 300 etc

                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 50,
                        child: Image.asset('assets/images/app_icon.png'),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 38,
                        child: Image.asset('assets/images/logo-text.png'),
                      ),
                    ),

                    Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        padding: const EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFF5F5F5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text("Welcome to Akarat!", style: TextStyle(fontSize: 20)),
                            const SizedBox(height: 15),


                            // Padding(
                            //   padding: const EdgeInsets.only(top: 10),
                            //   child: ElevatedButton.icon(
                            //     onPressed: _handleGoogleSignIn,
                            //     style: ElevatedButton.styleFrom(
                            //       minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
                            //       backgroundColor: Colors.white,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(10),
                            //         side: const BorderSide(color: Colors.black12),
                            //       ),
                            //       elevation: 1,
                            //     ),
                            //     icon: Image.asset(
                            //       'assets/images/gi.webp', // 👈 ensure this is correctly placed in pubspec.yaml
                            //       height: 24,
                            //     ),
                            //     label: const Text(
                            //       'Continue with Google',
                            //       style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                            //     ),
                            //   ),
                            // ),


                            //
                            // const SizedBox(height: 10),
                            //
                            // Center(
                            //   child: Text(
                            //     'or',
                            //     style: TextStyle(
                            //       color: Colors.grey,
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.w500,
                            //     ),
                            //   ),
                            // ),

                            const SizedBox(height: 10),




                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 50,
                              decoration: _boxDecoration(),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Email',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Please enter Email ID';
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Invalid email address';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 6),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  height: 50,
                                  decoration: _boxDecoration(),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Center(
                                    child: TextFormField(
                                      controller: passwordController,
                                      obscureText: obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _login(),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Password',
                                        contentPadding: const EdgeInsets.only(top: 16),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                                          ),
                                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Enter password';
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10, top: 4),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                                      );
                                    },
                                    child: const Text(
                                      "Forgot password?",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
                                backgroundColor: const Color(0xFFF1F1F1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 1,
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ),





                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Not registered yet? ',
                                    style: TextStyle(color: Color(0xFF424242))),
                                InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                                  ),
                                  child: const Text('Create new account',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
                            ],
                          ),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );



  }
}

BoxDecoration _boxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.shade300,
        offset: const Offset(0.3, 0.3),
        blurRadius: 2,
        spreadRadius: 0.2,
      ),
    ],
  );
}