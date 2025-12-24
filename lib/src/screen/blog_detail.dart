//
// import 'dart:convert';
//
// import 'package:Akarat/screen/shimmer.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:Akarat/model/blogdetailmodel.dart';
// import 'package:Akarat/screen/blog.dart';
// import 'package:Akarat/screen/home.dart';
// import 'package:Akarat/screen/my_account.dart';
// import 'package:Akarat/screen/profile_login.dart';
// import 'package:Akarat/utils/shared_preference_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class Blog_Detail extends StatefulWidget {
//   const Blog_Detail({super.key, required this.data});
//   final String data;
//
//   @override
//   State<Blog_Detail> createState() => _Blog_DetailDemoState();
// }
//
// class _Blog_DetailDemoState extends State<Blog_Detail> {
//
//   int pageIndex = 0;
//   String token = '';
//   String email = '';
//   String result = '';
//   bool isDataRead = false;
//   // Create an object of SharedPreferencesManager class
//   SharedPreferencesManager prefManager = SharedPreferencesManager();
//   // Method to read data from shared preferences
//   void readData() async {
//     token = await prefManager.readStringFromPref();
//     email = await prefManager.readStringFromPrefemail();
//     result = await prefManager.readStringFromPrefresult();
//     setState(() {
//       isDataRead = true;
//     });
//   }
//
//   BlogDetailModel? blogDetailModel;
//   @override
//   void initState() {
// readData();
//     fetchProducts(widget.data);
//   }
//
//
//   Future<void> fetchProducts(dynamic data) async {
//     final prefs = await SharedPreferences.getInstance();
//     final cacheKey = 'blog_detail_$data';
//     final cacheTimeKey = 'blog_detail_time_$data';
//     final now = DateTime.now().millisecondsSinceEpoch;
//     final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;
//
//     // Use cached version if it's less than 6 hours old
//     if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
//       final cachedData = prefs.getString(cacheKey);
//       if (cachedData != null) {
//         final jsonData = json.decode(cachedData);
//         final cachedModel = BlogDetailModel.fromJson(jsonData);
//         setState(() {
//           blogDetailModel = cachedModel;
//         });
//         debugPrint("📦 Loaded blog detail from cache.");
//         return;
//       }
//     }
//
//     // Fetch from API if no cache or cache is expired
//     try {
//       final response = await http
//           .get(Uri.parse('https://akarat.com/api/blog/$data'))
//           .timeout(const Duration(seconds: 10));
//
//       debugPrint("Status Code: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         final parsedModel = BlogDetailModel.fromJson(jsonData);
//
//         // Save to cache
//         await prefs.setString(cacheKey, json.encode(jsonData));
//         await prefs.setInt(cacheTimeKey, now);
//
//         if (mounted) {
//           setState(() {
//             blogDetailModel = parsedModel;
//           });
//         }
//
//         debugPrint("📖 Reading Time: ${blogDetailModel?.data?.readingTime}");
//       } else {
//         debugPrint("❌ Blog Detail API failed: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("🚨 Blog Detail API error: $e");
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     Size screenSize = MediaQuery.sizeOf(context);
//     if (blogDetailModel == null) {
//       return Scaffold(
//         body: ListView.builder(
//               itemCount: 5,
//               itemBuilder: (context, index) => const ShimmerCard(),) // Show loading state
//       // Show loading state
//       );
//     }
//     return Scaffold(
//         backgroundColor: Colors.white,
//       bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
//       appBar: AppBar(
//         title: const Text(
//             "Blog", style: TextStyle(color: Colors.black,
//             fontWeight: FontWeight.bold)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.red),
//           onPressed: ()async {
//             setState(() {
//               Navigator.of(context).pop();
//             });
//           },
//         ),
//         centerTitle: true,
//         backgroundColor: Color(0xFFFFFFFF),
//         iconTheme: const IconThemeData(color: Colors.red),
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//     child: Column(
//     children: <Widget>[
//       Padding(
//         padding: const EdgeInsets.only(top: 10.0),
//         child: Container(
//           height: 50,
//           width: double.infinity,
//           decoration: BoxDecoration(
//               shape: BoxShape.rectangle,
//               borderRadius: BorderRadiusDirectional.circular(6.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey,
//                   offset: const Offset(
//                     0.5,
//                     0.5,
//                   ),
//                   blurRadius: 1.0,
//                   spreadRadius: 0.5,
//                 ), //BoxShadow
//                 BoxShadow(
//                   color: Colors.white,
//                   offset: const Offset(0.0, 0.0),
//                   blurRadius: 0.0,
//                   spreadRadius: 0.0,
//                 ), //BoxShadow
//               ]),
//           child: Row(
//             children: [
//               /*Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
//                 child: Icon(Icons.search_rounded,color: Colors.red,size: 40,),
//               ),*/ Padding(padding: const EdgeInsets.only(left: 20,top: 0,right: 0),
//                   child: Image.asset("assets/images/app_icon.png",height: 35,)
//               ), Padding(padding: const EdgeInsets.only(left: 5,top: 0,right: 0),
//                   child: Image.asset("assets/images/logo-text.png",height: 30,)
//               ), /*Padding(padding: const EdgeInsets.only(left: 75,top: 0,right: 10),
//                 child: Icon(Icons.dehaze,color: Colors.red,size: 40,),
//               ),*/
//             ],
//           ),
//         ),
//       ),
//       Padding(padding: const EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 0),
//       child: Container(
//         height: screenSize.height*0.25,
//           width: double.infinity,
//           child: CachedNetworkImage( // this is to fetch the image
//             imageUrl: (blogDetailModel!.data!.image.toString()),
//             fit: BoxFit.fill,
//
//           ),),
//       ),
//       Padding(padding: const EdgeInsets.only(left: 10,right: 0,top: 10),
//       child: Container(
//         height: screenSize.height*0.07,
//         width: screenSize.width*1,
//       // color: Colors.grey,
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Text(blogDetailModel!.data!.translations!.en!.title.toString(),
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,fontSize: 18
//                 ),textAlign: TextAlign.left,),
//                 Text(""),
//               ],
//             ),
//             Row(
//               children: [
//                 Padding(padding: const EdgeInsets.only(left: 5,top: 10,right: 0,bottom: 0),
//                   child: Image.asset("assets/images/dot.png",height: 8,)
//                 ), Padding(padding: const EdgeInsets.only(left: 10,top: 8,right: 0,bottom: 0),
//                   child: Text(blogDetailModel!.data!.readingTime.toString(),style: TextStyle(
//                     fontSize: 12,color: Colors.grey
//                   ),)
//                 ), Padding(padding: const EdgeInsets.only(left: 30,top: 10,right: 0,bottom: 0),
//                   child: Image.asset("assets/images/dot.png",height: 10,)
//                 ), Padding(padding: const EdgeInsets.only(left: 10,top: 10,right: 0,bottom: 0),
//                     child: Text("Published:"+blogDetailModel!.data!.publishedDate.toString(),style: TextStyle(
//                         fontSize: 12,color: Colors.grey
//                     ),)
//                 ), Padding(padding: const EdgeInsets.only(left: 50,top: 10,right: 0,bottom: 0),
//                   child: Image.asset("assets/images/like.png",height: 12,)
//                 ), Padding(padding: const EdgeInsets.only(left: 5,top: 10,right: 0,bottom: 0),
//                   child: Image.asset("assets/images/dis-like.png",height: 12,)
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//       ),
//       Padding(padding: const EdgeInsets.only(left: 15,right: 10,top: 10),
//       child: Text("The Future of Real Estate: How Akarat is Transforming property search in the UAE",style:
//         TextStyle(
//           fontSize: 14,letterSpacing: 0.5,fontWeight: FontWeight.bold
//         ),),
//       ),
//       Padding(padding: const EdgeInsets.only(left: 15,right: 10,top: 10),
//       child: Container(
//         height: screenSize.height*0.5,
//         width: double.infinity,
//         //color: Colors.grey,
//         child: Text(blogDetailModel!.data!.translations!.en!.description.toString(),style: TextStyle(
//           letterSpacing: 0.5
//         ),),
//       ),
//       ),
//       SizedBox(
//   height: screenSize.height*0.1,
// )
//
//       ]
//     )
//     ),
//       bottomSheet: Container(
//         height: 50,
//         width: double.infinity,
//         margin: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
//         decoration: BoxDecoration(
//             shape: BoxShape.rectangle,
//             borderRadius: BorderRadiusDirectional.circular(6.0),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey,
//                 offset: const Offset(
//                   0.5,
//                   0.5,
//                 ),
//                 blurRadius: 1.0,
//                 spreadRadius: 0.5,
//               ), //BoxShadow
//               BoxShadow(
//                 color: Colors.white,
//                 offset: const Offset(0.0, 0.0),
//                 blurRadius: 0.0,
//                 spreadRadius: 0.0,
//               ), //BoxShadow
//             ]),
//         child: Row(
//           children: [
//             Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
//                 child: Image.asset("assets/images/app_icon.png",height: 25,)
//             ),
//             Padding(padding: const EdgeInsets.only(left: 5,top: 0,right: 0),
//                 child: Image.asset("assets/images/logo-text.png",height: 22,)
//             ),
//             Padding(padding: const EdgeInsets.only(left: 40,top: 0,right: 0),
//               child: SizedBox(
//                 height: 30,
//                 width: 80,
//                 child: ElevatedButton(onPressed: (){},style:
//                 ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFF59D),
//                   shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(10)),),),
//                     child: Text("Rent",style: TextStyle(color: Colors.black,))
//                 ),
//               ),
//             ),
//             Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
//               child: SizedBox(
//                 height: 30,
//                 width: 80,
//                 child: ElevatedButton(onPressed: (){},style:
//                 ElevatedButton.styleFrom(backgroundColor: Color(0xFFF5F5F5),
//                   shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(10)),),),
//                     child: Text("Sale",style: TextStyle(color: Colors.black,))
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Container buildMyNavBar(BuildContext context) {
//     Size screenSize = MediaQuery.sizeOf(context);
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         spacing: screenSize.width*0.7,
//         children: [
//           GestureDetector(
//               onTap: ()async{
//                 Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
//               },
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                 child: Image.asset("assets/images/home.png",height: 25,),
//               )),
//           Padding(
//             padding: const EdgeInsets.only(left: 0.0),
//             child: IconButton(
//               enableFeedback: false,
//               alignment: Alignment.bottomRight,
//               onPressed: () {
//
//                 setState(() {
//                   if(token == ''){
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
//                   }
//                   else{
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));
//
//                   }
//                 });
//               },
//               icon: pageIndex == 3
//                   ? const Icon(
//                 Icons.dehaze,
//                 color: Colors.red,
//                 size: 35,
//               )
//                   : const Icon(
//                 Icons.dehaze_outlined,
//                 color: Colors.red,
//                 size: 35,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
