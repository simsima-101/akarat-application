import 'package:Akarat/src/core/utils/secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

import '../core/utils/session_manager.dart';
import '../features/property/presentation/bloc/favorite_bloc.dart';

import '../features/property/presentation/bloc/favorite_state.dart';
import '../screen/ContactFormScreen.dart'; // Keep if used
import '../screen/featured_detail.dart';
import '../screen/home.dart';
import '../screen/login.dart';
import '../screen/my_account.dart';
import '../features/property/data/models/property_model.dart';

import '../features/property/presentation/bloc/favorite_event.dart';

class Fav_Logout extends StatefulWidget {
  const Fav_Logout({super.key});

  @override
  State<Fav_Logout> createState() => _Fav_LogoutState();
}

class _Fav_LogoutState extends State<Fav_Logout> {
  int pageIndex = 0;
  String? token;

  final Map<int, int> _carouselPageIndex = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final fToken = await SecureStorage.getToken();
      setState(() {
        token = fToken;
      });

      context.read<FavoriteBloc>().add(const LoadFavorites());
    });
  }

  Future<void> refreshFavorites() async {
    context.read<FavoriteBloc>().add(const LoadFavorites());
  }

  Future<void> _clearAllFavorites() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Clear All Favorites?"),
        content: const Text("This will remove all saved properties from your favorites. This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Clear All", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm != true) return;

    final currentToken = SessionManager().token ?? await SecureStorage.getToken();
    if (currentToken == null || currentToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You are not logged in")));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Row(children: [
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        SizedBox(width: 16),
        Text("Clearing all favorites..."),
      ]),
      duration: Duration(seconds: 10),
    ));

    try {
      final response = await http.delete(
        Uri.parse('https://akarat.com/api/saved-properties/delete-all'),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 200 || response.statusCode == 204) {
        context.read<FavoriteBloc>().add(const LoadFavorites());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("All favorites cleared successfully"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to clear favorites: ${response.statusCode}"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error clearing favorites. Check your connection."),
        backgroundColor: Colors.red,
      ));
      debugPrint("Clear favorites error: $e");
    }
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Image.asset("assets/images/home.png", height: 25)),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: null,
            icon: pageIndex == 2
                ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                : const Icon(Icons.favorite_border_outlined, color: Colors.red, size: 30),
          ),
          IconButton(icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28), onPressed: () => showHomeContactDialog(context)),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              enableFeedback: false,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const My_Account())),
              icon: pageIndex == 3
                  ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                  : const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = token != null && token!.isNotEmpty;

    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        if (state is FavoriteLoading) {
          return Scaffold(appBar: AppBar(title: const Text("Favorites")), body: const Center(child: CircularProgressIndicator()));
        }

        if (state is FavoriteError) {
          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
            appBar: AppBar(
              elevation: 0,
              surfaceTintColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.red),
              title: const Text("Favorites", style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: () => context.read<FavoriteBloc>().add(const LoadFavorites()), child: const Text("Retry")),
                ],
              ),
            ),
          );
        }

        if (state is FavoriteLoaded) {
          final favorites = state.favorites;

          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
            appBar: AppBar(
              elevation: 0,
              surfaceTintColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.red),
              title: const Text("Favorites", style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              actions: [
                if (favorites.isNotEmpty)
                  TextButton(onPressed: _clearAllFavorites, child: const Text("Clear All", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
              ],
            ),
            body: !isLoggedIn
                ? _loginPrompt(context)
                : favorites.isEmpty
                ? RefreshIndicator(
              onRefresh: refreshFavorites,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 20),
                        const Text("No favorite properties yet", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        const Text("Tap the heart icon on any property to save it here", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Home())),
                          icon: const Icon(Icons.explore, color: Colors.white),
                          label: const Text("Browse Properties", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: refreshFavorites,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  final propertyId = int.tryParse(item.id ?? '') ?? 0;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
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
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Featured_Detail(data: item.id ?? ''))),
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
                                                child: Stack(
                                                  children: [
                                                    PageView.builder(
                                                      itemCount: (item.media?.isNotEmpty ?? false) ? item.media!.length : 1,
                                                      onPageChanged: (idx) => setState(() => _carouselPageIndex[propertyId] = idx),
                                                      itemBuilder: (context, pageIndex) {
                                                        String imageUrl = item.media?[pageIndex].originalUrl ?? item.image ?? '';
                                                        if (imageUrl.isEmpty) imageUrl = 'https://via.placeholder.com/400x300.png?text=No+Image';
                                                        if (!imageUrl.startsWith('http')) imageUrl = 'https://akarat.com/$imageUrl';

                                                        return CachedNetworkImage(
                                                          imageUrl: imageUrl,
                                                          fit: BoxFit.cover,
                                                          placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                                          errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                                                        );
                                                      },
                                                    ),
                                                    if (item.media != null && item.media!.length > 1)
                                                      Positioned(
                                                        bottom: 10,
                                                        left: 0,
                                                        right: 0,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: List.generate(item.media!.length, (dotIndex) {
                                                            final current = _carouselPageIndex[propertyId] ?? 0;
                                                            return Container(
                                                              margin: const EdgeInsets.symmetric(horizontal: 3),
                                                              width: current == dotIndex ? 10 : 6,
                                                              height: current == dotIndex ? 10 : 6,
                                                              decoration: BoxDecoration(color: current == dotIndex ? Colors.white : Colors.white60, shape: BoxShape.circle),
                                                            );
                                                          }),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            // Favorite Heart Button
                                            Positioned(
                                              top: 12,
                                              right: 12,
                                              child: Material(
                                                color: Colors.white.withOpacity(0.85),
                                                shape: const CircleBorder(),
                                                child: BlocBuilder<FavoriteBloc, FavoriteState>(
                                                  builder: (context, favState) {
                                                    final isFavorite = favState is FavoriteLoaded && favState.favoriteIds.contains(propertyId);

                                                    return IconButton(
                                                      padding: const EdgeInsets.all(6),
                                                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border_outlined, color: isFavorite ? Colors.red : Colors.grey, size: 22),
                                                      onPressed: () {
                                                        if (!isLoggedIn) {
                                                          _showLoginDialog(context);
                                                          return;
                                                        }
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
                                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Featured_Detail(data: item.id ?? ''))),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 28,
                                                      backgroundImage: (item.agentImage?.isNotEmpty ?? false)
                                                          ? CachedNetworkImageProvider(item.agentImage!)
                                                          : const AssetImage("assets/images/dummy.jpg") as ImageProvider,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    const Text("AGENT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1A73E9), letterSpacing: 0.5)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 15),

                                        // Property Details
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Padding(padding: const EdgeInsets.only(left: 10), child: Text(item.agent ?? 'Agent', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))),
                                            Row(children: [
                                              if (item.postedOn?.isNotEmpty ?? false) Text('Listed ${item.postedOn}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                              const SizedBox(width: 4),
                                              if (item.agencyLogo?.isNotEmpty ?? false)
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    height: 30,
                                                    width: 60,
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), image: DecorationImage(image: CachedNetworkImageProvider(item.agencyLogo!), fit: BoxFit.contain)),
                                                  ),
                                                ),
                                            ]),
                                          ],
                                        ),

                                        const SizedBox(height: 5),
                                        const Divider(color: Colors.grey, thickness: 0.3),
                                        const SizedBox(height: 8),

                                        Text(item.title ?? '', style: const TextStyle(fontSize: 16, height: 1.4), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 5),
                                        Text('AED ${item.price ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                                        const SizedBox(height: 5),

                                        Row(children: [
                                          Image.asset("assets/images/map.png", height: 14),
                                          const SizedBox(width: 5),
                                          Expanded(child: Text(item.location ?? '', overflow: TextOverflow.ellipsis)),
                                        ]),

                                        const SizedBox(height: 8),

                                        Row(children: [
                                          Image.asset("assets/images/bed.png", height: 13),
                                          const SizedBox(width: 5),
                                          Text(item.bedrooms?.toString() ?? '0'),
                                          const SizedBox(width: 10),
                                          Image.asset("assets/images/bath.png", height: 13),
                                          const SizedBox(width: 5),
                                          Text(item.bathrooms?.toString() ?? '0'),
                                          const SizedBox(width: 10),
                                          if (item.displaySize?.isNotEmpty ?? false) ...[
                                            Image.asset("assets/images/messure.png", height: 13),
                                            const SizedBox(width: 5),
                                            Text(item.displaySize!, style: const TextStyle(fontWeight: FontWeight.w500)),
                                          ],
                                        ]),

                                        const SizedBox(height: 10),

                                        Row(children: [
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => launchUrlString('tel:${item.phoneNumber}', mode: LaunchMode.externalApplication),
                                              icon: const Icon(Icons.call, color: Colors.red),
                                              label: const Text("Call", style: TextStyle(color: Colors.black)),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[100], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => launchUrlString('https://wa.me/${item.whatsapp}', mode: LaunchMode.externalApplication),
                                              icon: Image.asset("assets/images/whats.png", height: 20),
                                              label: const Text("WhatsApp", style: TextStyle(color: Colors.black)),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[100], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                        ]),

                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }

        // Fallback
        return Scaffold(appBar: AppBar(title: const Text("Favorites")), body: const Center(child: CircularProgressIndicator()));
      },
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Login Required", style: TextStyle(color: Colors.black)),
        content: const Text("Please login to manage favorites.", style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.red))),
          TextButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginDemo()), (route) => false), child: const Text("Login", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _loginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text("You need to log in to view your favorite properties.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Login())),
              icon: const Icon(Icons.login),
              label: const Text("Login"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
          ],
        ),
      ),
    );
  }
}