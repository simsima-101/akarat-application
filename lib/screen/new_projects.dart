import 'dart:async';
import 'dart:convert';

import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/projectmodel.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/property_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/togglemodel.dart';
import '../model/projectmodel.dart';
import '../secure_storage.dart';

import '../utils/shared_preference_manager.dart';
import 'featured_detail.dart';
import 'login.dart';
import 'my_account.dart';
import 'package:Akarat/utils/whatsapp_button.dart';

import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';





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

  bool isDataRead = false;
  bool isFavorited = false;


  final TextEditingController _projectSearchController = TextEditingController();





  ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<Data> projectModel = [];
  bool showNoPropertiesMessage = false;

  ToggleModel? toggleModel;
  int? property_id ;
  String token = '';
  String email = '';
  String result = '';




  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();

  String phoneCallNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (input.startsWith('+971')) return input;
    if (input.startsWith('00971')) return '+971${input.substring(5)}';
    if (input.startsWith('971')) return '+971${input.substring(3)}';
    if (input.startsWith('0') && input.length == 10)
      return '+971${input.substring(1)}';
    if (input.length == 9) return '+971$input';
    return input; // fallback
  }

  String whatsAppNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d]'), '');
    if (input.startsWith('971')) return input;
    if (input.startsWith('00971')) return input.substring(2);
    if (input.startsWith('+971')) return input.substring(1);
    if (input.startsWith('0') && input.length == 10)
      return '971${input.substring(1)}';
    if (input.length == 9) return '971$input';
    return input; // fallback
  }




  // Method to read data from shared preferences
  void readData() async {
    token = await SecureStorage.getToken() ?? '';
    setState(() {
      isDataRead = true;
    });
  }

  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    getFilesApi();
    readData();


    _searchController.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          hasMore) {
        getFilesApi(loadMore: true); // explicitly pass loadMore = true
      }
    });


    // Start a timer for 5 minutes
    Future.delayed(const Duration(minutes: 2), () {
      if (mounted && projectModel == null) {
        setState(() {
          showNoPropertiesMessage = true;
        });
      }
    });

    //  getFilesApi(); // load first page initially
  }





  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController.text;
      _callSearchApi(query);
    });
  }


  Map<String, List<Data>> _searchCache = {};
  String lastSearchQuery = '';

  Future<void> _callSearchApi(String query) async {
    query = query.trim();

    // Avoid unnecessary calls
    if (query == lastSearchQuery || query.isEmpty) return;

    lastSearchQuery = query;

    // Use cached data if available
    if (_searchCache.containsKey(query)) {
      setState(() {
        projectModel = _searchCache[query]!;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://akarat.com/api/filters?search=$query&amenities=&property_type=&furnished_status=&bedrooms=&min_price='
              '&max_price=&payment_period=&min_square_feet=&max_square_feet=&bathrooms=&purpose=New%20Projects'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = ProjectModel.fromJson(data);

        _searchCache[query] = result.data ?? [];
        projectModel = _searchCache[query]!;

        if (mounted) {
          setState(() {
            projectModel = result.data ?? [];
          });
        }
      } else {
        debugPrint('❌ API failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🚨 Search API Error: $e');
    }
  }



  Future<void> getFilesApi({bool loadMore = false}) async {
    if (isLoading || (!hasMore && loadMore)) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'new_projects_cache';
    final cacheTimeKey = 'new_projects_cache_time';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    final uri = Uri.parse("https://akarat.com/api/new-projects?page=$currentPage");

    // ✅ Load from cache if not loading more and cache is valid
    if (!loadMore && now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
          final jsonData = jsonDecode(cachedData);
          final ProjectResponseModel responseModel = ProjectResponseModel.fromJson(jsonData);
          final ProjectModel cachedModel = responseModel.data!;
          final newItems = cachedModel.data ?? [];

          setState(() {
            projectModel = newItems;
            hasMore = cachedModel.meta?.currentPage != cachedModel.meta?.lastPage;
            currentPage = (cachedModel.meta?.currentPage ?? 1) + 1;
            isLoading = false;
          });

          debugPrint("📦 Loaded new projects from cache");
          return;
        } catch (e) {
          debugPrint("⚠️ Cache parsing failed: $e");
        }
      }
    }

    // ✅ Make API call
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final ProjectResponseModel responseModel = ProjectResponseModel.fromJson(jsonData);
        final ProjectModel fetchedModel = responseModel.data!;
        final newItems = fetchedModel.data ?? [];

        setState(() {
          if (loadMore) {
            projectModel.addAll(newItems);
          } else {
            projectModel = newItems;
          }

          currentPage = (fetchedModel.meta?.currentPage ?? 1) + 1;
          hasMore = fetchedModel.meta?.currentPage != fetchedModel.meta?.lastPage;
          isLoading = false;
        });

        // ✅ Save to cache if it's the first page
        if (!loadMore && currentPage == 2) {
          await prefs.setString(cacheKey, jsonEncode(jsonData));
          await prefs.setInt(cacheTimeKey, now);
          debugPrint("✅ Cached new projects");
        }
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("🚨 Exception in getFilesApi: $e");
      setState(() => isLoading = false);
    }
  }




  /// Returns true if the toggle call succeeded, false otherwise.
  Future<bool> toggledApi(String token, int propertyId) async {
    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/toggle-saved-property'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({ "property_id": propertyId }),
      );

      if (response.statusCode == 200) {
        // Optionally parse the response JSON here if you need the new `saved` state
        return true;
      } else {
        debugPrint("❌ toggle failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("🚨 toggle exception: $e");
      return false;
    }
  }


  Future<String> resolveImageUrl(String? url) async {
    if (url == null || url.isEmpty) {
      return "https://akarat.com/default-image.jpg"; // fallback image
    }
    if (!url.startsWith('http')) {
      return 'https://akarat.com$url';
    }
    return url;
  }





  // Load saved favorites from SharedPreferences

  @override
  Widget build(BuildContext context) {
    if (projectModel == null) {
      if (showNoPropertiesMessage) {
        return Scaffold(
          body: Center(
            child: Text(
              "No properties found.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        return Scaffold(
          body: SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ShimmerCard(),
              ),
            ),
          ),
        );
      }
    }
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        appBar: AppBar(
          title: const Text(
              "New Projects", style: TextStyle(color: Colors.black,
              fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.red),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Home())), // ✅ Add close functionality
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: const IconThemeData(color: Colors.red),
          elevation: 1,
        ),
        body:
        //SingleChildScrollView(
        //  child:
        Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 15,left: 15,right: 15),
                padding: const EdgeInsets.only(top: 5,left: 5,right: 10),
                height: 50,
                width: double.infinity,
                //color: Colors.grey,
                child: Text("Find off-plan development and everything you need to "
                    "know to invest in UAE's real estate market",style: TextStyle(letterSpacing: 0.5,),),
              ),


              // Row(
              // children: [
              // Padding(
              // padding: const EdgeInsets.only(top: 20, left: 20, right: 15),
              // child: Container(
              // width: screenSize.width * 0.9,
              // height: 50,
              // padding: const EdgeInsets.symmetric(horizontal: 12),
              // decoration: BoxDecoration(
              // color: Colors.white,                              // active background
              // borderRadius: BorderRadius.circular(10.0),
              // boxShadow: [
              // BoxShadow(
              // color: Colors.grey.withOpacity(0.5),
              // offset: const Offset(0.5, 0.5),
              // blurRadius: 1.0,
              // spreadRadius: 0.5,
              // ),
              // BoxShadow(
              // color: Colors.white.withOpacity(0.8),
              // offset: const Offset(0, 0),
              // blurRadius: 0,
              // spreadRadius: 0,
              // ),
              // ],
              // ),
              // child: Row(
              // children: [
              // Icon(Icons.location_on, color: Colors.red),      // active icon color
              // const SizedBox(width: 8),
              // Expanded(
              // child: TextField(
              // controller: _projectSearchController,
              // decoration: InputDecoration(
              // hintText: "Search new projects",
              // hintStyle: TextStyle(
              // color: Colors.grey.shade600,
              // fontSize: 15,
              // letterSpacing: 0.5,
              // fontWeight: FontWeight.w500,
              // ),
              // border: InputBorder.none,
              // ),
              // onChanged: (value) {
              // // TODO: your filter/search logic here
              // },
              // ),
              // ),
              // ],
              // ),
              // ),
              // ),
              // ],
              // ),

              Row(
                children: [
                  Padding(padding: const EdgeInsets.only(top: 20,left: 20,right: 0),
                    child: Text("Latest Projects in Dubai",textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                  ),
                  Text("")
                ],
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
              projectModel.isEmpty
                  ? Center(child: ShimmerCard())
                  : Expanded(
                child: ListView.builder(
                  itemCount: projectModel.length,
                  itemBuilder: (context, index) {
                    final item = projectModel[index];


                    return GestureDetector(
                      onTap: () {
                        String id = item.id.toString();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Featured_Detail(data: id),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Card(
                          color: Colors.white,
                          shadowColor: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: AspectRatio(
                                        aspectRatio: 1.5,
                                        child: FutureBuilder<String>(
                                          future: resolveImageUrl(
                                            item.media != null && item.media!.isNotEmpty
                                                ? item.media!.first.originalUrl
                                                : null,
                                          ),
                                          builder: (ctx, snap) {
                                            if (snap.connectionState == ConnectionState.waiting) {
                                              return const Center(child: CircularProgressIndicator());
                                            }
                                            final url = snap.data!;
                                            return CachedNetworkImage(
                                              imageUrl: url,
                                              fit: BoxFit.cover,
                                              placeholder: (c, u) =>
                                              const Center(child: CircularProgressIndicator()),
                                              errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    // ❤️ Favorite icon (top right)
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Material(
                                        color: Colors.white,
                                        shape: const CircleBorder(),
                                        elevation: 4,
                                        child: Consumer<FavoriteProvider>(
                                          builder: (context, favProvider, _) {
                                            final propertyId = item.id!;
                                            final isFav = favProvider.isFavorite(propertyId);

                                            return IconButton(
                                              icon: Icon(
                                                isFav ? Icons.favorite : Icons.favorite_border,
                                                color: isFav ? Colors.red : Colors.grey,
                                                size: 20,
                                              ),
                                              onPressed: () async {
                                                final token = await SecureStorage.getToken();

                                                if (token == null || token.isEmpty) {
                                                  // 🔒 Show login dialog
                                                  showDialog(
                                                    context: context,
                                                    builder: (ctx) => Dialog(
                                                      backgroundColor: Colors.transparent,
                                                      insetPadding: EdgeInsets.zero,
                                                      child: Container(
                                                        height: 70,
                                                        margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Stack(
                                                          clipBehavior: Clip.none,
                                                          children: [
                                                            Positioned(
                                                              top: -14,
                                                              right: -10,
                                                              child: IconButton(
                                                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                                                onPressed: () => Navigator.of(ctx).pop(),
                                                                padding: EdgeInsets.zero,
                                                                constraints: const BoxConstraints(),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              left: 16,
                                                              right: 16,
                                                              bottom: 12,
                                                              child: Row(
                                                                children: [
                                                                  const Expanded(
                                                                    child: Text(
                                                                      'Login required to add favorites.',
                                                                      style: TextStyle(color: Colors.white, fontSize: 13),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 12),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.of(ctx).pop();
                                                                      Navigator.of(ctx).pushNamed('/login');
                                                                    },
                                                                    child: const Text(
                                                                      'Login',
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontWeight: FontWeight.bold,
                                                                        decoration: TextDecoration.underline,
                                                                        decorationColor: Colors.white,
                                                                        decorationThickness: 1.5,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                // ✅ Toggle with API + Provider
                                                final success = await favProvider.toggleFavoriteWithApi(propertyId, token);
                                                if (!success) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Failed to update favorite.")),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),



                                    // 👤 Agent photo, title, name with tap
                                    Positioned(
                                      bottom: -30,
                                      left: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          String id = item.id.toString();

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Featured_Detail(data: id),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 28,
                                              backgroundImage: (item.agentImage != null && item.agentImage!.isNotEmpty)
                                                  ? CachedNetworkImageProvider(item.agentImage!)
                                                  : const AssetImage("assets/images/dummy.jpg") as ImageProvider,
                                            ),
                                            const SizedBox(height: 6),
                                            Transform.translate(
                                              offset: const Offset(-5, 0), // shift 4 pixels to the left
                                              child: Text(
                                                "AGENT",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF1A73E9),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),





                                  ],
                                ),

                                // 🔽 Spacer so that the overlapping image is not clipped
                                const SizedBox(height: 15),

                                Padding(
                                  padding: const EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Agent Name
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(
                                            item.agentName ?? 'Agent',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),

                                      // Listed text + agency logo
                                      Row(
                                        children: [
                                          if (item.postedOn != null && item.postedOn!.isNotEmpty)
                                            Text(
                                              'Listed ${item.postedOn}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          const SizedBox(width: 4),
                                          if (item.agencyLogo != null && item.agencyLogo!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 30,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                  image: DecorationImage(
                                                    image: CachedNetworkImageProvider(item.agencyLogo!),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 5,),

                                const Divider(
                                  color: Colors.grey,
                                  thickness: 0.3,
                                  height: 6,
                                ),



SizedBox(height: 8,),


                                Text(
                                  item.title.toString(),
                                  style: TextStyle(fontSize: 16, height: 1.4),overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '${item.price} AED',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Image.asset("assets/images/map.png", height: 14),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        item.location.toString(),
                                        style: TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Image.asset("assets/images/bed.png", height: 13),
                                    SizedBox(width: 5),
                                    Text(item.bedrooms.toString()),
                                    SizedBox(width: 10),
                                    Image.asset("assets/images/bath.png", height: 13),
                                    SizedBox(width: 5),
                                    Text(item.bathrooms.toString()),
                                    SizedBox(width: 10),
                                    Image.asset("assets/images/messure.png", height: 13),
                                    SizedBox(width: 5),
                                    Text(item.squareFeet.toString()),
                                  ],
                                ),
                                SizedBox(height: 15),

                                Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          // Use the correct sanitizer for call (international format with +)
                                          String phone = 'tel:${phoneCallNumber(item.phoneNumber ?? '')}';
                                          try {
                                            final bool launched = await launchUrlString(
                                              phone,
                                              mode: LaunchMode.externalApplication,
                                            );
                                            if (!launched) print("❌ Could not launch dialer");
                                          } catch (e) {
                                            print("❌ Exception: $e");
                                          }
                                        },
                                        icon: const Icon(Icons.call, color: Colors.red),
                                        label: const Text("Call", style: TextStyle(color: Colors.black)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[100],
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          elevation: 2,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final phone = whatsAppNumber(item.whatsapp ?? '');
                                          final message = Uri.encodeComponent("Hello"); // you can change message
                                          final url = Uri.parse("https://wa.me/$phone?text=$message");
                                          if (await canLaunchUrl(url)) {
                                            try {
                                              final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
                                              if (!launched) print("❌ Could not launch WhatsApp");
                                            } catch (e) {
                                              print("❌ Exception: $e");
                                            }
                                          } else {
                                            print("❌ WhatsApp not available");
                                          }
                                        },
                                        icon: Image.asset("assets/images/whats.png", height: 20),
                                        label: const Text("WhatsApp", style: TextStyle(color: Colors.black)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[100],
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          elevation: 2,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              ]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]
        )
      //)
    );
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Image.asset("assets/images/home.png",height: 25,),
              )),
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
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  spreadRadius: 0.5,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: const Offset(0.0, 0.0),
                  blurRadius: 0.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () async {
                // Example: use first project, or replace with desired number
                final phone = projectModel.isNotEmpty
                    ? phoneCallNumber(projectModel[0].phoneNumber ?? '')
                    : '';
                if (phone.isNotEmpty) {
                  final telUrl = 'tel:$phone';
                  if (await canLaunchUrlString(telUrl)) {
                    await launchUrlString(telUrl, mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: Icon(Icons.call_outlined, color: Colors.red),
            ),
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
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  spreadRadius: 0.5,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: const Offset(0.0, 0.0),
                  blurRadius: 0.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () async {
                // Sanitize phone number to 971XXXXXXXXX (no plus)
                final phoneRaw = projectModel.isNotEmpty ? projectModel[0].whatsapp ?? '' : '';
                final phone = whatsAppNumber(phoneRaw); // always in 971XXXXXXXXX
                final message = Uri.encodeComponent("Hello");
                final waUrl = Uri.parse("https://wa.me/$phone?text=$message");

                if (await canLaunchUrl(waUrl)) {
                  try {
                    final launched = await launchUrl(
                      waUrl,
                      mode: LaunchMode.externalApplication,
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
              child: Image.asset("assets/images/whats.png", height: 20),
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.only(left: 1, right: 40),
          //   height: 35,
          //   width: 35,
          //   padding: const EdgeInsets.only(top: 2),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadiusDirectional.circular(20.0),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.grey,
          //         offset: const Offset(0.5, 0.5),
          //         blurRadius: 1.0,
          //         spreadRadius: 0.5,
          //       ),
          //       BoxShadow(
          //         color: Colors.white,
          //         offset: const Offset(0.0, 0.0),
          //         blurRadius: 0.0,
          //         spreadRadius: 0.0,
          //       ),
          //     ],
          //   ),
          //   child: GestureDetector(
          //     onTap: () async {
          //       // final String? email = projectDetailModel?.data?.email;
          //       if (email == null || email.isEmpty) {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(content: Text('No email available for this property.')),
          //         );
          //         return;
          //       }
          //       final Uri emailUri = Uri(
          //         scheme: 'mailto',
          //         path: email,
          //         query: Uri.encodeFull('subject=Property Inquiry&body=Hi, I saw your property on Akarat.'),
          //       );
          //       if (await canLaunchUrl(emailUri)) {
          //         await launchUrl(emailUri);
          //       } else {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(content: Text('Could not launch $emailUri')),
          //         );
          //       }
          //     },
          //     child: const Icon(Icons.mail, color: Colors.red),
          //   ),
          // ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                if(token == ''){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));
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