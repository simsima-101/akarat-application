import 'dart:convert';
import 'package:drawerdemo/model/api2model.dart';
import 'package:drawerdemo/screen/home.dart';
import 'package:drawerdemo/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:http/http.dart' as http;

import '../utils/api2cardscreen.dart';

void main(){
  runApp(const FliterList());

}

class FliterList extends StatelessWidget {
  const FliterList({Key ? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FliterListDemo(),
    );
  }
}
class FliterListDemo extends StatefulWidget {
  @override
  _FliterListDemoState createState() => _FliterListDemoState();
}
class _FliterListDemoState extends State<FliterListDemo> {
  int pageIndex = 0;

  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

  final TextEditingController _searchController = TextEditingController();
  RangeValues _currentRangeValues = const RangeValues(0, 80);

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        products = jsonData.map((data) => Product.fromJson(data)).toList();
      });
    } else {
      // Handle error if needed
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: buildMyNavBar(context),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
         // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //Searchbar
              Padding(
                padding: const EdgeInsets.only(top: 40,left: 10,right: 10),
                child: Container(
                  width: 400,
                  height: 60,
                  padding: const EdgeInsets.only(top: 10),
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
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Neighborhood or Building',
                      hintStyle: TextStyle(color: Colors.grey,fontSize: 15,
                          letterSpacing: 0.5),

                      // Add a clear button to the search bar
                      suffixIcon: IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: () => _searchController.clear(),
                      ),

                      // Add a search icon or button to the search bar
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search,color: Colors.red,),
                        onPressed: () {
                          // Perform the search here
                        },
                      ),
                    ),
                  ),
                ),
              ),

              //filter
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 10,right: 10),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  height: 35,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      //text
                      Padding(
                        padding: const EdgeInsets.only(
                            left:0.0,top: 7.0),

                        child: Center(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Icon(
                                  Icons.filter_alt_outlined,color: Colors.red,)
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left:1.0),
                                child: InkWell(
                                    onTap: (){
                                      //   print('hello');
                                    },
                                    child: Text('Filters', style: TextStyle(fontSize: 14, color: Colors.black),)),
                              )
                            ],
                          ),
                        ),

                      ),
                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                     child:  Container(
                        width: 70,
                        height: 10,
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
                      child: Row(
                        children: [
                          Text(" Buy"),
                          Container(
                            width: 10,
                          ),
                          Icon(Icons.keyboard_arrow_down,color: Colors.black,)
                        ],
                      ),
                      ),
                      ),
                      //all residential
                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child:  Container(
                          width: 130,
                          height: 10,
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
                          child: Row(
                            children: [
                              Text(" All Residential"),
                              Container(
                                width: 5,
                              ),
                              Icon(Icons.keyboard_arrow_down,color: Colors.black,)
                            ],
                          ),
                        ),
                      ),

                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child:  Container(
                          width: 120,
                          height: 10,
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
                          child: Row(
                            children: [
                              Text(" Price Range"),
                              Container(
                                width: 10,
                              ),
                              Icon(Icons.keyboard_arrow_down,color: Colors.black,)
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child:  Container(
                          width: 70,
                          height: 10,
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
                          child: Row(
                            children: [
                              Text(" Buy"),
                              Container(
                                width: 10,
                              ),
                              Icon(Icons.keyboard_arrow_down,color: Colors.black,)
                            ],
                          ),
                        ),
                      ),

                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child:  Container(
                          width: 70,
                          height: 10,
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
                          child: Row(
                            children: [
                              Text(" Buy"),
                              Container(
                                width: 10,
                              ),
                              Icon(Icons.keyboard_arrow_down,color: Colors.black,)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),

              //toggle
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 20, bottom: 0),
                child: Container(
                  width: 400,
                  height: 32,
                  padding: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          1.5,
                          1.5,
                        ),
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.5, 0.5),
                        blurRadius: 1.5,
                        spreadRadius: 1.5,
                      ), //BoxShadow
                    ],
                  ),
                  child: Row(
                    children: [
                      Text("    Show verified properties first",style: TextStyle(
                        letterSpacing: 0.5
                      ),),
                      Container(
                        width: 80,
                      ),
                      SlidingSwitch(value: true,
                          onChanged: (value) {
                          },
                          onTap: (){},
                          onDoubleTap: (){},
                          onSwipe: (){},
                      height: 20,
                      width: 45,colorOn: Colors.blue,
                      colorOff: Colors.grey,contentSize: 10,textOff: "",textOn: "",)
                    ],
                  ),
                ),
              ),
              //filter
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 10,right: 10),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  height: 35,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                     //items
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10,left: 10),
                        child:  Container(
                          width: 70,
                          height: 10,
                          padding: const EdgeInsets.only(top: 2,),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 0,
                              ),
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
                          child:
                              Text("All",textAlign: TextAlign.center,style:
                                TextStyle(letterSpacing: 0.5)),

                        ),
                      ),
                      //all residential
                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child:  Container(
                          width: 90,
                          height: 10,
                          padding: const EdgeInsets.only(top: 2,),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 0,
                              ),
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

                             child:  Text(" Ready",textAlign: TextAlign.center,
                                 style:
                                 TextStyle(letterSpacing: 0.5)),

                        ),
                      ),

                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child:  Container(
                          width: 100,
                          height: 10,
                          padding: const EdgeInsets.only(top: 2,),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 0,
                              ),
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
                          child:
                              Text(" Off-Plan",textAlign: TextAlign.center,
                                  style:
                                  TextStyle(letterSpacing: 0.5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
             new ListView.builder(
                   // this give th length of item
                   itemCount: products.length,
               shrinkWrap: true,
                   itemBuilder: (context, index) {
                     // here we card the card widget
                     // which is in utils folder
                     return ProductCard(product: products[index]);
                   },
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