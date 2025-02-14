import 'package:drawerdemo/screen/login.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Container(
                    height: 220,
                    color: Color(0xFFF5F5F5),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //logo 1
                      GestureDetector(
                        onTap: (){
                        //  Navigator.push(context, MaterialPageRoute(builder: (context)=> FliterListDemo()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 10.0, top: 20, bottom: 0),
                          child: Container(
                              width: 170,
                              height: 80,
                              padding: const EdgeInsets.only(top: 10),
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
                                ],
                              ),
                              child:   Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/Residential__1.png",height: 40,),
                                  Padding(padding: const EdgeInsets.only(left: 25,right: 20,top: 5),
                                    child:  Text("My Ads",style:
                                    TextStyle(height: 1.2,
                                        letterSpacing: 0.5,
                                        fontSize: 12,fontWeight: FontWeight.bold
                                    ),),
                                  )

                                ],
                              )
                          ),
                        ),
                      ),

                      //logo2
                      GestureDetector(
                        onTap: (){
                       //   Navigator.push(context, MaterialPageRoute(builder: (context)=> FliterListDemo()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, right: 15.0, top:20.0, bottom: 0),
                          child: Container(
                              width: 170,
                              height: 80,
                              padding: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(

                                // image: DecorationImage(
                                //   image: AssetImage("assets/images/02.png"),
                                // ),
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
                              child:   Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/commercial_new.png",height: 40,),
                                  Padding(padding: const EdgeInsets.only(left: 25,right: 20,top: 5),
                                    child:  Text("My Searches",style:
                                    TextStyle(height: 1.2,
                                        letterSpacing: 0.5,
                                        fontSize: 12,fontWeight: FontWeight.bold
                                    ),),
                                  )

                                ],
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: const EdgeInsets.only(top: 0,left: 15),
                   child:  ListView.builder(
                        shrinkWrap: true,
                        itemCount: 7,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              leading: const Icon(Icons.list),
                              trailing: const Text(
                                "GFG",
                                style: TextStyle(color: Colors.green, fontSize: 15),
                              ),
                              title: Text("List item $index"));
                        }),
                  ),


                ]
            )
        )
    );
  }
}