// lib/screen/login.dart
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/forgot_password.dart';

import 'package:Akarat/services/api_service.dart';
import '../secure_storage.dart';
import '../services/profile_cache.dart';
import '../services/session.dart';
import '../services/auth_prefs.dart'; // 🔹 NEW: track login method (password / google)

// Firebase + Google Sign-In (v7)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;

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
    ApiService.debugPrintBaseUrl();
    _initGoogle();
    if ((widget.initialEmail ?? '').isNotEmpty) {
      emailController.text = widget.initialEmail!.trim();
    }
  }

  Future<void> _initGoogle() async {
    // v7 requires clientId at initialize on iOS
    await _googleSignIn.initialize(clientId: _IOS_CLIENT_ID);
    try {
      await _googleSignIn.attemptLightweightAuthentication(); // optional fast path
    } catch (_) {}
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
    // 1) Start with what the login API returned
    var id = ApiService.extractIdentity(loginBody); // (first,last,name,email)

    // 2) If names are empty, try your canonical server profile (/me or /profile)
    if (id.first.isEmpty && id.last.isEmpty) {
      final fetched = await ApiService.tryFetchMe(token); // -> (first,last,name,email)?
      if (fetched != null) id = fetched;
    }

    // 3) Client-side override: if user edited on this device, prefer it
    final override = await ProfileCache.load(id.email);
    if (override != null) {
      final first = override.first.trim();
      final last = override.last.trim();
      if (first.isNotEmpty || last.isNotEmpty) {
        id = (
        first: first,
        last: last,
        name: [first, last].where((s) => s.isNotEmpty).join(' '),
        email: id.email,
        );
      }
    }

    // 4) Fallback: synthesize name from email local-part
    if (id.first.isEmpty && id.last.isEmpty) {
      final local = (id.email.isNotEmpty ? id.email : emailController.text.trim())
          .split('@')
          .first;
      id = (first: local, last: '', name: local, email: id.email);
    }

    // 5) Persist & seed session
    await SecureStorage.setToken(token);
    await SecureStorage.setUserProfile(name: id.name, email: id.email);

    await Session().setAuth(
      token: token,
      userName: id.name.isNotEmpty ? id.name : '${id.first} ${id.last}'.trim(),
      userEmail: id.email,
      firstName: id.first,
      lastName: id.last,
    );
  }

  // ----------------- Email/password login -----------------
  Future<void> _login() async {
    if (isLoading) return;
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text.trim();

      final resp = await ApiService.login(email: email, password: password);
      final status = resp['__status'] as int? ?? 500;

      if (status == 200) {
        final token = ApiService.extractToken(resp);
        if (token == null || token.isEmpty) {
          setState(() => errorMessage = 'Login succeeded but token missing.');
          await SecureStorage.signOutLocal();
          return;
        }

        await _hydrateAfterAuth(token: token, loginBody: resp);

        // 🔹 Mark: this user logged in with email/password
        await AuthPrefs.setLoginMethod(LoginMethod.password);

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Home()),
              (_) => false,
        );
        return;
      }

      if (status == 401) {
        await SecureStorage.signOutLocal();
        setState(
              () => errorMessage =
              resp['message']?.toString() ?? 'Invalid email or password.',
        );
        return;
      }

      if (status == 422) {
        await SecureStorage.signOutLocal();
        String msg = 'Validation error.';
        final body = resp['__raw'] is Map<String, dynamic>
            ? resp['__raw'] as Map<String, dynamic>
            : {};
        if (body['errors'] is Map && (body['errors'] as Map).isNotEmpty) {
          final firstErr = (body['errors'] as Map).values.first;
          if (firstErr is List && firstErr.isNotEmpty) {
            msg = firstErr.first.toString();
          }
        } else if (body['message'] != null) {
          msg = body['message'].toString();
        }
        setState(() => errorMessage = msg);
        return;
      }

      await SecureStorage.signOutLocal();
      setState(
            () => errorMessage =
            resp['message']?.toString() ?? 'Server error ($status). Try again.',
      );
    } catch (_) {
      await SecureStorage.signOutLocal();
      if (mounted) {
        setState(
              () => errorMessage = 'Network error. Check internet / API_BASE_URL.',
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ----------------- Google Sign-In (v7) -----------------
  Future<void> _signInWithGoogle() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    StreamSubscription? sub;
    try {
      final completer = Completer<gsi.GoogleSignInAccount>();
      sub = _googleSignIn.authenticationEvents.listen((event) {
        // Helpful logs for Simulator issues:
        // debugPrint('GI event: $event');
        if (event is gsi.GoogleSignInAuthenticationEventSignIn &&
            !completer.isCompleted) {
          completer.complete(event.user);
        }
      });

      if (_googleSignIn.supportsAuthenticate()) {
        await _googleSignIn.authenticate(); // opens the Google sheet
      } else {
        throw Exception('This platform does not support authenticate().');
      }

      final account = await completer.future;
      await sub.cancel();

      final gAuth = await account.authentication;
      final String? googleIdTokenMaybe = gAuth.idToken;

      if (googleIdTokenMaybe != null && googleIdTokenMaybe.isNotEmpty) {
        final cred = GoogleAuthProvider.credential(idToken: googleIdTokenMaybe);
        await FirebaseAuth.instance.signInWithCredential(cred);
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Firebase user is null after sign-in');

      final String? firebaseIdToken = await user.getIdToken(true);
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Failed to get Firebase ID token.');
      }

      // Exchange token with your backend
      final data = await ApiService.loginWithGoogleIdToken(firebaseIdToken);
      final token = ApiService.extractToken(data);
      if (token == null || token.isEmpty) {
        throw Exception('This account has been deleted or token missing.');
      }

      await _hydrateAfterAuth(token: token, loginBody: data);

      // 🔹 Mark: this user logged in with Google
      await AuthPrefs.setLoginMethod(LoginMethod.google);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Home()),
            (_) => false,
      );
    } catch (e) {
      await SecureStorage.signOutLocal();
      if (mounted) {
        setState(
              () => errorMessage = 'This account has been deleted or is inactive.\nPlease contact support to reactivate it or use a different email',
        );
      }
    } finally {
      await sub?.cancel();
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ----------------- UI -----------------
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
                          child: const Icon(Icons.close,
                              size: 28, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 50,
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 38,
                        child: Image.asset(
                          'assets/images/logo-text.png',
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
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
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text("Welcome to Akarat!",
                                style: TextStyle(fontSize: 20)),
                            const SizedBox(height: 15),

                            // Email
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 50,
                              decoration: _boxDecoration(),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10),
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
                                  if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Invalid email address';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Password
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width:
                                  MediaQuery.of(context).size.width * 0.8,
                                  height: 50,
                                  decoration: _boxDecoration(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
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
                                          icon: Icon(
                                            obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () => setState(
                                                () => obscurePassword =
                                            !obscurePassword,
                                          ),
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
                                  padding: const EdgeInsets.only(
                                      right: 10, top: 4),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const ForgotPasswordScreen(),
                                        ),
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

                            // Login button
                            isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(
                                  MediaQuery.of(context).size.width *
                                      0.8,
                                  50,
                                ),
                                backgroundColor:
                                const Color(0xFFF1F1F1),
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
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    height: 1,
                                    color: Colors.black12,
                                  ),
                                ),
                                const Text('  or  ',
                                    style:
                                    TextStyle(color: Colors.black54)),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    height: 1,
                                    color: Colors.black12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Google Sign-In
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
                                    errorBuilder: (_, __, ___) =>
                                    const Icon(
                                        Icons.g_mobiledata_outlined,
                                        size: 20),
                                  ),
                                ),
                                label: const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.black12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
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
                                const Text(
                                  'Not registered yet? ',
                                  style: TextStyle(color: Color(0xFF424242)),
                                ),
                                InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const RegisterScreen(),
                                    ),
                                  ),
                                  child: const Text(
                                    'Create new account',
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold),
                                  ),
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
                                offset: Offset(2, 2),
                              ),
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
