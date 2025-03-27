import 'dart:async';
import 'dart:convert';
import 'package:Akarat/model/contactmodel.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:http/http.dart' as http;
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';

class Support extends StatefulWidget {
  Support({super.key,});


  @override
  State<StatefulWidget> createState() => new _SupportState();
}

class _SupportState extends State<Support> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  int pageIndex = 0;
  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;
  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();
  // Method to read data from shared preferences
  void readData() async {
    token = await prefManager.readStringFromPref();
    email = await prefManager.readStringFromPrefemail();
    result = await prefManager.readStringFromPrefresult();
    setState(() {
      isDataRead = true;
    });
  }

  @override
  void initState() {
    readData();
    super.initState();
  }




  ContactModel? contactModel;
  //String result = '';
  Future<void> sendMessage() async {
    try {
      final response = await http.post(Uri.parse('https://akarat.com/api/contact'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "name": nameController.text,
          "email": emailController.text,
          "phone":phoneController.text,
          "subject":subjectController.text,
          "message": messageController.text
          // Add any other data you want to send in the body
        }),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        contactModel = ContactModel.fromJson(jsonData);
      // result= contactModel!.message.toString();
      // Text(result);
        Navigator.push(context, MaterialPageRoute(builder: (context) => Profile_Login()));
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
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: buildMyNavBar(context),
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Container(
                    height: screenSize.height*0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(2.0),
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
                      ],),
                    child:  Stack(
                      // alignment: Alignment.topCenter,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 25),
                          child: Container(
                            height: screenSize.height*0.07,
                            width: double.infinity,
                            // color: Color(0xFFEEEEEE),
                            child:   Row(
                              children: [GestureDetector(
                                onTap: (){
                                  setState(() {
                                    if(token == ''){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
                                    }
                                    else{
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

                                    }
                                  });                                },
                                child:   Container(
                                  margin: const EdgeInsets.only(left: 10,top: 5,bottom: 0),
                                  height: 35,
                                  width: 35,
                                  padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadiusDirectional.circular(20.0),
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
                                  child: Image.asset("assets/images/ar-left.png",
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.contain,),
                                ),
                              ),
                                SizedBox(
                                  width: screenSize.width*0.23,
                                ),
                                Padding(padding: const EdgeInsets.all(8.0),
                                  child: Text("Contact Us",style: TextStyle(
                                      fontWeight: FontWeight.bold,fontSize: 20
                                  ),),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 25),
                    height: screenSize.height*0.05,
                    width: screenSize.width*0.9,
                   // color: Colors.grey,
                    child: Text("Ask us anything?",textAlign: TextAlign.left
                      ,style: TextStyle(
                      fontSize: 25,fontWeight: FontWeight.bold,letterSpacing: 0.5

                    ),),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
                   // color: Colors.grey,
                    height: screenSize.height*0.75,
                    width: screenSize.width*0.9,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,right: 300,top: 8,bottom: 8),
                          child: Text("Name",textAlign: TextAlign.left,style: TextStyle(
                            fontSize: 15,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
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
                                  return 'Please Enter Your Name';
                                }
                                else {

                                }
                                return null;
                              },
                              controller: nameController,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                               // hintText: 'Email',
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,right: 240,top: 8,bottom: 8),
                          child: Text("Email Address",textAlign: TextAlign.left,style: TextStyle(
                              fontSize: 15,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
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
                               // hintText: 'Email',
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,right: 240,top: 8,bottom: 8),
                          child: Text("Phone Number",textAlign: TextAlign.left,style: TextStyle(
                              fontSize: 15,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
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
                                  return 'Please Enter Phone Number';
                                }
                                else {

                                }
                                return null;
                              },
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                               // hintText: 'Email',
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,right: 280,top: 8,bottom: 8),
                          child: Text("Subject",textAlign: TextAlign.left,style: TextStyle(
                              fontSize: 15,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
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
                                  return 'Please Enter Subject';
                                }
                                else {

                                }
                                return null;
                              },
                              controller: subjectController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                // hintText: 'Email',
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,right: 280,top: 8,bottom: 8),
                          child: Text("Message",textAlign: TextAlign.left,style: TextStyle(
                              fontSize: 15,letterSpacing: 0.5
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
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
                           /* child: TextField(
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              textAlign: TextAlign.left,
                            ),*/
                            child: TextFormField(
                              maxLines: 3,
                              validator: (value) {
                                if (value!.isEmpty || value == null) {
                                  return 'Please Enter Message Here';
                                }
                                else {

                                }
                                return null;
                              },
                              controller: messageController,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                // hintText: 'Email',
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Container(
                          width: screenSize.width*0.9,
                          height: screenSize.height*0.1,
                          child: Padding(padding: const EdgeInsets.only(top: 40,left: 10,right: 20),
                            child: ElevatedButton(
                                onPressed: (){
                                  sendMessage();
                             // Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                            },style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius:  BorderRadius.all(
                                    Radius.circular(8)),),),
                                child: Text("Send Email",
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 15),)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            )
        )
    );
  }
  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () {

              Navigator.push(context, MaterialPageRoute(builder: (context)=> MyApp()));

            },
            icon: pageIndex == 0
                ? const Icon(
              Icons.home_filled,
              color: Colors.red,
              size: 35,
            )
                : const Icon(
              Icons.home_outlined,
              color: Colors.red,
              size: 35,
            ),
          ),
          Container(
              margin: const EdgeInsets.only(left: 40),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
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
              child: Icon(Icons.favorite_border,color: Colors.red,)
          ),

          Container(
              margin: const EdgeInsets.only(left: 1),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
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
              child: Icon(Icons.add_location_rounded,color: Colors.red,)

          ),
          Container(
              margin: const EdgeInsets.only(left: 1,right: 40),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
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
              child: Icon(Icons.chat,color: Colors.red,)

          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {

setState(() {
  if(token == ''){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
  }
  else{
    Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

  }
});
            },
            icon: pageIndex == 3
                ? const Icon(
              Icons.dehaze,
              color: Colors.red,
              size: 35,
            )
                : const Icon(
              Icons.dehaze_outlined,
              color: Colors.red,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 1",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 2",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 3",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Page4 extends StatelessWidget {
  const Page4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 4",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}