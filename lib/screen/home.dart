import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drawerdemo/model/featuredmodel.dart';
import 'package:drawerdemo/screen/featured_detail.dart';
import 'package:drawerdemo/screen/filter.dart';
import 'package:drawerdemo/screen/new_projects.dart';
import 'package:drawerdemo/screen/product_detail.dart';
import 'package:drawerdemo/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];
  final TextEditingController _searchController = TextEditingController();
  FeaturedModel? featuredModel;

  @override
  void initState() {
    super.initState();
    getFilesApi();
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


  Future<void> getFilesApi() async {
    final response = await http.get(Uri.parse(
        "https://akarat.com/api/featured-properties"));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      FeaturedModel feature= FeaturedModel.fromJson(data);

      setState(() {
        featuredModel = feature ;

      });

    } else {
      //return FeaturedModel.fromJson(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          bottomNavigationBar: buildMyNavBar(context),
          //body: pages[pageIndex],
          backgroundColor: Colors.white,
          body:   SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    //logo 1
                    Container(
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.only(top: 25,left:115),
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
                  padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
                  child: Container(
                    width: 400,
                    height: 60,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(15.0),
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
                    // Use a Material design search bar
                    child: TextField(
                      textAlign: TextAlign.left,
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search for a locality,area or city',
                        hintStyle: TextStyle(color: Colors.grey),

                        // Add a clear button to the search bar
                        suffixIcon: IconButton(
                          alignment: Alignment.center,
                          icon: Icon(Icons.mic),
                          onPressed: () => _searchController.clear(),
                        ),

                        // Add a search icon or button to the search bar
                        prefixIcon: IconButton(
                          alignment: Alignment.center,
                          icon: Icon(Icons.search,color: Colors.red,),
                          onPressed: () {
                            // Perform the search here
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                //images gridview
                Row(
                  children: [
                    //logo 1
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                      },
                      child:  Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 5.0, top: 10, bottom: 0),

                        child: Container(
                            width: screenSize.width * 0.3,
                            height: 100,
                            padding: const EdgeInsets.only(top: 0),
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
                                Image.asset("assets/images/ak-rent-red.png"
                                  ,height: 40,),
                                Padding(padding: const EdgeInsets.only(left: 30,right: 20,top: 5),
                                  child:  Text("Property For Rent",style:
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                      },
                      child:
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 13.0, bottom: 0),
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
                                Image.asset("assets/images/ak-sale.png",height: 40,),
                                Padding(padding: const EdgeInsets.only(left: 30,right: 20,top: 5),
                                  child:  Text("Property For Sale",style:
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> New_Projects()));
                      },
                      child:
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 4.0, right: 5.0, top: 13.0, bottom: 0),
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
                                Image.asset("assets/images/ak-off-plan.png",height: 40,),
                                Padding(padding: const EdgeInsets.only(left: 30,right: 20,top: 5),
                                  child:  Text("Off-Plan-Properties",style:
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
                  ],
                ),
                Row(
                  children: [
                    //logo 1
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                      },
                      child:
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 5.0, top: 8, bottom: 0),
                        child: Container(
                            width: screenSize.width * 0.3,
                            height: 100,
                            padding: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(

                              // image: DecorationImage(
                              //   image: AssetImage("assets/images/04.png"),
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                      },
                      child:
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 8, bottom: 0),
                        child: Container(
                            width: screenSize.width * 0.3,
                            height: 100,
                            padding: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(

                              // image: DecorationImage(
                              //   image: AssetImage("assets/images/05.png"),
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
                                Image.asset("assets/images/city.png",height: 40,),
                                Padding(padding: const EdgeInsets.only(left: 25,right: 20,top: 5),
                                  child:  Text("Apartments",style:
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                      },
                      child:
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 8, bottom: 0),
                        child: Container(
                            width: screenSize.width * 0.3,
                            height: 100,
                            padding: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(

                              // image: DecorationImage(
                              //   image: AssetImage("assets/images/06.png"),
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
                                Image.asset("assets/images/villa-new.png",height: 40,),
                                Padding(padding: const EdgeInsets.only(left: 25,right: 20,top: 5),
                                  child:  Text("Villas",style:
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
                  ],
                ),
                //banner
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 12.0, bottom: 0),
                  child:
                  Container(
                    width: screenSize.width * 1.0,
                    height: 150,
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
                      ],),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 10,left: 00,right: 5),
                            child: Container(
                              width: 200,
                              height: 100,
                              padding: const EdgeInsets.only(top: 10,left: 10,right: 00),
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
                        Image.asset('assets/images/02.png',height: 145, width: screenSize.width * 0.36,),

                      ],
                    ),),),
                //  Text
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 10, bottom: 0),
                      child:  Text("1,738 Projects",style: TextStyle(
                        color: Colors.black,fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),textAlign: TextAlign.left,),
                    ),
                    Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 140.0, right: 10.0, top: 10, bottom: 0),
                            child:  Image.asset("assets/images/arrows 1.png")
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 2.0, right: 10.0, top: 10, bottom: 0),
                          child:  Text("Featured",style: TextStyle(
                            color: Colors.black,fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),textAlign: TextAlign.right,),
                        ),
                      ],
                    )

                  ],
                ),
                //Slider
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const ScrollPhysics(),
                  itemCount: featuredModel!.data!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if(featuredModel== null){
                      return Scaffold(
                      body: Center(child: CircularProgressIndicator()), // Show loading state
                    );
                    }
                    return SingleChildScrollView(
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Featured_Detail(data: '${featuredModel!.data![index].id}')));
                          },
                          child : Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0,top: 1,right: 5),
                              child: Column(
                                // spacing: 5,// this is the coloumn
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1.6,
                                    // this is the ratio
                                    child: CachedNetworkImage( // this is to fetch the image
                                      imageUrl: (featuredModel!.data![index].media![index].originalUrl.toString()),
                                      fit: BoxFit.cover,
                                      height: 100,
                                    ),
                                  ),
                                  Padding(padding: const EdgeInsets.only(top: 5),
                                    child: ListTile(
                                      title: Text(featuredModel!.data![index].title.toString(),style: TextStyle(
                                          fontWeight: FontWeight.bold,fontSize: 15,height: 1.4
                                      ),),
                                      subtitle: Text('${featuredModel!.data![index].price} AED',style: TextStyle(
                                          fontWeight: FontWeight.bold,fontSize: 18,height: 1.8
                                      ),),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 0),
                                        child:  Image.asset("assets/images/map.png",height: 14,),
                                      ),
                                      Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                        child: Text(featuredModel!.data![index].location.toString(),style: TextStyle(
                                            fontWeight: FontWeight.bold,fontSize: 13,height: 1.4,
                                            overflow: TextOverflow.visible
                                        ),),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(padding: const EdgeInsets.only(left: 30,top: 10,bottom: 15),
                                        child: ElevatedButton.icon(onPressed: (){},
                                            label: Text("call",style: TextStyle(
                                                color: Colors.black
                                            ),),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[50],
                                              alignment: Alignment.center,
                                              elevation: 1,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: EdgeInsets.symmetric(vertical: 1.0,horizontal: 40),
                                              textStyle: TextStyle(letterSpacing: 0.5,
                                                  color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            icon: Icon(Icons.call,color: Colors.red,)),
                                      ),
                                      // Text(product.description),
                                      Padding(padding: const EdgeInsets.only(left: 15,top: 10,bottom: 15),
                                        child: ElevatedButton.icon(onPressed: (){},
                                            label: Text("Watsapp",style: TextStyle(
                                                color: Colors.black
                                            ),),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[50],
                                              alignment: Alignment.center,
                                              elevation: 1,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: EdgeInsets.symmetric(vertical: 1.0,horizontal: 30),
                                              textStyle: TextStyle(letterSpacing: 0.5,
                                                  color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            icon: Icon(Icons.call,color: Colors.red,)),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),

                          ),

                        )

                    );
                  },
                ),
                //buttons
               /* Padding(
                  padding: const EdgeInsets.only(top: 12,left: 10,right: 10),
                  child: Container(
                    width: 400,
                    height: 55,
                    padding: const EdgeInsets.only(top: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(15.0),
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

                    child:  Row(
                      children: [
                        Padding(padding: const EdgeInsets.only(left: 30,top: 10,bottom: 10),
                          child: ElevatedButton.icon(onPressed: (){},
                              label: Text("call",style: TextStyle(
                                  color: Colors.black
                              ),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[50],
                                alignment: Alignment.center,
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.symmetric(vertical: 1.0,horizontal: 40),
                                textStyle: TextStyle(letterSpacing: 0.5,
                                    color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold
                                ),
                              ),
                              icon: Icon(Icons.call,color: Colors.red,)),
                        ),
                        // Text(product.description),
                        Padding(padding: const EdgeInsets.only(left: 15,top: 10,bottom: 10),
                          child: ElevatedButton.icon(onPressed: (){},
                              label: Text("Watsapp",style: TextStyle(
                                  color: Colors.black
                              ),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[50],
                                alignment: Alignment.center,
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.symmetric(vertical: 1.0,horizontal: 30),
                                textStyle: TextStyle(letterSpacing: 0.5,
                                    color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold
                                ),
                              ),
                              icon: Icon(Icons.call,color: Colors.red,)),
                        ),
                      ],
                    ),
                  ),
                ),*/
                //tab
                SizedBox(
                  height: 15,
                  width: 25,
                ),
              ],
            ),
          ),
        ));

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
                pageIndex = 0;
              });
            },
            icon: pageIndex == 0
                ? const Icon(
              Icons.home_filled,
              color: Colors.red,
              size: 30,
            )
                : const Icon(
              Icons.home_outlined,
              color: Colors.red,
              size: 30,
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