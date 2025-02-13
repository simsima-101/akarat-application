import 'package:flutter/material.dart';

void main(){
  runApp(const Login());

}

class Login extends StatelessWidget {
  const Login({Key ? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginDemo(),
    );
  }
}
class LoginDemo extends StatefulWidget {
  @override
  _LoginDemoState createState() => _LoginDemoState();
}
class _LoginDemoState extends State<LoginDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[



        //logo
        Padding(
        padding: const EdgeInsets.only(top: 200.0),
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
              height: 55,
              child: Image.asset('assets/images/logo-text.png')),
        ),
      ),

        Container(
            height: 350,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10,left: 20,right: 20),
            padding: const EdgeInsets.only(top: 15,bottom: 00),
            // alignment: Alignment.bottomCenter,
            //transform: Matrix4.rotationZ(0.1),
            decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(10.0),
                border: Border.all(
                    color: Color(0xFFEEEEEE))),

            child: Column(
              children: [
                //welcome text

                Text("Welcome to Akarat!",style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),textAlign: TextAlign.center,),


                //google button
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  child: Container(
                    width: 300,
                    height: 50,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/g.png"),
                      ),
                      borderRadius: BorderRadiusDirectional.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: const Offset(
                            0.5,
                            0.5,
                          ),
                          blurRadius: 1.0,
                          spreadRadius: 0.5,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white,
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                    ),
                  ),
                ),

                //  Text

                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  child:  Text("or",style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),textAlign: TextAlign.center,),
                ),

                //edittext

                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  child: Container(
                    width: 300,
                    height: 50,
                    padding: const EdgeInsets.only(top: 10,left: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: const Offset(
                            0.5,
                            0.5,
                          ),
                          blurRadius: 1.0,
                          spreadRadius: 0.5,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white,
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        /* border: OutlineInputBorder(
                       ),*/
                        border: InputBorder.none,
                        hintText: 'Email',
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),

                //button


                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  child: Container(
                    width: 300,
                    height: 50,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      borderRadius: BorderRadiusDirectional.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: const Offset(
                            0.5,
                            0.5,
                          ),
                          blurRadius: 1.0,
                          spreadRadius: 0.5,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white,
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                    ),

                    child: Text("Continue",style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),textAlign: TextAlign.center,),
                  ),
                ),


                //text
                Padding(
                  padding: const EdgeInsets.only(
                      left:0.0,top: 7.0),

                  child: Container(
                    child: Center(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 62),
                            child: Text('Not registered yet? ',style: TextStyle(
                              color: Colors.grey,fontSize: 13,
                            ),),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left:1.0),
                            child: InkWell(
                                onTap: (){
                                 // Text("hiiii");
                                },
                                child: Text('Create new account', style: TextStyle(fontSize: 14, color: Colors.black),)),
                          )
                        ],
                      ),
                    ),
                  ),

                ),
  ]),
        ),
],

    )
    )
    );

  }
}
