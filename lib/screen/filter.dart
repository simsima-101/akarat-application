import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Akarat/model/propertytypemodel.dart';
import 'package:Akarat/screen/settingstile.dart';
import 'package:Akarat/screen/search.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/amenities.dart';
import 'package:Akarat/model/filtermodel.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:http/http.dart' as http;
import '../utils/fav_login.dart';
import '../utils/fav_logout.dart';
import '../utils/shared_preference_manager.dart';
import 'filter_list.dart';
import 'full_amenities_screen.dart';
import 'locationsearch.dart';
import 'my_account.dart';


class Filter extends StatelessWidget {
  final dynamic data;
  const Filter({super.key,required this.data});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FilterDemo(data: data,),
    );
  }
}
class FilterDemo extends StatefulWidget {
  final dynamic data;

  const FilterDemo({super.key,required this.data});

  @override
  _FilterDemoState createState() => _FilterDemoState();
}
class _FilterDemoState extends State<FilterDemo> {
  late bool isSelected = true;
   double start = 3000;
   double startarea = 3000;
   double endarea = 5000;
   double end = 5000;
   SfRangeValues _values = SfRangeValues(80000 ,200000);
   SfRangeValues _valuesArea = SfRangeValues(3000 ,5000);
  late RangeController _rangeController;
  late RangeController _rangeControllerarea;
  final agenciesController = TextEditingController();

  ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  late FilterModel filterModel;


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

  List<Amenities> selectedAmenities = [];


  @override
  void initState() {
    super.initState();
    _rangeController = RangeController(start: start.toString(), end: end.toString());
    _rangeControllerarea = RangeController(start: startarea.toString(), end: endarea.toString());
    selectedproduct = _product.indexOf(widget.data);
    purpose = widget.data;
    loadInitialData(); // this now uses cache
    chartData = List.generate(
      96,
          (index) => Data(500 + index * 100.0, yValues[index % yValues.length].toDouble()),
    );

  }

  Future<void> loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();

      // -- Caching Amenities --
      final amenitiesKey = 'cached_amenities';
      final amenitiesTimeKey = 'cached_amenities_time';
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastFetchedAmenities = prefs.getInt(amenitiesTimeKey) ?? 0;

      if (now - lastFetchedAmenities < Duration(hours: 6).inMilliseconds) {
        final cachedAmenities = prefs.getString(amenitiesKey);
        if (cachedAmenities != null) {
          final jsonData = json.decode(cachedAmenities) as List;
          amenities = jsonData.map((e) => Amenities.fromJson(e)).toList();
        }
      } else {
        final response = await http.get(Uri.parse("https://akarat.com/api/amenities")).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body) as List;
          amenities = jsonData.map((e) => Amenities.fromJson(e)).toList();
          prefs.setString(amenitiesKey, response.body);
          prefs.setInt(amenitiesTimeKey, now);
        }
      }

      // -- Caching Property Types --
      final propTypeKey = 'cached_prop_type_$purpose';
      final propTypeTimeKey = '${propTypeKey}_time';
      final lastFetchedProp = prefs.getInt(propTypeTimeKey) ?? 0;

      if (now - lastFetchedProp < Duration(hours: 6).inMilliseconds) {
        final cachedProp = prefs.getString(propTypeKey);
        if (cachedProp != null) {
          final data = json.decode(cachedProp);
          propertyTypeModel = PropertyTypeModel.fromJson(data);
        }
      } else {
        final uri = Uri.parse("https://akarat.com/api/property-types/$purpose");
        final response = await http.get(uri).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          propertyTypeModel = PropertyTypeModel.fromJson(data);
          prefs.setString(propTypeKey, response.body);
          prefs.setInt(propTypeTimeKey, now);
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      setState(() => _isLoading = false);
    }
  }


  List<Amenities> amenities = [];
  @override
  void dispose() {
    _rangeController.dispose();
    _rangeControllerarea.dispose();
    super.dispose();
  }
final List _product = [
  'Rent',
  'Buy',
  'New Projects',
'Commercial'

];
  final List _category = [
    'All Residential',
    'Apartment',
    'Villa',
    'Townhouse',
  ];
  final List _bedroom = [
    'Studio', '1', '2', '3','4','5','6','7','8','9+'
  ];
  final List _bathroom = [
    '1', '2', '3','4','5','6+'
  ];
  final List _ftype = [
    'All', 'Furnished', 'Unfurnished'
  ];
  final List _rent = [
    'Yearly', 'Daily',
        'Monthly'
  ];

  final List<int> yValues = [5000, 3000, 9000,7000,10000,1500,4000,];
  late List<Data> chartData;


  final List<Dataarea> chartDataarea = <Dataarea>[
    Dataarea(x: 500, y: 5000),
    Dataarea(x: 600, y: 3000),
    Dataarea(x: 700, y: 6000),
    Dataarea(x: 800, y: 2000),
    Dataarea(x: 900, y:8000),
    Dataarea(x: 1000, y:1000),
    Dataarea(x: 1100, y:3000),
    Dataarea(x: 1200, y:5000),
    Dataarea(x: 1300, y: 9000),
    Dataarea(x: 1400, y: 4000),
    Dataarea(x: 1500, y: 1500),
    Dataarea(x: 1600, y: 6000),
    Dataarea(x: 1700, y: 9000),
    Dataarea(x: 1800, y: 2000),
    Dataarea(x: 1900, y: 8000),
    Dataarea(x: 2000, y: 1000),
    Dataarea(x: 2100, y: 6000),
    Dataarea(x: 2200, y: 3000),
    Dataarea(x: 2300, y: 5000),
    Dataarea(x: 2400, y: 1000),
    Dataarea(x: 2500, y: 2500),
    Dataarea(x: 2600, y: 5500),
    Dataarea(x: 2700, y: 8000),
    Dataarea(x: 2800, y: 2500),
    Dataarea(x: 2900, y: 6000),
    Dataarea(x: 3000, y: 1000),
    Dataarea(x: 3100, y: 3000),
    Dataarea(x: 3200, y: 5000),
    Dataarea(x: 3300, y: 7000),
    Dataarea(x: 3400, y: 6000),
    Dataarea(x: 3500, y: 4000),
    Dataarea(x: 3600, y: 2000),
    Dataarea(x: 3700, y: 5000),
    Dataarea(x: 3800, y: 7000),
    Dataarea(x: 3900, y: 9000),
    Dataarea(x: 4000, y: 1000),
    Dataarea(x: 4100, y: 3000),
    Dataarea(x: 4200, y: 5000),
    Dataarea(x: 4300, y: 7000),
    Dataarea(x: 4400, y: 4000),
    Dataarea(x: 4500, y: 10000),
    Dataarea(x: 4600, y: 8000),
    Dataarea(x: 4700, y: 6000),
    Dataarea(x: 4800, y: 4000),
    Dataarea(x: 4900, y: 2000),
    Dataarea(x: 5000, y: 5500),
    Dataarea(x: 5100, y: 1000),
    Dataarea(x: 5200, y: 3000),
    Dataarea(x: 5300, y: 5000),
    Dataarea(x: 5400, y: 7000),
    Dataarea(x: 5500, y: 9000),
    Dataarea(x: 5600, y: 3000),
    Dataarea(x: 5700, y: 7500),
    Dataarea(x: 5800, y: 3500),
    Dataarea(x: 5900, y: 4560),
    Dataarea(x: 6000, y: 7500),
    Dataarea(x: 6100, y: 10000),
    Dataarea(x: 6200, y: 6000),
    Dataarea(x: 6300, y: 4000),
    Dataarea(x: 6400, y: 2000),
    Dataarea(x: 6500, y: 6000),
    Dataarea(x: 6600, y: 3000),
    Dataarea(x: 6700, y: 5000),
    Dataarea(x: 6800, y: 7000),
    Dataarea(x: 6900, y: 9000),
    Dataarea(x: 7000, y: 8000),
    Dataarea(x: 7100, y: 6000),
    Dataarea(x: 7200, y: 4000),
    Dataarea(x: 7300, y: 2000),
    Dataarea(x: 7400, y: 6500),
    Dataarea(x: 7500, y: 1000),
    Dataarea(x: 7600, y: 3000),
    Dataarea(x: 7700, y: 5000),
    Dataarea(x: 7800, y: 7000),
    Dataarea(x: 7900, y: 7500),
    Dataarea(x: 8000, y: 5000),
    Dataarea(x: 8100, y: 3000),
    Dataarea(x: 8200, y: 1000),
    Dataarea(x: 8300, y: 5000),
    Dataarea(x: 8400, y: 7000),
    Dataarea(x: 8500, y: 5000),
    Dataarea(x: 8600, y: 6000),
    Dataarea(x: 8700, y: 4000),
    Dataarea(x: 8800, y: 2000),
    Dataarea(x: 8900, y: 8000),
    Dataarea(x: 9000, y: 7000),
    Dataarea(x: 9100, y: 8800),
    Dataarea(x: 9200, y: 10000),
    Dataarea(x: 9300, y: 6600),
    Dataarea(x: 9400, y: 6600),
    Dataarea(x: 9500, y: 9999),
    Dataarea(x: 9600, y: 5555),
    Dataarea(x: 9700, y: 4444),
    Dataarea(x: 9800, y: 6666),
    Dataarea(x: 9900, y: 7777),
    Dataarea(x: 10000, y: 3000),
  ];

  int pageIndex = 0;
  int? selectedIndex; // Holds the index of the selected container
  int? selectedtype; // Holds the index of the selected container
  int? selectedproduct ; // Holds the index of the selected container
  int? selectedcategory; // Holds the index of the selected container
  int? selectedbedroom; // Holds the index of the selected container
  int? selectedbathroom; // Holds the index of the selected container
  int? selectedamenities; // Holds the index of the selected container
  // int? selectedamenities; // Holds the index of the selected container
  int? selectedrent; // Holds the index of the selected container
String purpose = ' ';
String category = ' ';
String bedroom = ' ';
String bathroom = ' ';
String ftype = ' ';
String amnities = ' ';
String property_type= ' ';
String rent = ' ';
String min_price = '';
String max_price = ' ';
String min_sqrfeet = ' ';
String max_sqrfeet = ' ';
  Set<int> selectedIndexes = {};
  PropertyTypeModel? propertyTypeModel;


  Future<void> showResult() async {
    setState(() {
      isLoading = true;
    });

    try {
      final amenitiesList = selectedIndexes.toList();

      final uriString =
          'https://akarat.com/api/filters?search='
          '&amenities=${amenitiesList.join(",")}'
          '&property_type=$property_type'
          '&furnished_status=$ftype'
          '&bedrooms=$bedroom'
          '&min_price=$min_price'
          '&max_price=$max_price'
          '&payment_period=$rent'
          '&min_square_feet=$min_sqrfeet'
          '&max_square_feet=$max_sqrfeet'
          '&bathrooms=$bathroom'
          '&purpose=$purpose';

      final uri = Uri.parse(uriString);
      final cacheKey = 'filter_cache_${md5.convert(utf8.encode(uriString))}';
      final cacheTimeKey = '${cacheKey}_time';

      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

      // ✅ Use cached data if valid
      if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
        final cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          final data = jsonDecode(cachedData);
          final feature = FilterResponseModel.fromJson(data);
          if (mounted) {
            setState(() {
              filterModel = feature.data!;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FliterList(filterModel: filterModel),
              ),
            );
          }
          return;
        }
      }

      // 🔄 Fetch fresh data
      final response = await http.get(uri).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feature = FilterResponseModel.fromJson(data);

        prefs.setString(cacheKey, response.body);
        prefs.setInt(cacheTimeKey, now);

        if (mounted) {
          setState(() {
            filterModel = feature.data!;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FliterList(filterModel: filterModel),
            ),
          );
        }
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Something went wrong. Please try again.")),
        );
      }
    } on SocketException {
      debugPrint("❌ No internet connection.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No internet connection.")),
      );
    } on TimeoutException {
      debugPrint("❌ Request timed out.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request timed out. Please try again.")),
      );
    } catch (e) {
      debugPrint("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error occurred.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  bool _isLoading = false;

  Future<void> propertyApi(String purpose) async {
    final cachedKey = 'property_type_$purpose';
    final cachedTimeKey = 'cached_time_property_type_$purpose';

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cachedTimeKey) ?? 0;

    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cachedKey);
      if (cachedData != null) {
        final data = jsonDecode(cachedData);
        final feature = PropertyTypeModel.fromJson(data);
        setState(() {
          propertyTypeModel = feature;
        });
        return;
      }
    }

    try {
      final uri = Uri.parse("https://akarat.com/api/property-types/$purpose");
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feature = PropertyTypeModel.fromJson(data);

        if (mounted) {
          setState(() {
            propertyTypeModel = feature;
          });
          prefs.setString(cachedKey, response.body);
          prefs.setInt(cachedTimeKey, now);
        }
      } else {
        debugPrint("❌ Property API failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Property API error: $e");
    }
  }


  Future<void> fetchAmenities() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedKey = 'cached_amenities';
    final cachedTimeKey = 'cached_time_amenities';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cachedTimeKey) ?? 0;

    // ✅ If cached data is fresh (<6 hours), use it
    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cachedKey);
      if (cachedData != null) {
        final List<dynamic> jsonData = json.decode(cachedData);
        if (mounted) {
          setState(() {
            amenities = jsonData.map((data) => Amenities.fromJson(data)).toList();
          });
        }
        return;
      }
    }

    // ⬇️ If not cached or expired, fetch from API
    try {
      final response = await http
          .get(Uri.parse("https://akarat.com/api/amenities"))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // ✅ Save to cache
        prefs.setString(cachedKey, response.body);
        prefs.setInt(cachedTimeKey, now);

        if (mounted) {
          setState(() {
            amenities = jsonData.map((data) => Amenities.fromJson(data)).toList();
          });
        }
      } else {
        debugPrint("❌ Failed to load amenities: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Error fetching amenities: $e");
    }
  }

// Inside your State class:
  bool _showAllAmenities = false;
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (propertyTypeModel == null) {
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
      appBar: AppBar(
        backgroundColor: Color(0xFFF9F9F9), // Softer white
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Filters",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Home())), // ✅ Add close functionality
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                // Reset all string/int filter variables
                purpose = '';
                category = '';
                bedroom = '';
                bathroom = '';
                ftype = '';
                property_type = '';
                rent = '';
                min_price = '';
                max_price = '';
                min_sqrfeet = '';
                max_sqrfeet = '';

                // Reset selected indexes
                selectedIndex = null;
                selectedtype = null;
                selectedproduct = null;
                selectedcategory = null;
                selectedbedroom = null;
                selectedbathroom = null;
                selectedrent = null;

                // Reset amenities
                selectedIndexes.clear();

                // Reset sliders
                _values = SfRangeValues(80000, 200000);
                _valuesArea = SfRangeValues(3000, 5000);

                // Also clear text fields if any (you already use controllers for search etc.)
                _searchController.clear();
                agenciesController.clear();
              });
            },
            child: const Text(
              "Reset",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              //properties
              Padding(
                padding: const EdgeInsets.all(5),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _product.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          setState(() {
                            selectedproduct = index;
                            purpose = _product[index];
                            _isLoading = true;
                          });

                          await propertyApi(purpose);

                          setState(() {
                            _isLoading = false;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            /*border: Border.all(
                              color: selectedproduct == index ? Colors.blueAccent : Colors.white,
                              width: selectedproduct == index ? 2 : 1,
                            ),*/
                            color: selectedproduct == index ? Color(0xFF42A5F5) : Colors.white,
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
                          child: Text(
                            _product[index],
                            style: TextStyle(
                              color: selectedproduct == index ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1,indent: 15,endIndent: 15,),
              const SizedBox(height: 20),
              //Searchbar
              Padding(
                padding: const EdgeInsets.only(left: 10.0,right: 10),
                child: Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.redAccent.shade100, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.redAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search for a locality, area or city",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1,indent: 15,endIndent: 15,),
              const SizedBox(height: 20),
              //property type
              Row(
                children: [
                  Padding(padding: const EdgeInsets.only(left: 20),
                      // child:  Text(purpose,
                      child:  Text("Property Type",
                        style: TextStyle(
                            color: Colors.black,fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                        textAlign: TextAlign.left,)
                  ),
                ],
              ),
              const SizedBox(height: 5),
              AnimatedOpacity(
          opacity: _isLoading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 500),
          child: Container(
            margin: const EdgeInsets.all(5),
            height: screenSize.height * 0.125,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: propertyTypeModel?.data?.length ?? 0,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedtype = index;
                      property_type = propertyTypeModel!.data![index].name.toString();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: selectedtype == index ? Color(0xFFEEEEEE) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset: Offset(0, 2),
                          blurRadius: 4,
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CachedNetworkImage(
                            imageUrl: propertyTypeModel!.data![index].icon.toString(),
                            height: 35,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            propertyTypeModel!.data![index].name.toString(),
                            style: TextStyle(
                              color: selectedtype == index ? Colors.black : Colors.black,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
              const SizedBox(height: 20),
              const Divider(height: 1,indent: 15,endIndent: 15,),
              const SizedBox(height: 20),
              //text
              Row(
                children: [
                  Padding(padding: const EdgeInsets.only(left: 20),
                    child:  Text("Price range",
                      style: TextStyle(
                          color: Colors.black,fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.left,),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.only(top: 0,left: 20,right: 10),
                  child: Row(
                    spacing: 15,
                      children: [
                        Container(
                            width: screenSize.width*0.38,
                            height: 40,
                            padding: const EdgeInsets.only(top: 8,left: 8),
                            decoration: BoxDecoration(
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
                              ],
                            ),
                            child: Text(_values.start.toStringAsFixed(0),style: TextStyle(
                                fontWeight: FontWeight.bold,fontSize: 15 ))

                        ),

                        Padding(padding: const EdgeInsets.only(top: 5),
                          child:  Text("to",
                            style: TextStyle(
                                color: Colors.black,fontSize: 15.0),
                            textAlign: TextAlign.left,),
                        ),

                        Container(
                            width: screenSize.width*0.38,
                            height: 40,
                            padding: const EdgeInsets.only(top: 8,left: 8),
                            decoration: BoxDecoration(
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
                              ],
                            ),
                            child: Text(_values.end.toStringAsFixed(0),style: TextStyle(
                                fontWeight: FontWeight.bold ,fontSize: 15))
                        ),
                      ]
                  )
              ),
              const SizedBox(height: 20),
              //rangeslider
              Padding(
                padding: const EdgeInsets.all(0),
                child: SfRangeSelectorTheme(
                  data: SfRangeSelectorThemeData(
                    overlappingTooltipStrokeColor: Color(0x80E0E0E0),
                    tooltipBackgroundColor: Colors.black,
                    activeDividerStrokeWidth: 1,
                    activeDividerRadius: 2,
                    thumbStrokeWidth: 0.5,// Change tooltip background color
                    tooltipTextStyle: TextStyle(
                      color: Colors.white, // Change tooltip text color
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                  child: SfRangeSelector(
                    min: 500,
                    max: 300000,
                    interval: 10000,
                    activeColor: Colors.black,
                    inactiveColor: Color(0x80F1EEEE) ,
                    enableTooltip: true,
                    shouldAlwaysShowTooltip: true,
                    initialValues: _values,
                    tooltipTextFormatterCallback: (actualValue, _) =>
                    'AED ${actualValue.toInt()}',
                    onChanged: (value) {
                      setState(() {
                        _values=SfRangeValues(value.start, value.end);
                        min_price=value.start.toStringAsFixed(0);
                        max_price=value.end.toStringAsFixed(0);
                      });

                    },
                    child: SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: SfCartesianChart(
                        backgroundColor: Colors.transparent,
                        plotAreaBorderColor: Colors.transparent,
                        margin: const EdgeInsets.all(0),
                        primaryXAxis: NumericAxis(
                          minimum: 500,
                          maximum: 10000,
                          isVisible: false,),
                        primaryYAxis: NumericAxis(isVisible: false),
                        plotAreaBorderWidth: 0,
                        plotAreaBackgroundColor: Colors.transparent,
                        series: <ColumnSeries<Data, double>>[
                          ColumnSeries<Data, double>(
                            trackColor: Colors.transparent,
                            //color: Color.fromARGB(255, 126, 184, 253),
                            //opacity: 0.5,
                            dataSource: chartData,
                            selectionBehavior: SelectionBehavior(
                              unselectedOpacity: 0.0,
                              selectedColor: Colors.transparent,
                              selectedOpacity: 0.0,unselectedColor: Colors.transparent,
                              selectionController: _rangeController,
                            ),
                            xValueMapper: (Data sales, int index) => sales.x,
                            yValueMapper: (Data sales, int index) => sales.y,
                            pointColorMapper: (Data sales, int index) {
                              return const Color.fromARGB(255, 37, 117, 212);
                            },
                            // color: const Color.fromRGBO(255, 255, 255, 0),
                            dashArray: const <double>[5, 3],
                            // borderColor: const Color.fromRGBO(194, 194, 194, 1),
                            animationDuration: 0,
                            borderWidth: 0,
                            //opacity: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1,indent: 15,endIndent: 15,),
              const SizedBox(height: 20),
              Row(
                children: [
                  Padding(padding: const EdgeInsets.only(left: 20),
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
              const SizedBox(height: 5),
              //studio
              Padding(
                padding: const EdgeInsets.all(5),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: _bedroom.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedbedroom = index;
                            bedroom = _bedroom[index];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: selectedbedroom == index ? Color(0xFFEF5350) : Colors.white,
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
                          alignment: Alignment.center,
                          child: Text(
                            _bedroom[index],
                            style: TextStyle(
                              color: selectedbedroom == index ? Colors.white : Colors.black,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1,indent: 15,endIndent: 15,),
              const SizedBox(height: 20),
              Row(
                children: [
                  Padding(padding: const EdgeInsets.only(left: 20),
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
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(5),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _bathroom.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedbathroom = index;
                            bathroom = _bathroom[index];
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: selectedbathroom == index ? Color(0xFFEF5350) : Colors.white,
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
                          child: Text(
                            _bathroom[index],
                            style: TextStyle(
                              color: selectedbathroom == index ? Colors.white : Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1,indent: 15,endIndent: 15,),
              const SizedBox(height: 20),
              //area
              Row(
                children: [
                  Padding(padding: const EdgeInsets.only(left: 20),
                    child:  Text("Area/Size",
                      style: TextStyle(
                          color: Colors.black,fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                         ),
                      textAlign: TextAlign.left,),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.only(top: 0,left: 20,right: 10),
                  child: Row(
                    spacing: 15,
                      children: [
                        Container(
                            width: screenSize.width*0.38,
                            height: 40,
                            padding: const EdgeInsets.only(top: 8,left: 8),
                            decoration: BoxDecoration(
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
                              ],
                            ),
                            child: Text(_valuesArea.start.toStringAsFixed(0),style: TextStyle(
                              fontWeight: FontWeight.bold,fontSize: 15
                            ),)
                        ),

                        Padding(padding: const EdgeInsets.only(top: 5),
                          child:  Text("to",
                            style: TextStyle(
                                color: Colors.black,fontSize: 15.0),
                            textAlign: TextAlign.left,),
                        ),

                        Container(
                            width: screenSize.width*0.38,
                            height: 40,
                            padding: const EdgeInsets.only(top: 8,left: 8),
                            decoration: BoxDecoration(
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
                              ],
                            ),
                            child: Text(_valuesArea.end.toStringAsFixed(0),style: TextStyle(
                                fontWeight: FontWeight.bold ,fontSize: 15))
                        ),
                      ]
                  )
              ),
              const SizedBox(height: 20),
              //rangeslider
              Padding(
                padding: const EdgeInsets.all(5),
                child: SfRangeSelectorTheme(
                  data: SfRangeSelectorThemeData(
                    tooltipBackgroundColor: Colors.black, // Change tooltip background color
                    tooltipTextStyle: TextStyle(
                      color: Colors.white, // Change tooltip text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: SfRangeSelector(
                    min: 500,
                    max: 10000,
                    interval: 1000,
                    enableTooltip: true,
                    shouldAlwaysShowTooltip: true,
                    activeColor: Colors.black,
                    inactiveColor: Color(0x80E0E0E0),
                    initialValues: _valuesArea,
                    onChanged: (value) {
                      setState(() {
                        _valuesArea=SfRangeValues(value.start, value.end);
                        min_sqrfeet=value.start.toStringAsFixed(0);
                        max_sqrfeet=value.end.toStringAsFixed(0);
                      });

                    },
                    child: SizedBox(
                      height: 70,
                      width: 400,
                      child: SfCartesianChart(
                        plotAreaBorderColor: Colors.transparent,
                        margin: const EdgeInsets.all(0),
                        primaryXAxis: NumericAxis(minimum: 500, maximum: 10000,
                          isVisible: false,),
                        primaryYAxis: NumericAxis(isVisible: false),
                        plotAreaBorderWidth: 0,
                        plotAreaBackgroundColor: Colors.transparent,
                        series: <ColumnSeries<Dataarea, double>>[
                          ColumnSeries<Dataarea, double>(
                            trackColor: Colors.transparent,
                            // color: Color.fromARGB(255, 126, 184, 253),
                            dataSource: chartDataarea,
                            selectionBehavior: SelectionBehavior(
                              unselectedOpacity: 0,
                              selectedOpacity: 0.0,unselectedColor: Colors.transparent,
                              selectionController: _rangeControllerarea,
                            ),
                            xValueMapper: (Dataarea sales, int index) => sales.x,
                            yValueMapper: (Dataarea sales, int index) => sales.y,
                            pointColorMapper: (Dataarea sales, int index) {
                              return const Color.fromARGB(255, 37, 117, 212);
                            },
                            // color: const Color.fromRGBO(255, 255, 255, 0),
                            dashArray: const <double>[5, 3],
                            // borderColor: const Color.fromRGBO(194, 194, 194, 1),
                            animationDuration: 0,
                            borderWidth: 0,
                            //opacity: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1,indent: 15,endIndent: 15,),
              const SizedBox(height: 20),
              //furnished
              Row(
                children: [
                  Padding(padding: const EdgeInsets.only(left: 20),
                    child:  Text("Furnished Type",
                      style: TextStyle(
                          color: Colors.black,fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          ),
                      textAlign: TextAlign.left,),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(5),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const ScrollPhysics(),
                    itemCount: _ftype.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            ftype = _ftype[index];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: selectedIndex == index ? Color(0xFF42A5F5) : Colors.white,
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
                          alignment: Alignment.center,
                          child: Text(
                            _ftype[index],
                            style: TextStyle(
                              color: selectedIndex == index ? Colors.white : Colors.black,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1,indent: 15,endIndent: 15,),
              const SizedBox(height: 20),
              //Amenities
              Row(
                children: [
                  Padding(padding: const EdgeInsets.only(left: 20),
                    child:  Text("Amenities",
                      style: TextStyle(
                          color: Colors.black,fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          ),
                      textAlign: TextAlign.left,),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.builder(
                      itemCount: _showAllAmenities ? amenities.length : 4,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final isSelected = selectedIndexes.contains(index);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isSelected
                                  ? selectedIndexes.remove(index)
                                  : selectedIndexes.add(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: isSelected ? Colors.black87 : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Image.network(
                                  amenities[index].icon ?? '',
                                  width: 18,
                                  height: 18,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    amenities[index].title ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (amenities.length > 6)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullAmenitiesScreen(
                                allAmenities: amenities,
                                selectedIndexes: selectedIndexes,
                                onDone: (selected) {
                                  setState(() {
                                    selectedIndexes = selected;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Text(
                          _showAllAmenities ? "Show less amenities" : "Show more amenities",
                          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold,fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1,indent: 15,endIndent: 15,),
              const SizedBox(height: 20),
              //real estate
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child:  Text("Rent is paid",style: TextStyle(
                        color: Colors.black,fontSize: 16.0,
                        fontWeight: FontWeight.bold,letterSpacing: 0.5
                    ),textAlign: TextAlign.left,),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(5),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const ScrollPhysics(),
                    itemCount: _rent.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedrent == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedrent = index;
                            rent = _rent[index];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFF42A5F5) : Colors.white,
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
                          alignment: Alignment.center,
                          child: Text(
                            _rent[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1,indent: 15,endIndent: 15,),
              Container(
                height: 100,
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
                    child: Text("Showing ${propertyTypeModel?.totalFeaturedProperties ??0} Results",style: TextStyle(

                        color: Colors.white,letterSpacing: 0.5,fontWeight: FontWeight.bold,fontSize: 15
                    ),textAlign: TextAlign.center,),
                  ),
                ),
              ),
              Container(
                height: 10,
              ),
            ]),
      ),
    ) ;

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
        IconButton(
          enableFeedback: false,
          onPressed: () {
            setState(() {
              pageIndex = 1;
            });
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
class Data {
  final double x, y;
  Data(this.x, this.y);
}

class Dataarea {
  Dataarea({required this.x, required this.y});
  final double x;
  final double y;
}