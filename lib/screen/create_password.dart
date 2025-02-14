import 'package:drawerdemo/screen/emai_login.dart';
import 'package:drawerdemo/screen/login.dart';
import 'package:drawerdemo/screen/my_account.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(const CreatePassword());

}
class CreatePassword extends StatelessWidget {
  const CreatePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreatePasswordDemo(),
    );
  }
}
class CreatePasswordDemo extends StatefulWidget {
  const CreatePasswordDemo({super.key});

  @override
  _CreatePasswordDemoState createState() => _CreatePasswordDemoState();
}
class _CreatePasswordDemoState extends State<CreatePasswordDemo> {

  bool passwordVisible=false;
  @override
  void initState(){
    super.initState();
    passwordVisible=true;
  }

  @override
  Widget build(BuildContext context) {
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

                    Container(
                      height: 400,
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
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> EmaiLogin()));
                    },
                      child:
                      Text("    Back",style: TextStyle(
                                color: Colors.blue,
                                fontSize: 17,
                              ),textAlign: TextAlign.left,),),

                            ],
                          ),
                          Padding(padding: const EdgeInsets.only(top: 10,left: 15),
                            child:  Text("Create a Password                                 ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,letterSpacing: 0.5
                              ),),
                          ),
                          Padding(padding: const EdgeInsets.only(left: 15,top: 2),
                            child:  Text("View saved Properties Keep Search history across devices see"
                                " which properties you have contacted.",
                              style: TextStyle(fontSize: 14,letterSpacing: 0.5),
                              softWrap: true,),
                          ),

                          //google button
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15.0, top: 15, bottom: 0),
                            child: Container(
                              width: 350,
                              height: 50,
                              padding: const EdgeInsets.only(top: 4,left: 15),
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
                              child: TextField(
                               // obscureText: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Name',hintStyle: TextStyle(color: Colors.grey)
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0),
                            child: Container(
                              width: 350,
                              height: 50,
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

                              child:   TextField(
                                obscureText: passwordVisible,
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
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 15, bottom: 0),
                            child: Container(
                              width: 350,
                              height: 50,
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

                              child:   TextField(
                                obscureText: passwordVisible,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  fillColor: Colors.white,
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
                                //  filled: true,
                                ),
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                              ),
                            ),

                          ),
                          //button
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 18, bottom: 0),
                            child: Container(
                              width: 350,
                              height: 50,
                              padding: const EdgeInsets.only(top: 13),
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
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));
                                  },
                                  child: Text('Create Account',textAlign: TextAlign.center,
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
                          left:15.0,top: 15.0),

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
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                                  },
                                  child: Text('Login Here', style: TextStyle(
                                      fontWeight:FontWeight.bold,
    fontSize: 15, color: Colors.black),)),
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