import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ⭐ ADDED: use your ApiService for resend
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

  // ⭐ ADDED: resend state
  bool _isResending = false;
  int _cooldown = 0; // seconds until next resend allowed

  // ⭐ ADDED: support both flows (register / reset)
  String mode = 'reset'; // 'register' or 'reset'
  String email = '';
  String name = '';
  String password = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      email = (args['email'] as String?) ?? '';
      mode = (args['mode'] as String?) ?? 'reset'; // default to reset
      name = (args['name'] as String?) ?? '';
      password = (args['password'] as String?) ?? '';
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);

    final otp = otpController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final data = jsonDecode(response.body);
      setState(() => _isVerifying = false);

      if (response.statusCode == 200 && data['token'] != null) {
        final token = data['token']?.toString() ?? '';
        if (!mounted) return;

        // If you’re using this screen for registration,
        // you can complete the signup here instead of going to reset-password.
        if (mode == 'register') {
          // Option 1 (recommended): complete registration then go home
          // await ApiService.completeRegistration(
          //   name: name, email: email, password: password, token: token,
          // );
          // Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);

          // Option 2 (your current behavior is for reset-password)
          Navigator.pushReplacementNamed(
            context,
            '/reset-password',
            arguments: {'email': email, 'token': token},
          );
        } else {
          // forgot-password flow
          Navigator.pushReplacementNamed(
            context,
            '/reset-password',
            arguments: {'email': email, 'token': token},
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Invalid OTP. Please try again.')),
        );
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
  }

  // ⭐ ADDED: real resend implementation
  Future<void> _resendOtp() async {
    if (_isResending || email.isEmpty) return;

    setState(() => _isResending = true);
    try {
      Map<String, dynamic> res = const {}; // for message & optional cooldown

      if (mode == 'register') {
        // For registration, your backend expects GET /register/send-otp
        res = await ApiService.sendRegisterOtp(email: email);
      } else {
        // For forgot-password flow, trigger another reset email
        final ok = await ApiService.forgotPassword(email);
        res = {
          'message': ok
              ? 'If the email exists, we sent a new code.'
              : 'Could not resend code. Try again shortly.'
        };
      }

      if (!mounted) return;

      final msg = (res['message'] as String?) ??
          (mode == 'register'
              ? 'We’ve sent a new code (if the previous expired).'
              : 'If the email exists, we sent a new code.');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      // Optional cooldown UI (API may return resend_after)
      final wait = (res['resend_after'] is int) ? res['resend_after'] as int : 45;
      setState(() => _cooldown = wait);

      while (_cooldown > 0 && mounted) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) break;
        setState(() => _cooldown--);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
    final resendLabel = _cooldown > 0
        ? 'Resend in $_cooldown s'
        : "Didn't receive the code? Resend";

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Enter the 6-digit code sent to your email",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(email, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 30),

                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    prefixIcon: Icon(Icons.key),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 4) {
                      return 'Enter valid OTP';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isVerifying
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text("Verify OTP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),

                // ⭐ ADDED: real resend button with cooldown/disable
                TextButton(
                  onPressed: (_isResending || _cooldown > 0) ? null : _resendOtp,
                  child: _isResending
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(resendLabel, style: const TextStyle(color: Colors.blueAccent)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
