
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
  bool _isVisible = true;
  String selected = "About";
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
          Row(
            children: [
              GestureDetector(
                onTap: (){
                  setState(() {
                    selected = 'About';
                    Container(
                    height: 300,
                    child:  Column(
                    children: [
                    //About details
                    Padding(
                    padding: const EdgeInsets.only(top: 20, left: 0.0, right: 310),
                    child: Text("About", style: TextStyle(
                    fontSize: 18, color: Colors.black, letterSpacing: 0.5
                    ),),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(top: 10, left: 0.0, right: 300),
                    child: Text("Language(s)", style: TextStyle(
                    fontSize: 10, color: Colors.grey, letterSpacing: 0.5
                    ),),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(top: 2, left: 0.0, right: 320),
                    child: Text("dfgh ", style: TextStyle(
                    fontSize: 15, color: Colors.black, letterSpacing: 0.5
                    ),),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(top: 20, left: 0.0, right: 310),
                    child: Text("Expertise", style: TextStyle(
                    fontSize: 10, color: Colors.grey, letterSpacing: 0.5
                    ),),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(top: 2, left: 0.0, right: 310),
                    child: Text("About", style: TextStyle(
                    fontSize: 15, color: Colors.black, letterSpacing: 0.5
                    ),),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(top: 20, left: 0.0, right: 290),
                    child: Text("Services Area", style: TextStyle(
                    fontSize: 10, color: Colors.grey, letterSpacing: 0.5
                    ),),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(top: 2, left: 0.0, right: 310),
                    child: Text("About", style: TextStyle(
                    fontSize: 15, color: Colors.black, letterSpacing: 0.5
                    ),),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(top: 20, left: 0.0, right: 310),
                    child: Text("Properties", style: TextStyle(
                    fontSize: 10, color: Colors.grey, letterSpacing: 0.5
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
                    padding: const EdgeInsets.only(
                    top: 5, left: 5, right: 10),
                    decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(8.0),
                    boxShadow: [
                    BoxShadow(
                    color: Colors.red,
                    offset: const Offset(
                    0.3,
                    0.5,
                    ),
                    blurRadius: 0.5,
                    spreadRadius: 0.8,
                    ), //BoxShadow
                    BoxShadow(
                    color: Colors.white,
                    offset: const Offset(0.5, 0.5),
                    blurRadius: 0.5,
                    spreadRadius: 0.5,
                    ), //BoxShadow
                    ],
                    ),

                    child: Row(
                    children: [
                    Text("18 Properties for Rent", style: TextStyle(
                    letterSpacing: 0.5,
                    color: Colors.black,
                    fontSize: 13
                    ), textAlign: TextAlign.left,),
                    Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Image.asset("assets/images/arrow.png",
                    width: 15,
                    height: 15,
                    fit: BoxFit.contain,)
                    ),

                    ],
                    )
                    ),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(
                    left: 10.0, right: 2.0, top: 20, bottom: 0),
                    child: Container(
                    // width: 130,
                    height: 35,
                    padding: const EdgeInsets.only(
                    top: 8, left: 5, right: 10),
                    decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(8.0),
                    boxShadow: [
                    BoxShadow(
                    color: Colors.red,
                    offset: const Offset(
                    0.3,
                    0.5,
                    ),
                    blurRadius: 0.5,
                    spreadRadius: 0.8,
                    ), //BoxShadow
                    BoxShadow(
                    color: Colors.white,
                    offset: const Offset(0.5, 0.5),
                    blurRadius: 0.5,
                    spreadRadius: 0.5,
                    ), //BoxShadow
                    ],
                    ),
                    child: Row(
                    children: [
                    Text("18 Properties for Rent", style: TextStyle(
                    letterSpacing: 0.5,
                    color: Colors.black,
                    fontSize: 13
                    ), textAlign: TextAlign.left,),
                    Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Image.asset("assets/images/arrow.png",
                    width: 15,
                    height: 15,
                    fit: BoxFit.contain,)
                    ),
                    ],
                    )
                    ),
                    ),
                    ],
                    ),
                    Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10.0, right: 290),
                    child: Text("Description", style: TextStyle(
                    fontSize: 15, color: Colors.black, letterSpacing: 0.5
                    ),),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(top: 8, left: 20.0, right: 10),
                    child: SizedBox(
                    width: 400,
                    height: 70,
                    child: Text(
                    "Having worked in the real estate sector over 11 years across Dubai"
                    "hong kong and india,i come with a rich experience"
                    " of different aspects of the property market....",
                    style: TextStyle(
    fontSize: 13, color: Colors.grey, letterSpacing: 0.5
    ),),
    )
    ),
    Padding(
    padding: const EdgeInsets.only(top: 1, left: 5.0, right: 320),
    child: Text("BRN", style: TextStyle(
    fontSize: 12, color: Colors.grey, letterSpacing: 0.5
    ),),
    ),
    Padding(
    padding: const EdgeInsets.only(top: 5, left: 10.0, right: 310),
    child: Text("40841", style: TextStyle(
    fontSize: 15, color: Colors.black, letterSpacing: 0.5
    ),),
    ),
    Padding(
    padding: const EdgeInsets.only(top: 10, left: 10.0, right: 290),
    child: Text("Experience", style: TextStyle(
    fontSize: 12, color: Colors.grey, letterSpacing: 0.5
    ),),
    ),
    Padding(
    padding: const EdgeInsets.only(top: 5, left: 10.0, right: 310),
    child: Text("5 Years", style: TextStyle(
    fontSize: 15, color: Colors.black, letterSpacing: 0.5
    ),),
    ),
    //ending about details

    ],
    )
    );
                  });
                 /* setState(() {
                   if(selected == 'About') {
                     Visibility(
                       visible: _isVisible,
                         child:SizedBox(
                        width: double.infinity,
                          height: 300,
                          child:  Column(
                            children: [
                              //About details
                              Padding(
                                padding: const EdgeInsets.only(top: 20, left: 0.0, right: 310),
                                child: Text("About", style: TextStyle(
                                    fontSize: 18, color: Colors.black, letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10, left: 0.0, right: 300),
                                child: Text("Language(s)", style: TextStyle(
                                    fontSize: 10, color: Colors.grey, letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2, left: 0.0, right: 320),
                                child: Text("dfgh ", style: TextStyle(
                                    fontSize: 15, color: Colors.black, letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20, left: 0.0, right: 310),
                                child: Text("Expertise", style: TextStyle(
                                    fontSize: 10, color: Colors.grey, letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2, left: 0.0, right: 310),
                                child: Text("About", style: TextStyle(
                                    fontSize: 15, color: Colors.black, letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20, left: 0.0, right: 290),
                                child: Text("Services Area", style: TextStyle(
                                    fontSize: 10, color: Colors.grey, letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2, left: 0.0, right: 310),
                                child: Text("About", style: TextStyle(
                                    fontSize: 15, color: Colors.black, letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20, left: 0.0, right: 310),
                                child: Text("Properties", style: TextStyle(
                                    fontSize: 10, color: Colors.grey, letterSpacing: 0.5
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
                                        padding: const EdgeInsets.only(
                                            top: 5, left: 5, right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadiusDirectional.circular(8.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red,
                                              offset: const Offset(
                                                0.3,
                                                0.5,
                                              ),
                                              blurRadius: 0.5,
                                              spreadRadius: 0.8,
                                            ), //BoxShadow
                                            BoxShadow(
                                              color: Colors.white,
                                              offset: const Offset(0.5, 0.5),
                                              blurRadius: 0.5,
                                              spreadRadius: 0.5,
                                            ), //BoxShadow
                                          ],
                                        ),

                                        child: Row(
                                          children: [
                                            Text("18 Properties for Rent", style: TextStyle(
                                                letterSpacing: 0.5,
                                                color: Colors.black,
                                                fontSize: 13
                                            ), textAlign: TextAlign.left,),
                                            Padding(
                                                padding: const EdgeInsets.only(left: 5, right: 5),
                                                child: Image.asset("assets/images/arrow.png",
                                                  width: 15,
                                                  height: 15,
                                                  fit: BoxFit.contain,)
                                            ),

                                          ],
                                        )
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 2.0, top: 20, bottom: 0),
                                    child: Container(
                                      // width: 130,
                                        height: 35,
                                        padding: const EdgeInsets.only(
                                            top: 8, left: 5, right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadiusDirectional.circular(8.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red,
                                              offset: const Offset(
                                                0.3,
                                                0.5,
                                              ),
                                              blurRadius: 0.5,
                                              spreadRadius: 0.8,
                                            ), //BoxShadow
                                            BoxShadow(
                                              color: Colors.white,
                                              offset: const Offset(0.5, 0.5),
                                              blurRadius: 0.5,
                                              spreadRadius: 0.5,
                                            ), //BoxShadow
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Text("18 Properties for Rent", style: TextStyle(
                                                letterSpacing: 0.5,
                                                color: Colors.black,
                                                fontSize: 13
                                            ), textAlign: TextAlign.left,),
                                            Padding(
                                                padding: const EdgeInsets.only(left: 5, right: 5),
                                                child: Image.asset("assets/images/arrow.png",
                                                  width: 15,
                                                  height: 15,
                                                  fit: BoxFit.contain,)
                                            ),
                                          ],
                                        )
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20, left: 10.0, right: 290),
                                child: Text("Description", style: TextStyle(
                                    fontSize: 15, color: Colors.black, letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 8, left: 20.0, right: 10),
                                  child: SizedBox(
                                    width: 400,
                                    height: 70,
                                    child: Text(
                                      "Having worked in the real estate sector over 11 years across Dubai"
                                          "hong kong and india,i come with a rich experience"
                                          " of different aspects of the property market....",
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey, letterSpacing: 0.5
                                      ),),
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 1, left: 5.0, right: 320),
                                child: Text("BRN", style: TextStyle(
                                    fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5, left: 10.0, right: 310),
                                child: Text("40841", style: TextStyle(
                                    fontSize: 15, color: Colors.black, letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10, left: 10.0, right: 290),
                                child: Text("Experience", style: TextStyle(
                                    fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5, left: 10.0, right: 310),
                                child: Text("5 Years", style: TextStyle(
                                    fontSize: 15, color: Colors.black, letterSpacing: 0.5
                                ),),
                              ),
                              //ending about details

                            ],
                          )

                      ));
                   }


                  });*/
                },
                child:  Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 2.0, top: 20, bottom: 0),
                    child: Container(
                      // width: 130,
                      height: 35,
                      padding: const EdgeInsets.only(top: 8,left: 12,right: 12),
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
                            color: Colors.white,
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 0.5,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                        ],
                      ),
                      child: Text("About",style: TextStyle(
                          letterSpacing: 0.5,color: Colors.blue,fontSize: 15
                      ),textAlign: TextAlign.center,),
                    )
                )
              ),


              GestureDetector(
                onTap: (){
                  //visibility
                  Visibility(
                      visible: _isVisible,
                      child: Column(
                        children: [
                          //Searchbar
                          Padding(
                            padding: const EdgeInsets.only(top: 15,left: 10,right: 10),
                            child: Container(
                              width: 350,
                              height: 50,
                              padding: const EdgeInsets.only(top: 13),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red,
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
                                  hintText: 'Search for a locality,area or city',
                                  hintStyle: TextStyle(color: Colors.grey,fontSize: 15,
                                      letterSpacing: 0.5),

                                  // Add a clear button to the search bar
                                 /* suffixIcon: IconButton(
                                    alignment: Alignment.topLeft,
                                    icon: Icon(Icons.mic),
                                    onPressed: () => _searchController.clear(),
                                  ),*/

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
                      )
                  );
                },
                child:  Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 2.0, top: 20, bottom: 0),
                  child: Container(
                    // width: 130,
                      height: 35,
                      padding: const EdgeInsets.only(top: 8,left: 12,right: 12),
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
                            color: Colors.white,
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 0.5,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                        ],
                      ),
                      child:   Text("Properties",style: TextStyle(
                          letterSpacing: 0.5,color: Colors.black,fontSize: 15
                      ),textAlign: TextAlign.center,)
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 5.0, top: 20, bottom: 0),
                child: Container(
                  // width: 130,
                  height: 35,
                  padding: const EdgeInsets.only(top: 8,left: 5,right: 0),
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
                        color: Colors.white,
                        offset: const Offset(0.5, 0.5),
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                    ],
                  ),
                    child:   Text("Reviews",style: TextStyle(
                        letterSpacing: 0.5,color: Colors.black,fontSize: 15
                    ),textAlign: TextAlign.center,)
                ),
              ),
            ],
          ),

          SizedBox(
            height: 100,
          )
          ]
    )
        )
    );
  
  }

  //  _topCategoriesListView() {
  //
  // }



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