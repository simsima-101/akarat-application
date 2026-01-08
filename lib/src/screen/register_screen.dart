  // lib/screen/register_screen.dart
  import 'dart:async';

  import 'package:Akarat/src/screen/privacy.dart';
import 'package:country_code_picker/country_code_picker.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/gestures.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:google_sign_in/google_sign_in.dart' as gsi;
  import 'package:intl_country_data/intl_country_data.dart';
  import '../core/utils/auth_prefs.dart' as prefs;
  import '../core/utils/secure_storage.dart';
  import '../core/services/api_service.dart';
  import '../core/utils/auth_prefs.dart';
  import '../core/utils/profile_cache.dart';

  import '../features/auth/data/datasources/auth_local_datasource.dart';

  import '../core/utils/session_manager.dart';
  import 'home.dart';
  import 'login.dart';
  import 'terms_condition.dart';

  const String _IOS_CLIENT_ID =
      '370139668712-ema9n0o9vhq25nbqu771v5c71ehivolf.apps.googleusercontent.com';

  class RegisterScreen extends StatefulWidget {
    const RegisterScreen({super.key});
    @override
    State<RegisterScreen> createState() => _RegisterScreenState();
  }

  class _RegisterScreenState extends State<RegisterScreen> {


    bool get _isFormValid {
      final first = firstController.text.trim().isNotEmpty;
      final last = lastController.text.trim().isNotEmpty;
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();
      final pwd = passwordController.text;
      final confirm = confirmController.text;

      // Email validation
      final validEmail = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);

      // Phone: must be exactly _maxPhoneLength digits and not empty
      final validPhone = phone.isNotEmpty && phone.length == _maxPhoneLength;

      // Password match and not empty
      final passwordsMatch = pwd.isNotEmpty && pwd == confirm;

      // Password strength rules
      final passwordValid = pwd.length >= 8 &&
          RegExp(r'[A-Z]').hasMatch(pwd) &&
          RegExp(r'\d').hasMatch(pwd) &&
          RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\]=;+`~]').hasMatch(pwd);

      return first &&
          last &&
          email.isNotEmpty &&
          validEmail &&
          validPhone &&
          pwd.isNotEmpty &&
          passwordsMatch &&
          passwordValid;
    }
    // Controllers
    final firstController = TextEditingController();
    final lastController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    String selectedCountryCode = "+971"; // default UAE

    int _maxPhoneLength = 9;

    // Register state
    bool _isLoading = false;
    bool _hidePwd = true;
    bool _hideConfirm = true;


    // Google state (separate from _isLoading)
    bool isLoading = false;
    String? errorMessage;
    final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn.instance;

    // Password rules
    bool get _ruleLen => passwordController.text.trim().length >= 8;
    bool get _ruleUpper => RegExp(r'[A-Z]').hasMatch(passwordController.text);
    bool get _ruleNum => RegExp(r'\d').hasMatch(passwordController.text);
    bool get _ruleSpecial => RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\]=;+`~]')
        .hasMatch(passwordController.text);

    // Styles
    OutlineInputBorder get _fieldBorder => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE9E9E9)),
        );

    InputDecoration _dec(String hint, {Widget? prefix, Widget? suffix}) =>
        InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: _fieldBorder,
          focusedBorder: _fieldBorder.copyWith(
            borderSide: const BorderSide(color: Color(0xFFDADADA)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          prefixIcon: prefix != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: prefix)
              : null,
          suffixIcon: suffix,
        );

    // ---------- SUBMIT ----------
    Future<void> _submit() async {
      // Read values
      final first = firstController.text.trim();
      final last = lastController.text.trim();
      final email = emailController.text.trim().toLowerCase();
      final phone = phoneController.text.trim();
      final pwd = passwordController.text.trim();
      final confirm = confirmController.text.trim();

      // Manual validation (screen-level)
      if (first.isEmpty) {
        _showErr('Please enter first name');
        return;
      }
      if (last.isEmpty) {
        _showErr('Please enter last name');
        return;
      }
      if (email.isEmpty) {
        _showErr('Please enter email');
        return;
      }
      if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
        _showErr('Invalid email');
        return;
      }
      if (phone.isEmpty) {
        _showErr('Please enter phone');
        return;
      }
      if (!RegExp(r'^[0-9]{7,12}$').hasMatch(phone)) {
        _showErr('Enter a valid number');
        return;
      }
      debugPrint("phone:${phone.length}, max len :${_maxPhoneLength}");

      // Check length based on selected country
      if (phone.length != _maxPhoneLength) {
        _showErr(
            'Phone number must be $_maxPhoneLength digits for ${selectedCountryCode}');

        return;
      }

      if (pwd.isEmpty) {
        _showErr('Please enter password');
        return;
      }
      if (!(_ruleLen && _ruleUpper && _ruleNum && _ruleSpecial)) {
        _showErr('Password doesn’t meet requirements');
        return;
      }
      if (confirm.isEmpty) {
        _showErr('Please confirm password');
        return;
      }
      if (confirm != pwd) {
        _showErr('Passwords do not match');
        return;
      }



      FocusScope.of(context).unfocus();
      setState(() => _isLoading = true);

      try {
        // Prefer normalized endpoint
        final reg = await ApiService.registerStart(
          firstName: first,
          lastName: last,
          email: email,
          phoneCountryCode: selectedCountryCode,
          phone: phone,
          password: pwd,
          passwordConfirmation: confirm,
        ).timeout(const Duration(seconds: 15));

        final status = reg['__status'] as int? ?? 500;
        if (status == 200 || status == 201) {
          // Pull optional OTP hints / timers (with sane fallbacks)
          final devOtp = (reg['otp'] ?? reg['dev_otp'] ?? '').toString().trim();
          final expiresIn =
              reg['expires_in'] is int ? reg['expires_in'] as int : 300;
          final resendAfter =
              reg['resend_after'] is int ? reg['resend_after'] as int : 60;

          // Try to extract a token if your backend returned one on register
          final regToken = _extractTokenFromAny(reg) ?? '';

          // Prefer server-provided identity if present
          final emailFromApi = (reg['email'] ?? email).toString().trim();
          final serverUser =
              ((reg['user'] ?? reg['name']) ?? '').toString().trim();

          final fullName = serverUser.isNotEmpty
              ? serverUser
              : (('$first $last').trim().isNotEmpty
                  ? ('$first $last').trim()
                  : emailFromApi.split('@').first);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent. Please check your email.')),
          );

          // 🚀 Navigate to OTP with everything needed to seed Session after verify
          Navigator.of(context, rootNavigator: true).pushNamed(
            '/verify-otp',
            arguments: {
              'mode': 'register',
              'email': emailFromApi,
              'firstName': first,
              'lastName': last,
              'name': fullName,
              'password': pwd,
              'phone': phone,
              'phoneCode': selectedCountryCode,
              'expiresIn': expiresIn,
              'resendAfter': resendAfter,
              if (devOtp.isNotEmpty) 'devOtp': devOtp,
              if (regToken.isNotEmpty) 'token': regToken,
            },
          );
          return;
        }

        // Non-200/201
        final msg = (reg['message'] ?? 'Registration failed').toString();
        _showErr(msg);
      } on TimeoutException {
        _showErr('Registration timed out. Please try again.');
      } catch (e) {
        final low = e.toString().toLowerCase();
        if (low.contains('already been taken') ||
            low.contains('already exists') ||
            low.contains('conflict') ||
            low.contains('422')) {
          _showErr(
              'This email is already registered. Please Login or use Forgot Password.');
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginDemo(initialEmail: email)),
          );
        } else if (low.contains('too many') ||
            low.contains('throttle') ||
            low.contains('rate limit') ||
            low.contains('429')) {
          _showErr('Too many attempts. Please wait a minute and try again.');
        } else {
          _showErr(e.toString());
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    // ---------- helpers ----------
    String? _extractTokenFromAny(Map<String, dynamic> m) {
      // Supports: {token}, {access_token}, {data:{token}}, {data:{access_token}}
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

    ({String first, String last}) _splitName(String input) {
      final parts = input.trim().split(RegExp(r'\s+'));
      if (parts.isEmpty) return (first: '', last: '');
      final f = parts.first;
      final l = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      return (first: f, last: l);
    }

    void _showErr(String m) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }

    @override
    void initState() {
      super.initState();
      passwordController.addListener(() => setState(() {}));

      firstController.addListener(() => setState(() {}));
      lastController.addListener(() => setState(() {}));
      emailController.addListener(() => setState(() {}));
      phoneController.addListener(() => setState(() {}));
      passwordController.addListener(() => setState(() {}));
      confirmController.addListener(() => setState(() {}));


      _initGoogle();
    }

    Future<void> _initGoogle() async {
      // v7 requires clientId at initialize on iOS
      await _googleSignIn.initialize(clientId: _IOS_CLIENT_ID);
      try {
        // await _googleSignIn
        //     .attemptLightweightAuthentication(); // optional fast path
      } catch (_) {}
    }

    @override
    void dispose() {
      firstController.dispose();
      lastController.dispose();
      emailController.dispose();
      phoneController.dispose();
      passwordController.dispose();
      confirmController.dispose();
      super.dispose();
    }

    // ----------------- Common auth hydration (same pattern as login) -----------------
    Future<void> _hydrateAfterAuth({
      required String token,
      required Map<String, dynamic> loginBody,
    }) async {
      // 1) Start with what the login/Google API returned
      var id = ApiService.extractIdentity(loginBody); // (first,last,name,email)

      // 2) If names are empty, try your canonical server profile (/me or /profile)
      if (id.first.isEmpty && id.last.isEmpty) {
        final fetched =
            await ApiService.tryFetchMe(token); // -> (first,last,name,email)?
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
        final local =
            (id.email.isNotEmpty ? id.email : emailController.text.trim())
                .split('@')
                .first;
        id = (first: local, last: '', name: local, email: id.email);
      }

      // 5) Persist & seed session
      await SecureStorage.setToken(token);
      await SecureStorage.setUserProfile(name: id.name, email: id.email);

      await SessionManager().setAuth(
        token: token,
        userName: id.name.isNotEmpty ? id.name : '${id.first} ${id.last}'.trim(),
        userEmail: id.email,
        firstName: id.first,
        lastName: id.last,
      );
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

        await prefs.AuthPrefs.setLoginMethod(prefs.LoginMethod.google);

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Home()),
          (_) => false,
        );
      } catch (e) {
        await SecureStorage.signOutLocal();
        if (mounted) {
          setState(
            () => errorMessage =
                'This account has been deleted or is inactive.\nPlease contact support to reactivate it or use a different email',
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
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text('Create Account'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Center(
            // 🔹 Constrain horizontal width like login
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: _buildScreenContent(context),
            ),
          ),
        ),
      );
    }

    Widget _buildScreenContent(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),

          // Google button
          Center(
            child: SizedBox(
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFE3E3E3))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR', style: TextStyle(color: Color(0xFF6B6B6B))),
              ),
              Expanded(child: Divider(color: Color(0xFFE3E3E3))),
            ],
          ),
          const SizedBox(height: 16),

          // Inputs (no Form)
          TextField(
            controller: firstController,
            textInputAction: TextInputAction.next,
            decoration: _dec('First Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: lastController,
            textInputAction: TextInputAction.next,
            decoration: _dec('Last Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _dec('E-mail'),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE9E9E9)),
                ),
                child: CountryCodePicker(
                  onChanged: (code) {
                    setState(() {
                      selectedCountryCode = code.dialCode ?? "+971";
                      final intlCountry = IntlCountryData.fromCountryCodeAlpha2(
                          code.code ?? "AE");

                      phoneController.clear();

                      _maxPhoneLength = intlCountry.telephoneMaxLength;
                    });
                  },
                  initialSelection: 'AE', // UAE default
                  favorite: const [],
                  showDropDownButton: false,
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  margin: EdgeInsetsGeometry.only(left: 0, right: 8),
                  padding: EdgeInsetsGeometry.all(0),
                  headerTextStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  closeIcon: Icon(
                    Icons.close,
                    size: 25,
                  ),
                  dialogSize: Size(double.infinity, 700),

                  searchDecoration: InputDecoration(
                    hintText: 'Search country',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  dialogItemPadding:
                      EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 13),
                  // topBarPadding: EdgeInsets.only(bottom: 20),
                  searchPadding:
                      EdgeInsetsGeometry.only(bottom: 10, left: 10, right: 10),
                ),

                // const Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     Text('🇦🇪', style: TextStyle(fontSize: 16)),
                //     SizedBox(width: 8),
                //     Text('+971', style: TextStyle(fontWeight: FontWeight.w600)),
                //   ],
                // ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: _maxPhoneLength ?? 9,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  // Fallback default if no country selected
                  decoration: InputDecoration(
                    hintText: 'Phone',
                    hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: _fieldBorder,
                    focusedBorder: _fieldBorder.copyWith(
                      borderSide: const BorderSide(color: Color(0xFFDADADA)),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0),
                    counterText: '',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: passwordController,
            obscureText: _hidePwd,
            textInputAction: TextInputAction.next,
            decoration: _dec(
              'Password',
              suffix: IconButton(
                onPressed: () => setState(() => _hidePwd = !_hidePwd),
                icon: Icon(_hidePwd ? Icons.visibility_off : Icons.visibility),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _ruleRow(_ruleLen, 'At least 8 characters'),
          _ruleRow(_ruleUpper, 'One uppercase letter'),
          _ruleRow(_ruleNum, 'One number'),
          _ruleRow(_ruleSpecial, 'One special character'),
          const SizedBox(height: 12),

          TextField(
            controller: confirmController,
            obscureText: _hideConfirm,
            decoration: _dec(
              'Confirm Password',
              suffix: IconButton(
                onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                icon:
                    Icon(_hideConfirm ? Icons.visibility_off : Icons.visibility),
              ),
            ),
          ),
          const SizedBox(height: 16),



          const SizedBox(height: 22),

          const SizedBox(height: 22),

// 🔴 Register button
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isFormValid && !_isLoading ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid
                      ? const Color(0xFFFF2D2D)  // Bright red when valid
                      : Colors.grey.shade400,   // Grey when invalid
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: _isFormValid ? 4 : 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Register',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

// ✅ New agreement text with two links
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'By Signing up I agree to the '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: const TextStyle(
                      color: Color(0xFF2F6FE4),
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TermsCondition(),
                          ),
                        );
                      },
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: Color(0xFF2F6FE4),
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Replace with your actual Privacy Policy screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const Privacy(), // Create this screen
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

// Existing "Already have an account?" row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account?  ',
                style: TextStyle(color: Color(0xFF616161), fontSize: 16),
              ),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginDemo()),
                ),
                child: const Text(
                  'Login Here',
                  style: TextStyle(
                    color: Color(0xFF2F6FE4),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     const Text(
          //       'Already have an account?  ',
          //       style: TextStyle(color: Color(0xFF616161), fontSize: 16),
          //     ),
          //     GestureDetector(
          //       onTap: () => Navigator.pushReplacement(
          //         context,
          //         MaterialPageRoute(builder: (_) => const LoginDemo()),
          //       ),
          //       child: const Text(
          //         'Login Here',
          //         style: TextStyle(
          //           color: Color(0xFF2F6FE4),
          //           fontWeight: FontWeight.w600,
          //           decoration: TextDecoration.underline,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      );
    }

    Widget _ruleRow(bool ok, String text) => Row(
          children: [
            Icon(
              ok ? Icons.check_circle : Icons.circle,
              size: 14,
              color: ok ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 13.5)),
          ],
        );
  }
