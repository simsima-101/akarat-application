import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/projectmodel.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/property_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/togglemodel.dart';
import '../utils/shared_preference_manager.dart';
import 'login.dart';

void main(){
  runApp(const New_Projects());
}
class New_Projects extends StatelessWidget {
  const New_Projects({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: New_ProjectsDemo(),
    );
  }
}

class New_ProjectsDemo extends StatefulWidget {
  @override
  _New_ProjectsDemoState createState() => _New_ProjectsDemoState();
}
class _New_ProjectsDemoState extends State<New_ProjectsDemo> {
  final TextEditingController _searchController = TextEditingController();
  int pageIndex = 0;

  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];
  bool isDataRead = false;
  bool isFavorited = false;
  ProjectModel? projectModel;
  ToggleModel? toggleModel;
  int? property_id ;
  String token = '';
  String email = '';
  String result = '';

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
    getFilesApi();
    readData();
    _loadFavorites();
  }

  Future<void> getFilesApi() async {
    final response = await http.get(Uri.parse("https://akarat.com/api/new-projects"));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ProjectModel feature= ProjectModel.fromJson(data);

      setState(() {
        projectModel = feature ;

      });

    } else {
      //return FeaturedModel.fromJson(data);
    }
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
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: buildMyNavBar(context),
        body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          Row(
            children: [
              Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 50,left:15),
                height: 30,
                width: 30,
                padding: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(15.0),
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

                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> MyApp()));
                  },
                  child:  Icon(Icons.arrow_back,color: Colors.red,
                )

                ),
              ),
              //logo2
              Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 52,left: 80),
                height: 30,
                width: 125,
                decoration: BoxDecoration(

                ),
                child: Text("New Projects",style: TextStyle(
                    color: Colors.black,letterSpacing: 0.5,fontSize: 18,
                    fontWeight: FontWeight.bold,
                ),textAlign: TextAlign.center,),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 15,left: 15,right: 15),
            padding: const EdgeInsets.only(top: 5,left: 5,right: 10),
            height: 50,
            width: double.infinity,
            //color: Colors.grey,
            child: Text("Find off-plan development and everything you need to "
                "know to invest in UAE's real estate market",style: TextStyle(letterSpacing: 0.5,),),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 20,right: 15),
                child: Container(
                  width: screenSize.width*0.9,
                  height: 50,
                 // color: Colors.grey,
                  padding: const EdgeInsets.only(top: 5),
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
                    ],),
                  // Use a Material design search bar
                  child: TextField(
                    textAlign: TextAlign.left,
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search new projects by location ',
                      hintStyle: TextStyle(color: Colors.grey,fontSize: 15,
                          letterSpacing: 0.5),
                      // Add a search icon or button to the search bar
                      prefixIcon: IconButton(
                        alignment: Alignment.topLeft,
                        icon: Icon(Icons.location_on,color: Colors.red,),
                        onPressed: () {
                          // Perform the search here
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.only(top: 20,left: 10,right: 190),
           child: Text("Latest Projects in Dubai",textAlign: TextAlign.left,
           style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
         ),
          Container(
            margin: const EdgeInsets.only(top: 15,left: 20,right: 15),
            padding: const EdgeInsets.only(top: 5,left: 5,right: 10),
            height: 50,
            width: double.infinity,
            //color: Colors.grey,
            child: Text("Find off-plan development and everything you need to "
                "know to invest in UAE's real estate market",style: TextStyle(letterSpacing: 0.5,),),
          ),
          ListView.builder(
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
            // this give th length of item
            itemCount: projectModel?.data?.length  ?? 0,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              bool isFavorited = favoriteProperties.contains(projectModel!.data![index].id);
              return SingleChildScrollView(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          Property_Detail(data:projectModel!.data![index].id.toString())));
                    },
                    child : Padding(
                      padding: const EdgeInsets.only(left: 5.0,right: 5,top: 0,bottom: 5),
                      child: Card(
                        color: Colors.white,
                        elevation: 20,
                        shadowColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0,top: 1,right: 5,bottom: 15),
                          child: Column(
                            // spacing: 5,// this is the coloumn
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1.4,
                                          // this is the ratio
                                          child: CachedNetworkImage( // this is to fetch the image
                                            imageUrl: (projectModel!.data![index].media![index].originalUrl.toString()),
                                            fit: BoxFit.contain,

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
                                                  property_id=projectModel!.data![index].id;
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
                              Padding(padding: const EdgeInsets.only(top: 5),
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.only(top: 5.0,bottom: 5),
                                    child: Text(projectModel!.data![index].title.toString(),
                                      style: TextStyle(
                                          fontSize: 16,height: 1.4
                                      ),),
                                  ),
                                  subtitle: Text('${projectModel!.data![index].price} AED',
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
                                    child:  Image.asset("assets/images/map.png",height: 14,),
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                    child: Text(projectModel!.data![index].location.toString(),style: TextStyle(
                                        fontSize: 13,height: 1.4,
                                        overflow: TextOverflow.visible
                                    ),),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(padding: const EdgeInsets.only(left: 15,right: 5,top: 5),
                                    child: Image.asset("assets/images/bed.png",height: 13,),
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                      child: Text(projectModel!.data![index].bedrooms.toString())
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 5),
                                    child: Image.asset("assets/images/bath.png",height: 13,),
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                      child: Text(projectModel!.data![index].bathrooms.toString())
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 5),
                                    child: Image.asset("assets/images/messure.png",height: 13,),
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                      child: Text(projectModel!.data![index].squareFeet.toString())
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(padding: const EdgeInsets.only(left: 30,top: 20,bottom: 15),
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
                                  Padding(padding: const EdgeInsets.only(left: 15,top: 20,bottom: 15),
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
                                        icon: Image.asset("assets/images/whats.png",height: 20,)
                                    ),
                                  ),
                                ],
                              ),
                            /*  Row(

                                children: [
                                  Padding(padding: const EdgeInsets.only(left: 1,right: 0,top: 0,bottom: 0),
                                      child:  Icon(Icons.circle,color: Colors.red,size: 12,)
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 1,right: 5,top: 0,bottom: 0),
                                    child:  Text(blogModel!.data![index].readingTime.toString(),
                                      style: TextStyle(
                                          color: Colors.grey
                                      ),),
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 10,right: 0,top: 0,bottom: 0),
                                      child:  Icon(Icons.circle,color: Colors.red,size: 12,)
                                  ),

                                  Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0,bottom: 0),
                                    child: Text("Published:"+blogModel!.data![index].publishedDate.toString(),
                                      style: TextStyle(color: Colors.grey
                                      ),),
                                  ),
                                ],
                              ),*/
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
          Container(
              margin: const EdgeInsets.only(left: 40),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
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
              child: Icon(Icons.call_outlined,color: Colors.red,)
          ),

          Container(
              margin: const EdgeInsets.only(left: 1),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
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
              child: Image.asset("assets/images/whats.png",height: 20,)

          ),
          Container(
              margin: const EdgeInsets.only(left: 1,right: 40),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
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
              child: Icon(Icons.mail,color: Colors.red,)

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