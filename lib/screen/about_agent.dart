import 'dart:async';
import 'dart:convert';
import 'package:Akarat/model/agentdetaill.dart';
import 'package:Akarat/model/agentpropertiesmodel.dart';
import 'package:Akarat/screen/findagent.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../model/togglemodel.dart';
import '../utils/shared_preference_manager.dart';
import 'agent_detail.dart';
import 'htmlEpandableText.dart';
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
  int? property_id;

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

  Timer? _debounce;
  @override
  void initState() {
    fetchProducts(widget.data);
    getFilesApi(widget.data);
    readData();
    _loadFavorites();
    _searchController.addListener(_onSearchChanged);
  }


  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _callSearchApi(query);
      }
    });
  }

  AgentProperties? agentProperties;

  Future<void> fetchProducts(String data) async {
    try {
      final response = await http.get(
        Uri.parse('https://akarat.com/api/agent/$data'),
      );

      debugPrint("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint("API Response: $jsonData");

        final AgentDetail parsedModel = AgentDetail.fromJson(jsonData);

        if (mounted) {
          setState(() {
            agentDetail = parsedModel;
          });
        }

        debugPrint("Agent service areas: ${agentDetail?.serviceAreas}");
      } else {
        debugPrint("❌ API Error Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception while fetching agent: $e");
    }
  }

  Future<void> _callSearchApi(query) async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://akarat.com/api/filters?'
        'search=$query&amenities=&property_type='
        '&furnished_status=&bedrooms=&min_price='
        '&max_price=&payment_period=&min_square_feet='
        '&max_square_feet=&bathrooms=&purpose='));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      AgentProperties feature= AgentProperties.fromJson(data);

      setState(() {
        agentProperties = feature ;

      });

    } else {
    }
  }

  Future<void> getFilesApi(String user) async {
    try {
      final response = await http.get(
        Uri.parse("https://akarat.com/api/agent/properties/$user"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final AgentProperties feature = AgentProperties.fromJson(data);

        if (mounted) {
          setState(() {
            agentProperties = feature;
          });
        }
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception in getFilesApi: $e");
    }
  }

  ToggleModel? toggleModel;

  Future<void> toggledApi(token, property_id) async {
    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/toggle-saved-property'),
        headers: <String, String>{'Authorization': 'Bearer $token',
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
        'favorite_properties',
        favoriteProperties.map((id) => id.toString()).toList());
  }
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if (agentDetail == null) {
      return Scaffold(
          body: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerCard(),)
        // body: Center(child: const ShimmerCard()), // Show loading state
      );
    }
    return Scaffold(
      bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Top Stack (Back & Share icons + Image)
            Stack(
              children: <Widget>[
                const SizedBox(height: 10,),
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Container(
                    height: screenSize.height*0.2,
                    width: double.infinity,
                    color: Color(0xFFEEEEEE),
                    child:   Row(
                      spacing: screenSize.width*0.75,
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
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
                          margin: const EdgeInsets.only(left: 0,top: 20,bottom: 100,),
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
            // Agent Name
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(agentDetail!.name.toString(),
                    style: TextStyle(
                        fontSize: 20, color: Colors.black, letterSpacing: 0.5)),
              ),
            ),
            // Tags Row
            Container(
              height: screenSize.height * 0.06,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  buildTag("Prime Agent", Icons.check_circle, Colors.blueAccent,
                      Colors.white),
                  buildTag("Quality Listener", Icons.stars, Color(0xFFEAD893),
                      Colors.black),
                  buildTag(
                      "Responsive Broker", Icons.call_outlined, Colors.white,
                      Colors.black,
                      border: true),
                ],
              ),
            ),
            // TabBar
            TabBar(
              padding:  EdgeInsets.only(top: 20,left: 0,right: 10),
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
                  width: screenSize.width*0.25,
                  height: screenSize.height*0.039,
                  padding: const EdgeInsets.only(top: 5,),
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
                  child: Text('About',textAlign: TextAlign.center,

                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: screenSize.width*0.25,
                  height: screenSize.height*0.039,
                  padding: const EdgeInsets.only(top: 5,),
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
                  child: Text('Properties',textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: screenSize.width*0.25,
                  height: screenSize.height*0.039,
                  padding: const EdgeInsets.only(top: 5,),
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
                  child: Text('Review',textAlign: TextAlign.center,
                    // style: tabTextStyle(context)
                  ),
                ),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  Text("About", style: TextStyle(
                                      fontSize: 18, color: Colors.black, letterSpacing: 0.5
                                  ),textAlign: TextAlign.left,),
                                  Text("")
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                    Text("Language(s)", style: TextStyle(
                                        fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                    ),),

                                  Text("")
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                   Text('${agentDetail!.languages}', style: TextStyle(
                                        fontSize: 15, color: Colors.black, letterSpacing: 0.5
                                    ),),

                                  Text("")
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  Text("Expertise", style: TextStyle(
                                        fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                    ),),
                                  Text("")
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(agentDetail!.expertise.toString(), style: TextStyle(
                                  fontSize: 15, color: Colors.black, letterSpacing: 0.5
                              ),),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  Text("Services Area", style: TextStyle(
                                        fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                    ),),
                                  Text("")
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(agentDetail!.serviceAreas!.toString(), style: TextStyle(
                                  fontSize: 15, color: Colors.black, letterSpacing: 0.5
                              ),
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                    Text("Properties", style: TextStyle(
                                        fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                    ),),
                                  Text("")
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              height: MediaQuery.of(context).size.height * 0.06,
                              alignment: Alignment.centerLeft,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  _buildTagContainer(
                                    text: "${agentDetail!.rent} Properties for Rent",
                                    iconPath: "assets/images/arrow.png",
                                  ),
                                  const SizedBox(width: 4,),
                                  _buildTagContainer(
                                    text: "${agentDetail!.sale} Properties for Sale",
                                    iconPath: "assets/images/arrow.png",
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                 Text("Description", style: TextStyle(
                                        fontSize: 13, color: Colors.black, letterSpacing: 0.5
                                    ),),

                                  Text("")
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: HtmlExpandableText(
                                htmlContent: agentDetail!.about.toString().replaceAll('\r\n', '<br>'),
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                   Text("BRN", style: TextStyle(
                                        fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                    ),),

                                  Text("")
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  Text(agentDetail!.brokerRegisterationNumber.toString(), style: TextStyle(
                                          fontSize: 15, color: Colors.black, letterSpacing: 0.5
                                      ),),
                                  Text("")
                                ],
                              ),
                            ),

                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  Text("Experience", style: TextStyle(
                                        fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                                    ),),
                                  Text("")
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  Text("${agentDetail!.experience} Years", style: TextStyle(
                                        fontSize: 15, color: Colors.black, letterSpacing: 0.5
                                    ),),
                                  Text("")
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],

                        ),

                      ),),
                  SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5,left: 5),
                              child:  Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5,left: 5,right: 15),
                                    child: Container(
                                      width: screenSize.width*0.85,
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
                                 /* Padding(
                                    padding: const EdgeInsets.only(top: 15,left: 15,right: 0),
                                    child: Image.asset("assets/images/filter.png",width: 20,height: 30,),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15,left: 5,right: 10),
                                    child: Text("Filters",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),),
                                  )*/
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
                                          color: Color(0xFFEAD893),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                              spreadRadius: 0,
                                            ),
                                            BoxShadow(
                                              color: Color(0xFFEAD893).withOpacity(0.8),
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(8),
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
                            ListView.builder(
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
                                                Row(
                                                  children: [
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: () async {
                                                          String phone = 'tel:${agentProperties!.data![index].phoneNumber}';
                                                          try {
                                                            final bool launched = await launchUrlString(
                                                              phone,
                                                              mode: LaunchMode.externalApplication,
                                                            );
                                                            if (!launched) print("❌ Could not launch dialer");
                                                          } catch (e) {
                                                            print("❌ Exception: $e");
                                                          }
                                                        },
                                                        icon: const Icon(Icons.call, color: Colors.red),
                                                        label: const Text("Call", style: TextStyle(color: Colors.black)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.grey[100],
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                          elevation: 3,
                                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: () async {
                                                          final phone = agentProperties!.data![index].whatsapp;
                                                          final url = Uri.parse("https://api.whatsapp.com/send/?phone=%2B$phone&text&type=phone_number&app_absent=0");
                                                          if (await canLaunchUrl(url)) {
                                                            try {
                                                              final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
                                                              if (!launched) print("❌ Could not launch WhatsApp");
                                                            } catch (e) {
                                                              print("❌ Exception: $e");
                                                            }
                                                          } else {
                                                            print("❌ WhatsApp not available");
                                                          }
                                                        },
                                                        icon: Image.asset("assets/images/whats.png", height: 20),
                                                        label: const Text("WhatsApp", style: TextStyle(color: Colors.black)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.grey[100],
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                          elevation: 1,
                                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),

                                              ],
                                            ),
                                          ),

                                        ),
                                      ),

                                    )

                                );
                              },
                            ),
                          ],
                        ),
                      )),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Reviews",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 6,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Avatar initials
                                    Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            offset: const Offset(0.5, 0.5),
                                            blurRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        "DM",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        "Bilsay Citak",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.star, color: Colors.amber),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "In the realm of real estate, Ben Caballero's name is synonymous with unparalleled success, particularly in the new homes market.",
                                  style: TextStyle(fontSize: 14, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

// Widget helper for tags
  Widget buildTag(String label, IconData icon, Color bgColor, Color textColor,
      {bool border = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: border ? Border.all(color: Colors.grey) : null,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.5),
                offset: Offset(0, 2),
                blurRadius: 4),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 16),
            SizedBox(width: 5),
            Text(label, style: TextStyle(color: textColor, fontSize: 12))
          ],
        ),
      ),
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
              child: GestureDetector(
                  onTap:  () async {
                    String phone = 'tel:${agentDetail!.email}';
                    try {
                      final bool launched = await launchUrlString(
                        phone,
                        mode: LaunchMode.externalApplication, // ✅ Force external
                      );
                      if (!launched) {
                        print("❌ Could not launch dialer");
                      }
                    } catch (e) {
                      print("❌ Exception: $e");
                    }

                  },
                  child: Icon(Icons.call_outlined,color: Colors.red,))
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
              child: GestureDetector(
                  onTap: () async {
                    final phone = agentDetail!.name; // without plus
                    final message = Uri.encodeComponent("Hello");
                    // final url = Uri.parse("https://api.whatsapp.com/send/?phone=971503440250&text=Hello");
                    // final url = Uri.parse("https://wa.me/?text=hello");
                    final url = Uri.parse("https://api.whatsapp.com/send/?phone=%2B$phone&text&type=phone_number&app_absent=0");

                    if (await canLaunchUrl(url)) {
                      try {
                        final launched = await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication, // 💥 critical on Android 15
                        );

                        if (!launched) {
                          print("❌ Could not launch WhatsApp");
                        }
                      } catch (e) {
                        print("❌ Exception: $e");
                      }
                    } else {
                      print("❌ WhatsApp not available or URL not supported");
                    }
                  },
                  child: Image.asset("assets/images/whats.png",height: 20,))

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
              child: GestureDetector(
                  onTap: () async {
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: '${agentDetail!.email}', // Replace with actual email
                      query: 'subject=Property Inquiry&body=Hi, I saw your property on Akarat.',
                    );

                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    } else {
                      throw 'Could not launch $emailUri';
                    }
                  },
                  child: Icon(Icons.mail,color: Colors.red,))

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
  Widget _buildTagContainer({required String text, required String iconPath}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.red,
              offset: const Offset(0.3, 0.5),
              blurRadius: 0.5,
              spreadRadius: 0.8,
            ),
            BoxShadow(
              color: Colors.white,
              offset: const Offset(0.5, 0.5),
              blurRadius: 0.5,
              spreadRadius: 0.5,
            ),
          ],
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                letterSpacing: 0.5,
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 5),
            Image.asset(
              iconPath,
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}