import 'package:drawerdemo/screen/create_password.dart';
import 'package:drawerdemo/screen/login.dart';
import 'package:drawerdemo/screen/login_page.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(const EmaiLogin());

}
class EmaiLogin extends StatelessWidget {
  const EmaiLogin({Key ? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EmaiLoginDemo(),
    );
  }
}
class EmaiLoginDemo extends StatefulWidget {
  @override
  _EmaiLoginDemoState createState() => _EmaiLoginDemoState();
}
class _EmaiLoginDemoState extends State<EmaiLoginDemo> {

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
        padding: const EdgeInsets.only(top: 150.0),
    child: Center(
    child: SizedBox(
    width: 150,
    height: 55,
    child: Image.asset('assets/images/app_icon.png')),
    ),
    ),
    //textlogo
    Padding(
    padding: const EdgeInsets.only(top:5),
    child: Center(
    child: SizedBox(
    width: 150,
    height: 40,
    child: Image.asset('assets/images/logo-text.png')),
    ),
    ),

          Container(
            height: 340,
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
                    width: 350,
                    height: 50,
                    padding: const EdgeInsets.only(top: 5),
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
                        Text("    neethupbaby95@gmail.com",style:
                        TextStyle(color: Colors.grey),),
                        Container(
                          width: 100,
                        ),
                        Icon(Icons.check,color: Colors.green,)
                      ],
                    ),
                  ),
                ),
                //facebook button
                Padding(
                  padding: const EdgeInsets.only(
                      left: 14.0, right: 14.0, top: 15, bottom: 0),
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
                            hintText: '   Password',
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