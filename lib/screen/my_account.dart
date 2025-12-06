// lib/screen/my_account.dart
import 'dart:convert';

// Screens
import 'package:Akarat/screen/about_us.dart';
import 'package:Akarat/screen/findagent.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/privacy.dart';
import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/saved_alert_screen.dart';
import 'package:Akarat/screen/support.dart';
import 'package:Akarat/screen/terms_condition.dart';
import 'package:Akarat/utils/fav_logout.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Providers / Services
import '../providers/profile_image_provider.dart';
import '../secure_storage.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../services/session.dart';
import '../widgets/custom_alert_box.dart';
import 'ContactFormScreen.dart';
import 'login.dart';
import 'personal_information.dart';

class My_Account extends StatefulWidget {
  const My_Account({super.key});

  @override
  State<My_Account> createState() => _My_AccountState();
}

class _My_AccountState extends State<My_Account> {
  // These will be filled from Session().restore()
  String? userName;
  String? userEmail;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Now fully async + restores real name
  }

  /// Load real user data from Session (which restores from SecureStorage)
  Future<void> _loadUserData() async {
    await Session().restore(); // This is the magic fix

    if (!mounted) return;

    setState(() {
      userName = Session().userName?.trim().isNotEmpty == true
          ? Session().userName!.trim()
          : 'User';
      userEmail = Session().userEmail?.trim().isNotEmpty == true
          ? Session().userEmail!.trim()
          : '';
    });
  }

  /// Smart display name — never shows "User" unless truly not logged in
  String get _displayName {
    if (userName == null || userName == 'User' || userName!.trim().isEmpty) {
      return 'Welcome! Login / Sign up';
    }
    return userName!;
  }

  /// Check if user is truly logged in (uses Session)
  bool get _isLoggedIn =>
      Session().isAuthenticated &&
      userName != 'User' &&
      userName?.isNotEmpty == true;

  // ===================== LOGOUT =====================
  Future<void> _logout() async {
    try {
      final token = Session().token;
      if (token != null && token.isNotEmpty) {
        try {
          await ApiService.logoutUser(token);
        } catch (_) {}
      }
    } finally {
      await Session().signOut(); // Full clear
      if (mounted) context.read<ProfileImageProvider>().clear();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginDemo()),
        (route) => false,
      );
    }
  }

  // ===================== DELETE ACCOUNT =====================
  Future<void> deleteAccount() async {
    try {
      final token = Session().token;
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are not logged in')),
        );
        return;
      }

      final uri = Uri.parse('${ApiService.baseUrl}/delete');
      var resp =
          await http.delete(uri, headers: {'Authorization': 'Bearer $token'});

      if (resp.statusCode == 405 || resp.statusCode == 404) {
        resp = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'_method': 'DELETE'}),
        );
      }

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        await Session().signOut();
        if (mounted) context.read<ProfileImageProvider>().clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginDemo()),
          (route) => false,
        );
      } else {
        throw Exception('Failed: ${resp.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deletion failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoggedIn == false && userName == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Account',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),

                    // Profile Card
                    Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6)
                          ],
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (!_isLoggedIn) {
                                  _showLoginDialog(
                                      "Please login to edit your profile.");
                                  return;
                                }

                                final changed = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PersonalInformationScreen(
                                      name: userName ?? '',
                                      email: userEmail ?? '',
                                      onDeleteAccount: deleteAccount,
                                    ),
                                  ),
                                );

                                if (changed == true && mounted) {
                                  await _loadUserData();
                                }
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: Consumer<ProfileImageProvider>(
                                    builder: (context, provider, child) {
                                      if (provider.remoteImageUrl != null) {
                                        return Image.network(
                                          provider.remoteImageUrl!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Image.asset(
                                            'assets/images/avatar.png',
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                      return Image.asset(
                                        'assets/images/avatar.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _isLoggedIn
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _displayName,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          userEmail ?? '',
                                          style: const TextStyle(
                                              fontSize: 13, color: Colors.grey),
                                        ),
                                      ],
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginDemo()),
                                        );
                                        if (mounted) await _loadUserData();
                                      },
                                      child: const Text(
                                        "Welcome! Login / Sign up",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    _buildSettings(_isLoggedIn),
                  ],
                ),
              ),
      ),
    );
  }

  void _showLoginDialog(String description) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red,
        title:
            const Text("Login Required", style: TextStyle(color: Colors.white)),
        content: Text(description, style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginDemo()));
            },
            child: const Text("Login",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(bool isLoggedIn) {
    return Column(
      children: [
        _settingsContainer([
          if (!isLoggedIn)
            _settingsTile("My Account", "assets/images/my-account-profile.png",
                () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()));
            }),
          _settingsTile("Find My Agent", "assets/images/find-my-agent.png", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FindAgentDemo()));
          }),
          _settingsTile("Favorites", "assets/images/favourites.png", () {
            if (!isLoggedIn) {
              _showLoginDialog("Please login to access favorites");
            } else {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Fav_Logout()));
            }
          }),
          _settingsTile("Saved Alerts", "assets/images/favourites.png", () {
            if (!isLoggedIn) {
              _showLoginDialog("Please login to access saved alerts.");
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SavedAlertsScreen()));
            }
          }),
          _settingsTile("About Us", "assets/images/about.png", () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => About_Us()));
          }),
          _settingsTile("Support", "assets/images/support.png", () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const Support()));
          }),
          _settingsTile("Privacy Policy", "assets/images/privacy-policy.png",
              () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const Privacy()));
          }),
          _settingsTile(
              "Terms And Conditions", "assets/images/terms-and-conditions.png",
              () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TermsCondition()));
          }),
        ]),
        _settingsContainer(
          isLoggedIn
              ? [
                  _settingsTile("Logout", "", () async {
                    customAlertBox(
                      context: context,
                      title: 'Are you sure you want to logout?',
                      onPress: () async {
                        Navigator.of(context, rootNavigator: true).pop();
                        await _logout();
                      },
                      icons: 'assets/images/alert_box_logout_icon.png',
                    );
                  }),
                ]
              : [
                  _settingsTile("Login", "", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginDemo())).then((_) {
                      if (mounted) _loadUserData();
                    });
                  }),
                ],
        ),
      ],
    );
  }

  Widget _settingsContainer(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _settingsTile(String title, String iconPath, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: iconPath.isNotEmpty ? Image.asset(iconPath, width: 28) : null,
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
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
        children: [
          GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Home()),
              (route) => false,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Image(
                  image: AssetImage("assets/images/home.png"), height: 25),
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () async {
              final token = await SecureStorage.getToken();

              if (token == null || token.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white, // white container
                    title: const Text("Login Required",
                        style: TextStyle(color: Colors.black)),
                    content: const Text("Please login to access favorites.",
                        style: TextStyle(color: Colors.black)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red), // red text
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginDemo()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.red), // red text
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // ✅ Logged in – go to favorites
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Fav_Logout()),
                ).then((_) async {
                  // 🔁 Re-sync when coming back
                  final updatedFavorites =
                      await FavoriteService.fetchApiFavorites(token);
                  setState(() {
                    FavoriteService.loggedInFavorites = updatedFavorites;
                  });
                });
              }
            },
            icon: pageIndex == 2
                ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                : const Icon(Icons.favorite_border_outlined,
                    color: Colors.red, size: 30),
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
            onPressed: () => showHomeContactDialog(context),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.dehaze, color: Colors.red, size: 35),
          ),
        ],
      ),
    );
  }
}
