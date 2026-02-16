  // lib/screen/login.dart
  import 'dart:async';
  import 'dart:convert';
  
  import 'package:Akarat/src/screen/register_screen.dart';
  // Firebase + Google Sign-In (v7)
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:google_sign_in/google_sign_in.dart' as gsi;
  import 'package:http/http.dart' as http;
  
  import '../../l10n/app_localizations.dart';
import '../core/services/api_service.dart';
  import '../core/utils/secure_storage.dart';
  import '../core/utils/session_manager.dart';
  import 'forgot_password.dart';
  import 'home.dart';
  
  const String _IOS_CLIENT_ID =
      '370139668712-ema9n0o9vhq25nbqu771v5c71ehivolf.apps.googleusercontent.com';
  
  class Login extends StatelessWidget {
    const Login({super.key});
    @override
    Widget build(BuildContext context) => const LoginDemo();
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
  
    final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn.instance;
    String? errorMessage;
  
    @override
    void initState() {
      super.initState();
  
      // REMOVED: _ensureFreshGuestState() — This was destroying login persistence!
      // We now ONLY show Login screen when user is truly logged out (handled by SplashScreen)
  
      _initGoogle();
  
      if ((widget.initialEmail ?? '').isNotEmpty) {
        emailController.text = widget.initialEmail!.trim();
      }
    }
  
    Future<void> _initGoogle() async {
      try {
        await _googleSignIn.initialize(clientId: _IOS_CLIENT_ID);
        // await _googleSignIn.attemptLightweightAuthentication();
      } catch (_) {
        // Ignore — not critical
      }
    }
  
    @override
    void dispose() {
      emailController.dispose();
      passwordController.dispose();
      super.dispose();
    }
  
    // ----------------- Common auth hydration -----------------
    Future<void> _hydrateAfterAuth({
      required String token,
      required Map<String, dynamic> loginBody,
    }) async {
      var id = extractIdentity(loginBody);
  
      if (id.first.isEmpty && id.last.isEmpty) {
        final fetched = await tryFetchMe(token);
        if (fetched != null) id = fetched;
      }
  
      if (id.first.isEmpty && id.last.isEmpty) {
        final local =
            (id.email.isNotEmpty ? id.email : emailController.text.trim())
                .split('@')
                .first;
        id = (first: local, last: '', name: local, email: id.email);
      }
  
      // Persist to SecureStorage + in-memory Session
      await SecureStorage.setToken(token);
      await SecureStorage.saveUserName(
          id.name.isNotEmpty ? id.name : '${id.first} ${id.last}'.trim());
      await SecureStorage.saveUserEmail(id.email);
      await SecureStorage.saveFirstName(id.first);
      await SecureStorage.saveLastName(id.last);
  
      await SessionManager().setAuth(
        token: token,
        userName: id.name.isNotEmpty ? id.name : '${id.first} ${id.last}'.trim(),
        userEmail: id.email,
        firstName: id.first,
        lastName: id.last,
      );
    }
  
    // --- compatibility wrapper so existing call sites can use extractIdentity(...) ---
    static ({String first, String last, String name, String email})
        extractIdentity(Map<String, dynamic> src) {
      return extractIdentityFromAny(src);
    }
  
    /// Try `/me` to fetch canonical identity if the login payload is thin.
    static Future<({String first, String last, String name, String email})?>
        tryFetchMe(String token) async {
      try {
        // Try multiple possible endpoints (in order)
        final endpoints = ['/me', '/user', '/profile', '/account'];
  
        for (final endpoint in endpoints) {
          try {
            final resp = await _getAuth(endpoint, token);
            if (resp.statusCode != 200) continue;
  
            if (!_looksJson(resp)) continue;
  
            final data = _decodeMap(resp.body);
  
            // Debug: Print raw response so you can see what's returned
            if (kDebugMode) {
              print('[/api$endpoint] RESPONSE: ${resp.body}');
            }
  
            final id = extractIdentityFromAny(data);
  
            // If we got valid first + last name → use it
            if (id.first.isNotEmpty || id.last.isNotEmpty) {
              final fullName = '${id.first} ${id.last}'.trim();
              return (
                first: id.first,
                last: id.last,
                name: fullName.isNotEmpty ? fullName : id.name,
                email: id.email
              );
            }
  
            // Fallback: if only 'name' exists and it's not empty
            if (id.name.isNotEmpty) {
              return id;
            }
          } catch (e) {
            if (kDebugMode) print('Failed on $endpoint: $e');
            continue;
          }
        }
  
        return null;
      } catch (e) {
        if (kDebugMode) print('tryFetchMe all failed: $e');
        return null;
      }
    }
  
    static ({String first, String last, String name, String email})
        extractIdentityFromAny(Map<String, dynamic> src) {
      String pickStr(List<List<String>> paths) {
        for (final p in paths) {
          dynamic cur = src;
          for (final k in p) {
            if (cur is Map && cur.containsKey(k)) {
              cur = cur[k];
            } else {
              cur = null;
              break;
            }
          }
          if (cur is String && cur.trim().isNotEmpty) {
            return cur.trim();
          }
        }
        return '';
      }
  
      final first = pickStr([
        ['first_name'],
        ['user', 'first_name'],
        ['data', 'first_name'],
        ['data', 'user', 'first_name'],
      ]);
  
      final last = pickStr([
        ['last_name'],
        ['user', 'last_name'],
        ['data', 'last_name'],
        ['data', 'user', 'last_name'],
      ]);
  
      String name = pickStr([
        ['name'],
        ['user', 'name'],
        ['data', 'name'],
        ['data', 'user', 'name'],
      ]);
  
      String email = pickStr([
        ['email'],
        ['user', 'email'],
        ['data', 'email'],
        ['data', 'user', 'email'],
      ]);
  
      // Synthesize missing pieces from name when possible
      String f = first, l = last;
      if ((f.isEmpty || l.isEmpty) && name.isNotEmpty) {
        final parts = name.split(RegExp(r'\s+'));
        f = f.isEmpty ? (parts.isNotEmpty ? parts.first : '') : f;
        l = l.isEmpty ? (parts.length > 1 ? parts.sublist(1).join(' ') : '') : l;
      }
      if (name.isEmpty) {
        name = [f, l].where((s) => s.isNotEmpty).join(' ').trim();
      }
  
      return (first: f, last: l, name: name, email: email);
    }
  
    static bool _looksJson(http.Response r) {
      final ct = (r.headers['content-type'] ?? '').toLowerCase();
      return ct.contains('application/json');
    }
  
    static Future<http.Response> _getAuth(
      String endpoint,
      String token, [
      Map<String, String>? qs,
    ]) async {
      if (token.isEmpty) {
        throw Exception(
            'No auth token present for ${ApiService.baseUrl}$endpoint');
      }
      final url = ApiService.buildUri(endpoint, query: qs);
      // final resp = await http
      //     .get(url, headers: _authHeaders(token))
      //     .timeout(Duration(seconds: 25));
  
      final resp = await ApiService.get(
        endpoint,
        query: qs,
        headers: _authHeaders(token),
      ).timeout(const Duration(seconds: 25));
  
      if (kDebugMode) {
        if (_looksJson(resp)) {
          print('[GET*]  $url -> ${resp.statusCode}');
        } else {
          final head = resp.body
              .substring(0, resp.body.length > 120 ? 120 : resp.body.length);
          print('[GET*]  $url -> ${resp.statusCode} (Non-JSON) head: $head');
        }
      }
      if (resp.statusCode == 401) {
        throw Exception('Unauthorized (401) on $url');
      }
      return resp;
    }
  
    static Map<String, String> _authHeaders(String token) {
      final cleanToken = token.trim();
      debugPrint('SENDING AUTH HEADER → Bearer $cleanToken');
  
      if (cleanToken.isEmpty) {
        throw Exception('Empty token in _authHeaders');
      }
  
      return {
        ..._jsonHeaders,
        'Authorization': 'Bearer $cleanToken',
        'Origin': 'https://akarat.com', // ← Add this (helps Sanctum)
        'Referer': 'https://akarat.com', // ← Add this (helps Sanctum)
      };
    }
  
    // ----------------- Email/password login -----------------
    Future<void> _login() async {

      final l10n = AppLocalizations.of(context)!;

      if (isLoading) return;
      if (!formKey.currentState!.validate()) return;
  
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
  
      try {
        final email = emailController.text.trim().toLowerCase();
        final password = passwordController.text.trim();
  
        final resp = await login(email: email, password: password);
        final status = resp['__status'] as int? ?? 500;
  
        if (status == 200) {
          final token = extractToken(resp);
          if (token == null || token.isEmpty) {
            setState(() => errorMessage = l10n.loginSucceededButTokenMissing);
            return;
          }
  
          await _hydrateAfterAuth(token: token, loginBody: resp);
  
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const Home()),
            (_) => false,
          );
          return;
        }
  
        // Handle errors
        String msg = l10n.serverErrorTryAgain;
        if (status == 401) {
          msg = resp['message']?.toString() ?? l10n.invalidEmailOrPassword;
        } else if (status == 422) {
          final body =
              resp['__raw'] is Map ? resp['__raw'] as Map<String, dynamic> : {};
          final errors = body['errors'] as Map?;
          if (errors != null && errors.isNotEmpty) {
            msg = (errors.values.first is List &&
                    (errors.values.first as List).isNotEmpty)
                ? (errors.values.first as List).first.toString()
                : l10n.validationError;
          } else {
            msg = body['message']?.toString() ?? msg;
          }
        } else {
          msg = resp['message']?.toString() ?? 'Server error ($status).';
        }
  
        setState(() => errorMessage = msg);
      } catch (_) {
        setState(() => errorMessage = l10n.networkErrorCheckConnection);
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  
    static Future<Map<String, dynamic>> login({
      required String email,
      required String password,
    }) async {
      final res = await ApiService.post(
        '/login',
        body: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      ).timeout(const Duration(seconds: 25));
  
      // Optional: throw early on non-200
      if (res.statusCode != 200) {
        try {
          final error = jsonDecode(res.body);
          throw Exception(error['message'] ?? 'Login failed (${res.statusCode})');
        } catch (_) {
          throw Exception('Login failed (${res.statusCode})');
        }
      }
  
      return _decorateStatus(res);
    }
  
    static Map<String, dynamic> _decorateStatus(http.Response r) {
      Map<String, dynamic> m = {};
      try {
        final v = jsonDecode(r.body);
        if (v is Map<String, dynamic>) m = v;
      } catch (_) {}
      m['__status'] = r.statusCode;
      return m;
    }
  
    // ----------------- Google Sign-In -----------------
    Future<void> _signInWithGoogle() async {

      final l10n = AppLocalizations.of(context)!;
      if (isLoading) return;
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
  
      StreamSubscription? sub;
      try {
        final completer = Completer<gsi.GoogleSignInAccount>();
        sub = _googleSignIn.authenticationEvents.listen((event) {
          if (event is gsi.GoogleSignInAuthenticationEventSignIn &&
              !completer.isCompleted) {
            completer.complete(event.user);
          }
        });
  
        if (!_googleSignIn.supportsAuthenticate()) {
          throw Exception(l10n.googleSignInNotSupported);
        }
  
        await _googleSignIn.authenticate();
        final account = await completer.future;
        await sub?.cancel();
  
        final gAuth = await account.authentication;
        final googleIdToken = gAuth.idToken;
        if (googleIdToken == null) throw Exception(l10n.googleIdTokenMissing);
  
        final cred = GoogleAuthProvider.credential(idToken: googleIdToken);
        await FirebaseAuth.instance.signInWithCredential(cred);
  
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception(l10n.firebaseSignInFailed);
  
        final firebaseIdToken = await user.getIdToken(true);
        if (firebaseIdToken == null)
          throw Exception(l10n.failedToGetFirebaseToken);
  
        final data = await loginWithGoogleIdToken(firebaseIdToken);
        final token = extractToken(data);
        if (token == null || token.isEmpty) {
          throw Exception(l10n.accountInactiveOrDeleted);
        }
  
        await _hydrateAfterAuth(token: token, loginBody: data);
  
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Home()),
          (_) => false,
        );
      } catch (e) {
        // setState(() {
        //   errorMessage =
        //       'Login failed. This account may be inactive or deleted.\nPlease try another method.';
        // });
      } finally {
        await sub?.cancel();
        if (mounted) setState(() => isLoading = false);
      }
    }
  
    static String? extractToken(Map<String, dynamic> m) {
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
  
    static Future<Map<String, dynamic>> loginWithGoogleIdToken(
        String firebaseIdToken) async {
      final resp =
          await _post('/login-google', {"google_id_token": firebaseIdToken});
  
      if (_looksHtml(resp)) {
        throw Exception(
          'Non-JSON from /login-google (HTML). Check API_BASE_URL (QA vs PROD) and route.',
        );
      }
  
      final data = _decodeMap(resp.body);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return data;
      }
      throw Exception(
        data['message'] ?? 'Google login failed (${resp.statusCode})',
      );
    }
  
    static Future<http.Response> _post(
      String endpoint,
      Map<String, dynamic> body,
    ) async {
      final url = ApiService.buildUri(endpoint);
      // final resp = await http
      //     .post(url, headers: _jsonHeaders, body: jsonEncode(body))
      //     .timeout(Duration(seconds: 25));
      final resp = await ApiService.post(
        endpoint,
        body: body, // ← pass Dart map directly — ApiService does jsonEncode
      ).timeout(const Duration(seconds: 25));
  
      if (kDebugMode) {
        print('[POST]  $url -> ${resp.statusCode} ${resp.body}');
      }
      return resp;
    }
  
    static const Map<String, String> _jsonHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Requested-With': 'XMLHttpRequest',
    };
  
    static bool _looksHtml(http.Response r) {
      final ct = (r.headers['content-type'] ?? '').toLowerCase();
      if (ct.contains('text/html')) return true;
      final body = r.body.trimLeft();
      return body.startsWith('<!doctype') || body.startsWith('<html');
    }
  
    static Map<String, dynamic> _decodeMap(String body) {
      try {
        final decoded = jsonDecode(body);
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      } catch (_) {
        return <String, dynamic>{};
      }
    }
  
    // ----------------- UI -----------------
    @override
    Widget build(BuildContext context) {

        final l10n = AppLocalizations.of(context)!;

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
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const Home()),
                              (_) => false,
                            ),
                            child: const Icon(Icons.close,
                                size: 28, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      Center(
                        child: Image.asset('assets/images/app_icon.png',
                            width: 150, height: 50),
                      ),
                      Center(
                        child: Image.asset('assets/images/logo-text.png',
                            width: 150, height: 38),
                      ),
                      Form(
                        key: formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 30),
                          padding: const EdgeInsets.only(top: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFF5F5F5),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1)),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(l10n.welcomeToAkarat,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 15),
  
                              // Email Field
                              _buildTextField(emailController, l10n.email,
                                  TextInputType.emailAddress),
  
                              const SizedBox(height: 6),
  
                              // Password Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Correct call: positional optional parameters (no named syntax!)
                                  _buildTextField(
                                    passwordController,
                                   l10n.email,
                                    TextInputType.visiblePassword,
                                    obscurePassword, // obscureText
                                    (_) => _login(), // onFieldSubmitted
                                    IconButton(
                                      // suffixIcon
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () => setState(() =>
                                          obscurePassword = !obscurePassword),
                                    ),
                                  ),
  
                                  // Forgot password link
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(right: 10, top: 4),
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const ForgotPasswordScreen()),
                                      ),
                                      child: Text(
                                        l10n.forgotPassword,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
  
                              // Login Button
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
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      child: Text(l10n.login,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                    ),
  
                              const SizedBox(height: 14),
                              _buildDivider(),
                              const SizedBox(height: 14),
  
                              // Google Button
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: _signInWithGoogle,
                                  icon: Image.asset('assets/images/google.png',
                                      width: 20, height: 20),
                                  label: Text(l10n.continueWithGoogle,
                                      style:
                                          const TextStyle(fontWeight: FontWeight.w600)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.black12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
  
                              const SizedBox(height: 15),
  
                              // Register Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(l10n.notRegisteredYet,
                                      style: const TextStyle(color: Color(0xFF424242))),
                                  InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const RegisterScreen())),
                                    child: Text(l10n.createNewAccount,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
  
                      // Error Message
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(errorMessage!,
                                style: const TextStyle(color: Colors.white)),
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
  
    // ---------- Helper Method (Correctly Defined) ----------
    Widget _buildTextField(
        TextEditingController controller,
        String fieldKey,  // 'email' or 'password' — semantic key, not the displayed text
        [
          TextInputType? keyboardType,
          bool obscureText = false,
          void Function(String)? onFieldSubmitted,
          Widget? suffixIcon,
        ]) {
      final l10n = AppLocalizations.of(context)!;

      // Map fieldKey → localized label
      late String label;
      if (fieldKey == 'email') {
        label = l10n.email;
      } else if (fieldKey == 'password') {
        label = l10n.password;
      } else {
        // Fallback — in real app you should handle unknown keys better
        label = fieldKey;
      }

      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: _boxDecoration(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: keyboardType == TextInputType.emailAddress
              ? TextInputAction.next
              : TextInputAction.done,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label,                    // ← localized hint
            suffixIcon: suffixIcon,
          ),
          validator: (value) {
            // 1. Required check
            if (value == null || value.trim().isEmpty) {
              return l10n.pleaseEnterField(label);
            }

            // 2. Email format check (only for email field)
            if (fieldKey == 'email') {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return l10n.invalidEmailAddress;
              }
            }

            return null;
          },
        ),
      );
    }
  
    Widget _buildDivider() {

      final l10n = AppLocalizations.of(context)!;


      return Row(
        children: [
          Expanded(
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 1,
                  color: Colors.black12)),
          Text(l10n.or, style: const TextStyle(color: Colors.black54)),
          Expanded(
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 1,
                  color: Colors.black12)),
        ],
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
            spreadRadius: 0.2),
      ],
    );
  }
