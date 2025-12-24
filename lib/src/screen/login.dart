// lib/screen/login.dart
import 'dart:async';


import 'package:Akarat/src/screen/register_screen.dart';
// Firebase + Google Sign-In (v7)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;

import '../core/utils/secure_storage.dart';
import '../core/services/api_service.dart';

import '../features/auth/data/datasources/auth_local_datasource.dart';

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
    ApiService.debugPrintBaseUrl();

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
    var id = ApiService.extractIdentity(loginBody);

    if (id.first.isEmpty && id.last.isEmpty) {
      final fetched = await ApiService.tryFetchMe(token);
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
      String msg = 'Server error. Try again.';
      if (status == 401) {
        msg = resp['message']?.toString() ?? 'Invalid email or password.';
      } else if (status == 422) {
        final body =
            resp['__raw'] is Map ? resp['__raw'] as Map<String, dynamic> : {};
        final errors = body['errors'] as Map?;
        if (errors != null && errors.isNotEmpty) {
          msg = (errors.values.first is List &&
                  (errors.values.first as List).isNotEmpty)
              ? (errors.values.first as List).first.toString()
              : 'Validation error.';
        } else {
          msg = body['message']?.toString() ?? msg;
        }
      } else {
        msg = resp['message']?.toString() ?? 'Server error ($status).';
      }

      setState(() => errorMessage = msg);
    } catch (_) {
      setState(() => errorMessage = 'Network error. Check your connection.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ----------------- Google Sign-In -----------------
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
        if (event is gsi.GoogleSignInAuthenticationEventSignIn &&
            !completer.isCompleted) {
          completer.complete(event.user);
        }
      });

      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception('Google Sign-In not supported on this platform.');
      }

      await _googleSignIn.authenticate();
      final account = await completer.future;
      await sub?.cancel();

      final gAuth = await account.authentication;
      final googleIdToken = gAuth.idToken;
      if (googleIdToken == null) throw Exception('Google ID token missing.');

      final cred = GoogleAuthProvider.credential(idToken: googleIdToken);
      await FirebaseAuth.instance.signInWithCredential(cred);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Firebase sign-in failed.');

      final firebaseIdToken = await user.getIdToken(true);
      if (firebaseIdToken == null)
        throw Exception('Failed to get Firebase token.');

      final data = await ApiService.loginWithGoogleIdToken(firebaseIdToken);
      final token = ApiService.extractToken(data);
      if (token == null || token.isEmpty) {
        throw Exception('Account inactive or deleted.');
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
                            const Text("Welcome to Akarat!",
                                style: TextStyle(fontSize: 20)),
                            const SizedBox(height: 15),

                            // Email Field
                            _buildTextField(emailController, 'Email',
                                TextInputType.emailAddress),

                            const SizedBox(height: 6),

                            // Password Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Correct call: positional optional parameters (no named syntax!)
                                _buildTextField(
                                  passwordController,
                                  'Password',
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
                                    child: const Text(
                                      "Forgot password?",
                                      style: TextStyle(
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
                                    child: const Text("Login",
                                        style: TextStyle(
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
                                label: const Text('Continue with Google',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
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
                                const Text('Not registered yet? ',
                                    style: TextStyle(color: Color(0xFF424242))),
                                InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen())),
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
    String hint, [
    TextInputType? keyboardType,
    bool obscureText = false,
    void Function(String)? onFieldSubmitted,
    Widget? suffixIcon,
  ]) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      // height: 50,
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
          hintText: hint,
          suffixIcon: suffixIcon,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hint';
          }
          if (hint == 'Email' &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Invalid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 1,
                color: Colors.black12)),
        const Text('  or  ', style: TextStyle(color: Colors.black54)),
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
