import 'dart:async';
import 'dart:convert';

import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/projectmodel.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/property_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/togglemodel.dart';
import '../utils/shared_preference_manager.dart';
import 'login.dart';
import 'my_account.dart';

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

  bool isDataRead = false;
  bool isFavorited = false;
  ProjectModel? projectModel;
  ToggleModel? toggleModel;
  int? property_id ;
  String token = '';
  String email = '';
  String result = '';

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
    super.initState();
    getFilesApi();
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
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController.text;
      _callSearchApi(query);
    });
  }


  Map<String, ProjectModel> _searchCache = {};
  String lastSearchQuery = '';

  Future<void> _callSearchApi(String query) async {
    query = query.trim();

    // Avoid unnecessary calls
    if (query == lastSearchQuery || query.isEmpty) return;

    lastSearchQuery = query;

    // Use cached data if available
    if (_searchCache.containsKey(query)) {
      setState(() {
        projectModel = _searchCache[query]!;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://akarat.com/api/filters?'
              'search=$query&amenities=&property_type='
              '&furnished_status=&bedrooms=&min_price='
              '&max_price=&payment_period=&min_square_feet='
              '&max_square_feet=&bathrooms=&purpose=New%20Projects'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = ProjectModel.fromJson(data);

        _searchCache[query] = result;

        if (mounted) {
          setState(() {
            projectModel = result;
          });
        }
      } else {
        debugPrint('❌ API failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🚨 Search API Error: $e');
    }
  }


  Future<void> getFilesApi() async {
    final prefs = await SharedPreferences.getInstance();
    const cacheKey = 'new_projects_cache';
    const cacheTimeKey = 'new_projects_time';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // Use cached data if less than 6 hours old
    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final ProjectModel cachedModel = ProjectModel.fromJson(jsonData);
        setState(() {
          projectModel = cachedModel;
        });
        return;
      }
    }

    // Fetch from API if no valid cache
    try {
      final response = await http.get(Uri.parse("https://akarat.com/api/new-projects"));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final ProjectModel feature = ProjectModel.fromJson(jsonData);

        // Save to cache
        await prefs.setString(cacheKey, jsonEncode(jsonData));
        await prefs.setInt(cacheTimeKey, now);

        setState(() {
          projectModel = feature;
        });
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 getFilesApi Exception: $e");
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

  @override
  Widget build(BuildContext context) {
    if (projectModel == null) {
      return Scaffold(
          body: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerCard(),) // Show loading state
      );
    }
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        appBar: AppBar(
          title: const Text(
              "New Projects", style: TextStyle(color: Colors.black,
              fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.red),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Home())), // ✅ Add close functionality
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: const IconThemeData(color: Colors.red),
          elevation: 1,
        ),
        body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          /*Row(
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

                child: GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child:  Icon(Icons.arrow_back,color: Colors.red,
                )

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
          ),*/
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
          Row(
            children: [
              Padding(padding: const EdgeInsets.only(top: 20,left: 20,right: 0),
               child: Text("Latest Projects in Dubai",textAlign: TextAlign.left,
               style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                       ),
              Text("")
            ],
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
          projectModel == null
              ? Center(child: const ShimmerCard())
              : ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            itemCount: projectModel?.data?.length ?? 0,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final item = projectModel!.data![index];
              bool isFavorited = favoriteProperties.contains(item.id);

              return GestureDetector(
                onTap: () {
                  String id = item.id.toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Property_Detail(data: id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Card(
                    color: Colors.white,
                    shadowColor: Colors.white,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1.4,
                                  child: PageView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: item.media?.length ?? 0,
                                    itemBuilder: (context, imgIndex) {
                                      return CachedNetworkImage(
                                        imageUrl: item.media![imgIndex].originalUrl.toString(),
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isFavorited ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          property_id = item.id;
                                          if (token == '') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => Login()),
                                            );
                                          } else {
                                            toggleFavorite(property_id!);
                                            toggledApi(token, property_id);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            item.title.toString(),
                            style: TextStyle(fontSize: 16, height: 1.4),overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 5),
                          Text(
                            '${item.price} AED',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Image.asset("assets/images/map.png", height: 14),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  item.location.toString(),
                                  style: TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Image.asset("assets/images/bed.png", height: 13),
                              SizedBox(width: 5),
                              Text(item.bedrooms.toString()),
                              SizedBox(width: 10),
                              Image.asset("assets/images/bath.png", height: 13),
                              SizedBox(width: 5),
                              Text(item.bathrooms.toString()),
                              SizedBox(width: 10),
                              Image.asset("assets/images/messure.png", height: 13),
                              SizedBox(width: 5),
                              Text(item.squareFeet.toString()),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    String phone = 'tel:${item.phoneNumber}';
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
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final phone = item.whatsapp;
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
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          ]
    )
    )
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 40,
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