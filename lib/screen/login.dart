import 'package:Akarat/screen/emai_login.dart';
import 'package:Akarat/screen/login_page.dart';
import 'package:Akarat/screen/profile_login.dart';
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
  String? emailError;
  bool isTyping = false;
  bool _showClose = true;
  final emailController = TextEditingController();
  final formkey =GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(0),
          children: [
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
              padding: const EdgeInsets.only(top: 140.0,bottom: 0),
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                padding: const EdgeInsets.only(top: 15),
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
                  children: [
                    Text("Welcome to Akarat!", style: TextStyle(fontSize: 20)),
                    SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      decoration: _boxDecoration(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 55.0),
                        child: Row(
                          children: [
                            Image.asset("assets/images/gi.webp", height: 25),
                            Text("Continue with Google", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("or", style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      decoration: _boxDecoration(),
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                      child: TextFormField(
                        controller: emailController,
                        onChanged: (value) {
                          if (formkey.currentState != null) {
                            formkey.currentState!.validate(); // revalidate as user types
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter Email ID';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Invalid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        if (formkey.currentState!.validate()) {
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(data: emailController.text,)));
                          Navigator.push(context, MaterialPageRoute(builder: (_) => EmaiLogin(data: emailController.text)));
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        decoration: _boxDecoration().copyWith(color: Color(0xFFEEEEEE)),
                        alignment: Alignment.center,
                        child: Text("Continue", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Not registered yet? ', style: TextStyle(color: Color(0xFF424242))),
                        InkWell(
                          // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateAccountScreen())),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage())),
                          child: Text('Create new account', style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    SizedBox(height: 10,)
                  ],
                ),
              ),
            ),
          ],

        )
    )
    );

  }
}

BoxDecoration _boxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.grey,
        offset: Offset(0.3, 0.3),
        blurRadius: 0.3,
        spreadRadius: 0.3,
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(0.0, 0.0),
        blurRadius: 0.0,
        spreadRadius: 0.0,
      ),
    ],
  );
}
