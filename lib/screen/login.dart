import 'dart:convert';

import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/forgot_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/profile_image_provider.dart';
import '../secure_storage.dart';
import '../services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/services/api_service.dart';
import 'package:Akarat/screen/home.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoginDemo();
  }
}

class LoginDemo extends StatefulWidget {
  final String? initialEmail;
  const LoginDemo({Key? key, this.initialEmail}) : super(key: key);

  @override
  State<LoginDemo> createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool showClose = true;
  bool obscurePassword = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _ensureCleanIfLoggedOut();
    if ((widget.initialEmail ?? '').isNotEmpty) {
      emailController.text = widget.initialEmail!.trim();
    }
  }

  Future<void> _ensureCleanIfLoggedOut() async {
    final ok = await SecureStorage.isLoggedIn(); // token + non-empty email
    if (!ok) {
      // Make sure nothing stale shows up on Login screen
      await SecureStorage.clearProfile();
    }
  }

  Future<bool> _isAccountActive(String token) async {
    try {
      final resp = await http.get(
        Uri.parse('${ApiService.baseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode != 200) return false;

      final raw = utf8.decode(resp.bodyBytes);
      final data = json.decode(raw);

      dynamic u = (data is Map)
          ? (data['user'] ?? data['data']?['user'] ?? data)
          : data;

      bool truthy(dynamic v) {
        if (v == null) return false;
        if (v is bool) return v;
        final s = v.toString().toLowerCase().trim();
        return s == '1' || s == 'true' || s == 'yes';
      }

      String asLower(dynamic v) => (v ?? '').toString().toLowerCase();

      final status = asLower(u?['status']);
      final isActive = truthy(u?['is_active']);
      final isDisabled = truthy(u?['disabled'] ?? u?['is_disabled']);
      final isDeleted = truthy(u?['deleted'] ?? u?['is_deleted']);
      final deletedAt = (u?['deleted_at'] ?? '').toString().trim();

      final active = (status.isEmpty || status == 'active') &&
          isDeleted == false &&
          isDisabled == false &&
          deletedAt.isEmpty &&
          (isActive == true ||
              status == 'active' ||
              (status.isEmpty && !isDeleted && !isDisabled));

      return active;
    } catch (_) {
      return false;
    }
  }

  Future<void> _fetchAndCacheMe(String token) async {
    try {
      final resp = await http.get(
        Uri.parse('${ApiService.baseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        final raw = utf8.decode(resp.bodyBytes);
        final data = json.decode(raw);

        String _path(dynamic o, List<String> p) {
          dynamic cur = o;
          for (final k in p) {
            if (cur is Map && cur.containsKey(k)) {
              cur = cur[k];
            } else {
              return '';
            }
          }
          return (cur is String ? cur : cur?.toString() ?? '').trim();
        }

        String firstNonEmpty(Iterable<String> vals) {
          for (final v in vals) {
            if (v.trim().isNotEmpty) return v.trim();
          }
          return '';
        }

        final first = firstNonEmpty([
          _path(data, ['first_name']),
          _path(data, ['data', 'first_name']),
          _path(data, ['user', 'first_name']),
          _path(data, ['data', 'user', 'first_name']),
        ]);

        final last = firstNonEmpty([
          _path(data, ['last_name']),
          _path(data, ['data', 'last_name']),
          _path(data, ['user', 'last_name']),
          _path(data, ['data', 'user', 'last_name']),
        ]);

        final full = firstNonEmpty([
          _path(data, ['name']),
          _path(data, ['data', 'name']),
          _path(data, ['user', 'name']),
          _path(data, ['data', 'user', 'name']),
          // fallback: join first + last
          [first, last].where((s) => s.isNotEmpty).join(' ')
        ]);

        String email = firstNonEmpty([
          _path(data, ['email']),
          _path(data, ['data', 'email']),
          _path(data, ['user', 'email']),
          _path(data, ['data', 'user', 'email']),
        ]);

        // last resort: scan for any "email" key
        if (email.isEmpty) {
          String findEmail(dynamic obj) {
            if (obj is Map) {
              for (final e in obj.entries) {
                if (e.key == 'email') {
                  final v = e.value?.toString() ?? '';
                  if (v.trim().isNotEmpty) return v.trim();
                }
                final f = findEmail(e.value);
                if (f.isNotEmpty) return f;
              }
            } else if (obj is List) {
              for (final it in obj) {
                final f = findEmail(it);
                if (f.isNotEmpty) return f;
              }
            }
            return '';
          }

          email = findEmail(data);
        }

        if (first.isNotEmpty) await SecureStorage.write('user_first_name', first);
        if (last.isNotEmpty) await SecureStorage.write('user_last_name', last);
        if (full.isNotEmpty) await SecureStorage.write('user_name', full);
        if (email.isNotEmpty) await SecureStorage.write('user_email', email);
      } else {
        debugPrint('GET /me failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      debugPrint('fetch /me error: $e');
    }
  }

  /// If backend doesn’t give first/last, derive/calc from a full name and cache.
  Future<void> _ensureFirstLastFromBestNameFallback({
    required String nameFromLogin,
  }) async {
    String? first = await SecureStorage.read('user_first_name');
    String? last = await SecureStorage.read('user_last_name');
    if ((first ?? '').trim().isEmpty && (last ?? '').trim().isEmpty) {
      // choose the best full name available
      final cachedFull =
          (await SecureStorage.read('user_name'))?.trim() ?? '';
      final full = cachedFull.isNotEmpty ? cachedFull : nameFromLogin;

      if (full.isNotEmpty) {
        final parts = full.replaceAll(RegExp(r'\s+'), ' ').trim().split(' ');
        final f = parts.isNotEmpty ? parts.first : '';
        final l = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        if (f.isNotEmpty) await SecureStorage.write('user_first_name', f);
        await SecureStorage.write('user_last_name', l);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showCustomMessage(String message, {Color bgColor = Colors.redAccent}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 80,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => entry.remove(),
                )
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlay.mounted) entry.remove();
    });
  }

  void _login() async {
    // Debounce & validate
    if (isLoading) return;
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final res = await http.post(
        Uri.parse('${ApiService.baseUrl}/login'),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );

      debugPrint('LOGIN status=${res.statusCode}');
      debugPrint('LOGIN body=${res.body}');

      Map<String, dynamic> body = {};
      try {
        body = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      // ----- Interpret status codes -----
      if (res.statusCode == 200) {
        final token = (body['token'] ?? '').toString().trim();
        if (token.isEmpty) {
          await SecureStorage.signOutLocal(); // clears token + profile
          setState(() => errorMessage = 'Login succeeded but token missing.');
          return;
        }

        // Save token first
        await SecureStorage.setToken(token);

        // Extract whatever user fields the /login response gives
        final dynamic userObj =
            body['user'] ?? body['data'] ?? const {};
        final nameFromApi = (userObj is Map && userObj['name'] != null
            ? userObj['name']
            : '')
            .toString()
            .trim();
        final emailFromApi = (userObj is Map && userObj['email'] != null
            ? userObj['email']
            : email)
            .toString()
            .trim();
        final imageFromApi = (userObj is Map && userObj['image'] != null
            ? userObj['image']
            : '')
            .toString()
            .trim();

        // Store profile (keeps UI stable)
        await SecureStorage.setUserProfile(
          name: nameFromApi,
          email: emailFromApi,
          image: imageFromApi.isEmpty ? null : imageFromApi,
        );

        // Hydrate from /me (now also writes first_name/last_name)
        try {
          await _fetchAndCacheMe(token);
        } catch (_) {}

        // If backend didn’t provide first/last, derive from best full name
        await _ensureFirstLastFromBestNameFallback(
          nameFromLogin: nameFromApi,
        );

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Home()),
              (_) => false,
        );
        return;
      }

      // ----- Soft-deleted account -----
      if (res.statusCode == 410) {
        await SecureStorage.signOutLocal();
        setState(() => errorMessage = 'This account has been deleted.');
        return;
      }

      // ----- Disabled / not verified -----
      if (res.statusCode == 403) {
        await SecureStorage.signOutLocal();

        final serverMsg =
        (body['message'] ?? '').toString().toLowerCase();
        final isUnverified = serverMsg.contains('verify') ||
            serverMsg.contains('inactive') ||
            serverMsg.contains('not verified');

        setState(() =>
        errorMessage = body['message']?.toString() ??
            'Your account is not allowed to log in.');

        if (isUnverified) {
          Navigator.of(context).pushNamed(
            '/verify-otp',
            arguments: {
              'mode': 'register',
              'email': emailController.text.trim().toLowerCase(),
              'resendAfter': 0,
            },
          );
        }
        return;
      }

      // ----- Invalid creds -----
      if (res.statusCode == 401) {
        await SecureStorage.signOutLocal();
        setState(() => errorMessage =
            body['message']?.toString() ?? 'Invalid email or password.');
        return;
      }

      // ----- Validation errors -----
      if (res.statusCode == 422) {
        await SecureStorage.signOutLocal();
        String msg = 'Validation error.';
        if (body['errors'] is Map && (body['errors'] as Map).isNotEmpty) {
          final first = (body['errors'] as Map).values.first;
          if (first is List && first.isNotEmpty) {
            msg = first.first.toString();
          }
        } else if (body['message'] != null) {
          msg = body['message'].toString();
        }
        setState(() => errorMessage = msg);
        return;
      }

      // ----- Other server errors -----
      await SecureStorage.signOutLocal();
      setState(() => errorMessage = body['message']?.toString() ??
          'Server error (${res.statusCode}). Try again.');
    } catch (e) {
      debugPrint('LOGIN error: $e');
      await SecureStorage.signOutLocal();
      if (!mounted) return;
      setState(() =>
      errorMessage = 'Network error. Check internet / BASE_URL.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Close button
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const Home()),
                                  (route) => false,
                            );
                          },
                          child: const Icon(Icons.close, size: 28, color: Colors.black),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 50,
                        child: Image.asset('assets/images/app_icon.png'),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 38,
                        child: Image.asset('assets/images/logo-text.png'),
                      ),
                    ),

                    Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        padding: const EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFF5F5F5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text("Welcome to Akarat!", style: TextStyle(fontSize: 20)),
                            const SizedBox(height: 15),

                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 50,
                              decoration: _boxDecoration(),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Email',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Email ID';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Invalid email address';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 6),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  height: 50,
                                  decoration: _boxDecoration(),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Center(
                                    child: TextFormField(
                                      controller: passwordController,
                                      obscureText: obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _login(),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Password',
                                        contentPadding:
                                        const EdgeInsets.only(top: 16),
                                        suffixIcon: IconButton(
                                          icon: Icon(obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                          onPressed: () => setState(() =>
                                          obscurePassword = !obscurePassword),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Enter password';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(right: 10, top: 4),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                ForgotPasswordScreen()),
                                      );
                                    },
                                    child: const Text(
                                      "Forgot password?",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width *
                                        0.8,
                                    50),
                                backgroundColor: const Color(0xFFF1F1F1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 1,
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Not registered yet? ',
                                    style:
                                    TextStyle(color: Color(0xFF424242))),
                                InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => RegisterScreen()),
                                  ),
                                  child: const Text('Create new account',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2)),
                            ],
                          ),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

BoxDecoration _boxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.shade300,
        offset: const Offset(0.3, 0.3),
        blurRadius: 2,
        spreadRadius: 0.2,
      ),
    ],
  );
}
