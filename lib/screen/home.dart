import 'dart:convert';

import 'package:Akarat/model/searchmodel.dart';
import 'package:Akarat/model/togglemodel.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/search.dart';
import 'package:Akarat/screen/searchexample.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:Akarat/utils/fav_logout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/featuredmodel.dart';
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

import 'package:http/io_client.dart';

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
  int pageIndex = 0;
  String token = '';
  String email = '';
  String result = '';

  bool isFavorited = false;
  final TextEditingController _searchController = TextEditingController();
  String location ='';
  FeaturedModel? featuredModel;
  SearchModel? searchModel;
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
    loadCachedFeatured(); // ⬅️ Load fast from local storage
    fetchFeaturedApi();   // ⬅️ Then fetch fresh data in background
    readData();
    _loadFavorites();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
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

  Future<void> loadCachedFeatured() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_featured');

    if (cachedData != null) {
      final cachedJson = jsonDecode(cachedData);
      final cachedModel = FeaturedModel.fromJson(cachedJson);
      setState(() {
        featuredModel = cachedModel;
      });
    }
  }

  Future<void> fetchFeaturedApi() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = Uri.parse("https://akarat.com/api/featured-properties?page=1");
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = await compute(jsonDecode, response.body);
        final updatedModel = FeaturedModel.fromJson(decoded);

        // Save to cache
        prefs.setString('cached_featured', response.body);

        if (mounted) {
          setState(() {
            featuredModel = updatedModel;
          });
        }
      } else {
        debugPrint("API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("API failed: $e");
    }
  }

/*  Future<void> searchApi(String location) async {
    try {
      final response = await http
          .get(Uri.parse("https://akarat.com/api/search-properties?location=$location"))
          .timeout(const Duration(seconds: 10)); // Timeout to prevent hanging

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = SearchModel.fromJson(data);

        if (mounted) {
          setState(() {
            searchModel = result;
          });
        }
      } else {
        print("Search API failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Search API error: $e");
    }
  }*/


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
    Size screenSize = MediaQuery.sizeOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 2 : 3;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
          //body: pages[pageIndex],
          backgroundColor: Colors.white,
          body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  padding: const EdgeInsets.only(top: 0, left: 20, right: 15,bottom: 10),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> LocationSearchScreen()));

                    },
                    child: Container(
                      width: 400,
                      height: 70,
                      padding: const EdgeInsets.only(top: 0,left: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.3,
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 0.5,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.search, color: Colors.red),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text("Search for a locality, area or city",
                                  style: TextStyle(color: Colors.grey,fontSize: 14),),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                //images gridview
                Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 0),
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
                                                  color: Colors.grey.withOpacity(0.4),
                                                  offset: Offset(7, 7),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                                BoxShadow(
                                                  color: Colors.white.withOpacity(0.3),
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
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 15.0, top: 0, bottom: 0),
                                      child:  Text("1,738 Projects",style: TextStyle(
                                        color: Colors.black,fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),textAlign: TextAlign.left,),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0.0, right: 10.0, top: 0, bottom: 0),
                                            child:  Image.asset("assets/images/filter.png",height: 20,)
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 2.0, right: 10.0, top: 0, bottom: 0),
                                          // child:  Text(result,style: TextStyle(
                                          child:  Text("Featured",style: TextStyle(
                                            color: Colors.black,fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),textAlign: TextAlign.right,),
                                        ),
                                      ],
                                    )

                                  ],
                                ),
                              ),
                              //Slider
                              featuredModel == null
                                  ? Center(child: const ShimmerCard())
                                  : ListView.builder(
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.vertical,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: featuredModel?.data?.length ?? 0,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final item = featuredModel!.data![index];
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
                                                        height: screenSize.height*0.04,
                                                        padding: const EdgeInsets.symmetric(),
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
                                                  Image.asset("assets/images/Central_Heating.png", height: 20),
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
                ),
              ],
            ),
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
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter(data: "Rent")));

              });
            },
            icon: pageIndex == 1
                ? const Icon(
              Icons.search,
              color: Colors.red,
              size: 30,
            )
                : const Icon(
              Icons.search_outlined,
              color: Colors.red,
              size: 30,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                if(token == ''){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Fav_Logout()));
                }
                else if(token.isNotEmpty){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Fav_Login()));
                }
               // Navigator.push(context, MaterialPageRoute(builder: (context)=> FavoriteButton()));

              });
            },
            icon: pageIndex == 2
                ? const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 28,
            )
                : const Icon(
              Icons.favorite_border_outlined,
              color: Colors.red,
              size: 28,
            ),
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
              size: 28,
            )
                : const Icon(
              Icons.dehaze_outlined,
              color: Colors.red,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
