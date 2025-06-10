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
import '../utils/shared_preference_manager.dart';
import 'login.dart';
import 'my_account.dart';
import 'package:Akarat/services/favorite_service.dart';
import 'package:Akarat/utils/whatsapp_button.dart';




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


  Set<int> favoriteProperties = {};

  int pageIndex = 0;

  bool isDataRead = false;
  bool isFavorited = false;






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
    token = await prefManager.readStringFromPref();
    email = await prefManager.readStringFromPrefemail();
    result = await prefManager.readStringFromPrefresult();
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
    _loadFavoritesFromService();

    _searchController.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
          !isLoading && hasMore) {
        getFilesApi(); // call your API method here
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


  Future<void> _loadFavoritesFromService() async {
    final favorites = await FavoriteService.loadFavorites();
    setState(() {
      favoriteProperties = favorites;
    });
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



  Future<void> getFilesApi() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(
        "https://akarat.com/api/new-projects?page=$currentPage",
      ));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final ProjectResponseModel responseModel = ProjectResponseModel.fromJson(jsonData);
        final ProjectModel fetchedModel = responseModel.data!;
        final newItems = fetchedModel.data ?? [];

        setState(() {
          currentPage++;
          isLoading = false;
          projectModel.addAll(newItems);
          hasMore = fetchedModel.meta?.currentPage != fetchedModel.meta?.lastPage;
        });
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("🚨 fetchProjects Exception: $e");
      setState(() => isLoading = false);
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



  void toggleFavorite(Data project) async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing favorites
    final existingFavoritesString = prefs.getString('favorite_projects_data');
    List<Map<String, dynamic>> existingFavorites = [];

    if (existingFavoritesString != null) {
      existingFavorites = List<Map<String, dynamic>>.from(jsonDecode(existingFavoritesString));
    }

    // Check if this project is already in favorites
    final isAlreadyFavorite = existingFavorites.any((item) => item['id'] == project.id);

    if (isAlreadyFavorite) {
      // Remove from favorites
      existingFavorites.removeWhere((item) => item['id'] == project.id);
      favoriteProperties.remove(project.id!);
      print('❌ Removed project ${project.id}');
    } else {
      // Add to favorites
      existingFavorites.add({
        'id': project.id,
        'title': project.title,
        'price': project.price,
        'location': project.location,
        'bedrooms': project.bedrooms,
        'bathrooms': project.bathrooms,
        'squareFeet': project.squareFeet,
        'image': project.media != null && project.media!.isNotEmpty
            ? project.media![0].originalUrl.toString()
            : '',
      });
      favoriteProperties.add(project.id!);
      print('✅ Added project ${project.id}');
    }

    // Save updated list
    await prefs.setString('favorite_projects_data', jsonEncode(existingFavorites));

    // If you are also syncing ids in FavoriteService (optional):
    await FavoriteService.saveFavorites(favoriteProperties);

    setState(() {}); // Refresh UI
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
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20,left: 20,right: 15),
                    child: Container(
                      width: screenSize.width * 0.9,
                      height: 50,
                      padding: const EdgeInsets.only(left: 10), // add left padding
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300, // grey background
                        borderRadius: BorderRadiusDirectional.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 1.0,
                            spreadRadius: 0.5,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey), // grey icon
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Search new projects (Coming Soon)",
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 15,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ),
                ],
              ),
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
                    bool isFavorited = favoriteProperties.contains(item.id);

                    return GestureDetector(
                      onTap: () {
                        String id = item.id.toString();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Property_Detail(data: id),
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1.4,
                                        child: PageView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: item.media?.length ?? 0,
                                          itemBuilder: (context, imgIndex) {
                                            return CachedNetworkImage(
                                              imageUrl: item.media![imgIndex].originalUrl.toString(),
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                      // ❤️ Favorite Icon (corrected)
                                      // Positioned(
                                      //   top: 10,
                                      //   right: 10,
                                      //   child: Container(
                                      //     height: MediaQuery.of(context).size.height * 0.04,
                                      //     width: MediaQuery.of(context).size.height * 0.04,
                                      //     decoration: BoxDecoration(
                                      //       color: Colors.white,
                                      //       shape: BoxShape.circle,
                                      //       boxShadow: [
                                      //         BoxShadow(
                                      //           color: Colors.grey.withOpacity(0.5),
                                      //           blurRadius: 4,
                                      //           offset: Offset(2, 2),
                                      //         ),
                                      //       ],
                                      //     ),
                                      //     child: Center(
                                      //       child: IconButton(
                                      //         icon: AnimatedSwitcher(
                                      //           duration: Duration(milliseconds: 300),
                                      //           transitionBuilder: (child, animation) =>
                                      //               ScaleTransition(scale: animation, child: child),
                                      //           child: Icon(
                                      //             favoriteProperties.contains(item.id!) ? Icons.favorite : Icons.favorite_border,
                                      //             key: ValueKey(favoriteProperties.contains(item.id!)),
                                      //             color: Colors.red,
                                      //             size: 18,
                                      //           ),
                                      //         ),
                                      //         onPressed: () async {
                                      //           property_id = item.id;
                                      //
                                      //           if (token.isEmpty) {
                                      //             print("🚫 No token - please login.");
                                      //             toggleFavorite(item); // Local save
                                      //           } else {
                                      //             print("✅ Token exists, calling toggle API...");
                                      //             await toggledApi(token, item.id!);
                                      //             toggleFavorite(item);
                                      //           }
                                      //
                                      //
                                      //           setState(() {}); // Update UI
                                      //         },
                                      //
                                      //
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),

                                    ],
                                  ),
                                ),





                                SizedBox(height: 10),
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
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ],
                            ),
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
        ],
      ),
    );
  }
}