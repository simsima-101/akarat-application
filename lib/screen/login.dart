  import 'package:Akarat/screen/register_screen.dart';
  import 'package:Akarat/screen/forgot_password.dart'; // <-- Add this import

  import 'secure_storage.dart';
  import 'package:flutter/material.dart';
  import 'package:Akarat/screen/profile_login.dart';
  import 'package:Akarat/services/api_service.dart';
  import 'package:Akarat/screen/home.dart';

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
            await SecureStorage.write('token', token);

            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const Home()),
                  (route) => false,
            );
          } else {
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
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0, right: 16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => showClose = false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const Profile_Login()),
                              );
                            },
                            child: AnimatedScale(
                              scale: showClose ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOut,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  "assets/images/close1.png",
                                  height: 18,
                                  width: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 140),

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

                          Container(
                            width: screenWidth * 0.8,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300, // grey background
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/gi.webp",
                                    height: 24,
                                    color: Colors.grey, // tint image grey (optional)
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Continue with Google(Coming Soon)", // mark disabled
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                      fontSize: 8
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),


                          const SizedBox(height: 10),
                          const Text("or", style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 10),

                          Container(
                            width: screenWidth * 0.8,
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

                          // Password field and "Forgot password?" link
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: screenWidth * 0.8,
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
                                      contentPadding: EdgeInsets.only(top: 16),
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
                              // "Forgot password?" link (right aligned below password)
                              Padding(
                                padding: EdgeInsets.only(right: 10, top: 4),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ForgotPasswordScreen(),
                                      ),
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
                              minimumSize: Size(screenWidth * 0.8, 50),
                              backgroundColor: Color(0xFFF1F1F1), // <-- Button background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 1,
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF000000), // <-- Button text color
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
                                    MaterialPageRoute(builder: (_) => RegisterScreen())),
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
                ],
              ),

              // 🔴 Error Message Popup
              if (errorMessage != null)
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              errorMessage = null;
                            });
                          },
                        ),
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