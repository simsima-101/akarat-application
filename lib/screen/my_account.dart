// lib/screen/my_account.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

import '../services/session.dart';
import 'login.dart';
import 'personal_information.dart';

// Providers / Models / Services
import '../providers/profile_image_provider.dart';
import '../services/api_service.dart';
import '../model/agencypropertiesmodel.dart' show Property; // if you still need it
import '../widgets/custom_alert_box.dart';

class My_Account extends StatefulWidget {
  const My_Account({super.key});

  @override
  State<My_Account> createState() => _My_AccountState();
}

class _My_AccountState extends State<My_Account> {
  int pageIndex = 0;

  // Local mirrors for quick display (purely UI; source = Session)
  String? userName;
  String? userEmail;
  String? firstName;
  String? lastName;
  String? profileImageUrl; // reserved for later (CDN/avatar)

  @override
  void initState() {
    super.initState();
    _hydrateFromSession();
  }

  /// Read only from in-memory session (no storage, no /me).
  void _hydrateFromSession() {
    final s = Session();

    final display = (s.userName ?? '').trim();
    final email = (s.userEmail ?? '').trim();

    String f = (s.firstName ?? '').trim();
    String l = (s.lastName ?? '').trim();

    // Derive first/last from full name if not provided
    if ((f.isEmpty && l.isEmpty) && display.isNotEmpty) {
      final parts = display.split(RegExp(r'\s+'));
      f = parts.isNotEmpty ? parts.first : '';
      l = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    setState(() {
      userName = display;
      userEmail = email;
      firstName = f;
      lastName = l;
      // profileImageUrl can be wired later from a provider/cache
    });
  }

  Future<bool> _hasSession() async {
    // Fast future, no IO
    return Future<bool>.value(Session().isAuthenticated);
  }

  String get _displayName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isNotEmpty || l.isNotEmpty) {
      return [f, l].where((s) => s.isNotEmpty).join(' ');
    }
    return (userName ?? '').trim();
  }

  // --- If you still need saved properties later; currently not used in UI ---
  Future<List<Property>> _fetchSavedProperties() async {
    try {
      final token = Session().token;
      if (token == null || token.isEmpty) return <Property>[];

      final uri = Uri.parse('${ApiService.baseUrl}/saved-property-list?page=1');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = json.decode(response.body);
        final List<dynamic> propertiesJsonList =
            responseJson['data']?['data'] ?? [];
        return propertiesJsonList
            .map((item) => Property.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch properties: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching saved properties: $e');
      return <Property>[];
    }
  }

  // ===================== LOGOUT =====================
  Future<void> _logout() async {
    try {
      final token = Session().token;
      if (token != null && token.isNotEmpty) {
        // Best-effort server logout (ignore failures)
        try {
          await ApiService.logoutUser(token);
        } catch (_) {}
      }
    } finally {
      // Clear in-memory session
      Session().clear();
      // Clear provider avatar, etc.
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are not logged in')),
          );
        }
        return;
      }

      final base = ApiService.baseUrl; // e.g. https://qa.akarat.com/api
      final uri = Uri.parse('$base/delete');

      http.Response resp = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // Some backends respond 405/404 for DELETE → use POST + _method override
      if (resp.statusCode == 405 || resp.statusCode == 404) {
        resp = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'_method': 'DELETE'}),
        );
      }

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        // Clear session + providers
        Session().clear();
        if (mounted) context.read<ProfileImageProvider>().clear();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginDemo()),
              (route) => false,
        );
      } else if (resp.statusCode == 401) {
        // Treat as forced logout
        Session().clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please login again.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginDemo()),
              (route) => false,
        );
      } else {
        throw Exception('Failed with status ${resp.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account deletion failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
      backgroundColor: Colors.white,
      body: SafeArea( // ✅ handles top notch / status bar area
        child: FutureBuilder<bool>(
          future: _hasSession(),
          builder: (context, snap) {
            final waiting = snap.connectionState == ConnectionState.waiting;
            final isLoggedIn = snap.data ?? false;

            if (waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'My Account',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  // Profile Card
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 16),
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
                          // Avatar → open Personal Information if logged in
                          GestureDetector(
                            onTap: () async {
                              if (!Session().isAuthenticated) {
                                _showLoginDialog(context);
                                return;
                              }

                              _hydrateFromSession();

                              final changed =
                              await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => PersonalInformationScreen(
                                    name: (userName ?? ''),
                                    email: (userEmail ?? ''),
                                    onDeleteAccount: deleteAccount,
                                  ),
                                ),
                              );

                              if (changed == true && mounted) {
                                _hydrateFromSession();
                                setState(() {});
                              }
                            },
                            child: const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                              AssetImage('assets/images/avatar.png'),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: isLoggedIn
                                ? Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _displayName.isNotEmpty
                                      ? _displayName
                                      : 'User',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Registered User",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                                : GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginDemo(),
                                  ),
                                );
                                if (mounted) {
                                  _hydrateFromSession();
                                  setState(() {});
                                }
                              },
                              child: const Text(
                                "Welcome!  Login / Sign up",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Settings
                  _buildSettings(isLoggedIn),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Login dialog for restricted actions when not logged in
  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: const BoxConstraints(minHeight: 70), // ✅ no hard fixed height
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
                ),
              ),
              Row(
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
                      Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder: (_) => const LoginDemo(),
                        ),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
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
  }

  Widget _buildSettings(bool isLoggedIn) {
    return Column(
      children: [
        _settingsContainer([
          if (!isLoggedIn)
            _settingsTile("My Account", "assets/images/my-account-profile.png",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                }),
          _settingsTile("Find My Agent", "assets/images/find-my-agent.png", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FindAgentDemo()),
            );
          }),
          _settingsTile("Favorites", "assets/images/favourites.png", () {
            if (!Session().isAuthenticated) {
              _showLoginRequiredForFavorites();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Fav_Logout()),
              );
            }
          }),
          _settingsTile("Saved Alerts", "assets/images/favourites.png", () {
            if (!Session().isAuthenticated) {
              _showLoginDialog(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedAlertsScreen()),
              );
            }
          }),
          _settingsTile("About Us", "assets/images/about.png", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => About_Us()),
            );
          }),
          _settingsTile("Support", "assets/images/support.png", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Support()),
            );
          }),
          _settingsTile("Privacy Policy", "assets/images/privacy-policy.png",
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Privacy()),
                );
              }),
          _settingsTile(
            "Terms And Conditions",
            "assets/images/terms-and-conditions.png",
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsCondition()),
              );
            },
          ),
        ]),
        _settingsContainer(
          isLoggedIn
              ? [
            // Logout
            _settingsTile("Logout", "", () async {
              customAlertBox(
                context: context,
                title: 'Are you sure you want to logout?',
                onPress: () async {
                  // Close dialog first
                  Navigator.of(context, rootNavigator: true).pop();
                  await _logout();
                },
                icons: 'assets/images/alert_box_logout_icon.png',
              );
            }),

            // Delete account
            _settingsTile("Delete your Account", "", () async {
              customAlertBox(
                context: context,
                title:
                'Are you sure you want to delete your account?',
                onPress: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  await deleteAccount();
                },
                icons: 'assets/images/alert_box_delete_icon.png',
              );
            }),
          ]
              : [
            _settingsTile("Login", "", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginDemo(),
                ),
              ).then((_) {
                if (mounted) {
                  _hydrateFromSession();
                  setState(() {});
                }
              });
            }),
          ],
        ),
      ],
    );
  }

  void _showLoginRequiredForFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Login Required"),
        content: const Text("Please login to access favorites."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginDemo()),
              );
            },
            child: const Text("Login", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Image(
                image: AssetImage("assets/images/home.png"),
                height: 25,
              ),
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              if (!Session().isAuthenticated) {
                _showLoginRequiredForFavorites();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Fav_Logout()),
                );
              }
            },
            icon: pageIndex == 2
                ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                : const Icon(Icons.favorite_border_outlined,
                color: Colors.red, size: 30),
          ),
          IconButton(
            tooltip: "Email",
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
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
                    backgroundColor: Colors.white,
                    title: const Text(
                      'Email not available',
                      style: TextStyle(color: Colors.black),
                    ),
                    content: const Text(
                      'No email app is configured on this device. Please add a mail account first.',
                      style: TextStyle(color: Colors.black),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
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
