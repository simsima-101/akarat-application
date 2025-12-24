import 'dart:convert';


// Akarat imports
import 'package:Akarat/src/core/utils/secure_storage.dart';

import 'package:Akarat/src/screen/saved_alert_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/constants/constants.dart' as ApiService;
import '../features/property/data/models/property_type_model.dart';
import 'login.dart';

/// ✅ Read the auth token from your secure storage correctly.
Future<String?> readToken() async {
  try {
    // IMPORTANT: use the same helper you use everywhere else
    return await SecureStorage.getToken();
  } catch (_) {
    return null;
  }
}

class CreateAlertScreen extends StatefulWidget {
  final String
      initialPurpose; // e.g., "Rent" | "Buy" | "New Projects" | "Commercial"
  final String initialPropertyType; // e.g., "Villa" | "Apartment" | ""
  final bool isFromSavedAlerts;
  const CreateAlertScreen({
    super.key,
    required this.initialPurpose,
    required this.initialPropertyType,
    this.isFromSavedAlerts = false,
  });

  @override
  State<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends State<CreateAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  late String _timePeriod; // UI: Hourly | Daily | Weekly | Monthly
  late String _purpose; // Locked display from caller
  late String _propertyType; // '' = Any (locked)

  final _timePeriods = const ['Hourly', 'Daily', 'Weekly', 'Monthly'];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    fetchAllPropertyType();

    _timePeriod = _timePeriods.first;
    _purpose = widget.initialPurpose.trim();

    final seen = <String>{};

    final raw = widget.initialPropertyType.trim();
    final rawLower = raw.toLowerCase();
    const anyMarkers = {'', 'all', 'any', 'all residential'};
    _propertyType = anyMarkers.contains(rawLower) ? '' : raw;

    // default alert name reflects the combo
    final labelType = _propertyType.isEmpty ? 'Any' : _propertyType;
    _nameCtrl.text = '$_purpose • $labelType';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ---------- Helpers (mappers) ----------

  InputDecoration _dec(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
      ),
    );
  }

  String _mapTimePeriodForApi(String period) {
    switch (period.trim().toLowerCase()) {
      case 'hourly':
        return 'hourly';
      case 'daily':
        return 'daily';
      case 'weekly':
        return 'weekly';
      case 'monthly':
        return 'monthly';
      default:
        return 'daily';
    }
  }

  String _mapTypeForApi(String t) {
    final s = t.trim().toLowerCase();
    if (s.isEmpty || s == 'all residential' || s == 'any' || s == 'all') {
      return '';
    }
    if (s.startsWith('office')) return 'office';
    if (s.startsWith('commercial')) return 'commercial';
    if (s.startsWith('apart')) return 'apartment';
    if (s.startsWith('villa')) return 'villa';
    if (s.startsWith('studio')) return 'studio';

    return s.replaceAll(' ', '_');
  }

  // ---------- Auth & navigation ----------

  Future<String?> _requireAuth() async {
    final token = await readToken();
    if (!mounted) return null;

    // If token is missing, still go to Login (this will only happen
    // if user is REALLY logged out; otherwise it will now get the token correctly)
    if (token == null || token.isEmpty) {
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const Login()));
      final t2 = await readToken();
      return (t2 != null && t2.isNotEmpty) ? t2 : null;
    }
    return token;
  }

  Future<void> _openSavedAlerts() async {
    final token = await _requireAuth();
    if (token == null || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SavedAlertsScreen(token: token)),
    );
  }

  // Make 'New Projects' == 'new_projects', 'Buy' == 'Sale', trim, etc.
  String _canonPurpose(String p) {
    var s = p.trim().toLowerCase().replaceAll(RegExp(r'[_\s-]+'), ' ');
    if (s.contains('rent')) return 'rent';
    if (s.contains('buy') || s.contains('sale')) return 'buy';
    if (s.contains('new')) return 'new projects';
    if (s.contains('commercial')) return 'commercial';
    return s;
  }

  // Ensure unique alert name (avoids “name already taken”)
  Future<String> _uniqueName(String base, String token) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/saved-searches');
      final res = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'X-Requested-With': 'XMLHttpRequest',
      });
      if (res.statusCode < 200 || res.statusCode >= 300) return base;

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      List<dynamic> list;
      if (body is List) {
        list = body;
      } else if (body is Map) {
        final data = body['data'];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'];
        } else if (body['saved_searches'] is List) {
          list = body['saved_searches'];
        } else {
          list = const [];
        }
      } else {
        list = const [];
      }

      final existing = list
          .map((e) => ((e as Map)['alert_name'] ?? (e)['name'] ?? '')
              .toString()
              .trim()
              .toLowerCase())
          .toSet();

      if (!existing.contains(base.trim().toLowerCase())) return base;

      for (int i = 2; i <= 50; i++) {
        final candidate = '$base ($i)';
        if (!existing.contains(candidate.toLowerCase())) return candidate;
      }
      return '${base}_${DateTime.now().millisecondsSinceEpoch}';
    } catch (_) {
      return base;
    }
  }

  // ---------- Save ----------

  Future<void> _save(bool isFromSavedAlerts) async {
    if (!_formKey.currentState!.validate()) return;

    final token = await _requireAuth();
    if (token == null) return;

    setState(() => _submitting = true);

    // Keep a clean label for UI/name
    final purposeForUi = _purpose.trim();
    final typeSlug = _mapTypeForApi(
        _propertyType); // apartment|villa|studio|office|commercial or ''

    // 🔑 Composite key so the server treats each combo as unique
    final purposeServerKey =
        '${_canonPurpose(purposeForUi)}|${typeSlug.isEmpty ? 'any' : typeSlug}';

    // 1) Meaningful default name (unique by combo)
    String alertName = _nameCtrl.text.trim();
    if (alertName.isEmpty) {
      final labelType = _propertyType.isEmpty ? 'Any' : _propertyType;
      alertName = '$purposeForUi • $labelType';
    }

    // Avoid name-only clashes
    alertName = await _uniqueName(alertName, token);

    // 2) Build payload
    final payload = <String, dynamic>{
      'alert_name': alertName,
      'time_period':
          _mapTimePeriodForApi(_timePeriod), // hourly|daily|weekly|monthly
      'purpose': purposeServerKey, // <-- composite key
      if (typeSlug.isNotEmpty) 'property_type': typeSlug,
    };

    debugPrint('CREATE ALERT payload => ${jsonEncode(payload)}');
    debugPrint(
        '🛰️ Save Alert: purposeUi="$purposeForUi", purposeKey="$purposeServerKey", typeSlug="$typeSlug"');

    try {
      final url = Uri.parse('${ApiService.baseUrl}/alerts');
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $token',
      };

      var res =
          await http.post(url, headers: headers, body: jsonEncode(payload));
      debugPrint('POST /alerts -> ${res.statusCode} ${res.body}');

      // If server still says duplicate/name conflict, auto-rename & retry once
      if (res.statusCode == 409 || res.statusCode == 422) {
        final newName = await _uniqueName('$alertName • 2', token);
        final retryPayload = Map<String, dynamic>.from(payload)
          ..['alert_name'] = newName;
        res = await http.post(url,
            headers: headers, body: jsonEncode(retryPayload));
        debugPrint('POST /alerts (retry) -> ${res.statusCode} ${res.body}');
      }

      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // ✅ On success, go to SavedAlertsScreen (as you wanted)

        if (isFromSavedAlerts) {
          Navigator.pop(context);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => SavedAlertsScreen(token: token)),
          );
        } else {
          Navigator.pop(context);
        }

        return;
      }

      // Show specific server error if present
      String msg = 'Failed to save alert';
      try {
        final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
        if (body is Map) {
          if (body['errors'] is Map && (body['errors'] as Map).isNotEmpty) {
            final errs = (body['errors'] as Map)
                .values
                .map((v) => (v is List && v.isNotEmpty)
                    ? v.first.toString()
                    : v.toString())
                .join('\n');
            msg = errs;
          } else if (body['message'] != null) {
            msg = body['message']..toString();
          }
        }
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  PropertyTypeModel? propertyTypeModel;

  Future<void> fetchAllPropertyType() async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}/property-types');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feature = PropertyTypeModel.fromJson(data);

        setState(() {
          propertyTypeModel = feature; // <-- IMPORTANT
        });
      } else {
        debugPrint("❌ Property API failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Property API error: $e");
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openSavedAlerts,
            icon: const Icon(Icons.notifications_active_outlined,
                color: Colors.black),
            tooltip: 'Saved Alerts',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: propertyTypeModel == null
          ? Center(
              child: CupertinoActivityIndicator(
              radius: 14,
            ))
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 2,
                            spreadRadius: 2,
                            offset: Offset(1, 1))
                      ],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -6,
                          top: -8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            const Text(
                              'Create Alert',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Alert Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _nameCtrl,
                                    decoration: _dec('Alert Name'),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Please enter a name'
                                            : null,
                                  ),
                                  const SizedBox(height: 16),

                                  const Text('Time Period',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    dropdownColor: Colors.white,
                                    value: _timePeriod,
                                    decoration: _dec(''),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: _timePeriods
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (v) => setState(
                                        () => _timePeriod = v ?? _timePeriod),
                                  ),
                                  const SizedBox(height: 16),

                                  // Purpose (locked)
                                  const Text('Purpose',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Color(0xFFE7E7E7)),
                                    ),
                                    child: Text(_purpose,
                                        style: const TextStyle(fontSize: 16)),
                                  ),
                                  const SizedBox(height: 16),

                                  // Property Type (locked)
                                  const Text('Property Type',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    menuMaxHeight: 340,
                                    value: _propertyType.isEmpty
                                        ? null
                                        : _propertyType,
                                    decoration:
                                        _dec('Any'), // <-- hint shows when null
                                    hint: const Text('Any'),
                                    dropdownColor: Colors.white,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: propertyTypeModel!.data!.map((pt) {
                                      return DropdownMenuItem(
                                        value: pt.name,
                                        child: Text(pt.name ?? ''),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _propertyType = value ?? '';
                                        final labelType = _propertyType.isEmpty
                                            ? 'Any'
                                            : _propertyType;
                                        _nameCtrl.text =
                                            '$_purpose • $labelType';
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _pillButton(
                                    label: 'Cancel',
                                    onTap: () => Navigator.pop(context),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _pillButton(
                                    label:
                                        _submitting ? 'Saving…' : 'Save Alert',
                                    onTap: _submitting
                                        ? () {}
                                        : () async {
                                            await _save(
                                                widget.isFromSavedAlerts);
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _pillButton({required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8A8A)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
