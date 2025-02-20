import 'package:drawerdemo/screen/home.dart';
import 'package:drawerdemo/screen/profile_login.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(const About_Agency());

}

class About_Agency extends StatelessWidget {
  const About_Agency({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: About_AgencyDemo(),
    );
  }
}

class About_AgencyDemo extends StatefulWidget {
  @override
  _About_AgencyDemoState createState() => _About_AgencyDemoState();
}
class _About_AgencyDemoState extends State<About_AgencyDemo> {
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
        backgroundColor: Colors.white,
        bottomNavigationBar: buildMyNavBar(context),
        body: DefaultTabController(
        length: 4,
        child: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Container(
                    height: 200,
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
                    child: GestureDetector(
                      onTap: (){
                       // Navigator.push(context, MaterialPageRoute(builder: (context) => FliterList()));
                      },
                              child: Image.asset("assets/images/ar-left.png",
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,),
                    ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 280,top: 35,bottom: 15),
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
                        Padding(padding: const EdgeInsets.only(left: 40,top: 0,right: 40,bottom: 15),
                          child: Container(
                            height: 100,
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
                          ),
                        ),
                      ],
                    ),

                  ),
                  TabBar(
                    padding: const EdgeInsets.only(top: 15,left: 0,right: 10),
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
                        margin: const EdgeInsets.only(left: 10),
                        width: 80,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5,),
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
                        child: Text('About',textAlign: TextAlign.center,

                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        width: 80,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5,),
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
                        child: Text('Properties',textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        width: 80,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5,),
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
                        child: Text('Agents',textAlign: TextAlign.center,
                          // style: tabTextStyle(context)
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        width: 80,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5,),
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
                        child: Text('Review',textAlign: TextAlign.center,
                          // style: tabTextStyle(context)
                        ),
                      ),
                    ],
                  ),
                  Container(
                      height: 800,
                      child: TabBarView(
                          children: [
                            Container(
                               // height: 800,
                                child:  Column(
                                  children: [
                                    //About details
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20, left: 10.0, right: 310),
                                      child: Text("About", style: TextStyle(
                                          fontSize: 20, color: Colors.black, letterSpacing: 0.5,
                                        fontWeight: FontWeight.bold
                                      ),),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(top: 2, left: 10.0, right: 280),
                                      child: Text("Description ", style: TextStyle(
                                          fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold
                                      ),),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 8, left: 20.0, right: 10),
                                        child: SizedBox(
                                          width: 400,
                                          height: 65,
                                          child: Text(
                                            "Having worked in the real estate sector over 11 years across Dubai"
                                                "hong kong and india,i come with a rich experience"
                                                " of different aspects of the property market....",
                                            style: TextStyle(
                                                fontSize: 13, color: Colors.black, letterSpacing: 0.5
                                            ),),
                                        )
                                    ),
                                  /*  Padding(
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
                                    ),*/
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0, left: 10.0, right: 310),
                                      child: Text("Properties", style: TextStyle(
                                          fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                      ),),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 5.0, top: 5, bottom: 0),
                                          child: Container(
                                            // width: 130,
                                              height: 35,
                                              padding: const EdgeInsets.only(
                                                  top: 0, left: 5, right: 10),
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
                                                      fontSize: 13,
                                                    fontWeight: FontWeight.bold
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
                                              left: 10.0, right: 5.0, top: 5, bottom: 0),
                                          child: Container(
                                            // width: 130,
                                              height: 35,
                                              padding: const EdgeInsets.only(
                                                  top: 8, left: 5, right: 5),
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
                                                      fontSize: 13,fontWeight: FontWeight.bold
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
                                      padding: const EdgeInsets.only(top: 15, left: 5.0, right: 290),
                                      child: Text("Service Areas", style: TextStyle(
                                          fontSize: 12, color: Colors.grey, letterSpacing: 0.5,
                                          height: 1.0
                                      ),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5, left: 10.0, right: 80),
                                      child: Text("Meydan City, Al Marjan Island, Dubailand", style: TextStyle(
                                          fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                          height: 1.0
                                      ),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15, left: 10.0, right: 290),
                                      child: Text("Property Type", style: TextStyle(
                                          fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                      ),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5, left: 10.0, right: 150),
                                      child: Text(" Villas, Townhouses,Apartments", style: TextStyle(
                                          fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                          height: 1.0
                                      ),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15, left: 10.0, right: 340),
                                      child: Text("DED", style: TextStyle(
                                          fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                      ),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5, left: 10.0, right: 325),
                                      child: Text(" 40841", style: TextStyle(
                                          fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                          height: 1.0
                                      ),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15, left: 10.0, right: 330),
                                      child: Text("RERA", style: TextStyle(
                                          fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                      ),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5, left: 10.0, right: 325),
                                      child: Text(" 23364", style: TextStyle(
                                          fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                          height: 1.0
                                      ),),
                                    ),
                                    //ending about details

                                  ],
                                )
                            ),
                            Container(
                              height: 800,
                              child:  Column(
                                children: [
                                  //About details
                                  Padding(padding: const EdgeInsets.only(top: 10,left: 5),
                                    child:  Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
                                          child: Container(
                                            width: 250,
                                            height: 45,
                                            padding: const EdgeInsets.only(top: 2),
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
                                                hintText: 'Select Location ',
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
                                        Padding(padding: const EdgeInsets.only(top: 10,left: 30,right: 5),
                                          child: Image.asset("assets/images/filter.png",width: 20,height: 30,),
                                        ),
                                        Padding(padding: const EdgeInsets.only(top: 10,left: 5,right: 10),
                                          child: Text("Filters",style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(padding: const EdgeInsets.only(top: 10,left: 10),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, right: 2.0, top: 20, bottom: 0),
                                            child: Container(
                                              width: 100,
                                              height: 35,
                                              padding: const EdgeInsets.only(top: 10,left: 5,right: 0),
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
                                              child:Padding(padding: const EdgeInsets.only(left: 1,right: 3),
                                                  child:   Text("All",style: TextStyle(
                                                      letterSpacing: 0.5,color: Colors.black,fontSize: 12
                                                  ),textAlign: TextAlign.center,)
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, right: 2.0, top: 20, bottom: 0),
                                            child: Container(
                                              width: 100,
                                              height: 35,
                                              padding: const EdgeInsets.only(top: 10,left: 5,right: 0),
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
                                              child: Padding(padding: const EdgeInsets.only(left: 1,right: 3),
                                                  child:   Text("Ready",style: TextStyle(
                                                      letterSpacing: 0.5,color: Colors.black,fontSize: 12
                                                  ),textAlign: TextAlign.center,)
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, right: 5.0, top: 20, bottom: 0),
                                            child: Container(
                                                width: 100,
                                                height: 35,
                                                padding: const EdgeInsets.only(top: 10,left: 5,right: 0),
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
                                                child:Padding(padding: const EdgeInsets.only(left: 1,right: 3),
                                                    child:   Text("Off-Plan",style: TextStyle(
                                                        letterSpacing: 0.5,color: Colors.black,fontSize: 12
                                                    ),textAlign: TextAlign.center,)
                                                )
                                            ),
                                          )
                                        ]),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                height: 800,
                                child:  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> About_Agency()));
                                        },
                                        child:  Padding(padding: const EdgeInsets.only(left: 15,top: 15,right: 10),
                                          child: Container(
                                            height: 120,
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
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> About_Agency()));
                                        },
                                        child:  Padding(padding: const EdgeInsets.only(left: 15,top: 15,right: 10),
                                          child: Container(
                                            height: 120,
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
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> About_Agency()));
                                        },
                                        child:  Padding(padding: const EdgeInsets.only(left: 15,top: 15,right: 10),
                                          child: Container(
                                            height: 120,
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
                                          ),
                                        ),
                                      ),
                                    ]
                                )
                            ),
                            Container(
                                height: 800,
                                child:  Column(
                                    children: [
                                      //About details
                                      Padding(padding: const EdgeInsets.only(top: 10,left: 5,right: 290),
                                        child: Text("Reviews",style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),textAlign: TextAlign.left,),
                                      ),
                                      Padding(padding: const EdgeInsets.only(top: 10,left: 15,right: 15),
                                        child: Container(
                                          //   width: 250,
                                            height: 120,
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
                                            child:Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                            alignment: Alignment.topCenter,
                                                            margin: const EdgeInsets.only(top: 5, left: 15,bottom: 0),
                                                            height: 30,
                                                            width: 30,
                                                            padding: const EdgeInsets.only(top: 6),
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
                                                            child: Text("DM",style:
                                                            TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                                color: Colors.black
                                                            ),textAlign: TextAlign.center,)
                                                        ),

                                                        //logo2
                                                        Container(
                                                          alignment: Alignment.topCenter,
                                                          margin: const EdgeInsets.only(top: 5, left: 10,right:10,bottom: 0),
                                                          /* height: 30,
                                      width: 125,*/

                                                          child: Text("Bilsay Citak", style: TextStyle(
                                                              color: Colors.black,
                                                              letterSpacing: 0.5,
                                                              fontSize: 15,fontWeight: FontWeight.bold
                                                          ),),
                                                        ),
                                                        Container(
                                                            margin: const EdgeInsets.only(left: 170,top: 5,bottom: 0),
                                                            /* height: 35,
                                      width: 35,*/
                                                            //  padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                                                            child: Icon(Icons.star,color: Colors.yellow,)
                                                          //child: Image(image: Image.asset("assets/images/share.png")),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Padding(padding: const EdgeInsets.only(top: 10,left: 10,right: 10,bottom: 10),
                                                  child: Text("In the realm of real estate, Ben Caballero's name"
                                                      " is synonymous with unparalleled success, particularly in the new homes market."),
                                                )
                                              ],

                                            )
                                        ),)
                                    ]
                                )
                            )
                          ]
                      )
                  )
                ]
            )

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