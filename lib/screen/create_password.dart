import 'dart:convert';
import 'package:Akarat/model/registermodel.dart';
import 'package:Akarat/screen/emai_login.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/my_account.dart';
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

  Future<void> registerUsers(data) async {
    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "name": myController.text,
          "email": data,
          "password": passwordController.text,
          "password_confirmation": confirmpasswordController.text
          // Add any other data you want to send in the body
        }),
      );

      if (response.statusCode == 200) {
       Map<String, dynamic> jsonData = json.decode(response.body);
          registermodel = RegisterModel.fromJson(jsonData);
          result=registermodel!.name.toString();
          token=registermodel!.token.toString();
          email=registermodel!.email.toString();
          print("Registered Succesfully");
       /*Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
         return My_Account(
           arguments: registermodel[index],
         );
       }));*/
       isDataSaved
           ? const Text('Data Saved!')
           : const Text('Data Not Saved!');
       // Call the addStringToPref method and pass the string value
       prefManager.addStringToPref(token);
       setState(() {
         isDataSaved = true;
       });
          Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
      } else {
        throw Exception("Registration failed");

      }
    } catch (e) {
      setState(() {
      print('Error: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
              child: Column(
                  children: <Widget>[
                    //logo
                    Padding(
                      padding: const EdgeInsets.only(top: 160.0),
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