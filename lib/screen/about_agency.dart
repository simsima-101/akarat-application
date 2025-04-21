import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Akarat/model/agencyagentmodel.dart';
import 'package:Akarat/model/agencypropertiesmodel.dart';
import 'package:Akarat/screen/agency_detail.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/agency_detailModel.dart';
import 'package:Akarat/screen/findagent.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../model/togglemodel.dart';
import '../utils/shared_preference_manager.dart';
import 'htmlEpandableText.dart';
import 'login.dart';


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
    _loadFavorites();
  }


  ToggleModel? toggleModel;

  Future<void> fetchProducts(String data) async {
    final uri = Uri.parse('https://akarat.com/api/company/$data');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      debugPrint("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        debugPrint("✅ API Success Response: ${jsonData.toString()}");

        final parsedModel = AgencyDetailmodel.fromJson(jsonData);

        if (!mounted) return;

        setState(() {
          agencyDetailmodel = parsedModel;
          debugPrint("✅ Agency Name: ${agencyDetailmodel?.name}");
        });
      } else {
        debugPrint("❌ API Error Status: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("⏱ Request timed out");
    } on SocketException {
      debugPrint("📡 No internet connection");
    } catch (e) {
      debugPrint("🚨 Unexpected error: $e");
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
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if (agencyDetailmodel == null) {
      return Scaffold(
          body: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerCard(),)
        // body: Center(child: const ShimmerCard()), // Show loading state
      );
    }
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        body: DefaultTabController(
        length: 4,
            child: Column(
                children: <Widget>[
                  Container(
                    height: screenSize.height*0.22,
                    color: Color(0xFFF5F5F5),
                   // color: Colors.grey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(

                            spacing:screenSize.width*0.7,
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
                                    Navigator.of(context).pop();
                                  },
                                          child: Image.asset("assets/images/ar-left.png",
                                            width: 15,
                                            height: 15,
                                            fit: BoxFit.contain,),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 0,top: 10,bottom: 15),
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
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0,top: 0,right: 0,bottom: 0),
                          child: Container(
                            height: screenSize.height*0.12,
                            width: screenSize.width*0.91,
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
                              borderRadius: BorderRadius.circular(10),
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
                                  margin: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                  height: screenSize.height*0.088,
                                  width: screenSize.width*0.61,
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
                                              width: screenSize.width*0.3,
                                              height: screenSize.height*0.033,
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
                                                borderRadius: BorderRadius.circular(6),),
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
                    padding: const EdgeInsets.only(top: 15,left: 0,right: 0),
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
                        height: 40,
                        padding: const EdgeInsets.only(top: 9,),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('About',textAlign: TextAlign.center,

                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        width: 80,
                        height: 40,
                        padding: const EdgeInsets.only(top: 9,),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Properties',textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        width: 80,
                        height: 40,
                        padding: const EdgeInsets.only(top: 9,),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Agents',textAlign: TextAlign.center,
                          // style: tabTextStyle(context)
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        width: 80,
                        height: 40,
                        padding: const EdgeInsets.only(top: 9,),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Review',textAlign: TextAlign.center,
                          // style: tabTextStyle(context)
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                      child: TabBarView(
                          children: [
                            //About
                            SingleChildScrollView(
                                child:  Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      //About details
                                      const SizedBox(height: 10,),
                                      Padding(
                                           padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                                      const SizedBox(height: 10,),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Row(
                                          children: [
                                            Text("Description ", style: TextStyle(
                                                fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold
                                            ),),
                                            Text(""),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                        child: HtmlExpandableText(
                                          htmlContent: agencyDetailmodel!.description.toString()
                                              .replaceAll('\r\n', '<br>'),
                                        ),
                                      ),

                                      const SizedBox(height: 10,),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Row(
                                          children: [
                                            Text("Properties", style: TextStyle(
                                                fontSize: 15, color: Colors.grey, letterSpacing: 0.5
                                            ),),
                                            Text(""),
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
                                              text: "18 Properties for Rent",
                                              iconPath: "assets/images/arrow.png",
                                            ),
                                            const SizedBox(width: 4,),
                                            _buildTagContainer(
                                              text: "18 Properties for Sale",
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
                                            Text("Service Areas", style: TextStyle(
                                                fontSize: 15, color: Colors.grey, letterSpacing: 0.5,
                                                height: 1.0
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
                                            Text("Meydan City, Al Marjan Island, Dubailand", style: TextStyle(
                                                fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                                height: 1.0
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
                                            Text("Property Type", style: TextStyle(
                                                fontSize: 15, color: Colors.grey, letterSpacing: 0.5
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
                                            Text("Villas, Townhouses,Apartments", style: TextStyle(
                                                fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                                height: 1.0
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
                                            Text("DED", style: TextStyle(
                                                fontSize: 15, color: Colors.grey, letterSpacing: 0.5
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
                                            Text(agencyDetailmodel!.ded.toString(), style: TextStyle(
                                                fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                                height: 1.0
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
                                            Text("RERA", style: TextStyle(
                                                fontSize: 15, color: Colors.grey, letterSpacing: 0.5
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
                                            Text(agencyDetailmodel!.rera.toString(), style: TextStyle(
                                                fontSize: 15, color: Colors.black, letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                                height: 1.0
                                            ),),
                                            Text("")
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20,)
                                      //ending about details
                                    ],
                                  ),
                                )
                            ),
                            //Properties
                            SingleChildScrollView(
                                child:  Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                  children: [
                                    //About details
                                   // const SizedBox(height: 20,),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      child: Row(
                                        children: [
                                          // Search Box (Flexible instead of Expanded)
                                          Flexible(
                                            child: Container(
                                              height: 45,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(0.3, 0.3),
                                                    blurRadius: 0.3,
                                                    spreadRadius: 0.3,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    offset: Offset(0.0, 0.0),
                                                    blurRadius: 0.0,
                                                    spreadRadius: 0.0,
                                                  ),
                                                ],
                                              ),
                                              child: TextField(
                                                controller: _searchController,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Select Location',
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                    letterSpacing: 0.5,
                                                  ),
                                                  prefixIcon: Icon(Icons.location_on, color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Filter Icon and Label
                                          Column(
                                            children: [
                                              Image.asset("assets/images/filter.png", width: 20, height: 30),
                                              const Text(
                                                "Filters",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: ["All", "Buy", "Rent"].map((label) {
                                          return Container(
                                            width: screenSize.width * 0.25,
                                            height: 35,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
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
                                            ),
                                            child: Text(
                                              label,
                                              style: const TextStyle(
                                                letterSpacing: 0.5,
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 0,right: 0,top: 15),
                                      child:   ListView.builder(
                                        padding: const EdgeInsets.all(0),
                                        scrollDirection: Axis.vertical,
                                        physics: const ScrollPhysics(),
                                        itemCount: agencyPropertiesModel?.data?.length ?? 0,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          if (agencyPropertiesModel == null) {
                                            return Scaffold(
                                                body: ListView.builder(
                                                  itemCount: 5,
                                                  itemBuilder: (context, index) => const ShimmerCard(),)
                                              // body: Center(child: const ShimmerCard()), // Show loading state
                                            );
                                          }
                                          bool isFavorited = favoriteProperties.contains(agencyPropertiesModel!.data![index].id);
                                          return SingleChildScrollView(
                                              child: GestureDetector(
                                                onTap: (){
                                                  String id = agencyPropertiesModel!.data![index].id.toString();
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                      Agency_Detail(data: id)));
                                                },
                                                child : Padding(
                                                  padding: const EdgeInsets.only(top: 0.0,left: 0,right: 0),
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
                                                                            itemBuilder: (BuildContext context, int mediaIndex) {
                                                                              return CachedNetworkImage(
                                                                                imageUrl: agencyPropertiesModel!.data![index].media![mediaIndex].originalUrl.toString(),
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
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 5),
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
                                                          Row(
                                                            children: [
                                                              const SizedBox(width: 10),
                                                              Expanded(
                                                                child: ElevatedButton.icon(
                                                                  onPressed: () async {
                                                                    String phone = 'tel:${agencyPropertiesModel!.data![index].phoneNumber}';
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
                                                                    final phone = agencyPropertiesModel!.data![index].whatsapp;
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

                                    ),
                                  ],
                                  ),
                                ),
                            ),
                            //Agent
                            SingleChildScrollView(
                                child:  Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
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
                                                padding: const EdgeInsets.only(left: 0.0,right: 0,top: 0,bottom: 5),
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
                                                              width: screenSize.width*0.55,
                                                             // color: Colors.grey,
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
                                                                          width: screenSize.width*0.16,
                                                                          height: screenSize.height*0.029,
                                                                          padding: const EdgeInsets.only(top: 2,),
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
                                                                            borderRadius: BorderRadius.circular(6),),
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
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(left: 10,right: 0,top: 10),
                                                                        child: Container(
                                                                          width: screenSize.width*0.16,
                                                                          height: screenSize.height*0.029,
                                                                          padding: const EdgeInsets.only(top: 2,),
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
                                                                            borderRadius: BorderRadius.circular(6),),
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
                                  ),
                                )
                            ),
                            //Review
                            SingleChildScrollView(
                                  child:  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
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
                                        Padding(padding: const EdgeInsets.only(top: 10,left: 10,right: 5),
                                          child: Container(
                                            //   width: 250,
                                              height: screenSize.height*0.17,
                                              padding: const EdgeInsets.only(top: 5),
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
                                                borderRadius: BorderRadius.circular(10),),
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
                                                          Row(
                                                            spacing: screenSize.width*0.35,
                                                            children: [
                                                              Text(""),
                                                              Container(
                                                                  margin: const EdgeInsets.only(left: 0,top: 5,bottom: 0),
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
                                                                    ),
                                  )
                            )
                          ]
                      )
                  )
                ]
            )

        )
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
                      String phone = 'tel:${agencyDetailmodel!.phone}';
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
                    final phone = agencyDetailmodel!.whatsapp; // without plus
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
                      path: '${agencyDetailmodel!.email}', // Replace with actual email
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