import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drawerdemo/model/amenities.dart';
import 'package:drawerdemo/screen/home.dart';
import 'package:drawerdemo/screen/profile_login.dart';
import 'package:drawerdemo/utils/Amenitiescardscreen.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:http/http.dart' as http;
import 'filter_list.dart';

void main(){
  runApp(const Filter());

}

class Filter extends StatelessWidget {
  const Filter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FilterDemo(),
    );
  }
}
class FilterDemo extends StatefulWidget {
  const FilterDemo({super.key});

  @override
  _FilterDemoState createState() => _FilterDemoState();
}
class _FilterDemoState extends State<FilterDemo> {
  late bool isSelected = true;
   double start = 12.0;
   double startarea = 2000.0;
   double endarea = 4500.0;
   double end = 30.0;
   SfRangeValues _values = SfRangeValues(12.0 ,30.0);
   SfRangeValues _valuesArea = SfRangeValues(2000.0 ,4500.0);
  late RangeController _rangeController;
  late RangeController _rangeControllerarea;
  final agenciesController = TextEditingController();

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
  }
  List<Amenities> amenities = [];
  @override
  void dispose() {
    _rangeController.dispose();
    _rangeControllerarea.dispose();
    super.dispose();
  }
final List _product = [
'Properties',
'New Projects',
'Buy',
'Rent',
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
  final List _amnities = [
    'Maids Room', 'Study', 'Central A/C Heating',
    'Balcony', 'Private Garden'
  ];
  final List _rent = [
    'Yearly', 'Bi-Yearly', 'Quarterly'
        'Monthly'
  ];
  final List<Data> chartData = <Data>[
    Data(x: 5.0, y: 15.45),
    Data(x: 6.0, y: 10.44),
    Data(x: 7.0, y: 38.12),
    Data(x: 8.0, y: 18.9),
    Data(x: 9.0, y: 22.8),
    Data(x: 10.0, y:19.7),
    Data(x: 11.0, y: 36.11),
    Data(x: 12.0, y: 12.5),
    Data(x: 13.0, y: 13.7),
    Data(x: 14.0, y: 20.8),
    Data(x: 15.0, y: 33.7),
    Data(x: 16.0, y: 34.7),
    Data(x: 17.0, y: 17.7),
    Data(x: 18.0, y: 22.7),
    Data(x: 19.0, y: 19.7),
    Data(x: 20.0, y: 22.7),
    Data(x: 21.0, y: 20.7),
    Data(x: 22.0, y: 44.7),
    Data(x: 23.0, y: 45.7),
    Data(x: 24.0, y: 40.7),
    Data(x: 25.0, y: 15.7),
    Data(x: 26.0, y: 26.7),
    Data(x: 27.0, y: 14.7),
    Data(x: 28.0, y: 20.7),
    Data(x: 29.0, y: 41.7),
    Data(x: 30.0, y: 13.7),
    Data(x: 31.0, y: 13.7),
    Data(x: 32.0, y: 34.0),
    Data(x: 33.0, y: 25.5),
    Data(x: 34.0, y: 41.5),
    Data(x: 35.0, y: 13.7),
    Data(x: 36.0, y: 13.7),
    Data(x: 37.0, y: 13.7),
    Data(x: 38.0, y: 45.7),
    Data(x: 39.0, y: 13.7),
    Data(x: 40.0, y: 13.7),
    Data(x: 41.0, y: 42.7),
    Data(x: 42.0, y: 13.7),
    Data(x: 43.0, y: 44.7),
    Data(x: 44.0, y: 13.7),
    Data(x: 45.0, y: 20.7),
    Data(x: 46.0, y: 44.7),
    Data(x: 47.0, y: 55.7),
    Data(x: 48.0, y: 60.7),
    Data(x: 49.0, y: 33.7),
    Data(x: 50.0, y: 24.7),
    Data(x: 51.0, y: 27.7),
    Data(x: 52.0, y: 35.7),
    Data(x: 53.0, y: 36.7),
    Data(x: 54.0, y: 39.7),
    Data(x: 55.0, y: 25.7),
    Data(x: 56.0, y: 13.7),
    Data(x: 57.0, y: 40.7),
    Data(x: 58.0, y: 56.7),
    Data(x: 59.0, y: 60.7),
    Data(x: 60.0, y: 53.7),
  ];
  final List<Dataarea> chartDataarea = <Dataarea>[
    Dataarea(x: 500.0, y: 1500.45),
    Dataarea(x: 600.0, y: 1000.44),
    Dataarea(x: 700.0, y: 3800.12),
    Dataarea(x: 800.0, y: 1800.9),
    Dataarea(x: 900.0, y: 2200.8),
    Dataarea(x: 1000.0, y:1900.7),
    Dataarea(x: 1100.0, y: 3600.11),
    Dataarea(x: 1200.0, y: 1200.5),
    Dataarea(x: 1300.0, y: 1300.7),
    Dataarea(x: 1400.0, y: 2000.8),
    Dataarea(x: 1500.0, y: 3300.7),
    Dataarea(x: 1600.0, y: 3400.7),
    Dataarea(x: 1700.0, y: 1700.7),
    Dataarea(x: 1800.0, y: 2200.7),
    Dataarea(x: 1900.0, y: 1900.7),
    Dataarea(x: 2000.0, y: 2200.7),
    Dataarea(x: 2100.0, y: 2000.7),
    Dataarea(x: 2200.0, y: 4400.7),
    Dataarea(x: 2300.0, y: 4500.7),
    Dataarea(x: 2400.0, y: 4000.7),
    Dataarea(x: 2500.0, y: 1500.7),
    Dataarea(x: 2600.0, y: 2600.7),
    Dataarea(x: 2700.0, y: 1400.7),
    Dataarea(x: 2800.0, y: 2000.7),
    Dataarea(x: 2900.0, y: 4100.7),
    Dataarea(x: 3000.0, y: 1300.7),
    Dataarea(x: 3100.0, y: 1300.7),
    Dataarea(x: 3200.0, y: 3400.0),
    Dataarea(x: 3300.0, y: 2500.5),
    Dataarea(x: 3400.0, y: 4100.5),
    Dataarea(x: 3500.0, y: 1300.7),
    Dataarea(x: 3600.0, y: 1300.7),
    Dataarea(x: 3700.0, y: 1300.7),
    Dataarea(x: 3800.0, y: 4500.7),
    Dataarea(x: 3900.0, y: 1300.7),
    Dataarea(x: 4000.0, y: 1300.7),
    Dataarea(x: 4100.0, y: 4200.7),
    Dataarea(x: 4200.0, y: 1300.7),
    Dataarea(x: 4300.0, y: 4400.7),
    Dataarea(x: 4400.0, y: 1300.7),
    Dataarea(x: 4500.0, y: 2000.7),
    Dataarea(x: 4600.0, y: 4400.7),
    Dataarea(x: 4700.0, y: 1550.7),
    Dataarea(x: 4800.0, y: 1600.7),
    Dataarea(x: 4900.0, y: 3300.7),
    Dataarea(x: 5000.0, y: 2400.7),
  ];

  int pageIndex = 0;
  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];
String myData = ' ';
String category = ' ';
String bedroom = ' ';
String bathroom = ' ';
String ftype = ' ';
String amnities = ' ';
String rent = ' ';
String min_price = '';
String max_price = ' ';


  Future<void> showResult() async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('http://akarat.com/api/filters?search=$_searchController&amenities=$amnities&'
        'category=$category&furnished_status=$ftype&bedrooms=$bedroom&'
        'min_price=$min_price&max_price=$max_price&payment_period=$rent&square_feet=1200&bathrooms=$bathroom&purpose=$myData'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
       // products = jsonData.map((data) => Product.fromJson(data)).toList();
      });
    } else {
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
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      bottomNavigationBar: buildMyNavBar(context),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          //filter
          Padding(
            padding: const EdgeInsets.only(top: 30,left: 0,right: 0),
            child: Container(
              margin: const EdgeInsets.only(left: 10,right: 10),
             // color: Colors.grey,
              width: screenSize.width * 1.0,
              height: 50,
              padding: const EdgeInsets.only(top: 5),
            child: Row(
              spacing: 10,
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeDemo()));
                  },
                  child:  Icon(Icons.close,color: Colors.red,),
                ),


                Padding(
                  padding: const EdgeInsets.only(left: 100.0),
                  child: Text("Filters",textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,fontSize: 20.0,fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),),
                ),

            GestureDetector(
              onTap: (){
               // Navigator.push(context, MaterialPageRoute(builder: (context)=> FliterListDemo()));
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) => Filter(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 100.0),
                child: Text("Reset",textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.red,fontSize: 16.0,fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,),),
              ),
            ),
              ],
            )
            ),
          ),
          //properties
          Padding(
            padding: const EdgeInsets.only(top: 0,left: 15,right: 10),
              child: Container(
                //color: Colors.grey,
                height: 40,
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
                    margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                  //  width: screenSize.width * 0.25,
                   // height: 20,
                       padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
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
                    //color:myData == index ? Colors.amber : Colors.transparent,
                    color: Colors.white,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                    ), //BoxShadow
                    ],
                    ),
                    child: GestureDetector(
                     child:   Center(
                       child: Text(_product[index],style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                     ),
                      onTap: (){
                        setState(() {
                          if(isSelected=true) {
                            myData = _product[index];
                          }
                        });
                      },
                    )
                    );
                  },
                ),
               /* child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5,left: 0,right: 1),
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
                        child: Text(" Properties  ",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.3,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("New projects",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Buy",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Rent",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                  ],
                  ),*/
              )
            ),
          //Searchbar
          Padding(
            padding: const EdgeInsets.only(top: 15,left: 15,right: 10),
            child: Container(
              width: 400,
              height: 60,
              padding: const EdgeInsets.only(top: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red,
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
              // Use a Material design search bar
              child: TextField(
                textAlign: TextAlign.left,
                controller: _searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search for a locality,area or city',
                  hintStyle: TextStyle(color: Colors.grey,fontSize: 15,
                      letterSpacing: 0.5),

                  // Add a clear button to the search bar
                  suffixIcon: IconButton(
                    alignment: Alignment.topLeft,
                    icon: Icon(Icons.mic),
                    onPressed: () => _searchController.clear(),
                  ),

                  // Add a search icon or button to the search bar
                  prefixIcon: IconButton(
                    alignment: Alignment.topLeft,
                    icon: Icon(Icons.search,color: Colors.red,),
                    onPressed: () {
                      // Perform the search here
                    },
                  ),
                ),
              ),
            ),
          ),
          //property type
          Row(
            children: [
              Padding(padding: const EdgeInsets.only(top: 25.0,left: 15,bottom: 15),
                  child:  Text("Property Type",
                    style: TextStyle(
                        color: Colors.black,fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5),
                    textAlign: TextAlign.left,)
              ),
            ],
          ),
          //images gridview
          Row(
            children: [
              //logo 1
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> FliterListDemo()));
                },
                child: Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 5.0, top: 5, bottom: 0),
                child: Container(
                    width: screenSize.width * 0.3,
                  height: 100,
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(10.0),
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
                    child:   Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/Residential__1.png",height: 40,),
                        Padding(padding: const EdgeInsets.only(left: 25,right: 20,top: 5),
                          child:  Text("Residential",style:
                          TextStyle(height: 1.2,
                              letterSpacing: 0.5,
                              fontSize: 12,fontWeight: FontWeight.bold
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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> FliterListDemo()));
                },
                child: Padding(
                padding: const EdgeInsets.only(
                    left: 3.0, right: 5.0, top:5.0, bottom: 0),
                child: Container(
                    width: screenSize.width * 0.3,
                  height: 100,
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(

                    // image: DecorationImage(
                    //   image: AssetImage("assets/images/02.png"),
                    // ),
                    borderRadius: BorderRadiusDirectional.circular(10.0),
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
                    child:   Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/commercial_new.png",height: 40,),
                        Padding(padding: const EdgeInsets.only(left: 25,right: 20,top: 5),
                          child:  Text("Commercial",style:
                          TextStyle(height: 1.2,
                              letterSpacing: 0.5,
                              fontSize: 12,fontWeight: FontWeight.bold
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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> FliterListDemo()));
                },
                child:Padding(
                padding: const EdgeInsets.only(
                    left: 3.0, right: 5.0, top: 5.0, bottom: 0),
                child: Container(
                    width: screenSize.width * 0.3,
                  height: 100,
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(10.0),
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
                    child:   Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/rooms_stand.png",height: 40,),
                        Padding(padding: const EdgeInsets.only(left: 25,right: 20,top: 5),
                          child:  Text("Rooms",style:
                          TextStyle(height: 1.2,
                              letterSpacing: 0.5,
                              fontSize: 12,fontWeight: FontWeight.bold
                          ),),
                        ),
                      ],
                    )
                ),
              ),
              ),
            ],
          ),
          //text
          Row(
          children: [
            Padding(padding: const EdgeInsets.only(top: 25.0,left: 15,bottom: 15),
              child:  Text("Residential Categories",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,fontWeight: FontWeight.w500,
                    letterSpacing: 0.5),
                textAlign: TextAlign.left,),
            ),
          ],
        ),
          //category
          Padding(
              padding: const EdgeInsets.only(top: 0,left: 15,right: 10),
              child: Container(
                //color: Colors.grey,
                height: 40,
                child:  ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const ScrollPhysics(),
                  itemCount: _category.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    // Colors.grey;
                    return Container(
                      // color: selectedIndex == index ? Colors.amber : Colors.transparent,
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                       // width: screenSize.width * 0.25,
                        // height: 20,
                        padding: const EdgeInsets.only(top: 0,left: 5,right: 5),
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
                              //color:myData == index ? Colors.amber : Colors.transparent,
                              color: Colors.white,
                              offset: const Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ), //BoxShadow
                          ],
                        ),
                        child: GestureDetector(
                          child:   Center(
                            child: Text(_category[index],style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                          ),
                          onTap: (){
                            setState(() {
                              if(isSelected=true) {
                                category = _category[index];
                              }
                            });
                          },
                        )
                    );
                  },
                ),
                /* child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5,left: 0,right: 1),
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
                        child: Text(" Properties  ",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.3,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("New projects",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Buy",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Rent",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                  ],
                  ),*/
              )
          ),
          Row(
            children: [
              Padding(padding: const EdgeInsets.only(top: 25.0,left: 15,bottom: 15),
                child:  Text("Price range",
                  style: TextStyle(
                      color: Colors.black,fontSize: 18.0,
                      letterSpacing: 0.5,
                  fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,),
              ),
            ],
          ),
          Padding(
        padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
        child: Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Container(
                width: 135,
                height: 35,
                padding: const EdgeInsets.only(top: 5,left: 5),
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
                child: Text(min_price)

              ),
              Container(
                width: 30,
              ),
              Padding(padding: const EdgeInsets.only(top: 5),
                child:  Text("to",
                  style: TextStyle(
                      color: Colors.black,fontSize: 15.0),
                  textAlign: TextAlign.left,),
              ),
              Container(
                width: 35,
              ),
              Container(
                width: 135,
                height: 35,
                padding: const EdgeInsets.only(top: 5,left: 5),
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
                child: Text(max_price)
              ),
              ]
        )
      ),
          //rangeslider
          Padding(padding: const EdgeInsets.only(top: 25.0,left: 1,bottom: 15),
            child: SfRangeSelector(
              min: 5.0,
              max: 60.0,
              interval: 1,
              enableTooltip: true,
              shouldAlwaysShowTooltip: true,
              initialValues: _values,
             onChanged: (value) {
                setState(() {
                  _values=SfRangeValues(value.start, value.end);
                  min_price=value.start.toStringAsFixed(2);
                  max_price=value.end.toStringAsFixed(2);
                });

             },
              child: SizedBox(
                height: 60,
                width: 400,
                child: SfCartesianChart(
                  backgroundColor: Colors.transparent,
                  plotAreaBorderColor: Colors.transparent,
                  margin: const EdgeInsets.all(0),
                  primaryXAxis: NumericAxis(minimum: 5.0, maximum: 60.0,
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
                        return const Color.fromARGB(255, 126, 184, 253);
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
          Row(
            children: [
              Padding(padding: const EdgeInsets.only(top: 25.0,left: 15,bottom: 15),
                // child:  Text(_values.start.toStringAsFixed(2),
               child:  Text("Bedrooms",
                  style: TextStyle(
                      color: Colors.black,fontSize: 18.0,
                      letterSpacing: 0.5,fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,),
              ),
            ],
          ),
          //studio
          Padding(
              padding: const EdgeInsets.only(top: 0,left: 15,right: 10),
              child: Container(
                //color: Colors.grey,
               // width: 60,
                height: 40,
                child:  ListView.builder(
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
                        padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
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
                              //color:myData == index ? Colors.amber : Colors.transparent,
                              color: Colors.white,
                              offset: const Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ), //BoxShadow
                          ],
                        ),
                        child: GestureDetector(
                          child:   Center(
                            child: Text(_bedroom[index],style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                          ),
                          onTap: (){
                            setState(() {
                              if(isSelected=true) {
                                bedroom = _bedroom[index];
                              }
                            });
                          },
                        )
                    );
                  },
                ),
                /* child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5,left: 0,right: 1),
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
                        child: Text(" Properties  ",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.3,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("New projects",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Buy",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Rent",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                  ],
                  ),*/
              )
          ),
          Row(
  children: [
    Padding(padding: const EdgeInsets.only(top: 25.0,left: 15,bottom: 15),
      // child:  Text(bedroom,
      child:  Text("Bathrooms",
        style: TextStyle(
            color: Colors.black,fontSize: 18.0,fontWeight: FontWeight.w500,
            letterSpacing: 0.5),
        textAlign: TextAlign.left,),
    ),
  ],
),
          Padding(
              padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
              child: Container(
                //color: Colors.grey,
                // width: 60,
                alignment: Alignment.topLeft,
                height: 40,
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
                        padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
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
                              //color:myData == index ? Colors.amber : Colors.transparent,
                              color: Colors.white,
                              offset: const Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ), //BoxShadow
                          ],
                        ),
                        child: GestureDetector(
                          child:   Center(
                            child: Text(_bathroom[index],style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                          ),
                          onTap: (){
                            setState(() {
                              if(isSelected=true) {
                                bathroom = _bathroom[index];
                              }
                            });
                          },
                        )
                    );
                  },
                ),
                /* child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5,left: 0,right: 1),
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
                        child: Text(" Properties  ",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.3,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("New projects",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Buy",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Rent",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                  ],
                  ),*/
              )
          ),
          //area
          Row(
            children: [
              Padding(padding: const EdgeInsets.only(top: 25.0,left: 15,bottom: 15),
                child:  Text("Area/Size",
                  style: TextStyle(
                      color: Colors.black,fontSize: 18.0,
                      letterSpacing: 0.5,
                  fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,),
              ),
            ],
          ),
          Padding(
              padding: const EdgeInsets.only(top: 5,left: 15,right: 10),
              child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 135,
                      height: 35,
                      padding: const EdgeInsets.only(top: 5,left: 5),
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
                      child: Text(_valuesArea.start.toStringAsFixed(2) )
                    ),
                    Container(
                      width: 35,
                    ),
                    Padding(padding: const EdgeInsets.only(top: 5),
                      child:  Text("to",
                        style: TextStyle(
                            color: Colors.black,fontSize: 15.0),
                        textAlign: TextAlign.left,),
                    ),
                    Container(
                      width: 35,
                    ),
                    Container(
                      width: 135,
                      height: 35,
                      padding: const EdgeInsets.only(top: 5,left: 5),
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
                      child: Text(_valuesArea.end.toStringAsFixed(2) )
                    ),
                  ]
              )
          ),
          //rangeslider
          Padding(padding: const EdgeInsets.only(top: 25.0,left: 1,bottom: 15),
           child: SfRangeSelector(
             min: 1000.0,
             max: 5000.0,
             interval: 5,
             enableTooltip: true,
             shouldAlwaysShowTooltip: true,
             initialValues: _valuesArea,
             onChanged: (value) {
               setState(() {
                 _valuesArea=SfRangeValues(value.start, value.end);
               });

             },
             child: SizedBox(
               height: 70,
               width: 400,
               child: SfCartesianChart(
                 plotAreaBorderColor: Colors.transparent,
                 margin: const EdgeInsets.all(0),
                 primaryXAxis: NumericAxis(minimum: 1000.0, maximum: 5000.0,
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
                       return const Color.fromRGBO(0, 178, 206, 1);
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
          //furnished
          Row(
  children: [
    Padding(padding: const EdgeInsets.only(top: 25.0,left: 15,bottom: 15),
      child:  Text("Furnished Type",
        style: TextStyle(
            color: Colors.black,fontSize: 18.0,
            letterSpacing: 0.5,
        fontWeight: FontWeight.w500),
        textAlign: TextAlign.left,),
    ),
  ],
),
          Padding(
              padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
              child: Container(
                //color: Colors.grey,
                // width: 60,
                alignment: Alignment.topLeft,
                height: 40,
                child:  ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const ScrollPhysics(),
                  itemCount: _ftype.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    // Colors.grey;
                    return Container(
                        margin: const EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                        padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
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
                              //color:myData == index ? Colors.amber : Colors.transparent,
                              color: Colors.white,
                              offset: const Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ), //BoxShadow
                          ],
                        ),
                        child: GestureDetector(
                          child:   Center(
                            child: Text(_ftype[index],style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                          ),
                          onTap: (){
                            setState(() {
                              if(isSelected=true) {
                                ftype = _ftype[index];
                              }
                            });
                          },
                        )
                    );
                  },
                ),
                /* child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5,left: 0,right: 1),
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
                        child: Text(" Properties  ",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.3,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("New projects",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Buy",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Rent",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                  ],
                  ),*/
              )
          ),
          //Amenities
          Row(
  children: [
    Padding(padding: const EdgeInsets.only(top: 25.0,left: 15,bottom: 15),
      child:  Text("Amenities",
        style: TextStyle(
            color: Colors.black,fontSize: 18.0,
            letterSpacing: 0.5,
        fontWeight: FontWeight.w500),
        textAlign: TextAlign.left,),
    ),
  ],
),
          Padding(
              padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
              child: Container(
                //color: Colors.grey,
                // width: 60,
                alignment: Alignment.topLeft,
                height: 40,
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
                              //color:myData == index ? Colors.amber : Colors.transparent,
                              color: Colors.white,
                              offset: const Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ), //BoxShadow
                          ],
                        ),
                        child: GestureDetector(
                          child:   Row(
                            children: [
                              CachedNetworkImage(imageUrl: amenities[index].icon.toString()),
                              Text(amenities[index].title.toString(),style: TextStyle(color: Colors.black,
                                  letterSpacing: 0.5,fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                            ],
                          ),
                          onTap: (){
                            setState(() {
                              if(isSelected=true) {
                                amnities = amenities[index].id.toString();
                              }
                            });
                          },
                        )
                    );
                    // return Amenitiescardscreen(amenities: amenities[index]);
                  },
                ),

              )
          ),

          //real estate
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 25.0,left: 15,bottom: 15),
                child:  Text("Real Estate Agencies",style: TextStyle(
                  color: Colors.black,letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                  fontSize: 18

                ),textAlign: TextAlign.left,),
              ),
            ],
          ),
          Padding(
        padding: const EdgeInsets.only(top: 5,left: 15,right: 10),
            child:   Container(
                width: 400,
                height: 35,
                padding: const EdgeInsets.only(top: 0,left: 15),
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
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                 controller: agenciesController,
                 // obscureText: true,
                  decoration: InputDecoration(
                    /* border: OutlineInputBorder(
                       ),*/
                    border: InputBorder.none,
                    hintText: '   eg.dubizzle properties',hintStyle: TextStyle(
                      color: Colors.grey,fontSize: 15,
                      letterSpacing: 0.5)
                  ),
                  textAlign: TextAlign.left,

                ),
              ),
      ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 25.0,left: 15,bottom: 15),
                child:  Text("Rent is paid",style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,letterSpacing: 0.5
                ),textAlign: TextAlign.left,),
              ),
            ],
          ),
          Padding(
              padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
              child: Container(
                //color: Colors.grey,
                // width: 60,
                alignment: Alignment.topLeft,
                height: 40,
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
                        padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
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
                              //color:myData == index ? Colors.amber : Colors.transparent,
                              color: Colors.white,
                              offset: const Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ), //BoxShadow
                          ],
                        ),
                        child: GestureDetector(
                          child:   Center(
                            child: Text(_rent[index],style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                          ),
                          onTap: (){
                            setState(() {
                              if(isSelected=true) {
                                rent = _rent[index];
                              }
                            });
                          },
                        )
                    );
                  },
                ),
                /* child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5,left: 0,right: 1),
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
                        child: Text(" Properties  ",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.3,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("New projects",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Buy",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                        width: screenSize.width * 0.2,
                        height: 30,
                        padding: const EdgeInsets.only(top: 5),
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
                        child: Text("Rent",
                          style: TextStyle(color: Colors.black,
                              letterSpacing: 0.5,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                      ),
                  ],
                  ),*/
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
      width: 400,
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
        );
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=> MyApp()));
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
            size: 35,
          )
              : const Icon(
            Icons.favorite_border_outlined,
            color: Colors.red,
            size: 35,
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