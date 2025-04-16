import 'package:flutter/material.dart';

import 'emai_login.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String data;
  const CreatePasswordScreen({super.key, required this.data});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmaiLogin(data: widget.data),
                            ),
                          );
                        },
                        child: const Text(
                          "← Back",
                          style: TextStyle(color: Colors.blue, fontSize: 17),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Create a Password",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "View saved properties, keep search history across devices, and see which properties you have contacted.",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 15),

                      // Name Field
                      _inputField(
                        context,
                        controller: myController,
                        hintText: 'Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // Password Field
                      _inputField(
                        context,
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: !passwordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        toggleObscure: () => setState(() => passwordVisible = !passwordVisible),
                      ),

                      const SizedBox(height: 15),

                      // Confirm Password Field
                      _inputField(
                        context,
                        controller: confirmpasswordController,
                        hintText: 'Confirm Password',
                        obscureText: !passwordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        toggleObscure: () => setState(() => passwordVisible = !passwordVisible),
                      ),

                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: screenWidth * 0.85,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              registerUsers(widget.data);
                              showDialog(
                                context: context,
                                builder: (_) => const Center(child: CircularProgressIndicator()),
                              );
                            }
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }







  Widget _inputField(
      BuildContext context, {
        required TextEditingController controller,
        required String hintText,
        bool obscureText = false,
        required String? Function(String?) validator,
        VoidCallback? toggleObscure,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          hintText: hintText,
          suffixIcon: toggleObscure != null
              ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: toggleObscure,
          )
              : null,
        ),
      ),
    );
  }

  void registerUsers(String data) {
    // Call your register logic here
  }
}