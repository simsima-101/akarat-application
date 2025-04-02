import 'package:Akarat/screen/create_password.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/utils/Validator.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(const LoginPage());

}
class LoginPage extends StatelessWidget {
  const LoginPage({Key ? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPageDemo(),
    );
  }
}
class LoginPageDemo extends StatefulWidget {
  @override
  _LoginPageDemoState createState() => _LoginPageDemoState();
}
class _LoginPageDemoState extends State<LoginPageDemo> {
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  padding: const EdgeInsets.only(top:0),
                  child: Center(
                    child: SizedBox(
                        width: 150,
                        height: 40,
                        child: Image.asset('assets/images/logo-text.png')),
                  ),
                ),
                Container(
      height: 380,
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
         /* border: Border.all(
                    color: Color(0xFFEEEEEE))*/
       ),
       child: Column(
         children: [
           Text("Create an account",style: TextStyle(
            color: Colors.black,
          fontSize: 20,
            ),textAlign: TextAlign.center,),
          //google button
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 10, bottom: 0),
            child: Container(
            width: 300,
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
          //facebook button
           Padding(
             padding: const EdgeInsets.only(
                 left: 15.0, right: 15.0, top: 15, bottom: 0),
             child: Container(
               width: 300,
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
                   Padding(padding: const EdgeInsets.only(left: 60,top: 0),
                     child:  Image.asset("assets/images/blog.png",height: 20,
                       alignment: Alignment.center,) ,
                   ),
                   Padding(padding: const EdgeInsets.only(left: 5,top: 0),
                     child:  Text("Continue with Facebook",style: TextStyle(fontWeight: FontWeight.bold),) ,
                   )

                 ],
               ),

             ),
           ),
          //  Text
           Padding(
         padding: const EdgeInsets.only(
             left: 15.0, right: 15.0, top: 10, bottom: 0),
         child:  Text("or",style: TextStyle(
           color: Colors.grey,
           fontSize: 17,
         ),textAlign: TextAlign.center,),
       ),
           //edittext
           Padding(
             padding: const EdgeInsets.only(
                 left: 15.0, right: 15.0, top: 10, bottom: 0),
             child: Container(
               width: 300,
               height: 50,
               padding: const EdgeInsets.only(top: 3,left: 12),
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
                   validator: (value) =>
                       Validator.validateEmail(value ?? ""),
                   controller: emailController,
                   keyboardType: TextInputType.emailAddress,
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
            GestureDetector(
         onTap: (){
           Navigator.push(context, MaterialPageRoute(builder: (context)=> CreatePassword(data: emailController.text)));
         },
         child:
           Padding(
             padding: const EdgeInsets.only(
                 left: 15.0, right: 15.0, top: 15, bottom: 0),
             child: Container(
               width: 300,
               height: 50,
               padding: const EdgeInsets.only(top: 13),
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
               color: Colors.black,
               fontSize: 15,
               fontWeight: FontWeight.bold,
             ),textAlign: TextAlign.center,),
             ),
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
                     child: Text('Already have an account? ',style: TextStyle(
                       color: Color(0xFF424242),fontSize: 13,
                     ),),
                   ),
                   Padding(
                     padding: const EdgeInsets.only(left:1.0),
                     child: InkWell(
                         onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                         },
                         child: Text('Login Here', style: TextStyle(fontSize: 14, color: Colors.black,
                         fontWeight: FontWeight.bold),)),
                   )
                 ],
               ),
             ),

           ),
         ],
       ),
     ),
    ]))
    );
  }
  }