import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../secure_storage.dart';
import '../services/api_service.dart';
import 'login.dart';

class PersonalInformationScreen extends StatefulWidget {
  final String? name;        // optional initial values (fallback)
  final String? email;       // optional initial values
  final String? firstName;   // ✅ NEW: preferred initial first name
  final String? lastName;    // ✅ NEW: preferred initial last name

  final Future<void> Function() onDeleteAccount;
  final String? afterSaveRouteName;

  const PersonalInformationScreen({
    super.key,
    this.name,
    this.email,
    this.firstName,
    this.lastName,
    required this.onDeleteAccount,
    this.afterSaveRouteName,
  });

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;

  final TextEditingController _passwordCtrl = TextEditingController(); // (unused in UI now)
  final TextEditingController _currentPwdCtrl = TextEditingController();
  final TextEditingController _newPwdCtrl     = TextEditingController();
  final TextEditingController _confirmPwdCtrl = TextEditingController();

  bool _loading = false;
  bool _editMode = false;

  // visibility toggles
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _obscureCurrent = true;

  bool _looksHtml(http.Response r) {
    final ct = (r.headers['content-type'] ?? '').toLowerCase();
    if (ct.contains('text/html')) return true;
    final body = r.body.trimLeft();
    return body.startsWith('<!doctype') || body.startsWith('<html');
  }

  /// Try GET /me against a specific baseUrl. Returns JSON map or null (if not JSON).
  Future<Map<String, dynamic>?> _tryMe(String baseUrl, String token) async {
    final uri = Uri.parse('$baseUrl/me');
    final r = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (_looksHtml(r)) {
      debugPrint('ME at $uri returned HTML (status ${r.statusCode}).');
      return null;
    }
    if (r.statusCode != 200) {
      debugPrint('ME at $uri -> ${r.statusCode} ${r.body}');
      return null;
    }

    try {
      final decoded = json.decode(r.body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      debugPrint('ME decode error for $uri: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    // Start with whatever the caller passed.
    _firstNameCtrl = TextEditingController(text: widget.firstName ?? '');
    _lastNameCtrl  = TextEditingController(text: widget.lastName ?? '');
    _nameCtrl      = TextEditingController(text: widget.name ?? '');
    _emailCtrl     = TextEditingController(text: widget.email ?? '');

    _newPwdCtrl.addListener(() => setState(() {}));

    // Hydrate from local storage (same source as My Account)
    _hydrateFromLocal().then((_) {
      // Try API refresh (best-effort). Even if it fails, UI is already correct.
      _fetchProfileFromApi();
    });
  }

  Future<void> _hydrateFromLocal() async {
    // ✅ Do NOT delete any cache here.
    final localFirst = (await SecureStorage.read('user_first_name') ?? '').trim();
    final localLast  = (await SecureStorage.read('user_last_name')  ?? '').trim();
    final localEmail = (await SecureStorage.read('user_email')      ?? '').trim();

    // If no explicit first/last were passed, use local
    final first = (widget.firstName ?? '').trim().isNotEmpty ? widget.firstName!.trim() : localFirst;
    final last  = (widget.lastName  ?? '').trim().isNotEmpty ? widget.lastName!.trim()  : localLast;
    final email = _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : localEmail;

    // Build a name only for display; we still store first/last separately
    final joinedName = [first, last].where((s) => s.isNotEmpty).join(' ');

    if (!mounted) return;
    setState(() {
      _firstNameCtrl.text = first;
      _lastNameCtrl.text  = last;
      _emailCtrl.text     = email;
      // keep name as a convenience display field (not used for saving)
      if (_nameCtrl.text.trim().isEmpty) _nameCtrl.text = joinedName;
    });

    debugPrint('PI local hydrate → first="$first" last="$last" email="$email"');
  }

  List<String> _splitName(String full) {
    final s = full.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (s.isEmpty) return ['', ''];
    final parts = s.split(' ');
    if (parts.length == 1) return [parts[0], ''];
    return [parts.first, parts.sublist(1).join(' ')];
  }

  String _joinName(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    return (f.isEmpty || l.isEmpty) ? ('$f $l').trim() : '$f $l';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();

    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    _currentPwdCtrl.dispose();
    _passwordCtrl.dispose();

    super.dispose();
  }

  Future<void> _fetchProfileFromApi() async {
    try {
      setState(() => _loading = true);
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) return;

      final base = ApiService.baseUrl; // e.g. https://qa.akarat.com/api
      Map<String, dynamic>? data;

      // 1) Try current base
      data = await _tryMe(base, token);

      // 2) If HTML or non-JSON, auto-retry with alternate host (qa <-> prod)
      if (data == null) {
        final altBase = base.contains('qa.akarat.com')
            ? base.replaceFirst('qa.akarat.com', 'akarat.com')
            : base.replaceFirst('akarat.com', 'qa.akarat.com');
        if (altBase != base) {
          debugPrint('Retrying /me on alternate base: $altBase');
          data = await _tryMe(altBase, token);
        }
      }

      // 3) If still null, bail without touching local cache
      if (data == null) {
        debugPrint('Could not refresh profile (non-JSON from /me). Using local values.');
        return;
      }

      String pickStr(List<List<String>> paths) {
        for (final keys in paths) {
          dynamic cur = data;
          for (final k in keys) {
            if (cur is Map && cur.containsKey(k)) {
              cur = cur[k];
            } else {
              cur = null;
              break;
            }
          }
          final s = (cur is String ? cur : cur?.toString() ?? '').trim();
          if (s.isNotEmpty) return s;
        }
        return '';
      }

      final fetchedFirst = pickStr([
        ['first_name'], ['data','first_name'], ['user','first_name'], ['data','user','first_name'],
      ]);
      final fetchedLast = pickStr([
        ['last_name'], ['data','last_name'], ['user','last_name'], ['data','user','last_name'],
      ]);
      final fetchedEmail = pickStr([
        ['email'], ['data','email'], ['user','email'], ['data','user','email'],
      ]);

      if (!mounted) return;
      setState(() {
        if (fetchedFirst.isNotEmpty) _firstNameCtrl.text = fetchedFirst;
        if (fetchedLast.isNotEmpty)  _lastNameCtrl.text  = fetchedLast;
        if (fetchedEmail.isNotEmpty) _emailCtrl.text     = fetchedEmail;

        final display = [
          _firstNameCtrl.text.trim(),
          _lastNameCtrl.text.trim(),
        ].where((s) => s.isNotEmpty).join(' ').trim();
        if (display.isNotEmpty) _nameCtrl.text = display;
      });

      // Persist only non-empty values (keeps My Account in sync)
      if (fetchedFirst.isNotEmpty) await SecureStorage.write('user_first_name', fetchedFirst);
      if (fetchedLast .isNotEmpty) await SecureStorage.write('user_last_name',  fetchedLast);
      if (fetchedEmail.isNotEmpty) await SecureStorage.write('user_email',      fetchedEmail);
      final joined = [_firstNameCtrl.text.trim(), _lastNameCtrl.text.trim()]
          .where((s) => s.isNotEmpty).join(' ').trim();
      if (joined.isNotEmpty) await SecureStorage.write('user_name', joined);

    } catch (e) {
      debugPrint('fetch profile error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _loading = true);

      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are not logged in')),
          );
        }
        return;
      }

      final base = ApiService.baseUrl;               // e.g. https://qa.akarat.com/api
      final url  = Uri.parse('$base/update');        // backend: POST /api/update

      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final first      = _firstNameCtrl.text.trim();
      final last       = _lastNameCtrl.text.trim();
      final joinedName = _joinName(first, last);

      final newPwd     = _newPwdCtrl.text.trim();
      final confirmPwd = _confirmPwdCtrl.text.trim();
      final currentPwd = _currentPwdCtrl.text.trim();

      final payload = <String, dynamic>{
        'first_name': first,
        'last_name':  last,
        'name':       joinedName,              // legacy compatibility
        'email':      _emailCtrl.text.trim(),  // email read-only in UI
      };

      if (newPwd.isNotEmpty) {
        if (newPwd.length < 8) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New password must be at least 8 characters')),
            );
          }
          return;
        }
        if (newPwd != confirmPwd) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New password and confirmation do not match')),
            );
          }
          return;
        }
        if (currentPwd.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enter your current password to change it')),
            );
          }
          return;
        }

        payload['password']              = newPwd;
        payload['password_confirmation'] = confirmPwd;
        payload['current_password']      = currentPwd;
      }

      final resp = await http.post(url, headers: headers, body: jsonEncode(payload));

      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);

        // Save updated fields locally for UI (keeps My Account consistent)
        await SecureStorage.write('user_first_name', first);
        await SecureStorage.write('user_last_name',  last);
        await SecureStorage.write('user_name',       joinedName);
        await SecureStorage.write('user_email',      _emailCtrl.text.trim());

        _nameCtrl.text = joinedName;

        final newToken = (body['token'] ?? '').toString().trim();
        if (newToken.isNotEmpty) {
          await SecureStorage.writeToken(newToken);
          debugPrint('UPDATE → rotated token saved');
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );

        setState(() {
          _editMode = false;
          _newPwdCtrl.clear();
          _confirmPwdCtrl.clear();
          _currentPwdCtrl.clear();
        });

        final route = widget.afterSaveRouteName;
        if (route != null && route.isNotEmpty) {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(route);
        } else if (Navigator.of(context).canPop()) {
          if (!mounted) return;
          Navigator.of(context).pop(true);
        } else {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/my-account');
        }
        return;
      }

      if (resp.statusCode == 401 || resp.statusCode == 403) {
        await _signOutLocalOnly();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session expired (${resp.statusCode}). Please log in again.')),
          );
          _goLogin();
        }
        return;
      }

      if (resp.statusCode == 422) {
        try {
          final m = json.decode(resp.body);
          String msg = (m['message'] ?? 'Validation error').toString();
          if (m['errors'] is Map && (m['errors'] as Map).isNotEmpty) {
            final firstKey = (m['errors'] as Map).keys.first;
            final list = m['errors'][firstKey];
            if (list is List && list.isNotEmpty) {
              msg = list.first.toString();
            }
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          }
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Validation error')),
            );
          }
        }
        return;
      }

      String msg = 'Update failed: ${resp.statusCode}';
      try {
        final m = json.decode(resp.body);
        final s = (m['message'] ?? m['error'] ?? '').toString().trim();
        if (s.isNotEmpty) msg = s;
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ===================== Delete via API =====================
  Future<void> _deleteAccountViaApi() async {
    setState(() => _loading = true);
    try {
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are not logged in')),
          );
        }
        return;
      }

      final base = ApiService.baseUrl;
      final del  = Uri.parse('$base/delete');
      final me   = Uri.parse('$base/me');

      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest',
      };

      final body = jsonEncode(<String, dynamic>{ 'token': token });

      debugPrint('[DELETE] $del');
      http.Response resp;
      try {
        final rq = http.Request('DELETE', del)
          ..headers.addAll(headers)
          ..body = body;
        final streamed = await rq.send().timeout(const Duration(seconds: 20));
        resp = await http.Response.fromStream(streamed);
        debugPrint('DELETE status=${resp.statusCode} body=${resp.body}');
      } on TimeoutException catch (e) {
        debugPrint('DELETE timeout: $e');
        await _signOutLocalOnly();
        _goLogin();
        return;
      } catch (e) {
        debugPrint('DELETE exception: $e');
        rethrow;
      }

      final ok = <int>{200, 202, 204, 205, 302, 307}.contains(resp.statusCode);
      if (ok) {
        bool looksDeleted = true;
        try {
          final meResp = await http.get(me, headers: headers).timeout(const Duration(seconds: 6));
          debugPrint('ME after delete => ${meResp.statusCode} ${meResp.body}');
          looksDeleted = (meResp.statusCode == 401 || meResp.statusCode == 403 || meResp.statusCode == 404);
        } catch (e) {
          debugPrint('ME check after delete failed: $e');
        }

        await _signOutLocalOnly();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(looksDeleted
                ? 'Account deleted successfully'
                : 'Deleted (client signed out), but server still shows active.'),
          ));
        }
        _goLogin();
        return;
      }

      if (resp.statusCode == 401 || resp.statusCode == 403) {
        await _signOutLocalOnly();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session expired (${resp.statusCode}). Please log in again.')),
          );
        }
        _goLogin();
        return;
      }

      String msg = 'Delete failed (${resp.statusCode}).';
      try {
        final m = json.decode(resp.body);
        final s = (m['message'] ?? m['error'] ?? '').toString().trim();
        if (s.isNotEmpty) msg = s;
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // wipe local session only
  Future<void> _signOutLocalOnly() async {
    await SecureStorage.deleteToken();
    await SecureStorage.delete('user_name');
    await SecureStorage.delete('user_email');
    await SecureStorage.delete('user_image');
    await SecureStorage.delete('user_first_name');
    await SecureStorage.delete('user_last_name');
  }

  void _goLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginDemo()),
            (_) => false,
      );
    });
  }

  InputDecoration _dec(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _editMode && !_loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          if (!_editMode)
            TextButton(
              onPressed: _loading ? null : () => setState(() => _editMode = true),
              child: const Text('Edit', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          if (_editMode) ...[
            TextButton(
              onPressed: _loading ? null : _saveProfile,
              child: const Text('Save', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: _loading
                  ? null
                  : () {
                setState(() {
                  _editMode = false;
                  _newPwdCtrl.clear();
                  _confirmPwdCtrl.clear();
                  _currentPwdCtrl.clear();
                });
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
            ),
          ],
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: AbsorbPointer(
        absorbing: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameCtrl,
                        readOnly: !canEdit,
                        decoration: _dec('First name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'First name is required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameCtrl,
                        readOnly: !canEdit,
                        decoration: _dec('Last name'),
                        validator: (v) => null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailCtrl,
                  readOnly: true,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _dec('Email').copyWith(helperText: 'Email cannot be changed'),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Email is required';
                    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
                    return emailOk ? null : 'Enter a valid email';
                  },
                ),

                const SizedBox(height: 12),

                if (_editMode) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Change password (optional)',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _newPwdCtrl,
                    readOnly: !_editMode,
                    obscureText: _obscureNew,
                    decoration: _dec('New password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      helperText: 'Leave blank to keep your current password',
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _confirmPwdCtrl,
                    readOnly: !_editMode,
                    obscureText: _obscureConfirm,
                    decoration: _dec('Confirm new password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (_editMode && _newPwdCtrl.text.trim().isNotEmpty) {
                        if ((v ?? '').trim().isEmpty) return 'Please confirm the new password';
                        if (v!.trim() != _newPwdCtrl.text.trim()) return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  if (_newPwdCtrl.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _currentPwdCtrl,
                      readOnly: !_editMode,
                      obscureText: _obscureCurrent,
                      decoration: _dec('Current password (required to change)').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        ),
                      ),
                      validator: (v) {
                        if (_newPwdCtrl.text.trim().isNotEmpty && (v ?? '').trim().isEmpty) {
                          return 'Enter your current password';
                        }
                        return null;
                      },
                    ),
                  ],
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _confirmAndDelete,
                    child: const Text('Delete your account'),
                  ),
                ),

                if (_loading) ...[
                  const SizedBox(height: 14),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed == true) {
      await _deleteAccountViaApi();
    }
  }
}
