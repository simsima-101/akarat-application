// lib/screen/personal_information.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../secure_storage.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../services/profile_cache.dart';
import '../services/auth_prefs.dart';
import 'login.dart';

// Add this import if not already there
import '../widgets/custom_alert_box.dart'; // Make sure this file exists

class PersonalInformationScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final Future<void> Function() onDeleteAccount;
  final String? afterSaveRouteName;

  const PersonalInformationScreen({
    super.key,
    this.name,
    this.email,
    required this.onDeleteAccount,
    this.afterSaveRouteName,
  });

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;

  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  bool _loading = false;
  bool _editMode = false;
  bool _isPasswordAuth = false;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController(text: widget.email ?? '');
    _loadUserData();
  }

  Future<void> _confirmAndDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C), // dark like your app
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Delete Account?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'You will lose all your saved alerts,\nsaved properties, etc.',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue, fontSize: 17),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await widget.onDeleteAccount();
    }
  }

  Future<void> _loadUserData() async {
    final session = Session();
    String first = session.firstName?.trim() ?? '';
    String last = session.lastName?.trim() ?? '';
    String email = session.userEmail?.trim() ?? widget.email ?? '';

    if (email.isEmpty) email = await SecureStorage.getUserEmail() ?? '';
    if (first.isEmpty && last.isEmpty) {
      final name = await SecureStorage.getUserName() ?? '';
      if (name.isNotEmpty) {
        final parts = name.split(RegExp(r'\s+'));
        first = parts.isNotEmpty ? parts.first : '';
        last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    if (email.isNotEmpty) {
      final override = await ProfileCache.load(email);
      if (override != null) {
        first = override.first.trim().isNotEmpty ? override.first.trim() : first;
        last = override.last.trim().isNotEmpty ? override.last.trim() : last;
      }
    }

    final method = await AuthPrefs.getLoginMethod();
    final isPasswordAuth = method != LoginMethod.google;

    if (!mounted) return;

    setState(() {
      _isPasswordAuth = isPasswordAuth;
      _firstNameCtrl.text = first;
      _lastNameCtrl.text = last;
      _emailCtrl.text = email;
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  String _joinName() {
    final f = _firstNameCtrl.text.trim();
    final l = _lastNameCtrl.text.trim();
    return [f, l].where((s) => s.isNotEmpty).join(' ');
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please login again.')),
        );
        _goToLogin();
        return;
      }

      final url = Uri.parse('${ApiService.baseUrl}/update');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'first_name': _firstNameCtrl.text.trim(),
          'last_name': _lastNameCtrl.text.trim(),
          'name': _joinName(),
          'email': _emailCtrl.text.trim(),
          if (_isPasswordAuth && _newPwdCtrl.text.trim().isNotEmpty) ...{
            'password': _newPwdCtrl.text,
            'password_confirmation': _confirmPwdCtrl.text,
            'current_password': _currentPwdCtrl.text,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newName = _joinName();
        final email = _emailCtrl.text.trim();

        await SecureStorage.setUserProfile(name: newName, email: email);
        await ProfileCache.save(email: email, firstName: _firstNameCtrl.text.trim(), lastName: _lastNameCtrl.text.trim());

        Session().updateProfile(
          userName: newName,
          userEmail: email,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
        );

        if (data['token'] != null) {
          final newToken = data['token'].toString().trim();
          await SecureStorage.setToken(newToken);
          Session().setAuth(
            token: newToken,
            userName: newName,
            userEmail: email,
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
          );
        }

        _showSuccess('Profile updated successfully');
        setState(() => _editMode = false);
        _clearPasswordFields();

        if (widget.afterSaveRouteName != null) {
          Navigator.pushReplacementNamed(context, widget.afterSaveRouteName!);
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      } else if (response.statusCode == 401) {
        await SecureStorage.signOutLocal();
        Session().clear();
        _goToLogin();
      } else {
        _showError(_parseError(response));
      }
    } catch (e) {
      _showError('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _parseError(http.Response resp) {
    try {
      final json = jsonDecode(resp.body);
      return json['message'] ?? (json['errors'] is Map ? (json['errors'] as Map).values.first[0] : 'Update failed');
    } catch (_) {}
    return 'Update failed (${resp.statusCode})';
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  void _clearPasswordFields() {
    _currentPwdCtrl.clear();
    _newPwdCtrl.clear();
    _confirmPwdCtrl.clear();
  }

  void _goToLogin() {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginDemo()),
          (route) => false,
    );
  }

  // Reusable UI components — same as My Account
  Widget _settingsContainer(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _settingsTile(
      String title,
      String iconPath,
      VoidCallback onTap, {
        TextStyle? titleStyle,
        Widget? trailing,
      }) {
    return ListTile(
      onTap: onTap,
      leading: iconPath.isNotEmpty ? Image.asset(iconPath, width: 28) : null,
      title: Text(title, style: titleStyle ?? const TextStyle(fontSize: 16)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  InputDecoration _inputDecoration(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7E7E7))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Text('Edit', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          if (_editMode) ...[
            TextButton(onPressed: _loading ? null : _saveProfile, child: const Text('Save', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
            TextButton(
              onPressed: _loading ? null : () {
                setState(() => _editMode = false);
                _clearPasswordFields();
                _loadUserData();
              },
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: AbsorbPointer(
        absorbing: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name Fields
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameCtrl,
                        readOnly: !_editMode,
                        decoration: _inputDecoration('First Name'),
                        validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _lastNameCtrl, readOnly: !_editMode, decoration: _inputDecoration('Last Name'))),
                  ],
                ),
                const SizedBox(height: 16),

                // Email — Fully disabled
                TextFormField(
                  controller: _emailCtrl,
                  readOnly: true,
                  enabled: false,
                  decoration: _inputDecoration('Email').copyWith(
                    helperText: 'Email cannot be changed',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  style: const TextStyle(color: Colors.grey),
                  enableInteractiveSelection: false,
                  showCursor: false,
                  focusNode: AlwaysDisabledFocusNode(),
                ),

                // Password Fields
                if (_editMode && _isPasswordAuth) ...[
                  const SizedBox(height: 24),
                  const Align(alignment: Alignment.centerLeft, child: Text('Change Password (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newPwdCtrl,
                    obscureText: _obscureNew,
                    decoration: _inputDecoration('New Password').copyWith(
                      suffixIcon: IconButton(icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureNew = !_obscureNew)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPwdCtrl,
                    obscureText: _obscureConfirm,
                    decoration: _inputDecoration('Confirm New Password').copyWith(
                      suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                    ),
                  ),
                  if (_newPwdCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _currentPwdCtrl,
                      obscureText: _obscureCurrent,
                      decoration: _inputDecoration('Current Password (Required)').copyWith(
                        suffixIcon: IconButton(icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent)),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 32),

                // DELETE ACCOUNT — NOW 100% MATCHES LOGOUT/LOGIN STYLE
                // DELETE ACCOUNT — 100% consistent with Logout/Login style
                // DELETE ACCOUNT — Centered & Compact (Beautiful!)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // exact match from your screenshot
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _confirmAndDelete(), // ← now uses clean native AlertDialog
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'Delete Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,

                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (_loading) ...[
                  const SizedBox(height: 20),
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