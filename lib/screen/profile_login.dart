import 'package:drawerdemo/screen/about_us.dart';
import 'package:drawerdemo/screen/blog.dart';
import 'package:drawerdemo/screen/findagent.dart';
import 'package:drawerdemo/screen/home.dart';
import 'package:drawerdemo/screen/login.dart';
import 'package:drawerdemo/screen/privacy.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(const Profile_Login());

}

class Profile_Login extends StatelessWidget {
  const Profile_Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Profile_LoginDemo(),
    );
  }
}
class Profile_LoginDemo extends StatefulWidget {
  @override
  _Profile_LoginDemoState createState() => _Profile_LoginDemoState();
}
class _Profile_LoginDemoState extends State<Profile_LoginDemo> {

  int pageIndex = 0;
  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

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
                    height: screenSize.height*0.25,
                    color: Color(0xFFF5F5F5),
                    child: Column(
                      children: [
                        Row(
                          children: [
                    GestureDetector(
                    onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                  },
                    child: Container(
                              margin: const EdgeInsets.only(left: 20,top: 30,bottom: 0),
                              height: 35,
                              width: 35,
                              padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.circular(20.0),
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
                              child: Image.asset("assets/images/ar-left.png",
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,),
                            ),
                    ),
                            Container(
                              margin: const EdgeInsets.only(left: 280,top: 35,bottom: 0),
                              height: 35,
                              width: 35,
                              padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.circular(20.0),
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
                              child: Image.asset("assets/images/share.png",
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,),
                            ),
                          ],
                        ),
                       Row(
                         children: [
                           Container(
                             margin: const EdgeInsets.only(left: 50,top: 0,bottom: 0),
                             height: 90,
                             width: 90,
                             padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                             decoration: BoxDecoration(
                               borderRadius: BorderRadiusDirectional.circular(50.0),
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
                             child: Image.asset("assets/images/app_icon.png",
                               width: 15,
                               height: 15,
                               fit: BoxFit.contain,),
                           ),
                           Container(
                             margin: const EdgeInsets.only(left: 5),
                             height: 130,
                             width: 180,
                             // color: Colors.grey,
                             padding: const EdgeInsets.only(left: 0,top: 5),
                             child:   Column(
                                 children: [
                                   Padding(padding: const EdgeInsets.only(top: 0,left: 0,right: 70),
                                     child: Text("Hi there,",style: TextStyle(
                                       fontSize: 22,
                                       fontWeight: FontWeight.bold,
                                       letterSpacing: 0.5,
                                     ),textAlign: TextAlign.left,),
                                   ),
                                   Padding(padding: const EdgeInsets.only(top: 1,left: 10,right: 0),
                                     child: Text("Sign in for a more"
                                         " personalized experience.",style: TextStyle(
                                       fontSize: 12,
                                       // fontWeight: FontWeight.bold,
                                       letterSpacing: 0.5,
                                     ),textAlign: TextAlign.left,),
                                   ),
                                   Padding(padding: const EdgeInsets.only(top: 5,left: 0,right: 20),
                                   child: ElevatedButton(onPressed: (){
                                     Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                                   },style:
                                   ElevatedButton.styleFrom(backgroundColor: Colors.blue,
                                     shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(8)),),),
                                       child: Text("Login or Signup",style: TextStyle(color: Colors.white,fontSize: 12),)),
                                   ),
                                 ],
                               )
                           ),

                         ],
                       )
                      ],
                    ),

                  ),
                 Container(
                   height: screenSize.height*0.165,
                   width: screenSize.width*0.8,
                   margin: const EdgeInsets.only(left: 20,top: 20,right: 20),
                   decoration: BoxDecoration(
                     borderRadius: BorderRadiusDirectional.circular(10.0),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.grey,
                         offset: const Offset(
                           0.0,
                           0.0,
                         ),
                         blurRadius: 0.3,
                         spreadRadius: 0.5,
                       ), //BoxShadow
                       BoxShadow(
                         color: Colors.white,
                         offset: const Offset(0.0, 0.0),
                         blurRadius: 0.0,
                         spreadRadius: 0.3,
                       ), //BoxShadow
                     ],
                   ),
                   child: Column(
                     children: [
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Text("Hurry!",style: TextStyle(
                           fontWeight: FontWeight.bold,fontSize: 25,color: Colors.red
                         ),),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(2.0),
                         child: Text("Enjoy a FREE Subscription for all of 2025",style: TextStyle(
                             fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black
                         ),),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: ElevatedButton(onPressed: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                         },style:
                         ElevatedButton.styleFrom(backgroundColor: Colors.black,
                           shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(8)),),),
                             child: Text("Sign up Now!",style: TextStyle(color: Colors.white,fontSize: 12),)),
                       ),
                     ],
                   ),
                 ),
                  Container(
                   // color: Colors.grey,
                    height: screenSize.height*0.5,
                    margin:const EdgeInsets.only(left: 20,right: 20,top: 0),
                    child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> FindAgent()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                              height: screenSize.height*0.045,

                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 15),
                                    child: Image.asset("assets/images/find-my-agent.png",height: 22,),
                                  ),

                                  SizedBox(
                                    width: screenSize.width*0.13,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 0),
                                    child: Text("Find My Agent",style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.29,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0,left: 15),
                                    child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                  )
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              //Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                              height: screenSize.height*0.045,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 15),
                                    child: Image.asset("assets/images/favourites.png",height: 22,),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 12),
                                    child: Text("Favorites",style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.38,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0,left: 15),
                                    child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                  )
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                          onTap: (){
                            //Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                              height: screenSize.height*0.045,
                              child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 15),
                                  child: Image.asset("assets/images/cities.png",height: 25,),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0.0,left: 12),
                                  child: Text("City",style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(
                                  width: screenSize.width*0.43,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Text("UAE",style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),)
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0,left: 3),
                                  child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                ),
                              ],
                            ),
                          ),

                          ),
                          GestureDetector(
                            onTap: (){
                              //Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                            },
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                                  height: screenSize.height*0.045,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 0.0,left: 15),
                                        child: Image.asset("assets/images/languages.png",height: 25,),
                                      ),
                                      SizedBox(
                                        width: screenSize.width*0.1,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 0.0,left: 12),
                                        child: Text("Languages",style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ),),
                                      ),
                                      SizedBox(
                                        width: screenSize.width*0.26,
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Text("English",style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          ),)
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0,left: 3),
                                        child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                      )
                                    ],
                                  ),
                                ),
                            ),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> About_Us()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                              height: screenSize.height*0.045,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 15),
                                    child: Image.asset("assets/images/city.png",height: 25,),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 12),
                                    child: Text("About Us",style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.38,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0,left: 15),
                                    child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                  )
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Blog()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                              height: screenSize.height*0.045,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 15),
                                    child: Image.asset("assets/images/blog.png",height: 25,),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.13,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 0),
                                    child: Text("Blogs",style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.44,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0,left: 15),
                                    child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                  )
                                ],
                              ),
                            ),
                            ),
                          GestureDetector(
                            onTap: (){
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                              height: screenSize.height*0.045,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 15),
                                    child: Image.asset("assets/images/advertise.png",height: 25,),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.13,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 0),
                                    child: Text("Advertising",style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.35,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0,left: 12),
                                    child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                  )
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              //Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                              height: screenSize.height*0.045,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 15),
                                    child: Image.asset("assets/images/support.png",height: 25,),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.13,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 0),
                                    child: Text("Support",style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.4,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0,left: 15),
                                    child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                  )
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                               Navigator.push(context, MaterialPageRoute(builder: (context)=> Privacy()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                              height: screenSize.height*0.045,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 15),
                                    child: Image.asset("assets/images/privacy-policy.png",height: 22,),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.12,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 0),
                                    child: Text("Privacy Policy",style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.31,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0,left: 15),
                                    child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                  )
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                              height: screenSize.height*0.045,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 15),
                                    child: Image.asset("assets/images/terms-and-conditions.png",height: 25,),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.12,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 0),
                                    child: Text("Terms And Conditions",style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.17,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0,left: 15),
                                    child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                  )
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 10,top: 0,right: 5),
                              height: screenSize.height*0.045,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 15),
                                    child: Image.asset("assets/images/cookies.png",height: 25,),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.12,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0,left: 0),
                                    child: Text("Cookies",style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                  SizedBox(
                                    width: screenSize.width*0.39,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0,left: 15),
                                    child: Icon(Icons.arrow_forward_ios,color: Colors.red,size: 13,),
                                  )
                                ],
                              ),
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

              Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));

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