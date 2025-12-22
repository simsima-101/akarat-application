import 'dart:convert';

import 'package:Akarat/screen/home.dart'; // Home screen
import 'package:Akarat/screen/login.dart'; // Login screen (contains LoginDemo)
import 'package:Akarat/screen/my_account.dart'; // Account/Menu screen
import 'package:Akarat/secure_storage.dart';
import 'package:Akarat/services/api_service.dart'; // central base URL
import 'package:Akarat/services/favorite_service.dart';
import 'package:Akarat/utils/fav_logout.dart'; // Favorites screen
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../model/saved_alert.dart';
import 'CreateAlertScreen.dart';

class SavedAlertsScreen extends StatefulWidget {
  final String? token;
  const SavedAlertsScreen({super.key, this.token});

  @override
  State<SavedAlertsScreen> createState() => _SavedAlertsScreenState();
}

class _SavedAlertsScreenState extends State<SavedAlertsScreen> {
  late Future<List<SavedAlert>> _future;
  String? _token;

  List<SavedAlert> _all = [];
  final Set<int> _selected = {};
  bool _selectAll = false;

  static const int _pageSize = 4;
  int _page = 1;
  int _lastCount = 0;
  bool _deletingAll = false;

  int pageIndex = 2;

  @override
  void initState() {
    super.initState();
    _future = _fetchSavedAlerts(initial: true);
    _future.then((list) {
      if (!mounted) return;
      setState(() => _all = list);
    });
  }

  Future<void> _reload({bool goToLast = false}) async {
    setState(() {
      _future = _fetchSavedAlerts().then((list) {
        _all = list;

        final totalPages = _totalPages;
        if (goToLast || list.length > _lastCount) {
          _setPage(totalPages == 0 ? 1 : totalPages, resetSelection: true);
        } else if (_page > totalPages) {
          _setPage(totalPages == 0 ? 1 : totalPages, resetSelection: true);
        }

        _selected.removeWhere((id) => !_all.any((a) => a.id == id));
        _lastCount = list.length;
        return list;
      });
    });
    await _future;
  }

  Future<List<SavedAlert>> _fetchSavedAlerts({bool initial = false}) async {
    _token ??= widget.token ?? await readToken();

    if (_token == null || _token!.isEmpty) {
      if (!mounted) throw Exception('Not authenticated');
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const Login()));
      _token = await readToken();
      if (_token == null || _token!.isEmpty)
        throw Exception('Not authenticated');
    }

    return _loadList(_token!);
  }

  Future<List<SavedAlert>> _loadList(String token) async {
    debugPrint("tokensss : ${token}");
    final url = Uri.parse('${ApiService.baseUrl}/saved-searches');
    final res = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    if (res.statusCode == 401) {
      if (!mounted) throw Exception('Not authenticated');
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const Login()));
      final t2 = await readToken();
      if (t2 == null || t2.isEmpty) throw Exception('Not authenticated');
      _token = t2;
      return _loadList(t2);
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final dynamic jsonBody =
          res.body.isNotEmpty ? jsonDecode(res.body) : null;

      List<dynamic> list;
      if (jsonBody is List) {
        list = jsonBody;
      } else if (jsonBody is Map) {
        final data = jsonBody['data'];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'];
        } else if (jsonBody['saved_searches'] is List) {
          list = jsonBody['saved_searches'];
        } else {
          list = const [];
        }
      } else {
        list = const [];
      }

      return list
          .map((e) => SavedAlert.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Failed to load saved alerts (HTTP ${res.statusCode})';
      throw Exception(msg);
    }
  }

  Future<void> _deleteAlert(SavedAlert a) async {
    if (_token == null) return;
    try {
      final url = Uri.parse('${ApiService.baseUrl}/alerts/${a.id}');
      final res = await http.delete(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
        'X-Requested-With': 'XMLHttpRequest',
      });

      Future<void> applyLocalDelete() async {
        setState(() {
          _all.removeWhere((x) => x.id == a.id);
          _selected.remove(a.id);
        });
        if (_page > 1 && _pageItems.isEmpty) {
          _setPage(_page - 1);
        }
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        await applyLocalDelete();
      } else {
        final fallback =
            Uri.parse('${ApiService.baseUrl}/saved-searches/${a.id}');
        final res2 = await http.delete(fallback, headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
          'X-Requested-With': 'XMLHttpRequest',
        });
        if (res2.statusCode >= 200 && res2.statusCode < 300) {
          await applyLocalDelete();
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete alert')),
          );
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error while deleting')),
      );
    }
  }

  Future<void> _deleteAllAlerts() async {
    if (_token == null || _deletingAll) return;
    _deletingAll = true;

    try {
      final base = ApiService.baseUrl;
      final url = Uri.parse('$base/alerts-deleteall');

      final res = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      http.Response? fallbackRes;
      if (res.statusCode == 405 || res.statusCode == 404) {
        fallbackRes = await http.post(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
            'X-Requested-With': 'XMLHttpRequest',
          },
        );
      }

      final ok = (res.statusCode >= 200 && res.statusCode < 300) ||
          (fallbackRes != null &&
              fallbackRes.statusCode >= 200 &&
              fallbackRes.statusCode < 300);

      if (!mounted) return;

      if (ok) {
        await _reload();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All alerts deleted')),
        );
      } else {
        final code = fallbackRes?.statusCode ?? res.statusCode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete all alerts (HTTP $code)')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error while deleting all alerts: $e')),
      );
    } finally {
      _deletingAll = false;
    }
  }

  String _relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return 'Created ${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return 'Created ${diff.inHours} hours ago';
    return 'Created ${diff.inDays} days ago';
  }

  int get _totalPages {
    if (_all.isEmpty) return 1;
    return ((_all.length - 1) ~/ _pageSize) + 1;
  }

  List<SavedAlert> get _pageItems {
    if (_all.isEmpty) return const [];
    final start = (_page - 1) * _pageSize;
    final int end = ((_page * _pageSize).clamp(0, _all.length));
    if (start >= _all.length) return const [];
    return _all.sublist(start, end);
  }

  void _setPage(int p, {bool resetSelection = false}) {
    final total = _totalPages;
    final newPage = total <= 1 ? 1 : p.clamp(1, total);
    setState(() {
      _page = newPage;
      if (resetSelection) {
        _selected.clear();
        _selectAll = false;
      }
    });
  }

  /// ------------------------------ NAV BAR (EXACTLY LIKE New_Projects) ------------------------------
  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 50, // same as New_Projects
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // HOME
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

          // FAVORITES
          IconButton(
            enableFeedback: false,
            onPressed: () async {
              final token = await SecureStorage.getToken();

              if (token == null || token.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text("Login Required",
                        style: TextStyle(color: Colors.black)),
                    content: const Text("Please login to access favorites.",
                        style: TextStyle(color: Colors.black)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const Login()));
                        },
                        child: const Text("Login",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              } else {
                // Logged in – go to favorites
                Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const Fav_Logout()))
                    .then((_) async {
                  final updatedFavorites =
                      await FavoriteService.fetchApiFavorites(token);
                  if (!mounted) return;
                  setState(() {
                    FavoriteService.loggedInFavorites = updatedFavorites;
                  });
                });
              }
            },
            icon: const Icon(Icons.favorite_border_outlined,
                color: Colors.red, size: 30),
          ),

          // EMAIL
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
                    title: const Text('Email not available',
                        style: TextStyle(color: Colors.black)),
                    content: const Text(
                      'No email app is configured on this device. Please add a mail account first.',
                      style: TextStyle(color: Colors.black),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          // MENU / MY ACCOUNT
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const My_Account()));
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

  bool _alertCreated = false;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> _onCreateAlert() async {
    if (!isLoggedIn) {
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
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
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
                          'Login required to create alerts.',
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
      return;
    }

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAlertScreen(
          initialPurpose: "Rent",
          initialPropertyType: 'Any',
          isFromSavedAlerts: true,
        ),
      ),
    );

    // Optionally refresh saved alerts / show toast if user saved one
    if (saved == true) {
      // e.g., ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert saved')));
    }

    if (!mounted) return;

    if (saved == true) {
      setState(() => _alertCreated = true);

      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar(); // optional
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Alert created'),
          duration: Duration(milliseconds: 1200),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: buildMyNavBar(context),
        ),
      ),
      appBar: AppBar(
        actions: [
          if (_all.isNotEmpty) ...[
            IconButton(
                tooltip: "How to remove saved alerts",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      titlePadding: EdgeInsets.only(
                          top: 24, left: 20, right: 20, bottom: 0),
                      contentPadding: EdgeInsets.only(
                          top: 18, left: 20, right: 20, bottom: 0),
                      actionsPadding: EdgeInsets.only(
                          top: 18, left: 20, right: 30, bottom: 15),
                      title: const Text(
                        "How to Remove saved alerts ?",
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w600),
                      ),
                      content: const Text(
                        "Swipe left on any alert to remove it from your saved list",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            "Got it",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                )),
            Gap(5),
            TextButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text("Clear All Saved Alert?"),
                      content:
                          const Text("This will remove all your saved alerts."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_all.isEmpty || _deletingAll) {
                              Navigator.pop(ctx);
                            } else {
                              _deleteAllAlerts();
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text("Clear",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: Text("Clear All",
                    style: TextStyle(color: Colors.red, fontSize: 15))),
            Gap(10),
          ],
        ],
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.red),
        // title: const Text(
        //   "My Account",
        //   style: TextStyle(color: Colors.deepPurpleAccent),
        // ),
      ),
      body: FutureBuilder<List<SavedAlert>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting &&
                _all.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError && _all.isEmpty) {
              return _ErrorView(
                message: snap.error.toString(),
                onRetry: _reload,
              );
            }

            final int titleCount =
                snap.hasData ? (snap.data?.length ?? _all.length) : _all.length;

            return Column(
              children: [
                if (true) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Saved Alerts',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              height: 1.1),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '($titleCount)',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF4D4D),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Manage your saved property alerts here',
                        style: TextStyle(
                            fontSize: 14, color: Colors.black87, height: 1.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Expanded(
                  child: _all.isEmpty
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'You haven’t saved any alerts yet.',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(24),
                            SizedBox(
                                width: 150, // <-- reduce width here
                                child: CreateAlertButton(
                                  disabled:
                                      _alertCreated, // true after saving the alert
                                  onTap: _onCreateAlert, // normal handler
                                )),
                          ],
                        ))
                      : ListView.builder(
                          itemCount: _pageItems.length,
                          itemBuilder: (context, index) {
                            final alert = _pageItems[index];
                            return Dismissible(
                              key: Key(alert.id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white, size: 30),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text("Delete Saved Alert?"),
                                    content: const Text(
                                        "Are you sure to delete this saved alert."),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text("Cancel",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(ctx, true);
                                        },
                                        child: const Text("Delete",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) async {
                                await _deleteAlert(alert);
                              },
                              child: SavedAlertCard(
                                title: alert.alertName,
                                frequency: alert.timePeriod,
                                created: _relativeTime(alert.createdAt),
                              ),
                            );
                          },
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                ),
              ],
            );
          }),
    );
  }
}

class SavedAlertCard extends StatelessWidget {
  final String title;
  final String frequency;
  final String created;

  const SavedAlertCard({
    super.key,
    required this.title,
    required this.frequency,
    required this.created,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 0),
            color: Colors.grey.shade300,
            blurRadius: 3,
            spreadRadius: 3,
          ),
          // BoxShadow(
          //   offset: Offset(1, 1),
          //   color: Colors.grey.shade300,
          //   blurRadius: 2,
          //   spreadRadius: 2,
          // ),
          // BoxShadow(
          //   offset: Offset(1, 1),
          //   color: Colors.grey.shade300,
          //   blurRadius: 1,
          //   spreadRadius: 2,
          // ),
          // BoxShadow(
          //   offset: Offset(1, 1),
          //   color: Colors.grey.shade300,
          //   blurRadius: 2,
          //   spreadRadius: 2,
          // )
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "Receive updates",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey, width: 0.6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  frequency,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                // const Icon(Icons.keyboard_arrow_down, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            created,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class CreateAlertButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool disabled;

  const CreateAlertButton({
    super.key,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // keep the same visuals always
    const gradient = LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [Color(0xFFFFA3A3), Color(0xFFFFFFFF)],
    );

    return AbsorbPointer(
      // blocks taps but keeps semantics hit-test for parent
      absorbing: disabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          // don't trigger ripple when disabled
          onTap: disabled ? null : onTap,
          splashColor: disabled ? Colors.transparent : null,
          highlightColor: disabled ? Colors.transparent : null,
          child: Container(
            height: 41,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.red, width: 1),
              gradient: gradient,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/bell-red.png',
                  height: 18,
                  width: 18,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.notifications_none,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Create Alert',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $message', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
