

import 'dart:convert';

import 'package:Akarat/screen/filter.dart';
import 'package:Akarat/screen/product_detail.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/searchexample.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../model/filtermodel.dart';
import '../model/propertytypemodel.dart';
import '../model/searchmodel.dart';
import '../model/togglemodel.dart';
import '../utils/shared_preference_manager.dart';
import 'filter_list.dart';
import 'home.dart';
import 'login.dart';
import 'my_account.dart';

class Search extends StatefulWidget {
  const Search({super.key, required this.data});
  final String data;
  @override
  State<Search> createState() => _SearchState();
}
class _SearchState extends State<Search> {
  late bool isSelected = true;
  double start = 3000;
  double end = 5000;
  late SfRangeValues _values = SfRangeValues(1000.0, 5000.0);
  late RangeController _rangeController =
  RangeController(start: 1000.0, end: 5000.0);

  @override
  void initState() {
    super.initState();

    _rangeController = RangeController(start: start.toString(), end: end.toString());

    purpose = "Rent"; // ✅ Move this up

    _initializeData(); // Now it uses a valid purpose
    _loadFavorites();
    readData();

    selectedproduct = 0;
    selectedtype = 0;

    chartData = List.generate(
      96,
          (index) => Data(
        500 + index * 100.0,
        yValues[index % yValues.length].toDouble(),
      ),
    );
  }

  void _initializeData() async {
    // Fire both in parallel
    propertyApi(purpose);
    searchApi(widget.data);
  }
  @override
  void dispose() {
    _rangeController.dispose();
    super.dispose();
  }
  final List<int> yValues = [5000, 3000, 9000,7000,10000,1500,4000,];
  late List<Data> chartData;
 /* final List<Data> chartData = <Data>[
    Data(x: 500, y: 5000),
    Data(x: 600, y: 3000),
    Data(x: 700, y: 6000),
    Data(x: 800, y: 2000),
    Data(x: 900, y:8000),
    Data(x: 1000, y:1000),
    Data(x: 1100, y:3000),
    Data(x: 1200, y:5000),
    Data(x: 1300, y: 9000),
    Data(x: 1400, y: 4000),
    Data(x: 1500, y: 1500),
    Data(x: 1600, y: 6000),
    Data(x: 1700, y: 9000),
    Data(x: 1800, y: 2000),
    Data(x: 1900, y: 8000),
    Data(x: 2000, y: 1000),
    Data(x: 2100, y: 6000),
    Data(x: 2200, y: 3000),
    Data(x: 2300, y: 5000),
    Data(x: 2400, y: 1000),
    Data(x: 2500, y: 2500),
    Data(x: 2600, y: 5500),
    Data(x: 2700, y: 8000),
    Data(x: 2800, y: 2500),
    Data(x: 2900, y: 6000),
    Data(x: 3000, y: 1000),
    Data(x: 3100, y: 3000),
    Data(x: 3200, y: 5000),
    Data(x: 3300, y: 7000),
    Data(x: 3400, y: 6000),
    Data(x: 3500, y: 4000),
    Data(x: 3600, y: 2000),
    Data(x: 3700, y: 5000),
    Data(x: 3800, y: 7000),
    Data(x: 3900, y: 9000),
    Data(x: 4000, y: 1000),
    Data(x: 4100, y: 3000),
    Data(x: 4200, y: 5000),
    Data(x: 4300, y: 7000),
    Data(x: 4400, y: 4000),
    Data(x: 4500, y: 10000),
    Data(x: 4600, y: 8000),
    Data(x: 4700, y: 6000),
    Data(x: 4800, y: 4000),
    Data(x: 4900, y: 2000),
    Data(x: 5000, y: 5500),
    Data(x: 5100, y: 1000),
    Data(x: 5200, y: 3000),
    Data(x: 5300, y: 5000),
    Data(x: 5400, y: 7000),
    Data(x: 5500, y: 9000),
    Data(x: 5600, y: 3000),
    Data(x: 5700, y: 7500),
    Data(x: 5800, y: 3500),
    Data(x: 5900, y: 4560),
    Data(x: 6000, y: 7500),
    Data(x: 6100, y: 10000),
    Data(x: 6200, y: 6000),
    Data(x: 6300, y: 4000),
    Data(x: 6400, y: 2000),
    Data(x: 6500, y: 6000),
    Data(x: 6600, y: 3000),
    Data(x: 6700, y: 5000),
    Data(x: 6800, y: 7000),
    Data(x: 6900, y: 9000),
    Data(x: 7000, y: 8000),
    Data(x: 7100, y: 6000),
    Data(x: 7200, y: 4000),
    Data(x: 7300, y: 2000),
    Data(x: 7400, y: 6500),
    Data(x: 7500, y: 1000),
    Data(x: 7600, y: 3000),
    Data(x: 7700, y: 5000),
    Data(x: 7800, y: 7000),
    Data(x: 7900, y: 7500),
    Data(x: 8000, y: 5000),
    Data(x: 8100, y: 3000),
    Data(x: 8200, y: 1000),
    Data(x: 8300, y: 5000),
    Data(x: 8400, y: 7000),
    Data(x: 8500, y: 5000),
    Data(x: 8600, y: 6000),
    Data(x: 8700, y: 4000),
    Data(x: 8800, y: 2000),
    Data(x: 8900, y: 8000),
    Data(x: 9000, y: 7000),
    Data(x: 9100, y: 8800),
    Data(x: 9200, y: 10000),
    Data(x: 9300, y: 6600),
    Data(x: 9400, y: 6600),
    Data(x: 9500, y: 9999),
    Data(x: 9600, y: 5555),
    Data(x: 9700, y: 4444),
    Data(x: 9800, y: 6666),
    Data(x: 9900, y: 7777),
    Data(x: 10000, y: 3000),
  ];*/
  String min_price = '';
  String max_price = ' ';
  SearchModel? searchModel;
  ToggleModel? toggleModel;
  int? property_id ;
  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;

  Future<void> searchApi(String location) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'search_result_$location';
    final cacheTimeKey = 'search_result_time_$location';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // Use cache if it's less than 6 hours old
    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final cachedModel = SearchModel.fromJson(json.decode(cachedData));
        setState(() {
          searchModel = cachedModel;
        });
        debugPrint("✅ Loaded search data from cache");
        return;
      }
    }

    // Else fetch from API
    try {
      final response = await http.get(
        Uri.parse("https://akarat.com/api/search-properties?location=$location"),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = SearchModel.fromJson(jsonData);

        // Save to cache
        await prefs.setString(cacheKey, json.encode(jsonData));
        await prefs.setInt(cacheTimeKey, now);

        setState(() {
          searchModel = model;
        });

        debugPrint("✅ Search data fetched and cached");
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Exception in searchApi: $e");
    }
  }


  Future<void> toggledApi( token,  propertyId) async {
    final url = Uri.parse('https://akarat.com/api/toggle-saved-property');

    try {
      final response = await http.post(
        url,
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
        debugPrint("✅ Property toggled successfully.");
      } else {
        debugPrint("❌ Toggle failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error during toggle: $e");
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
    try {
      final response = await http
          .get(Uri.parse("https://akarat.com/api/property-types/$purpose"))
          .timeout(const Duration(seconds: 10)); // ⏱ Timeout prevents slow hang

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feature = PropertyTypeModel.fromJson(data);

        if (mounted) {
          setState(() {
            propertyTypeModel = feature;
          });
        }
      } else {
        print("Property API failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Property API error: $e");
    }
  }
  late FilterModel filterModel;
  Future<void> showResult() async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://akarat.com/api/filters?'
        'search=&amenities=&property_type=$property_type'
        '&furnished_status=$ftype&bedrooms=$bedroom&min_price=$min_price'
        '&max_price=$max_price&payment_period=$rent&min_square_feet='
        '&max_square_feet=&bathrooms=$bathroom&purpose=$purpose'));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      FilterModel feature= FilterModel.fromJson(data);

      setState(() {
        filterModel = feature ;
        Navigator.push(context, MaterialPageRoute(builder: (context)=> FliterList(filterModel: filterModel,)));

      });
    } else {
    }
  }
  int pageIndex = 0;
  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

  bool isFavorited = false;
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
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if (searchModel == null) {
      return Scaffold(
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerCard(),)
       // body: Center(child: const ShimmerCard()), // Show loading state
      );
    }
    return Scaffold(
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.red),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            backgroundColor: Color(0xFFFFFFFF),
            iconTheme: const IconThemeData(color: Colors.red),
            // elevation: 1,
          ),
        ),
            body: SingleChildScrollView(
                child: Column(
                    children: <Widget>[
                    /*  Stack(
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
                                    margin: const EdgeInsets.only(left: 10),
                                    height: 35,
                                    width: 35,
                                    padding: const EdgeInsets.all(7),
                                    decoration: _iconBoxDecoration(),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
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
                      ),*/
                      //Searchbar
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 20, right: 15),
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
                        padding: const EdgeInsets.only(top: 20,left: 10,right: 0),
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
                                    width: 100,
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
                                  padding: const EdgeInsets.only(top: 3,bottom: 3,right: 5,left: 0),
                                  child:  Container(
                                    width: 80,
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
                          padding: const EdgeInsets.only(top: 5,left: 15,right: 0,bottom: 15),
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
                                          letterSpacing: 0.5,fontSize: 16,
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
                        itemCount: searchModel?.data?.length ?? 0,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          bool isFavorited = favoriteProperties.contains(searchModel!.data![index].id);
                          return SingleChildScrollView(
                              child: GestureDetector(
                                onTap: (){
                                  String id = searchModel!.data![index].id.toString();
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                      Product_Detail(data: id)));
                                },
                                child : Padding(
                                  padding: const EdgeInsets.only(top: 0.0,left: 10,right: 10,bottom: 10),
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
                                                          child: CachedNetworkImage( // this is to fetch the image
                                                            imageUrl: (searchModel!.data![index].image.toString()),
                                                            fit: BoxFit.fill,
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
                                                                  property_id=searchModel!.data![index].id;
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
                                                child: Text(searchModel!.data![index].title.toString(),
                                                  style: TextStyle(
                                                      fontSize: 16,height: 1.4
                                                  ),),
                                              ),
                                              subtitle: Text('${searchModel!.data![index].price}',
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
                                                child:  Image.asset("assets/images/map.png",height: 15,),
                                              ),
                                              Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                                child: Text(searchModel!.data![index].location.toString(),style: TextStyle(
                                                    fontSize: 13,height: 1.4,
                                                    overflow: TextOverflow.visible
                                                ),maxLines: 2,),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Padding(padding: const EdgeInsets.only(left: 15,right: 5,top: 5),
                                                child: Image.asset("assets/images/bed.png",height: 15,),
                                              ),
                                              Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                                  child: Text(searchModel!.data![index].bedrooms.toString(),style: TextStyle(
                                                    fontWeight: FontWeight.bold
                                                  ),)
                                              ),
                                              Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 5),
                                                child: Image.asset("assets/images/bath.png",height: 15,),
                                              ),
                                              Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                                  child: Text(searchModel!.data![index].bathrooms.toString(),style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  ),)
                                              ),
                                              Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 5),
                                                child: Image.asset("assets/images/messure.png",height: 15,),
                                              ),
                                              Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                                  child: Text(searchModel!.data![index].squareFeet.toString(),style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  ),)
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const SizedBox(width: 10,),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    String phone = 'tel:${searchModel!.data![index].phone}';
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
                                                    final phone = searchModel!.data![index].whatsapp;
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
                                              const SizedBox(width: 10,),
                                            ],
                                          ),
                                        const SizedBox(height: 10,)
                                        ],
                                      ),
                                    ),

                                  ),
                                ),

                              )

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
              child: Image.asset("assets/images/home.png",height: 25,)),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
                }
                else{
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

                }
              });
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
              size: 30,
            )
                : const Icon(
              Icons.dehaze_outlined,
              color: Colors.red,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
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
class Page1 extends StatelessWidget {
  const Page1({super.key});

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
  const Page2({super.key});

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
  const Page3({super.key});

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
  const Page4({super.key});

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
class Data {
  final double x, y;
  Data(this.x, this.y);
}