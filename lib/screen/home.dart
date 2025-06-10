import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Akarat/model/searchmodel.dart' as search;
import 'package:Akarat/model/togglemodel.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/search.dart';
import 'package:Akarat/screen/searchexample.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:Akarat/utils/fav_logout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/featuredmodel.dart' as featured;
import 'package:Akarat/screen/featured_detail.dart';
import 'package:Akarat/screen/filter.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/new_projects.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/fav_login.dart';
import '../utils/shared_preference_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:Akarat/screen/filter.dart' as filter;
import 'package:Akarat/screen/search.dart' as search;


import 'package:http/io_client.dart';
import 'package:Akarat/secure_storage.dart';
import 'package:Akarat/services/api_service.dart';


import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Save full project for guest (fav_logout)
Future<void> _saveProjectFavoriteLocally(Map<String, dynamic> project) async {
  final prefs = await SharedPreferences.getInstance();
  final favList = prefs.getStringList('favorite_projects') ?? [];
  // Prevent duplicates
  if (!favList.any((item) => jsonDecode(item)['id'] == project['id'])) {
    favList.add(jsonEncode(project));
    await prefs.setStringList('favorite_projects', favList);
  }
}

// Remove project from guest favorites
Future<void> _removeProjectFavoriteLocally(int projectId) async {
  final prefs = await SharedPreferences.getInstance();
  final favList = prefs.getStringList('favorite_projects') ?? [];
  favList.removeWhere((item) => jsonDecode(item)['id'] == projectId);
  await prefs.setStringList('favorite_projects', favList);
}

// For logged-in users, call your API as you already do


void main() {
  runApp(const Home());
}
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeDemo(),
    );
  }
}
class HomeDemo extends StatefulWidget {
  const HomeDemo({super.key});

  @override
  State<HomeDemo> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeDemo> {

  List<filter.Data> projectList = [];
  List<String> locationList = [];



  String token = '';

  // For phone calls: Always output in +971... format
  // Phone sanitizer: always outputs +971XXXXXXXXX
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

// WhatsApp sanitizer: always outputs 971XXXXXXXXX (no plus)
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




  bool loadingSavedProperties = true;
  List<Property> savedProperties = [];

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }


  @override


  Future<void> _fetchSavedProperties() async {
    final savedToken = await SecureStorage.getToken();
    if (savedToken == null) {
      // No token, navigate to Login
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
      }
      return;
    }
    setState(() {
      token = savedToken;
      loadingSavedProperties = true;
    });

    try {
      // Assuming ApiService.getSavedProperties returns List<Property>
      final List<Property> properties = (await ApiService.getSavedProperties(token!)).cast<Property>();
      setState(() {
        savedProperties = properties;
      });

    } catch (e) {
      print('Error fetching saved properties: $e');
      // Optionally show a snackbar or dialog
    } finally {
      setState(() {
        loadingSavedProperties = false;
      });
    }
  }

  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override

  int pageIndex = 0;
  String? authToken;
  String email = '';
  String result = '';

  bool isFavorited = false;
  final TextEditingController _searchController = TextEditingController();
  String location ='';

  ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  featured.FeaturedModel? featuredModel;

  search.SearchModel? searchModel;
  ToggleModel? toggleModel;
  bool isDataRead = false;
  int? property_id ;
  String purpose = '';
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
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();

    getFeaturedProperties(forceRefresh: true);

    // Fetch featured properties
    getFeaturedProperties();
    _fetchSavedProperties();

    fetchLocations();

    // Set up scroll controller for infinite scroll
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
            !isLoading &&
            hasMore) {
          getFeaturedProperties(loadMore: true);
        }
      });

    // Load favorites and saved properties
    _loadFavorites();
    _fetchSavedProperties(); // Replaces readData()

    // Focus on the desired input field after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void initToken() async {
    token = await getToken(); // ✅ fetch token from secure storage
    setState(() {});
  }



  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        backgroundColor: Colors.white,
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No',style: TextStyle(color: Colors.black,
                fontWeight: FontWeight.bold),),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes',style: TextStyle(color: Colors.black,
                fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    )) ?? false;
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




  Future<void> getFeaturedProperties({bool loadMore = false, bool forceRefresh = false}) async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    final uri = Uri.parse("https://akarat.com/api/featured-properties?page=$currentPage");
    final cacheKey = 'featured_cache_page_$currentPage';
    final cacheTimeKey = 'featured_cache_time_page_$currentPage';

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheValidityDuration = const Duration(hours: 6).inMilliseconds; // 6 hours cache

    // If forceRefresh = true → clear cache first
    if (forceRefresh) {
      await prefs.remove(cacheKey);
      await prefs.remove(cacheTimeKey);
      debugPrint("🔄 Forced cache cleared for page $currentPage");
    }

    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;
    final cachedData = prefs.getString(cacheKey);

    // 👉 Use cache if still fresh AND not forcing refresh
    if (cachedData != null && (now - lastFetched) < cacheValidityDuration && !forceRefresh) {
      final jsonData = jsonDecode(cachedData);
      final model = featured.FeaturedResponseModel.fromJson(jsonData);

      setState(() {
        if (loadMore && featuredModel != null) {
          featuredModel!.data!.addAll(model.data?.data ?? []);
        } else {
          featuredModel = model.data;
        }
        currentPage = model.data?.meta?.currentPage ?? 1;
        hasMore = (model.data?.meta?.currentPage ?? 1) < (model.data?.meta?.lastPage ?? 1);
      });

      setState(() => isLoading = false);
      return; // ✅ Done using cache
    }

    // Else → Call fresh API
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 10)); // Timeout for faster failure

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          final model = featured.FeaturedResponseModel.fromJson(jsonData);

          setState(() {
            if (loadMore && featuredModel != null) {
              featuredModel!.data!.addAll(model.data?.data ?? []);
            } else {
              featuredModel = model.data;
            }
            currentPage = model.data?.meta?.currentPage ?? 1;
            hasMore = (model.data?.meta?.currentPage ?? 1) < (model.data?.meta?.lastPage ?? 1);
          });

          // 👉 Save to cache
          prefs.setString(cacheKey, response.body);
          prefs.setInt(cacheTimeKey, now);

          debugPrint("✅ Fresh API data loaded and cached for page $currentPage");

          break; // ✅ Success, break retry loop
        }  else {
    debugPrint("❌ API Error: ${response.statusCode}");
    featuredModel = null; // Clear to avoid stuck UI
    break; // stop retry loop
    }

    } on SocketException catch (_) {
        retryCount++;
        debugPrint('⚠️ SocketException, retrying... ($retryCount/$maxRetries)');
        if (retryCount >= maxRetries) {
          debugPrint('❌ Failed after retries.');
        }
        await Future.delayed(const Duration(seconds: 1));
      } on TimeoutException catch (_) {
        retryCount++;
        debugPrint('⚠️ Timeout, retrying... ($retryCount/$maxRetries)');
        if (retryCount >= maxRetries) {
          debugPrint('❌ Failed after retries.');
        }
        await Future.delayed(const Duration(seconds: 1));
      }  catch (e) {
    debugPrint("❌ Unexpected Exception: $e");
    featuredModel = null; // Reset model
    break;
    }

  }

    setState(() => isLoading = false);
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


  Future<void> fetchLocations() async {
    debugPrint("🔍 Fetching Locations...");

    try {
      final response = await http.get(Uri.parse("https://akarat.com/api/locations"));

      debugPrint("🔍 Locations API Status: ${response.statusCode}");
      debugPrint("🔍 Locations API Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          locationList = data.cast<String>();
        });


        debugPrint("✅ Locations loaded: ${locationList.length}");
        debugPrint("Locations List: $locationList");

      } else {
        debugPrint("❌ Locations API failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Locations API exception: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 2 : 3;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          // appBar: AppBar(),
          bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
          //body: pages[pageIndex],
          backgroundColor: Colors.white,
          body:
          // SingleChildScrollView(
          // child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo 1
                  Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(top: 25,left:0),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/app_icon.png'),
                      ),
                    ),
                  ),

                  //logo2
                  Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(top: 25),
                    height: 80,
                    width: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/logo-text.png'),
                      ),
                    ),
                  ),
                ],
              ),
              //Searchbar
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 20, right: 15, bottom: 10),
                child: Container(
                  width: 400,
                  height: 70,
                  padding: const EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, // grey background
                    borderRadius: BorderRadius.circular(25.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: Offset(0.0, 0.0),
                        blurRadius: 4.0,
                        spreadRadius: 1.0,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        offset: Offset(0.0, 0.0),
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.search, color: Colors.grey), // grey icon
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Search (Coming Soon)", // updated text
                            style: TextStyle(
                              color: Colors.black45, // grey text
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8), // spacing before Vector.png

                        // You can uncomment this later when ready:
                        /*
          Image.asset(
            'assets/images/Vector.png',
            width: 36.5,
            height: 36.5,
            fit: BoxFit.contain,
          ),

          const SizedBox(width: 4), // spacing before Mic.png

          Image.asset(
            'assets/images/Mic.png',
            width: 20.55,
            height: 20,
            fit: BoxFit.contain,
          ),
          */
                      ],
                    ),
                  ),
                ),
              ),


              //images gridview
              //   Expanded(
              // child: SingleChildScrollView(
              //  child:
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await getFeaturedProperties(forceRefresh: true);
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(), // important for pull-to-refresh
                child: Column(

                children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              //logo 1
                              GestureDetector(
                                onTap: (){
                                  purpose= "Rent";
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter(data:purpose)));
                                },
                                child:  Padding(
                                  padding: const EdgeInsets.all(8),
                                  /*padding: const EdgeInsets.only(
                                      left: 17.0, right: 10.0, top: 10, bottom: 0),
                                                */
                                  child: Container(
                                      width: screenSize.width * 0.29,
                                      height: screenSize.height*0.11,
                                      padding: const EdgeInsets.only(top: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.8),
                                            offset: Offset(7, 7),
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child:   Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset("assets/images/ak-rent-red.png"
                                            ,height: 35,),
                                          Padding(
                                            padding: const EdgeInsets.all(4),
                                            child:  Text("Property For Rent",style:
                                            TextStyle(height: 1.2,
                                                letterSpacing: 0.5,
                                                fontSize: 11,fontWeight: FontWeight.bold
                                            ),),
                                          )
                                        ],
                                      )
                                  ),
                                ),
                              ),
                              //logo2
                              GestureDetector(
                                onTap: (){
                                  purpose= "Buy";
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter(data: purpose,)));
                                },
                                child:
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  /* padding: const EdgeInsets.only(
                                      left: 5.0, right: 10.0, top: 10.0, bottom: 0),*/
                                  child: Container(
                                      width: screenSize.width * 0.29,
                                      height: screenSize.height*0.11,
                                      padding: const EdgeInsets.only(top: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.8),
                                            offset: Offset(7, 7),
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child:   Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset("assets/images/ak-sale.png",height: 35,),
                                          Padding(padding: const EdgeInsets.all(4),
                                            child:  Text("Property For Sale",style:
                                            TextStyle(height: 1.2,
                                                letterSpacing: 0.5,
                                                fontSize: 11,fontWeight: FontWeight.bold
                                            ),),
                                          )
                                        ],
                                      )
                                  ),
                                ),
                              ),
                              //logo2
                              GestureDetector(
                                onTap: (){
                                  // purpose=""
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> New_Projects()));
                                },
                                child:
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  /*padding: const EdgeInsets.only(
                                      left: 5.0, right: 10.0, top: 10.0, bottom: 0),*/
                                  child: Container(
                                      width: screenSize.width * 0.3,
                                      height: screenSize.height*0.11,
                                      padding: const EdgeInsets.only(top: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.8),
                                            offset: Offset(7, 7),
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child:   Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2.0),
                                            child: Image.asset("assets/images/ak-off-plan.png",height: 35,),
                                          ),
                                          Padding(padding: const EdgeInsets.only(top: 5),
                                            child:  Text("Off-Plan-Properties",style:
                                            TextStyle(height: 1.2,
                                                letterSpacing: 0.5,
                                                fontSize: 10,fontWeight: FontWeight.bold
                                            ),),
                                          )
                                        ],
                                      )
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Row(
                            children: [
                              //logo 1
                              GestureDetector(
                                onTap: (){
                                  purpose="Commercial";
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter(data: purpose,)));
                                },
                                child:
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  /* padding: const EdgeInsets.only(
                                      left: 17.0, right: 10.0, top: 8, bottom: 0),*/
                                  child: Container(
                                      width: screenSize.width * 0.29,
                                      height: screenSize.height*0.11,
                                      padding: const EdgeInsets.only(top: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.8),
                                            offset: Offset(7, 7),
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child:   Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2.0),
                                            child: Image.asset("assets/images/commercial_new.png",height: 35,),
                                          ),
                                          Padding(padding: const EdgeInsets.all(4),
                                            child:  Text("Commercial",style:
                                            TextStyle(height: 1.2,
                                                letterSpacing: 0.5,
                                                fontSize: 11,fontWeight: FontWeight.bold
                                            ),),
                                          )

                                        ],
                                      )
                                  ),
                                ),
                              ),
                              //logo2
                              GestureDetector(
                                onTap: (){
                                  purpose= "Rent";
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter(data: purpose,)));
                                },
                                child:
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  /*padding: const EdgeInsets.only(
                                      left: 5.0, right: 10.0, top: 8, bottom: 0),*/
                                  child: Container(
                                      width: screenSize.width * 0.29,
                                      height: screenSize.height*0.11,
                                      padding: const EdgeInsets.only(top: 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.8),
                                            offset: Offset(7, 7),
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child:   Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2.0),
                                            child: Image.asset("assets/images/city.png",height: 35,),
                                          ),
                                          Padding(padding: const EdgeInsets.all(5),
                                            child:  Text("Apartments",style:
                                            TextStyle(height: 1.2,
                                                letterSpacing: 0.5,
                                                fontSize: 11,fontWeight: FontWeight.bold
                                            ),),
                                          )

                                        ],
                                      )
                                  ),
                                ),
                              ),
                              //logo2
                              GestureDetector(
                                onTap: (){
                                  purpose= "Rent";
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter(data: purpose,)));
                                },
                                child:
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  /*padding: const EdgeInsets.only(
                                      left: 5.0, right: 5.0, top: 8, bottom: 0),*/
                                  child: Container(
                                      width: screenSize.width * 0.3,
                                      height: screenSize.height*0.11,
                                      padding: const EdgeInsets.only(top: 0),
                                      decoration: BoxDecoration(

                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.8),
                                            offset: Offset(7, 7),
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child:   Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2.0),
                                            child: Image.asset("assets/images/villa-new.png",height: 35,),
                                          ),
                                          Padding(padding: const EdgeInsets.all(5),
                                            child:  Text("Villas",style:
                                            TextStyle(height: 1.2,
                                                letterSpacing: 0.5,
                                                fontSize: 11,fontWeight: FontWeight.bold
                                            ),),
                                          )

                                        ],
                                      )
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //banner
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 20.0, bottom: 0),
                          child:
                          GestureDetector(
                            onTap: ()async{
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> New_Projects()));
                            },
                            child: Container(
                              width: screenSize.width * 1.0,
                              height: 150,
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                /* mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.center,*/
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10,left: 00,right: 0),
                                      child: Container(
                                        width: screenSize.width*0.4,
                                        height: 100,
                                        // color: Colors.grey,
                                        padding: const EdgeInsets.only(top: 10,left: 10,right: 5),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("New Projects            ",style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,fontWeight: FontWeight.bold
                                            ),textAlign: TextAlign.left,),
                                            Text("Discover more about the UAE "
                                                "real estate market",style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                              softWrap: true,)
                                          ],
                                        ),
                                      )
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0.0,right: 0),
                                    child: Container(
                                        height: screenSize.height*0.15,
                                        width: screenSize.width*0.5,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        // color: Colors.grey,
                                        child: Image.asset('assets/images/banner1.jpg',fit: BoxFit.contain,)
                                    ),
                                  ),

                                ],
                              ),),
                          ),),
                        //  Text
                        Container(
                          margin: const EdgeInsets.only(top: 20,left: 5,),
                          height: screenSize.height*0.03,
                          // color: Colors.grey,
                          child:   Row(
                            spacing: screenSize.width*0.3,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "${featuredModel?.totalFeaturedProperties ?? 0} Projects",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),

                              // Row(
                              //   children: [
                              //     Padding(
                              //         padding: const EdgeInsets.only(
                              //             left: 0.0, right: 10.0, top: 0, bottom: 0),
                              //         child:  Image.asset("assets/images/filter.png",height: 20,)
                              //     ),
                              //
                              //     Padding(
                              //       padding: const EdgeInsets.only(
                              //           left: 2.0, right: 10.0, top: 0, bottom: 0),
                              //       // child:  Text(result,style: TextStyle(
                              //       child:  Text("Featured",style: TextStyle(
                              //         color: Colors.black,fontWeight: FontWeight.bold,
                              //         fontSize: 15,
                              //       ),textAlign: TextAlign.right,),
                              //     ),
                              //   ],
                              // )

                            ],
                          ),
                        ),
                        featuredModel == null
                            ? Center(child: const ShimmerCard())
                            :
                        //Expanded(
                        // child:
                        /*Expanded(
                                        child:*/
                        ListView.builder(
                          controller: _scrollController, // ✅ Attach the controller here
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(), // 👈 disable inner scroll
                          shrinkWrap: true,
                          itemCount: (featuredModel?.data?.length ?? 0) + (hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == featuredModel?.data?.length) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final item = featuredModel!.data![index];
                            final projectId = item.id;
                            bool isFavorited = favoriteProperties.contains(item.id);

                            return GestureDetector(
                              onTap: () {
                                String id = item.id.toString();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Featured_Detail(data: id),
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

                                          Column(
                                            children: [
                                              Stack(
                                                clipBehavior: Clip.none, // ✅ Allows the overlap outside the Stack
                                                children: [
                                                  // 🖼️ Property Image Carousel with Rounded Corners
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: AspectRatio(
                                                      aspectRatio: 1.4,
                                                      child: PageView.builder(
                                                        controller: _pageController,
                                                        scrollDirection: Axis.horizontal,
                                                        itemCount: item.media?.length ?? 0,
                                                        onPageChanged: (index) {
                                                          setState(() {
                                                            _currentImageIndex = index;
                                                          });
                                                        },
                                                        itemBuilder: (context, imgIndex) {
                                                          return CachedNetworkImage(
                                                            imageUrl: item.media![imgIndex].originalUrl.toString(),
                                                            fit: BoxFit.cover,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),

                                                  // ⚪ Image Indicator Dots
                                                  Positioned(
                                                    bottom: 12,
                                                    left: 0,
                                                    right: 0,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: List.generate(
                                                        item.media?.length ?? 0,
                                                            (index) {
                                                          final distance = (index - _currentImageIndex).abs();
                                                          double scale;
                                                          double opacity;

                                                          if (distance == 0) {
                                                            scale = 1.2;
                                                            opacity = 1.0;
                                                          } else if (distance == 1) {
                                                            scale = 1.0;
                                                            opacity = 0.7;
                                                          } else if (distance == 2) {
                                                            scale = 0.8;
                                                            opacity = 0.5;
                                                          } else {
                                                            scale = 0.5;
                                                            opacity = 0.0;
                                                          }

                                                          return AnimatedOpacity(
                                                            duration: Duration(milliseconds: 300),
                                                            opacity: opacity,
                                                            child: SizedBox(
                                                              width: 12, // fixed size for layout stability
                                                              height: 12,
                                                              child: Center(
                                                                child: Container(
                                                                  width: 8 * scale,
                                                                  height: 8 * scale,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    shape: BoxShape.circle,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),


                                                  // ❤️ Favorite Icon
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
                                                  //         child: IconButton(
                                                  //           icon: Icon(
                                                  //             isFavorited ? Icons.favorite : Icons.favorite_border,
                                                  //             color: Colors.red,
                                                  //             size: 18,
                                                  //           ),
                                                  //           onPressed: () async {
                                                  //             setState(() {
                                                  //               property_id = item.id;
                                                  //             });
                                                  //
                                                  //             if (token == '') {
                                                  //               // User not logged in
                                                  //               // Build bare-minimum project info for guest favorites
                                                  //               Map<String, dynamic> projectData = {
                                                  //                 "id": item.id,
                                                  //                 "title": item.title,
                                                  //                 "price": item.price,
                                                  //                 "media": item.media != null && item.media!.isNotEmpty
                                                  //                     ? [
                                                  //                   {
                                                  //                     "originalUrl": item.media![0].originalUrl.toString(),
                                                  //                   }
                                                  //                 ]
                                                  //                     : [],
                                                  //                 // Add any other fields needed by fav_logout
                                                  //               };
                                                  //               if (favoriteProperties.contains(item.id)) {
                                                  //                 // Remove from favorites
                                                  //                 await _removeProjectFavoriteLocally(item.id!);
                                                  //               } else {
                                                  //                 // Add to favorites
                                                  //                 await _saveProjectFavoriteLocally(projectData);
                                                  //               }
                                                  //               toggleFavorite(item.id!); // update UI
                                                  //             } else {
                                                  //               // User logged in
                                                  //               toggleFavorite(item.id!);
                                                  //               await toggledApi(token, item.id!); // Your API call to save/unsave favorite
                                                  //               // Optionally update guest favorites here for offline sync
                                                  //             }
                                                  //             setState(() {}); // Update UI
                                                  //           },
                                                  //         )
                                                  //     ),
                                                  //   ),
                                                  // ),

                                                  // 🧑‍💼 Overlapping Agent Profile Image
                                                  // 🧑‍💼 Overlapping Agent Profile Image
                                                  // 🧑‍💼 Agent Profile with Navigation to Featured_Detail
                                                  Positioned(
                                                    bottom: -50, // Ensures the image appears above content, not overlapping
                                                    left: 10,
                                                    child: Builder( // Ensures context is valid for Navigator
                                                      builder: (context) => GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => Featured_Detail(data: item.id.toString()),
                                                            ),
                                                          );
                                                        },
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment: CrossAxisAlignment.start, // Align text to left
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 28,
                                                              backgroundImage: AssetImage("assets/images/agent44.png"),
                                                            ),
                                                            SizedBox(height: 25),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 1), // Same as map.png padding
                                                              child: Text(
                                                                "Agent",
                                                                style: TextStyle(fontSize: 10, color: Colors.black),
                                                              ),
                                                            ),
                                                            SizedBox(height: 2),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 1),
                                                              // Consistent padding
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(bottom: 6,),
                                                                child: Text(
                                                                  "John David",
                                                                  style: TextStyle(
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.w500,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),



                                                ],
                                              ),

                                              // 🔽 Spacer so that the overlapping image is not clipped
                                              const SizedBox(height: 20),

                                              SizedBox(height: 25),
                                            ],
                                          ),

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
                                              Image.asset("assets/images/bed.png", height: 14),
                                              SizedBox(width: 5),
                                              Text(item.bedrooms.toString()),
                                              SizedBox(width: 10),
                                              Image.asset("assets/images/bath.png", height: 14),
                                              SizedBox(width: 5),
                                              Text(item.bathrooms.toString()),
                                              SizedBox(width: 10),
                                              Image.asset("assets/images/messure.png", height: 14),
                                              SizedBox(width: 5),
                                              Text(item.squareFeet.toString()),
                                            ],
                                          ),
                                          /* SizedBox(height: 15),
                                                            Row(
                                                              children: [
                                                                Image.asset("assets/images/Flooring.png", height: 20),
                                                                SizedBox(width: 5),
                                                                Text(item.bedrooms.toString()),
                                                                SizedBox(width: 10),
                                                                Image.asset("assets/images/
                                                                Central_Heating.png", height: 20),
                                                                SizedBox(width: 5),
                                                                Text(item.bathrooms.toString()),
                                                                SizedBox(width: 10),
                                                                Image.asset("assets/images/Barbeque_Area.png", height: 20),
                                                                SizedBox(width: 5),
                                                                Text(item.squareFeet.toString()),
                                                              ],
                                                            ),*/
                                          SizedBox(height: 15,),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    // Use the correct sanitizer for call (international format with +)
                                                    String phone = 'tel:${phoneCallNumber(item.phoneNumber ?? '')}';
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
                                                    final phone = whatsAppNumber(item.whatsapp ?? '');
                                                    final message = Uri.encodeComponent("Hello"); // you can change message
                                                    final url = Uri.parse("https://wa.me/$phone?text=$message");
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

                                        ]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        //),
                        //  ),
                      ]
                  ),
                ),
              )

              //  ),
              // ),

          ),],
          ),
          //),
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Profile_Login()));
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
}
