// lib/screen/register_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:Akarat/src/screen/privacy.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:http/http.dart' as http;
import 'package:intl_country_data/intl_country_data.dart';

import '../../l10n/app_localizations.dart';
import '../core/services/api_service.dart';
import '../core/utils/auth_prefs.dart' as prefs;
import '../core/utils/profile_cache.dart';
import '../core/utils/secure_storage.dart';
import '../core/utils/session_manager.dart';
import 'home.dart';
import 'login.dart';
import 'otp_verification.dart';
import 'terms_condition.dart';

const String _IOS_CLIENT_ID =
    '370139668712-ema9n0o9vhq25nbqu771v5c71ehivolf.apps.googleusercontent.com';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
final _formKey = GlobalKey<FormState>();
class _RegisterScreenState extends State<RegisterScreen> {
  bool get _isFormValid {
    final first = firstController.text.trim().isNotEmpty;
    final last = lastController.text.trim().isNotEmpty;
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final pwd = passwordController.text;
    final confirm = confirmController.text;




    final loc = AppLocalizations.of(context)!;
    // Email validation
    final validEmail =
        RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);

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

  String? _validatePhone(BuildContext context, String? value) {
    final loc = AppLocalizations.of(context)!;

    // Allow empty during typing — only validate length when something is entered
    if (value == null || value.isEmpty) {
      return null;  // ← Critical: do NOT return loc.errorPhoneRequired here
    }

    final enteredLength = value.length;
    final expectedLength = _maxPhoneLength ?? 9;

    if (enteredLength != expectedLength) {
      return loc.errorPhoneLength(
        '$expectedLength',
        selectedCountryCode,
      );
    }



    return null;
  }

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
    final loc = AppLocalizations.of(context)!;

    // Validate the entire form (including phone via _validatePhone)
    if (!(_formKey.currentState?.validate() ?? false)) {
      // Optional: Scroll to the first error field for better UX
      // You can add ScrollController to your SingleChildScrollView if you want auto-scroll
      return;
    }

    // At this point, ALL fields are valid according to their validators
    final first = firstController.text.trim();
    final last = lastController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final phone = phoneController.text.trim();
    final pwd = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    // Keep password strength check (not yet in a FormField validator)
    if (!(_ruleLen && _ruleUpper && _ruleNum && _ruleSpecial)) {
      _showErr(loc.errorPasswordRequirements);
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final reg = await registerStart(
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
        final devOtp = (reg['otp'] ?? reg['dev_otp'] ?? '').toString().trim();
        final expiresIn = reg['expires_in'] is int ? reg['expires_in'] as int : 300;
        final resendAfter = reg['resend_after'] is int ? reg['resend_after'] as int : 60;

        final regToken = _extractTokenFromAny(reg) ?? '';

        String emailFromApi = (reg['email'] as String?)?.trim().toLowerCase() ?? '';
        if (emailFromApi.isEmpty) {
          emailFromApi = email.trim().toLowerCase();  // input email as ultimate fallback
        }

        debugPrint('Navigating to OTP with emailFromApi: "$emailFromApi" (original input: "$email")');
        final serverUser = ((reg['user'] ?? reg['name']) ?? '').toString().trim();

        final fullName = serverUser.isNotEmpty
            ? serverUser
            : (('$first $last').trim().isNotEmpty
            ? ('$first $last').trim()
            : emailFromApi.split('@').first);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.otpSentMessage)),
        );

        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => const OtpVerificationScreen(),
            settings: RouteSettings(
              name: '/verify-otp', // optional – keeps route name for debugging
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
            ),
          ),
        );
        return;
      }

      // Handle non-success response
      final msg = (reg['message'] ?? 'Registration failed').toString();
      _showErr(msg);
    } on TimeoutException {
      _showErr(loc.registrationTimedOut);
    } catch (e) {
      final low = e.toString().toLowerCase();

      if (low.contains('already been taken') ||
          low.contains('already exists') ||
          low.contains('conflict') ||
          low.contains('422')) {
        _showErr(loc.emailAlreadyRegistered);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginDemo(initialEmail: email)),
        );
      } else if (low.contains('too many') ||
          low.contains('throttle') ||
          low.contains('rate limit') ||
          low.contains('429')) {
        _showErr(loc.tooManyAttempts);
      } else {
        _showErr(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  static Future<Map<String, dynamic>> registerStart({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneCountryCode, // include '+'
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    // Helper: safe value picker with root-level priority
    String? _pick(Map<String, dynamic> map, List<String> paths) {
      // 1. Direct root-level check (most common in your API responses)
      if (map.containsKey('email')) {
        final val = map['email']?.toString()?.trim();
        if (val != null && val.isNotEmpty) return val.toLowerCase();
      }

      // 2. Nested paths
      for (final path in paths) {
        dynamic current = map;
        final keys = path.split('.');
        bool found = true;

        for (final key in keys) {
          if (current is Map<String, dynamic> && current.containsKey(key)) {
            current = current[key];
          } else {
            found = false;
            break;
          }
        }

        if (found && current is String && current.trim().isNotEmpty) {
          return current.trim().toLowerCase();
        }
      }

      return null;
    }

    // Helper: integer picker
    int? _pickInt(Map<String, dynamic> map, List<String> paths) {
      final v = _pick(map, paths);
      return v != null ? int.tryParse(v) : null;
    }

    // Helper: first validation error message
    String? _firstErr(Map<String, dynamic> data) {
      final errs = data['errors'];
      if (errs is Map<String, dynamic>) {
        for (final entry in errs.entries) {
          final val = entry.value;
          if (val is List && val.isNotEmpty) return val.first.toString();
          if (val is String && val.isNotEmpty) return val;
        }
      }
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      return null;
    }

    // Prepare phone country code
    final cc = phoneCountryCode.trim().startsWith('+')
        ? phoneCountryCode.trim()
        : '+${phoneCountryCode.trim()}';

    // Make the API call
    final resp = await _postForm('/register', {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': email.trim().toLowerCase(),
      'phone_country_code': cc,
      'phone': phone.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    // Early declaration + safe fallback
    Map<String, dynamic> data = <String, dynamic>{};

    try {
      data = _decodeMap(resp.body);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to decode register response: $e\nBody: ${resp.body}');
      }
      // data remains empty map → safe
    }

    if (kDebugMode) {
      print(
        '[POST-FORM] ${resp.request?.url} -> ${resp.statusCode} ${resp.body}',
      );
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      // Extract values with fallback
      final otp = _pick(data, ['otp', 'data.otp', 'meta.otp']);
      final expiresIn = _pickInt(data, ['expires_in', 'meta.expires_in']) ?? 300;
      final resendAfter =
          _pickInt(data, ['resend_after', 'meta.resend_after']) ?? 60;

      // Email: prefer API → fallback to input email
      final emailOut = _pick(data, [
        'email',
        'data.email',
        'user.email',
        'data.user.email',
      ]) ??
          email.trim().toLowerCase();

      final nameOut = _pick(data, [
        'user',
        'name',
        'data.name',
        'data.user.name',
      ]) ??
          '$firstName $lastName'.trim();

      final tokenOut = extractToken(data);

      // Debug log to confirm extraction
      if (kDebugMode) {
        print('Extracted emailFromApi in registerStart: "$emailOut" '
            '(fallback input: "${email.trim().toLowerCase()}")');
      }

      return {
        '__status': resp.statusCode,
        'message': (data['message'] ?? '').toString(),
        'otp': otp,
        'expires_in': expiresIn,
        'resend_after': resendAfter,
        'email': emailOut,
        'user': nameOut,
        'token': tokenOut, // may be null if not issued at register step
        '__raw': data,
      };
    }

    // Error handling
    if (resp.statusCode == 422 || resp.statusCode == 409) {
      final msg = _firstErr(data) ??
          'This email is already registered or the data is invalid.';
      throw Exception(msg);
    }

    final backendMsg = _firstErr(data);
    throw Exception(backendMsg ?? 'Registration failed (${resp.statusCode}).');
  }

  static Future<http.Response> _postForm(
    String endpoint,
    Map<String, String> fields,
  ) async {
    final url = ApiService.buildUri(endpoint);
    // final resp = await http
    //     .post(url, headers: _formHeaders, body: fields)
    //     .timeout(Duration(seconds: 25));

    final resp = await ApiService.post(
      endpoint,
      body: fields,

    ).timeout(const Duration(seconds: 25));

    if (kDebugMode) {
      print('[POST-FORM] $url -> ${resp.statusCode} ${resp.body}');
    }
    return resp;
  }

  static Map<String, dynamic> _decodeMap(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static bool _looksJson(http.Response r) {
    final ct = (r.headers['content-type'] ?? '').toLowerCase();
    return ct.contains('application/json');
  }

  static bool _looksHtml(http.Response r) {
    final ct = (r.headers['content-type'] ?? '').toLowerCase();
    if (ct.contains('text/html')) return true;
    final body = r.body.trimLeft();
    return body.startsWith('<!doctype') || body.startsWith('<html');
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

  // --- Laravel-friendly form posts ---
  static const Map<String, String> _formHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
    'X-Requested-With': 'XMLHttpRequest',
  };

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
    var id = extractIdentity(loginBody); // (first,last,name,email)

    // 2) If names are empty, try your canonical server profile (/me or /profile)
    if (id.first.isEmpty && id.last.isEmpty) {
      final fetched = await tryFetchMe(token); // -> (first,last,name,email)?
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

  // --- compatibility wrapper so existing call sites can use extractIdentity(...) ---
  static ({String first, String last, String name, String email})
      extractIdentity(Map<String, dynamic> src) {
    return extractIdentityFromAny(src);
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
      headers: {'Authorization': 'Bearer $token'},
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

  // ----------------- Google Sign-In (v7) -----------------
  Future<void> _signInWithGoogle() async {
    if (isLoading) return;

    final loc = AppLocalizations.of(context)!;
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
        throw Exception(loc.googleSignInNotSupported);
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
      if (user == null) throw Exception(loc.firebaseUserNullAfterSignIn);

      final String? firebaseIdToken = await user.getIdToken(true);
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception(loc.failedToGetFirebaseIdToken);
      }

      // Exchange token with your backend
      final data = await loginWithGoogleIdToken(firebaseIdToken);
      final token = extractToken(data);
      if (token == null || token.isEmpty) {
        throw Exception(loc.accountDeletedOrTokenMissing);
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
              loc.accountDeletedOrInactiveContactSupport
        );
      }
    } finally {
      await sub?.cancel();
      if (mounted) setState(() => isLoading = false);
    }
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
      body: body,
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

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {

    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(loc.registerTitle),
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Form(                           // ← Add this
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,// ← Add GlobalKey<FormState> _formKey = GlobalKey();
              child: _buildScreenContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreenContent(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
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
              label: Text(loc.continueWithGoogle,
                style: const TextStyle(fontWeight: FontWeight.w600),
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
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE3E3E3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                AppLocalizations.of(context)!.or,           // ← changed here
                style: const TextStyle(color: Color(0xFF6B6B6B)),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE3E3E3))),
          ],
        ),
        const SizedBox(height: 16),

        // Inputs (no Form)
        TextField(
          controller: firstController,
          textInputAction: TextInputAction.next,
          decoration: _dec(loc.firstNameHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: lastController,
          textInputAction: TextInputAction.next,
          decoration: _dec(loc.lastNameHint),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: _dec(loc.emailHint),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            // Country Code Picker
            CountryCodePicker(
              onChanged: (code) {
                setState(() {
                  selectedCountryCode = code.dialCode ?? "+971";
                  final intlCountry = IntlCountryData.fromCountryCodeAlpha2(
                    code.code ?? "AE",
                  );

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
              margin: const EdgeInsets.only(left: 0, right: 8), // ← adjusted like your second example
              padding: EdgeInsets.zero,
              headerTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              closeIcon: const Icon(Icons.close, size: 25),
              dialogSize: const Size(double.infinity, 700),

              searchDecoration: InputDecoration(
                hintText: loc.searchCountryHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              dialogItemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              searchPadding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            ),

            const SizedBox(width: 8),

            // Phone number Input
            Expanded(
              child: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: _maxPhoneLength ?? 9,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) => _validatePhone(context, value),
                decoration: InputDecoration(
                  hintText: loc.phoneHint,
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: _fieldBorder,
                  focusedBorder: _fieldBorder.copyWith(
                    borderSide: const BorderSide(color: Color(0xFFDADADA)),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  counterText: '',
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
       loc.passwordHint,
            suffix: IconButton(
              onPressed: () => setState(() => _hidePwd = !_hidePwd),
              icon: Icon(_hidePwd ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _ruleRow(_ruleLen, loc.atLeast8Characters),
        _ruleRow(_ruleUpper, loc.oneUppercaseLetter),
        _ruleRow(_ruleNum, loc.oneNumber),
        _ruleRow(_ruleSpecial, loc.oneSpecialCharacter),
        const SizedBox(height: 12),

        TextField(
          controller: confirmController,
          obscureText: _hideConfirm,
          decoration: _dec(
         loc.confirmPasswordHint,
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
                    ? const Color(0xFFFF2D2D) // Bright red when valid
                    : Colors.grey.shade400, // Grey when invalid
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
                  : Text(
                      loc.registerButton,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                TextSpan(text: loc.bySigningUpAgreeTo),
                TextSpan(
                  text: loc.termsAndConditions,
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
                TextSpan(text: loc.and),
                TextSpan(
                  text: loc.privacyPolicy,
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
           Text(
              loc.alreadyHaveAccount,
              style: TextStyle(color: Color(0xFF616161), fontSize: 16),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginDemo()),
              ),
              child:Text(
              loc.loginHere,
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
