import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../model/favoritemodel.dart';
import '../model/togglemodel.dart';
import '../screen/home.dart';
import '../screen/login.dart';
import '../screen/product_detail.dart';

class Fav_Login extends StatefulWidget {

   Fav_Login({super.key,});

  @override
  State<Fav_Login> createState() => new _Fav_LoginState();
}
class _Fav_LoginState extends State<Fav_Login> {
  int pageIndex = 0;
  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];


  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;
  int? property_id ;
  ToggleModel? toggleModel;
  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();
  // Method to read data from shared preferences
  void readData() async {
    token = await prefManager.readStringFromPref();
    email = await prefManager.readStringFromPrefemail();
    result = await prefManager.readStringFromPrefresult();
    setState(() {
      isDataRead = true;
      getFilesApi(token);
    });
  }
  bool isFavorited = false;
  FavoriteModel? favoriteModel;

   @override
   void initState() {
     super.initState();
     readData();
     _loadFavorites();
   }

   Future<void> getFilesApi(token) async {
     final response = await http.get(Uri.parse("https://akarat.com/api/saved-property-list"),
       headers: <String, String>{'Authorization': 'Bearer $token',
         'Content-Type': 'application/json; charset=UTF-8',
       },
     );
     if (response.statusCode == 200) {
       Map<String, dynamic> jsonData = json.decode(response.body);
       FavoriteModel feature= FavoriteModel.fromJson(jsonData);

       setState(() {
         favoriteModel = feature ;

       });

     }
     else {
       //return FeaturedModel.fromJson(data);
     }
   }

  Set<int> favoriteProperties = {}; // Stores favorite property IDs

  void toggleFavorite(int propertyId) async {
    setState(() {
      if (favoriteProperties.contains(propertyId)) {
        favoriteProperties.remove(propertyId);
        getFilesApi(token);// Remove from favorites
      } else {
        favoriteProperties.add(propertyId); // Add to favorites
      }
    });
    await _saveFavorites();
    getFilesApi(token);
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


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        body: DefaultTabController(
          length: 2,
          child:  SingleChildScrollView(
              child: Column(
                  children: <Widget>[
                    Container(
                      height: screenSize.height*0.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(2.0),
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
                      child:  Stack(
                        // alignment: Alignment.topCenter,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 25,left: 10),
                            child: Container(
                              height: screenSize.height*0.07,
                              width: double.infinity,
                              // color: Color(0xFFEEEEEE),
                              child:   Row(
                                children: [GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
                                  },
                                  child:   Container(
                                    margin: const EdgeInsets.only(left: 10,top: 5,bottom: 0),
                                    height: 35,
                                    width: 35,
                                    padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
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
                                    child: Image.asset("assets/images/ar-left.png",
                                      width: 15,
                                      height: 15,
                                      fit: BoxFit.contain,),
                                  ),
                                ),
                                  SizedBox(
                                    width: screenSize.width*0.28,
                                  ),
                                  Padding(padding: const EdgeInsets.all(8.0),
                                    // child: Text(token,style: TextStyle(
                                    child: Text("Saved",style: TextStyle(
                                        fontWeight: FontWeight.bold,fontSize: 20
                                    ),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      height: screenSize.height*0.06,
                      width: screenSize.width*0.9,
                      // color: Colors.grey,
                      child:  TabBar(
                        padding:  EdgeInsets.only(top: 0,left: 10,right: 0),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 0,),
                        splashFactory: NoSplash.splashFactory,
                        indicatorWeight: 1.0,
                        labelColor: Colors.lightBlueAccent,
                        dividerColor: Colors.transparent,
                        indicatorColor: Colors.transparent,
                        tabAlignment: TabAlignment.center,
                        // onTap: (int index) => setState(() =>  screens[about_tb()]),
                        tabs: [
                          Container(
                            margin: const EdgeInsets.only(left: 0),
                            width: screenSize.width*0.41,
                            height: screenSize.height*0.045,
                            padding: const EdgeInsets.only(top: 10,),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                            child: Text('Searches',textAlign: TextAlign.center,style: TextStyle(
                                fontWeight: FontWeight.bold,fontSize: 15
                            ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            width: screenSize.width*0.41,
                            height: screenSize.height*0.045,
                            padding: const EdgeInsets.only(top: 10,),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                            child: Text('Favorites',textAlign: TextAlign.center,style: TextStyle(
                                fontWeight: FontWeight.bold,fontSize: 15
                            ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: const ScrollPhysics(),
                      // this give th length of item
                      itemCount: favoriteModel?.data?.length ?? 0,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        bool isFavorited = favoriteProperties.contains(favoriteModel!.data![index].id);
                        return SingleChildScrollView(
                            child: GestureDetector(
                              onTap: () {
                                String id = favoriteModel!.data![index].id.toString();
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    Product_Detail(data: id)));
                                //Navigator.push(context, MaterialPageRoute(builder: (context) => Blog_Detail(data:blogModel!.data![index].id.toString())));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0,right: 5,top: 0,bottom: 15),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 20,
                                  shadowColor: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0,
                                        top: 0,
                                        right: 5,
                                        bottom: 10),
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
                                            imageUrl: (favoriteModel!
                                                .data![index].image
                                                .toString()),
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
                                                  property_id=favoriteModel!.data![index].id;
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
                                          padding: const EdgeInsets
                                              .only(top: 3),
                                          child: ListTile(
                                            title: Text(favoriteModel!
                                                .data![index].title
                                                .toString(),
                                              style: TextStyle(
                                                  fontSize: 16,height: 1.4
                                              ),),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(top: 3.0),
                                              child: Text('${favoriteModel!.data![index].price} AED',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,fontSize: 22,height: 1.4
                                                ),),
                                            ),
                                          ),
                                        ),

                                        Row(
                                          children: [
                                            Padding(padding: const EdgeInsets.only(left: 15,right: 5,top: 0,bottom: 0),
                                              child:  Image.asset("assets/images/map.png",height: 14,),
                                            ),
                                            Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                              child: Text(favoriteModel!.data![index].address.toString(),style: TextStyle(
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
                                                child: Text(favoriteModel!.data![index].bedrooms.toString())
                                            ),
                                            Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 5),
                                              child: Image.asset("assets/images/bath.png",height: 13,),
                                            ),
                                            Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                                child: Text(favoriteModel!.data![index].bathrooms.toString())
                                            ),
                                            Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 5),
                                              child: Image.asset("assets/images/messure.png",height: 13,),
                                            ),
                                            Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                                child: Text(favoriteModel!.data![index].squareFeet.toString())
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(padding: const EdgeInsets.only(left: 30,top: 10,bottom: 5),
                                              child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    String phone = 'tel:${favoriteModel!.data![index].title}';
                                                    try {
                                                      final bool launched = await launchUrlString(
                                                        phone,
                                                        mode: LaunchMode.externalApplication, // ✅ Force external
                                                      );
                                                      if (!launched) {
                                                        print("❌ Could not launch dialer");
                                                      }
                                                    } catch (e) {
                                                      print("❌ Exception: $e");
                                                    }
                                                  },
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
                                            Padding(padding: const EdgeInsets.only(left: 15,top: 10,bottom: 5),
                                              child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final phone = favoriteModel!.data![index].title; // without plus
                                                    final message = Uri.encodeComponent("Hello");
                                                    // final url = Uri.parse("https://api.whatsapp.com/send/?phone=971503440250&text=Hello");
                                                    // final url = Uri.parse("https://wa.me/?text=hello");
                                                    final url = Uri.parse("https://api.whatsapp.com/send/?phone=%2B$phone&text&type=phone_number&app_absent=0");

                                                    if (await canLaunchUrl(url)) {
                                                      try {
                                                        final launched = await launchUrl(
                                                          url,
                                                          mode: LaunchMode.externalApplication, // 💥 critical on Android 15
                                                        );

                                                        if (!launched) {
                                                          print("❌ Could not launch WhatsApp");
                                                        }
                                                      } catch (e) {
                                                        print("❌ Exception: $e");
                                                      }
                                                    } else {
                                                      print("❌ WhatsApp not available or URL not supported");
                                                    }
                                                  },
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
          ),

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

               Navigator.push(context, MaterialPageRoute(builder: (context)=> MyApp()));

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
               child: Icon(Icons.favorite_border,color: Colors.red,)
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
               child: Icon(Icons.add_location_rounded,color: Colors.red,)

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
               child: Icon(Icons.chat,color: Colors.red,)

           ),
           IconButton(
             enableFeedback: false,
             onPressed: () {

                  Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

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