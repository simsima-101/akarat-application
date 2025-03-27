import 'package:Akarat/screen/emai_login.dart';
import 'package:Akarat/screen/login_page.dart';
import 'package:Akarat/utils/Validator.dart';
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
  final emailController = TextEditingController();
  final formkey =GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
        //logo
        Padding(
        padding: const EdgeInsets.only(top: 190.0,bottom: 0),
        child: Center(
          child: SizedBox(
              width: 150,
              height: 50,
              child: Image.asset('assets/images/app_icon.png')),
        ),
      ),

      //textlogo
      Padding(
        padding: const EdgeInsets.only(top:0),
        child: Center(
          child: SizedBox(
              width: 150,
              height: 38,
              child: Image.asset('assets/images/logo-text.png')),
        ),
      ),
        Form(
          key: formkey,
          child: Container(
          // color: Colors.white70,
          height: 310,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 30,left: 20,right: 20),
          padding: const EdgeInsets.only(top: 15,bottom: 00),
          // alignment: Alignment.bottomCenter,
          //transform: Matrix4.rotationZ(0.1),
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
            /* border: Border.all(
                    color: Color(0xFFEEEEEE))*/
          ),
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
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      // image: DecorationImage(
                      //   image: AssetImage("assets/images/g.png"),
                      // ),
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
                        Padding(padding: const EdgeInsets.only(left: 60,top: 0),
                          child:  Image.asset("assets/images/gi.webp",height: 25,
                            alignment: Alignment.center,) ,
                        ),
                        Padding(padding: const EdgeInsets.only(left: 5,top: 0),
                          child:  Text("Continue with Google",style: TextStyle(fontWeight: FontWeight.bold),) ,
                        )

                      ],
                    ),
                  ),
                ),

                //  Text

                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5, bottom: 0),
                  child:  Text("or",style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),textAlign: TextAlign.center,),
                ),

                //edittext
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5, bottom: 0),
                  child: Container(
                    width: 300,
                    height: 50,
                    padding: const EdgeInsets.only(top: 2,left: 10),
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
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty || value == null) {
                          return 'Please Enter EmailId';
                        }
                        else {
                          value.toString().contains('email') == true &&
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value) == false;
                        //  return 'This is not a valid email address.';
                        }
                        return null;
                      },
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                //button
                GestureDetector(
                  onTap: (){
                    /*  if(emailController.text.toString() == null){
                  return 'Empty';
                }
                else{
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> EmaiLogin(data: emailController.text)));
                }*/if(formkey.currentState!.validate()){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> EmaiLogin(data: emailController.text)));
                    }

                  },
                  child:  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 0),
                    child: Container(
                      width: 300,
                      height: 50,
                      padding: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        color: Color(0xFFEEEEEE),
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

                      child: Text("Continue",style: TextStyle(
                        color: Colors.black,fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),textAlign: TextAlign.center,),
                    ),
                  ),
                ),


                //text
                Padding(
                  padding: const EdgeInsets.only(
                      left:0.0,top: 15.0),

                  child: Container(
                    child: Center(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 55),
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
                                child: Text('Create new account', style: TextStyle(fontSize: 14, color: Colors.black,
                                    fontWeight: FontWeight.bold),)),
                          )
                        ],
                      ),
                    ),
                  ),

                ),
              ]),
        ),),

],

    )
    )
    );

  }
}
