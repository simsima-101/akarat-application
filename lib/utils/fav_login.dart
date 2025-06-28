import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../model/favoritemodel.dart' as favModel;
import '../model/propertymodel.dart'as propModel;
import '../model/togglemodel.dart';
import '../screen/home.dart';
import '../screen/login.dart';
import '../screen/product_detail.dart';

class Fav_Login extends StatefulWidget {
  Fav_Login({super.key});

  @override
  State<Fav_Login> createState() => new _Fav_LoginState();
}

class _Fav_LoginState extends State<Fav_Login> {
  int pageIndex = 0;
  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;
  int? property_id;
  ToggleModel? toggleModel;

  SharedPreferencesManager prefManager = SharedPreferencesManager();

  // For phone calls: Always output in +971... format
  // Phone sanitizer: always outputs +971XXXXXXXXX
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

// WhatsApp sanitizer: always outputs 971XXXXXXXXX (no plus)
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
  ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<favModel.Data> favoriteModel = [];

  @override
  void initState() {
    super.initState();
    readData();
    _loadFavorites();
  }

  Future<void> getFilesApi(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'saved_properties_$token';
    final cacheTimeKey = 'saved_properties_time_$token';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;

    // Try cache first
    if (now - lastFetched < Duration(hours: 3).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        try {
          final cachedModel = favModel.FavoriteResponseModel.fromJson(json.decode(cachedData));
          setState(() {
            favoriteModel = cachedModel.data?.data ?? [];
            print("favoriteModel length (cache): ${favoriteModel.length}");
            for (var data in favoriteModel) {
              print("Favorite from cache: ${data.title}, id: ${data.id}");
            }
          });
          debugPrint("✅ Loaded saved properties from cache");
          return; // Early return if cache is valid
        } catch (e) {
          print("Cache JSON parse error: $e");
          print("Raw cache body: $cachedData");
          // Fall through to network fetch if cache is corrupted
        }
      }
    }

    // Fetch from API
    try {
      final response = await http.get(
        Uri.parse("https://akarat.com/api/saved-property-list"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Explicit handling for 401 Unauthenticated
      if (response.statusCode == 401) {
        print("Error: Unauthenticated. Logging out.");
        // Here you can also clear token from storage or trigger a logout flow
        setState(() {
          favoriteModel = [];
        });
        return;
      }

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);

          // Defensive: check if keys exist and are not null
          if (jsonData['data'] != null && jsonData['data']['data'] != null) {
            final feature = favModel.FavoriteResponseModel.fromJson(jsonData);

            await prefs.setString(cacheKey, json.encode(jsonData));
            await prefs.setInt(cacheTimeKey, now);

            setState(() {
              favoriteModel = feature.data?.data ?? [];
              print("favoriteModel length (API): ${favoriteModel.length}");
              for (var data in favoriteModel) {
                print("Favorite from API: ${data.title}, id: ${data.id}");
              }
            });

            debugPrint("✅ Fetched and cached saved properties");
          } else {
            print("API format not as expected: missing 'data' or 'data.data'");
            setState(() {
              favoriteModel = [];
            });
          }
        } catch (e) {
          print("JSON parse error: $e");
          print("Raw response body: ${response.body}");
          setState(() {
            favoriteModel = [];
          });
        }
      } else {
        // Handle other non-200 responses (e.g. 500 Server error)
        print("Error: ${response.statusCode}");
        print("Response: ${response.body}");
        setState(() {
          favoriteModel = [];
        });
      }
    } catch (e) {
      debugPrint("🚨 Exception in getFilesApi: $e");
      setState(() {
        favoriteModel = [];
      });
    }
  }
  Set<int> favoriteProperties = {};

  void toggleFavorite(int propertyId) async {
    setState(() {
      if (favoriteProperties.contains(propertyId)) {
        favoriteProperties.remove(propertyId); // ❌ Remove from favorites
      } else {
        favoriteProperties.add(propertyId);    // ✅ Add to favorites
      }
    });

    await _saveFavorites();     // 💾 Save updated favorites
    await getFilesApi(token);   // 🔄 Refresh list from API
  }



  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favorite_properties') ?? [];
    setState(() {
      favoriteProperties = savedFavorites.map(int.parse).toSet();
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'favorite_properties', favoriteProperties.map((id) => id.toString()).toList());
  }

  Future<bool> toggledApi(String token, int propertyId) async {
    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/toggle-saved-property/$propertyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Favorite toggled successfully");
        return true;
      } else {
        print("❌ Failed to toggle favorite: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("🚨 Error in toggledApi: $e");
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    List<favModel.Data> allFavorites = favoriteModel
        .where((item) => favoriteProperties.contains(item.id))
        .toList();

    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
        body: DefaultTabController(
            length: 2,
            child: Column(children: <Widget>[
              Container(
                height: screenSize.height * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(2.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: const Offset(0.3, 0.3),
                      blurRadius: 0.3,
                      spreadRadius: 0.3,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ),
                  ],
                ),
                child: Stack(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 25, left: 10),
                    child: Container(
                      height: screenSize.height * 0.07,
                      width: double.infinity,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 10, top: 5, bottom: 0),
                              height: 35,
                              width: 35,
                              padding: const EdgeInsets.only(top: 7, left: 7, right: 7, bottom: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.circular(20.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: const Offset(0.3, 0.3),
                                    blurRadius: 0.3,
                                    spreadRadius: 0.3,
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: const Offset(0.0, 0.0),
                                    blurRadius: 0.0,
                                    spreadRadius: 0.0,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/images/ar-left.png",
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(width: screenSize.width * 0.28),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Saved", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          )
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                height: screenSize.height * 0.06,
                width: screenSize.width * 0.9,
                child: TabBar(
                  padding: EdgeInsets.only(top: 0, left: 10, right: 0),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 0),
                  splashFactory: NoSplash.splashFactory,
                  indicatorWeight: 1.0,
                  labelColor: Colors.lightBlueAccent,
                  dividerColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  tabAlignment: TabAlignment.center,
                  tabs: [
                    Container(
                      margin: const EdgeInsets.only(left: 0),
                      width: screenSize.width * 0.41,
                      height: screenSize.height * 0.045,
                      padding: const EdgeInsets.only(top: 10),
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
                      child: Text('Favorites', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      width: screenSize.width * 0.41,
                      height: screenSize.height * 0.045,
                      padding: const EdgeInsets.only(top: 10),
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
                      child: Text('Searches', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allFavorites.length,
                  itemBuilder: (context, index) {
                    final item = allFavorites[index];
                    String id = item.id.toString();

                    print('🏷️ Property ${item.id} using URL → "${item.image}"');
                    bool isFavorited = favoriteProperties.contains(item.id);
                    return SingleChildScrollView(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Product_Detail(data: item.id.toString()),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0, right: 5, top: 0, bottom: 15),
                            child: Card(
                              color: Colors.white,
                              elevation: 20,
                              shadowColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0, top: 0, right: 5, bottom: 10),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(children: [
                                          AspectRatio(
                                            aspectRatio: 1.5,
                                            child: CachedNetworkImage(
                                              imageUrl: item.image ?? getFullImageUrl(null),
                                              fit: BoxFit.cover,
                                              placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                                              errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                                            ),


                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.5),
                                                    blurRadius: 4,
                                                    offset: Offset(2, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: IconButton(
                                                  icon: Icon(
                                                    favoriteProperties.contains(item.id)
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: Colors.red,
                                                    size: 18,
                                                  ),
                                                  onPressed: () async {
                                                    if (token.isEmpty) {
                                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                                                      return;
                                                    }

                                                    final success = await toggledApi(token, item.id!);
                                                    if (success) {
                                                      toggleFavorite(item.id!); // ✅ update list
                                                    } else {
                                                      debugPrint("❌ API toggle failed");
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Positioned(
                                          //   top: 5,
                                          //   right: 10,
                                          //   child: Container(
                                          //     margin: const EdgeInsets.only(left: 320, top: 10, bottom: 0),
                                          //     height: 35,
                                          //     width: 35,
                                          //     padding: const EdgeInsets.only(top: 0, left: 0, right: 5, bottom: 5),
                                          //     decoration: BoxDecoration(
                                          //       borderRadius: BorderRadiusDirectional.circular(20.0),
                                          //       boxShadow: [
                                          //         BoxShadow(
                                          //           color: Colors.grey,
                                          //           offset: const Offset(0.3, 0.3),
                                          //           blurRadius: 0.3,
                                          //           spreadRadius: 0.3,
                                          //         ),
                                          //         BoxShadow(
                                          //           color: Colors.white,
                                          //           offset: const Offset(0.0, 0.0),
                                          //           blurRadius: 0.0,
                                          //           spreadRadius: 0.0,
                                          //         ),
                                          //       ],
                                          //     ),
                                          //     child: IconButton(
                                          //       padding: EdgeInsets.only(left: 5, top: 7),
                                          //       alignment: Alignment.center,
                                          //       icon: Icon(
                                          //         isFavorited ? Icons.favorite : Icons.favorite_border,
                                          //         color: isFavorited ? Colors.red : Colors.red,
                                          //       ),
                                          //       onPressed: () async {
                                          //         if (token.isEmpty) {
                                          //           Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                                          //           return;
                                          //         }
                                          //         final success = await toggledApi(token, item.id);
                                          //         if (success) {
                                          //           await getFilesApi(token);
                                          //         }
                                          //       },
                                          //     ),
                                          //   ),
                                          // ),
                                        ])),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: ListTile(
                                        title: Text(item.title.toString(), style: TextStyle(fontSize: 16, height: 1.4)),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 3.0),
                                          child: Text('${item.price} AED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, height: 1.4)),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15, right: 5, top: 0, bottom: 0),
                                          child: Image.asset("assets/images/map.png", height: 14),
                                        ),
                                        Expanded(
                                          child: Text(item.address.toString(), style: TextStyle(fontSize: 13, height: 1.4, overflow: TextOverflow.visible)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Padding(padding: const EdgeInsets.only(left: 15, right: 5, top: 5), child: Image.asset("assets/images/bed.png", height: 13)),
                                        Padding(padding: const EdgeInsets.only(left: 5, right: 5, top: 5), child: Text(item.bedrooms.toString())),
                                        Padding(padding: const EdgeInsets.only(left: 10, right: 5, top: 5), child: Image.asset("assets/images/bath.png", height: 13)),
                                        Padding(padding: const EdgeInsets.only(left: 5, right: 5, top: 5), child: Text(item.bathrooms.toString())),
                                        Padding(padding: const EdgeInsets.only(left: 10, right: 5, top: 5), child: Image.asset("assets/images/messure.png", height: 13)),
                                        Padding(padding: const EdgeInsets.only(left: 5, right: 5, top: 5), child: Text(item.squareFeet.toString())),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              String phone = 'tel:${phoneCallNumber(item.phone ?? '')}';
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
                                              final message = Uri.encodeComponent("Hello");
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
                        ));
                  },
                ),
              ),
            ])));
  }

  Container buildMyNavBar(BuildContext context) {
    return  Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ distributes space correctly
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/home.png", height: 25),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
              },
              icon: pageIndex == 3
                  ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                  : const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Add this helper function outside the class (at the bottom of Fav_Login.dart)

String getFullImageUrl(String? url) {
  if (url == null || url.isEmpty) {
    return 'https://via.placeholder.com/400x300.png?text=No+Image';
  }

  if (url.contains('/conversions/') && url.endsWith('.webp')) {
    final fallbackUrl = url
        .replaceAll('/conversions/', '/')
        .replaceAll('-thumbnail.webp', '.jpg');
    return fallbackUrl;
  }

  if (url.startsWith('http')) {
    return url;
  }

  return 'https://akarat.com/$url';
}
