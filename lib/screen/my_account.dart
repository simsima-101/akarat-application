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

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class My_Account extends StatefulWidget {
  My_Account({super.key});

  @override
  State<My_Account> createState() => _My_AccountState();
}

class _My_AccountState extends State<My_Account> {
  int pageIndex = 0;

  String? userName;

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


  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();




  @override
  void initState() {
    // readData();
    super.initState();
    _loadSavedProfileImage();
    _loadUserName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSavedProfileImage(); // ← Ensures image reloads every time screen rebuilds
  }


  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final savedImage = await File(image.path).copy('${directory.path}/profile_image.png');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', savedImage.path);

    setState(() {
      _selectedImage = savedImage;
    });
  }

  Future<void> _loadSavedProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');

    if (path != null && File(path).existsSync()) {
      setState(() {
        _selectedImage = File(path);
      });
    } else {
      setState(() {
        _selectedImage = null;
      });
    }
  }



  Future<void> _deleteProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');

    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      await prefs.remove('profile_image_path');
    }

    setState(() {
      _selectedImage = null;
    });
  }


  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? '';
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 70), // Adjusts vertical spacing from top (you can fine-tune this)
                  const Text(
                    'My Account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),


                  // ✅ Place the profile container at the top
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
                                child: ClipOval(
                                  child: (isLoggedIn && _selectedImage != null)
                                      ? Image.file(
                                    _selectedImage!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  )
                                      : Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Image.asset(
                                      'assets/images/app_icon.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                              ),
                              Positioned(
                                bottom: -12,
                                right: -9,
                                child: PopupMenuButton<String>(
                                  color: Colors.white,
                                  icon: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.edit, size: 14, color: Colors.grey),
                                  ),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'upload',
                                      child: Text('Upload Image'),
                                    ),
                                    if (_selectedImage != null)
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Remove Image'),
                                      ),
                                  ],
                                  onSelected: (value) async {
                                    final token = await SecureStorage.getToken();

                                    if (value == 'upload') {
                                      if (token == null || token.isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            insetPadding: EdgeInsets.zero,
                                            child: Container(
                                              height: 70,
                                              margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
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
                                                          child: Text(
                                                            'Login required to upload profile image.',
                                                            style: TextStyle(color: Colors.white, fontSize: 13),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
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
                                                              decorationColor: Colors.white,
                                                              decorationThickness: 1.5,
                                                            ),
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
                                      } else {
                                        _pickImage();
                                      }
                                    } else if (value == 'delete') {
                                      _deleteProfileImage();
                                    }
                                  },

                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: isLoggedIn
                                ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName ?? '',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Registered User",
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            )
                                : GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginDemo()));
                              },
                              child: const Text(
                                "Login / Sign up",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.red,
                                ),
                              ),
                            ),
                          )


                        ],
                      ),
                    ),
                  ),



                  SizedBox(height: 20,),

                  // ✅ Remove the extra SizedBox(height: 200),
                  // const SizedBox(height: 200),

                  Column(
                    children: [
                      // Main settings tiles in one container
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Container(
                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
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
                            ],
                          ),
                        ),
                      ),

                      // Conditional container based on login state
                      Padding(
                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: isLoggedIn
                                ? [
                              _settingsTile("Logout", "", () async {
                                await SecureStorage.deleteToken();
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.remove('user_name'); // ✅ clear username

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
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await deleteAccount();
                                }
                              }),
                            ]
                                : [
                              _settingsTile("Login", "", () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginDemo()));
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )

                ],
              ),
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
            icon: const Icon(Icons.email_outlined, color: Colors.red),
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
            child: Icon(
              Icons.dehaze,
              color: Colors.red,
              size: 35,
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
      // const Divider(height: 1),
    ],
  );
}