import 'dart:convert';
import 'package:Akarat/screen/about_us.dart';
import 'package:Akarat/screen/advertising.dart';
import 'package:Akarat/screen/blog.dart';
import 'package:Akarat/screen/cookies.dart';
import 'package:Akarat/screen/findagent.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/privacy.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/settingstile.dart';
import 'package:Akarat/screen/support.dart';
import 'package:Akarat/screen/terms_condition.dart';
import 'package:Akarat/utils/fav_login.dart';
import 'package:Akarat/utils/fav_logout.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../model/agencypropertiesmodel.dart';
import '../secure_storage.dart';
import '../services/api_service.dart';
import '../utils/shared_preference_manager.dart';
import 'favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'login_page.dart';

class My_Account extends StatefulWidget {
  My_Account({super.key});

  @override
  State<My_Account> createState() => _My_AccountState();
}

class _My_AccountState extends State<My_Account> {
  int pageIndex = 0;
  // String token = '';
  // String email = '';
  // String result = '';
  // bool isDataRead = false;
  // bool isDataSaved = true;
  // final SharedPreferencesManager prefManager = SharedPreferencesManager();

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // void readData() async {
  //   token = await prefManager.readStringFromPref() ?? '';
  //   email = await prefManager.readStringFromPrefemail() ?? '';
  //   result = await prefManager.readStringFromPrefresult() ?? '';
  //   setState(() {
  //     isDataRead = true;
  //   });
  // }

  @override
  void initState() {
    // readData();
    super.initState();
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
        print('Fetched ${propertiesJsonList.length} properties');
        List<Property> properties = propertiesJsonList
            .map((item) => Property.fromJson(item))
            .toList();
        return properties;
      } else {
        throw Exception('Failed to fetch properties: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching saved properties: $e');
      return [];
    }
  }

  // New method for account deletion
  Future<void> deleteAccount() async {
    try {
      String? token = await SecureStorage.getToken();
      if (token == null) {
        throw Exception("No token found.");
      }

      final response = await http.delete(
        Uri.parse('https://akarat.com/api/delete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await SecureStorage.deleteToken();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => RegisterScreen()),
              (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account deleted successfully")),
        );
      } else {
        throw Exception("Failed to delete account: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account deletion failed: $e")),
      );
    }
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
      backgroundColor: Colors.white,
      body: FutureBuilder<String?>(
        future: SecureStorage.getToken(), // ✅ get token from secure storage
        builder: (context, snapshot) {
          final token = snapshot.data ?? '';
          final isLoggedIn = token.isNotEmpty;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 200),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
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

                      if (isLoggedIn) ...[
                        _settingsTile("Logout", "", () async {
                          await SecureStorage.deleteToken();
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
                              title: Text("Delete Account"),
                              content: Text("Are you sure you want to delete your account?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await deleteAccount();
                          }
                        }),
                      ] else ...[
                        _settingsTile("Login", "", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginDemo()));
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
            onTap: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
            },
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
                    backgroundColor: Colors.white, // white container
                    title: const Text("Login Required", style: TextStyle(color: Colors.black)),
                    content: const Text("Please login to access favorites.", style: TextStyle(color: Colors.black)),
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
                            MaterialPageRoute(builder: (_) => const LoginDemo()),
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
              }
              else {
                // ✅ Logged in – go to favorites
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Fav_Logout()),
                );
              }
            },
            icon: pageIndex == 2
                ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                : const Icon(Icons.favorite_border_outlined, color: Colors.red, size: 30),
          ),

          IconButton(
            tooltip: "Email",
            icon: const Icon(Icons.email, color: Colors.red),
            onPressed: () async {
              final Uri emailUri = Uri.parse(
                'mailto:info@akarat.com?subject=Property%20Inquiry&body=Hi,%20I%20saw%20your%20agent%20profile%20on%20Akarat.',
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Email not available'),
                    content: const Text('No email app is configured on this device. Please add a mail account first.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
              },

              icon: pageIndex == 3
                  ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                  : const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }

  logoutAPI(String token) {}
}

Widget _settingsTile(String title, String iconPath, VoidCallback onTap) {
  return Column(
    children: [
      GestureDetector(
        onTap: onTap,
        child: ListTile(
          leading: iconPath.isNotEmpty
              ? Image.asset(iconPath, width: 28)
              : null,
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
      const Divider(height: 1),
    ],
  );
}