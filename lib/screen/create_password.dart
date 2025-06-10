import 'dart:convert';
import 'package:Akarat/model/registermodel.dart';
import 'package:Akarat/screen/emai_login.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/utils/Validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/shared_preference_manager.dart';

class CreatePassword extends StatefulWidget {
  const CreatePassword({super.key, required this.data});
  final String data;
  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}
class _CreatePasswordState extends State<CreatePassword> {

  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  bool passwordVisible = false;
  String result = '';
  String token = '';
  String email = '';
  RegisterModel? registermodel;
  bool isDataSaved = false;
  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();
  @override
  void initState(){
    super.initState();
    passwordVisible=true;
  }

  Future<void> registerUsers(String emailInput) async {
    try {
      final url = Uri.parse('https://akarat.com/api/register');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json', // ✅ Important: forces JSON response
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "name": myController.text.trim(),
          "email": emailInput.trim(),
          "password": passwordController.text.trim(),
          "password_confirmation": confirmpasswordController.text.trim(),
        }),
      );

      debugPrint("📡 Status Code: ${response.statusCode}");
      debugPrint("📄 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        registermodel = RegisterModel.fromJson(jsonData);

        token = registermodel!.token ?? '';
        email = registermodel!.email ?? '';
        result = registermodel!.name ?? '';

        await prefManager.addStringToPref(token);
        await prefManager.addStringToPrefemail(email);
        await prefManager.addStringToPrefresult(result);

        setState(() {
          isDataSaved = true;
        });

        debugPrint("✅ Registered Successfully");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => My_Account()),
        );
      } else {
        try {
          final errorResponse = json.decode(response.body);
          _showErrorDialog("Registration failed: ${errorResponse["message"] ?? 'Unknown error'}");
          debugPrint("❌ Registration failed: ${errorResponse["message"]}");
        } catch (_) {
          _showErrorDialog("Registration failed: ${response.body}");
          debugPrint("❌ Server returned non-JSON: ${response.body}");
        }
      }
    } catch (e) {
      debugPrint("🚨 Exception: $e");
      _showErrorDialog("Something went wrong. Please try again later.");
    }
  }


// Optional: Show error in a dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registration Error"),
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
    final screenWidth = MediaQuery.of(context).size.width;
    Size screenSize = MediaQuery.sizeOf(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
              child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20,),
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0, right: 16),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _showClose = false);
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => Profile_Login(),
                                ));
                              },
                              child: AnimatedScale(
                                scale: _showClose ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 1000),
                                curve: Curves.easeInOut,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
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
                    //logo
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Center(
                        child: SizedBox(
                            width: 150,
                            height: 55,
                            child: Image.asset('assets/images/app_icon.png')),
                      ),
                    ),
                    //textlogo
                    Padding(
                      padding: const EdgeInsets.only(top:0),
                      child: Center(
                        child: SizedBox(
                            width: 150,
                            height: 35,
                            child: Image.asset('assets/images/logo-text.png')),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xFFF5F5F5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 0.1,
                                    spreadRadius: 0.1,
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 0.0,
                                    spreadRadius: 0.0,
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
                    //text
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already registered? ',
                              style: TextStyle(
                                color: Color(0xFF424242),
                                fontSize: 13,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                              },
                              child: const Text(
                                'Login Here',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
              )
          )
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
          hintStyle: TextStyle(color: Colors.grey),

          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 15),
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

}