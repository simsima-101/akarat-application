import 'dart:convert';
import 'dart:io';
import 'package:Akarat/screen/about_us.dart';
import 'package:Akarat/screen/findagent.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/privacy.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/support.dart';
import 'package:Akarat/screen/terms_condition.dart';
import 'package:Akarat/utils/fav_logout.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/agencypropertiesmodel.dart';
import '../providers/profile_image_provider.dart';
import '../secure_storage.dart';
import 'favorite.dart';
import 'login.dart';
import 'login_page.dart';

class My_Account extends StatefulWidget {
  const My_Account({super.key});

  @override
  State<My_Account> createState() => _My_AccountState();
}

class _My_AccountState extends State<My_Account> {
  int pageIndex = 0;
  String? userName;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserName();

  }

  Future<void> _loadUserName() async {
    final name = await SecureStorage.read('user_name');
    final imageUrl = await SecureStorage.read('user_image'); // Load image URL
    setState(() {
      userName = name ?? '';
      profileImageUrl = imageUrl ?? ''; // Store it in a new variable
    });
  }

  Future<List<Property>> fetchSavedProperties() async {
    try {
      final token = await SecureStorage.getToken();
      final response = await http.get(
        Uri.parse('https://akarat.com/api/saved-property-list?page=1'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = json.decode(response.body);
        final List<dynamic> propertiesJsonList = responseJson['data']?['data'] ?? [];
        return propertiesJsonList.map((item) => Property.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch properties: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching saved properties: $e');
      return [];
    }
  }

  Future<void> deleteAccount() async {
    try {
      String? token = await SecureStorage.getToken();
      if (token == null) throw Exception("No token found.");

      final response = await http.delete(
        Uri.parse('https://akarat.com/api/delete'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await SecureStorage.deleteToken();
        await SecureStorage.delete('user_name');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => RegisterScreen()),
              (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account deleted successfully")));
      } else {
        throw Exception("Failed to delete account: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account deletion failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileImageProvider>();


    return Scaffold(
      bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
      backgroundColor: Colors.white,
      body: FutureBuilder<String?>(
        future: SecureStorage.getToken(),
        builder: (context, snapshot) {
          final token = snapshot.data ?? '';
          final isLoggedIn = token.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70),
                const Text('My Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                /// Profile Card
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: (isLoggedIn && profileImageUrl != null && profileImageUrl!.isNotEmpty)
                                  ? NetworkImage(profileImageUrl!) // Load image from API
                                  : null,
                              child: (isLoggedIn && profileImageUrl != null && profileImageUrl!.isNotEmpty)
                                  ? null
                                  : Padding(
                                padding: const EdgeInsets.all(6),
                                child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain),
                              ),
                            ),

                            // Positioned(
                            //   bottom: -12,
                            //   right: -9,
                            //   child: PopupMenuButton<String>(
                            //     color: Colors.white,
                            //     icon: const CircleAvatar(
                            //       radius: 10,
                            //       backgroundColor: Colors.white,
                            //       child: Icon(Icons.edit, size: 14, color: Colors.grey),
                            //     ),
                            //     itemBuilder: (context) => [
                            //       const PopupMenuItem(value: 'upload', child: Text('Upload Image')),
                            //       if (profileProvider.image != null)
                            //         const PopupMenuItem(value: 'delete', child: Text('Remove Image')),
                            //     ],
                            //     onSelected: (value) async {
                            //       final token = await SecureStorage.getToken();
                            //       if (value == 'upload') {
                            //         if (token == null || token.isEmpty) {
                            //           _showLoginDialog(context);
                            //         } else {
                            //           await context.read<ProfileImageProvider>().pickImage();
                            //         }
                            //       } else if (value == 'delete') {
                            //         await context.read<ProfileImageProvider>().deleteImage();
                            //       }
                            //     },
                            //
                            //   ),
                            // )
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: isLoggedIn
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (userName != null && userName!.isNotEmpty) ? userName! : 'Welcome!',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text("Registered User", style: TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          )
                              : GestureDetector(
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginDemo()));
                              _loadUserName();
                            },
                            child: const Text(
                              "Login / Sign up",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.red),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Settings
                _buildSettings(isLoggedIn),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Login dialog
  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
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
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Login required to upload profile image.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(ctx).pushNamed('/login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettings(bool isLoggedIn) {
    return Column(
      children: [
        _settingsContainer([
          _settingsTile("Find My Agent", "assets/images/find-my-agent.png", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => FindAgentDemo()));
          }),
          _settingsTile("Favorites", "assets/images/favourites.png", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Favorite()));
          }),
          _settingsTile("About Us", "assets/images/about.png", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => About_Us()));
          }),
          _settingsTile("Support", "assets/images/support.png", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Support()));
          }),
          _settingsTile("Privacy Policy", "assets/images/privacy-policy.png", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Privacy()));
          }),
          _settingsTile("Terms And Conditions", "assets/images/terms-and-conditions.png", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => TermsCondition()));
          }),
        ]),
        _settingsContainer(isLoggedIn
            ? [
          _settingsTile("Logout", "", () async {
            await SecureStorage.deleteToken();
            await SecureStorage.delete('user_name');
            context.read<ProfileImageProvider>().clear(); // ✅ clear profile image
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => RegisterScreen()),
                  (route) => false,
            );
          }),
          _settingsTile("Delete your Account", "", () async {
            bool? confirm = await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Delete Account"),
                content: const Text("Are you sure you want to delete your account?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Delete", style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirm == true) await deleteAccount();
          }),
        ]
            : [
          _settingsTile("Login", "", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginDemo()));
          }),
        ]),
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
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(children: children),
      ),
    );
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
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Home())),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/home.png", height: 25),
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
                    backgroundColor: Colors.white,
                    title: const Text("Login Required"),
                    content: const Text("Please login to access favorites."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginDemo()));
                        },
                        child: const Text("Login", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Fav_Logout()));
              }
            },
            icon: pageIndex == 2
                ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                : const Icon(Icons.favorite_border_outlined, color: Colors.red, size: 30),
          ),
          IconButton(
            tooltip: "Email",
            icon: const Icon(Icons.email_outlined, color: Colors.red),
            onPressed: () async {
              final Uri emailUri = Uri.parse('mailto:info@akarat.com?subject=Property%20Inquiry');
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Email not available'),
                    content: const Text('No email app is configured on this device.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                  ),
                );
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(Icons.dehaze, color: Colors.red, size: 35),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(String title, String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: iconPath.isNotEmpty ? Image.asset(iconPath, width: 28) : null,
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
