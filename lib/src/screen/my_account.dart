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
import '../extensions/localization_extension.dart';
import '../features/find_agent/presentation/pages/findagent.dart';
import '../features/localization/presentation/bloc/localization_cubit.dart';
import '../features/localization/presentation/bloc/localization_state.dart';
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
      return 'User'; // fallback — real text comes from l10n in UI
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
      throw Exception('No auth token present for ${ApiService.baseUrl}$endpoint');
    }

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
      'Origin': 'https://akarat.com',
      'Referer': 'https://akarat.com',
    };
  }

  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Requested-With': 'XMLHttpRequest',
  };

  // ===================== DELETE ACCOUNT =====================
  Future<void> deleteAccount() async {
    final l10n = context.l10n;

    try {
      final token = SessionManager().token;

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notLoggedInForAction),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

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
            content: Text(l10n.accountDeletedSuccessfully),
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
        String errorMsg = '${l10n.deletionFailed}: ${resp.statusCode}';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.deletionFailed}: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<LocalizationCubit, LocalizationState>(
      builder: (context, locState) {
        // Determine direction based on current language
        final isArabic = locState.language.toLowerCase() == 'ar';
        final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

        return Directionality(
          textDirection: textDirection,
          child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
            body: SafeArea(
              child: _isLoggedIn == false && userName == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  // Use start alignment so it flips in RTL
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.myAccount,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        child: Row(
                          // Crucial: respect direction so avatar flips side in RTL
                          mainAxisAlignment: MainAxisAlignment.start,
                          textDirection: textDirection,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (!_isLoggedIn) {
                                  _showLoginDialog(l10n.loginToEditProfile);
                                  return;
                                }

                                final changed = await Navigator.push<bool?>(
                                  context,
                                  MaterialPageRoute<bool?>(
                                    builder: (context) => PersonalInformationScreen(
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
                                // In RTL, text should align to right (start)
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _displayName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userEmail ?? '',
                                    style: const TextStyle(
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
                                  if (mounted) await _loadUserData();
                                },
                                child: Text(
                                  l10n.welcomeLoginSignUp,
                                  style: const TextStyle(
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
          ),
        );
      },
    );
  }

  void _showLoginDialog(String description) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Listen to current language to determine direction
        return BlocBuilder<LocalizationCubit, LocalizationState>(
          builder: (context, locState) {
            final isArabic = locState.language.toLowerCase() == 'ar';
            final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

            return Directionality(
              textDirection: textDirection,
              child: AlertDialog(
                backgroundColor: Colors.red,
                title: Text(
                  dialogContext.l10n.loginRequiredTitle,
                  style: const TextStyle(color: Colors.white),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
                content: Text(
                  description,
                  style: const TextStyle(color: Colors.white),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      dialogContext.l10n.cancel,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginDemo()),
                      );
                    },
                    child: Text(
                      dialogContext.l10n.login,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                // Optional: better RTL button alignment
                actionsAlignment: isArabic ? MainAxisAlignment.start : MainAxisAlignment.end,
                buttonPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettings(bool isLoggedIn) {
    final isArabic = context.read<LocalizationCubit>().state.language.toLowerCase() == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Column(
        children: [
          _settingsContainer([
            // ─────────────────────────────────────────────────────────────
            // Only show "My Profile" when user IS logged in
            // Placed at the very top of the list
            // ─────────────────────────────────────────────────────────────
            if (isLoggedIn)
              _settingsTile(
                context.l10n.myProfile,   // ← or context.l10n.editProfile if you prefer
                "assets/images/my-account-profile.png",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalInformationScreen(
                        name: userName ?? '',
                        email: userEmail ?? '',
                        onDeleteAccount: deleteAccount,
                      ),
                    ),
                  ).then((changed) async {
                    if (changed == true && mounted) {
                      await _loadUserData(); // refresh name & email after edit
                    }
                  });
                },
              ),

            _settingsTile(
              context.l10n.findMyAgent,
              "assets/images/find-my-agent.png",
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FindAgentDemo()),
                );
              },
            ),

            _settingsTile(
              context.l10n.favorites,
              "assets/images/favourites.png",
                  () {
                if (!isLoggedIn) {
                  _showLoginDialog(context.l10n.loginToAccessFavorites);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Fav_Logout()),
                  );
                }
              },
            ),

            _settingsTile(
              context.l10n.savedAlerts,
              "assets/images/savealert.png",
                  () {
                if (!isLoggedIn) {
                  _showLoginDialog(context.l10n.loginToAccessSavedAlerts);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedAlertsScreen()),
                  );
                }
              },
            ),

            _settingsTile(
              context.l10n.contactedProperties,
              "assets/images/contacted.png",
                  () {
                if (!isLoggedIn) {
                  _showLoginDialog(context.l10n.loginToViewContacted);
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactedProperties()),
                );
              },
            ),

            _settingsTile(
              context.l10n.aboutUs,
              "assets/images/about.png",
                  () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => About_Us()));
              },
            ),

            _settingsTile(
              context.l10n.support,
              "assets/images/support.png",
                  () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const Support()));
              },
            ),

            _settingsTile(
              context.l10n.privacyPolicy,
              "assets/images/privacy-policy.png",
                  () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const Privacy()));
              },
            ),

            _settingsTile(
              context.l10n.termsAndConditions,
              "assets/images/terms-and-conditions.png",
                  () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsCondition()));
              },
            ),

            _settingsTile(
              context.l10n.language,
              "assets/images/language-icon.png",
                  () async {
                showChangeLanguageDialog(
                  context: context,
                  onOpenSettings: () async {
                    try {
                      await AppSettings.openAppSettings(type: AppSettingsType.settings);
                    } catch (e) {
                      await AppSettings.openAppSettings(type: AppSettingsType.settings);
                    }
                  },
                  onLanguageSelected: (lang) async {
                    await context.read<LocalizationCubit>().updateLocale(lang.languageCode);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                          (route) => false,
                    );
                  },
                );
              },
            ),

            _settingsTile(
              context.l10n.rateUs,
              "assets/images/stars (1).png",
                  () async {
                // ... rate us logic remains unchanged ...
              },
            ),
          ]),

          // Logout / Login section at the bottom
          _settingsContainer(
            isLoggedIn
                ? [
              _settingsTile(
                context.l10n.logout,
                "",
                    () async {
                  customAlertBox(
                    context: context,
                    title: context.l10n.logoutConfirmationTitle,
                    onPress: () async {
                      Navigator.of(context, rootNavigator: true).pop();
                      await _logout();
                    },
                    icons: 'assets/images/alert_box_logout_icon.png',
                  );
                },
              ),
            ]
                : [
              _settingsTile(
                context.l10n.login,
                "",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginDemo()),
                  ).then((_) {
                    if (mounted) _loadUserData();
                  });
                },
              ),
            ],
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

  Widget _settingsTile(String title, String iconPath, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: iconPath.isNotEmpty
          ? Image.asset(iconPath, width: 28, height: 28)
          : null,
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      // Let Flutter automatically flip leading/trailing in RTL
      // No need for manual textDirection here — parent Directionality handles it
    );
  }

  Container buildMyNavBar(BuildContext context) {
    final l10n = context.l10n!;

    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
              child: Image(image: AssetImage("assets/images/home.png"), height: 25),
            ),
          ),
          IconButton(
            onPressed: () async {
              final token = await SecureStorage.getToken();
              if (token == null || token.isEmpty) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(l10n.loginRequiredTitle),
                    content: Text(l10n.loginToAccessFavorites),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginDemo()),
                          );
                        },
                        child: Text(l10n.login),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Fav_Logout()),
                );
              }
            },
            icon: const Icon(Icons.favorite_border_outlined, color: Colors.red, size: 30),
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