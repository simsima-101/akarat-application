import 'package:flutter/material.dart';

void main(){
  runApp(const AboutAgent());

}

class AboutAgent extends StatelessWidget {
  const AboutAgent({Key ? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AboutAgentDemo(),
    );
  }
}
class AboutAgentDemo extends StatefulWidget {
  @override
  _AboutAgentDemoState createState() => _AboutAgentDemoState();
}
class _AboutAgentDemoState extends State<AboutAgentDemo> {
    int pageIndex = 0;

  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       // length: 3,

        bottomNavigationBar: buildMyNavBar(context),
      backgroundColor: Colors.white,
        body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          Stack(
           // alignment: Alignment.topCenter,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Color(0xFFEEEEEE),
                  child:   Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(left: 10,top: 20,bottom: 100),
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
                            margin: const EdgeInsets.only(left: 290,top: 20,bottom: 100,),
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
                          //child: Image(image: Image.asset("assets/images/share.png")),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 70,left: 20),
                  width: 130,
                  height: 130,
                //  color: Colors.white,
                 /* decoration: ShapeDecoration(
                    shape: CircleBorder(),
                   // color: Colors.red,
                  ),*/
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(63.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          0.5,
                          0.5,
                        ),
                        blurRadius: 1.0,
                        spreadRadius: 1.0,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Image.asset("assets/images/ag.png",
                      ),
                  ),
                )
              ],
          ),
          Padding(padding: const EdgeInsets.only(top: 10,left: 0.0,right: 170),
          child: Text("Dina Marzouk Soffar",style: TextStyle(
            fontSize: 20,color: Colors.black,letterSpacing: 0.5
          ),),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 2.0, top: 20, bottom: 0),
                child: Container(
                 // width: 130,
                  height: 35,
                  padding: const EdgeInsets.only(top: 2,left: 5,right: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          1.5,
                          1.5,
                        ),
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.blue,
                        offset: const Offset(0.5, 0.5),
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(padding: const EdgeInsets.only(left: 1),
                          child:   Icon(Icons.check_circle,color: Colors.white,size: 17,)
                      ),
                      Padding(padding: const EdgeInsets.only(left: 1,right: 3),
                          child:   Text("Prime Agent",style: TextStyle(
                              letterSpacing: 0.5,color: Colors.white,fontSize: 12
                          ),textAlign: TextAlign.center,)
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 2.0, top: 20, bottom: 0),
                child: Container(
                 // width: 130,
                  height: 35,
                  padding: const EdgeInsets.only(top: 2,left: 5,right: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          1.5,
                          1.5,
                        ),
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                      BoxShadow(
                        color: Color(0xFFEAD893),
                        offset: const Offset(0.5, 0.5),
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(padding: const EdgeInsets.only(left: 1),
                          child:   Icon(Icons.stars,color: Colors.red,size: 17,)
                      ),
                      Padding(padding: const EdgeInsets.only(left: 1,right: 3),
                          child:   Text("Quality Listener",style: TextStyle(
                              letterSpacing: 0.5,color: Colors.black,fontSize: 12
                          ),textAlign: TextAlign.center,)
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 5.0, top: 20, bottom: 0),
                child: Container(
                 // width: 130,
                  height: 35,
                  padding: const EdgeInsets.only(top: 2,left: 5,right: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          1.5,
                          1.5,
                        ),
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                      BoxShadow(
                        color: Color(0xFFF5F5F5),
                        offset: const Offset(0.5, 0.5),
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(padding: const EdgeInsets.only(left: 1),
                          child:   Icon(Icons.call_outlined,color: Colors.red,size: 17,)
                      ),
                      Padding(padding: const EdgeInsets.only(left: 1,right: 3),
                          child:   Text("Responsive Broker",style: TextStyle(
                              letterSpacing: 0.5,color: Colors.black,fontSize: 12
                          ),textAlign: TextAlign.center,)
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.only(top: 15,left: 15),
            child: Row(
    children: [
      Container(
        margin: const EdgeInsets.only(left: 10),
        width: 80,
        height: 30,
        padding: const EdgeInsets.only(top: 0,),
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
    child:   Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
           // Image.asset('assets/images/filter.png', width: 18, height: 18),
           // const SizedBox(width: 8),
            Text('About'),
          ],
        ),
      ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 10),
        width: 80,
        height: 30,
        padding: const EdgeInsets.only(top: 0,),
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
        child:   Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
             // Image.asset('assets/images/filter.png', width: 18, height: 18),
             // const SizedBox(width: 8),
              Text('Properties'),
            ],
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 10),
        width: 80,
        height: 30,
        padding: const EdgeInsets.only(top: 0,),
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
        child:   Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image.asset('assets/images/filter.png', width: 18, height: 18),
              // const SizedBox(width: 8),
              Text('Reviews'),
            ],
          ),
        ),
      ),
      TabBarView(
          children:[
            Center(
              child: Text("about"),
            ),
            Center(
              child: Text("properties"),
            ),
            Center(
              child: Text("review"),
            ),
    ]
        ),
    ],
    ),

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
                pageIndex = 0;
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
                pageIndex = 3;
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