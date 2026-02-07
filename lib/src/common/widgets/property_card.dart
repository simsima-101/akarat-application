import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/services/api_service.dart';
import '../../core/utils/secure_storage.dart';
import '../../core/utils/session_manager.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/localization/presentation/bloc/localization_cubit.dart';
import '../../features/property/data/models/property_model.dart';
import '../../features/property/presentation/bloc/favorite_bloc.dart';
import '../../features/property/presentation/bloc/favorite_event.dart';
import '../../features/property/presentation/bloc/favorite_state.dart';
import '../../screen/featured_detail.dart';
import '../../screen/login.dart';

class PropertyCard extends StatelessWidget {
  final Property item;

  const PropertyCard({super.key, required this.item});

  int get propertyId => int.tryParse(item.id) ?? 0;

  String _formatAgentName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'Agent';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0]} ${parts[1]}';
    return parts.isNotEmpty ? parts[0] : 'Agent';
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

  Future<bool> markAsContacted(
      BuildContext context,
      int propertyId, {
        required String contactType,
      }) async {
    if (propertyId <= 0) return false;

    final token = SessionManager().token ?? await SecureStorage.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final currentLang = context.read<LocalizationCubit>().state.language;

      debugPrint('→ markAsContacted → Accept-Language: $currentLang');

      final response = await http.post(
        ApiService.buildUri('property-contact'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept-Language': currentLang,
        },
        body: jsonEncode({
          "property_id": propertyId,
          "contact_type": contactType,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error marking as contacted: $e');
      return false;
    }
  }

  // Helper to safely load any image with fallback
  Widget _safeCachedImage(
      String? url, {
        double? height,
        double? width,
        BoxFit fit = BoxFit.cover,
        Widget? placeholder,
        Widget? errorWidget,
      }) {
    if (url == null || url.trim().isEmpty) {
      return Container(
        height: height,
        width: width,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey, size: 32),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) =>
      placeholder ?? const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (context, url, error) =>
      errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey, size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Featured_Detail(data: item.id)),
      ),
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
                PropertyImageCarousel(item: item),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _formatAgentName(item.agent),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _safeCachedImage(
                        item.agencyLogo,
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                        errorWidget: const Icon(Icons.business, color: Colors.grey, size: 20),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(thickness: 0.3),
                const SizedBox(height: 8),

                Text(
                  item.title ?? 'No title',
                  style: const TextStyle(fontSize: 16, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  '${item.price ?? 'Price on request'} AED',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 5),

                Row(
                  children: [
                    Image.asset("assets/images/map.png", height: 14),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.location ?? 'Location not available',
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (item.bedrooms > 0) ...[
                      Image.asset("assets/images/bed.png", height: 14),
                      const SizedBox(width: 5),
                      Text("${item.bedrooms}", style: const TextStyle(fontSize: 13)),
                    ],
                    if (item.bathrooms > 0) ...[
                      if (item.bedrooms > 0) const SizedBox(width: 12),
                      Image.asset("assets/images/bath.png", height: 14),
                      const SizedBox(width: 5),
                      Text("${item.bathrooms}", style: const TextStyle(fontSize: 13)),
                    ],
                    if (item.displaySize.isNotEmpty) ...[
                      if (item.bedrooms > 0 || item.bathrooms > 0) const SizedBox(width: 12),
                      Image.asset("assets/images/messure.png", height: 14),
                      const SizedBox(width: 5),
                      Text(item.displaySize, style: const TextStyle(fontSize: 13)),
                    ],
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await markAsContacted(context, propertyId, contactType: "call");
                          final phone = 'tel:${phoneCallNumber(item.phoneNumber ?? '')}';
                          if (await canLaunchUrlString(phone)) await launchUrlString(phone);
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
                          await markAsContacted(context, propertyId, contactType: "whatsapp");
                          final url = "https://wa.me/${whatsAppNumber(item.whatsapp ?? '')}"
                              "?text=${Uri.encodeComponent("Hi, I'm interested in your property: ${item.title ?? ''}")}";
                          if (await canLaunchUrlString(url)) await launchUrlString(url);
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// PropertyImageCarousel (updated with safe image loading)
// ──────────────────────────────────────────────

class PropertyImageCarousel extends StatefulWidget {
  final Property item;

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
    _pageController.addListener(() {
      setState(() {}); // For smooth swipe animation
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _safeCachedImage(String? url) {
    if (url == null || url.trim().isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
      errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaList = widget.item.media ?? [];
    final hasMultiple = mediaList.length > 1;
    final mainImage = widget.item.image ?? '';

    final double currentPage = _pageController.hasClients
        ? (_pageController.page ?? 0.0)
        : _currentImageIndex.toDouble();

    final int currentIndex = currentPage.round();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1.4,
            child: hasMultiple
                ? PageView.builder(
              controller: _pageController,
              itemCount: mediaList.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (_, i) => _safeCachedImage(mediaList[i].originalUrl),
            )
                : _safeCachedImage(mainImage),
          ),
        ),

        // Minimal Dots Indicator
        if (hasMultiple)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 14,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(mediaList.length, (index) {
                      final distance = (index - currentIndex).abs();
                      if (distance > 2) return const SizedBox.shrink();

                      final bool isCurrent = distance == 0;
                      final bool isAdjacent = distance == 1;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: isCurrent ? 11 : 8,
                        height: isCurrent ? 11 : 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isCurrent ? 1.0 : isAdjacent ? 0.5 : 0.3),
                          shape: BoxShape.circle,
                          boxShadow: isCurrent
                              ? [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                              : null,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

        // Favorite Button
        Positioned(
          top: 10,
          right: 10,
          child: Material(
            color: Colors.transparent,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final isLoggedIn = authState is AuthAuthenticated;

                return BlocBuilder<FavoriteBloc, FavoriteState>(
                  builder: (context, favState) {
                    final propertyId = int.tryParse(widget.item.id) ?? 0;
                    final isFavorited = favState is FavoriteLoaded &&
                        favState.favoriteIds.contains(propertyId);

                    return IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: isFavorited ? Colors.red : Colors.white,
                        shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                        size: 28,
                      ),
                      onPressed: () {
                        if (!isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginDemo()),
                          );
                          return;
                        }

                        context.read<FavoriteBloc>().add(
                          ToggleFavorite(propertyId: propertyId),
                        );
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
          bottom: -35,
          left: 2,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Featured_Detail(data: widget.item.id),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _safeCachedImage(widget.item.agentImage),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "AGENT",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A73E9),
                    letterSpacing: 0.6,
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