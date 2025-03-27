import 'dart:convert';

import 'package:Akarat/model/agencymodel.dart';
import 'package:Akarat/model/agentsmodel.dart';
import 'package:Akarat/screen/about_agency.dart';
import 'package:Akarat/screen/about_agent.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/utils/agencyCardScreen.dart';
import 'package:Akarat/utils/agentcardscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/shared_preference_manager.dart';

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
  List<AgentsModel> agentsmodel = [];
  List<AgencyModel> agentcymodel = [];
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
    super.initState();
    agentfetch();
    agencyfetch();
    readData();
  }

  Future<void> agentfetch() async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://akarat.com/api/agents'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        agentsmodel = jsonData.map((data) => AgentsModel.fromJson(data)).toList();
      });
    } else {
    }
  }
  Future<void> agencyfetch() async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://akarat.com/api/companies'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        agentcymodel = jsonData.map((data) => AgencyModel.fromJson(data)).toList();
      });
    } else {
    }
  }

  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      bottomNavigationBar: buildMyNavBar(context),
      backgroundColor: Colors.white,
      body:DefaultTabController(
        length: 2,
        child: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            if(token == ''){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
                            }
                            else{
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(top: 40,left:20),
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
                      ),
                      //logo 1
                      Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.only(top: 40,left:25),
                        height: 40,
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
                        margin: const EdgeInsets.only(top: 40,left: 10),
                        height: 30,
                        width: 125,
                        decoration: BoxDecoration(

                        ),
                        // child: Text(agentsmodel.em,style: TextStyle(
                        child: Text("Find My Agent",style: TextStyle(
                            color: Colors.black,letterSpacing: 0.5,fontSize: 18,fontWeight: FontWeight.bold
                        ),),
                      ),
                    ],
                  ),
                  Padding(padding: const EdgeInsets.only(top: 20,left: 5,right: 190),
                    child: Container(
                      height: 40,
                      // width: 200,
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

                          Container(
                            margin: const EdgeInsets.only(left: 3),
                            width: screenSize.width*0.2,
                            height: 30,
                            padding: const EdgeInsets.only(top: 2,),
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
                            child: Text('Agents',style:TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,

                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            width: screenSize.width*0.22,
                            height: 30,
                            padding: const EdgeInsets.only(top: 2,right: 13),
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
                            child: Text('Agency',style:TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                    ),
                  ),
                  SizedBox(
                    // height: 1800,
                    height: screenSize.height*2,
                    child: TabBarView(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 15,left: 11,right: 20),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 1),
                                height: 45,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10,left: 10,right: 15),
                                      child:  Container(
                                        width: 70,
                                        height: 10,
                                        padding: const EdgeInsets.only(top: 6,),
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
                                    //buy
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child:  Container(
                                        width: 90,
                                        height: 10,
                                        padding: const EdgeInsets.only(top: 6,),
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
                            Padding(
                              padding: const EdgeInsets.only(top: 20,left: 20,right: 20),
                              child: Container(
                                width: screenSize.width*1.0,
                                height: screenSize.height*0.07,
                                padding: const EdgeInsets.only(top: 12),
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
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 0.0, top: 20, bottom: 0),
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
                                Text("")
                              ],
                            ),
                            Padding(padding: const EdgeInsets.only(left: 20,top: 20),
                              child: Text("Explore agents with a proven track record of high response rates "
                                  "and Authentic listings.",style: TextStyle(
                                letterSpacing: 0.5,
                              ),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10,left: 10,right: 10),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 1),
                                height: 45,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10,left: 10),
                                      child:  Container(
                                        width: 70,
                                        height: 10,
                                        padding: const EdgeInsets.only(top: 8,),
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
                                        padding: const EdgeInsets.only(top: 8,),
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
                                        padding: const EdgeInsets.only(top: 8,),
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
                                        child:  Text(" Sharjah",textAlign: TextAlign.center,
                                            style:
                                            TextStyle(letterSpacing: 0.5)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ListView.builder(
                              scrollDirection: Axis.vertical,
                              physics: const ScrollPhysics(),
                              itemCount: agentsmodel.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Agentcardscreen(agentsModel: agentsmodel[index]);
                              },
                            ),
                          ],
                        ),
                        //AGENCIES
                        Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20,left: 20,right: 10),
                                  child: Container(
                                    width: screenSize.width*0.6,
                                    height: screenSize.height*0.05,
                                    padding: const EdgeInsets.only(top: 2,left: 0,right: 5),
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
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Dubai ',
                                        hintStyle: TextStyle(color: Colors.grey,fontSize: 15,),
                                        // Add a search icon or button to the search bar
                                        prefixIcon: IconButton(
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
                            Row(
                              children: [
                                Padding(padding: const EdgeInsets.only(left: 20,top: 20,right: 0),
                                  child: Text("Featured Agencies",style: TextStyle(fontWeight: FontWeight.bold,
                                    fontSize: 18,letterSpacing: 0.5,),textAlign: TextAlign.left,),
                                ),
                                Text("")
                              ],
                            ),
                            Padding(padding: const EdgeInsets.only(left: 20,top: 10,right: 10),
                              child: Text("Explore agents with a proven track record of high response rates"
                                  " and authentic listings.",style: TextStyle(
                                fontSize: 15,letterSpacing: 0.5,),textAlign: TextAlign.left,),
                            ),
                            ListView.builder(
                              scrollDirection: Axis.vertical,
                              physics: const ScrollPhysics(),
                              itemCount: agentcymodel.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Agencycardscreen(agencyModel: agentcymodel[index]);
                              },

                            ),
                          ],
                        )

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
            child: Image.asset("assets/images/whats.png",height: 20,)

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