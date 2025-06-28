import 'dart:convert';

import 'package:Akarat/model/loginmodel.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmaiLogin extends StatefulWidget {
  const EmaiLogin({super.key, required this.data});
  final String data;

  @override
  State<EmaiLogin> createState() => _EmaiLoginState();
}

class _EmaiLoginState extends State<EmaiLogin> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  bool passwordVisible = false;

  SharedPreferencesManager prefManager = SharedPreferencesManager();

  LoginModel? loginModel;
  String result = '';
  String token = '';
  String email = '';
  bool isDataSaved = false;

  Future<void> loginUsers(String emailInput) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        'https://akarat.com/api/login',
        data: {
          'email': emailInput.trim(),
          'password': passwordController.text.trim(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint("Login Status Code: ${response.statusCode}");
      debugPrint("Login Response Body: ${response.data}");

      if (response.statusCode == 200) {
        try {
          final jsonData = response.data;
          loginModel = LoginModel.fromJson(jsonData);

          token = loginModel!.token ?? '';
          email = loginModel!.email ?? '';
          result = loginModel!.name ?? '';

          await prefManager.addStringToPref(token);
          await prefManager.addStringToPrefemail(email);
          await prefManager.addStringToPrefresult(result);

          setState(() {
            isDataSaved = true;
          });

          debugPrint("✅ Login Successful");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => My_Account()),
          );
        } catch (jsonError) {
          debugPrint("❌ Login failed: Unable to parse JSON: $jsonError");
          _showErrorDialog("Login failed: Unexpected server response.");
        }
      } else {
        try {
          final errorResponse = response.data;
          debugPrint("❌ Login failed: ${errorResponse["message"] ?? 'Unknown error'}");
          _showErrorDialog("Login failed: ${errorResponse["message"] ?? 'Please try again.'}");
        } catch (_) {
          debugPrint("❌ Login failed: Non-JSON error response");
          _showErrorDialog("Login failed: Unexpected server response.");
        }
      }
    } on DioError catch (e) {
      debugPrint("🚨 Login DioError: $e");

      String errorMessage = "Something went wrong. Please try again.";

      if (e.response != null) {
        try {
          final errorData = e.response?.data;

          if (e.response?.statusCode == 422) {
            // Check if specific email error is available
            if (errorData["errors"] != null && errorData["errors"]["email"] != null) {
              errorMessage = errorData["errors"]["email"][0];
            } else {
              errorMessage = errorData["message"] ?? "Account not registered.";
            }
          } else {
            // Other error messages
            errorMessage = errorData["message"] ?? errorMessage;
          }

          debugPrint("❌ DioError response message: $errorMessage");
        } catch (_) {
          debugPrint("❌ DioError: Unexpected format in error response.");
        }
      }

      // Show popup error dialog
      _showErrorDialog(errorMessage);
    }
    catch (e) {
      debugPrint("🚨 Login Exception: $e");
      _showErrorDialog("Something went wrong. Please try again.");
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  bool _showClose = true;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, right: 16),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _showClose = false);
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => My_Account(),
                          ));
                        },
                        child: AnimatedScale(
                          scale: _showClose ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 1000),
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
              // Logo
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Center(
                  child: SizedBox(
                    width: screenSize.width * 0.3,
                    height: screenSize.height * 0.06,
                    child: Image.asset('assets/images/app_icon.png'),
                  ),
                ),
              ),
              // Text logo
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Center(
                  child: SizedBox(
                    width: screenSize.width * 0.5,
                    height: screenSize.height * 0.05,
                    child: Image.asset('assets/images/logo-text.png'),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: const Color(0xFFF5F5F5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 0.1,
                      spreadRadius: 0.1,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text("← Back", style: TextStyle(color: Colors.blue, fontSize: 17)),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Welcome to Akarat!",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "View saved properties, keep search history across devices, and see which properties you have contacted.",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 15),
                      _infoCard(context, widget.data),
                      const SizedBox(height: 15),
                      _passwordField(),
                      const SizedBox(height: 15),
                      _loginButton(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 1),
              _registerPrompt(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, String data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _boxDecoration(),
      height: 50,
      width: double.infinity,
      child: Row(
        children: [
          Text(data, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const Spacer(),
          const Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      height: 50,
      decoration: _boxDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextFormField(
        controller: passwordController,
        obscureText: !passwordVisible,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => passwordVisible = !passwordVisible),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter your password';
          return null;
        },
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            loginUsers(widget.data);
          }
        },
        child: const Text('Log in', style: TextStyle(fontSize: 17, color: Colors.white)),
      ),
    );
  }

  Widget _registerPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Not registered yet?", style: TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/register'), // Or use your register screen route
          child: const Text(
            'Create new account',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
