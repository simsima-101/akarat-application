import 'dart:convert';
import 'package:Akarat/model/propertytypemodel.dart';
import 'package:Akarat/screen/settingstile.dart';
import 'package:Akarat/screen/search.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/amenities.dart';
import 'package:Akarat/model/filtermodel.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:http/http.dart' as http;
import 'filter_list.dart';
import 'locationsearch.dart';


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
   SfRangeValues _values = SfRangeValues(3000 ,5000);
   SfRangeValues _valuesArea = SfRangeValues(3000 ,5000);
  late RangeController _rangeController;
  late RangeController _rangeControllerarea;
  final agenciesController = TextEditingController();

  late FilterModel filterModel;

  @override
  void initState() {
    super.initState();
    _rangeController = RangeController(
        start: start.toString(),
        end: end.toString());
    _rangeControllerarea = RangeController(
        start: startarea.toString(),
        end: endarea.toString());
    fetchAmenities();
    if(widget.data == 'Rent'){
      selectedproduct = 0;
    }else if(widget.data == 'Buy'){
      selectedproduct = 1;
    }else if(widget.data == 'Commercial'){
      selectedproduct = 3;
    }
    else{
      selectedproduct = 0;
    }
   // selectedproduct = 0; // Select first item initially
    purpose = widget.data; // Set initial purpose

    propertyApi(widget.data);
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
    'studio', '1', '2', '3','4','5','6','7','8','9+'
  ];
  final List _bathroom = [
    '1', '2', '3','4','5','6+'
  ];
  final List _ftype = [
    'All', 'Furnished', 'Unfurnished'
  ];
  final List _rent = [
    'Yearly', 'Bi-Yearly', 'Quarterly',
        'Monthly'
  ];
  final List<Data> chartData = <Data>[
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
  ];
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
  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];
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
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://akarat.com/api/filters?'
        'search=&amenities=[$selectedIndexes]&property_type=$property_type'
        '&furnished_status=$ftype&bedrooms=$bedroom&min_price=$min_price'
        '&max_price=$max_price&payment_period=$rent&min_square_feet=$min_sqrfeet'
        '&max_square_feet=$max_sqrfeet&bathrooms=$bathroom&purpose=$purpose'));
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

  Future<void> fetchAmenities() async {
    final response = await http.get(Uri.parse("https://akarat.com/api/amenities"));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        amenities = jsonData.map((data) => Amenities.fromJson(data)).toList();
      });
    } else {
    }
  }

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
              // TODO: Add reset logic
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
              //properties
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    //color: Colors.grey,
                    height: 60,
                    child:  ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const ScrollPhysics(),
                      itemCount: _product.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // Colors.grey;
                        return Container(
                            alignment: Alignment.topLeft,
                            // color: selectedIndex == index ? Colors.amber : Colors.transparent,
                            margin: const EdgeInsets.only(left: 5,right: 3,top: 5,bottom: 5),
                            //  width: screenSize.width * 0.25,
                            // height: 20,
                            padding: const EdgeInsets.only(top: 0,left: 14,right: 14),
                            decoration: BoxDecoration(
                              color: selectedproduct == index ? Colors.blueAccent : Colors.white,
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
                              child:   Center(
                                child: Text(_product[index],style: TextStyle(
                                  //color: Colors.black,
                                  color: selectedproduct == index ? Colors.white : Colors.black,
                                  letterSpacing: 0.5,fontWeight: FontWeight.bold,fontSize: 16),textAlign: TextAlign.center,),
                              ),
                              onTap: (){
                                setState(() {
                                //  if(isSelected=true) {
                                  selectedproduct = index;
                                  purpose = _product[index];
                                  propertyApi(purpose);
                                    //  Color(0xFF212121);
                                //  }
                                });
                              },
                            )
                        );
                      },
                    ),
                  )
              ),
              const SizedBox(height: 20),
              //Searchbar
              Padding(
                padding: const EdgeInsets.all(5),
                child: GestureDetector(
                  onTap: (){
                   // Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchScreen()));

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
              const SizedBox(height: 20),
              //property type
              Row(
                children: [
                  Padding(padding: const EdgeInsets.all(5),
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
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.all(5),
                height: screenSize.height*0.12,
             //  width: screenSize.width*0.5,
               // color: Colors.grey,
                child:  ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const ScrollPhysics(),
                  itemCount: propertyTypeModel?.data?.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: const EdgeInsets.only(left: 8,right: 8,top: 5,bottom: 5),
                        padding: const EdgeInsets.only(top: 5,left: 15,right: 15),
                        decoration: BoxDecoration(
                          color: selectedtype == index ? Color(0xFFEEEEEE): Colors.white,
                          //color: Colors.white,
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
                          child:   Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: CachedNetworkImage(
                                  imageUrl: propertyTypeModel!.data![index].icon.toString(),height: 35,),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(propertyTypeModel!.data![index].name.toString(),
                                  style: TextStyle(
                                    color: selectedtype == index ? Colors.black : Colors.black,
                                  letterSpacing: 0.5,fontWeight: FontWeight.bold,fontSize: 16),
                                  textAlign: TextAlign.center,),
                              ),
                            ],
                          ),
                          onTap: (){
                            setState(() {
                              selectedtype = index;
                                property_type = propertyTypeModel!.data![index].name.toString();
                              // }
                            });
                          },
                        )
                    );
                    // return Amenitiescardscreen(amenities: amenities[index]);
                  },
                ),
              ),
              const SizedBox(height: 24),
              //text
              Row(
                children: [
                  Padding(padding: const EdgeInsets.all(5),
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
                                fontWeight: FontWeight.bold,fontSize: 18 ))

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
                                fontWeight: FontWeight.bold ,fontSize: 18))
                        ),
                      ]
                  )
              ),
              const SizedBox(height: 10),
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
                    interval: 100,
                    activeColor: Colors.black,
                    inactiveColor: Color(0x80E0E0E0),
                    enableTooltip: true,
                    shouldAlwaysShowTooltip: true,
                    initialValues: _values,
                    onChanged: (value) {
                      setState(() {
                        _values=SfRangeValues(value.start, value.end);
                        min_price=value.start.toStringAsFixed(0);
                        max_price=value.end.toStringAsFixed(0);
                      });

                    },
                    child: SizedBox(
                      height: 60,
                      width: 400,
                      child: SfCartesianChart(
                        backgroundColor: Colors.transparent,
                        plotAreaBorderColor: Colors.transparent,
                        margin: const EdgeInsets.all(0),
                        primaryXAxis: NumericAxis(minimum: 500, maximum: 10000,
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Padding(padding: const EdgeInsets.all(5),
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
              const SizedBox(height: 10),
              //studio
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    //color: Colors.grey,
                    // width: 60,
                    height: 60,
                    child:  ListView.builder(
                      padding: const EdgeInsets.all(0),
                      scrollDirection: Axis.horizontal,
                      physics: const ScrollPhysics(),
                      itemCount: _bedroom.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // Colors.grey;
                        return Container(
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
                            child: GestureDetector(
                              child:   Center(
                                child: Text(_bedroom[index],
                                  style: TextStyle(
                                    color: selectedbedroom == index ? Colors.white : Colors.black,
                                  letterSpacing: 0.5,fontWeight: FontWeight.bold,
                                  fontSize: 18),textAlign: TextAlign.center,),
                              ),
                              onTap: (){
                                setState(() {
                                //  if(isSelected=true) {
                                  selectedbedroom = index;
                                    bedroom = _bedroom[index];
                                //  }
                                });
                              },
                            )
                        );
                      },
                    ),
                  )
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Padding(padding: const EdgeInsets.all(5),
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
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.all(5),
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
                        return Container(
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
                            child: GestureDetector(
                              child:   Center(
                                child: Text(_bathroom[index],
                                  style: TextStyle(
                                    color: selectedbathroom == index ? Colors.white : Colors.black,
                                  letterSpacing: 0.5,fontSize: 18,
                                    fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                              ),
                              onTap: (){
                                setState(() {
                                //  if(isSelected=true) {
                                  selectedbathroom = index;
                                    bathroom = _bathroom[index];
                                 // }
                                });
                              },
                            )
                        );
                      },
                    ),
                  )
              ),
              const SizedBox(height: 24),
              //area
              Row(
                children: [
                  Padding(padding: const EdgeInsets.all(5),
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
                              fontWeight: FontWeight.bold,fontSize: 18
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
                                fontWeight: FontWeight.bold ,fontSize: 18))
                        ),
                      ]
                  )
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 24),
              //furnished
              Row(
                children: [
                  Padding(padding: const EdgeInsets.all(5),
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
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    alignment: Alignment.topLeft,
                    height: 60,
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
              const SizedBox(height: 24),
              //Amenities
              Row(
                children: [
                  Padding(padding: const EdgeInsets.all(5),
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
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    //color: Colors.grey,
                    // width: 60,
                    alignment: Alignment.topLeft,
                    height: 60,
                    child:  ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const ScrollPhysics(),
                      itemCount: amenities.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Container(
                            margin: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                            padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
                            decoration: BoxDecoration(
                              color: selectedIndexes.contains(index) ? Colors.blueAccent : Colors.white,
                              // color: selectedamenities == index ? Colors.grey : Colors.white,
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
                              child:   Row(
                                spacing: 5,
                                children: [
                                   Padding(
                                     padding: const EdgeInsets.all(2.0),
                                     child: CachedNetworkImage(imageUrl: amenities[index].icon.toString(),height: 17,),
                                   ),
                                  Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Text(amenities[index].title.toString(),
                                      style: TextStyle(
                                        color: selectedIndexes.contains(index) ? Colors.white : Colors.black,
                                      letterSpacing: 0.5,fontSize: 16,
                                        fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                                  ),
                                ],
                              ),
                              onTap: (){
                                setState(() {
                                 // if(isSelected=true) {
                                  if (selectedIndexes.contains(index)) {
                                    selectedIndexes.remove(index);
                                  } else {
                                    selectedIndexes.add(index);
                                  }
                                  // selectedamenities = index;
                                  //   amnities = amenities[index].title.toString();
                                 // }
                                });
                              },
                            )
                        );
                        // return Amenitiescardscreen(amenities: amenities[index]);
                      },
                    ),

                  )
              ),
              const SizedBox(height: 24),
              //real estate
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child:  Text("Rent is paid",style: TextStyle(
                        color: Colors.black,fontSize: 16.0,
                        fontWeight: FontWeight.bold,letterSpacing: 0.5
                    ),textAlign: TextAlign.left,),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    //color: Colors.grey,
                    // width: 60,
                    alignment: Alignment.topLeft,
                    height: 60,
                    child:  ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const ScrollPhysics(),
                      itemCount: _rent.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // Colors.grey;
                        return Container(
                          // color: selectedIndex == index ? Colors.amber : Colors.transparent,
                            margin: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                            // width: screenSize.width * 0.25,
                            // height: 20,
                            padding: const EdgeInsets.only(top: 0,left: 15,right: 15),
                            decoration: BoxDecoration(
                              color: selectedrent == index ? Colors.blueAccent : Colors.white,
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
                              child:   Center(
                                child: Text(_rent[index],
                                  style: TextStyle(
                                    color: selectedrent == index ? Colors.white : Colors.black,
                                  letterSpacing: 0.5,fontSize: 16,
                                    fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                              ),
                              onTap: (){
                                setState(() {
                                 // if(isSelected=true) {
                                  selectedrent = index;
                                    rent = _rent[index];
                                 // }
                                });
                              },
                            )
                        );
                      },
                    ),
                  )
              ),
              Container(
                height: 150,
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
                    child: Text("Showing 112,765 Results",style: TextStyle(

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
    height: 60,
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
        IconButton(
          enableFeedback: false,
          onPressed: () {
            setState(() {
              // Navigator.push(context, MaterialPageRoute(builder: (context)=> FilterScreen()));
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
            });
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
        ),
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
              pageIndex = 2;
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
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
class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

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
  const Page2({Key? key}) : super(key: key);

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
  const Page3({Key? key}) : super(key: key);

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
  const Page4({Key? key}) : super(key: key);

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
  Data({required this.x, required this.y});
  final double x;
  final double y;
}
class Dataarea {
  Dataarea({required this.x, required this.y});
  final double x;
  final double y;
}