import 'dart:convert';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/blogmodel.dart';
import 'package:Akarat/screen/blog_detail.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  runApp(const Blog());

}

class Blog extends StatelessWidget {
  const Blog({Key ? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlogDemo(),
    );
  }
}
class BlogDemo extends StatefulWidget {
  @override
  _BlogDemoState createState() => _BlogDemoState();
}
class _BlogDemoState extends State<BlogDemo> {

  int pageIndex = 0;
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
  ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<BlogModel> blogList = [];

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    hasMore = true;
    isLoading = false;

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    getFilesApi(); // fetch first page
    readData();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore) {
      getFilesApi(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getFilesApi({bool loadMore = false}) async {
    if (isLoading || (!hasMore && loadMore)) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'blog_cache_page_$currentPage';
    final cacheTimeKey = 'blog_cache_time_page_$currentPage';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // Load from cache if within 6 hours
    if (!loadMore && now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final model = BlogResponseModel.fromJson(jsonData);
        setState(() {
          blogList = model.data?.data ?? [];
          final meta = model.data?.meta;
          currentPage = (meta?.currentPage ?? 1) + 1;
          hasMore = (meta?.currentPage ?? 1) < (meta?.lastPage ?? 1);
          isLoading = false;
        });
        debugPrint("📦 Loaded blog data from cache");
        return;
      }
    }

    // Fetch from API
    final url = Uri.parse('https://akarat.com/api/blogs?page=$currentPage');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = BlogResponseModel.fromJson(jsonData);
        final newData = model.data?.data ?? [];

        setState(() {
          if (loadMore) {
            blogList.addAll(newData);
          } else {
            blogList = newData;
          }

          final meta = model.data?.meta;
          currentPage = (meta?.currentPage ?? 1) + 1;
          hasMore = (meta?.currentPage ?? 1) < (meta?.lastPage ?? 1);
        });

        // Cache current page if not loading more
        if (!loadMore) {
          await prefs.setString(cacheKey, jsonEncode(jsonData));
          await prefs.setInt(cacheTimeKey, now);
          debugPrint("✅ Cached blog page $currentPage");
        }
      } else {
        debugPrint("❌ Blog API error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception in fetchBlogs: $e");
    }

    setState(() => isLoading = false);
  }



  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if (blogList.isEmpty && isLoading) {
      return Scaffold(
          body: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerCard(),) // Show loading state
      );
    }
   return Scaffold(
       backgroundColor: Colors.white,
     bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
     appBar: AppBar(
       title: const Text(
           "Blog", style: TextStyle(color: Colors.black,
           fontWeight: FontWeight.bold)),
       leading: IconButton(
         icon: const Icon(Icons.arrow_back, color: Colors.red),
         onPressed: ()async {
           setState(() {
             if(token == ''){
               Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
             }
             else{
               Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

             }
           });
         },
       ),
       centerTitle: true,
       backgroundColor: Color(0xFFFFFFFF),
       iconTheme: const IconThemeData(color: Colors.red),
       elevation: 1,
     ),
     body: Column(
       children: <Widget>[
         Padding(
           padding: const EdgeInsets.symmetric(vertical: 10,),
           child: Container(
             height: 50,
             width: double.infinity,
             decoration: BoxDecoration(
                 shape: BoxShape.rectangle,
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
                 /* Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
              child: Icon(Icons.search_rounded,color: Colors.red,size: 40,),
              ),*/ Padding(padding: const EdgeInsets.only(left: 20,top: 0,right: 0),
                     child: Image.asset("assets/images/app_icon.png",height: 35,)
                 ), Padding(padding: const EdgeInsets.only(left: 5,top: 0,right: 0),
                     child: Image.asset("assets/images/logo-text.png",height: 30,)
                 ), /*Padding(padding: const EdgeInsets.only(left: 75,top: 0,right: 10),
              child: Icon(Icons.dehaze,color: Colors.red,size: 40,),
              ),*/
               ],
             ),
           ),
         ),
         Expanded(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 8.0),
             child: ListView.builder(
               controller: _scrollController,
               itemCount: blogList.length + (hasMore ? 1 : 0),
               itemBuilder: (context, index) {
                 if (index < blogList.length) {
                   final blog = blogList[index];
                   return GestureDetector(
                     onTap: () async {
                       Navigator.push(context, MaterialPageRoute(builder: (context)=> Blog_Detail(data: blog.id.toString())));
                     },
                     child: Card(
                       color: Colors.white,
                       margin: const EdgeInsets.all(10),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           CachedNetworkImage(
                             imageUrl: blog.image.toString(),
                             height: 200,
                             width: double.infinity,
                             fit: BoxFit.cover,
                           ),
                           Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Text(blog.translations!.en!.title.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                           ),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
                             child: Text('Published: ${blog.publishedDate} • ${blog.readingTime} read'),
                           ),
                         ],
                       ),
                     ),
                   );
                 } else {
                   return const Padding(
                     padding: EdgeInsets.all(16.0),
                     child: Center(child: CircularProgressIndicator()),
                   );
                 }
               },
             ),
           ),
         ),
                ]
              ),

             bottomSheet:  Container(
           height: 50,
           width: double.infinity,
           margin: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
           decoration: BoxDecoration(
               shape: BoxShape.rectangle,
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
               Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
                   child: Image.asset("assets/images/app_icon.png",height: 25,)
               ),
               Padding(padding: const EdgeInsets.only(left: 5,top: 0,right: 0),
                   child: Image.asset("assets/images/logo-text.png",height: 22,)
               ),
               Padding(padding: const EdgeInsets.only(left: 40,top: 0,right: 0),
                 child: SizedBox(
                   height: 30,
                   width: 80,
                   child: ElevatedButton(onPressed: (){},style:
                   ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFF59D),
                     shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(10)),),),
                       child: Text("Rent",style: TextStyle(color: Colors.black,))
                   ),
                 ),
               ),
               Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
                 child: SizedBox(
                   height: 30,
                   width: 80,
                   child: ElevatedButton(onPressed: (){},style:
                   ElevatedButton.styleFrom(backgroundColor: Color(0xFFF5F5F5),
                     shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(10)),),),
                       child: Text("Sale",style: TextStyle(color: Colors.black,))
                   ),
                 ),
               )
             ],
           ),
         ),
         );
    }
  Container buildMyNavBar(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
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
        spacing: screenSize.width*0.7,
       // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
              onTap: ()async{
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Image.asset("assets/images/home.png",height: 25,),
              )),

          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: IconButton(
              alignment: Alignment.bottomRight,
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
          ),
        ],
      ),
    );
  }
}