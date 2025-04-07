import 'dart:convert';
import 'package:Akarat/model/agentdetaill.dart';
import 'package:Akarat/model/agentpropertiesmodel.dart';
import 'package:Akarat/screen/findagent.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/togglemodel.dart';
import '../utils/shared_preference_manager.dart';
import 'agent_detail.dart';
import 'login.dart';


class AboutAgent extends StatefulWidget {
  const AboutAgent({super.key, required this.data});
  final String data;
  @override
  State<AboutAgent> createState() => _AboutAgentState();
}
class _AboutAgentState extends State<AboutAgent> {
  AgentDetail? agentDetail;
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
    readData();
    _loadFavorites();

  }
  AgentProperties? agentProperties;

  Future<void> fetchProducts(data) async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://akarat.com/api/agent/$data'));
    Map<String,dynamic> jsonData=json.decode(response.body);
    debugPrint("Status Code: ${response.statusCode}");
    if (response.statusCode == 200) {
      debugPrint("API Response: ${jsonData.toString()}");
      debugPrint("API 200: ");
      AgentDetail parsedModel = AgentDetail.fromJson(jsonData);
      debugPrint("Parsed ProductModel: ${parsedModel.toString()}");
      setState(() {
        debugPrint("API setState: ");
        String title = jsonData['title'] ?? 'No title';
        debugPrint("API title: $title");
        agentDetail = parsedModel;

      });

      debugPrint("productModels title_after: ${agentDetail!.serviceAreas}");

    } else {
      // Handle error if needed
    }
  }

  Future<void> getFilesApi(user) async {
    final response = await http.get(Uri.parse("https://akarat.com/api/agent/properties/$user"));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      AgentProperties feature= AgentProperties.fromJson(data);

      setState(() {
        agentProperties = feature ;

      });

    } else {
      //return FeaturedModel.fromJson(data);
    }
  }

  ToggleModel? toggleModel;

  Future<void> toggledApi(token,property_id) async {
    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/toggle-saved-property'),
        headers: <String, String>{'Authorization':'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "property_id": property_id,
          // Add any other data you want to send in the body
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        toggleModel = ToggleModel.fromJson(jsonData);
        print(" Succesfully");
        // Navigator.push(context, MaterialPageRoute(builder: (context) => Profile_Login()));
      } else {
        throw Exception(" failed");

      }
    } catch (e) {
      setState(() {
        print('Error: $e');
      });
    }
  }

  Set<int> favoriteProperties = {}; // Stores favorite property IDs

  void toggleFavorite(int propertyId) async {
    setState(() {
      if (favoriteProperties.contains(propertyId)) {
        favoriteProperties.remove(propertyId); // Remove from favorites
      } else {
        favoriteProperties.add(propertyId); // Add to favorites
      }
    });
    await _saveFavorites();
  }

  // Load saved favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favorite_properties') ?? [];
    setState(() {
      favoriteProperties = savedFavorites.map(int.parse).toSet();
    });
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'favorite_properties', favoriteProperties.map((id) => id.toString()).toList());
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
    if (agentDetail == null) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator() ), // Show loading state
      );
    }
    return Scaffold(
        bottomNavigationBar: buildMyNavBar(context),
      backgroundColor: Colors.white,
      body: DefaultTabController(
    length: 3,
      child: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Container(
                    height: screenSize.height*0.2,
                    width: double.infinity,
                    color: Color(0xFFEEEEEE),
                  child:   Row(
                      children: [
                      GestureDetector(
                      onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> FindAgent()));
                  },
                    child:
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
                      ),
                        Container(
                            margin: const EdgeInsets.only(left: 300,top: 20,bottom: 100,),
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
                    backgroundImage: NetworkImage(agentDetail!.image.toString()),
                  ),
                )
              ],
          ),
          Container(
            margin: EdgeInsets.only(left: 0,top: 10,right: 120),
            alignment: Alignment.centerLeft,
            height: screenSize.height*0.05,
            width: screenSize.width*0.6,
           // color: Colors.grey,
            child: Padding(padding:  EdgeInsets.only(top: 0,left: 0.0,right: 0),
            child: Text(agentDetail!.name.toString(),style: TextStyle(
              fontSize: 20,color: Colors.black,letterSpacing: 0.5
            ),),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15,right: 0),
            height: screenSize.height*0.06,
            alignment: Alignment.centerLeft,
           // color: Colors.grey,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                Padding(
                  padding:  EdgeInsets.only(left: 5.0, right: 5.0, top: 8, bottom: 8),
                  child: Container(
                    width: screenSize.width*0.26,
                    height: 35,
                    padding:  EdgeInsets.only(top: 2,left: 5,right: 1),
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
                  padding:  EdgeInsets.only(left: 5.0, right: 5.0, top: 8, bottom: 8),
                  child: Container(
                    width: screenSize.width*0.31,
                    height: 35,
                    padding: const EdgeInsets.only(top: 2,left: 5,right: 3),
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
                  padding:  EdgeInsets.only(left: 5.0, right: 5.0, top: 8, bottom: 8),
                  child: Container(
                    width: screenSize.width*0.35,
                    height: 35,
                    padding: const EdgeInsets.only(top: 2,left: 5,right: 1),
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
          ),
          Container(
            margin: const EdgeInsets.only(right: 10,top: 5),
            height: screenSize.height*0.05,
            //color: Colors.grey,
            child: TabBar(
              padding:  EdgeInsets.only(top: 0,left: 0,right: 60),
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
                  width: screenSize.width*0.2,
                  height: screenSize.height*0.035,
                  padding: const EdgeInsets.only(top: 5,),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(8.0),
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
                  margin: const EdgeInsets.only(left: 20),
                  width: screenSize.width*0.2,
                  height: screenSize.height*0.035,
                  padding: const EdgeInsets.only(top: 5,),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(8.0),
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
                  margin: const EdgeInsets.only(left: 20),
                  width: screenSize.width*0.2,
                  height: screenSize.height*0.035,
                  padding: const EdgeInsets.only(top: 5,),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(8.0),
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
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: screenSize.height*10,
              child: TabBarView(
                children: [
                  Container(
                    //color: Colors.grey,
                  margin: const EdgeInsets.only(left: 20,right: 15,top: 10),
                  height: screenSize.height*0.8,
                  child:  Column(
                    children: [
                      //About details
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 10.0, right: 0),
                            child: Text("About", style: TextStyle(
                                fontSize: 18, color: Colors.black, letterSpacing: 0.5
                            ),),
                          ),
                          Text("")
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 10.0, right: 0),
                            child: Text("Language(s)", style: TextStyle(
                                fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                            ),),
                          ),
                          Text("")
                        ],
                      ),
                      Container(
                        height: 30,
                        //color: Colors.grey,
                        width: screenSize.width*0.9,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, left: 8.0, right: 0),
                          child: Text('${agentDetail!.languages}', style: TextStyle(
                              fontSize: 15, color: Colors.black, letterSpacing: 0.5
                          ),),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 10.0, right: 0),
                            child: Text("Expertise", style: TextStyle(
                                fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                            ),),
                          ),
                          Text("")
                        ],
                      ),
                      Container(
                        height: screenSize.height*0.1,
                        width: screenSize.width*0.9,
                       // color: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, left: 10.0, right: 0),
                          child: Text(agentDetail!.expertise.toString(), style: TextStyle(
                              fontSize: 15, color: Colors.black, letterSpacing: 0.5
                          ),),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 0, left: 13.0, right: 0),
                            child: Text("Services Area", style: TextStyle(
                                fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                            ),),
                          ),Text("")
                        ],
                      ),
                      Container(
                        //color: Colors.grey,
                        height: screenSize.height*0.12,
                        width: screenSize.width*0.9,
                      /*   child:  ListView.builder(
                           scrollDirection: Axis.vertical,
                           physics: const ScrollPhysics(),
                           shrinkWrap: true,
                            itemCount: agentDetail?.serviceAreas?.length ?? 0,
                            itemBuilder: (context, index) {
                              if(agentDetail!.serviceAreas == null){
                                return Scaffold(
                                  body: Center(child: CircularProgressIndicator()), // Show loading state
                                );
                              }
                              return ListTile(
                                title: Text(agentDetail!.serviceAreas![index]), // Use ! if you are sure it's not null
                              );
                            },
                          )*/
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, left: 10.0, right: 0),
                         child: Text(agentDetail!.serviceAreas!.toString(), style: TextStyle(
                             fontSize: 15, color: Colors.black, letterSpacing: 0.5
                         ),
                         ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 12.0, right: 0),
                            child: Text("Properties", style: TextStyle(
                                fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                            ),),
                          ),
                          Text("")
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10,right: 0,top: 5),
                        height: screenSize.height*0.06,
                        alignment: Alignment.centerLeft,
                       // color: Colors.grey,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0, right: 5, top: 8, bottom: 8),
                              child: Container(
                                // width: 130,
                                  height: 35,
                                  padding: const EdgeInsets.only(
                                      top: 5, left: 10, right: 8),
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
                                      Text("${agentDetail!.rent} Properties for Rent", style: TextStyle(
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
                              padding: const EdgeInsets.only(left: 10.0, right: 5, top: 8, bottom: 8),
                              child: Container(
                                // width: 130,
                                  height: 35,
                                  padding: const EdgeInsets.only(top: 8, left: 10, right: 8,bottom: 8),
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
                                      Text("${agentDetail!.sale} Properties for Sale", style: TextStyle(
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
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 12.0, right: 0),
                            child: Text("Description", style: TextStyle(
                                fontSize: 13, color: Colors.black, letterSpacing: 0.5
                            ),),
                          ),
                          Text("")
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12.0, right: 5),
                          child: SizedBox(
                            width: screenSize.width*0.9,
                            height: screenSize.height*0.2,
                            child:  ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                children: <Widget>[
                                  Text(
                                    agentDetail!.about.toString(),
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black,
                                        letterSpacing: 0.5,fontWeight: FontWeight.bold,height: 1.5
                                    ),),
                                  ]
                            ),

                          )
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 12.0, right: 0),
                            child: Text("BRN", style: TextStyle(
                                fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                            ),),
                          ),
                          Text("")
                        ],
                      ),
                      Container(
                        height: 25,
                        width: screenSize.width*0.9,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, left: 9.0, right: 0),
                          child: Text(agentDetail!.brokerRegisterationNumber.toString(), style: TextStyle(
                              fontSize: 15, color: Colors.black, letterSpacing: 0.5
                          ),),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 12.0, right: 0),
                            child: Text("Experience", style: TextStyle(
                                fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                            ),),
                          ),
                          Text("")
                        ],
                      ),
                      Container(
                        height: 25,
                        width: screenSize.width*0.9,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, left: 10.0, right: 0),
                          child: Text("${agentDetail!.experience} Years", style: TextStyle(
                              fontSize: 15, color: Colors.black, letterSpacing: 0.5
                          ),),
                        ),
                      ),
                      //ending about details

                    ],
                  )
              ),
                  Container(
                   // height: screenSize.height*0.8,
                   // color: Colors.grey,
                    margin: const EdgeInsets.only(left: 15,right: 15,top: 20),
                    child:  Column(
                      children: [
                        //About details
                        Padding(
                          padding: const EdgeInsets.only(top: 5,left: 5),
                    child:  Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5,left: 5,right: 10),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 15,left: 15,right: 0),
                          child: Image.asset("assets/images/filter.png",width: 20,height: 30,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15,left: 5,right: 10),
                          child: Text("Filters",style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),),
                        )
                      ],
                    ),
                  ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10,left: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                        Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 2.0, top: 20, bottom: 0),
                          child: Container(
                             width: 80,
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
                             width: 80,
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
                               width: 80,
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
                          ]
                         ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                        child:   ListView.builder(
                            scrollDirection: Axis.vertical,
                            physics: const ScrollPhysics(),
                            itemCount: agentProperties?.data?.length ?? 0,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if(agentProperties== null){
                                return Scaffold(
                                  body: Center(child: CircularProgressIndicator()), // Show loading state
                                );
                              }
                              bool isFavorited = favoriteProperties.contains(agentProperties!.data![index].id);
                              return SingleChildScrollView(
                                  child: GestureDetector(
                                    onTap: (){
                                      String id = agentProperties!.data![index].id.toString();
                                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                          Agent_Detail(data: id)));
                                    },
                                    child : Padding(
                                      padding: const EdgeInsets.only(top: 5.0,left: 2,right: 2,bottom: 5),
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
                                                              aspectRatio: 1.5,
                                                              // this is the ratio
                                                              child: ListView.builder(
                                                                scrollDirection: Axis.horizontal,
                                                                physics: const ScrollPhysics(),
                                                                itemCount: agentProperties?.data?[index].media?.length ?? 0,
                                                                shrinkWrap: true,
                                                                itemBuilder: (BuildContext context, int index) {
                                                                  return CachedNetworkImage( // this is to fetch the image
                                                                    imageUrl: (agentProperties!.data![index].media![index].originalUrl.toString()),
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
                                                                      property_id=agentProperties!.data![index].id;
                                                                      if(token == ''){
                                                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                                                                      }
                                                                      else{
                                                                        toggleFavorite(property_id!);
                                                                        toggledApi(token,property_id);
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
                                                    child: Text(agentProperties!.data![index].title.toString(),
                                                      style: TextStyle(
                                                          fontSize: 16,height: 1.4
                                                      ),),
                                                  ),
                                                  subtitle: Text('${agentProperties!.data![index].price} AED',
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
                                                    child: Text(agentProperties!.data![index].location.toString(),style: TextStyle(
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
                  Container(
                      height: screenSize.height*0.8,
                     // color: Colors.grey,
                      margin: const EdgeInsets.only(left: 15,right: 15,top: 20),
                      child:  Column(
                          children: [
                            //About details
                            Padding(padding: const EdgeInsets.only(top: 10,left: 5,right: 280),
                              child: Text("Reviews",style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),textAlign: TextAlign.left,),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 15,left: 5,right: 10),
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
                  ),
                ]
               )
              ),
            )
          ]
         ),
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