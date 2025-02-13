import 'package:drawerdemo/screen/about_agency.dart';
import 'package:drawerdemo/screen/about_agent.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(const FindAgent());

}

class FindAgent extends StatelessWidget {
  const FindAgent({Key ? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FindAgentDemo(),
    );
  }
}
class FindAgentDemo extends StatefulWidget {
  @override
  _FindAgentDemoState createState() => _FindAgentDemoState();
}
class _FindAgentDemoState extends State<FindAgentDemo> {

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
        body: DefaultTabController(
        length: 2,
        child: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.only(top: 40,left:15),
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
                      //logo 1
                      Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.only(top: 40,left:8),
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/app_icon.png'),
                          ),
                        ),
                      ),

                      //logo2
                      Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.only(top: 40,left: 2),
                        height: 30,
                        width: 125,
                        decoration: BoxDecoration(

                        ),
                       child: Text("Find My Agent",style: TextStyle(
                         color: Colors.black,letterSpacing: 0.5,fontSize: 18,fontWeight: FontWeight.bold
                       ),),
                      ),
                    ],
                  ),
                  Padding(padding: const EdgeInsets.only(top: 10,left: 15,right: 180),
                  child: Container(
                    height: 32,
                    width: 200,
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
                    child: TabBar(
                      padding: const EdgeInsets.only(top: 1,left: 1,right: 1),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 0,),
                      splashFactory: NoSplash.splashFactory,
                      indicatorWeight: 0.1,
                      labelColor: Colors.lightBlueAccent,
                      dividerColor: Colors.transparent,
                      indicatorColor: Colors.transparent,
                      tabAlignment: TabAlignment.center,
                      // onTap: (int index) => setState(() => selectedColor),
                      tabs: [
                        /* Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0, right: 145.0, top: 10, bottom: 0),
                        child: Container(
                          width: 200,
                          height: 40,
                          padding: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusDirectional.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: const Offset(
                                  0.5,
                                  0.5,
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
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                width: 70,
                                height: 30,
                                padding: const EdgeInsets.only(top: 5,left: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusDirectional.circular(8.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: const Offset(
                                        0.5,
                                        0.5,
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
                                child: Text("Agents",style: TextStyle(
                                    letterSpacing: 0.5,color: Colors.white
                                ),),
                              ),
                              Padding(padding: const EdgeInsets.only(left: 20),
                                  child:   Text("Agencies",style: TextStyle(
                                    letterSpacing: 0.5,
                                  ),textAlign: TextAlign.center,)
                              )
                            ],
                          ),
                        ),
                      ),*/

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
                                  0.0,
                                  0.0,
                                ),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
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
                                  0.0,
                                  0.0,
                                ),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ), //BoxShadow
                              BoxShadow(
                                color: Colors.white,
                                offset: const Offset(0.0, 0.0),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ), //BoxShadow
                            ],
                          ),
                          child: Text('Agencies',textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                  ),
                  ),
                  SizedBox(
                    height: 800,
                    child: TabBarView(
                      children: [
                        Container(
                          height: 800,
                         child: Column(
                           children: [
                             Padding(
                               padding: const EdgeInsets.only(top: 10,left: 5,right: 20),
                               child: Container(
                                 margin: const EdgeInsets.symmetric(vertical: 1),
                                 height: 35,
                                 child: ListView(
                                   scrollDirection: Axis.horizontal,
                                   children: <Widget>[
                                     //items
                                     //buy
                                     Padding(
                                       padding: const EdgeInsets.only(top: 10,left: 10),
                                       child:  Container(
                                         width: 70,
                                         height: 10,
                                         padding: const EdgeInsets.only(top: 2,),
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
                                         child:
                                         Text("Buy",textAlign: TextAlign.center,style:
                                         TextStyle(letterSpacing: 0.5)),

                                       ),
                                     ),
                                     //all residential
                                     Container(
                                       width: 10,
                                     ),
                                     //buy
                                     Padding(
                                       padding: const EdgeInsets.only(top: 10),
                                       child:  Container(
                                         width: 90,
                                         height: 10,
                                         padding: const EdgeInsets.only(top: 2,),
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
                                         child:  Text(" Rent",textAlign: TextAlign.center,
                                             style:
                                             TextStyle(letterSpacing: 0.5)),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                             //Searchbar
                             Padding(
                               padding: const EdgeInsets.only(top: 15,left: 15,right: 15),
                               child: Container(
                                 width: 400,
                                 height: 60,
                                 padding: const EdgeInsets.only(top: 10),
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
                                   controller: _searchController,
                                   decoration: InputDecoration(
                                     border: InputBorder.none,
                                     hintText: 'Search for a locality,area or city',
                                     hintStyle: TextStyle(color: Colors.grey,fontSize: 15,
                                         letterSpacing: 0.5),

                                     // Add a clear button to the search bar
                                     suffixIcon: IconButton(
                                       icon: Icon(Icons.mic),
                                       onPressed: () => _searchController.clear(),
                                     ),

                                     // Add a search icon or button to the search bar
                                     prefixIcon: IconButton(
                                       icon: Icon(Icons.search,color: Colors.red,),
                                       onPressed: () {
                                         // Perform the search here
                                       },
                                     ),
                                   ),
                                 ),
                               ),
                             ),
                             Padding(
                               padding: const EdgeInsets.only(
                                   left: 15.0, right: 250.0, top: 15, bottom: 0),
                               child: Container(
                                 width: 130,
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
                                     Padding(padding: const EdgeInsets.only(left: 5),
                                         child:   Icon(Icons.check_circle,color: Colors.white,)
                                     ),
                                     Padding(padding: const EdgeInsets.only(left: 5),
                                         child:   Text("Prime Agent",style: TextStyle(
                                             letterSpacing: 0.5,color: Colors.white
                                         ),textAlign: TextAlign.center,)
                                     )
                                   ],
                                 ),
                               ),
                             ),

                             Padding(padding: const EdgeInsets.only(left: 15,top: 15),
                               child: Text("Explore agents with a proven track record of high response rates "
                                   "and Authentic listings.",style: TextStyle(
                                 letterSpacing: 0.5,
                               ),),
                             ),
                             Padding(
                               padding: const EdgeInsets.only(top: 5,left: 5,right: 10),
                               child: Container(
                                 margin: const EdgeInsets.symmetric(vertical: 1),
                                 height: 35,
                                 child: ListView(
                                   scrollDirection: Axis.horizontal,
                                   children: <Widget>[
                                     //items
                                     //buy
                                     Padding(
                                       padding: const EdgeInsets.only(top: 10,left: 10),
                                       child:  Container(
                                         width: 70,
                                         height: 10,
                                         padding: const EdgeInsets.only(top: 2,),
                                         decoration: BoxDecoration(
                                           /*shape: BoxShape.rectangle,
                                  border: Border.all(
                                    width: 0,
                                  ),*/
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
                                         child:
                                         Text("Dubai",textAlign: TextAlign.center,style:
                                         TextStyle(letterSpacing: 0.5)),

                                       ),
                                     ),
                                     //all residential
                                     Container(
                                       width: 10,
                                     ),
                                     //buy
                                     Padding(
                                       padding: const EdgeInsets.only(top: 10),
                                       child:  Container(
                                         width: 90,
                                         height: 10,
                                         padding: const EdgeInsets.only(top: 2,),
                                         decoration: BoxDecoration(
                                           /*shape: BoxShape.rectangle,
                                  border: Border.all(
                                    width: 0,
                                  ),*/
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
                                         child:  Text(" Abu Dhabi",textAlign: TextAlign.center,
                                             style:
                                             TextStyle(letterSpacing: 0.5)),
                                       ),
                                     ),
                                     Container(
                                       width: 10,
                                     ),
                                     //buy
                                     Padding(
                                       padding: const EdgeInsets.only(top: 10),
                                       child:  Container(
                                         width: 90,
                                         height: 10,
                                         padding: const EdgeInsets.only(top: 2,),
                                         decoration: BoxDecoration(
                                           /*shape: BoxShape.rectangle,
                                  border: Border.all(
                                    width: 0,
                                  ),*/
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
                                         child:  Text(" Sharjah",textAlign: TextAlign.center,
                                             style:
                                             TextStyle(letterSpacing: 0.5)),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                             GestureDetector(
                               onTap: (){
                                 Navigator.push(context, MaterialPageRoute(builder: (context)=> AboutAgent()));
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
                                 Navigator.push(context, MaterialPageRoute(builder: (context)=> AboutAgent()));
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
                           ],
                         )
                        ),
                        Container(
                          height: 400,
                          padding: const EdgeInsets.only(top: 0,left: 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15,left: 15,right: 10),
                                    child: Container(
                                      width: 250,
                                      height: 50,
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
                                          hintText: 'Dubai ',
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
                                  Padding(padding: const EdgeInsets.only(top: 15,left: 25,right: 5),
                                    child: Image.asset("assets/images/filter.png",width: 20,height: 30,),
                                  ),
                                  Padding(padding: const EdgeInsets.only(top: 15,left: 5,right: 10),
                                    child: Text("Filters",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),),
                                  )
                                ],
                              ),
                              //Searchbar
                              Padding(padding: const EdgeInsets.only(left: 5,top: 10,right: 200),
                                child: Text("Featured Agencies",style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: 18,letterSpacing: 0.5,),textAlign: TextAlign.left,),
                              ),
                              Padding(padding: const EdgeInsets.only(left: 15,top: 5,right: 10),
                                child: Text("Explore agents with a proven track record of high response rates"
                                    " and authentic listings.",style: TextStyle(
                                  fontSize: 15,letterSpacing: 0.5,),textAlign: TextAlign.left,),
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
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                ]
            )
        ),
        ),
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