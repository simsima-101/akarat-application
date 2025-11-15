// lib/screen/personal_information.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../secure_storage.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../services/profile_cache.dart';
import '../services/auth_prefs.dart'; // 🔹 NEW: to read LoginMethod
import 'login.dart';

class PersonalInformationScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? firstName;
  final String? lastName;

  /// 🔹 This is injected from My_Account:
  /// PersonalInformationScreen(onDeleteAccount: deleteAccount, ...)
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
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;

  final TextEditingController _currentPwdCtrl = TextEditingController();
  final TextEditingController _newPwdCtrl = TextEditingController();
  final TextEditingController _confirmPwdCtrl = TextEditingController();

  bool _loading = false;
  bool _editMode = false;

  // visibility toggles
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _obscureCurrent = true;

  // only show password area for email/password auth
  bool _isPasswordAuth = false;

  @override
  void initState() {
    super.initState();

    _firstNameCtrl = TextEditingController(text: widget.firstName ?? '');
    _lastNameCtrl  = TextEditingController(text: widget.lastName  ?? '');
    _nameCtrl      = TextEditingController(text: widget.name      ?? '');
    _emailCtrl     = TextEditingController(text: widget.email     ?? '');

    _newPwdCtrl.addListener(() => setState(() {}));

    _hydrateFromLocal(); // loads names + auth provider
  }

  Future<void> _hydrateFromLocal() async {
    final s = Session();

    final fullFromSession  = (s.userName  ?? '').trim();
    final emailFromSession = (s.userEmail ?? '').trim();

    String first = (s.firstName ?? '').trim();
    String last  = (s.lastName  ?? '').trim();

    // Derive first/last from full name if needed
    if ((first.isEmpty && last.isEmpty) && fullFromSession.isNotEmpty) {
      final parts = fullFromSession
          .split(RegExp(r'\s+'))
          .where((p) => p.isNotEmpty)
          .toList();
      first = parts.isNotEmpty ? parts.first : '';
      last  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    // Prefer client override if present
    final override = await ProfileCache.load(
      emailFromSession.isNotEmpty ? emailFromSession : _emailCtrl.text.trim(),
    );
    if (override != null) {
      final oFirst = override.first.trim();
      final oLast  = override.last.trim();
      if (oFirst.isNotEmpty || oLast.isNotEmpty) {
        first = oFirst.isNotEmpty ? oFirst : first;
        last  = oLast.isNotEmpty  ? oLast  : last;
      }
    }

    // 🔹 Read login method via AuthPrefs instead of SecureStorage.read()
    final method = await AuthPrefs.getLoginMethod();
    // FINAL RULE:
    // - Hide password section ONLY when method == LoginMethod.google
    // - For everything else (null, password, legacy) → treat as password auth
    bool isPasswordAuth = true;
    if (method == LoginMethod.google) {
      isPasswordAuth = false;
    }

    if (!mounted) return;
    setState(() {
      _isPasswordAuth = isPasswordAuth;
      _firstNameCtrl.text = first;
      _lastNameCtrl.text  = last;
      _emailCtrl.text     =
      emailFromSession.isNotEmpty ? emailFromSession : _emailCtrl.text;
      if (_nameCtrl.text.trim().isEmpty) {
        final joined = [first, last].where((s) => s.isNotEmpty).join(' ');
        _nameCtrl.text = joined.isNotEmpty ? joined : fullFromSession;
      }
    });

    debugPrint(
      'PI hydrate → loginMethod=${method?.name ?? '(none)'} '
          'isPasswordAuth=$_isPasswordAuth '
          'first="$first" last="$last" email="${_emailCtrl.text}" name="${_nameCtrl.text}"',
    );
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

    super.dispose();
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

      final base = ApiService.baseUrl; // e.g. https://qa.akarat.com/api
      final url  = Uri.parse('$base/update'); // adjust if your endpoint differs

      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final first = _firstNameCtrl.text.trim();
      final last  = _lastNameCtrl.text.trim();
      final joinedName = _joinName(first, last);

      final newPwd     = _newPwdCtrl.text.trim();
      final confirmPwd = _confirmPwdCtrl.text.trim();
      final currentPwd = _currentPwdCtrl.text.trim();

      final payload = <String, dynamic>{
        'first_name': first,
        'last_name' : last,
        'name'      : joinedName,
        'email'     : _emailCtrl.text.trim(),
      };

      // Only include password fields if this is a password-auth user
      if (_isPasswordAuth && newPwd.isNotEmpty) {
        if (newPwd.length < 8) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('New password must be at least 8 characters')),
            );
          }
          return;
        }
        if (newPwd != confirmPwd) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('New password and confirmation do not match')),
            );
          }
          return;
        }
        if (currentPwd.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                  Text('Enter your current password to change it')),
            );
          }
          return;
        }

        payload['password']              = newPwd;
        payload['password_confirmation'] = confirmPwd;
        payload['current_password']      = currentPwd;
      }

      final resp =
      await http.post(url, headers: headers, body: jsonEncode(payload));

      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);

        // Persist profile (legacy helper – now a NO-OP, but kept for compatibility)
        await SecureStorage.setUserProfile(
          name: joinedName,
          email: _emailCtrl.text.trim(),
        );

        // Update session
        Session().updateProfile(
          userName: joinedName,
          userEmail: _emailCtrl.text.trim(),
          firstName: first,
          lastName: last,
        );

        // Save local override (prevents Google-display-name from overriding later)
        final email = _emailCtrl.text.trim();
        if (email.isNotEmpty) {
          await ProfileCache.save(
            email: email,
            firstName: first,
            lastName:  last,
          );
        }

        // Optional token rotation
        final newToken = (body['token'] ?? '').toString().trim();
        if (newToken.isNotEmpty) {
          await SecureStorage.setToken(newToken);
          Session().setAuth(
            token: newToken,
            userName: joinedName,
            userEmail: _emailCtrl.text.trim(),
            firstName: first,
            lastName: last,
          );
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
            SnackBar(
              content: Text(
                  'Session expired (${resp.statusCode}). Please log in again.'),
            ),
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
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
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
        final s =
        (m['message'] ?? m['error'] ?? '').toString().trim();
        if (s.isNotEmpty) msg = s;
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
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

  /// 🔹 Still used for profile-update 401/403 case
  Future<void> _signOutLocalOnly() async {
    await SecureStorage.signOutLocal();
    await SecureStorage.clearProfile();
  }

  /// 🔹 Still used for profile-update 401/403 case
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
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _editMode && !_loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Information',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          if (!_editMode)
            TextButton(
              onPressed:
              _loading ? null : () => setState(() => _editMode = true),
              child: const Text(
                'Edit',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          if (_editMode) ...[
            TextButton(
              onPressed: _loading ? null : _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
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
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black87),
              ),
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
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'First name is required'
                            : null,
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
                  decoration: _dec('Email').copyWith(
                    helperText: 'Email cannot be changed',
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Email is required';
                    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(value);
                    return emailOk ? null : 'Enter a valid email';
                  },
                ),
                const SizedBox(height: 12),

                // 🔹 Show password controls ONLY if this is a password-auth user
                if (_editMode && _isPasswordAuth) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Change password (optional)',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _newPwdCtrl,
                    readOnly: !_editMode,
                    obscureText: _obscureNew,
                    decoration: _dec('New password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      helperText:
                      'Leave blank to keep your current password',
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _confirmPwdCtrl,
                    readOnly: !_editMode,
                    obscureText: _obscureConfirm,
                    decoration: _dec('Confirm new password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (_editMode &&
                          _newPwdCtrl.text.trim().isNotEmpty) {
                        if ((v ?? '').trim().isEmpty) {
                          return 'Please confirm the new password';
                        }
                        if (v!.trim() != _newPwdCtrl.text.trim()) {
                          return 'Passwords do not match';
                        }
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
                      decoration: _dec(
                        'Current password (required to change)',
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCurrent
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                                  () => _obscureCurrent = !_obscureCurrent),
                        ),
                      ),
                      validator: (v) {
                        if (_newPwdCtrl.text.trim().isNotEmpty &&
                            (v ?? '').trim().isEmpty) {
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  /// 🔹 Only confirmation is handled here; actual delete logic
  /// is delegated to `widget.onDeleteAccount` (from My_Account.deleteAccount).
  Future<void> _confirmAndDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content:
        const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed == true) {
      // 🔹 Use EXACT SAME delete logic as My_Account
      await widget.onDeleteAccount();
    }
  }
}
