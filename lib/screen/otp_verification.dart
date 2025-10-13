import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// Your app's API helpers
import 'package:Akarat/services/api_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isVerifying = false;

  // Resend state
  bool _isResending = false;
  int _cooldown = 0; // seconds remaining for resend cooldown

  // Flow + payload passed from previous screen
  // mode: 'register' or 'reset'
  String mode = 'reset';
  String email = '';
  String name = '';
  String password = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      email = (args['email'] as String?)?.trim().toLowerCase() ?? '';
      mode = (args['mode'] as String?) ?? 'reset';
      name = (args['name'] as String?) ?? '';
      password = (args['password'] as String?) ?? '';
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);
    final otp = otpController.text.trim();

    try {
      final uri = Uri.parse('${ApiService.baseUrl}/verify-otp');

      final response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final Map<String, dynamic> body =
      response.body.isNotEmpty ? (jsonDecode(response.body) as Map<String, dynamic>) : {};

      setState(() => _isVerifying = false);

      if (response.statusCode == 200) {
        // ✅ Treat 200 as success even if there's no {success:true} or {token}
        final token = (body['token'] ?? '').toString();
        final hasToken = token.isNotEmpty;

        if (!mounted) return;

        if (mode == 'register') {
          // Try auto-login (if your backend supports it)
          try {
            final loginResp = await ApiService.loginUser(email: email, password: password);
            final loginToken = (loginResp['token'] ?? '').toString();
            if (loginToken.isNotEmpty) {
              // TODO: persist loginToken if you store auth
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
              return;
            }
          } catch (_) {
            // ignore and fall back to login screen
          }

          // No token / auto-login failed → go to Login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP verified. Please log in.')),
          );
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        } else {
          // reset/forgot flow
          if (hasToken) {
            Navigator.of(context).pushReplacementNamed(
              '/reset-password',
              arguments: {'email': email, 'token': token},
            );
          } else {
            Navigator.of(context).pushReplacementNamed(
              '/reset-password',
              arguments: {'email': email},
            );
          }
        }
      } else {
        final msg = (body['message'] ?? body['error'] ?? 'Invalid or expired OTP.').toString();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    }
  }


  Future<void> _resendOtp() async {
    if (_isResending || _cooldown > 0 || email.isEmpty) return;

    setState(() => _isResending = true);

    try {
      Map<String, dynamic> res = const {};

      if (mode == 'register') {
        // One canonical resend for register flow
        res = await ApiService.resendOtp(email: email);
      } else {
        // Start/reset flow: trigger the backend to send code for password reset
        final ok = await ApiService.forgotPassword(email);
        res = {
          'success': ok,
          'message': ok
              ? 'If the email exists, we sent a new code.'
              : 'Could not resend code. Try again soon.'
        };
      }

      if (!mounted) return;

      // Friendly message
      final msg = (res['message'] as String?) ??
          (mode == 'register'
              ? 'We’ve sent a new code.'
              : 'If the email exists, we sent a new code.');
      final attemptsLeft = res['attempts_left'];
      final extra = attemptsLeft is int ? ' (Attempts left: $attemptsLeft)' : '';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$msg$extra')));

      // Show DEV OTP if backend includes it (only in local/dev)
      final devOtp = ((res['otp'] ?? '') as String).trim();
      if (devOtp.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('DEV OTP: $devOtp')));
      }

      // Cooldown (server value wins; default 60s)
      final wait = (res['resend_after'] is int) ? res['resend_after'] as int : 60;
      setState(() => _cooldown = wait);

      // Optional: could also read expires_in if you display a timer somewhere
      // final expiresIn = (res['expires_in'] is int) ? res['expires_in'] as int : 300;

      // Countdown
      while (_cooldown > 0 && mounted) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) break;
        setState(() => _cooldown--);
      }
    } catch (e) {
      if (!mounted) return;

      final text = e.toString().toLowerCase().contains('429') ||
          e.toString().toLowerCase().contains('too many')
          ? 'Too many attempts. Please wait and try again.'
          : e.toString();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }



  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resendLabel = _cooldown > 0 ? 'Resend in $_cooldown s' : "Didn't receive the code? Resend";

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Enter the 4-digit code sent to your email',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // OTP input
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.length < 4 || s.length > 6) return 'Enter the 4–6 digit code';
                    return null;
                  },

                  onChanged: (value) {
                    if (value.length == 4) {
                      // Optional: auto-submit on 4 digits
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Verify OTP',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: (_isResending || _cooldown > 0) ? null : _resendOtp,
                    child: _isResending
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(
                      resendLabel,
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Check Spam/Promotions if you don’t see the email.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
