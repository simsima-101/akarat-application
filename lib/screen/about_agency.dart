import 'dart:async';
import 'dart:convert';
import 'package:Akarat/model/agencyagentmodel.dart';
import 'package:Akarat/model/agencypropertiesmodel.dart' as propertyModel;
import 'package:Akarat/screen/agency_detail.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/agency_detailModel.dart';
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
import 'package:Akarat/utils/whatsapp_button.dart';


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

  final TextEditingController _locationController = TextEditingController();
  // Method to read data from shared preferences
  void readData() async {
    token = await prefManager.readStringFromPref();
    email = await prefManager.readStringFromPrefemail();
    result = await prefManager.readStringFromPrefresult();
    setState(() {
      isDataRead = true;
    });
  }
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  List<propertyModel.Property> allProperties = [];
  propertyModel.AgencyPropertiesResponseModel? agencyPropertiesModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAgencyDetails();
    getAgentsApi(widget.data);
    readData();
    _loadFavorites();

    getFilesApi(widget.data); // Load page 1
    _scrollController.addListener(() {
      print("📍 Scroll position: ${_scrollController.position.pixels}");
      print("📍 Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMoreData) {
        print("🚀 Triggering next page fetch");
        getFilesApi(widget.data);
      }
    });
  }

  Future<void> _loadAgencyDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedKey = 'agency_details_${widget.data}';
    final cachedTimeKey = 'cached_time_agency_${widget.data}';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cachedTimeKey) ?? 0;

    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cachedKey);
      if (cachedData != null) {
        final jsonData = json.decode(cachedData);
        final model = AgencyDetailmodel.fromJson(jsonData);
        setState(() {
          agencyDetailmodel = model;
        });
        return;
      }
    }

    try {
      final uri = Uri.parse('https://akarat.com/api/company/${widget.data}');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final parsedModel = AgencyDetailmodel.fromJson(jsonData);

        await prefs.setString(cachedKey, json.encode(jsonData));
        await prefs.setInt(cachedTimeKey, now);

        if (mounted) {
          setState(() {
            agencyDetailmodel = parsedModel;
          });
        }
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Error: $e");
    }
  }

  ToggleModel? toggleModel;

  AgencyAgentsModel? agencyAgentsModel;

  Future<void> getFilesApi(String user) async {
    if (isLoadingMore || !hasMoreData) return;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'agency_props_${user}_page_$currentPage';
    final cacheTimeKey = 'agency_props_time_${user}_page_$currentPage';

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // ⏱ Use cache if within 6 hours
    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final feature = propertyModel.AgencyPropertiesResponseModel.fromJson(jsonData);

        final newProperties = feature.data?.data ?? [];
        final meta = feature.data?.meta;

        setState(() {
          allProperties.addAll(newProperties);
          if (meta != null && meta.currentPage != null && meta.lastPage != null) {
            if (meta.currentPage! >= meta.lastPage!) {
              hasMoreData = false;
            } else {
              currentPage = meta.currentPage! + 1;
            }
          } else {
            hasMoreData = false;
          }
          isLoadingMore = false;
        });

        print("✅ Loaded agency properties from cache (page $currentPage)");
        return;
      }
    }

    // 🛰️ Fallback: API fetch
    setState(() => isLoadingMore = true);
    try {
      final response = await http.get(
        Uri.parse("https://akarat.com/api/company/properties/$user?page=$currentPage"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feature = propertyModel.AgencyPropertiesResponseModel.fromJson(data);
        final newProperties = feature.data?.data ?? [];
        final meta = feature.data?.meta;

        await prefs.setString(cacheKey, jsonEncode(data));
        await prefs.setInt(cacheTimeKey, now);

        setState(() {
          allProperties.addAll(newProperties);
          if (meta != null && meta.currentPage != null && meta.lastPage != null) {
            if (meta.currentPage! >= meta.lastPage!) {
              hasMoreData = false;
            } else {
              currentPage = meta.currentPage! + 1;
            }
          } else {
            hasMoreData = false;
          }
          isLoadingMore = false;
        });

        print("✅ API properties loaded & cached (page $currentPage)");
      } else {
        print("❌ Failed: status code ${response.statusCode}");
        setState(() => isLoadingMore = false);
      }
    } catch (e) {
      print("❌ Error fetching properties: $e");
      setState(() => isLoadingMore = false);
    }
  }

// Make sure to dispose the controller
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getAgentsApi(String user) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'agency_agents_$user';
    final cacheTimeKey = 'agency_agents_time_$user';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = json.decode(cachedData);
        final cachedModel = AgencyAgentsModel.fromJson(jsonData);
        setState(() {
          agencyAgentsModel = cachedModel;
        });
        return;
      }
    }

    // If no cache or cache is stale, fetch from API
    try {
      final response = await http
          .get(Uri.parse("https://akarat.com/api/company/agents/$user"))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final freshModel = AgencyAgentsModel.fromJson(data);

        await prefs.setString(cacheKey, json.encode(data));
        await prefs.setInt(cacheTimeKey, now);

        setState(() {
          agencyAgentsModel = freshModel;
        });
      } else {
        debugPrint("❌ Agents API failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Agents API error: $e");
    }
  }

  Future<void> toggledApi( token,  propertyId) async {
    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/toggle-saved-property'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "property_id": propertyId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        toggleModel = ToggleModel.fromJson(jsonData);
        debugPrint("✅ Property toggled successfully");
      } else {
        debugPrint("❌ Toggle failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Toggle error: $e");
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
                  const SizedBox(height: 20,),
                  Container(
                    height: screenSize.height * 0.22,
                    color: Color(0xFFF5F5F5),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ instead of spacing
                            children: [
                              // Container(
                              //   margin: const EdgeInsets.only(left: 20),
                              //   height: 35,
                              //   width: 35,
                              //   padding: const EdgeInsets.all(7),
                              //   decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.circular(20.0),
                              //     boxShadow: [
                              //       BoxShadow(
                              //         color: Colors.grey,
                              //         offset: Offset(0.3, 0.3),
                              //         blurRadius: 0.3,
                              //         spreadRadius: 0.3,
                              //       ),
                              //       BoxShadow(
                              //         color: Colors.white,
                              //         offset: Offset(0.0, 0.0),
                              //         blurRadius: 0.0,
                              //         spreadRadius: 0.0,
                              //       ),
                              //     ],
                              //   ),
                              //   child: GestureDetector(
                              //     onTap: () {
                              //       Navigator.of(context).pop();
                              //     },
                              //     child: Image.asset(
                              //       "assets/images/ar-left.png",
                              //       width: 15,
                              //       height: 15,
                              //       fit: BoxFit.contain,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Container(
                            height: screenSize.height * 0.12,
                            width: screenSize.width * 0.91,
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
                            child: Row(
                              children: [
                                Container(
                                  width: screenSize.width * 0.29,
                                  height: screenSize.height * 0.1,
                                  child: CachedNetworkImage(
                                    imageUrl: (agencyDetailmodel!.image.toString()),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: 8), // ✅ Add spacing
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // ✅ Center vertically
                                    crossAxisAlignment: CrossAxisAlignment.start, // ✅ Align text left
                                    children: [
                                      Text(
                                        agencyDetailmodel!.name.toString(),
                                        style: TextStyle(
                                          fontSize: 17,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis, // ✅ To prevent overflow
                                        maxLines: 1,
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          "${agencyDetailmodel!.propertiesCount} Properties",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            letterSpacing: 0.5,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                      // Padding(
                                      //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      //   child: Row(
                                      //     children: [
                                      //       Text("Properties", style: TextStyle(
                                      //           fontSize: 15, color: Colors.grey, letterSpacing: 0.5
                                      //       ),),
                                      //       Text(""),
                                      //     ],
                                      //   ),
                                      // ),
                                      // const SizedBox(height: 10,),
                                      // Container(
                                      //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      //   height: MediaQuery.of(context).size.height * 0.06,
                                      //   alignment: Alignment.centerLeft,
                                      //   child: ListView(
                                      //     scrollDirection: Axis.horizontal,
                                      //     physics: const BouncingScrollPhysics(),
                                      //     shrinkWrap: true,
                                      //     children: [
                                      //       _buildTagContainer(
                                      //         text: "18 Properties for Rent",
                                      //         iconPath: "assets/images/arrow.png",
                                      //       ),
                                      //       const SizedBox(width: 4,),
                                      //       _buildTagContainer(
                                      //         text: "18 Properties for Sale",
                                      //         iconPath: "assets/images/arrow.png",
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
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
                            // SingleChildScrollView(
                            //     child:
                            Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                  children: [
                                    //About details
                                   // const SizedBox(height: 20,),
                                   //  Padding(
                                   //    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                   //    child: Row(
                                   //      crossAxisAlignment: CrossAxisAlignment.center,  // center children vertically
                                   //      children: [
                                   //        Expanded(
                                   //          child: Container(
                                   //            height: 45,
                                   //            decoration: BoxDecoration(
                                   //              color: Colors.white,
                                   //              borderRadius: BorderRadius.circular(10.0),
                                   //              boxShadow: [
                                   //                BoxShadow(
                                   //                  color: Colors.grey.withOpacity(0.3),
                                   //                  offset: const Offset(0.3, 0.3),
                                   //                  blurRadius: 2.0,
                                   //                  spreadRadius: 0.3,
                                   //                ),
                                   //                BoxShadow(
                                   //                  color: Colors.white.withOpacity(0.8),
                                   //                  offset: const Offset(0, 0),
                                   //                  blurRadius: 0,
                                   //                  spreadRadius: 0,
                                   //                ),
                                   //              ],
                                   //            ),
                                   //            child: TextField(
                                   //              controller: _locationController,
                                   //              readOnly: true,
                                   //              onTap: () {
                                   //                // TODO: open your location picker here
                                   //              },
                                   //              decoration: InputDecoration(
                                   //                hintText: "Select Location",
                                   //                hintStyle: TextStyle(
                                   //                  color: Colors.grey.shade600,
                                   //                  fontSize: 15,
                                   //                  letterSpacing: 0.5,
                                   //                ),
                                   //                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                   //                prefixIconConstraints: const BoxConstraints(
                                   //                  minWidth: 40,
                                   //                  minHeight: 40,
                                   //                ),
                                   //                prefixIcon: Padding(
                                   //                  padding: const EdgeInsets.only(left: 8, right: 8),
                                   //                  child: Image.asset(
                                   //                    "assets/images/map.png",
                                   //                    width: 24,
                                   //                    height: 24,
                                   //                    fit: BoxFit.contain,
                                   //                  ),
                                   //                ),
                                   //                border: InputBorder.none,
                                   //              ),
                                   //            ),
                                   //          ),
                                   //        ),
                                   //
                                   //        // if you want a filter button/icon next to it:
                                   //        const SizedBox(width: 16),
                                   //        // Image.asset("assets/images/filter.png", width: 24, height: 24),
                                   //      ],
                                   //    ),
                                   //  ),

                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                    //   child: Row(
                                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //     children: ["All", "Buy", "Rent"].map((label) {
                                    //       // All buttons disabled → adding "(Coming Soon)" to label
                                    //       String displayLabel = "$label (Coming Soon)";
                                    //
                                    //       return Container(
                                    //         width: screenSize.width * 0.25,
                                    //         height: 35,
                                    //         alignment: Alignment.center,
                                    //         decoration: BoxDecoration(
                                    //           color: Colors.grey.shade300, // grey background
                                    //           borderRadius: BorderRadius.circular(10),
                                    //           boxShadow: [
                                    //             BoxShadow(
                                    //               color: Colors.grey.withOpacity(0.5),
                                    //               offset: Offset(4, 4),
                                    //               blurRadius: 8,
                                    //               spreadRadius: 2,
                                    //             ),
                                    //             BoxShadow(
                                    //               color: Colors.white.withOpacity(0.8),
                                    //               offset: Offset(-4, -4),
                                    //               blurRadius: 8,
                                    //               spreadRadius: 2,
                                    //             ),
                                    //           ],
                                    //         ),
                                    //         child: Text(
                                    //           displayLabel, // Show "Buy (Coming Soon)"
                                    //           textAlign: TextAlign.center,
                                    //           style: TextStyle(
                                    //             letterSpacing: 0.5,
                                    //             color: Colors.black45,
                                    //             fontSize: 11, // slightly smaller to fit
                                    //             fontWeight: FontWeight.bold,
                                    //           ),
                                    //         ),
                                    //       );
                                    //     }).toList(),
                                    //   ),
                                    // ),


                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 0,right: 0,top: 15),
                                          child: ListView.builder(
                                            padding: const EdgeInsets.all(0),
                                            controller: _scrollController,
                                            itemCount: allProperties.length + (isLoadingMore ? 1 : 0),
                                            physics: const AlwaysScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              if (index == allProperties.length) {
                                                return Center(child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: CircularProgressIndicator(),
                                                ));
                                              }

                                              final property = allProperties[index];
                                              bool isFavorited = favoriteProperties.contains(property.id);
                                              return
                                                //SingleChildScrollView(
                                                //  child:
                                                  GestureDetector(
                                                    onTap: () {
                                                      String id = property.id.toString();
                                                      Navigator.push(context, MaterialPageRoute(
                                                        builder: (context) => Agency_Detail(data: id),
                                                      ));
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
                                                                                  shrinkWrap: false,
                                                                                  itemCount: property.media?.length ?? 0,
                                                                                  itemBuilder: (context, mediaIndex) {
                                                                                    return CachedNetworkImage(
                                                                                      imageUrl: property.media![mediaIndex].originalUrl.toString(),
                                                                                      fit: BoxFit.fill,
                                                                                    );
                                                                                  }
                                                                              ),
                                                                            ),
                                                                            // Positioned(
                                                                            //   top: 5,
                                                                            //   right: 10,
                                                                            //   child: Container(
                                                                            //     margin: const EdgeInsets.only(left: 320,top: 10,bottom: 0),
                                                                            //     height: 35,
                                                                            //     width: 35,
                                                                            //      padding: const EdgeInsets.only(top: 0,left: 0,right: 5,bottom: 5),
                                                                            //     decoration: BoxDecoration(
                                                                            //       borderRadius: BorderRadiusDirectional.circular(20.0),
                                                                            //       boxShadow: [
                                                                            //         BoxShadow(
                                                                            //           color: Colors.grey,
                                                                            //           offset: const Offset(
                                                                            //             0.3,
                                                                            //             0.3,
                                                                            //           ),
                                                                            //           blurRadius: 0.3,
                                                                            //           spreadRadius: 0.3,
                                                                            //         ), //BoxShadow
                                                                            //         BoxShadow(
                                                                            //           color: Colors.white,
                                                                            //           offset: const Offset(0.0, 0.0),
                                                                            //           blurRadius: 0.0,
                                                                            //           spreadRadius: 0.0,
                                                                            //         ), //BoxShadow
                                                                            //       ],
                                                                            //     ),
                                                                            //     // child: Positioned(
                                                                            //     // child: Icon(Icons.favorite_border,color: Colors.red,),)
                                                                            //     child: IconButton(
                                                                            //       padding: const EdgeInsets.only(left: 5, top: 7),
                                                                            //       alignment: Alignment.center,
                                                                            //       icon: Icon(
                                                                            //         isFavorited ? Icons.favorite : Icons.favorite_border,
                                                                            //         color: isFavorited ? Colors.red : Colors.red,
                                                                            //       ),
                                                                            //       onPressed: () {
                                                                            //         setState(() {
                                                                            //           property_id = property.id; // ✅ Use 'property', not agencyPropertiesModel
                                                                            //           if (token == '') {
                                                                            //             Navigator.push(
                                                                            //               context,
                                                                            //               MaterialPageRoute(builder: (context) => Login()),
                                                                            //             );
                                                                            //           } else {
                                                                            //             toggleFavorite(property_id!);
                                                                            //             toggledApi(token, property_id);
                                                                            //           }
                                                                            //           isFavorited = !isFavorited;
                                                                            //         });
                                                                            //       },
                                                                            //     ),
                                                                            //     //)
                                                                            //   ),
                                                                            // ),
                                                                          ]
                                                                      )
                                                                  )
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 5),
                                                                child: ListTile(
                                                                  title: Padding(
                                                                    padding: const EdgeInsets.only(top: 5.0,bottom: 5),
                                                                    child: Text(property.title.toString(),
                                                                      style: TextStyle(
                                                                          fontSize: 16,height: 1.4
                                                                      ),),
                                                                  ),
                                                                  subtitle: Text('${property.price} AED',
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
                                                                    child: Text(property.location.toString(),style: TextStyle(
                                                                        fontSize: 13,height: 1.4,
                                                                        overflow: TextOverflow.visible
                                                                    ),),
                                                                  ),
                                                                ],
                                                              ),
                                                              // Row(
                                                              //   children: [
                                                              //     const SizedBox(width: 10),
                                                              //     Expanded(
                                                              //       child: ElevatedButton.icon(
                                                              //         onPressed: () async {
                                                              //           String phone = 'tel:${property.phoneNumber}';
                                                              //           try {
                                                              //             final bool launched = await launchUrlString(
                                                              //               phone,
                                                              //               mode: LaunchMode.externalApplication,
                                                              //             );
                                                              //             if (!launched) print("❌ Could not launch dialer");
                                                              //           } catch (e) {
                                                              //             print("❌ Exception: $e");
                                                              //           }
                                                              //         },
                                                              //         icon: const Icon(Icons.call, color: Colors.red),
                                                              //         label: const Text("Call", style: TextStyle(color: Colors.black)),
                                                              //         style: ElevatedButton.styleFrom(
                                                              //           backgroundColor: Colors.grey[100],
                                                              //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                              //           elevation: 3,
                                                              //           padding: const EdgeInsets.symmetric(vertical: 10),
                                                              //         ),
                                                              //       ),
                                                              //     ),
                                                              //     const SizedBox(width: 10),
                                                              //     Expanded(
                                                              //       child: ElevatedButton.icon(
                                                              //         onPressed: () async {
                                                              //           final phone = property.whatsapp;
                                                              //           final url = Uri.parse("https://api.whatsapp.com/send/?phone=%2B$phone&text&type=phone_number&app_absent=0");
                                                              //           if (await canLaunchUrl(url)) {
                                                              //             try {
                                                              //               final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
                                                              //               if (!launched) print("❌ Could not launch WhatsApp");
                                                              //             } catch (e) {
                                                              //               print("❌ Exception: $e");
                                                              //             }
                                                              //           } else {
                                                              //             print("❌ WhatsApp not available");
                                                              //           }
                                                              //         },
                                                              //         icon: Image.asset("assets/images/whats.png", height: 20),
                                                              //         label: const Text("WhatsApp", style: TextStyle(color: Colors.black)),
                                                              //         style: ElevatedButton.styleFrom(
                                                              //           backgroundColor: Colors.grey[100],
                                                              //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                              //           elevation: 1,
                                                              //           padding: const EdgeInsets.symmetric(vertical: 10),
                                                              //         ),
                                                              //       ),
                                                              //     ),
                                                              //     const SizedBox(width: 10),
                                                              //   ],
                                                              // ),
                                                              const SizedBox(height: 10),
                                                            ],
                                                          ),
                                                        ),

                                                      ),
                                                    ),

                                                  );

                                             // );
                                            },
                                          ),
                                      ),
                                    ),
                                  ],
                                  ),
                                ),
                           // ),
                            //Agent
                            // AGENTS TAB
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                itemCount: agencyAgentsModel?.data?.length ?? 0,
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  if (agencyAgentsModel == null) {
                                    return Center(child: CircularProgressIndicator());
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      // Navigate if needed
                                    },
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 10,
                                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            // Agent image
                                            Container(
                                              width: screenSize.width * 0.2,
                                              height: screenSize.width * 0.2,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.3),
                                                    offset: Offset(0, 2),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(agencyAgentsModel!.data![index].image.toString()),
                                              ),
                                            ),

                                            SizedBox(width: 10),

                                            // Agent details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Name
                                                  Text(
                                                    agencyAgentsModel!.data![index].name.toString(),
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),

                                                  // Speaks
                                                  Text(
                                                    "Speaks: ${agencyAgentsModel!.data![index].languages.toString()}",
                                                    style: TextStyle(fontSize: 12, letterSpacing: 0.5),
                                                  ),
                                                  SizedBox(height: 8),

                                                  // Sale & Rent buttons
                                                  // Container(
                                                  //   width: screenSize.width * 0.35,
                                                  //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                                  //   decoration: BoxDecoration(
                                                  //     color: Colors.white,
                                                  //     borderRadius: BorderRadius.circular(6),
                                                  //     boxShadow: [
                                                  //       BoxShadow(
                                                  //         color: Colors.grey.withOpacity(0.3),
                                                  //         offset: Offset(2, 2),
                                                  //         blurRadius: 6,
                                                  //         spreadRadius: 1,
                                                  //       ),
                                                  //     ],
                                                  //   ),
                                                  //   child: Column(
                                                  //     crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  //     children: [
                                                  //       // Sale button
                                                  //       // Container(
                                                  //       //   height: 24,
                                                  //       //   alignment: Alignment.center,
                                                  //       //   decoration: BoxDecoration(
                                                  //       //     color: Colors.grey.shade200,
                                                  //       //     borderRadius: BorderRadius.circular(4),
                                                  //       //     boxShadow: [
                                                  //       //       BoxShadow(
                                                  //       //         color: Colors.grey.withOpacity(0.2),
                                                  //       //         offset: Offset(1, 1),
                                                  //       //         blurRadius: 3,
                                                  //       //         spreadRadius: 1,
                                                  //       //       ),
                                                  //       //     ],
                                                  //       //   ),
                                                  //       //   child: Text(
                                                  //       //     "${agencyAgentsModel!.data![index].sale} Sale (Coming Soon)",
                                                  //       //     textAlign: TextAlign.center,
                                                  //       //     style: TextStyle(
                                                  //       //       letterSpacing: 0.4,
                                                  //       //       color: Colors.black54,
                                                  //       //       fontWeight: FontWeight.w500,
                                                  //       //       fontSize: 9,
                                                  //       //     ),
                                                  //       //   ),
                                                  //       // ),
                                                  //       // SizedBox(height: 5),
                                                  //       //
                                                  //       // // Rent button
                                                  //       // Container(
                                                  //       //   height: 24,
                                                  //       //   alignment: Alignment.center,
                                                  //       //   decoration: BoxDecoration(
                                                  //       //     color: Colors.grey.shade200,
                                                  //       //     borderRadius: BorderRadius.circular(4),
                                                  //       //     boxShadow: [
                                                  //       //       BoxShadow(
                                                  //       //         color: Colors.grey.withOpacity(0.2),
                                                  //       //         offset: Offset(1, 1),
                                                  //       //         blurRadius: 3,
                                                  //       //         spreadRadius: 1,
                                                  //       //       ),
                                                  //       //     ],
                                                  //       //   ),
                                                  //       //   child: Text(
                                                  //       //     "${agencyAgentsModel!.data![index].rent} Rent (Coming Soon)",
                                                  //       //     textAlign: TextAlign.center,
                                                  //       //     style: TextStyle(
                                                  //       //       letterSpacing: 0.4,
                                                  //       //       color: Colors.black54,
                                                  //       //       fontWeight: FontWeight.w500,
                                                  //       //       fontSize: 9,
                                                  //       //     ),
                                                  //       //   ),
                                                  //       // ),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ distributes space correctly
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/home.png", height: 25),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0), // consistent spacing from right edge
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                setState(() {
                  if (token == '') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
                  }
                });
              },
              icon: pageIndex == 3
                  ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                  : const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
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