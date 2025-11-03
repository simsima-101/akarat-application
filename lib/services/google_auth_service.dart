import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleAuthService {
  final _auth = FirebaseAuth.instance;

  // v7: use the singleton instance (no constructor)
  final gsi.GoogleSignIn _google = gsi.GoogleSignIn.instance;

  // .env → API_BASE_URL=https://qa.akarat.com/api (or prod)
  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://qa.akarat.com/api';

  /// Returns your backend token on success.
  Future<String> signInAndGetBackendToken() async {
    // --- 1) Initialize the new v7 plugin API ---
    await _google.initialize(
      // If you need explicit IDs on iOS/macOS:
      // clientId: 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com',
      // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    );

    // Optional: try to restore a lightweight session silently (no UI)
    try {
      await _google.attemptLightweightAuthentication();
    } catch (_) {/* ignore on first run */}

    if (!_google.supportsAuthenticate()) {
      throw Exception('This platform does not support GoogleSignIn.authenticate().');
    }

    // --- 2) Start auth and wait for the sign-in event to deliver the user ---
    final account = await _authenticateAndGetAccount();

    // --- 3) Get Google tokens ---
    final gAuth   = await account.authentication;
    final idToken = gAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google idToken is null/empty.');
    }

    // --- 4) Sign in to Firebase with Google idToken ---
    final cred    = GoogleAuthProvider.credential(idToken: idToken);
    final userCred = await FirebaseAuth.instance.signInWithCredential(cred);
    final fbUser = userCred.user;
    if (fbUser == null) throw Exception('Firebase user null after Google sign-in');

    final email = (fbUser.email ?? account.email).trim();
    final name  = (fbUser.displayName ?? account.displayName ?? 'Google User').trim();
    final uid   = fbUser.uid;

    // --- 5) Try your backend LOGIN first (some backends allow email-only login) ---
    final token1 = await _login(email: email);
    if (token1 != null) return token1;

    // --- 6) Fallback: REGISTER then LOGIN with a generated password ---
    final pwd = "GGL_${uid}_!@#${DateTime.now().millisecondsSinceEpoch}";
    final ok = await _register(name: name, email: email, password: pwd);
    if (!ok) throw Exception('Backend register failed for Google user');

    final token2 = await _login(email: email, password: pwd);
    if (token2 == null) {
      throw Exception('Could not obtain backend token after Google sign-in.');
    }
    return token2;
  }

  // ---------------- v7 helper: authenticate() + wait for event ----------------
  Future<gsi.GoogleSignInAccount> _authenticateAndGetAccount() async {
    final completer = Completer<gsi.GoogleSignInAccount>();
    StreamSubscription? sub;

    try {
      sub = _google.authenticationEvents.listen((event) {
        if (event is gsi.GoogleSignInAuthenticationEventSignIn && !completer.isCompleted) {
          completer.complete(event.user);
        }
      });

      await _google.authenticate(); // launches the Google UI
      final account = await completer.future;
      return account;
    } finally {
      await sub?.cancel();
    }
  }

  // ---------------- Backend calls ----------------

  Future<String?> _login({required String email, String? password}) async {
    final uri = Uri.parse("$_baseUrl/login");

    // If your backend expects form-encoded instead, switch headers+body accordingly.
    final body = password == null ? {"email": email} : {"email": email, "password": password};

    final r = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (r.statusCode >= 200 && r.statusCode < 300) {
      return _extractToken(r.body);
    }
    return null;
  }

  Future<bool> _register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse("$_baseUrl/register");
    final r = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password,
      }),
    );
    return r.statusCode >= 200 && r.statusCode < 300;
  }

  /// Supports {token}, {access_token}, {data:{token}}, {data:{access_token}}
  String? _extractToken(String raw) {
    try {
      final m = jsonDecode(raw);
      if (m is Map<String, dynamic>) {
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
      }
    } catch (_) {}
    return null;
  }
}
