import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:Akarat/model/propertymodel.dart';
import 'package:Akarat/secure_storage.dart';
import 'package:Akarat/screen/product_detail.dart';


class Fav_Logout extends StatefulWidget {
  const Fav_Logout({super.key});

  @override
  State<Fav_Logout> createState() => _Fav_LogoutState();
}

class _Fav_LogoutState extends State<Fav_Logout> {
  List<Property> savedProperties = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _fetchSavedProperties();
  }

  Future<void> _fetchSavedProperties() async {
    token = await SecureStorage.getToken();
    if (token == null) return;
    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse('https://akarat.com/api/saved-property-list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Property> props = (data['data']['data'] as List)
          .map((e) => Property.fromJson(e))
          .toList();
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedProperties.isEmpty
          ? const Center(child: Text("No favorite properties found."))
          : ListView.builder(
        itemCount: savedProperties.length,
        itemBuilder: (context, index) {
          final item = savedProperties[index];

          print('🏷️ Property ${item.id} using URL → "${item.image}"');
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 5,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Product_Detail(data: item.id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0, top: 1, right: 5),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 1.5,
                          child: FutureBuilder<String>(
                            future: resolveImageUrl(item.image),
                            builder: (ctx, snap) {
                              if (snap.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final url = snap.data!;
                              return CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                      ),


                      ListTile(
                        title: Text(item.title, style: const TextStyle(fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "AED ${item.price}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          Image.asset("assets/images/map.png", height: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
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
                      ),
                      const SizedBox(height: 8),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
            ),
          );
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





