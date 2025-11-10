// lib/screen/login.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Screens
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/forgot_password.dart';

// Utils
import 'package:Akarat/services/api_service.dart';
import '../secure_storage.dart';

// 🔐 Firebase + Google Sign-In (v7)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginDemo();
  }
}

class LoginDemo extends StatefulWidget {
  final String? initialEmail;
  const LoginDemo({super.key, this.initialEmail});

  @override
  State<LoginDemo> createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obscurePassword = true;

  // ✅ v7 uses the singleton
  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn.instance;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initGoogle();
    _ensureCleanIfLoggedOut();
    if ((widget.initialEmail ?? '').isNotEmpty) {
      emailController.text = widget.initialEmail!.trim();
    }
  }

  Future<void> _initGoogle() async {
    // If needed on iOS/macOS: pass clientId/serverClientId here.
    await _googleSignIn.initialize(
      // clientId: 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com',
      // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    );

    // Optional: try lightweight restore if available
    try {
      await _googleSignIn.attemptLightweightAuthentication();
    } catch (_) {
      // normal on first run
    }
  }

  Future<void> _ensureCleanIfLoggedOut() async {
    final ok = await SecureStorage.isLoggedIn(); // token + non-empty email
    if (!ok) {
      await SecureStorage.clearProfile();
    }
  }

  // ============== Helpers for /me and profile cache ==============

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

        String path(dynamic o, List<String> p) {
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
          path(data, ['first_name']),
          path(data, ['data', 'first_name']),
          path(data, ['user', 'first_name']),
          path(data, ['data', 'user', 'first_name']),
        ]);

        final last = firstNonEmpty([
          path(data, ['last_name']),
          path(data, ['data', 'last_name']),
          path(data, ['user', 'last_name']),
          path(data, ['data', 'user', 'last_name']),
        ]);

        final full = firstNonEmpty([
          path(data, ['name']),
          path(data, ['data', 'name']),
          path(data, ['user', 'name']),
          path(data, ['data', 'user', 'name']),
          [first, last].where((s) => s.isNotEmpty).join(' ')
        ]);

        String email = firstNonEmpty([
          path(data, ['email']),
          path(data, ['data', 'email']),
          path(data, ['user', 'email']),
          path(data, ['data', 'user', 'email']),
        ]);

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

  Future<void> _ensureFirstLastFromBestNameFallback({
    required String nameFromLogin,
  }) async {
    String? first = await SecureStorage.read('user_first_name');
    String? last = await SecureStorage.read('user_last_name');
    if ((first ?? '').trim().isEmpty && (last ?? '').trim().isEmpty) {
      final cachedFull = (await SecureStorage.read('user_name'))?.trim() ?? '';
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

  // ============== Email/password login ==============

  bool _looksUnverified(int statusCode, Map<String, dynamic> body) {
    final msg = (body['message'] ?? '').toString().toLowerCase();
    return statusCode == 403 ||
        statusCode == 423 ||
        msg.contains('verify') ||
        msg.contains('inactive') ||
        msg.contains('not verified');
  }

  Future<void> _maybeBounceToVerifyIfNeeded({
    required int statusCode,
    required Map<String, dynamic> body,
    required String emailLower,
  }) async {
    final locallyVerifiedFor =
    (await SecureStorage.read('email_verified_for'))?.trim().toLowerCase();

    final recentlyVerified = (locallyVerifiedFor == emailLower);
    if (_looksUnverified(statusCode, body) && !recentlyVerified) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushNamed(
        '/verify-otp',
        arguments: {
          'mode': 'register',
          'email': emailLower,
          'resendAfter': 0,
        },
      );
    }
  }

  void _login() async {
    if (isLoading) return;
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final email = emailController.text.trim();
      final emailLower = email.toLowerCase();
      final password = passwordController.text.trim();

      final res = await http.post(
        Uri.parse('${ApiService.baseUrl}/login'),
        headers: {'Accept': 'application/json'},
        body: {'email': emailLower, 'password': password}, // Laravel form
      );

      final Map<String, dynamic> body = _tryDecode(res.body);

      // === Guard: if backend says "verify/inactive", only bounce if not just verified ===
      if (res.statusCode != 200) {
        await _maybeBounceToVerifyIfNeeded(
          statusCode: res.statusCode,
          body: body,
          emailLower: emailLower,
        );
      }

      if (res.statusCode == 200) {
        final token = _extractTokenFromAny(body);
        if (token == null || token.isEmpty) {
          await SecureStorage.signOutLocal();
          setState(() => errorMessage = 'Login succeeded but token missing.');
          return;
        }

        await SecureStorage.setToken(token);

        final dynamic userObj = body['user'] ?? body['data'] ?? const {};
        final nameFromApi =
        (userObj is Map && userObj['name'] != null ? userObj['name'] : '')
            .toString()
            .trim();
        final emailFromApi =
        (userObj is Map && userObj['email'] != null ? userObj['email'] : emailLower)
            .toString()
            .trim();
        final imageFromApi =
        (userObj is Map && userObj['image'] != null ? userObj['image'] : '')
            .toString()
            .trim();

        await SecureStorage.setUserProfile(
          name: nameFromApi,
          email: emailFromApi,
          image: imageFromApi.isEmpty ? null : imageFromApi,
        );

        try {
          await _fetchAndCacheMe(token);
        } catch (_) {}

        await _ensureFirstLastFromBestNameFallback(nameFromLogin: nameFromApi);

        // Clear the "just verified" marker after successful login
        final locallyVerifiedFor =
        (await SecureStorage.read('email_verified_for'))?.trim().toLowerCase();
        if (locallyVerifiedFor == emailLower) {
          await SecureStorage.delete('email_verified_for');
          await SecureStorage.delete('email_verified_at');
        }

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Home()),
              (_) => false,
        );
        return;
      }

      if (res.statusCode == 410) {
        await SecureStorage.signOutLocal();
        setState(() => errorMessage = 'This account has been deleted.');
        return;
      }

      if (res.statusCode == 401) {
        await SecureStorage.signOutLocal();
        setState(() =>
        errorMessage = body['message']?.toString() ?? 'Invalid email or password.');
        return;
      }

      if (res.statusCode == 422) {
        await SecureStorage.signOutLocal();
        String msg = 'Validation error.';
        if (body['errors'] is Map && (body['errors'] as Map).isNotEmpty) {
          final first = (body['errors'] as Map).values.first;
          if (first is List && first.isNotEmpty) msg = first.first.toString();
        } else if (body['message'] != null) {
          msg = body['message'].toString();
        }
        setState(() => errorMessage = msg);
        return;
      }

      await SecureStorage.signOutLocal();
      setState(() => errorMessage =
          body['message']?.toString() ?? 'Server error (${res.statusCode}). Try again.');
    } catch (e) {
      await SecureStorage.signOutLocal();
      if (!mounted) return;
      setState(() => errorMessage = 'Network error. Check internet / BASE_URL.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ============== GOOGLE SIGN-IN (v7 authenticate + robust backend exchange) ==============

  Future<void> _signInWithGoogle() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    StreamSubscription? sub;
    try {
      // 1) Wait for the sign-in event (v7 pattern)
      final completer = Completer<gsi.GoogleSignInAccount>();
      sub = _googleSignIn.authenticationEvents.listen((event) {
        if (event is gsi.GoogleSignInAuthenticationEventSignIn && !completer.isCompleted) {
          completer.complete(event.user);
        }
      });

      // 2) Start auth flow
      if (_googleSignIn.supportsAuthenticate()) {
        await _googleSignIn.authenticate(); // add scopeHint if you need more scopes
      } else {
        throw Exception('This platform does not support authenticate().');
      }

      // 3) Get account and Google idToken (may be null depending on flow)
      final gsi.GoogleSignInAccount account = await completer.future;
      await sub.cancel();

      final gsi.GoogleSignInAuthentication googleAuth = await account.authentication;
      final String? googleIdTokenMaybe = googleAuth.idToken; // may be null on some iOS flows

      // 4) Sign in to Firebase using whichever token is available
      if (googleIdTokenMaybe != null && googleIdTokenMaybe.isNotEmpty) {
        final cred = GoogleAuthProvider.credential(idToken: googleIdTokenMaybe);
        await FirebaseAuth.instance.signInWithCredential(cred);
      } else {
        // Proceed; we'll fetch Firebase ID token after auth restore
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Firebase user is null after sign-in');

      // ✅ Get a DEFINITIVELY non-null Firebase ID token
      final String? tokenMaybe = await user.getIdToken(true);
      if (tokenMaybe == null || tokenMaybe.isEmpty) {
        throw Exception('Failed to get Firebase ID token.');
      }
      final String firebaseIdToken = tokenMaybe;

      final displayName = (user.displayName ?? '').trim();
      final email = (user.email ?? '').trim();
      final photoUrl = (user.photoURL ?? '').trim();

      // ======== Backend exchange using ApiService ========
      String? backendToken;
      try {
        final data = await ApiService.loginWithGoogleIdToken(firebaseIdToken);
        backendToken = _extractTokenFromAny(data);
      } catch (_) {
        backendToken = await ApiService.tryLoginGoogle(firebaseIdToken);
      }

      // Ensure subsequent calls use the same host we just hit (QA vs PROD)
      ApiService.setRuntimeBase(ApiService.baseUrl);

      if (backendToken == null || backendToken.isEmpty) {
        throw Exception('This account has been deleted. Please contact support or use a different Google account.');
      }

      // Cache session + profile
      await SecureStorage.setToken(backendToken);
      await SecureStorage.setUserProfile(
        name: displayName,
        email: email,
        image: photoUrl.isEmpty ? null : photoUrl,
      );
      try {
        await _fetchAndCacheMe(backendToken);
      } catch (_) {}
      await _ensureFirstLastFromBestNameFallback(nameFromLogin: displayName);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Home()),
            (_) => false,
      );
    } catch (e) {
      await SecureStorage.signOutLocal();
      if (mounted) {
        setState(() {
          errorMessage = 'Google sign-in failed. ${e.toString()}';
        });
      }
    } finally {
      await sub?.cancel();
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ============== Small helpers ==============

  Map<String, dynamic> _tryDecode(String s) {
    try {
      final m = jsonDecode(s);
      if (m is Map<String, dynamic>) return m;
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Supports these shapes:
  /// {token:".."}, {access_token:".."}, {data:{token:".."}}, {data:{access_token:".."}}
  String? _extractTokenFromAny(Map<String, dynamic> m) {
    final t1 = (m['token'] ?? '').toString().trim();
    if (t1.isNotEmpty) return t1;

    final t2 = (m['access_token'] ?? '').toString().trim();
    if (t2.isNotEmpty) return t2;

    final d = m['data'];
    if (d is Map<String, dynamic>) {
      final t3 = (d['token'] ?? '').toString().trim();
      if (t3.isNotEmpty) return t3;
      final t4 = (d['access_token'] ?? '').toString().trim();
      if (t4.isNotEmpty) return t4;
    }
    return null;
  }

  String _randomPassword({int length = 24}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^*()-_=+[]{}';
    final rnd = Random.secure();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  // ============== UI ==============

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Close
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
                        child: Image.asset('assets/images/app_icon.png',
                            errorBuilder: (_, __, ___) => const SizedBox()),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 38,
                        child: Image.asset('assets/images/logo-text.png',
                            errorBuilder: (_, __, ___) => const SizedBox()),
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

                            // EMAIL
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

                            // PASSWORD
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
                                        contentPadding: const EdgeInsets.only(top: 16),
                                        suffixIcon: IconButton(
                                          icon: Icon(obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                          onPressed: () => setState(
                                                  () => obscurePassword = !obscurePassword),
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
                                  padding: const EdgeInsets.only(right: 10, top: 4),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ForgotPasswordScreen()),
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

                            // Email Login button
                            isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
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

                            const SizedBox(height: 14),

                            // ---- Divider OR ----
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    height: 1,
                                    color: Colors.black12,
                                  ),
                                ),
                                const Text('  or  ', style: TextStyle(color: Colors.black54)),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    height: 1,
                                    color: Colors.black12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Google Sign-In button
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _signInWithGoogle,
                                icon: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Image.asset(
                                    'assets/images/google.png',
                                    fit: BoxFit.contain,
                                    // Prevent crashes if asset is missing
                                    errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.g_mobiledata_outlined, size: 20),
                                  ),
                                ),
                                label: const Text(
                                  'Continue with Google',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.black12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  foregroundColor: Colors.black87,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Register
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Not registered yet? ',
                                    style: TextStyle(color: Color(0xFF424242))),
                                InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                                  ),
                                  child: const Text('Create new account',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                          padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
