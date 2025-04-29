import 'package:Akarat/screen/create_password.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/profile_login.dart';
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
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showClose = true;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Column(
              children: <Widget>[
                const SizedBox(height: 30,),
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
                  padding: const EdgeInsets.only(top: 100.0),
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
                Padding(
                  padding: const EdgeInsets.only(top: 25.0, left: 20, right: 20),
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
                            children: [
                              const Text(
                                "Create an account",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),

                              // Google Button
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
                             /* _socialButton(
                                context,
                                image: "assets/images/gi.webp",
                                text: "Continue with Google",
                              ),*/

                              const SizedBox(height: 10),

                              const Text("or", style: TextStyle(color: Colors.grey, fontSize: 17)),

                              const SizedBox(height: 10),

                              // Email Field
                              Container(
                                width: screenSize.width * 0.85,
                                decoration: _boxDecoration(),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Email',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Invalid email format';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Continue Button
                              SizedBox(
                                width: screenSize.width * 0.85,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEEEEEE),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreatePassword(data: emailController.text),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text("Continue",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Already have account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?",
                                style: TextStyle(color: Color(0xFF424242), fontSize: 13)),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
                              },
                              child: const Text("Login Here",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
    ]))
    );
  }
  Widget _socialButton(BuildContext context,
      {required String image, required String text}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 50,
      decoration: _boxDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Image.asset(image, height: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }
  }