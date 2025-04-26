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

  final  FilterModel filterModel;


  FliterList({super.key, required this.filterModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FliterListDemo(filterModel: filterModel,),
    );
  }
}
  class FliterListDemo extends StatefulWidget {
  final FilterModel filterModel;

  const FliterListDemo({super.key,required this.filterModel});

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
      super.initState();

      _rangeController = RangeController(
        start: start.toString(),
        end: end.toString(),
      );

      _loadFavorites();         // Load local favorites
      readData();               // Fetch token/user info
      filterModel = widget.filterModel;

      selectedproduct = 0;
      purpose = "Rent";         // Default filter
      propertyApi(purpose);     // Fetch property list

      selectedtype = 0;

      chartData = List.generate(
        96,
            (index) => Data(
          500 + index * 100.0,
          yValues[index % yValues.length].toDouble(),
        ),
      );
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
    String max_price = ' ';
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


    Future<void> propertyApi(String purpose) async {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'property_types_$purpose';
      final cacheTimeKey = 'property_types_time_$purpose';
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

          debugPrint("✅ Loaded property types from cache for '$purpose'");
          return;
        }
      }

      // Else: fetch from API
      try {
        final response = await http
            .get(Uri.parse("https://akarat.com/api/property-types/$purpose"))
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

          debugPrint("✅ Cached property types for '$purpose'");
        } else {
          debugPrint("❌ Property API failed [${response.statusCode}]: ${response.reasonPhrase}");
        }
      } catch (e) {
        debugPrint("❌ Property API error: $e");
      }
    }


    Future<void> showResult() async {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'filters_result_${property_type}_$ftype$bedroom$min_price$max_price$rent$bathroom$purpose';
      final cacheTimeKey = '${cacheKey}_time';
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

      // Cache valid for 2 hours
      if (now - lastFetched < Duration(hours: 2).inMilliseconds) {
        final cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          final jsonData = jsonDecode(cachedData);
          final cachedModel = FilterModel.fromJson(jsonData);

          setState(() {
            filterModel = cachedModel;
            Navigator.push(context, MaterialPageRoute(builder: (context) => FliterList(filterModel: filterModel)));
          });

          debugPrint("✅ Loaded filter results from cache");
          return;
        }
      }

      // If no cache or cache expired
      try {
        final response = await http.get(Uri.parse('https://akarat.com/api/filters?'
            'search=&amenities=&property_type=$property_type'
            '&furnished_status=$ftype&bedrooms=$bedroom&min_price=$min_price'
            '&max_price=$max_price&payment_period=$rent&min_square_feet='
            '&max_square_feet=&bathrooms=$bathroom&purpose=$purpose'));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final feature = FilterModel.fromJson(data);

          setState(() {
            filterModel = feature;
            Navigator.push(context, MaterialPageRoute(builder: (context) => FliterList(filterModel: filterModel)));
          });

          // Save cache
          await prefs.setString(cacheKey, response.body);
          await prefs.setInt(cacheTimeKey, now);

          debugPrint("✅ Fetched and cached filter result");
        } else {
          debugPrint("❌ Filter API failed: ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("🚨 Filter API exception: $e");
      }
    }


    int? selectedtype;
    String property_type= ' ';
    String selectedaction = " ";
    String bathroom = ' ';
    String purpose = ' ';
    int? selectedproduct ;
    int? selectedrent ;
    String product='';
    String rent='';


  final TextEditingController _searchController = TextEditingController();

    Future<void> toggledApi( token,  propertyId) async {
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
          final Map<String, dynamic> jsonData = json.decode(response.body);
          setState(() {
            toggleModel = ToggleModel.fromJson(jsonData);
          });
          debugPrint("✅ Property toggle success for ID: $propertyId");
        } else {
          debugPrint("❌ Toggle failed: Status ${response.statusCode}");
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


  @override
  Widget build(BuildContext context) {
    if (filterModel == null) {
      return Scaffold(
          body: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerCard(),) // Show loading state
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
                                // Navigator.of(context).pop();
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Filter(data: "Rent")));
                              },
                              child: Image.asset(
                                "assets/images/ar-left.png",
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          // Like Button
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            height: 35,
                            width: 35,
                            padding: const EdgeInsets.all(7),
                            decoration: _iconBoxDecoration(),
                            child: Image.asset(
                              "assets/images/lov.png",
                              width: 15,
                              height: 15,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              //Searchbar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
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
                                                onTap: () {
                                                  setModalState(() {
                                                    selectedproduct = index;
                                                    purpose = _product[index];
                                                    propertyApi(purpose);
                                                  });
                                                  setState(() {});
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
                                                onTap: () {
                                                  setModalState(() {
                                                    selectedrent = index;
                                                    rent = label;
                                                  });
                                                  setState(() {});
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
                                       // const Spacer(),
                                        SizedBox(height: 10,),
                                        // Submit Button
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: showResult,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text(
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 2, offset: const Offset(0.5, 0.5)),
                            ],
                            color: Colors.white,
                          ),
                          child: const Text("Rent", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                                onTap: () {
                                                  setModalState(() {
                                                    selectedtype = index;
                                                    property_type = item.name.toString();
                                                  });
                                                  setState(() {});
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
                                            onPressed: showResult,
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 3,
                                offset: const Offset(0.5, 0.5),
                              ),
                            ],
                          ),
                          child: const Text(
                            "All Residential",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                                            activeColor: Colors.black,
                                            inactiveColor: const Color(0x80F1EEEE),
                                            enableTooltip: true,
                                            shouldAlwaysShowTooltip: true,
                                            initialValues: _values,
                                            tooltipTextFormatterCallback: (actualValue, _) =>
                                            'AED ${actualValue.toInt()}',
                                            onChanged: (value) {
                                              setModalState(() {
                                                _values = SfRangeValues(value.start, value.end);
                                                min_price = value.start.toStringAsFixed(0);
                                                max_price = value.end.toStringAsFixed(0);
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
                                            onPressed: () {
                                              // showResult();
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 2,
                                offset: const Offset(0.5, 0.5),
                              ),
                            ],
                          ),
                          child: const Text("Price Range", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      //bedroom
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
                                              // child:  Text(_values.start.toStringAsFixed(2),
                                              child:  Text("Bedrooms",
                                                style: TextStyle(
                                                  color: Colors.black,fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,),
                                                textAlign: TextAlign.left,),
                                            ),
                                          ],
                                        ),
                                        //studio
                                        Padding(
                                            padding: const EdgeInsets.only(top: 5,left: 15,right: 10),
                                            child: Container(
                                              //color: Colors.grey,
                                              // width: 60,
                                              height: 60,
                                              child:  ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                physics: const ScrollPhysics(),
                                                itemCount: _bedroom.length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  // Colors.grey;
                                                  return GestureDetector(
                                                    onTap: (){
                                                      setModalState(() {
                                                        selectedbedroom = index;
                                                        bedroom = _bedroom[index];
                                                      });
                                                      setState(() {
                                                      });
                                                    },
                                                    child: Container(
                                                      // color: selectedIndex == index ? Colors.amber : Colors.transparent,
                                                      margin: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                                                      // width: screenSize.width * 0.25,
                                                      // height: 20,
                                                      padding: const EdgeInsets.only(top: 0,left: 15,right: 15),
                                                      decoration: BoxDecoration(
                                                        color: selectedbedroom == index ? Colors.blueAccent : Colors.white,
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
                                                      child:   Center(
                                                        child: Text(_bedroom[index],
                                                          style: TextStyle(
                                                              color: selectedbedroom == index ? Colors.white : Colors.black,
                                                              letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                                              fontSize: 18),textAlign: TextAlign.center,),
                                                      ),


                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            showResult();
                                            // Navigator.push(context, MaterialPageRoute(builder: (context)=> FliterListDemo()));
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
                            Text("Bedroom",style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),textAlign: TextAlign.center,),

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
                                                    color: Colors.black,fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
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
                                                    onTap: (){
                                                      setModalState(() {
                                                        selectedbathroom = index;
                                                        bathroom = _bathroom[index];
                                                      });
                                                      setState(() {
                                                      });
                                                    },

                                                    child: Container(
                                                      // color: selectedIndex == index ? Colors.amber : Colors.transparent,
                                                      margin: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
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
                                                            letterSpacing: 0.5,fontSize: 18,
                                                            fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                                                      ),


                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            showResult();
                                            // Navigator.push(context, MaterialPageRoute(builder: (context)=> FliterListDemo()));
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
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter(data: "Rent",)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3,bottom: 3,right: 10),
                          child:  Container(
                            width: 90,
                            height: 10,
                            padding: const EdgeInsets.only(left: 8),
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
                            child: Row(
                              children: [
                                Text(" All Filters",style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),),
                                Container(
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration.zero,
                              pageBuilder: (_, __, ___) => Search(data: purpose,),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3,bottom: 3,right: 10,left: 0),
                          child:  Container(
                            width: 70,
                            height: 10,
                            padding: const EdgeInsets.only(left: 8),
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
                            child: Row(
                              children: [
                                Text(" Reset",style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),textAlign: TextAlign.center,),
                                Container(
                                  width: 15,
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
             ListView.builder(
               padding: const EdgeInsets.all(0),
               scrollDirection: Axis.vertical,
                   physics: const ScrollPhysics(),
                   itemCount: filterModel.data?.length ?? 0,
                    shrinkWrap: true,
                   itemBuilder: (context, index) {
                     bool isFavorited = favoriteProperties.contains(filterModel.data![index].id);
                 return Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Card(
                     elevation: 20,
                     shadowColor: Colors.white,
                     color: Colors.white,
                       child: GestureDetector(
                       onTap: () async{
                     String id = filterModel.data![index].id.toString();
                     Navigator.push(context, MaterialPageRoute(builder: (context) =>
                         Product_Detail(data: id)));
                     //Navigator.push(context, MaterialPageRoute(builder: (context) => Blog_Detail(data:blogModel!.data![index].id.toString())));
                      },
                     child: Padding(
                       padding: const EdgeInsets.only(left: 5.0,top: 1,right: 5),
                       child: Column(
                         // spacing: 5,// this is the coloumn
                         children: [
                           ClipRRect(
                               borderRadius: BorderRadius.circular(12),
                               child: Stack(
                                   children: [
                                     AspectRatio(
                                       aspectRatio: 1.5,
                                       // this is the ratio
                                       child: CachedNetworkImage( // this is to fetch the image
                                         imageUrl: (filterModel.data![index].media![index].originalUrl.toString()),
                                         fit: BoxFit.cover,
                                         height: 100,
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
                                               property_id=filterModel.data![index].id;
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
                           ),

                           Padding(
                             padding: const EdgeInsets.only(top: 5),
                             child: ListTile(
                                title: Text(filterModel.data![index].title.toString(),
                                  style: TextStyle(
                            fontSize: 16,height: 1.4
                        ),),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('${filterModel.data![index].price} AED',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,fontSize: 22,height: 1.4
                          ),),
                        ),
                             ),
                           ),
                           Row(
                             children: [
                               Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 0),
                                 child:  Image.asset("assets/images/map.png",height: 14,),
                               ),
                               Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                  child: Text(filterModel.data![index].location.toString(),
                                    style: TextStyle(
                                        fontSize: 13,height: 1.4,
                                        overflow: TextOverflow.visible
                          ),),
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
                                 Image.asset("assets/images/messure.png", height: 13),
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
                                     String phone = 'tel:${filterModel.data![index].phoneNumber}';
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
                                     final phone = filterModel.data![index].whatsapp;
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
                    // return ProductCard(product: products[index]);
                   },
                 ),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
              onTap: ()async{
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
              },
              child: Image.asset("assets/images/home.png",height: 25,)),
          /*IconButton(
            enableFeedback: false,
            onPressed: () {
             // setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
             // });
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
          ),*/
          IconButton(
            enableFeedback: false,
            onPressed: () {
             // setState(() {
                pageIndex = 1;
            //  });
            },
            icon: pageIndex == 1
                ? const Icon(
              Icons.search,
              color: Colors.red,
              size: 35,
            )
                : const Icon(
              Icons.search_outlined,
              color: Colors.red,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
            //  setState(() {
             //   Navigator.push(context, MaterialPageRoute(builder: (context)=> Blog()));
             // });
            },
            icon: pageIndex == 2
                ? const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 30,
            )
                : const Icon(
              Icons.favorite_border_outlined,
              color: Colors.red,
              size: 30,
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