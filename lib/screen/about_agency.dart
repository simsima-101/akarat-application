import 'dart:convert';
import 'package:Akarat/model/agencyagentmodel.dart';
import 'package:Akarat/model/agencypropertiesmodel.dart';
import 'package:Akarat/screen/agency_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/agency_detailModel.dart';
import 'package:Akarat/screen/findagent.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/shared_preference_manager.dart';


class About_Agency extends StatefulWidget {
  const About_Agency({super.key, required this.data});
  final String data;
  @override
  State<About_Agency> createState() => _About_AgencyState();
}
class _About_AgencyState extends State<About_Agency> {
  AgencyDetailmodel? agencyDetailmodel;
  int pageIndex = 0;
  bool isFavorited = false;
  int? property_id ;
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
    fetchProducts(widget.data);
    getFilesApi(widget.data);
    getAgentsApi(widget.data);
    readData();
  }

  Future<void> fetchProducts(data) async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://akarat.com/api/company/$data'));
    Map<String,dynamic> jsonData=json.decode(response.body);
    debugPrint("Status Code: ${response.statusCode}");
    if (response.statusCode == 200) {
      debugPrint("API Response: ${jsonData.toString()}");
      debugPrint("API 200: ");
      AgencyDetailmodel parsedModel = AgencyDetailmodel.fromJson(jsonData);
      debugPrint("Parsed ProductModel: ${parsedModel.toString()}");
      setState(() {
        debugPrint("API setState: ");
       /* String title = jsonData['title'] ?? 'No title';
        debugPrint("API title: $title");*/
        agencyDetailmodel = parsedModel;

      });

      debugPrint("productModels title_after: ${agencyDetailmodel!.name}");

    } else {
      // Handle error if needed
    }
  }
AgencyPropertiesModel? agencyPropertiesModel;
AgencyAgentsModel? agencyAgentsModel;

  Future<void> getFilesApi(user) async {
    final response = await http.get(Uri.parse("https://akarat.com/api/company/properties/$user"));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      AgencyPropertiesModel feature= AgencyPropertiesModel.fromJson(data);

      setState(() {
        agencyPropertiesModel = feature ;

      });

    } else {
      //return FeaturedModel.fromJson(data);
    }
  }

  Future<void> getAgentsApi(user) async {
    final response = await http.get(Uri.parse("https://akarat.com/api/company/agents/$user"));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      AgencyAgentsModel feature= AgencyAgentsModel.fromJson(data);

      setState(() {
        agencyAgentsModel = feature ;

      });

    } else {
      //return FeaturedModel.fromJson(data);
    }
  }

  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if (agencyDetailmodel == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // Show loading state
      );
    }
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: buildMyNavBar(context),
        body: DefaultTabController(
        length: 4,
        child: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Container(
                    height: screenSize.height*0.18,
                    color: Color(0xFFF5F5F5),
                   // color: Colors.grey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 20,top: 0,bottom: 0),
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
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => FindAgent()));
                                },
                                        child: Image.asset("assets/images/ar-left.png",
                                          width: 15,
                                          height: 15,
                                          fit: BoxFit.contain,),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 280,top: 10,bottom: 15),
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
                              child: Image.asset("assets/images/share.png",
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0,top: 0,right: 0,bottom: 10),
                          child: Container(
                            height: screenSize.height*0.1,
                            width: screenSize.width*0.88,
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
                            child:  Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 0,left: 0),
                                  width: screenSize.width*0.29,
                                  height: screenSize.height*0.1,
                                 // color: Colors.grey,
                                  child: CachedNetworkImage( // this is to fetch the image
                                    imageUrl: (agencyDetailmodel!.image.toString()),
                                    fit: BoxFit.contain,

                                  ),

                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 10,right: 0,top: 10),
                                  height: screenSize.height*0.085,
                                  width: screenSize.width*0.56,
                                  // color: Colors.grey,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Padding(padding: const EdgeInsets.only(left: 10,right: 0,top: 10),
                                            child: Text(agencyDetailmodel!.name.toString(),style: TextStyle(
                                                fontSize: 17,letterSpacing: 0.5,fontWeight: FontWeight.bold
                                            ),),
                                          ),

                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Padding(padding: const EdgeInsets.only(left: 10,right: 0,top: 5,bottom: 5),
                                            child: Container(
                                              width: screenSize.width*0.27,
                                              height: screenSize.height*0.033,
                                              padding: const EdgeInsets.only(top: 5,),
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
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 3.0,right: 3),
                                                child: Text("${agencyDetailmodel!.propertiesCount}  Properties",textAlign: TextAlign.center,style:
                                                TextStyle(letterSpacing: 0.5,color: Colors.blueAccent)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
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
                        height: 35,
                        padding: const EdgeInsets.only(top: 7,),
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
                        height: 35,
                        padding: const EdgeInsets.only(top: 7,),
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
                        height: 35,
                        padding: const EdgeInsets.only(top: 7,),
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
                        height: 35,
                        padding: const EdgeInsets.only(top: 7,),
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
                      height: screenSize.height*10,
                      child: TabBarView(
                          children: [
                            //About
                            Container(
                              //padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                               margin: const EdgeInsets.only(left: 15,right: 15,top: 30),
                               // height: 800,
                             // color: Colors.grey,
                                child:  Column(
                                  children: [
                                    //About details
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0, left: 10.0, right: 0),
                                      child: Row(
                                        children: [
                                          Text("About  ", style: TextStyle(
                                              fontSize: 20, color: Colors.black, letterSpacing: 0.5,
                                            fontWeight: FontWeight.bold
                                          ),textAlign: TextAlign.start,),
                                          Text(""),
                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(top: 5, left: 10.0, right: 0),
                                      child: Row(
                                        children: [
                                          Text("Description ", style: TextStyle(
                                              fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold
                                          ),),
                                          Text(""),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 0, left: 10.0, right: 0),
                                        child: Container(
                                         // color: Colors.grey,
                                          width: screenSize.width*1,
                                          height: screenSize.height*0.2,
                                          child:  ListView(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              children: <Widget>[
                                                Text(
                                                  agencyDetailmodel!.description.toString(),
                                                  style: TextStyle(
                                                      fontSize: 13, color: Colors.black,
                                                      letterSpacing: 0.5,fontWeight: FontWeight.bold,height: 1.5
                                                  ),),
                                              ]
                                          ),
                                        )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20, left: 10.0, right: 0),
                                      child: Row(
                                        children: [
                                          Text("Properties", style: TextStyle(
                                              fontSize: 15, color: Colors.grey, letterSpacing: 0.5
                                          ),),
                                          Text(""),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 5.0, top: 10, bottom: 0),
                                          child: Container(
                                            // width: 130,
                                              height: 35,
                                              padding: const EdgeInsets.only(
                                                  top: 0, left: 5, right: 5),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadiusDirectional.circular(8.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red,
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
                                      padding: const EdgeInsets.only(top: 15, left: 10.0, right: 0),
                                      child: Row(
                                        children: [
                                          Text("Service Areas", style: TextStyle(
                                              fontSize: 15, color: Colors.grey, letterSpacing: 0.5,
                                              height: 1.0
                                          ),),
                                          Text("")
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, left: 10.0, right: 0),
                                      child: Row(
                                        children: [
                                          Text("Meydan City, Al Marjan Island, Dubailand", style: TextStyle(
                                              fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                              height: 1.0
                                          ),),
                                          Text("")
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15, left: 10.0, right: 0),
                                      child: Row(
                                        children: [
                                          Text("Property Type", style: TextStyle(
                                              fontSize: 15, color: Colors.grey, letterSpacing: 0.5
                                          ),),
                                          Text("")
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, left: 8.0, right: 0),
                                      child: Row(
                                        children: [
                                          Text(" Villas, Townhouses,Apartments", style: TextStyle(
                                              fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                              height: 1.0
                                          ),),
                                          Text("")
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15, left: 10.0, right: 0),
                                      child: Row(
                                        children: [
                                          Text("DED", style: TextStyle(
                                              fontSize: 15, color: Colors.grey, letterSpacing: 0.5
                                          ),),
                                          Text("")
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, left: 10.0, right: 0),
                                      child: Row(
                                        children: [
                                          Text(agencyDetailmodel!.ded.toString(), style: TextStyle(
                                              fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                              height: 1.0
                                          ),),
                                          Text("")
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15, left: 10.0, right: 0),
                                      child: Row(
                                        children: [
                                          Text("RERA", style: TextStyle(
                                              fontSize: 15, color: Colors.grey, letterSpacing: 0.5
                                          ),),
                                          Text("")
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, left: 10.0, right: 0),
                                      child: Row(
                                        children: [
                                          Text(agencyDetailmodel!.rera.toString(), style: TextStyle(
                                              fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                              height: 1.0
                                          ),),
                                          Text("")
                                        ],
                                      ),
                                    ),
                                    //ending about details

                                  ],
                                )
                            ),
                            //Properties
                            Container(
                             // height: screenSize.height*0.8,
                             // color: Colors.grey,
                              margin: const EdgeInsets.only(left: 10,right: 15,top: 20),
                              child:  Column(
                                children: [
                                  //About details
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5,left: 5),
                                    child:  Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5,left: 5,right: 0),
                                          child: Container(
                                            width: screenSize.width*0.65,
                                            height: 45,
                                            padding: const EdgeInsets.only(top: 2),
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
                                        Padding(padding: const EdgeInsets.only(top: 10,left: 20,right: 5),
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10,left: 0),
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
                                              child:Padding(padding: const EdgeInsets.only(left: 1,right: 3),
                                                  child:   Text("All",style: TextStyle(
                                                      letterSpacing: 0.5,color: Colors.black,fontSize: 12,
                                                    fontWeight: FontWeight.bold
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
                                              child: Padding(padding: const EdgeInsets.only(left: 1,right: 3),
                                                  child:   Text("Buy",style: TextStyle(
                                                      letterSpacing: 0.5,color: Colors.black,fontSize: 12,
                                                      fontWeight: FontWeight.bold
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
                                                child:Padding(padding: const EdgeInsets.only(left: 1,right: 3),
                                                    child:   Text("Rent",style: TextStyle(
                                                        letterSpacing: 0.5,color: Colors.black,fontSize: 12,
                                                        fontWeight: FontWeight.bold
                                                    ),textAlign: TextAlign.center,)
                                                )
                                            ),
                                          )
                                        ]),

                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0,right: 0,top: 15),
                                    child:   ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      physics: const ScrollPhysics(),
                                      itemCount: agencyPropertiesModel?.data?.length ?? 0,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        if(agencyPropertiesModel== null){
                                          return Scaffold(
                                            body: Center(child: CircularProgressIndicator()), // Show loading state
                                          );
                                        }
                                        return SingleChildScrollView(
                                            child: GestureDetector(
                                              onTap: (){
                                                String id = agencyPropertiesModel!.data![index].id.toString();
                                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                    Agency_Detail(data: id)));
                                              },
                                              child : Padding(
                                                padding: const EdgeInsets.only(top: 0.0,left: 10,right: 10),
                                                child: Card(
                                                  color: Colors.white,
                                                  borderOnForeground: true,
                                                  shadowColor: Colors.white,
                                                  elevation: 10,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 5.0,top: 0,right: 5),
                                                    child: Column(
                                                      // spacing: 5,// this is the coloumn
                                                      children: [
                                                        Padding(
                                                            padding: const EdgeInsets.only(top: 0.0),
                                                            child:ClipRRect(
                                                                borderRadius: BorderRadius.circular(12),
                                                                child: Stack(
                                                                    children: [
                                                                      AspectRatio(
                                                                        aspectRatio: 1.6,
                                                                        // this is the ratio
                                                                        child: ListView.builder(
                                                                          scrollDirection: Axis.horizontal,
                                                                          physics: const ScrollPhysics(),
                                                                          itemCount: agencyPropertiesModel?.data?[index].media?.length ?? 0,
                                                                          shrinkWrap: true,
                                                                          itemBuilder: (BuildContext context, int index) {
                                                                            return CachedNetworkImage( // this is to fetch the image
                                                                              imageUrl: (agencyPropertiesModel!.data![index].media![index].originalUrl.toString()),
                                                                              fit: BoxFit.fill,
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top: 5,
                                                                        right: 10,
                                                                        child: Container(
                                                                          margin: const EdgeInsets.only(left: 320,top: 10,bottom: 0),
                                                                          height: 35,
                                                                          width: 35,
                                                                          padding: const EdgeInsets.only(top: 0,left: 0,right: 5,bottom: 5),
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
                                                                          // child: Positioned(
                                                                          // child: Icon(Icons.favorite_border,color: Colors.red,),)
                                                                          child: IconButton(
                                                                            padding: EdgeInsets.only(left: 5,top: 7),
                                                                            alignment: Alignment.center,
                                                                            icon: Icon(
                                                                              isFavorited ? Icons.favorite : Icons.favorite_border,
                                                                              color: isFavorited ? Colors.red : Colors.red,
                                                                            ),
                                                                            onPressed: () {
                                                                              setState(() {
                                                                                property_id=agencyPropertiesModel!.data![index].id;
                                                                                if(token == ''){
                                                                                  //  Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                                                                                }
                                                                                else{
                                                                                  //   toggledApi(token,property_id);
                                                                                }
                                                                                isFavorited = !isFavorited;
                                                                              });
                                                                            },
                                                                          ),
                                                                          //)
                                                                        ),
                                                                      ),
                                                                    ]
                                                                )
                                                            )
                                                        ),

                                                        Padding(padding: const EdgeInsets.only(top: 5),
                                                          child: ListTile(
                                                            title: Padding(
                                                              padding: const EdgeInsets.only(top: 5.0,bottom: 5),
                                                              child: Text(agencyPropertiesModel!.data![index].title.toString(),
                                                                style: TextStyle(
                                                                    fontSize: 16,height: 1.4
                                                                ),),
                                                            ),
                                                            subtitle: Text('${agencyPropertiesModel!.data![index].price} AED',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,fontSize: 22,height: 1.4
                                                              ),),
                                                          ),
                                                        ),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Padding(padding: const EdgeInsets.only(left: 15,right: 5,top: 0,bottom: 10),
                                                              child:  Image.asset("assets/images/map.png",height: 14,),
                                                            ),
                                                            Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                                              child: Text(agencyPropertiesModel!.data![index].location.toString(),style: TextStyle(
                                                                  fontSize: 13,height: 1.4,
                                                                  overflow: TextOverflow.visible
                                                              ),),
                                                            ),
                                                          ],
                                                        ),
                                                        /*  Row(
                                                children: [
                                                  Padding(padding: const EdgeInsets.only(left: 15,right: 5,top: 5),
                                                    child: Image.asset("assets/images/bed.png",height: 13,),
                                                  ),
                                                  Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                                      child: Text(agentProperties!.data![index].bedrooms.toString())
                                                  ),
                                                  Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 5),
                                                    child: Image.asset("assets/images/bath.png",height: 13,),
                                                  ),
                                                  Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                                      child: Text(featuredModel!.data![index].bathrooms.toString())
                                                  ),
                                                  Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 5),
                                                    child: Image.asset("assets/images/messure.png",height: 13,),
                                                  ),
                                                  Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                                      child: Text(featuredModel!.data![index].squareFeet.toString())
                                                  ),
                                                ],
                                              ),*/
                                                        Row(
                                                          children: [
                                                            Padding(padding: const EdgeInsets.only(left: 30,top: 20,bottom: 15),
                                                              child: ElevatedButton.icon(onPressed: (){},
                                                                  label: Text("call",style: TextStyle(
                                                                      color: Colors.black
                                                                  ),),
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: Colors.grey[50],
                                                                    alignment: Alignment.center,
                                                                    elevation: 1,
                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                    padding: EdgeInsets.symmetric(vertical: 1.0,horizontal: 40),
                                                                    textStyle: TextStyle(letterSpacing: 0.5,
                                                                        color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold
                                                                    ),
                                                                  ),
                                                                  icon: Icon(Icons.call,color: Colors.red,)),
                                                            ),
                                                            // Text(product.description),
                                                            Padding(padding: const EdgeInsets.only(left: 15,top: 20,bottom: 15),
                                                              child: ElevatedButton.icon(onPressed: (){},
                                                                  label: Text("Watsapp",style: TextStyle(
                                                                      color: Colors.black
                                                                  ),),
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: Colors.grey[50],
                                                                    alignment: Alignment.center,
                                                                    elevation: 1,
                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                    padding: EdgeInsets.symmetric(vertical: 1.0,horizontal: 30),
                                                                    textStyle: TextStyle(letterSpacing: 0.5,
                                                                        color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold
                                                                    ),
                                                                  ),
                                                                  icon: Image.asset("assets/images/whats.png",height: 20,)
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                      ],
                                                    ),
                                                  ),

                                                ),
                                              ),

                                            )

                                        );
                                      },
                                    ),

                                  ),
                                ],
                              ),
                            ),
                            //Agent
                            Container(
                              //padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                margin: const EdgeInsets.only(left: 10,right: 10,top: 20),
                                // height: 800,
                               //  color: Colors.grey,
                                child:  Column(
                                  children: [
                                     ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      physics: const ScrollPhysics(),
                                      itemCount: agencyAgentsModel?.data?.length ?? 0,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        if(agencyAgentsModel== null){
                                          return Scaffold(
                                            body: Center(child: CircularProgressIndicator()), // Show loading state
                                          );
                                        }
                                        return SingleChildScrollView(
                                          child: GestureDetector(
                                            onTap: (){
                                             // Navigator.push(context, MaterialPageRoute(builder: (context) => AboutAgent(data: '${agentsModel.id}')));
                                            },
                                            child : Padding(
                                              padding: const EdgeInsets.only(left: 8.0,right: 8,top: 0,bottom: 5),
                                              child: Card(
                                                color: Colors.white,
                                                shadowColor: Colors.white,
                                                elevation: 20,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 0.0,top: 0,right: 0,bottom: 5),
                                                  child: Column(
                                                    // spacing: 5,// this is the coloumn
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                              margin: const EdgeInsets.only(top: 0,left: 5),
                                                              width: screenSize.width*0.25,
                                                              height: screenSize.height*0.1,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadiusDirectional.circular(63.0),
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
                                                                    blurRadius: 0.5,
                                                                    spreadRadius: 0.5,
                                                                  ), //BoxShadow
                                                                ],
                                                              ),
                                                              child: CircleAvatar(
                                                                backgroundImage: NetworkImage(agencyAgentsModel!.data![index].image.toString()),
                                                              )
                                                          ),
                                                          Container(
                                                            margin: const EdgeInsets.only(left: 10,right: 0,top: 10),
                                                            height: screenSize.height*0.13,
                                                            width: screenSize.width*0.6,
                                                            //color: Colors.grey,
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 10),
                                                                      child: Text(agencyAgentsModel!.data![index].name.toString(),style: TextStyle(
                                                                          fontSize: 17,letterSpacing: 0.5,fontWeight: FontWeight.bold
                                                                      ),),
                                                                    ),
                                                                    Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                                                      child: Text(""),),
                                                                  ],
                                                                ),
                                                               /* Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 0.0),
                                                                      child:
                                                                      Text(agencyAgentsModel!.data![index].email.toString(),style: TextStyle(
                                                                          overflow: TextOverflow.visible,fontWeight: FontWeight.bold
                                                                      ),textAlign: TextAlign.right,maxLines: 2,
                                                                        softWrap: true,),
                                                                    ),
                                                                    Text("")
                                                                  ],
                                                                ),*/
                                                                /*  Row(
                                    children: [
                                      Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                      child: Text("Service Area:",style: TextStyle(
                                        fontSize: 12,letterSpacing: 0.5
                                      ),),),
                                      Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                        child: Text("",style: TextStyle(
                                            fontSize: 12,letterSpacing: 0.5
                                        ),),),
                                    ],
                                  ),*/
                                                                Row(
                                                                  children: [
                                                                    Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                                                      child: Text("Speaks:",style: TextStyle(
                                                                          fontSize: 12,letterSpacing: 0.5
                                                                      ),),),
                                                                    Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                                                      child: Text(agencyAgentsModel!.data![index].languages.toString(),style: TextStyle(
                                                                          fontSize: 12,letterSpacing: 0.5
                                                                      ),),),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 10),
                                                                      child: Container(
                                                                        width: screenSize.width*0.14,
                                                                        height: screenSize.height*0.027,
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
                                                                        Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 8.0),
                                                                              child: Text(agencyAgentsModel!.data![index].sale.toString(),textAlign: TextAlign.center,style:
                                                                              TextStyle(letterSpacing: 0.5,color: Colors.blueAccent)),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 5.0),
                                                                              child: Text("Sale",textAlign: TextAlign.center,style:
                                                                              TextStyle(letterSpacing: 0.5,color: Colors.blueAccent)),
                                                                            ),
                                                                          ],
                                                                        ),

                                                                      ),
                                                                    ),
                                                                    Padding(padding: const EdgeInsets.only(left: 10,right: 0,top: 10),
                                                                      child: Container(
                                                                        width: screenSize.width*0.15,
                                                                        height: screenSize.height*0.027,
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
                                                                        Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 8.0),
                                                                              child: Text(agencyAgentsModel!.data![index].rent.toString(),textAlign: TextAlign.center,style:
                                                                              TextStyle(letterSpacing: 0.5,color: Colors.blueAccent)),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 5.0),
                                                                              child: Text("Rent",textAlign: TextAlign.center,style:
                                                                              TextStyle(letterSpacing: 0.5,color: Colors.blueAccent)),
                                                                            ),
                                                                          ],
                                                                        ),

                                                                      ),
                                                                    ),

                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                              ),
                                            ),
                                          ),

                                        );
                                      },
                                    ),

                                  ],
                                )
                            ),
                            //Review
                            Container(
                                height: screenSize.height*0.8,
                               // color: Colors.grey,
                                margin: const EdgeInsets.only(left: 10,right: 10,top: 20),
                                child:  Column(
                                    children: [
                                      //About details
                                      Padding(padding: const EdgeInsets.only(top: 10,left: 10,right: 0),
                                        child: Row(
                                          children: [
                                            Text("Reviews",style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),textAlign: TextAlign.left,),
                                            Text(""),
                                          ],
                                        ),
                                      ),
                                      Padding(padding: const EdgeInsets.only(top: 10,left: 10,right: 10),
                                        child: Container(
                                          //   width: 250,
                                            height: screenSize.height*0.15,
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
                if(isDataRead == true){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));
                }
                else{
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));

                }              });
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