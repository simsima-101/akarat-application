import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../secure_storage.dart';
import '../services/account_service.dart';
import '../services/api_service.dart';
import 'login.dart';

class PersonalInformationScreen extends StatefulWidget {
  final String? name;   // optional initial values
  final String? email;  // optional initial values

  // You can keep this if other parts use it, but we won't rely on it here.
  final Future<void> Function() onDeleteAccount;
  final String? afterSaveRouteName;

  const PersonalInformationScreen({
    Key? key,
    this.name,
    this.email,
    required this.onDeleteAccount,
    this.afterSaveRouteName,
  }) : super(key: key);

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

  @override
  void initState() {
    super.initState();

    _firstNameCtrl = TextEditingController();
    _lastNameCtrl  = TextEditingController();

    _nameCtrl  = TextEditingController(text: widget.name ?? '');
    _emailCtrl = TextEditingController(text: widget.email ?? '');
    _newPwdCtrl.addListener(() => setState(() {}));

    _resolveInitialValues();
  }

  List<String> _splitName(String full) {
    final s = full.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (s.isEmpty) return ['', ''];
    final parts = s.split(' ');
    if (parts.length == 1) return [parts[0], ''];
    // first = first token, last = everything after
    return [parts.first, parts.sublist(1).join(' ')];
  }

  String _joinName(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    return (f.isEmpty || l.isEmpty) ? (f + ' ' + l).trim() : '$f $l';
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

    // _passwordCtrl was never used in the UI; if you plan to use it later, keep it.
    // For now we can safely dispose it once (or remove entirely if unused everywhere).
    _passwordCtrl.dispose();

    super.dispose();
  }


  String _firstNonEmpty(Iterable<String?> vals) {
    for (final v in vals) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  Future<void> _resolveInitialValues() async {
    // Prefer the more granular fields if available
    final localFirst = await SecureStorage.read('user_first_name');
    final localLast  = await SecureStorage.read('user_last_name');
    final localName  = await SecureStorage.read('user_name');
    final localEmail = await SecureStorage.read('user_email');

    // 1) Email
    final mergedEmail = _firstNonEmpty([_emailCtrl.text, widget.email, localEmail]);

    // 2) First/Last from storage; fallback to splitting provided name
    String first = (localFirst ?? '').trim();
    String last  = (localLast ?? '').trim();
    if (first.isEmpty && last.isEmpty) {
      final mergedName = _firstNonEmpty([_nameCtrl.text, widget.name, localName]);
      final parts = _splitName(mergedName);
      first = parts[0];
      last  = parts[1];
      if ((_nameCtrl.text).trim().isEmpty) {
        _nameCtrl.text = mergedName;
      }
    }

    if (mounted) {
      setState(() {
        _emailCtrl.text = mergedEmail;
        _firstNameCtrl.text = first;
        _lastNameCtrl.text  = last;

        // keep a full-name mirror for compatibility/UI hints
        final joined = _joinName(first, last);
        if (joined.isNotEmpty) _nameCtrl.text = joined;
      });
    }

    debugPrint('PI init name="${_nameCtrl.text}" email="${_emailCtrl.text}" '
        'first="${_firstNameCtrl.text}" last="${_lastNameCtrl.text}"');

    // If anything still missing, pull from API
    if (_emailCtrl.text.trim().isEmpty || _nameCtrl.text.trim().isEmpty) {
      await _fetchProfileFromApi();
    }
  }

  Future<void> _fetchProfileFromApi() async {
    try {
      setState(() => _loading = true);
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) return;

      final resp = await http.get(
        Uri.parse('${ApiService.baseUrl}/me'), // ✅ dynamic base
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);

        String pick(List<dynamic> paths) {
          for (final p in paths) {
            dynamic cur = data;
            final keys = (p as List).cast<String>();
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

        final fetchedFirst = pick([
          ['first_name'],
          ['data','first_name'],
          ['user','first_name'],
          ['data','user','first_name'],
        ]);

        final fetchedLast = pick([
          ['last_name'],
          ['data','last_name'],
          ['user','last_name'],
          ['data','user','last_name'],
        ]);

        String fetchedName = pick([
          ['name'],
          ['data','name'],
          ['user','name'],
          ['data','user','name'],
        ]);

        String fetchedEmail = pick([
          ['email'],
          ['data','email'],
          ['user','email'],
          ['data','user','email'],
        ]);

        // If only first/last provided, synthesize name
        if (fetchedName.isEmpty) {
          fetchedName = [fetchedFirst, fetchedLast].where((s) => s.isNotEmpty).join(' ').trim();
        }

        if (mounted) {
          setState(() {
            if (fetchedFirst.isNotEmpty) _firstNameCtrl.text = fetchedFirst;
            if (fetchedLast.isNotEmpty)  _lastNameCtrl.text  = fetchedLast;

            if (fetchedName.isNotEmpty)  _nameCtrl.text  = fetchedName;
            if (fetchedEmail.isNotEmpty) _emailCtrl.text = fetchedEmail;
          });
        }

        // Persist for next app launch / other screens
        if (fetchedFirst.isNotEmpty) await SecureStorage.write('user_first_name', fetchedFirst);
        if (fetchedLast.isNotEmpty)  await SecureStorage.write('user_last_name',  fetchedLast);
        if (fetchedName.isNotEmpty)  await SecureStorage.write('user_name',       fetchedName);
        if (fetchedEmail.isNotEmpty) await SecureStorage.write('user_email',      fetchedEmail);
      } else {
        debugPrint('/me failed: ${resp.statusCode} ${resp.body}');
      }
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

      // Build payload
      final first      = _firstNameCtrl.text.trim();
      final last       = _lastNameCtrl.text.trim();
      final joinedName = _joinName(first, last);

      final newPwd     = _newPwdCtrl.text.trim();
      final confirmPwd = _confirmPwdCtrl.text.trim();
      final currentPwd = _currentPwdCtrl.text.trim();

      final payload = <String, dynamic>{
        'first_name': first,
        'last_name':  last,
        'name':       joinedName,              // keep legacy compatibility
        'email':      _emailCtrl.text.trim(),  // email stays read-only in UI
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

      // ⬇️ use POST instead of PUT
      final resp = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      // ----- Success -----
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);

        // Save updated fields locally for UI
        await SecureStorage.write('user_first_name', first);
        await SecureStorage.write('user_last_name',  last);
        await SecureStorage.write('user_name',       joinedName);
        await SecureStorage.write('user_email',      _emailCtrl.text.trim());

        _nameCtrl.text = joinedName;

        // If backend rotated token (only when password changed), store it
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

        // ---- Navigate to "My Account" (or pop with result) ----
        final route = widget.afterSaveRouteName;
        if (route != null && route.isNotEmpty) {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(route);
        } else if (Navigator.of(context).canPop()) {
          if (!mounted) return;
          Navigator.of(context).pop(true); // parent can refresh on result == true
        } else {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/my-account');
        }
        return;
      }

      // ----- Auth expired / forbidden -----
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

      // ----- Validation errors -----
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

      // ----- Other errors -----
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
      final del  = Uri.parse('$base/delete'); // DELETE /api/delete
      final me   = Uri.parse('$base/me');     // sanity check

      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest',
      };

      final body = jsonEncode(<String, dynamic>{
        'token': token,
      });

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

  // navigate using the ROOT navigator on the next frame
  void _goLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginDemo()),
            (_) => false,
      );
    });
  }

  Future<void> _confirmAndDelete() async {
    // Show ONE confirmation dialog and wait for the user's choice
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

    if (!mounted) return; // context could be gone if user navigated away

    if (confirmed == true) {
      await _deleteAccountViaApi();
    }
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
                        validator: (v) => null, // optional
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailCtrl,
                  readOnly: true, // email is static
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

                  // New Password
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

                  // Confirm New Password
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
}
