import 'dart:convert';
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
import 'package:url_launcher/url_launcher.dart';
import '../model/agencypropertiesmodel.dart';
import '../providers/profile_image_provider.dart';
import '../secure_storage.dart';
import '../services/account_service.dart';
import '../services/api_service.dart';
import 'personal_information.dart';
import 'favorite.dart';
import 'login.dart';

class My_Account extends StatefulWidget {
  const My_Account({super.key});

  @override
  State<My_Account> createState() => _My_AccountState();
}

class _My_AccountState extends State<My_Account> {
  int pageIndex = 0;
  String? userName;
  String? profileImageUrl;
  String? userEmail;

  String? firstName;
  String? lastName;


  @override
  void initState() {
    super.initState();
    _loadUserName();
    _ensureProfileLoaded();

  }


  Future<void> _ensureProfileLoaded() async {
    // 1) Fast path from cache
    final cachedEmail = (await SecureStorage.getUserEmail())?.trim() ?? '';
    final cachedName  = (await SecureStorage.getUserName())?.trim() ?? '';
    final cachedFirst = (await SecureStorage.read('user_first_name'))?.trim() ?? '';
    final cachedLast  = (await SecureStorage.read('user_last_name'))?.trim() ?? '';

    if (mounted) {
      setState(() {
        if (cachedEmail.isNotEmpty) userEmail = cachedEmail;
        if (cachedName.isNotEmpty)  userName  = cachedName;
        if (cachedFirst.isNotEmpty) firstName = cachedFirst;
        if (cachedLast.isNotEmpty)  lastName  = cachedLast;
      });
    }

    // If we already have an email, we're done (no server call).
    if (cachedEmail.isNotEmpty) return;

    // 2) No cached email → fetch /me only if token exists
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      await SecureStorage.signOutLocal(); // ensure no ghost user
      if (mounted) {
        setState(() {
          userEmail = '';
          userName  = '';
          firstName = '';
          lastName  = '';
        });
      }
      return;
    }

    try {
      final resp = await http.get(
        Uri.parse('${ApiService.baseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // Auth expired/invalid
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        await SecureStorage.signOutLocal();
        if (mounted) {
          setState(() {
            userEmail = '';
            userName  = '';
            firstName = '';
            lastName  = '';
          });
        }
        return;
      }

      if (resp.statusCode == 200) {
        final raw  = utf8.decode(resp.bodyBytes);
        final data = json.decode(raw);

        // ---- helpers ----
        String firstNonEmpty(Iterable<String?> vals) {
          for (final v in vals) {
            if (v != null && v.trim().isNotEmpty) return v.trim();
          }
          return '';
        }

        String getByPath(dynamic obj, List<String> path) {
          dynamic cur = obj;
          for (final key in path) {
            if (cur is Map && cur.containsKey(key)) {
              cur = cur[key];
            } else {
              return '';
            }
          }
          final s = (cur is String) ? cur : cur?.toString();
          return (s ?? '').trim();
        }

        String findStringByKey(dynamic obj, String key) {
          if (obj is Map) {
            for (final e in obj.entries) {
              if (e.key == key) {
                final v = e.value;
                final s = (v is String) ? v : v?.toString();
                if (s != null && s.trim().isNotEmpty) return s.trim();
              }
              final found = findStringByKey(e.value, key);
              if (found.isNotEmpty) return found;
            }
          } else if (obj is List) {
            for (final item in obj) {
              final found = findStringByKey(item, key);
              if (found.isNotEmpty) return found;
            }
          }
          return '';
        }
        // ---- end helpers ----

        // Possible payload shapes
        final namePaths = <List<String>>[
          ['name'],
          ['data','name'],
          ['user','name'],
          ['data','user','name'],
          ['result','name'],
        ];
        final emailPaths = <List<String>>[
          ['email'],
          ['data','email'],
          ['user','email'],
          ['data','user','email'],
          ['result','email'],
        ];
        final imagePaths = <List<String>>[
          ['image'], ['data','image'], ['user','image'], ['data','user','image'],
          ['result','image'], ['avatar'], ['profile','image'],
        ];
        final firstPaths = <List<String>>[
          ['first_name'], ['data','first_name'], ['user','first_name'],
          ['data','user','first_name'], ['result','first_name'],
        ];
        final lastPaths = <List<String>>[
          ['last_name'], ['data','last_name'], ['user','last_name'],
          ['data','user','last_name'], ['result','last_name'],
        ];

        final fetchedName   = firstNonEmpty(namePaths.map((p) => getByPath(data, p)));
        String fetchedEmail = firstNonEmpty(emailPaths.map((p) => getByPath(data, p)));
        final fetchedImage  = firstNonEmpty(imagePaths.map((p) => getByPath(data, p)));
        String fetchedFirst = firstNonEmpty(firstPaths.map((p) => getByPath(data, p)));
        String fetchedLast  = firstNonEmpty(lastPaths.map((p) => getByPath(data, p)));

        // Fill first/last from full name if needed (one-time split)
        if (fetchedFirst.isEmpty && fetchedLast.isEmpty && fetchedName.isNotEmpty) {
          final parts = fetchedName.split(RegExp(r'\s+'));
          fetchedFirst = parts.isNotEmpty ? parts.first : '';
          fetchedLast  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        }

        // Last resort: scan nested
        if (fetchedEmail.isEmpty) fetchedEmail = findStringByKey(data, 'email');

        // 3) Persist locally (so other screens can use it immediately)
        if (fetchedFirst.isNotEmpty) await SecureStorage.write('user_first_name', fetchedFirst);
        if (fetchedLast.isNotEmpty)  await SecureStorage.write('user_last_name',  fetchedLast);
        if (fetchedName.isNotEmpty)  await SecureStorage.write('user_name',       fetchedName);
        if (fetchedEmail.isNotEmpty) await SecureStorage.write('user_email',      fetchedEmail);
        if (fetchedImage.isNotEmpty) await SecureStorage.write('user_image',      fetchedImage);

        // 4) Reflect in UI
        if (mounted) {
          setState(() {
            if (fetchedFirst.isNotEmpty) firstName = fetchedFirst;
            if (fetchedLast.isNotEmpty)  lastName  = fetchedLast;
            if (fetchedName.isNotEmpty)  userName  = fetchedName;
            if (fetchedEmail.isNotEmpty) userEmail = fetchedEmail;
          });
        }
      } else {
        debugPrint('GET /me failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e');
      // keep whatever we had locally
    }
  }


  Future<bool> _hasSession() async {
    final t = await SecureStorage.getToken();
    return t != null && t.isNotEmpty;
  }


  String get _displayName {
    final f = (firstName ?? '').trim();
    final l = (lastName  ?? '').trim();
    if (f.isNotEmpty || l.isNotEmpty) return [f, l].where((s) => s.isNotEmpty).join(' ');
    final n = (userName ?? '').trim();
    return n; // legacy fallback (split logic already handled above)
  }

  Future<void> _loadUserName() async {
    final name     = await SecureStorage.read('user_name');
    final email    = await SecureStorage.read('user_email');
    final imageUrl = await SecureStorage.read('user_image');
    final f        = await SecureStorage.read('user_first_name');
    final l        = await SecureStorage.read('user_last_name');

    setState(() {
      userName        = name ?? '';
      userEmail       = email ?? '';
      profileImageUrl = imageUrl ?? '';
      firstName       = (f ?? '').trim();
      lastName        = (l ?? '').trim();
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

  // ===================== DELETE ACCOUNT FUNCTION =====================
  // In My_Account State class
  Future<void> deleteAccount() async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("No token found.");
      }

      final uri = Uri.parse('https://akarat.com/api/delete');
      http.Response resp = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

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
        // Clear local auth/profile
        await SecureStorage.deleteToken();
        await SecureStorage.delete('user_name');
        await SecureStorage.delete('user_email');
        await SecureStorage.delete('user_image');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully")),
        );

        // 👉 Navigate to LOGIN (not Register)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginDemo()),
              (route) => false,
        );
      } else if (resp.statusCode == 401) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please login again.")),
        );
      } else {
        throw Exception("Failed with status ${resp.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account deletion failed: $e")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileImageProvider>();


    return Scaffold(
      bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
      backgroundColor: Colors.white,
      body: FutureBuilder<bool>(
        // Logged-in means: token exists AND a non-empty email is cached
        future: SecureStorage.isLoggedIn(),
        builder: (context, snap) {
          final waiting = snap.connectionState == ConnectionState.waiting;
          final isLoggedIn = snap.data ?? false;

          if (waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70),
                const Text('My Account',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                // Profile Card
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    child: Row(
                      children: [
                        // Avatar → open Personal Information if logged in
                        GestureDetector(
                          onTap: () async {
                            final token = await SecureStorage.getToken();
                            if (token == null || token.isEmpty) {
                              _showLoginDialog(context);
                              return;
                            }

                            // Make sure local profile is fresh
                            await _ensureProfileLoaded();

                            final changed = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => PersonalInformationScreen(
                                  name: (userName ?? ''),
                                  email: (userEmail ?? ''),
                                  onDeleteAccount: deleteAccount,
                                ),
                              ),
                            );

                            if (changed == true && mounted) {
                              await _ensureProfileLoaded();
                              setState(() {}); // rebuild header
                            }
                          },
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage('assets/images/avatar.png'),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: isLoggedIn
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _displayName.isNotEmpty ? _displayName : 'User',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Registered User",
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          )
                              : GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginDemo()),
                              );

                              setState(() {});
                              await _ensureProfileLoaded();
                              if (mounted) setState(() {});
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

                // Settings (make sure your _buildSettings refreshes UI after logout)
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
    // Build the first group dynamically so "My Account" only shows for guests.
    final List<Widget> primaryTiles = [];

    // ✅ Only show this when NOT logged in (guest users)
    if (!isLoggedIn) {
      primaryTiles.add(
        _settingsTile("My Account", "assets/images/my-account-profile.png", () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
        }),
      );
    }

    // Always show these (both logged-in & guest)
    primaryTiles.addAll([
      _settingsTile("Find My Agent", "assets/images/find-my-agent.png", () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => FindAgentDemo()));
      }),
      _settingsTile("Favorites", "assets/images/favourites.png", () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => Favorite()));
      }),
      _settingsTile("Saved Alerts", "assets/images/favourites.png", () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => SavedAlertsScreen()));
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
    ]);

    return Column(
      children: [
        _settingsContainer(primaryTiles),

        // Second group: auth actions depend on login state
        _settingsContainer(
          isLoggedIn
              ? [
            _settingsTile("Logout", "", () async {
              await SecureStorage.deleteToken();
              await SecureStorage.delete('user_name');
              context.read<ProfileImageProvider>().clear(); // clear profile image
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginDemo()),
                    (route) => false,
              );
            }),
            _settingsTile("Delete your Account", "", () async {
              await AccountService.confirmAndDelete(context);
              final bool? confirmed = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text("Delete Account"),
                  content: const Text("Are you sure you want to delete your account?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
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
                    backgroundColor: Colors.white, // White dialog container
                    title: const Text(
                      'Email not available',
                      style: TextStyle(color: Colors.black), // Title in black
                    ),
                    content: const Text(
                      'No email app is configured on this device. Please add a mail account first.',
                      style: TextStyle(color: Colors.black), // Content in black
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Colors.red), // Red "OK" text
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
