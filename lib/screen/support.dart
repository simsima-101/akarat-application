import 'dart:async';
import 'dart:convert';
import 'package:Akarat/model/contactmodel.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../secure_storage.dart';
import '../services/favorite_service.dart';
import '../utils/fav_logout.dart';
import 'login.dart';


class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  bool _isLoading = false;

  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;
  int pageIndex = 0;


  SharedPreferencesManager prefManager = SharedPreferencesManager();

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
    super.initState();
    readData();
  }

  Future<void> sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final Map<String, String> body = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "message": messageController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/contact'),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent successfully!')),
          );

          // Clear form
          nameController.clear();
          emailController.clear();
          phoneController.clear();
          subjectController.clear();
          messageController.clear();

          // Optionally navigate
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => My_Account()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${data['message'] ?? 'Unknown error'}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);

    return WillPopScope(
        onWillPop: () async {
      if (token == '') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
      }
      return false; // prevent default pop
    },
    child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.red),
          title: const Text(
            "Contact Us",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        // bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
        body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ask us anything?",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
                    // color: Colors.grey,
                    height: screenSize.height*0.75,
                    width: screenSize.width*0.9,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0,right: 0,top: 8,bottom: 8),
                              child: Text("Name",textAlign: TextAlign.left,style: TextStyle(
                                  fontSize: 15,letterSpacing: 0.5
                              ),),
                            ),
                            Text("")
                          ],
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
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0,right: 0,top: 8,bottom: 8),
                              child: Text("Email Address",textAlign: TextAlign.left,style: TextStyle(
                                  fontSize: 15,letterSpacing: 0.5
                              ),),
                            ),
                            Text("")
                          ],
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
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0,right: 0,top: 8,bottom: 8),
                              child: Text("Phone Number",textAlign: TextAlign.left,style: TextStyle(
                                  fontSize: 15,letterSpacing: 0.5
                              ),),
                            ),
                            Text("")
                          ],
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
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0,right: 0,top: 8,bottom: 8),
                              child: Text("Subject",textAlign: TextAlign.left,style: TextStyle(
                                  fontSize: 15,letterSpacing: 0.5
                              ),),
                            ),
                            Text("")
                          ],
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
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0,right: 0,top: 8,bottom: 8),
                              child: Text("Message",textAlign: TextAlign.left,style: TextStyle(
                                  fontSize: 15,letterSpacing: 0.5
                              ),),
                            ),
                            Text("")
                          ],
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
                          width: screenSize.width * 0.9,
                          height: screenSize.height * 0.1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40, left: 10, right: 20),
                           child: ElevatedButton(
                              onPressed: () async {
                                await sendMessage();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                "Send Email",
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),

                          ),
                        ),

                      ],
                    ),
                  ),
                ]
            )
        )
    ),);
  }
  // Container buildMyNavBar(BuildContext context) {
  //   return Container(
  //     height: 50,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: const BorderRadius.only(
  //         topLeft: Radius.circular(20),
  //         topRight: Radius.circular(20),
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ distributes space correctly
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         GestureDetector(
  //           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Home())),
  //
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //             child: Image.asset("assets/images/home.png", height: 25),
  //           ),
  //         ),
  //
  //         IconButton(
  //           enableFeedback: false,
  //           onPressed: () async {
  //             final token = await SecureStorage.getToken();
  //
  //             if (token == null || token.isEmpty) {
  //               showDialog(
  //                 context: context,
  //                 builder: (context) => AlertDialog(
  //                   backgroundColor: Colors.white, // white container
  //                   title: const Text("Login Required", style: TextStyle(color: Colors.black)),
  //                   content: const Text("Please login to access favorites.", style: TextStyle(color: Colors.black)),
  //                   actions: [
  //                     TextButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       child: const Text(
  //                         "Cancel",
  //                         style: TextStyle(color: Colors.red), // red text
  //                       ),
  //                     ),
  //                     TextButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(builder: (_) => const LoginDemo()),
  //                         );
  //                       },
  //                       child: const Text(
  //                         "Login",
  //                         style: TextStyle(color: Colors.red), // red text
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             }
  //             else {
  //               // ✅ Logged in – go to favorites
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (_) => const Fav_Logout()),
  //               ).then((_) async {
  //                 // 🔁 Re-sync when coming back
  //                 final updatedFavorites = await FavoriteService.fetchApiFavorites(token);
  //                 setState(() {
  //                   FavoriteService.loggedInFavorites = updatedFavorites;
  //                 });
  //               });
  //
  //             }
  //           },
  //           icon: pageIndex == 2
  //               ? const Icon(Icons.favorite, color: Colors.red, size: 30)
  //               : const Icon(Icons.favorite_border_outlined, color: Colors.red, size: 30),
  //         ),
  //
  //
  //
  //         IconButton(
  //           tooltip: "Email",
  //           icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
  //           onPressed: () async {
  //             final Uri emailUri = Uri.parse(
  //               'mailto:info@akarat.com?subject=Property%20Inquiry&body=Hi,%20I%20saw%20your%20agent%20profile%20on%20Akarat.',
  //             );
  //
  //             if (await canLaunchUrl(emailUri)) {
  //               await launchUrl(emailUri);
  //             } else {
  //               showDialog(
  //                 context: context,
  //                 builder: (context) => AlertDialog(
  //                   backgroundColor: Colors.white, // White dialog container
  //                   title: const Text(
  //                     'Email not available',
  //                     style: TextStyle(color: Colors.black), // Title in black
  //                   ),
  //                   content: const Text(
  //                     'No email app is configured on this device. Please add a mail account first.',
  //                     style: TextStyle(color: Colors.black), // Content in black
  //                   ),
  //                   actions: [
  //                     TextButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       child: const Text(
  //                         'OK',
  //                         style: TextStyle(color: Colors.red), // Red "OK" text
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             }
  //           },
  //         ),
  //
  //         Padding(
  //           padding: const EdgeInsets.only(right: 20.0), // consistent spacing from right edge
  //           child: IconButton(
  //             enableFeedback: false,
  //             onPressed: () {
  //               setState(() {
  //                 if (token == '') {
  //                   Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
  //                 } else {
  //                   Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
  //                 }
  //               });
  //             },
  //
  //
  //             icon: pageIndex == 3
  //                 ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
  //                 : const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
  //           ),
  //         ),
  //       ],
  //     ),
  //
  //   );
  // }
}
