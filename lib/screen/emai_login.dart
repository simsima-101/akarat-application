import 'dart:convert';

import 'package:Akarat/model/loginmodel.dart';
import 'package:Akarat/model/registermodel.dart';
import 'package:Akarat/screen/create_password.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/login_page.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/utils/Validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/shared_preference_manager.dart';

class EmaiLogin extends StatefulWidget {
  const EmaiLogin({super.key, required this.data});
  final String data;
  @override
  State<EmaiLogin> createState() => _EmaiLoginState();
}
class _EmaiLoginState extends State<EmaiLogin> {

  bool passwordVisible=false;
  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();
  final passwordController = TextEditingController();
  @override
  void initState(){
    super.initState();
    passwordVisible=true;
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
            height: screenSize.height*0.36,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 25,left: 20,right: 20),
            padding: const EdgeInsets.only(top: 15,bottom: 00),
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.circular(10.0),
              color: Color(0xFFF5F5F5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: const Offset(
                    0.0,
                    0.0,
                  ),
                  blurRadius: 0.1,
                  spreadRadius: 0.1,
                ), //BoxShadow
                BoxShadow(
                  color: Colors.white,
                  offset: const Offset(0.0, 0.0),
                  blurRadius: 0.0,
                  spreadRadius: 0.0,
                ), //BoxShadow
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
            GestureDetector(
            onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
          },
            child:
            Text("   Back",style: TextStyle(
                      color: Colors.blue,
                      fontSize: 17,
                    ),textAlign: TextAlign.left,),
            ),

                  ],
                ),
        Padding(padding: const EdgeInsets.only(top: 10,left: 14),
         child:  Text("Welcome to Akarat!                                  ",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,letterSpacing: 0.5
          ),),
        ),
      Padding(padding: const EdgeInsets.only(left: 14,top: 8),
       child:  Text("View saved Properties Keep Search history across devices see"
            " which properties you have contacted.",
          style: TextStyle(fontSize: 14,letterSpacing: 0.5),
          softWrap: true,),
      ),

                //google button
                Padding(
                  padding: const EdgeInsets.only(
                      left: 14, right: 14.0, top: 15, bottom: 0),
                  child: Container(
                    width: screenSize.width*0.9,
                    height: screenSize.height*0.05,
                    padding: const EdgeInsets.only(top: 2,left: 8),
                    decoration: BoxDecoration(

                      borderRadius: BorderRadiusDirectional.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: const Offset(
                            0.3,
                            0.3,
                          ),
                          blurRadius: 0.3,
                          spreadRadius: 0.3,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white,
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(    widget.data,style:
                        TextStyle(color: Colors.grey),),
                        Container(
                          width: screenSize.width*0.35
                        ),
                        Icon(Icons.check,color: Colors.green,)
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 14.0, right: 14.0, top: 15, bottom: 0),
                  child: Container(
                    width: screenSize.width*0.9,
                    height: screenSize.height*0.05,
                    padding: const EdgeInsets.only(top: 5,left: 8),
                    decoration: BoxDecoration(

                      borderRadius: BorderRadiusDirectional.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: const Offset(
                            0.3,
                            0.3,
                          ),
                          blurRadius: 0.3,
                          spreadRadius: 0.3,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white,
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                    ),

                    child:   TextFormField(
                      obscureText: passwordVisible,
                      controller: passwordController,
                      validator: (value){
                        if(value!.isEmpty) {
                          return 'Empty';
                        }
                        else{
                          Validator.validatePassword(value ?? "");
                        }
                        return null;
                      },
                      // validator: (value) => Validator.validatePassword(value ?? ""),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        //  fillColor: Colors.white,
                        hintText: '  Password',
                        hintStyle: TextStyle(color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(
                                  () {
                                passwordVisible = !passwordVisible;
                              },
                            );
                          },
                        ),
                        alignLabelWithHint: false,
                        // filled: true,
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                    ),
                        ),

                  ),
                //button
        Padding(
                  padding: const EdgeInsets.only(
                      left: 14.0, right: 14.0, top: 15, bottom: 0),
                  child: Container(
                    width: screenSize.width*0.9,
                    height: screenSize.height*0.05,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadiusDirectional.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: const Offset(
                            0.3,
                            0.3,
                          ),
                          blurRadius: 0.3,
                          spreadRadius: 0.3,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white,
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                    ),
                    child: InkWell(
                        onTap: (){
                          loginUsers(widget.data);
                         // Navigator.push(context, MaterialPageRoute(builder: (context)=> CreatePassword()));
                        },
                        child: Text('Log in',textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 17,
                              color: Colors.white),)),
                  ),
                ),
              ],
            ),
          ),
          //text
          Padding(
            padding: const EdgeInsets.only(
                left:0.0,top: 15.0),

            child: Center(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 62),
                    child: Text('Not registered yet? ',style: TextStyle(
                      color: Color(0xFF424242),fontSize: 13,
                    ),),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left:1.0),
                    child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginPage()));
                        },
                        child: Text('Create new account', style: TextStyle(fontSize: 15, color: Colors.black,
                        fontWeight: FontWeight.bold),)),
                  )
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
}