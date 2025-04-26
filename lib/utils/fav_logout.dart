import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';

import '../screen/home.dart';

class Fav_Logout extends StatefulWidget {
   Fav_Logout({super.key,});

  @override
  State<Fav_Logout> createState() => new _Fav_LogoutState();
}
class _Fav_LogoutState extends State<Fav_Logout> {
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        body: DefaultTabController(
          length: 2,
          child:  SingleChildScrollView(
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
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Profile_Login()));
                                  },
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
                                    width: screenSize.width*0.28,
                                  ),
                                  Padding(padding: const EdgeInsets.all(8.0),
                                    // child: Text(widget.token,style: TextStyle(
                                    child: Text("Saved",style: TextStyle(
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
                      margin: const EdgeInsets.all(15.0),
                      height: screenSize.height*0.06,
                      width: screenSize.width*0.9,
                      // color: Colors.grey,
                      child:  TabBar(
                        padding:  EdgeInsets.only(top: 0,left: 10,right: 0),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 0,),
                        splashFactory: NoSplash.splashFactory,
                        indicatorWeight: 1.0,
                        labelColor: Colors.lightBlueAccent,
                        dividerColor: Colors.transparent,
                        indicatorColor: Colors.transparent,
                        tabAlignment: TabAlignment.center,
                        // onTap: (int index) => setState(() =>  screens[about_tb()]),
                        tabs: [
                          Container(
                            margin: const EdgeInsets.only(left: 0),
                            width: screenSize.width*0.41,
                            height: screenSize.height*0.045,
                            padding: const EdgeInsets.only(top: 10,),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: Offset(4, 4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  offset: Offset(-4, -4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Searches',textAlign: TextAlign.center,style: TextStyle(
                                fontWeight: FontWeight.bold,fontSize: 15
                            ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            width: screenSize.width*0.41,
                            height: screenSize.height*0.045,
                            padding: const EdgeInsets.only(top: 10,),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: Offset(4, 4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  offset: Offset(-4, -4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Favorites',textAlign: TextAlign.center,style: TextStyle(
                                fontWeight: FontWeight.bold,fontSize: 15
                            ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        height: screenSize.height*0.8,
                        child: TabBarView(
                            children: [
                              Container(
                                 //color: Colors.grey,
                                  margin: const EdgeInsets.only(left: 20,right: 15,top: 10),
                                  height: screenSize.height*0.2,
                                  child:  Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(8.0),
                                        height: screenSize.height*0.03,
                                        width: screenSize.width*0.9,
                                        //color: Colors.white,
                                        child: Text("Want to keep track of all your searches?",textAlign: TextAlign.center
                                          ,style: TextStyle(
                                              fontSize: 16,fontWeight: FontWeight.bold,letterSpacing: 0.5
                                          ),),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(0.0),
                                        height: screenSize.height*0.03,
                                        width: screenSize.width*0.9,
                                        //color: Colors.white,
                                        child: Text("Save your searches at one place by signing up",textAlign: TextAlign.center
                                          ,style: TextStyle(
                                              fontSize: 13,letterSpacing: 0.5,fontWeight: FontWeight.bold
                                          ),),
                                      ),
                                      Container(
                                        width: screenSize.width*0.9,
                                        height: screenSize.height*0.08,
                                        child: Padding(padding: const EdgeInsets.only(top: 20,left: 10,right: 20),
                                          child: ElevatedButton(
                                              onPressed: (){
                                                // Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                                              },style:
                                          ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:  BorderRadius.all(
                                                  Radius.circular(8)),),),
                                              child: Text("Sign Up",
                                                style: TextStyle(color: Colors.white,
                                                    fontSize: 15),)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15.0, top: 10, bottom: 0),
                                        child:  Text("or",style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 17,
                                        ),textAlign: TextAlign.center,),
                                      ),
                                      //google button
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 20.0, top: 10, bottom: 0),
                                        child: Container(
                                          width: screenSize.width*0.9,
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
                                            left: 15.0, right: 20.0, top: 15, bottom: 0),
                                        child: Container(
                                          width: screenSize.width*0.9,
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
                                      SizedBox(
                                        height: screenSize.height*0.33,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(8.0),
                                        height: screenSize.height*0.04,
                                        width: screenSize.width*0.8,
                                        //color: Colors.white,
                                        alignment: Alignment.bottomCenter,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("Have an Account?",style: TextStyle(
                                                fontSize: 15,letterSpacing: 0.5
                                            ),),
                                            Text("Log in",style: TextStyle(
                                                fontSize: 15,letterSpacing: 0.5,fontWeight: FontWeight.bold
                                            ),),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                              ),
                              Container(
                                height: screenSize.height*0.5,
                                // color: Colors.grey,
                                margin: const EdgeInsets.only(left: 15,right: 15,top: 20),
                                child:  Column(
                                  children: [
                                    SizedBox(
                                      height: screenSize.height*0.1,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(8.0),
                                      height: screenSize.height*0.13,
                                      width: screenSize.width*0.4,
                                      // color: Colors.grey,
                                      child: Image.asset("assets/images/no-property-search.png"),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(8.0),
                                      height: screenSize.height*0.03,
                                      width: screenSize.width*0.9,
                                      color: Colors.white,
                                      child: Text("Save your favourite properties now!",textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue
                                        ),),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(8.0),
                                      height: screenSize.height*0.1,
                                      width: screenSize.width*0.9,
                                      color: Colors.white,
                                      child: Text("It looks like you haven’t added any favourite properties "
                                          " just yet. You can add a property listing to your favourites by tapping "
                                          "the icon at the top right corner of property details",textAlign: TextAlign.center,
                                        style: TextStyle(
                                            letterSpacing: 0.5,fontSize: 15
                                        ),),
                                    ),
                                    SizedBox(
                                      height: screenSize.height*0.13,
                                    ),
                                    Container(
                                      width: screenSize.width*0.9,
                                      height: screenSize.height*0.1,
                                      child: Padding(padding: const EdgeInsets.only(top: 40,left: 10,right: 10),
                                        child: ElevatedButton(
                                            onPressed: (){
                                              // Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                                            },style:
                                        ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:  BorderRadius.all(
                                                Radius.circular(8)),),),
                                            child: Text("Start a New Search",
                                              style: TextStyle(color: Colors.white,
                                                  fontSize: 15),)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        )
                    ),
                  ]
              )
          ),

        )

    );
  }
  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 50,
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
          GestureDetector(
              onTap: ()async{
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
              },
              child: Image.asset("assets/images/home.png",height: 22,)),
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