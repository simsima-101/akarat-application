import 'package:drawerdemo/screen/home.dart';
import 'package:drawerdemo/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

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
  final double _min = 2.0;
  final double _max = 30.0;
  final SfRangeValues _values = SfRangeValues(12.5, 20.5);
  late RangeController _rangeController;


  @override
  void initState() {
    super.initState();
    _rangeController = RangeController(
        start: _values.start,
        end: _values.end);
  }

  @override
  void dispose() {
    _rangeController.dispose();
    super.dispose();
  }



  final List<Data> chartData = <Data>[
    Data(x: 2.0, y: 9.2),
    Data(x: 3.0, y: 23.4),
    Data(x: 4.0, y: 4.13),
    Data(x: 5.0, y: 15.6),
    Data(x: 6.0, y: 6.3),
    Data(x: 7.0, y: 7.12),
    Data(x: 8.0, y: 18.9),
    Data(x: 9.0, y: 9.8),
    Data(x: 10.0, y:19.7),
    Data(x: 11.0, y: 11.11),
    Data(x: 12.0, y: 12.5),
    Data(x: 13.0, y: 13.7),
    Data(x: 14.0, y: 20.8),
    Data(x: 15.0, y: 6.7),
    Data(x: 16.0, y: 16.7),
    Data(x: 17.0, y: 17.7),
    Data(x: 18.0, y: 22.7),
    Data(x: 19.0, y: 19.7),
    Data(x: 20.0, y: 11.7),
    Data(x: 21.0, y: 20.7),
    Data(x: 22.0, y: 9.7),
    Data(x: 23.0, y: 8.7),
    Data(x: 24.0, y: 12.7),
    Data(x: 25.0, y: 15.7),
    Data(x: 26.0, y: 26.7),
    Data(x: 27.0, y: 14.7),
    Data(x: 28.0, y: 20.7),
    Data(x: 29.0, y: 15.7),
    Data(x: 30.0, y: 13.7),
  ];


  int pageIndex = 0;

  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: buildMyNavBar(context),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          //filter
          Padding(
            padding: const EdgeInsets.only(top: 30,left: 10,right: 10),
            child: Container(
              width: 400,
              height: 60,
              padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeDemo()));
                  },
                  child:  Icon(Icons.close,color: Colors.red,),
                ),
                Container(
                  width: 120.0,
                ),
                Text("Filters",textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,fontSize: 20.0,fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),),
                Container(
                  width: 120.0,
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
              child: Text("Reset",textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.red,fontSize: 16.0,fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,),),
            ),
              ],
            )
            ),
          ),

          //properties
          Padding(
            padding: const EdgeInsets.only(top: 10,left: 15,right: 10),
              child: Row(
                children: [
                  Container(
                    width: 85,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Properties",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5,fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 105,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("New projects",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 70,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Buy",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5,fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 70,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Rent",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5,fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,),
                  ),
                ],
                )
            ),
          //Searchbar
          Padding(
            padding: const EdgeInsets.only(top: 15,left: 10,right: 10),
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
                      0.5,
                      0.5,
                    ),
                    blurRadius: 1.0,
                    spreadRadius: 0.5,
                  ), //BoxShadow
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ), //BoxShadow
                ],),
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
                  width: 115,
                  height: 100,
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          0.5,
                          0.5,
                        ),
                        blurRadius: 1.0,
                        spreadRadius: 0.5,
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
                    left: 5.0, right: 5.0, top:5.0, bottom: 0),
                child: Container(
                  width: 115,
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
                          0.5,
                          0.5,
                        ),
                        blurRadius: 1.0,
                        spreadRadius: 0.5,
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
                    left: 5.0, right: 10.0, top: 5.0, bottom: 0),
                child: Container(
                  width: 115,
                  height: 100,
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(

                    // image: DecorationImage(
                    //   image: AssetImage("assets/images/03.png"),
                    // ),
                    borderRadius: BorderRadiusDirectional.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          0.5,
                          0.5,
                        ),
                        blurRadius: 1.0,
                        spreadRadius: 0.5,
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
              padding: const EdgeInsets.only(top: 10,left: 15,right: 5),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("All Residential",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5,fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 90,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Apartment",
                      style: TextStyle(color: Colors.black,letterSpacing: 0.5
                      ,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 50,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Villa",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 90,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Townhouse",
                      style: TextStyle(color: Colors.black,letterSpacing: 0.5,
                      fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  ),
                ],
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
                        0.5,
                        0.5,
                      ),
                      blurRadius: 1.0,
                      spreadRadius: 0.5,
                    ), //BoxShadow
                    BoxShadow(
                      color: Colors.white,
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ), //BoxShadow
                  ],),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    /* border: OutlineInputBorder(
                       ),*/
                    border: InputBorder.none,
                    hintText: '0',hintStyle: TextStyle(
                      color: Colors.grey,fontSize: 15)
                  ),
                  textAlign: TextAlign.left,
                ),
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
                        0.5,
                        0.5,
                      ),
                      blurRadius: 1.0,
                      spreadRadius: 0.5,
                    ), //BoxShadow
                    BoxShadow(
                      color: Colors.white,
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ), //BoxShadow
                  ],),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    /* border: OutlineInputBorder(
                       ),*/
                    border: InputBorder.none,
                    hintText: '0',hintStyle: TextStyle(
                      color: Colors.grey,fontSize: 15)
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              ]
        )
      ),
  //rangeslider
          Padding(padding: const EdgeInsets.only(top: 25.0,left: 1,bottom: 15),
           child:  SfRangeSelector(
             min: _min,
             max: _max,
             interval: 1,
             enableTooltip: true,
             shouldAlwaysShowTooltip: true,
             initialValues: _values,
             child: SizedBox(
               height: 70,
               width: 400,
               child: SfCartesianChart(
                 plotAreaBorderColor: Colors.transparent,
                 margin: const EdgeInsets.all(0),
                 primaryXAxis: NumericAxis(minimum: _min, maximum: _max,
                   isVisible: false,),
                 primaryYAxis: NumericAxis(isVisible: false),
                 plotAreaBorderWidth: 0,
                 plotAreaBackgroundColor: Colors.transparent,
                 series: <ColumnSeries<Data, double>>[
                   ColumnSeries<Data, double>(
                     trackColor: Colors.transparent,
                     dataSource: chartData,
                     selectionBehavior: SelectionBehavior(
                       unselectedOpacity: 0,
                       selectedOpacity: 1.5,unselectedColor: Colors.transparent,
                       selectionController: _rangeController,
                     ),
                     xValueMapper: (Data sales, int index) => sales.x,
                     yValueMapper: (Data sales, int index) => sales.y,
                     pointColorMapper: (Data sales, int index) {
                       return const Color.fromRGBO(0, 178, 206, 1);
                     },
                     dashArray: const <double>[5, 3],
                     animationDuration: 0,
                     borderWidth: 0,
                   ),
                 ],
               ),
             ),
           ),
          ),

          Row(
            children: [
              Padding(padding: const EdgeInsets.only(top: 25.0,left: 15,bottom: 15),
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
              padding: const EdgeInsets.only(top: 5,left: 15,right: 10),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Studio",
                      style: TextStyle(color: Colors.black,letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 27,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("1",
                      style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 27,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("2",
                      style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 27,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("3",
                      style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 27,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("4",
                      style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 27,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("5",
                      style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 27,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("6",
                      style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 27,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("7",
                      style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 27,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("8+",
                      style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
                  ),
                ],
              )
          ),
Row(
  children: [
    Padding(padding: const EdgeInsets.only(top: 25.0,left: 15,bottom: 15),
      child:  Text("Bathrooms",
        style: TextStyle(
            color: Colors.black,fontSize: 18.0,fontWeight: FontWeight.w500,
            letterSpacing: 0.5),
        textAlign: TextAlign.left,),
    ),
  ],
),

      Padding(
        padding: const EdgeInsets.only(top: 5,left: 15,right: 10),
        child: Row(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 27,
                height: 30,
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(6.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          0.5,
                          0.5,
                        ),
                        blurRadius: 1.0,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ]),
                child: Text("1",
                  style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
              ),
              Container(
                width: 10,
              ),
              Container(
                width: 27,
                height: 30,
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(6.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          0.5,
                          0.5,
                        ),
                        blurRadius: 1.0,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ]),
                child: Text("2",
                  style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
              ),
              Container(
                width: 10,
              ),
              Container(
                width: 27,
                height: 30,
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(6.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          0.5,
                          0.5,
                        ),
                        blurRadius: 1.0,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ]),
                child: Text("3",
                  style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
              ),
              Container(
                width: 10,
              ),
              Container(
                width: 27,
                height: 30,
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(6.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          0.5,
                          0.5,
                        ),
                        blurRadius: 1.0,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ]),
                child: Text("4",
                  style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
              ),
              Container(
                width: 10,
              ),
              Container(
                width: 27,
                height: 30,
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(6.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          0.5,
                          0.5,
                        ),
                        blurRadius: 1.0,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ]),
                child: Text("5",
                  style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
              ),
              Container(
                width: 10,
              ),
              Container(
                width: 27,
                height: 30,
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(6.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          0.5,
                          0.5,
                        ),
                        blurRadius: 1.0,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ]),
                child: Text("6+",
                  style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),
              ),
              ]
        ),
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
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ],),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          /* border: OutlineInputBorder(
                       ),*/
                          border: InputBorder.none,
                          hintText: '0',hintStyle: TextStyle(
                            color: Colors.grey,fontSize: 15)
                        ),
                        textAlign: TextAlign.left,
                      ),
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
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ],),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          /* border: OutlineInputBorder(
                       ),*/
                          border: InputBorder.none,
                          hintText: '0',hintStyle: TextStyle(color: Colors.grey,
                            fontSize: 15)
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ]
              )
          ),
          //rangeslider
          Padding(padding: const EdgeInsets.only(top: 25.0,left: 1,bottom: 15),
           child: SfRangeSelector(
             min: _min,
             max: _max,
             interval: 1,
             enableTooltip: true,
             shouldAlwaysShowTooltip: true,
             initialValues: _values,
             child: SizedBox(
               height: 70,
               width: 400,
               child: SfCartesianChart(
                 plotAreaBorderColor: Colors.transparent,
                 margin: const EdgeInsets.all(0),
                 primaryXAxis: NumericAxis(minimum: _min, maximum: _max,
                   isVisible: false,),
                 primaryYAxis: NumericAxis(isVisible: false),
                 plotAreaBorderWidth: 0,
                 plotAreaBackgroundColor: Colors.transparent,
                 series: <ColumnSeries<Data, double>>[
                   ColumnSeries<Data, double>(
                     trackColor: Colors.transparent,
                     // color: Color.fromARGB(255, 126, 184, 253),
                     dataSource: chartData,
                     selectionBehavior: SelectionBehavior(
                       unselectedOpacity: 0,
                       selectedOpacity: 1.5,unselectedColor: Colors.transparent,
                       selectionController: _rangeController,
                     ),
                     xValueMapper: (Data sales, int index) => sales.x,
                     yValueMapper: (Data sales, int index) => sales.y,
                     pointColorMapper: (Data sales, int index) {
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
              padding: const EdgeInsets.only(top: 5,left: 15,right: 10),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("All",
                      style: TextStyle(color: Colors.black
                      ,letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 80,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Furnished",
                      style: TextStyle(color: Colors.grey,
                          letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 100,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Unfurnished",
                      style: TextStyle(color: Colors.grey,
                          letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                ],
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

          Padding(padding: const EdgeInsets.only(top: 5,left: 15,right: 10),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 1),
              height: 30,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Maids Room",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 70,
                    height: 30,
                     padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Study",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 150,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Central A/C & Heating",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 70,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Balcony",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 100,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Private Garden",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),

                ],
              ),
            ),

          ),

//view
Row(
  children: [
    Padding(
      padding: const EdgeInsets.only(
          left: 15.0, top: 5, bottom: 0),
      child:  Text("View all",style: TextStyle(
        color: Colors.blue,fontSize: 11

      ),textAlign: TextAlign.left,),
    ),
    Padding(
        padding: const EdgeInsets.only(
            left: 1.0, right: 10.0, top: 5, bottom: 0),
       child: Icon(Icons.arrow_forward_outlined,color: Colors.red,size: 15,),
    ),
  ],
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
                        0.5,
                        0.5,
                      ),
                      blurRadius: 1.0,
                      spreadRadius: 0.5,
                    ), //BoxShadow
                    BoxShadow(
                      color: Colors.white,
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ), //BoxShadow
                  ],),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
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
              padding: const EdgeInsets.only(top: 5,left: 15,right: 10),
              child: Row(
               // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Yearly",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 80,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Bi-Yearly",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 85,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Quarterly",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    width: 80,
                    height: 30,
                    padding: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.5,
                              0.5,
                            ),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ]),
                    child: Text("Monthly",
                      style: TextStyle(color: Colors.black,
                          letterSpacing: 0.5),textAlign: TextAlign.center,),
                  ),
                ],
              )
          ),
          Container(
            height: 150,
          ),
GestureDetector(
  onTap: (){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> FliterListDemo()));
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
              0.5,
              0.5,
            ),
            blurRadius: 1.0,
            spreadRadius: 0.5,
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