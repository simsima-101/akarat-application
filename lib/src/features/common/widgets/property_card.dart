
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../screen/featured_detail.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../property/presentation/bloc/favorite_bloc.dart';
import '../../property/presentation/bloc/favorite_event.dart';
import '../../property/presentation/bloc/favorite_state.dart';

import 'package:Akarat/src/features/property/data/models/featuredmodel.dart' as featured;


class PropertyCard extends StatelessWidget {
  final featured.Data item;

  const PropertyCard({super.key, required this.item});

  String _formatAgentName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'Agent';
    List<String> parts = fullName.trim().split(RegExp(r'\s+'));
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

  int _safePropertyId(dynamic id) {
    if (id == null) return 0;
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Featured_Detail(data: item.id.toString()),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel + Favorite Button + Agent Avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1.4,
                        child: PageView.builder(
                          itemCount: item.media?.length ?? 0,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: item.media![index].originalUrl.toString(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[200]),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    ),

                    // Favorite Icon - Efficient with BlocSelector
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: BlocSelector<FavoriteBloc, FavoriteState, bool>(
                          selector: (state) {
                            if (state is FavoriteLoaded) {
                              final propertyId = _safePropertyId(item.id);
                              return state.favoriteIds.contains(propertyId);
                            }
                            return false;
                          },
                          builder: (context, isFavorite) {
                            return IconButton(
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  key: ValueKey(isFavorite),
                                  color: isFavorite ? Colors.red : Colors.grey,
                                  size: 28,
                                ),
                              ),
                              onPressed: () {
                                final authState = context.read<AuthBloc>().state;
                                if (authState is! AuthAuthenticated) {
                                  context.read<AuthBloc>().add(ShowLoginRequiredDialog(context));
                                  return;
                                }

                                final propertyId = _safePropertyId(item.id);
                                context.read<FavoriteBloc>().add(ToggleFavorite(propertyId: propertyId));
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
                            MaterialPageRoute(
                              builder: (_) => Featured_Detail(data: item.id.toString()),
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
                            const Text(
                              "AGENT",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A73E9),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40), // Space for overlapping avatar

                // Agent Name + Listed + Agency Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _formatAgentName(item.agentName),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          if (item.postedOn?.isNotEmpty == true)
                            Text('Listed ${item.postedOn}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(width: 4),
                          if (item.agencyLogo?.isNotEmpty == true)
                            Container(
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
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 20, thickness: 0.3),

                Text(
                  item.title.toString(),
                  style: const TextStyle(fontSize: 16, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),
                Text('${item.price} AED', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset("assets/images/map.png", height: 14),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.location.toString(),
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
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
                      if ((item.bedrooms ?? 0) > 0 || (item.bathrooms ?? 0) > 0) const SizedBox(width: 12),
                      Image.asset("assets/images/messure.png", height: 14),
                      const SizedBox(width: 5),
                      Text(item.displaySize, style: const TextStyle(fontSize: 13)),
                    ],
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String phone = 'tel:${phoneCallNumber(item.phoneNumber ?? '')}';
                          if (await canLaunchUrlString(phone)) {
                            await launchUrlString(phone, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.call, color: Colors.red),
                        label: const Text("Call", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final phone = whatsAppNumber(item.whatsapp ?? '');
                          final message = Uri.encodeComponent("Hi, I'm interested in your property: ${item.title}");
                          final url = "https://wa.me/$phone?text=$message";
                          if (await canLaunchUrlString(url)) {
                            await launchUrlString(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: Image.asset("assets/images/whats.png", height: 20),
                        label: const Text("WhatsApp", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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