// lib/screen/fav_logout.dart
import 'package:Akarat/model/propertymodel.dart';
import 'package:Akarat/providers/filter_provider.dart';
import 'package:Akarat/secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../providers/favorite_provider.dart';
import '../screen/ContactFormScreen.dart';
import '../screen/featured_detail.dart';
import '../screen/home.dart';
import '../screen/login.dart';
import '../screen/my_account.dart';

class Fav_Logout extends StatefulWidget {
  const Fav_Logout({super.key});

  @override
  State<Fav_Logout> createState() => _Fav_LogoutState();
}

class _Fav_LogoutState extends State<Fav_Logout> {
  int pageIndex = 0; // For bottom nav icon state
  String? token;

  final Map<int, int> _carouselPageIndex = {};

  String getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/400x300.png?text=No+Image';
    }
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

  // ✅ Clear ALL favorites (server + provider + local UI)
  void _clearAllFavorites() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Clear All Favorites?"),
        content: const Text(
            "This will remove all saved properties from your favorites."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) return;

    final base = FavoriteProvider.apiBase;
    try {
      final response = await http.delete(
        Uri.parse('$base/saved-properties/delete-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      if (response.statusCode == 200) {
        context.read<FavoriteProvider>().clearFavorites();

        if (!mounted) return;

        final favState = context.read<FavoriteProvider>();

        setState(() {
          for (var item in favState.savedProperties) {
            item.saved = false;
          }
          favState.savedProperties.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All favorites cleared successfully.")),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Failed to clear favorites: ${response.statusCode}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error clearing favorites: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // First load when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      String? fToken = await SecureStorage.getToken();

      setState(() {
        token = fToken;
      });

      // 1. Load full property details from server (images, price, etc.)
      context.read<FavoriteProvider>().fetchSavedProperties();

      // 2. Also do a fast sync of favorite IDs from provider (in case user added from another screen)
      context.read<FavoriteProvider>().syncFromServer(merge: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // This runs EVERY TIME the screen becomes visible again (perfect!)
    // → User came back from detail screen, home, or another tab

    // Fast: Update favorite IDs immediately (so new items appear instantly)
    context.read<FavoriteProvider>().syncFromServer(merge: true);

    // Then: Refresh full property data (safe, non-blocking)
    Future.microtask(() {
      if (mounted) {
        context.read<FavoriteProvider>().fetchSavedProperties();
      }
    });
  }

  Future<void> refreshFavorites() async {
    context.read<FavoriteProvider>().fetchSavedProperties();
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/home.png", height: 25),
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: null,
            icon: pageIndex == 2
                ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                : const Icon(Icons.favorite_border_outlined,
                    color: Colors.red, size: 30),
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
            onPressed: () => showHomeContactDialog(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => My_Account()));
              },
              icon: pageIndex == 3
                  ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                  : const Icon(Icons.dehaze_outlined,
                      color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(builder: (context, favoriteProvider, _) {
      final Set<int> currentFavoriteIds = favoriteProvider.ids;

      // Filter savedProperties to only show items that are actually favorited
      final List<Property> displayedProperties =
          favoriteProvider.savedProperties.where((property) {
        final id = int.tryParse(property.id ?? '') ?? 0;
        return currentFavoriteIds.contains(id);
      }).toList();

      return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: SafeArea(
            child: buildMyNavBar(context),
          ),
          appBar: AppBar(
            elevation: 0,
            surfaceTintColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.red),
            title:
                const Text("Favorites", style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            actions: [
              if (favoriteProvider.savedProperties.isNotEmpty)
                TextButton(
                  onPressed: _clearAllFavorites,
                  child: const Text("Clear All",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          body: favoriteProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : token == null || token!.isEmpty
                  ? _loginPrompt(context)
                  :
                  // Get current favorite IDs from provider (real-time)

                  // Show empty state if nothing is favorited
                  displayedProperties.isEmpty
                      ? RefreshIndicator(
                          onRefresh: favoriteProvider.fetchSavedProperties,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite_border,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      "No favorite properties yet",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Tap the heart icon on any property to save it here",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Consumer<FilterProvider>(
                                        builder: (context, filterListState, _) {
                                      return SizedBox(
                                        width: 220,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            // filterListState
                                            //   ..setInitialHomeCategory(0)
                                            //   ..resetAll(
                                            //     context,
                                            //     isUpdate: false,
                                            //   );
                                            //
                                            // await filterListState
                                            //     .setSelectedProductType(
                                            //   context,
                                            //   1,
                                            // );
                                            //
                                            // filterListState
                                            //     .captureInitialSnapshot();
                                            //
                                            // filterListState
                                            //     .updateFilterCount(context);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => Home(
                                                    // selectedPurpose: 'All',          // 👈 default purpose
                                                    // selectedPropertyType: 'All',     // 👈 default property type
                                                    ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.favorite_border,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            "Add to Favorites",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: favoriteProvider.fetchSavedProperties,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: displayedProperties.length,
                            itemBuilder: (context, index) {
                              final item = displayedProperties[index];
                              final propertyId =
                                  int.tryParse(item.id ?? '') ?? 0;

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 5,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Featured_Detail(
                                                            data: item.id
                                                                .toString()),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Image + Agent Avatar
                                                    Stack(
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          child: AspectRatio(
                                                            aspectRatio: 1.5,
                                                            child: Stack(
                                                              children: [
                                                                PageView
                                                                    .builder(
                                                                  itemCount: (item
                                                                              .media
                                                                              ?.isNotEmpty ??
                                                                          false)
                                                                      ? item
                                                                          .media!
                                                                          .length
                                                                      : 1,
                                                                  onPageChanged:
                                                                      (idx) {
                                                                    final pid =
                                                                        int.tryParse(item.id ??
                                                                                '') ??
                                                                            idx;
                                                                    setState(
                                                                        () {
                                                                      _carouselPageIndex[
                                                                              pid] =
                                                                          idx;
                                                                    });
                                                                  },
                                                                  itemBuilder:
                                                                      (context,
                                                                          pageIndex) {
                                                                    String
                                                                        imageUrl;
                                                                    if (item.media !=
                                                                            null &&
                                                                        item.media!
                                                                            .isNotEmpty) {
                                                                      imageUrl =
                                                                          item.media![pageIndex].originalUrl ??
                                                                              '';
                                                                    } else {
                                                                      imageUrl =
                                                                          item.image ??
                                                                              'https://via.placeholder.com/400x300.png?text=No+Image';
                                                                    }
                                                                    if (!imageUrl
                                                                        .startsWith(
                                                                            'http')) {
                                                                      imageUrl =
                                                                          'https://akarat.com/$imageUrl';
                                                                    }
                                                                    return CachedNetworkImage(
                                                                      imageUrl:
                                                                          imageUrl,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      placeholder: (context,
                                                                              url) =>
                                                                          const Center(
                                                                              child: CircularProgressIndicator()),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          const Icon(
                                                                              Icons.broken_image),
                                                                    );
                                                                  },
                                                                ),
                                                                if (item.media !=
                                                                        null &&
                                                                    item.media!
                                                                            .length >
                                                                        1)
                                                                  Positioned(
                                                                    bottom: 10,
                                                                    left: 0,
                                                                    right: 0,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children:
                                                                          List.generate(
                                                                        item.media!
                                                                            .length,
                                                                        (dotIndex) {
                                                                          final pid =
                                                                              int.tryParse(item.id ?? '') ?? dotIndex;
                                                                          final currentIndex =
                                                                              _carouselPageIndex[pid] ?? 0;
                                                                          return Container(
                                                                            margin:
                                                                                const EdgeInsets.symmetric(horizontal: 3),
                                                                            width: currentIndex == dotIndex
                                                                                ? 10
                                                                                : 6,
                                                                            height: currentIndex == dotIndex
                                                                                ? 10
                                                                                : 6,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: currentIndex == dotIndex ? Colors.white : Colors.white60,
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                        // FAVORITE HEART ICON (REAL-TIME)
                                                        Positioned(
                                                          top: 12,
                                                          right: 12,
                                                          child: Material(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.85),
                                                            shape:
                                                                const CircleBorder(),
                                                            child: Consumer<
                                                                FavoriteProvider>(
                                                              builder: (context,
                                                                  favProvider,
                                                                  _) {
                                                                final isFav =
                                                                    favProvider
                                                                        .isFavorite(
                                                                            propertyId);
                                                                return IconButton(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          6),
                                                                  icon: Icon(
                                                                    isFav
                                                                        ? Icons
                                                                            .favorite
                                                                        : Icons
                                                                            .favorite_border_outlined,
                                                                    color: isFav
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .grey,
                                                                    size: 22,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    if (token ==
                                                                            null ||
                                                                        token!
                                                                            .isEmpty) {
                                                                      _showLoginDialog(
                                                                          context);
                                                                      return;
                                                                    }

                                                                    final success = await context
                                                                        .read<
                                                                            FavoriteProvider>()
                                                                        .toggleFavoriteUnified(
                                                                            propertyId,
                                                                            context);

                                                                    if (success) {
                                                                      // No need to manually remove
                                                                      // Consumer will rebuild automatically
                                                                    }
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
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          Featured_Detail(
                                                                    data: item
                                                                        .id
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                CircleAvatar(
                                                                  radius: 28,
                                                                  backgroundImage: (item.agentImage !=
                                                                              null &&
                                                                          item.agentImage!
                                                                              .isNotEmpty)
                                                                      ? CachedNetworkImageProvider(item
                                                                          .agentImage!)
                                                                      : const AssetImage(
                                                                              "assets/images/dummy.jpg")
                                                                          as ImageProvider,
                                                                ),
                                                                const SizedBox(
                                                                    height: 6),
                                                                Transform
                                                                    .translate(
                                                                  offset:
                                                                      const Offset(
                                                                          -5,
                                                                          0),
                                                                  child:
                                                                      const Text(
                                                                    "AGENT",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Color(
                                                                          0xFF1A73E9),
                                                                      letterSpacing:
                                                                          0.5,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 15),

                                                    // Rest of your card content (unchanged)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 0,
                                                              right: 0,
                                                              top: 4,
                                                              bottom: 4),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10),
                                                              child: Text(
                                                                item.agent ??
                                                                    'Agent',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              if (item.postedOn !=
                                                                      null &&
                                                                  item.postedOn!
                                                                      .isNotEmpty)
                                                                Text(
                                                                  'Listed ${item.postedOn}',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              if (item.agencyLogo !=
                                                                      null &&
                                                                  item.agencyLogo!
                                                                      .isNotEmpty)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 60,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4),
                                                                      image:
                                                                          DecorationImage(
                                                                        image: CachedNetworkImageProvider(
                                                                            item.agencyLogo!),
                                                                        fit: BoxFit
                                                                            .contain,
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
                                                    const Divider(
                                                        color: Colors.grey,
                                                        thickness: 0.3,
                                                        height: 6),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      item.title,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          height: 1.4),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      'AED ${item.price}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 22,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                            "assets/images/map.png",
                                                            height: 14),
                                                        const SizedBox(
                                                            width: 5),
                                                        Expanded(
                                                          child: Text(
                                                            item.location,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        13),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                            "assets/images/bed.png",
                                                            height: 13),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(item.bedrooms
                                                            .toString()),
                                                        const SizedBox(
                                                            width: 10),
                                                        Image.asset(
                                                            "assets/images/bath.png",
                                                            height: 13),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(item.bathrooms
                                                            .toString()),
                                                        const SizedBox(
                                                            width: 10),
                                                        if (item.displaySize
                                                            .isNotEmpty) ...[
                                                          Image.asset(
                                                              "assets/images/messure.png",
                                                              height: 13),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(item.displaySize,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        ],
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: ElevatedButton
                                                              .icon(
                                                            onPressed:
                                                                () async {
                                                              final phone =
                                                                  'tel:${item.phoneNumber}';
                                                              await launchUrlString(
                                                                phone,
                                                                mode: LaunchMode
                                                                    .externalApplication,
                                                              );
                                                            },
                                                            icon: const Icon(
                                                                Icons.call,
                                                                color:
                                                                    Colors.red),
                                                            label: const Text(
                                                                "Call",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.grey[
                                                                      100],
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: ElevatedButton
                                                              .icon(
                                                            onPressed:
                                                                () async {
                                                              final link =
                                                                  'https://wa.me/${item.whatsapp}';
                                                              await launchUrlString(
                                                                link,
                                                                mode: LaunchMode
                                                                    .externalApplication,
                                                              );
                                                            },
                                                            icon: Image.asset(
                                                                "assets/images/whats.png",
                                                                height: 20),
                                                            label: const Text(
                                                                "WhatsApp",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.grey[
                                                                      100],
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                      ],
                                                    ),
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
                        ));
    });
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title:
            const Text("Login Required", style: TextStyle(color: Colors.black)),
        content: const Text("Please login to manage favorites.",
            style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginDemo()));
            },
            child: const Text("Login", style: TextStyle(color: Colors.red)),
          ),
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
            const Text(
              "You need to log in to view your favorite properties.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const Login()));
              },
              icon: const Icon(Icons.login),
              label: const Text("Login"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
