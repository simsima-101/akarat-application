import 'package:Akarat/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:Akarat/services/api_service.dart';

import 'home.dart';
import 'login.dart';
// import 'package:Akarat/screen/login.dart'; // Uncomment and update as needed

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Colors.grey,
          offset: Offset(0, 0),
          blurRadius: 0.1,
          spreadRadius: 0.1,
        ),
        BoxShadow(
          color: Colors.white,
          offset: Offset(0, 0),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
    );
  }

  Future<void> onRegisterButtonPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final responseJson = await ApiService.registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        passwordConfirmation: confirmPasswordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      // Uncomment and update navigation as per your app flow
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
    } catch (e) {
      debugPrint('RegisterUser error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [



            const SizedBox(height: 30),

            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => Home()), // 🏠 Go to home screen
                    );
                  },
                  child: const Icon(Icons.close, size: 28, color: Colors.black),
                ),
              ),
            ),
            // You can add a close button or profile navigation here if needed
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Center(
                child: SizedBox(
                    width: 150,
                    height: 55,
                    child: Image.asset('assets/images/app_icon.png')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Center(
                child: SizedBox(
                    width: 150,
                    height: 40,
                    child: Image.asset('assets/images/logo-text.png')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0, left: 20, right: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _boxDecoration(),
                      child: Column(
                        children: [
                          const Text(
                            "Create an account",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),

                          // Google Button (UI only)

                          const SizedBox(height: 10),

                          // Name Field
                          Container(
                            width: screenSize.width * 0.85,
                            decoration: _boxDecoration(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Name',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Email Field
                          Container(
                            width: screenSize.width * 0.85,
                            decoration: _boxDecoration(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Email',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Invalid email format';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Password Field
                          Container(
                            width: screenSize.width * 0.85,
                            decoration: _boxDecoration(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Password',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Confirm Password Field
                          Container(
                            width: screenSize.width * 0.85,
                            decoration: _boxDecoration(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Confirm Password',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Register Button
                          SizedBox(
                            width: screenSize.width * 0.85,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEEEEEE),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isLoading ? null : onRegisterButtonPressed,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                                  : const Text("Register",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?",
                            style: TextStyle(
                                color: Color(0xFF424242), fontSize: 13)),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginDemo(),
                              ),
                            );
                          },
                          child: const Text("Login Here",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}