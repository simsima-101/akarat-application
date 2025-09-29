import 'package:flutter/material.dart';
import 'package:Akarat/services/api_service.dart';

import 'home.dart';
import 'login.dart';

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
        BoxShadow(color: Colors.grey, offset: Offset(0, 0), blurRadius: 0.1, spreadRadius: 0.1),
        BoxShadow(color: Colors.white, offset: Offset(0, 0), blurRadius: 0, spreadRadius: 0),
      ],
    );
  }

  Future<void> onRegisterButtonPressed() async {
    if (!_formKey.currentState!.validate()) return;

    // close keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase(); // normalize email
    final password = passwordController.text.trim();

    try {
      // STEP A: Send OTP
      final res = await ApiService.sendRegisterOtp(email: email);
      if (!mounted) return;

      final msg = (res['message'] as String?) ?? 'We sent a 6-digit code to your email.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      // STEP B: Navigate via the ROOT navigator so it finds your named route
      Navigator.of(context, rootNavigator: true).pushNamed(
        '/verify-otp',
        arguments: {
          'mode': 'register',
          'name': name,
          'email': email,
          'password': password,
          'expiresIn': res['expires_in'],
          'resendAfter': res['resend_after'],
        },
      );

      // If you still ever hit routing issues, uncomment this hard push which bypasses the routes table:
      // Navigator.of(context, rootNavigator: true).push(
      //   MaterialPageRoute(
      //     builder: (_) => const OtpVerificationScreen(),
      //     settings: RouteSettings(arguments: {
      //       'mode': 'register',
      //       'name': name,
      //       'email': email,
      //       'password': password,
      //       'expiresIn': res['expires_in'],
      //       'resendAfter': res['resend_after'],
      //     }),
      //   ),
      // );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                      MaterialPageRoute(builder: (_) => const Home()),
                    );
                  },
                  child: const Icon(Icons.close, size: 28, color: Colors.black),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Center(
                child: SizedBox(width: 150, height: 55, child: Image.asset('assets/images/app_icon.png')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Center(
                child: SizedBox(width: 150, height: 40, child: Image.asset('assets/images/logo-text.png')),
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
                          const Text("Create an account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),

                          Container(
                            width: screenSize.width * 0.85,
                            decoration: _boxDecoration(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Name'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Container(
                            width: screenSize.width * 0.85,
                            decoration: _boxDecoration(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Email'),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please enter your email';
                                if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                                  return 'Invalid email format';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),

                          Container(
                            width: screenSize.width * 0.85,
                            decoration: _boxDecoration(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Password'),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please enter your password';
                                if (v.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),

                          Container(
                            width: screenSize.width * 0.85,
                            decoration: _boxDecoration(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Confirm Password'),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please confirm your password';
                                if (v != passwordController.text) return 'Passwords do not match';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 15),

                          SizedBox(
                            width: screenSize.width * 0.85,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEEEEEE),
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _isLoading ? null : onRegisterButtonPressed,
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.black)
                                  : const Text("Send Code",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?", style: TextStyle(color: Color(0xFF424242), fontSize: 13)),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginDemo()));
                          },
                          child: const Text("Login Here",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
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
