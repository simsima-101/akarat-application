// lib/src/common/widgets/property_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/utils/secure_storage.dart';
import '../../core/utils/session_manager.dart';
import '../../core/services/api_service.dart';
import '../../features/property/presentation/bloc/favorite_bloc.dart';
import '../../features/property/data/models/project_model.dart';
import '../../features/property/presentation/bloc/favorite_event.dart';
import '../../features/property/presentation/bloc/favorite_state.dart';
import '../../screen/featured_detail.dart';

class PropertyCard extends StatelessWidget {
  final Data item;

  const PropertyCard({super.key, required this.item});

  int _safePropertyId(dynamic id) {
    if (id == null) return 0;
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }

  String phoneCallNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (input.startsWith('+971')) return input;
    if (input.startsWith('00971')) return '+971${input.substring(5)}';
    if (input.startsWith('971')) return '+971${input.substring(3)}';
    if (input.startsWith('0') && input.length == 10) return '+971${input.substring(1)}';
    if (input.length == 9) return '+971$input';
    return input;
  }

  String whatsAppNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d]'), '');
    if (input.startsWith('971')) return input;
    if (input.startsWith('00971')) return input.substring(2);
    if (input.startsWith('+971')) return input.substring(1);
    if (input.startsWith('0') && input.length == 10) return '971${input.substring(1)}';
    if (input.length == 9) return '971$input';
    return input;
  }

  String _formatAgentName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'Agent';
    List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0]} ${parts[1]}';
    return parts.isNotEmpty ? parts[0] : 'Agent';
  }

  Future<bool> markAsContacted(BuildContext context, int propertyId, {required String contactType}) async {
    if (propertyId <= 0) return false;

    await SessionManager().restore();
    final token = SessionManager().token ?? await SecureStorage.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.post(
        ApiService.buildUri('property-contact'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"property_id": propertyId, "contact_type": contactType}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Featured_Detail(data: item.id.toString())),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Card(
          color: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel with its own state
                PropertyImageCarousel(item: item),

                const SizedBox(height: 15),

                // Agent name and listed info
                Padding(
                  padding: const EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            _formatAgentName(item.agentName),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (item.postedOn != null && item.postedOn!.isNotEmpty)
                            Text('Listed ${item.postedOn}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
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

                const SizedBox(height: 5),
                const Divider(color: Colors.grey, thickness: 0.3, height: 6),
                const SizedBox(height: 8),

                // Title
                Text(
                  item.title.toString(),
                  style: const TextStyle(fontSize: 16, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                const SizedBox(height: 5),

                // Price
                Text(
                  '${item.price} AED',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, height: 1.4),
                ),
                const SizedBox(height: 5),

                // Location
                Row(
                  children: [
                    Image.asset("assets/images/map.png", height: 14),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.location.toString(),
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Beds, Baths, Size
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (item.bedrooms != null && item.bedrooms! > 0) ...[
                      Image.asset("assets/images/bed.png", height: 14),
                      const SizedBox(width: 5),
                      Text("${item.bedrooms}", style: const TextStyle(fontSize: 13)),
                    ],
                    if (item.bathrooms != null && item.bathrooms! > 0) ...[
                      if (item.bedrooms != null && item.bedrooms! > 0) const SizedBox(width: 12),
                      Image.asset("assets/images/bath.png", height: 14),
                      const SizedBox(width: 5),
                      Text("${item.bathrooms}", style: const TextStyle(fontSize: 13)),
                    ],
                    if (item.displaySize.isNotEmpty) ...[
                      if ((item.bedrooms != null && item.bedrooms! > 0) || (item.bathrooms != null && item.bathrooms! > 0))
                        const SizedBox(width: 12),
                      Image.asset("assets/images/messure.png", height: 14),
                      const SizedBox(width: 5),
                      Text(item.displaySize, style: const TextStyle(fontSize: 13)),
                      // DLD Badge
                      // if (item.dldPermitInfo?.propertySize != null &&
                      //     num.tryParse(item.dldPermitInfo!.propertySize!.replaceAll(RegExp(r'[^0-9.]'), '')) != null &&
                      //     num.tryParse(item.dldPermitInfo!.propertySize!.replaceAll(RegExp(r'[^0-9.]'), ''))! > 0)
                      //   const Padding(
                      //     padding: EdgeInsets.only(left: 6),
                      //     child: Row(
                      //       children: [
                      //         Icon(Icons.verified, color: Colors.blue, size: 14),
                      //         Text(" DLD", style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                      //       ],
                      //     ),
                      //   ),
                    ],
                  ],
                ),

                const SizedBox(height: 15),

                // Call & WhatsApp buttons
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final propertyId = _safePropertyId(item.id);
                          final success = await markAsContacted(context, propertyId, contactType: "call");

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Added to contacted properties"),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }

                          final phone = 'tel:${phoneCallNumber(item.phoneNumber ?? '')}';
                          if (await canLaunchUrlString(phone)) {
                            await launchUrlString(phone, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.call, color: Colors.red),
                        label: const Text("Call", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final propertyId = _safePropertyId(item.id);
                          final success = await markAsContacted(context, propertyId, contactType: "whatsapp");

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Added to contacted properties"),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }

                          final phone = whatsAppNumber(item.whatsapp ?? '');
                          final message = Uri.encodeComponent("Hi, I'm interested in your property: ${item.title}");
                          final url = Uri.parse("https://wa.me/$phone?text=$message");

                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("WhatsApp not installed")),
                            );
                          }
                        },
                        icon: Image.asset("assets/images/whats.png", height: 20),
                        label: const Text("WhatsApp", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
  }
}

// Separate StatefulWidget for the image carousel
class PropertyImageCarousel extends StatefulWidget {
  final Data item;

  const PropertyImageCarousel({super.key, required this.item});

  @override
  State<PropertyImageCarousel> createState() => _PropertyImageCarouselState();
}

class _PropertyImageCarouselState extends State<PropertyImageCarousel> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaList = widget.item.media ?? [];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: mediaList.isEmpty
                ? Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported, size: 50))
                : PageView.builder(
              controller: _pageController,
              itemCount: mediaList.length,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: mediaList[index].originalUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                );
              },
            ),
          ),
        ),

        // Image indicator dots
        if (mediaList.isNotEmpty)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(mediaList.length, (i) {
                final distance = (i - _currentImageIndex).abs();
                double scale = distance == 0 ? 1.2 : distance == 1 ? 1.0 : 0.8;
                double opacity = distance == 0 ? 1.0 : distance == 1 ? 0.7 : 0.5;

                return AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8 * scale,
                    height: 8 * scale,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                );
              }),
            ),
          ),

        // Favorite Button
        Positioned(
          top: 10,
          right: 10,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
            child: FutureBuilder<String?>(
              future: SecureStorage.getToken(),
              builder: (context, snapshot) {
                final bool isLoggedIn = snapshot.data != null && snapshot.data!.isNotEmpty;

                return BlocSelector<FavoriteBloc, FavoriteState, bool>(
                  selector: (state) {
                    if (state is FavoriteLoaded) {
                      final propertyId = int.tryParse(widget.item.id.toString()) ?? 0;
                      return state.favorites.any((p) => int.tryParse(p.id ?? '') == propertyId);
                    }
                    return false;
                  },
                  builder: (context, isFavorite) {
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      onPressed: () async {
                        if (!isLoggedIn) {
                          showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: EdgeInsets.zero,
                              child: Container(
                                height: 70,
                                margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
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
                                            child: Text('Login required to add favorites.', style: TextStyle(color: Colors.white, fontSize: 13)),
                                          ),
                                          const SizedBox(width: 12),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(ctx).pop();
                                              Navigator.of(context).pushNamed('/login');
                                            },
                                            child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
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

                        final propertyId = int.tryParse(widget.item.id.toString()) ?? 0;
                        context.read<FavoriteBloc>().add(ToggleFavorite(propertyId: propertyId));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),

        // Agent Avatar
        Positioned(
          bottom: -30,
          left: 10,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Featured_Detail(data: widget.item.id.toString())),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: (widget.item.agentImage != null && widget.item.agentImage!.isNotEmpty)
                      ? CachedNetworkImageProvider(widget.item.agentImage!)
                      : const AssetImage("assets/images/dummy.jpg") as ImageProvider,
                ),
                const SizedBox(height: 6),
                Transform.translate(
                  offset: const Offset(-5, 0),
                  child: const Text(
                    "AGENT",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1A73E9), letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}