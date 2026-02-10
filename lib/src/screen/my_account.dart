// lib/src/screen/my_account.dart
import 'dart:convert';
import 'dart:io';

import 'package:Akarat/src/screen/privacy.dart';
import 'package:Akarat/src/screen/register_screen.dart';
import 'package:Akarat/src/screen/saved_alert_screen.dart';
import 'package:Akarat/src/screen/splash_screen.dart';
import 'package:Akarat/src/screen/support.dart';
import 'package:Akarat/src/screen/terms_condition.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../general/widgets/lanagauage_dailog.dart';
import '../../l10n/app_localizations.dart';
import '../core/services/api_service.dart';
import '../core/utils/secure_storage.dart';
import '../core/utils/session_manager.dart';
import '../features/find_agent/presentation/pages/findagent.dart';
import '../features/localization/presentation/bloc/localization_cubit.dart';
import '../utils/fav_logout.dart';
import '../widgets/custom_alert_box.dart';
import 'ContactFormScreen.dart';
import 'about_us.dart';
import 'contacted_properties.dart';
import 'home.dart';
import 'login.dart';
import 'personal_information.dart';

class My_Account extends StatefulWidget {
  const My_Account({super.key});

  @override
  State<My_Account> createState() => _My_AccountState();
}

class _My_AccountState extends State<My_Account> {
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await SessionManager().restore();

    if (!mounted) return;

    setState(() {
      userName = SessionManager().userName?.trim().isNotEmpty == true
          ? SessionManager().userName!.trim()
          : 'User';
      userEmail = SessionManager().userEmail?.trim().isNotEmpty == true
          ? SessionManager().userEmail!.trim()
          : '';
    });
  }

  String get _displayName {
    if (userName == null || userName == 'User' || userName!.trim().isEmpty) {
      return 'Welcome! Login / Sign up';
    }
    return userName!;
  }

  bool get _isLoggedIn =>
      SessionManager().isAuthenticated &&
      userName != 'User' &&
      userName?.isNotEmpty == true;

  // ===================== LOGOUT =====================
  Future<void> _logout() async {
    try {
      final token = SessionManager().token;
      if (token != null && token.isNotEmpty) {
        try {
          await logoutUser(token);
        } catch (_) {}
      }
    } finally {
      await SessionManager().signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginDemo()),
        (route) => false,
      );
    }
  }

  static Future<void> logoutUser(String token) async {
    final resp = await _postAuth('/logout', token, const {});
    if (resp.statusCode != 200) {
      throw Exception('Logout failed: ${resp.statusCode}');
    }
  }

  static Future<http.Response> _postAuth(
    String endpoint,
    String token,
    Map<String, dynamic> body,
  ) async {
    if (token.isEmpty) {
      throw Exception(
          'No auth token present for ${ApiService.baseUrl}$endpoint');
    }
    // final url = ApiService.buildUri(endpoint);
    // final resp = await http
    //     .post(url, headers: _authHeaders(token), body: jsonEncode(body))
    //     .timeout(Duration(seconds: 25));

    final resp = await ApiService.post(
      endpoint,
      body: body,
      headers: _authHeaders(token),
    ).timeout(const Duration(seconds: 25));

    if (kDebugMode) {
      print('[POST*] -> ${resp.statusCode} ${resp.body}');
    }

    return resp;
  }

  static Map<String, String> _authHeaders(String token) {
    final cleanToken = token.trim();
    debugPrint('SENDING AUTH HEADER → Bearer $cleanToken');

    if (cleanToken.isEmpty) {
      throw Exception('Empty token in _authHeaders');
    }

    return {
      ..._jsonHeaders,
      'Authorization': 'Bearer $cleanToken',
      'Origin': 'https://akarat.com', // ← Add this (helps Sanctum)
      'Referer': 'https://akarat.com', // ← Add this (helps Sanctum)
    };
  }

  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Requested-With': 'XMLHttpRequest',
  };

  // ===================== DELETE ACCOUNT =====================
  Future<void> deleteAccount() async {
    try {
      final token = SessionManager().token;

      final l10n = AppLocalizations.of(context);

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.notLoggedInForAction ??
                  l10n?.loginRequired ??
                  'You are not logged in',
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // ──────────────────────────────────────────────
      // ... DELETE request logic remains the same ...
      // ──────────────────────────────────────────────

      var resp = await ApiService.delete(
        '/delete',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 405 || resp.statusCode == 404) {
        resp = await ApiService.post(
          '/delete',
          body: {'_method': 'DELETE'},
          headers: {'Authorization': 'Bearer $token'},
        );
      }

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        await SessionManager().signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.accountDeletedSuccessfully ?? 'Account deleted successfully',
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginDemo()),
                (route) => false,
          );
        }
      } else {
        String errorMsg = '${l10n?.deletionFailed ?? 'Deletion failed'}: ${resp.statusCode}';
        try {
          final errorBody = jsonDecode(resp.body);
          final serverMessage = errorBody['message'] ?? errorBody['error'] ?? 'Unknown error';
          errorMsg += ' - $serverMessage';
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n?.deletionFailed ?? 'Deletion failed'}: $e',
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                    Text(
                      l10n?.myAccount ?? 'My Account',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),

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
                                backgroundColor: Colors.grey[200],
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/avatar.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
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
        content: Text(description, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginDemo()),
              );
            },
            child: const Text(
              "Login",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(bool isLoggedIn) {
    final l10n = AppLocalizations.of(context);

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
            if (!isLoggedIn) {
              _showLoginDialog("Please login to access favorites");
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Fav_Logout()),
              );
            }
          }),
          _settingsTile("Saved Alerts", "assets/images/savealert.png", () {
            if (!isLoggedIn) {
              _showLoginDialog("Please login to access saved alerts.");
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedAlertsScreen()),
              );
            }
          }),
          _settingsTile("Contacted Properties", "assets/images/contacted.png",
              () {
            if (!_isLoggedIn) {
              _showLoginDialog("Please login to view contacted properties.");
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactedProperties()),
            );
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

          // Language Tile - Opens native per-app language settings
          _settingsTile(
            "Language",
            "assets/images/terms-and-conditions.png", // Recommended: add a globe icon
            () async {
              showChangeLanguageDialog(
                  context: context,

                  ////// FOR IOS //////
                  onOpenSettings: () async {
                    try {
                      await AppSettings.openAppSettings(
                        type: AppSettingsType.settings,
                      );
                    } catch (e) {
                      await AppSettings.openAppSettings(
                        type: AppSettingsType.settings,
                      );
                    }
                  },

                  ////// FOR ANDROID //////
                  onLanguageSelected: (lang) async {
                    await context
                        .read<LocalizationCubit>()
                        .updateLocale(lang.languageCode);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false,
                    );
                  });
            },
          ),
          _settingsTile(
            "Rate Us",
            "assets/images/stars (1).png",
            () async {
              const String androidPackage = "com.akarat.drawerdemo";
              const String iosAppId = "6745213903";

              // Use country-specific link (very important for AE/UAE!)
              final String countryCode =
                  'ae'; // Change to 'us', 'gb', etc. if needed

              final Uri storeUrl = Platform.isIOS
                  ? Uri.parse(
                      "https://apps.apple.com/$countryCode/app/id$iosAppId")
                  : Platform.isAndroid
                      ? Uri.parse(
                          "https://play.google.com/store/apps/details?id=$androidPackage")
                      : Uri.parse(
                          "https://apps.apple.com/$countryCode/app/id$iosAppId"); // fallback

              try {
                // First try external app mode (App Store / Play Store native)
                if (await canLaunchUrl(storeUrl)) {
                  final bool launched = await launchUrl(
                    storeUrl,
                    mode: LaunchMode.externalApplication,
                  );

                  if (!launched) {
                    debugPrint(
                        "External launch failed → trying in-app/browser fallback");
                    await launchUrl(
                      storeUrl,
                      mode: LaunchMode
                          .platformDefault, // Opens in Safari or in-app webview
                    );
                  }
                } else {
                  debugPrint(
                      "Cannot launch $storeUrl → trying platform default");
                  await launchUrl(
                    storeUrl,
                    mode: LaunchMode.platformDefault,
                  );
                }
              } catch (e) {
                debugPrint("Error launching store: $e");
                // Optional: Show a snackbar to user
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text("Could not open store. Please check later.")),
                // );
              }
            },
          ),
        ]),

        // Logout / Login Section
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
                      MaterialPageRoute(builder: (_) => const LoginDemo()),
                    ).then((_) {
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
      leading: iconPath.isNotEmpty
          ? Image.asset(iconPath, width: 28, height: 28)
          : null,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            onPressed: () async {
              final token = await SecureStorage.getToken();
              if (token == null || token.isEmpty) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Login Required"),
                    content: const Text("Please login to access favorites."),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel")),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginDemo()));
                        },
                        child: const Text("Login"),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const Fav_Logout()));
              }
            },
            icon: const Icon(Icons.favorite_border_outlined,
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
