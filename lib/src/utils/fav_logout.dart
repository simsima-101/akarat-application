// lib/src/screen/fav_logout.dart

import 'package:Akarat/src/core/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/widgets/property_card.dart';
import '../core/services/api_service.dart';
import '../core/utils/session_manager.dart';
import '../features/property/data/models/property_model.dart'; // Unified Property model
import '../features/property/presentation/bloc/favorite_bloc.dart';
import '../features/property/presentation/bloc/favorite_event.dart';
import '../features/property/presentation/bloc/favorite_state.dart';
import '../screen/ContactFormScreen.dart';
import '../screen/home.dart';
import '../screen/login.dart';
import '../screen/my_account.dart';

class Fav_Logout extends StatefulWidget {
  const Fav_Logout({super.key});

  @override
  State<Fav_Logout> createState() => _Fav_LogoutState();
}

// ======================== EXTENSION: Convert featured.Data → Property ========================

// ======================================================================================

class _Fav_LogoutState extends State<Fav_Logout> {
  int pageIndex = 2;
  String? token;
  bool hasCheckedLogin = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final currentToken = await SecureStorage.getToken();

      setState(() {
        token = currentToken;
        hasCheckedLogin = true;
      });

      if (currentToken != null && currentToken.isNotEmpty) {
        context.read<FavoriteBloc>().add(const LoadFavorites());
      }
    });
  }

  Future<void> refreshFavorites() async {
    final currentToken = await SecureStorage.getToken();
    if (currentToken == null || currentToken.isEmpty) return;
    context.read<FavoriteBloc>().add(const LoadFavorites());
  }

  Future<void> _clearAllFavorites() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Clear All Favorites?"),
        content: const Text(
            "This will remove all saved properties from your favorites. This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Clear All",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final currentToken =
        SessionManager().token ?? await SecureStorage.getToken();
    if (currentToken == null || currentToken.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("You are not logged in")));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Row(
        children: const [
          SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 16),
          Text("Clearing all favorites..."),
        ],
      ),
      duration: const Duration(seconds: 10),
    ));
    try {
      // final response = await http.delete(
      //   ApiService.buildUri('saved-properties/delete-all'),   // ← This is the key change!
      //   headers: {
      //     'Authorization': 'Bearer $currentToken',
      //     'Accept': 'application/json',
      //     'Content-Type': 'application/json',
      //   },
      // );

      final response = await ApiService.delete(
        'saved-properties/delete-all',
        headers: {
          'Authorization': 'Bearer $currentToken',
        },
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 200 || response.statusCode == 204) {
        context.read<FavoriteBloc>().add(const LoadFavorites());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: const Text("All favorites cleared successfully"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
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
        content: const Text("Error clearing favorites. Check your connection."),
        backgroundColor: Colors.red,
      ));
    }
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/home.png", height: 25),
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: null,
            icon: const Icon(Icons.favorite, color: Colors.red, size: 30),
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
            onPressed: () => showHomeContactDialog(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              enableFeedback: false,
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const My_Account())),
              icon: const Icon(Icons.dehaze, color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!hasCheckedLogin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isLoggedIn = token != null && token!.isNotEmpty;

    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        // Not logged in
        if (!isLoggedIn) {
          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.red),
              title: const Text("Favorites",
                  style: TextStyle(color: Colors.black)),
            ),
            body: _loginPrompt(context),
          );
        }

        // Loading
        if (state is FavoriteLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error
        if (state is FavoriteError) {
          final bool isUnauthorized = state.message.contains('401') ||
              state.message.contains('Unauthorized');

          if (isUnauthorized) {
            return Scaffold(
              backgroundColor: Colors.white,
              bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.red),
                title: const Text("Favorites",
                    style: TextStyle(color: Colors.black)),
              ),
              body: _loginPrompt(context),
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.red),
              title: const Text("Favorites",
                  style: TextStyle(color: Colors.black)),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: refreshFavorites, child: const Text("Retry")),
                ],
              ),
            ),
          );
        }

        // Loaded successfully
        // Loaded successfully
        if (state is FavoriteLoaded) {
          // No conversion needed anymore — favorites is already List<Property>
          final List<Property> favoriteProperties = state.favorites;

          final bool hasFavorites = favoriteProperties.isNotEmpty;

          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.red),
              title: const Text("Favorites",
                  style: TextStyle(color: Colors.black)),
              actions: [
                if (hasFavorites)
                  TextButton(
                    onPressed: _clearAllFavorites,
                    child: const Text("Clear All",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            body: hasFavorites
                ? RefreshIndicator(
                    onRefresh: refreshFavorites,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: favoriteProperties.length,
                      itemBuilder: (context, index) {
                        final Property property = favoriteProperties[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 4.0),
                          child: PropertyCard(item: property),
                        );
                      },
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: refreshFavorites,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border,
                                  size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 20),
                              const Text("No favorite properties yet",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 10),
                              const Text(
                                  "Tap the heart icon on any property to save it here",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const Home())),
                                icon: const Icon(Icons.explore,
                                    color: Colors.white),
                                label: const Text("Browse Properties",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        }

        // Fallback
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
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
            const Text("You need to log in to view your favorite properties.",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Login())),
              icon: const Icon(Icons.login),
              label: const Text("Login"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
