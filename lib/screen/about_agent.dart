import 'dart:async';
import 'dart:convert';
import 'package:Akarat/model/agentdetaill.dart';
import 'package:Akarat/model/agentpropertiesmodel.dart';
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
import 'findagent.dart';
import 'htmlEpandableText.dart';
import 'login.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:Akarat/utils/whatsapp_button.dart';


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


  // lib/utils/phone_utils.dart

  String phoneCallNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (input.startsWith('+971')) return input;
    if (input.startsWith('00971')) return '+971${input.substring(5)}';
    if (input.startsWith('971')) return '+971${input.substring(3)}';
    if (input.startsWith('0') && input.length == 10)
      return '+971${input.substring(1)}';
    if (input.length == 9) return '+971$input';
    return input; // fallback
  }

  String whatsAppNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d]'), '');
    if (input.startsWith('971')) return input;
    if (input.startsWith('00971')) return input.substring(2);
    if (input.startsWith('+971')) return input.substring(1);
    if (input.startsWith('0') && input.length == 10)
      return '971${input.substring(1)}';
    if (input.length == 9) return '971$input';
    return input; // fallback
  }


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
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    fetchProducts(widget.data);        // Initial data fetch
    getFilesApi(widget.data, loadMore: false);  // Load first page of agent properties
    readData();                        // Other setups
    _loadFavorites();
    _searchController.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          hasMore &&
          !isLoading) {
        getFilesApi(widget.data, loadMore: true); // Load next page
      }
    });
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
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'agent_detail_$data';
    final cacheTimeKey = 'agent_detail_time_$data';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // ⏱ If cache is valid (within 6 hours)
    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final cachedModel = AgentDetail.fromJson(jsonData);
        setState(() {
          agentDetail = cachedModel;
        });
        debugPrint("✅ Loaded agent from cache");
        return;
      }
    }

    // 🛰 API fallback
    try {
      final response = await http.get(
        Uri.parse('https://akarat.com/api/agent/$data'),
      );

      debugPrint("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint("API Response: $jsonData");

        final parsedModel = AgentDetail.fromJson(jsonData);

        await prefs.setString(cacheKey, jsonEncode(jsonData));
        await prefs.setInt(cacheTimeKey, now);

        if (mounted) {
          setState(() {
            agentDetail = parsedModel;
          });
        }

        debugPrint("📦 Agent service areas: ${agentDetail?.serviceAreas}");
      } else {
        debugPrint("❌ API Error Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception while fetching agent: $e");
    }
  }

  Future<void> _callSearchApi(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'search_result_$query';
    final cacheTimeKey = 'search_result_time_$query';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // ⏱ 1 hour cache validity
    if (now - lastFetched < Duration(hours: 1).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final cachedModel = AgentProperties.fromJson(jsonData);
        setState(() {
          agentProperties = cachedModel;
        });
        debugPrint("✅ Loaded search result from cache");
        return;
      }
    }

    // 🔍 Fetch from API
    final uri = Uri.parse(
        'https://akarat.com/api/filters?search=$query&amenities=&property_type='
            '&furnished_status=&bedrooms=&min_price=&max_price='
            '&payment_period=&min_square_feet=&max_square_feet='
            '&bathrooms=&purpose=');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feature = AgentProperties.fromJson(data);

        await prefs.setString(cacheKey, jsonEncode(data));
        await prefs.setInt(cacheTimeKey, now);

        setState(() {
          agentProperties = feature;
        });

        debugPrint("✅ API search loaded & cached");
      } else {
        debugPrint("❌ API failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception in search: $e");
    }
  }

  Future<void> getFilesApi(String user, {bool loadMore = false}) async {
    if (isLoading) return;

    isLoading = true;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'agent_properties_$user';
    final cacheTimeKey = 'agent_properties_time_$user';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    final uri = Uri.parse("https://akarat.com/api/agent/properties/$user?page=$currentPage");

    // Use cache if not loading more and cache is valid
    if (!loadMore && now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final model = AgentProperties.fromJson(jsonData); // only 'data' saved in cache
        setState(() {
          agentProperties = model;
          hasMore = (model.meta?.currentPage ?? 1) < (model.meta?.lastPage ?? 1);
          if (hasMore) {
            currentPage = (model.meta?.currentPage ?? 1) + 1;
          }
        });
        debugPrint("📦 Loaded agent properties from cache");
        isLoading = false;
        return;
      }
    }

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = AgentProperties.fromJson(jsonData['data']);

        setState(() {
          if (loadMore) {
            final oldData = agentProperties?.data ?? [];
            final newData = model.data ?? [];
            agentProperties = AgentProperties(
              data: [...oldData, ...newData],
              links: model.links,
              meta: model.meta,
            );
          } else {
            agentProperties = model;
          }

          hasMore = (model.meta?.currentPage ?? 1) < (model.meta?.lastPage ?? 1);
          if (hasMore) {
            currentPage = (model.meta?.currentPage ?? 1) + 1;
          }
        });

        if (!loadMore) {
          await prefs.setString(cacheKey, jsonEncode(jsonData['data']));
          await prefs.setInt(cacheTimeKey, now);
          debugPrint("✅ Cached agent properties");
        }
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception in getFilesApi: $e");
    }

    isLoading = false;
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

    // 👉 This check must be OUTSIDE the "if (agentDetail == null)"
    String imageUrl = agentDetail?.image?.toString().trim() ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://akarat.com$imageUrl';
    }

    bool isValidImage = imageUrl.isNotEmpty &&
        imageUrl.toLowerCase() != 'n/a' &&
        imageUrl.toLowerCase() != 'null' &&
        imageUrl.toLowerCase().contains('.jpg') &&
        !imageUrl.toLowerCase().contains('default-image.jpg');

    // ✅ Now check if agentDetail is null
    if (agentDetail == null) {
      return Scaffold(
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerCard(),
        ),
      );
    }
    return Scaffold(
      bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // --- TOP STACK ---
            Stack(
              children: [
                // Background header bar
                Container(
                  height: screenSize.height * 0.19,
                  width: double.infinity,
                  color: const Color(0xFFEEEEEE),
                ),

                // Big Avatar
                Positioned(
                  left: 20,
                  top: 70,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(65),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.5, 0.5),
                          blurRadius: 1.0,
                          spreadRadius: 1.0,
                        ),
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 0.5,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: isValidImage
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/images/profile.png') as ImageProvider,
                    ),
                  ),
                ),

                // Back button — ✅ WORKING AFTER FIX
                // Positioned(
                //   left: 20,
                //   top: 20,
                //   child: GestureDetector(
                //     onTap: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(builder: (context) => FindAgentDemo()),
                //       );
                //     },
                //     child: Container(
                //       height: 28,
                //       width: 28,
                //       padding: const EdgeInsets.all(7),
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(20.0),
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.grey,
                //             offset: Offset(0.0, 0.0),
                //             blurRadius: 0.1,
                //             spreadRadius: 0.1,
                //           ),
                //           BoxShadow(
                //             color: Colors.white,
                //             offset: Offset(0.0, 0.0),
                //             blurRadius: 0.0,
                //             spreadRadius: 0.0,
                //           ),
                //         ],
                //       ),
                //       child: Image.asset(
                //         "assets/images/ar-left.png",
                //         width: 12,
                //         height: 12,
                //         fit: BoxFit.contain,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),




            // --- AGENT NAME ROW (only once) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Expanded(
                    child: Text(
                      agentDetail!.name.toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // --- TAGS ROW ---
            Container(
              height: screenSize.height * 0.04,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  buildTag("Prime Agent", Icons.check_circle, Colors.blueAccent, Colors.white),
                  buildTag("Quality Listener", Icons.stars, Color(0xFFEAD893), Colors.black),
                  // buildTag("Responsive Broker", Icons.call_outlined, Colors.white, Colors.black, border: true),
                ],
              ),
            ),

            // --- TAB BAR ---
            TabBar(
              padding: EdgeInsets.only(top: 10, left: 0, right: 10),
              labelPadding: const EdgeInsets.symmetric(horizontal: 0),
              splashFactory: NoSplash.splashFactory,
              indicatorWeight: 1.0,
              labelColor: Colors.lightBlueAccent,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              tabAlignment: TabAlignment.center,
              tabs: [
                Container(
                  margin: const EdgeInsets.only(left: 0),
                  width: screenSize.width * 0.25,
                  height: screenSize.height * 0.039,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('About', textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: screenSize.width * 0.25,
                  height: screenSize.height * 0.039,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Properties', textAlign: TextAlign.center),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: screenSize.width * 0.25,
                  height: screenSize.height * 0.039,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Review', textAlign: TextAlign.center),
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
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          //   child: Row(
                          //     children: [
                          //         Text("Properties", style: TextStyle(
                          //             fontSize: 12, color: Colors.grey, letterSpacing: 0.5
                          //         ),),
                          //       Text("")
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
                          //         text: "${agentDetail!.rent} Properties for Rent",
                          //         iconPath: "assets/images/arrow.png",
                          //       ),
                          //       const SizedBox(width: 4,),
                          //       _buildTagContainer(
                          //         text: "${agentDetail!.sale} Properties for Sale",
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
                                Text("Description", style: TextStyle(
                                    fontSize: 13, color: Colors.black, letterSpacing: 0.5
                                ),),

                                Text("")
                              ],
                            ),
                          ),
                          const SizedBox(height: 10,),
                          agentDetail!.about != null && agentDetail!.about!.trim().isNotEmpty
                              ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: HtmlExpandableText(
                              htmlContent: agentDetail!.about!.replaceAll('\r\n', '<br>'),
                            ),
                          )
                              : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text(
                              "No description available",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 5),
                          child: Row(
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 5, left: 5, right: 15),
                              //   child: Container(
                              //     width: screenSize.width * 0.85,
                              //     height: 40,
                              //     padding: const EdgeInsets.only(top: 5),
                              //     decoration: BoxDecoration(
                              //       color: Colors.white,                           // active background
                              //       borderRadius: BorderRadiusDirectional.circular(10.0),
                              //       border: Border.all(color: Colors.grey.shade400, width: 1), // optional border
                              //     ),
                              //     child: Padding(
                              //       padding: const EdgeInsets.only(top: 1, bottom: 3),
                              //       child: TextField(
                              //         textAlign: TextAlign.left,
                              //         controller: _searchController,
                              //         decoration: InputDecoration(
                              //           border: InputBorder.none,
                              //           hintText: 'Select Location',               // removed “(Coming Soon)”
                              //           hintStyle: TextStyle(
                              //             color: Colors.grey.shade600,
                              //             fontSize: 15,
                              //             letterSpacing: 0.5,
                              //           ),
                              //           prefixIcon: Padding(
                              //             padding: const EdgeInsets.only(top: 1, bottom: 2),
                              //             child: Icon(Icons.location_on, color: Colors.red), // active icon color
                              //           ),
                              //         ),
                              //         onTap: () {
                              //           // TODO: open location selector
                              //         },
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              /* Uncomment and style these if you need filter buttons again:
      Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 0),
        child: Image.asset("assets/images/filter.png", width: 20, height: 30),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 15, left: 5, right: 10),
        child: Text(
          "Filters",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      */
                            ],
                          ),
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.only(top: 10, left: 2),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     children: [
                        //       Padding(
                        //         padding: const EdgeInsets.only(left: 10.0, right: 2.0, top: 20, bottom: 0),
                        //         child: Container(
                        //           width: 80,
                        //           height: 35,
                        //           padding: const EdgeInsets.only(top: 10, left: 5, right: 0),
                        //           decoration: BoxDecoration(
                        //             color: Colors.grey.shade300, // grey background
                        //             borderRadius: BorderRadius.circular(8),
                        //           ),
                        //           child: Padding(
                        //             padding: const EdgeInsets.only(left: 1, right: 3),
                        //             child: Text(
                        //               "All\n(Coming Soon)", // updated text
                        //               style: TextStyle(
                        //                 letterSpacing: 0.5,
                        //                 color: Colors.grey.shade700, // grey text
                        //                 fontSize: 8,
                        //                 height: 1.2,
                        //               ),
                        //               textAlign: TextAlign.center,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       Padding(
                        //         padding: const EdgeInsets.only(left: 10.0, right: 2.0, top: 20, bottom: 0),
                        //         child: Container(
                        //           width: 80,
                        //           height: 35,
                        //           padding: const EdgeInsets.only(top: 10, left: 5, right: 0),
                        //           decoration: BoxDecoration(
                        //             color: Colors.grey.shade300, // grey background
                        //             borderRadius: BorderRadius.circular(8),
                        //           ),
                        //           child: Padding(
                        //             padding: const EdgeInsets.only(left: 1, right: 3),
                        //             child: Text(
                        //               "Ready\n(Coming Soon)",
                        //               style: TextStyle(
                        //                 letterSpacing: 0.5,
                        //                 color: Colors.grey.shade700, // grey text
                        //                 fontSize: 8,
                        //                 height: 1.2,
                        //               ),
                        //               textAlign: TextAlign.center,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       Padding(
                        //         padding: const EdgeInsets.only(left: 10.0, right: 5.0, top: 20, bottom: 0),
                        //         child: Container(
                        //           width: 80,
                        //           height: 35,
                        //           padding: const EdgeInsets.only(top: 10, left: 5, right: 0),
                        //           decoration: BoxDecoration(
                        //             color: Colors.grey.shade300, // grey background
                        //             borderRadius: BorderRadius.circular(8),
                        //           ),
                        //           child: Padding(
                        //             padding: const EdgeInsets.only(left: 1, right: 3),
                        //             child: Text(
                        //               "Off-Plan\n(Coming Soon)",
                        //               style: TextStyle(
                        //                 letterSpacing: 0.5,
                        //                 color: Colors.grey.shade700, // grey text
                        //                 fontSize: 8,
                        //                 height: 1.2,
                        //               ),
                        //               textAlign: TextAlign.center,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(0),
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: agentProperties?.data?.length ?? 0,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if(agentProperties== null){
                                  return Scaffold(
                                    body: Center(child: CircularProgressIndicator()), // Show loading state
                                  );
                                }
                                final property = agentProperties!.data![index];
                                bool isFavorited = favoriteProperties.contains(property.id);
                                return SingleChildScrollView(
                                    child: GestureDetector(
                                      // onTap: (){
                                      //   String id = property.id.toString();
                                      //   Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                      //       Agent_Detail(data: id)));
                                      // },
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
                                                          aspectRatio: 1.4,
                                                          child: PageView.builder(
                                                            scrollDirection: Axis.horizontal,
                                                            itemCount: property.media?.length ?? 0, // ✅ use 'property'
                                                            itemBuilder: (context, imgIndex) {
                                                              return CachedNetworkImage(
                                                                imageUrl: property.media![imgIndex].originalUrl.toString(), // ✅ use 'property'
                                                                fit: BoxFit.cover,
                                                              );
                                                            },
                                                          ),
                                                        ),

                                                        // ❤️ Favorite Icon (corrected)
                                                        // Positioned(
                                                        //   top: 10,
                                                        //   right: 10,
                                                        //   child: Container(
                                                        //     height: MediaQuery.of(context).size.height * 0.04,
                                                        //     width: MediaQuery.of(context).size.height * 0.04,
                                                        //     decoration: BoxDecoration(
                                                        //       color: Colors.white,
                                                        //       shape: BoxShape.circle,
                                                        //       boxShadow: [
                                                        //         BoxShadow(
                                                        //           color: Colors.grey.withOpacity(0.5),
                                                        //           blurRadius: 4,
                                                        //           offset: Offset(2, 2),
                                                        //         ),
                                                        //       ],
                                                        //     ),
                                                        //     child: Center(
                                                        //       // child: IconButton(
                                                        //       //   icon: AnimatedSwitcher(
                                                        //       //     duration: Duration(milliseconds: 300),
                                                        //       //     transitionBuilder: (child, animation) =>
                                                        //       //         ScaleTransition(scale: animation, child: child),
                                                        //       //     // child: Icon(
                                                        //       //     //   favoriteProperties.contains(property.id!) ? Icons.favorite : Icons.favorite_border,
                                                        //       //     //
                                                        //       //     //   key: ValueKey(favoriteProperties.contains(property.id!)),
                                                        //       //     //   color: Colors.red,
                                                        //       //     //   size: 18,
                                                        //       //     // ),
                                                        //       //   ),
                                                        //       //   onPressed: () async {
                                                        //       //     property_id = property.id;
                                                        //       //
                                                        //       //     if (token.isEmpty) {
                                                        //       //       print("🚫 No token - please login.");
                                                        //       //       toggleFavorite(property.id!); // Local save
                                                        //       //     } else {
                                                        //       //       print("✅ Token exists, calling toggle API...");
                                                        //       //       await toggledApi(token, property.id!);
                                                        //       //       toggleFavorite(property.id!);
                                                        //       //     }
                                                        //       //
                                                        //       //
                                                        //       //
                                                        //       //     setState(() {}); // Update UI
                                                        //       //   },
                                                        //       //
                                                        //       //
                                                        //       // ),
                                                        //     ),
                                                        //   ),
                                                        // ),

                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                Padding(padding: const EdgeInsets.only(top: 5),
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
                                                Row(
                                                  children: [
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: () async {
                                                          String phone = 'tel:${phoneCallNumber(agentDetail!.phone ?? '')}';
                                                          try {
                                                            final bool launched = await launchUrlString(
                                                              phone,
                                                              mode: LaunchMode.externalApplication,
                                                            );
                                                            if (!launched) {
                                                              print("❌ Could not launch dialer");
                                                            }
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
                                                          final phone = whatsAppNumber(agentDetail!.phone ?? '');
                                                          final message = Uri.encodeComponent("Hello");
                                                          final url = Uri.parse("https://wa.me/$phone?text=$message");

                                                          if (await canLaunchUrl(url)) {
                                                            try {
                                                              final launched = await launchUrl(
                                                                url,
                                                                mode: LaunchMode.externalApplication,
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
                        ),
                      ],
                    ),
                  ),
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