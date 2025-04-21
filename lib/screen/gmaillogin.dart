import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Google Sign-In',
    home: SignInDemo(),
  ));
}

class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});
  @override
  State<SignInDemo> createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;
  String _status = 'Not signed in';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
    // Optional: required only for Flutter Web or explicit config
     clientId: '603404646565-au4gtpa3jshedd8ligh5atl9amn5fiqc.apps.googleusercontent.com',
  );

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() => _currentUser = account);
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      setState(() => _status = 'Signing in...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _status = 'Sign-in cancelled ❌');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      // Send tokens to Laravel backend
      final response = await http.post(
        Uri.parse('https://akarat.com/api/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'access_token': accessToken,
        /*  'id_token': idToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'photo_url': googleUser.photoUrl,
          'google_id': googleUser.id,*/
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _status = 'Login Success ✅');
        print('✅ Response: ${response.body}');
      } else {
        setState(() => _status = 'Backend login failed ❌');
        print('❌ Backend error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() => _status = 'Sign-in error ❌');
      print('⚠️ Error: $e');
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.disconnect();
    setState(() {
      _currentUser = null;
      _status = 'Signed out';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In')),
      body: Center(
        child: _currentUser != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage:
              NetworkImage(_currentUser!.photoUrl ?? ''),
              radius: 30,
            ),
            const SizedBox(height: 10),
            Text(_currentUser!.displayName ?? ''),
            Text(_currentUser!.email,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Text(_status),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSignOut,
              child: const Text('Sign Out'),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You are not signed in'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSignIn,
              child: const Text('Sign In with Google'),
            ),
            const SizedBox(height: 20),
            Text(_status),
          ],
        ),
      ),
    );
  }
}