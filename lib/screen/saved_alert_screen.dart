import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Akarat imports
import 'package:Akarat/secure_storage.dart';
import 'package:Akarat/screen/login.dart';            // Login / LoginDemo (adjust if needed)
import 'package:Akarat/services/api_service.dart';    // central base URL
import 'package:Akarat/utils/fav_logout.dart';        // Favorites screen (adjust if needed)
import 'package:Akarat/screen/my_account.dart';       // Account/Menu screen (adjust if needed)

// spacing
const double _headerLeftPad   = 0;   // pull header to the very left
const double _afterCheckboxGap = 8;   // gap after the header checkbox
const double _headerColGap     = 20;  // gap between header columns
const double _colGap          = 13;

// text sizes
const double _headerFontSize   = 12;  // smaller header text
const double _rowFontSize     = 11;  // ⬅️ reduced row text a bit
const FontWeight _rowFontWeight = FontWeight.w600;

const double _gapBeforePurposeHeader = 4; // was 26 for others
const double _gapBeforePurposeRow    = 10; // a bit tighter between Time & Purpose in rows

const double _minTableWidth          = 860;


// unified spacing for both header & rows
const double _gapCheckboxToName = 8;


// --- header-only gaps ---
const double _hGapNameToTime     = 10;
const double _hGapTimeToPurpose  = 1;
const double _hGapPurposeToType  = 8;

// --- row-only gaps (you can tweak these without touching header) ---
const double _rGapNameToTime     = 18;
const double _rGapTimeToPurpose  = 18;   // <- different from header
const double _rGapPurposeToType  = 10;


const double _checkColW = 42.0;


const double _trashIconW = 32;       // matches IconButton constraint
const double _gapTypeToTrash = 5;    // ⬅️ gap you want to see





/// Read the auth token from your secure storage.
Future<String?> readToken() async {
  try {
    return await SecureStorage.read('token'); // or SecureStorage.readToken()
  } catch (_) {
    return null;
  }
}

/// -------------------------------- NAV BAR (shared) --------------------------------

Container buildMyNavBar(
    BuildContext context, {
      required int currentIndex, // 0: Home, 1: Fav, 2: Email, 3: Menu
    }) {
  Future<void> openFavorites() async {
    final token = await SecureStorage.read('token');

    if (token == null || token.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Login Required", style: TextStyle(color: Colors.black)),
          content: const Text("Please login to access favorites.", style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
              },
              child: const Text("Login", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      return;
    }

    await Navigator.push(context, MaterialPageRoute(builder: (_) => const Fav_Logout()));
  }

  return Container(
    height: 64,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4)),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Home
        IconButton(
          tooltip: "Home",
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          icon: Image.asset("assets/images/home.png", height: 26),
        ),

        // Favorites
        IconButton(
          tooltip: "Favorites",
          onPressed: openFavorites,
          icon: Icon(
            currentIndex == 1 ? Icons.favorite : Icons.favorite_border_outlined,
            color: Colors.red,
            size: 30,
          ),
        ),

        // Email
        IconButton(
          tooltip: "Email",
          icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
          onPressed: () {},
        ),

        // Menu / My Account
        IconButton(
          tooltip: "Menu",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => My_Account()));
          },
          icon: Icon(
            currentIndex == 3 ? Icons.dehaze : Icons.dehaze_outlined,
            color: Colors.red,
            size: 34,
          ),
        ),
      ],
    ),
  );
}

/// -------------------------------- MODEL --------------------------------

class SavedAlert {
  final int id;
  final String alertName;     // backend: alert_name
  final String timePeriod;    // backend: time_period
  final String purpose;       // pretty label (Rent/Buy/New Projects/Commercial)
  final String propertyType;  // normalized singular slug or '' for Any
  final DateTime createdAt;

  SavedAlert({
    required this.id,
    required this.alertName,
    required this.timePeriod,
    required this.purpose,
    required this.propertyType,
    required this.createdAt,
  });

  factory SavedAlert.fromJson(Map<String, dynamic> j) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      final s = v.toString();
      final d = DateTime.tryParse(s);
      return d ?? DateTime.now();
    }

    int parseInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse('${v ?? ''}') ?? 0;
    }

    String canonPurpose(String p) {
      var s = p.trim().toLowerCase().replaceAll(RegExp(r'[_\s-]+'), ' ');
      if (s.contains('rent')) return 'Rent';
      if (s.contains('buy') || s.contains('sale')) return 'Buy';
      if (s.contains('new')) return 'New Projects';
      if (s.contains('commercial')) return 'Commercial';
      return p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1);
    }

    String tidyType(String t) {
      final s = t.trim().toLowerCase();
      if (s.isEmpty || s == 'any') return '';
      if (s == 'apartments' || s == 'apartment') return 'Apartment';
      if (s == 'villas' || s == 'villa') return 'Villa';
      if (s == 'studios' || s == 'studio') return 'Studio';
      if (s == 'offices' || s == 'office') return 'Office';
      if (s == 'commercials' || s == 'commercial') return 'Commercial';
      return s.replaceAll(' ', '_');
    }

    final name = (j['alert_name'] ?? j['name'] ?? '').toString();
    final period = (j['time_period'] ?? j['frequency'] ?? '').toString();

    String rawPurpose = (j['purpose'] ?? '').toString();
    String typeFromPurpose = '';
    if (rawPurpose.contains('|')) {
      final parts = rawPurpose.split('|');
      rawPurpose = parts.isNotEmpty ? parts.first : rawPurpose;
      typeFromPurpose = parts.length > 1 ? parts[1] : '';
    }

    String propType = (j['property_type'] ?? j['propertyType'] ?? '').toString();
    if (propType.isEmpty && typeFromPurpose.isNotEmpty) {
      propType = tidyType(typeFromPurpose);
    } else {
      propType = tidyType(propType);
    }

    return SavedAlert(
      id: parseInt(j['id']),
      alertName: name,
      timePeriod: period,
      purpose: canonPurpose(rawPurpose),
      propertyType: propType,
      createdAt: parseDate(j['created_at'] ?? j['createdAt']),
    );
  }
}

/// -------------------------------- SCREEN --------------------------------

class SavedAlertsScreen extends StatefulWidget {
  final String? token; // optional token passed from previous screen
  const SavedAlertsScreen({super.key, this.token});

  @override
  State<SavedAlertsScreen> createState() => _SavedAlertsScreenState();
}

class _SavedAlertsScreenState extends State<SavedAlertsScreen> {
  late Future<List<SavedAlert>> _future;
  String? _token; // cache token once resolved

  // UI state
  List<SavedAlert> _all = [];
  final Set<int> _selected = {};
  bool _selectAll = false;

  // Simple client-side pagination
  static const int _pageSize = 4;
  int _page = 1;
  int _lastCount = 0;


  @override
  void initState() {
    super.initState();
    _future = _fetchSavedAlerts(initial: true);
    _future.then((list) {
      if (!mounted) return;
      setState(() {                 // ✅ trigger rebuild with new data
        _all = list;
      });
    });
  }



  Future<void> _reload({bool goToLast = false}) async {
    setState(() {
      _future = _fetchSavedAlerts().then((list) {
        final oldLen = _all.length;
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
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Login()));
      _token = await readToken();
      if (_token == null || _token!.isEmpty) throw Exception('Not authenticated');
    }

    return _loadList(_token!);
  }

  Future<List<SavedAlert>> _loadList(String token) async {
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
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Login()));
      final t2 = await readToken();
      if (t2 == null || t2.isEmpty) throw Exception('Not authenticated');
      _token = t2;
      return _loadList(t2);
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final dynamic jsonBody = res.body.isNotEmpty ? jsonDecode(res.body) : null;

      List<dynamic> list;
      if (jsonBody is List) {
        list = jsonBody;
      } else if (jsonBody is Map) {
        final data = jsonBody['data'];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data']; // paginator
        } else if (jsonBody['saved_searches'] is List) {
          list = jsonBody['saved_searches'];
        } else {
          list = const [];
        }
      } else {
        list = const [];
      }

      return list.map((e) => SavedAlert.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Failed to load saved alerts (HTTP ${res.statusCode})';
      throw Exception(msg);
    }
  }

  // --- Row actions (DELETE) --------------------------------------------------

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
        // if current page is now empty but there are previous pages, go back one
        if (_page > 1 && _pageItems.isEmpty) {
          _setPage(_page - 1);
        }
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        await applyLocalDelete();
      } else {
        final fallback = Uri.parse('${ApiService.baseUrl}/saved-searches/${a.id}');
        final res2 = await http.delete(fallback, headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
          'X-Requested-With': 'XMLHttpRequest',
        });
        if (res2.statusCode >= 200 && res2.statusCode < 300) {
          await applyLocalDelete();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete alert')),
          );
        }
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error while deleting')),
      );
    }
  }


  bool _deletingAll = false;

  Future<void> _deleteAllAlerts() async {
    if (_token == null || _deletingAll) return;
    _deletingAll = true;

    try {
      final base = ApiService.baseUrl;
      final url = Uri.parse('$base/alerts-deleteall');

      // Primary: DELETE
      final res = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      // Fallback: some backends require POST for bulk ops
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
          (fallbackRes != null && fallbackRes.statusCode >= 200 && fallbackRes.statusCode < 300);

      if (!mounted) return;

      if (ok) {
        // Always re-fetch from server to guarantee it’s really empty
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


  Future<void> _deleteSelected() async {
    final ids = _selected.toList();
    for (final id in ids) {
      final item = _all.firstWhere(
            (a) => a.id == id,
        orElse: () => SavedAlert(
          id: -1,
          alertName: '',
          timePeriod: '',
          purpose: '',
          propertyType: '',
          createdAt: DateTime.now(),
        ),
      );
      if (item.id != -1) {
        await _deleteAlert(item);
      }
    }
    setState(() {
      _selectAll = false;
    });
  }

  // --- Helpers ---------------------------------------------------------------

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


// Replace your helpers with these

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

  void _nextPage({bool resetSelection = false}) {
    if (_page < _totalPages) {
      _setPage(_page + 1, resetSelection: resetSelection);
    }
  }

  void _prevPage({bool resetSelection = false}) {
    if (_page > 1) {
      _setPage(_page - 1, resetSelection: resetSelection);
    }
  }



  void _toggleSelectAllOnPage(bool value) {
    setState(() {
      _selectAll = value;
      final idsOnPage = _pageItems.map((e) => e.id);
      if (value) {
        _selected.addAll(idsOnPage);
      } else {
        _selected.removeWhere((id) => idsOnPage.contains(id));
      }
    });
  }



  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Fallback if this is the first route (optional: go home or filter)
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Filter()));
      Navigator.of(context).pop(); // or do nothing
    }
  }

  // --- UI --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F7),
      body: SafeArea(
        child: FutureBuilder<List<SavedAlert>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting && _all.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError && _all.isEmpty) {
              return _ErrorView(
                message: snap.error.toString(),
                onRetry: _reload,
              );
            }

            final int titleCount = snap.hasData ? (snap.data?.length ?? _all.length) : _all.length;

            return Column(
              children: [
                const SizedBox(height: 8),

// ─── Back arrow row (before title & subtitle) ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: _handleBack,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0), // bigger tap target
                            child: Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                          ),
                        ),
                      ),
                      // const SizedBox(width: 4),
                      // const Text(
                      //   'Back',
                      //   style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),


                // Title
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
                          height: 1.1,
                        ),
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

                const SizedBox(height: 6),

                // Subtitle
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Manage your saved property alerts here',
                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Table card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header row
                          _headerRow(
                            onSelectAll: (v) => _toggleSelectAllOnPage(v ?? false),
                            value: _selectAll,
                          ),

                          const Divider(height: 1, color: Color(0xFFECECEC)),

                          // Rows
                          Expanded(
                            child: _all.isEmpty
                                ? const Center(child: Text('No saved alerts yet.'))
                                : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _pageItems.length,
                              itemBuilder: (_, i) {
                                final a = _pageItems[i];
                                final checked = _selected.contains(a.id);
                                return _dataRow(
                                  alert: a,
                                  checked: checked,
                                  onCheck: (v) {
                                    setState(() {
                                      if (v == true) {
                                        _selected.add(a.id);
                                      } else {
                                        _selected.remove(a.id);
                                      }
                                      final allOnPageSelected = _pageItems.every(
                                              (x) => _selected.contains(x.id));
                                      _selectAll = allOnPageSelected;
                                    });
                                  },
                                  onDelete: () => _deleteAlert(a),
                                  createdLabel: _relativeTime(a.createdAt),
                                );
                              },
                            ),
                          ),

                          // Footer controls: delete all + pagination
                          LayoutBuilder(
                            builder: (context, cs) {
                              final narrow = cs.maxWidth < 420; // tweak threshold as you like
                              final double txt = narrow ? 12 : 14;

                              return Row(
                                children: [
                                  // LEFT: controls (expand & allow wrapping)
                                  Expanded(
                                    child: Wrap(
                                      alignment: WrapAlignment.start,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        // ✅ Select all on this page (make this WRAP, not Row)
                                        Wrap(
                                          spacing: 6,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            Checkbox(
                                              visualDensity: VisualDensity.compact,
                                              value: _pageItems.isNotEmpty &&
                                                  _pageItems.every((a) => _selected.contains(a.id)),
                                              onChanged: (v) => _toggleSelectAllOnPage(v ?? false),
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            Text(
                                              narrow ? 'Select all' : 'Select all on this page',
                                              style: TextStyle(fontSize: txt),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),

                                        // 🗑 Delete selected
                                        // ✅ Delete selected (unchanged)
                                        TextButton.icon(
                                          onPressed: _selected.isEmpty ? null : _deleteSelected,
                                          icon: Icon(Icons.delete_outline, size: narrow ? 16 : 20),
                                          label: Text('Delete selected', style: TextStyle(fontSize: txt)),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: narrow ? 8 : 12,
                                              vertical: narrow ? 6 : 8,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ),

// ✅ Delete all alerts — now matches "Delete selected" (no border)
                                        TextButton.icon(
                                          onPressed: (_all.isEmpty || _deletingAll) ? null : _deleteAllAlerts,
                                          icon: Icon(Icons.delete_forever_outlined, size: narrow ? 16 : 20),
                                          label: Text(
                                            _deletingAll ? 'Deleting…' : 'Delete all alerts',
                                            style: TextStyle(fontSize: txt),
                                          ),
                                          style: ButtonStyle(
                                            // Same compact layout
                                            padding: WidgetStatePropertyAll(
                                              EdgeInsets.symmetric(
                                                horizontal: narrow ? 8 : 12,
                                                vertical: narrow ? 6 : 8,
                                              ),
                                            ),
                                            minimumSize: const WidgetStatePropertyAll(Size.zero),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,

                                            // Red when enabled, dimmed when disabled
                                            foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                                              if (states.contains(WidgetState.disabled)) {
                                                return Colors.red.withOpacity(0.38); // M3 disabled foreground
                                              }
                                              return Colors.red;
                                            }),

                                            // Remove any background/border
                                            backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
                                            overlayColor: WidgetStatePropertyAll(Colors.red.withOpacity(0.08)),
                                            side: const WidgetStatePropertyAll(BorderSide.none),
                                            shape: const WidgetStatePropertyAll(StadiumBorder()),
                                          ),
                                        ),


                                      ],
                                    ),
                                  ),

                                  // RIGHT: pager (expand, align right, allow horizontal scroll)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SizedBox(
                                            height: 34,
                                            child: FittedBox(
                                              child: _pager(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );

                            },
                          )

                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),

      // 🔻 Global bottom navigator (replaces old gradient bar)
      bottomNavigationBar: buildMyNavBar(context, currentIndex: 1),
    );
  }

  bool get _isAllSelectedGlobally => _all.isNotEmpty && _selected.length == _all.length;

  Widget _headerRow({
    required bool value,
    required ValueChanged<bool?> onSelectAll,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F4F4),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // fixed checkbox column
          SizedBox(
            width: _checkColW,
            child: Transform.scale(
              scale: 0.85,
              child: Checkbox(
                value: value,
                onChanged: onSelectAll,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

          // columns (same flex & gaps as rows)
          const _HeaderCell('Alert Name', flex: 4, fontSize: _headerFontSize),
          const SizedBox(width: _hGapNameToTime),

          const _HeaderCell('Time', flex: 3, fontSize: _headerFontSize),
          const SizedBox(width: _hGapTimeToPurpose),

          const _HeaderCell('Purpose', flex: 3, fontSize: _headerFontSize),
          const SizedBox(width: _hGapPurposeToType),

          const _HeaderCell('Property Type', flex: 4, fontSize: _headerFontSize),

        ],
      ),
    );
  }



  Widget _dataRow({
    required SavedAlert alert,
    required bool checked,
    required ValueChanged<bool?> onCheck,
    required VoidCallback onDelete,
    required String createdLabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          // ── TOP GRID ROW (no delete icon here) ────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // checkbox
              SizedBox(
                width: _checkColW,
                child: Transform.scale(
                  scale: 0.85,
                  child: Checkbox(
                    value: checked,
                    onChanged: onCheck,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),

              // Alert Name
              Expanded(
                flex: 4,
                child: _CellText(
                  alert.alertName,
                  fontSize: _rowFontSize,
                  fontWeight: _rowFontWeight,
                ),
              ),
              const SizedBox(width: _rGapNameToTime),

              // Time period (single line)
              Expanded(
                flex: 3,
                child: _CellText(
                  alert.timePeriod,
                  fontSize: _rowFontSize,
                  fontWeight: _rowFontWeight,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: _rGapTimeToPurpose),

              // Purpose (max 2 lines)
              Expanded(
                flex: 3,
                child: _CellText(
                  alert.purpose,
                  fontSize: _rowFontSize,
                  fontWeight: _rowFontWeight,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: _rGapPurposeToType),

              // Property Type (exactly 1 line)
              Expanded(
                flex: 4,
                child: _CellText(
                  alert.propertyType.isEmpty ? 'Any' : alert.propertyType,
                  fontSize: _rowFontSize,
                  fontWeight: _rowFontWeight,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // ── BOTTOM ROW: Created label + Delete icon on the SAME line ─────────
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    createdLabel,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                  iconSize: 16,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline, color: Colors.black54),
                ),
              ],
            ),
          ),

          const Divider(height: 20, color: Color(0xFFECECEC)),
        ],
      ),
    );
  }



  // Pagination controls
  Widget _pager() {
    final total = _totalPages;
    final canPrev = _page > 1;
    final canNext = _page < total;

    Widget navButton(IconData icon, bool enabled, VoidCallback onTap) {
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(icon, size: 20, color: enabled ? Colors.black87 : Colors.black26),
        ),
      );
    }

    Widget currentPageChip() {
      return Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF2D6CF6),
        ),
        child: Text(
          '$_page',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        navButton(Icons.chevron_left, canPrev, _prevPage),
        const SizedBox(width: 8),
        currentPageChip(), // 👈 only the current page number
        const SizedBox(width: 8),
        navButton(Icons.chevron_right, canNext, _nextPage),
      ],
    );
  }

}

/// -------------------------------- UI bits --------------------------------

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final double fontSize;

  const _HeaderCell(
      this.text, {
        this.flex = 1,
        this.fontSize = _headerFontSize,
      });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,         // ✅ never hide with dots
        textScaler: const TextScaler.linear(1), // ✅ ignore system text scaling here
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          height: 1.2,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}



class _CellText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final FontWeight fontWeight;
  final double fontSize;

  // NEW:
  final int? maxLines;                 // null = unlimited
  final bool softWrap;                 // whether to wrap lines
  final TextOverflow overflow;         // how to overflow

  const _CellText(
      this.text, {
        this.fontWeight = FontWeight.w400,
        this.fontSize = 13,
        // defaults keep previous behavior
        this.maxLines,
        this.softWrap = true,
        this.overflow = TextOverflow.visible,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      softWrap: softWrap,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: Colors.black87,
        height: 1.25,
      ),
    );
  }
}


// Placeholder to align with row checkbox space
class _HeaderCheckboxPlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const _HeaderCheckboxPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}


class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

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

/// Kept in case you want it later (currently unused)
class _ShrinkText extends StatelessWidget {
  final String text;
  final double baseSize;
  final double minSize;
  final TextAlign? textAlign;
  final FontWeight fontWeight;
  final Color? color;

  const _ShrinkText(
      this.text);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, __) => FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: baseSize,
            fontWeight: fontWeight,
            color: color ?? Colors.black87,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
