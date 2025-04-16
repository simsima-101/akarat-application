import 'dart:convert';

import 'package:Akarat/model/loginmodel.dart';
import 'package:Akarat/model/registermodel.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/login_page.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/utils/Validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/shared_preference_manager.dart';

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
  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();
  @override
  void initState(){
    super.initState();
  }
RegisterModel? registerModel;
  LoginModel? loginModel;
  String result = '';
  String token = '';
  String email = '';
  bool isDataSaved = false;
  Future<void> loginUsers(data) async {
    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "email": data,
          "password": passwordController.text,
          // Add any other data you want to send in the body
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        loginModel = LoginModel.fromJson(jsonData);
        result=loginModel!.name.toString();
         token=loginModel!.token.toString();
        email=loginModel!.email.toString();
        print("Registered Succesfully");
        isDataSaved
            ? const Text('Data Saved!')
            : const Text('Data Not Saved!');
        // Call the addStringToPref method and pass the string value
        prefManager.addStringToPref(token);
        prefManager.addStringToPrefemail(email);
        prefManager.addStringToPrefresult(result);
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
    Size screenSize = MediaQuery.sizeOf(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
        //logo
          Padding(
        padding: const EdgeInsets.only(top: 150.0),
    child: Center(
    child: SizedBox(
    width: screenSize.width*0.3,
    height: screenSize.height*0.06,
    child: Image.asset('assets/images/app_icon.png')),
    ),
    ),
          //textlogo
          Padding(
    padding: const EdgeInsets.only(top:5),
    child: Center(
    child: SizedBox(
        width: screenSize.width*0.5,
        height: screenSize.height*0.05,
    child: Image.asset('assets/images/logo-text.png')),
    ),
    ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
            ]
          )
        )
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
          Text(data, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          const Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _boxDecoration(),
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
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage())),
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