import 'package:drawerdemo/screen/home.dart';
import 'package:drawerdemo/screen/profile_login.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(const New_Projects());
}
class New_Projects extends StatelessWidget {
  const New_Projects({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: New_ProjectsDemo(),
    );
  }
}

class New_ProjectsDemo extends StatefulWidget {
  @override
  _New_ProjectsDemoState createState() => _New_ProjectsDemoState();
}
class _New_ProjectsDemoState extends State<New_ProjectsDemo> {
  final TextEditingController _searchController = TextEditingController();
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
          Row(
            children: [
              Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 50,left:15),
                height: 30,
                width: 30,
                padding: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(15.0),
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
                child: Icon(Icons.arrow_back,color: Colors.red,
                ),
              ),
              //logo2
              Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 52,left: 80),
                height: 30,
                width: 125,
                decoration: BoxDecoration(

                ),
                child: Text("New Projects",style: TextStyle(
                    color: Colors.black,letterSpacing: 0.5,fontSize: 18,
                    fontWeight: FontWeight.bold,
                ),textAlign: TextAlign.center,),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 15,left: 15,right: 15),
            padding: const EdgeInsets.only(top: 5,left: 5,right: 10),
            height: 50,
            width: double.infinity,
            //color: Colors.grey,
            child: Text("Find off-plan development and everything you need to "
                "know to invest in UAE's real estate market",style: TextStyle(letterSpacing: 0.5,),),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 20,right: 15),
                child: Container(
                  width: screenSize.width*0.9,
                  height: 50,
                 // color: Colors.grey,
                  padding: const EdgeInsets.only(top: 5),
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
                  // Use a Material design search bar
                  child: TextField(
                    textAlign: TextAlign.left,
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search new projects by location ',
                      hintStyle: TextStyle(color: Colors.grey,fontSize: 15,
                          letterSpacing: 0.5),
                      // Add a search icon or button to the search bar
                      prefixIcon: IconButton(
                        alignment: Alignment.topLeft,
                        icon: Icon(Icons.location_on,color: Colors.red,),
                        onPressed: () {
                          // Perform the search here
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
         Padding(padding: const EdgeInsets.only(top: 20,left: 10,right: 190),
           child: Text("Latest Projects in Dubai",textAlign: TextAlign.left,
           style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
         ),
          Container(
            margin: const EdgeInsets.only(top: 15,left: 20,right: 15),
            padding: const EdgeInsets.only(top: 5,left: 5,right: 10),
            height: 50,
            width: double.infinity,
            //color: Colors.grey,
            child: Text("Find off-plan development and everything you need to "
                "know to invest in UAE's real estate market",style: TextStyle(letterSpacing: 0.5,),),
          ),
          Container(
            width: double.infinity,
              height: 300,
             // color: Colors.grey,
             // padding: const EdgeInsets.only(top: 10,left: 10),
            margin: const EdgeInsets.only(top: 15,left: 15),
            child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                GestureDetector(
                onTap: (){
         //Navigator.push(context, MaterialPageRoute(builder: (context)=> Product_Detail(data: ,)));
          },
          child:   Container(
              margin: const EdgeInsets.only(top: 5,left: 5,right: 10,bottom: 5),
            width: 300,
                height: 300,
              decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(6.0),
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
                  ]),
            child:   Image.asset("assets/images/image 2.png",fit: BoxFit.fill,),
            ),
                ),
        GestureDetector(
            onTap: (){
              //Navigator.push(context, MaterialPageRoute(builder: (context)=> Property_Detail()));
            },
                child:   Container(
                    margin: const EdgeInsets.only(top: 5,left: 5,right: 10,bottom: 5),
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
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
                        ]),
                    child:   Image.asset("assets/images/image 4.png",fit: BoxFit.fill,),
                  ),
        ),
        GestureDetector(
            onTap: (){
             // Navigator.push(context, MaterialPageRoute(builder: (context)=> Property_Detail()));
            },child:
                  Container(
                    margin: const EdgeInsets.only(top: 5,left: 5,right: 10,bottom: 5),
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
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
                        ]),
                    child:   Image.asset("assets/images/image 2.png",fit: BoxFit.fill,),
                  ),
        ),
        GestureDetector(
            onTap: (){
             // Navigator.push(context, MaterialPageRoute(builder: (context)=> Property_Detail()));
            },child:
                  Container(
                    margin: const EdgeInsets.only(top: 5,left: 5,right: 10,bottom: 5),
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
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
                        ]),
                    child:   Image.asset("assets/images/image3.png",fit: BoxFit.fill,),
                  ),
        ),
                  ]
            )
          ),
          Padding(padding: const EdgeInsets.only(top: 15,left: 5,right: 265),
            child: Text("Dubai Marina",textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
          ),
          Container(
              width: double.infinity,
              height: 300,
              // color: Colors.grey,
              // padding: const EdgeInsets.only(top: 10,left: 10),
              margin: const EdgeInsets.only(top: 15,left: 15),
              child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                  GestureDetector(
                  onTap: (){
         // Navigator.push(context, MaterialPageRoute(builder: (context)=> Property_Detail()));
          },child:
                    Container(
                      margin: const EdgeInsets.only(top: 5,left: 5,right: 10,bottom: 5),
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.circular(6.0),
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
                          ]),
                      child:   Image.asset("assets/images/image 2.png",fit: BoxFit.fill,),
                    ),
                  ),
        GestureDetector(
            onTap: (){
             // Navigator.push(context, MaterialPageRoute(builder: (context)=> Property_Detail()));
            },child:
                    Container(
                      margin: const EdgeInsets.only(top: 5,left: 5,right: 10,bottom: 5),
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.circular(6.0),
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
                          ]),
                      child:   Image.asset("assets/images/image 4.png",fit: BoxFit.fill,),
                    ),
        ),
        GestureDetector(
            onTap: (){
             // Navigator.push(context, MaterialPageRoute(builder: (context)=> Property_Detail()));
            },child:
                    Container(
                      margin: const EdgeInsets.only(top: 5,left: 5,right: 10,bottom: 5),
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.circular(6.0),
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
                          ]),
                      child:   Image.asset("assets/images/image 2.png",fit: BoxFit.fill,),
                    ),
        ),
        GestureDetector(
            onTap: (){
             // Navigator.push(context, MaterialPageRoute(builder: (context)=> Property_Detail()));
            },child:
                    Container(
                      margin: const EdgeInsets.only(top: 5,left: 5,right: 10,bottom: 5),
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.circular(6.0),
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
                          ]),
                      child:   Image.asset("assets/images/image3.png",fit: BoxFit.fill,),
                    ),
        ),
                  ]
              )
          ),
          SizedBox(
            width: double.infinity,
            height: 100,
          )
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
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> MyApp()));
              });
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
              child: Icon(Icons.call_outlined,color: Colors.red,)
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
              child: Icon(Icons.call_outlined,color: Colors.green,)

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
              child: Icon(Icons.mail,color: Colors.red,)

          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
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