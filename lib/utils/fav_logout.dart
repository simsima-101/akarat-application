import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:Akarat/model/propertymodel.dart';
import 'package:Akarat/secure_storage.dart';
import 'package:Akarat/screen/product_detail.dart';

import '../screen/featured_detail.dart';
import '../screen/login.dart';
import '../services/favorite_service.dart';


class Fav_Logout extends StatefulWidget {
  const Fav_Logout({super.key});

  @override
  State<Fav_Logout> createState() => _Fav_LogoutState();
}




class _Fav_LogoutState extends State<Fav_Logout> {
  List<Property> savedProperties = [];
  bool isLoading = true;




  String? token;



  final Map<int, int> _carouselPageIndex = {};


  String getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/400x300.png?text=No+Image';
    }

    // 🛠️ Fix: ensure full URL
    if (!url.startsWith('http')) {
      return 'https://akarat.com/$url';
    }

    return url;
  }

  List<String> getResolvedImageUrls(List? mediaList) {
    if (mediaList == null || mediaList.isEmpty) {
      return ['https://via.placeholder.com/400x300.png?text=No+Image'];
    }

    return mediaList.map<String>((mediaItem) {
      final rawUrl = mediaItem.originalUrl;
      if (rawUrl == null || rawUrl.isEmpty) {
        return 'https://via.placeholder.com/400x300.png?text=No+Image';
      }
      if (!rawUrl.startsWith('http')) {
        return 'https://akarat.com/$rawUrl';
      }
      return rawUrl;
    }).toList();
  }



  void _clearAllFavorites() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Clear All Favorites?"),
        content: const Text("This will remove all saved properties from your favorites."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel",
    style: TextStyle(color: Colors.red),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Clear",
            style: TextStyle(color: Colors.red),
          ),),
        ],
      ),
    );

    if (confirm != true) return;

    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) return;

    try {
      final response = await http.delete(
        Uri.parse('https://akarat.com/api/saved-properties/delete-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          // ✅ Mark each property as not saved
          for (var item in savedProperties) {
            item.saved = false;
          }
          savedProperties.clear(); // ✅ clear the list afterward
        });

        // ✅ Clear memory + shared prefs
        FavoriteService.loggedInFavorites.clear();
        await FavoriteService.saveFavorites(<int>{});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All favorites cleared successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to clear favorites: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error clearing favorites: $e")),
      );
    }
  }






  @override
  void initState() {
    super.initState();
    _fetchSavedProperties();
  }

  Future<void> _fetchSavedProperties() async {
    token = await SecureStorage.getToken();

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse('https://akarat.com/api/saved-property-list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Property> props = (data['data']['data'] as List)
          .map((e) {
        final property = Property.fromJson(e);
        final intId = int.tryParse(property.id!);
        if (intId != null) {
          FavoriteService.loggedInFavorites.add(intId); // ✅ Fixed
        }
        return property;
      }).toList();


      setState(() => savedProperties = props);
    }
    setState(() => isLoading = false);
  }


  Future<bool> _urlExists(String url) async {
    try {
      final resp = await http.head(Uri.parse(url));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String> resolveImageUrl(String? rawUrl) async {
    if (rawUrl == null || rawUrl.isEmpty) {
      return 'https://via.placeholder.com/400x300.png?text=No+Image';
    }

    if (await _urlExists(rawUrl)) return rawUrl;

    if (!rawUrl.startsWith('http')) {
      final full = 'https://akarat.com/$rawUrl';
      if (await _urlExists(full)) return full;
    }

    return 'https://via.placeholder.com/400x300.png?text=No+Image';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Favorites", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (savedProperties.isNotEmpty)
            TextButton(
              onPressed: _clearAllFavorites,
              child: const Text(
                "Clear All",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
        ],

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : token == null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                "You need to log in to view your favorite properties.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Login()),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text("Login"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : savedProperties.isEmpty
          ? const Center(child: Text("No favorite properties found."))
          : ListView.builder(
        itemCount: savedProperties.length,
        itemBuilder: (context, index) {
          final item = savedProperties[index];

          print('🏷️ Property ${item.id} using URL → "${item.image}"');
          return Padding(
            padding: const EdgeInsets.all(8.0),
              child:Card(
                elevation: 5,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Stack(
                      clipBehavior: Clip.none,
                      children: [
                      // ✅ Tapping the image opens Product_Detail
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Featured_Detail(data: item.id.toString()),
                            ),
                          );
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🖼️ Image + agent avatar
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 1.5,
                                child: Stack(
                                  children: [
                                    PageView.builder(
                                      itemCount: (item.media?.isNotEmpty ?? false) ? item.media!.length : 1,

                                      onPageChanged: (index) {
                                        final propertyId = int.tryParse(item.id ?? '') ?? index;
                                        setState(() {
                                          _carouselPageIndex[propertyId] = index;
                                        });
                                      },
                                        itemBuilder: (context, pageIndex) {
                                          String imageUrl;
                                          if (item.media != null && item.media!.isNotEmpty) {
                                            imageUrl = item.media![pageIndex].originalUrl ?? '';
                                          } else {
                                            imageUrl = item.image ?? 'https://via.placeholder.com/400x300.png?text=No+Image';
                                          }

                                          if (!imageUrl.startsWith('http')) {
                                            imageUrl = 'https://akarat.com/$imageUrl';
                                          }

                                          return CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                            errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                                          );
                                        }

                                    ),

                                    if (item.media != null && item.media!.length > 1)
                                      Positioned(
                                        bottom: 10,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(item.media!.length, (dotIndex) {
                                            final propertyId = int.tryParse(item.id ?? '') ?? dotIndex;
                                            final currentIndex = _carouselPageIndex[propertyId] ?? 0;
                                            return Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 3),
                                              width: currentIndex == dotIndex ? 10 : 6,
                                              height: currentIndex == dotIndex ? 10 : 6,
                                              decoration: BoxDecoration(
                                                color: currentIndex == dotIndex ? Colors.white : Colors.white60,
                                                shape: BoxShape.circle,
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),






                            // Agent avatar section (unchanged)
                            Positioned(
                              bottom: -30,
                              left: 10,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Featured_Detail(data: item.id.toString()),
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
                                      offset: const Offset(-5, 0),
                                      child: const Text(
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
                                    item.agent ?? 'Agent',
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

                        // 🏷️ Title and Price
                        Text(
                          item.title,
                          style: const TextStyle(fontSize: 16, height: 1.4),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'AED ${item.price}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 5),

                        // 📍 Location
                        Row(
                          children: [
                            Image.asset("assets/images/map.png", height: 14),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                item.location,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 🛏️ Specs Row
                        Row(
                          children: [
                            Image.asset("assets/images/bed.png", height: 13),
                            const SizedBox(width: 5),
                            Text(item.bedrooms.toString()),
                            const SizedBox(width: 10),
                            Image.asset("assets/images/bath.png", height: 13),
                            const SizedBox(width: 5),
                            Text(item.bathrooms.toString()),
                            const SizedBox(width: 10),
                            Image.asset("assets/images/messure.png", height: 13),
                            const SizedBox(width: 5),
                            Text(item.squareFeet),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // 📞 Call / WhatsApp Buttons
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final phone = 'tel:${item.phoneNumber}';
                                  await launchUrlString(phone, mode: LaunchMode.externalApplication);
                                },
                                icon: const Icon(Icons.call, color: Colors.red),
                                label: const Text("Call", style: TextStyle(color: Colors.black)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final link = 'https://wa.me/${item.whatsapp}';
                                  await launchUrlString(link, mode: LaunchMode.externalApplication);
                                },
                                icon: Image.asset("assets/images/whats.png", height: 20),
                                label: const Text("WhatsApp", style: TextStyle(color: Colors.black)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ], ),

          ],),),),);
        },
      ),

    );
  }
}

Future<bool> _urlExists(String url) async {
  try {
    final resp = await http.head(Uri.parse(url));
    return resp.statusCode == 200;
  } catch (_) {
    return false;
  }
}

Future<String> resolveImageUrl(String? rawUrl) async {
  if (rawUrl == null || rawUrl.isEmpty) {
    return 'https://via.placeholder.com/400x300.png?text=No+Image';
  }

  // Prefer rawUrl if it exists
  if (await _urlExists(rawUrl)) return rawUrl;

  // Fallback: prepend domain if needed
  if (!rawUrl.startsWith('http')) {
    final full = 'https://akarat.com/$rawUrl';
    if (await _urlExists(full)) return full;
  }

  // As last resort, placeholder
  return 'https://via.placeholder.com/400x300.png?text=No+Image';
}





