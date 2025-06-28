import 'dart:convert';

import 'package:Akarat/screen/product_detail.dart';
import 'package:Akarat/screen/search.dart';
import 'package:Akarat/screen/searchexample.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/filtermodel.dart';
import 'package:Akarat/screen/blog.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/propertytypemodel.dart';
import '../model/searchmodel.dart';
import '../model/togglemodel.dart';
import '../utils/shared_preference_manager.dart';
import 'filter.dart';
import 'login.dart';
import 'my_account.dart';


class FliterList extends StatelessWidget {
  final FilterModel? filterModel;  // ❌ was required, ✅ now optional
  final String? location;
  final bool forceRefresh;

  FliterList({super.key, this.filterModel, this.location, this.forceRefresh = false});

  @override
  Widget build(BuildContext context) {
    return FliterListDemo(filterModel: filterModel, location: location);
  }
}

class FliterListDemo extends StatefulWidget {
  final FilterModel? filterModel;   // ✅ updated as nullable
  final String? location;

  const FliterListDemo({super.key, this.filterModel, this.location});


  @override
  _FliterListDemoState createState() => _FliterListDemoState();
}
class _FliterListDemoState extends State<FliterListDemo> {
  late  FilterModel filterModel;
  int pageIndex = 0;
  int? property_id ;
  String token = '';
  String email = '';
  String result = '';
  ToggleModel? toggleModel;
  bool isDataRead = false;
  bool isFavorited = false;



  bool isPurposeLoading = false;
  String selectedPurposeText = "Rent";
  bool _isLoading = true;   // ✅ add this


  ScrollController _scrollController = ScrollController();

  List<String> locationList = [];
  String? selectedLocation;


// WhatsApp sanitizer: always outputs 971XXXXXXXXX (no plus)
  String whatsAppNumber(String input) {
    // Remove all non-digit characters
    input = input.replaceAll(RegExp(r'[^\d]'), '');

    // Remove leading zeros
    if (input.startsWith('0')) {
      input = input.substring(1);
    }

    // Remove duplicated country code if already present
    if (input.startsWith('971971')) {
      input = input.replaceFirst('971971', '971');
    }

    // Ensure starts with UAE code
    if (input.startsWith('971')) {
      return input;
    }

    // Add UAE prefix if missing
    return '971$input';
  }


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

  void _resetAllFilters() {
    selectedproduct = 0;
    selectedrent = null;
    selectedtype = null;
    selectedbedroom = null;
    selectedbathroom = null;
    _values = SfRangeValues(3000, 5000);
    min_price = '';
    max_price = '';
    ftype = ' ';
    bedroom = ' ';
    bathroom = ' ';
    property_type = ' ';
    purpose = 'Rent';
  }


  String buildApiUrl() {
    Map<String, String> params = {
      if ((selectedLocation ?? '').isNotEmpty) 'location': selectedLocation!,
      if (purpose.isNotEmpty) 'purpose': purpose,
      if (property_type.trim().isNotEmpty) 'property_type': property_type.trim(),
      if (ftype.trim().isNotEmpty && ftype != 'All') 'furnished_status': ftype.trim(),
      if (bedroom.trim().isNotEmpty) 'bedrooms': bedroom.trim(),
      if (bathroom.trim().isNotEmpty) 'bathrooms': bathroom.trim(),
      if (min_price.isNotEmpty) 'min_price': min_price,
      if (max_price.isNotEmpty) 'max_price': max_price,
      if (rent.isNotEmpty) 'payment_period': rent,
    };

    final queryString = params.entries.map((e) => "${e.key}=${Uri.encodeComponent(e.value)}").join('&');
    return 'https://akarat.com/api/filters?$queryString';
  }


  @override
  void initState() {
    super.initState();

    _rangeController = RangeController(start: start.toString(), end: end.toString());
    _loadFavorites();
    readData();
    filterModel = widget.filterModel ?? FilterModel();

    selectedproduct = 0;
    purpose = "Rent";
    selectedtype = 0;
    selectedLocation = widget.location?.toString();


    fetchLocations();
    chartData = List.generate(
      96,
          (index) => Data(500 + index * 100.0, yValues[index % yValues.length].toDouble()),
    );

    Future.delayed(Duration.zero, () async {
      // 1️⃣ Load filter results first (faster search result shown to user)
      await showResult();  // ⚠️ Don't use forceRefresh on initial load

      // 2️⃣ After result, load property types (for filters UI)
      await propertyApi(purpose, location: selectedLocation);

      if (propertyTypeModel != null && propertyTypeModel!.data!.isNotEmpty) {
        property_type = propertyTypeModel!.data!.first.name ?? '';
      }
    });

  }




  late bool isSelected = true;
  double start = 3000;
  double end = 5000;
  SfRangeValues _values = SfRangeValues(3000 ,5000);
  late RangeController _rangeController;

  @override
  void dispose() {
    _rangeController.dispose();
    super.dispose();
  }
  final List<int> yValues = [5000, 3000, 9000,7000,10000,1500,4000,];
  late List<Data> chartData;
  String min_price = '';
  String max_price = '';
  SearchModel? searchModel;



  /*  Future<void> searchApi(String location) async {
        try {
          final cacheKey = 'search_cache_$location';
          final prefs = await SharedPreferences.getInstance();

          // Optional: Use cache if available
          final cachedData = prefs.getString(cacheKey);
          if (cachedData != null) {
            final jsonData = jsonDecode(cachedData);
            setState(() {
              searchModel = SearchModel.fromJson(jsonData);
            });
            debugPrint("✅ Loaded from cache for $location");
            return;
          }

          // Fetch from API if not cached
          final response = await http.get(
            Uri.parse("https://akarat.com/api/search-properties?location=$location"),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final feature = SearchModel.fromJson(data);

            setState(() {
              searchModel = feature;
            });

            // Save response to cache
            await prefs.setString(cacheKey, response.body);
            debugPrint("✅ API response cached for $location");
          } else {
            debugPrint("❌ API Error: ${response.statusCode}");
          }
        } catch (e) {
          debugPrint("🚨 Exception in searchApi: $e");
        }
      }*/




  PropertyTypeModel? propertyTypeModel;
  int? selectedIndex;
  String ftype = ' ';
  final List _ftype = [
    'All', 'Furnished','Semi furnished', 'Unfurnished'
  ];
  final List _bedroom = [
    'studio', '1', '2', '3','4','5','6','7','8','9+'
  ];
  int? selectedbedroom;
  String bedroom = ' ';
  final List _bathroom = [
    '1', '2', '3','4','5','6+'
  ];
  int? selectedbathroom;
  final List _product = [
    'Rent',
    'Buy',
    'New Projects',
    'Commercial'
  ];
  final List _rent = [
    'Yearly',
    'Monthly',
    'Daily',
  ];


  Future<void> propertyApi(String purpose, {String? location}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'property_types_${purpose}_${location ?? ''}';
    final cacheTimeKey = 'property_types_time_${purpose}_${location ?? ''}';
    final now = DateTime.now().millisecondsSinceEpoch;
    final cachedTime = prefs.getInt(cacheTimeKey) ?? 0;

    // Use cache if it's less than 6 hours old
    if (now - cachedTime < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final cachedModel = PropertyTypeModel.fromJson(jsonData);

        if (mounted) {
          setState(() {
            propertyTypeModel = cachedModel;
          });
        }

        debugPrint("✅ Loaded property types from cache for '$purpose' ${location != null ? 'with location $location' : ''}");
        return;
      }
    }

    // Build correct API URL based on whether location is provided
    String url;
    if (location != null) {
      url = "https://akarat.com/api/property-types/$purpose?location=${Uri.encodeQueryComponent(location)}";
    } else {
      url = "https://akarat.com/api/property-types/$purpose";
    }

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetchedTypes = PropertyTypeModel.fromJson(data);

        if (mounted) {
          setState(() {
            propertyTypeModel = fetchedTypes;
          });
        }

        // Cache the response
        await prefs.setString(cacheKey, response.body);
        await prefs.setInt(cacheTimeKey, now);

        debugPrint("✅ Cached property types for '$purpose' ${location != null ? 'with location $location' : ''}");
      } else {
        debugPrint("❌ Property API failed [${response.statusCode}]: ${response.reasonPhrase}");
      }
    } catch (e) {
      debugPrint("❌ Property API error: $e");
    }
  }



  Future<void> showResult({bool forceRefresh = false}) async {
    setState(() { _isLoading = true; });   // Start loading

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'filters_result_${property_type}_$ftype$bedroom$min_price$max_price$rent$bathroom$purpose';
    final cacheTimeKey = '${cacheKey}_time';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    String paymentPeriodParam = '';
    if (purpose == 'Rent') {
      paymentPeriodParam = rent;
    } else {
      paymentPeriodParam = '';
    }

    if (purpose == 'Rent' && (property_type.trim().isEmpty || property_type == ' ')) {
      if (propertyTypeModel != null && propertyTypeModel!.data != null && propertyTypeModel!.data!.isNotEmpty) {
        property_type = propertyTypeModel!.data![0].name.toString();
        debugPrint("ℹ️ Auto-selected property_type for Rent: $property_type");
      } else {
        debugPrint("❌ Cannot proceed — no property_type selected for Rent");
        setState(() { _isLoading = false; });  // ✅ Stop loading if failure
        return;
      }
    }

    // if (!forceRefresh && now - lastFetched < Duration(hours: 2).inMilliseconds) {
    //   final cachedData = prefs.getString(cacheKey);
    //   if (cachedData != null) {
    //     final cachedJson = jsonDecode(cachedData);
    //     final cachedResponse = FilterResponseModel.fromJson(cachedJson);
    //     final cachedFeature = cachedResponse.data;
    //
    //     setState(() {
    //       filterModel = cachedFeature!;
    //       _isLoading = false;  // ✅ Stop loading after loading cache
    //     });
    //
    //     _scrollController.animateTo(0, duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    //     debugPrint("✅ Loaded filter results from cache (${filterModel.data?.length ?? 0} items)");
    //     return;
    //   }
    // }

    try {
      final apiUrl = buildApiUrl();
      final response = await http.get(Uri.parse(apiUrl));


      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final featureResponse = FilterResponseModel.fromJson(responseData);
        final feature = featureResponse.data;

        if (selectedLocation != null && feature != null) {

        }

        setState(() {
          filterModel = feature!;
          _isLoading = false;   // ✅ Stop loading after success
        });

        _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        debugPrint("✅ Fetched and updated filter result (${filterModel.data?.length ?? 0} items)");

        await prefs.setString(cacheKey, response.body);
        await prefs.setInt(cacheTimeKey, now);
      } else {
        debugPrint("❌ Filter API failed: ${response.statusCode}");
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      debugPrint("🚨 Filter API exception: $e");
      setState(() { _isLoading = false; });
    }
  }



  Future<void> fetchLocations() async {
    try {
      final response = await http.get(Uri.parse("https://akarat.com/api/locations?q="));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        setState(() {
          locationList = List<String>.from(jsonData);
        });

        debugPrint("✅ Locations loaded: ${locationList.length}");
      } else {
        debugPrint("❌ Locations API failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Locations API exception: $e");
    }
  }






  int? selectedtype;
  String property_type= ' ';
  String selectedaction = " ";
  String bathroom = ' ';
  String purpose = '';
  int? selectedproduct ;
  int? selectedrent ;
  String product='';
  String rent='';


  final TextEditingController _searchController = TextEditingController();

  Future<bool> toggledApi(String token, int propertyId) async {
    final url = Uri.parse('https://akarat.com/api/toggle-saved-property');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"property_id": propertyId}),
      );

      if (response.statusCode == 200) {
        print("✅ Favorite toggled successfully");
        return true;
      } else {
        print("❌ Failed to toggle favorite: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("🚨 Error in toggledApi: $e");
      return false;
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

    if (_isLoading) {
      return Scaffold(
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerCard(),
        ),
      );
    }

    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10,),
              Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button
                          Container(
                            margin: const EdgeInsets.only(left: 20),
                            height: 35,
                            width: 35,
                            padding: const EdgeInsets.all(7),
                            decoration: _iconBoxDecoration(),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Filter(data: "Rent"),
                                  ),
                                );
                              },

                              child: Image.asset(
                                "assets/images/ar-left.png",
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )



                          // Like Button (optional)
                          // Container(
                          //   margin: const EdgeInsets.only(right: 10),
                          //   height: 35,
                          //   width: 35,
                          //   padding: const EdgeInsets.all(7),
                          //   decoration: _iconBoxDecoration(),
                          //   child: Image.asset(
                          //     "assets/images/lov.png",
                          //     width: 15,
                          //     height: 15,
                          //     fit: BoxFit.contain,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              //Searchbar
              // Responsive universal search bar
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //   child: Container(
              //     width: double.infinity,
              //     height: 55,
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(30),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.grey.withOpacity(0.2),
              //           blurRadius: 6,
              //           offset: Offset(0, 3),
              //         ),
              //       ],
              //     ),
              //     child: Row(
              //       children: [
              //         Expanded(
              //           child: Container(
              //             margin: const EdgeInsets.symmetric(horizontal: 8),
              //             decoration: BoxDecoration(
              //               border: Border.all(color: Colors.red.shade200),
              //               borderRadius: BorderRadius.circular(30),
              //             ),
              //             padding: const EdgeInsets.symmetric(horizontal: 12),
              //             height: 45,
              //             child: Row(
              //               children: [
              //                 Icon(Icons.search, color: Colors.red),
              //                 const SizedBox(width: 10),
              //                 Expanded(
              //                   child: TextField(
              //                     controller: _searchController,
              //                     decoration: InputDecoration(
              //                       hintText: "Search for a locality, area or city",
              //                       hintStyle: TextStyle(
              //                         color: Colors.grey,
              //                         fontSize: 14,
              //                       ),
              //                       border: InputBorder.none,
              //                     ),
              //                   ),
              //                 ),
              //
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),


              //filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                child: Container(
                  // margin: const EdgeInsets.symmetric(vertical: 1),
                  height: 50,
                  // color: Colors.grey,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      //text
                      Padding(
                        padding: const EdgeInsets.only(
                            left:8.0,top: 0.0),

                        child: Center(
                          child: Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(left: 2,right: 8),
                                  child: Image.asset("assets/images/filter.png",height: 17,)
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left:1.0,right: 10),
                                child: InkWell(
                                    onTap: (){
                                      //   print('hello');
                                    },
                                    child: Text('Filters',
                                      style: TextStyle(fontSize: 18, color: Colors.black,
                                          fontWeight: FontWeight.bold),)),
                              )
                            ],
                          ),
                        ),

                      ),
                      //buy
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            isScrollControlled: true,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  return Container(
                                    height: screenSize.height * 0.4,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: const BoxDecoration(color: Colors.white),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        const Text("Purpose", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        const Text("Choose your purpose"),
                                        const SizedBox(height: 10),

                                        // Purpose list
                                        SizedBox(
                                          height: 50,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _product.length,
                                            itemBuilder: (context, index) {
                                              bool isSelected = selectedproduct == index;
                                              return GestureDetector(
                                                onTap: () async {
                                                  setModalState(() {
                                                    selectedproduct = index;
                                                    purpose = _product[index];
                                                    selectedPurposeText = _product[index];
                                                  });

                                                  await showResult(forceRefresh: true);
                                                  Navigator.pop(context);
                                                },


                                                child: Container(
                                                  margin: const EdgeInsets.only(right: 10),
                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? Colors.blueAccent : Colors.white,
                                                    borderRadius: BorderRadius.circular(6),
                                                    boxShadow: [
                                                      BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      _product[index],
                                                      style: TextStyle(
                                                        color: isSelected ? Colors.white : Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 15),

                                        // Availability list
                                        SizedBox(
                                          height: 50,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: propertyTypeModel?.availability?.length ?? 0,
                                            itemBuilder: (context, index) {
                                              bool isSelected = selectedrent == index;
                                              final label = propertyTypeModel!.availability![index].toString();
                                              return GestureDetector(
                                                onTap: () async {
                                                  setModalState(() {
                                                    selectedrent = index;
                                                    rent = label;
                                                  });

                                                  await showResult(forceRefresh: true);
                                                  Navigator.pop(context);
                                                },

                                                child: Container(
                                                  margin: const EdgeInsets.only(right: 10),
                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? Colors.blueAccent : Colors.white,
                                                    borderRadius: BorderRadius.circular(6),
                                                    boxShadow: [
                                                      BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      label,
                                                      style: TextStyle(
                                                        color: isSelected ? Colors.white : Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // Show Results button
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: isPurposeLoading
                                                ? null
                                                : () async {  // <-- add async here
                                              await showResult(forceRefresh: true);

                                              Navigator.pop(context);
                                            },


                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: isPurposeLoading
                                                ? const CircularProgressIndicator(color: Colors.white)
                                                : const Text(
                                              "Showing Results",
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3, bottom: 3, right: 10),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 40,
                              maxHeight: 40,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(0.3, 0.3),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                selectedPurposeText, // Show current selected text here
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),

                      //type
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  return Container(
                                    height: screenSize.height * 0.35,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                    decoration: const BoxDecoration(color: Colors.white),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Property Type",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                        ),
                                        const SizedBox(height: 15),

                                        // Property Type Cards
                                        SizedBox(
                                          height: screenSize.height * 0.12,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: propertyTypeModel?.data?.length ?? 0,
                                            itemBuilder: (context, index) {
                                              final item = propertyTypeModel!.data![index];
                                              final isSelected = selectedtype == index;

                                              return GestureDetector(
                                                onTap: () async {
                                                  setModalState(() {
                                                    selectedtype = index;
                                                    property_type = item.name.toString();
                                                  });

                                                  await showResult(forceRefresh: true);
                                                  Navigator.pop(context);
                                                },

                                                child: Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? const Color(0xFFEEEEEE) : Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.3),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      CachedNetworkImage(
                                                        imageUrl: item.icon.toString(),
                                                        height: 35,
                                                        placeholder: (context, url) => const CircularProgressIndicator(),
                                                        errorWidget: (context, url, error) => const Icon(Icons.error, size: 35),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        item.name.toString(),
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                          color: isSelected ? Colors.black : Colors.black87,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // Confirm Button
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showResult(forceRefresh: true);   // 🔥 added forceRefresh
                                              Navigator.pop(context);
                                            },


                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                            ),
                                            child: const Text(
                                              "Showing Results",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3, bottom: 3, right: 10),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 40, // SAME as Price Range
                              maxHeight: 40,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14), // SAME as Price Range
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(0.3, 0.3),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Text(
                                "All Residential",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14, // SAME as Price Range
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),

                      //Price Range
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  return Container(
                                    height: screenSize.height * 0.38,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    decoration: const BoxDecoration(color: Colors.white),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Price range",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 12),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _rangeDisplayBox(_values.start.toStringAsFixed(0)),
                                            const Text("to", style: TextStyle(fontSize: 15)),
                                            _rangeDisplayBox(_values.end.toStringAsFixed(0)),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        SfRangeSelectorTheme(
                                          data: SfRangeSelectorThemeData(
                                            tooltipBackgroundColor: Colors.black,
                                            tooltipTextStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          child: SfRangeSelector(
                                            min: 500,
                                            max: 10000,
                                            interval: 1000,
                                            activeColor: const Color(0xFF2575D4),
                                            inactiveColor: const Color(0x80F1EEEE),
                                            enableTooltip: true,
                                            shouldAlwaysShowTooltip: true,
                                            initialValues: _values,
                                            tooltipTextFormatterCallback: (actualValue, _) =>
                                            'AED ${actualValue.toInt()}',
                                            onChanged: (value) {
                                              setModalState(() {
                                                double roundedMin = ((value.start / 100).round() * 100).toDouble();
                                                double roundedMax = ((value.end / 100).round() * 100).toDouble();

                                                _values = SfRangeValues(roundedMin, roundedMax);

                                                min_price = roundedMin.toStringAsFixed(0);
                                                max_price = roundedMax.toStringAsFixed(0);
                                              });
                                            },




                                            child: SizedBox(
                                              height: 60,
                                              width: double.infinity,
                                              child: SfCartesianChart(
                                                backgroundColor: Colors.transparent,
                                                plotAreaBorderColor: Colors.transparent,
                                                margin: const EdgeInsets.all(0),
                                                primaryXAxis: NumericAxis(minimum: 500, maximum: 10000, isVisible: false),
                                                primaryYAxis: NumericAxis(isVisible: false),
                                                plotAreaBorderWidth: 0,
                                                plotAreaBackgroundColor: Colors.transparent,
                                                series: <ColumnSeries<Data, double>>[
                                                  ColumnSeries<Data, double>(
                                                    dataSource: chartData,
                                                    xValueMapper: (Data sales, _) => sales.x,
                                                    yValueMapper: (Data sales, _) => sales.y,
                                                    pointColorMapper: (_, __) => const Color.fromARGB(255, 37, 117, 212),
                                                    animationDuration: 0,
                                                    borderWidth: 0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        SizedBox(
                                          width: double.infinity,
                                          height: 45,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              await showResult(forceRefresh: true);

                                              Navigator.pop(context); // Close the bottom sheet after showing result
                                            },

                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                            ),
                                            child: const Text(
                                              "Showing Results",
                                              style: TextStyle(
                                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3, bottom: 3, right: 10),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 40,
                              maxHeight: 40,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(0.3, 0.3),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Text(
                                "Price Range",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),


                      //bedroom
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            isScrollControlled: true,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (BuildContext context, StateSetter setModalState) {
                                  return Container(
                                    height: screenSize.height * 0.3,
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 40.0, left: 20, bottom: 0),
                                              child: Text(
                                                "Bedrooms",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Bedroom list
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5, left: 15, right: 10),
                                          child: Container(
                                            height: 60,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              physics: const ScrollPhysics(),
                                              itemCount: _bedroom.length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    setModalState(() {
                                                      selectedbedroom = index;

                                                      if (_bedroom[index] == 'studio') {
                                                        bedroom = '0';
                                                      } else if (_bedroom[index] == '9+') {
                                                        bedroom = '9';
                                                      } else {
                                                        bedroom = _bedroom[index];
                                                      }

                                                      print('Selected bedroom for API: $bedroom');
                                                    });

                                                    await showResult(forceRefresh: true);
                                                    Navigator.pop(context);
                                                  },

                                                  child: Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                                    decoration: BoxDecoration(
                                                      color: selectedbedroom == index ? Colors.blueAccent : Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.5),
                                                          offset: Offset(0, 2),
                                                          blurRadius: 4,
                                                          spreadRadius: 0,
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
                                                    child: Center(
                                                      child: Text(
                                                        _bedroom[index],
                                                        style: TextStyle(
                                                          color: selectedbedroom == index ? Colors.white : Colors.black,
                                                          letterSpacing: 0.5,
                                                          fontSize: 18,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        // Show Results button
                                        GestureDetector(
                                          onTap: () async {
                                            await showResult(forceRefresh: true);

                                            Navigator.pop(context); // ✅ Close BottomSheet after API call
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 25.0, left: 15, bottom: 15, right: 15),
                                            child: Container(
                                              width: screenSize.width * 0.9,
                                              height: 45,
                                              padding: const EdgeInsets.only(top: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadiusDirectional.circular(6.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: const Offset(0.3, 0.3),
                                                    blurRadius: 0.3,
                                                    spreadRadius: 0.3,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    offset: const Offset(0.0, 0.0),
                                                    blurRadius: 0.0,
                                                    spreadRadius: 0.0,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                "Showing Results",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3, bottom: 3, right: 10),
                          child: Container(
                            width: 90,
                            height: 10,
                            padding: const EdgeInsets.only(left: 0, top: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(0.3, 0.3),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                            ),
                            child: Text(
                              " Bedroom", // add 1 space in front for same alignment as " Bathroom"
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                      ),

                      //bathroom
                      GestureDetector(
                        onTap: (){
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            isScrollControlled: true,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (BuildContext context, StateSetter setModalState) {
                                  return  Container(
                                    height: screenSize.height*0.3,
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(padding: const EdgeInsets.only(top: 40.0,left: 20,bottom: 0),
                                              // child:  Text(bedroom,
                                              child:  Text("Bathrooms",
                                                style: TextStyle(
                                                    color: Colors.black,fontSize: 16.0,fontWeight: FontWeight.bold,

                                                    letterSpacing: 0.5),
                                                textAlign: TextAlign.left,),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(top: 5,left: 17,right: 10),
                                            child: Container(
                                              //color: Colors.grey,
                                              // width: 60,
                                              alignment: Alignment.topLeft,
                                              height: 60,
                                              child:  ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                physics: const ScrollPhysics(),
                                                itemCount: _bathroom.length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  // Colors.grey;
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      setModalState(() {
                                                        selectedbathroom = index;
                                                        bathroom = _bathroom[index];
                                                      });

                                                      await showResult(forceRefresh: true);
                                                      Navigator.pop(context);
                                                    },


                                                    child: Container(


                                                      // color: selectedIndex == index ? Colors.amber : Colors.transparent,
                                                      margin: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                                                      width: 50,  // ✅ smaller fixed width (you can adjust)
                                                      height: 20,
                                                      // width: screenSize.width * 0.25,
                                                      // height: 20,
                                                      padding: const EdgeInsets.only(top: 0,left: 15,right: 15),
                                                      decoration: BoxDecoration(
                                                        color: selectedbathroom == index ? Colors.blueAccent : Colors.white,
                                                        // color: Colors.white,
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
                                                      child:   Center(
                                                        child: Text(_bathroom[index],
                                                          style: TextStyle(
                                                            color: selectedbathroom == index ? Colors.white : Colors.black,
                                                            letterSpacing: 0.5,fontSize: 15,
                                                          ),textAlign: TextAlign.center,),
                                                      ),


                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await showResult(forceRefresh: true);

                                            Navigator.pop(context); // ✅ Close BottomSheet after API call
                                          },
                                          child:  Padding(
                                            padding: const EdgeInsets.only(top: 25.0,left: 15,bottom: 15,right: 15),
                                            child:   Container(
                                              // color: Colors.red,
                                              width: screenSize.width*0.9,
                                              height: 45,
                                              // color: Colors.red,
                                              padding: const EdgeInsets.only(top: 10,left: 0),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadiusDirectional.circular(6.0),
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
                                              child: Text("Showing Results",style: TextStyle(

                                                  color: Colors.white,letterSpacing: 0.5,fontWeight: FontWeight.bold,fontSize: 15
                                              ),textAlign: TextAlign.center,),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                },
                              );
                            },
                          );
                        },
                        child: Padding (
                          padding: const EdgeInsets.only(top: 3,bottom: 3,right: 10),
                          child:  Container(
                            width: 90,
                            height: 10,
                            padding: const EdgeInsets.only(left: 0,top: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 1,
                              ),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
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
                            child:
                            Text(" Bathroom",style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),textAlign: TextAlign.center,),

                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Filter(data: "Rent")));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3, bottom: 3, right: 10),
                          child: Container(
                            width: 90,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), // gives natural height
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(0.3, 0.3),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center, // center the text
                              children: [
                                Text(
                                  "All Filters",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // safe readable size
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _resetAllFilters();
                            showResult(forceRefresh: true);
                          });
                        },

                        child: Padding(
                          padding: const EdgeInsets.only(top: 3, bottom: 3, right: 10, left: 0),
                          child: Container(
                            width: 70,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: const Offset(0.3, 0.3),
                                  blurRadius: 0.3,
                                  spreadRadius: 0.3,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 0.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Reset",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),


                    ],
                  ),
                ),

              ),
              //filter
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                  child: Container(
                    alignment: Alignment.topLeft,
                    height: 50,
                    child:  ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const ScrollPhysics(),
                      itemCount: _ftype.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // Colors.grey;
                        return Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
                          decoration: BoxDecoration(
                            color: selectedIndex == index ? Colors.blueAccent : Colors.white, // Change color if selected
                            // color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                spreadRadius: 0,
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
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index; // Update selected index
                                ftype = _ftype[index]; // Update selected value
                              });
                            },
                            child: Center(
                              child: Text(
                                _ftype[index],
                                style: TextStyle(
                                  color: selectedIndex == index ? Colors.white : Colors.black,
                                  letterSpacing: 0.5,fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
              ),
              _isLoading
                  ? ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: 5,
                shrinkWrap: true,
                itemBuilder: (context, index) => const ShimmerCard(),
              )
                  : (filterModel.data == null || filterModel.data!.isEmpty)
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: Text(
                    "Property Not Found",
                    style: TextStyle(
                        fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(0),
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                itemCount: filterModel.data?.length ?? 0,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  bool isFavorited =
                  favoriteProperties.contains(filterModel.data![index].id);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 20,
                      shadowColor: Colors.white,
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: () async {
                          String id = filterModel.data![index].id.toString();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Product_Detail(data: id)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0, top: 1, right: 5),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(children: [
                                  AspectRatio(
                                    aspectRatio: 1.5,
                                    child: CachedNetworkImage(
                                      imageUrl: filterModel.data![index].media!
                                          .isNotEmpty
                                          ? filterModel.data![index].media![0]
                                          .originalUrl
                                          .toString()
                                          : 'https://via.placeholder.com/300x200?text=No+Image',
                                      fit: BoxFit.cover,
                                      height: 100,
                                      placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                      const Icon(Icons.error, size: 100),
                                    ),
                                  ),
                                ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: ListTile(
                                  title: Text(
                                    filterModel.data![index].title.toString(),
                                    style: TextStyle(fontSize: 16, height: 1.4),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '${filterModel.data![index].price} AED',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          height: 1.4),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 5, top: 0),
                                    child:
                                    Image.asset("assets/images/map.png", height: 14),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0, right: 0, top: 0),
                                    child: Text(
                                      filterModel.data![index].location.toString(),
                                      style: TextStyle(
                                          fontSize: 13,
                                          height: 1.4,
                                          overflow: TextOverflow.visible),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    Image.asset("assets/images/bed.png", height: 13),
                                    SizedBox(width: 5),
                                    Text(filterModel.data![index].bedrooms.toString()),
                                    SizedBox(width: 10),
                                    Image.asset("assets/images/bath.png", height: 13),
                                    SizedBox(width: 5),
                                    Text(filterModel.data![index].bathrooms.toString()),
                                    SizedBox(width: 10),
                                    Image.asset("assets/images/messure.png",
                                        height: 13),
                                    SizedBox(width: 5),
                                    Text(filterModel.data![index].squareFeet.toString()),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        String phone =
                                            'tel:${filterModel.data![index].phoneNumber}';
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
                                      label: const Text("Call",
                                          style: TextStyle(color: Colors.black)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)),
                                        elevation: 2,
                                        padding:
                                        const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final property = filterModel.data![index];

                                        final rawNumber = property.whatsapp ?? property.phoneNumber ?? '';
                                        final phone = whatsAppNumber(rawNumber);

                                        if (phone.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("No WhatsApp number available")),
                                          );
                                          return;
                                        }

                                        final message = Uri.encodeComponent("Hello");
                                        final url = Uri.parse("https://wa.me/$phone?text=$message");

                                        if (await canLaunchUrl(url)) {
                                          try {
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          } catch (e) {
                                            print("❌ Exception: $e");
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Cannot open WhatsApp")),
                                          );
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



                                  const SizedBox(width: 10),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )

            ]),
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
}
BoxDecoration _iconBoxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.3),
        blurRadius: 2,
        spreadRadius: 0.1,
        offset: const Offset(0, 1),
      ),
      const BoxShadow(
        color: Colors.white,
        offset: Offset(0.0, 0.0),
        blurRadius: 0.0,
        spreadRadius: 0.0,
      ),
    ],
  );
}
Widget _rangeDisplayBox(String value) {
  return Container(
    width: 100,
    height: 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          offset: const Offset(0.5, 0.5),
          blurRadius: 2,
        ),
      ],
    ),
    child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  );
}
class SwitchExample extends StatefulWidget {
  const SwitchExample({super.key});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}
class _SwitchExampleState extends State<SwitchExample> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: light,
      activeColor: Colors.blue,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          light = value;
        });
      },
    );
  }
}

class Data {
  final double x, y;
  Data(this.x, this.y);
}


String whatsAppNumber(String number) {
  number = number.replaceAll(RegExp(r'\D'), '');
  if (number.startsWith('0')) {
    number = number.substring(1);
  }
  if (!number.startsWith('971')) {
    number = '971$number';
  }
  return number;
}

