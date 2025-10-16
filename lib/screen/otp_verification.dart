import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Centralized API helpers
import 'package:Akarat/services/api_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // UI state
  bool _isVerifying = false;
  bool _isResending = false;
  int _cooldown = 0; // seconds remaining

  // flow + payload from previous screen
  // mode: 'register' | 'reset'
  String mode = 'register';
  String email = '';
  String name = '';
  String password = '';
  String? _devOtpHint;

  // ---------------- helpers ----------------

  void _setDevOtp(String otp) {
    setState(() => _devOtpHint = otp);
    // Auto-fill so you can just tap Verify (comment out if you prefer)
    otpController.text = otp;
  }

  void _startCooldown(int seconds) {
    if (seconds <= 0) return;
    setState(() => _cooldown = seconds);
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _fetchDevOtpIfNeeded() async {
    // Dev convenience only: auto-fetch a fresh OTP if none was passed
    if (!kDebugMode || email.isEmpty || (_devOtpHint?.isNotEmpty ?? false)) return;
    try {
      final res = await ApiService
          .resendOtp(email: email)
          .timeout(const Duration(seconds: 8));
      final dev = ((res['otp'] ?? '') as String).trim();
      if (mounted && dev.isNotEmpty) _setDevOtp(dev);
    } catch (e) {
      if (kDebugMode) debugPrint('DEV resendOtp failed: $e');
    }
  }

  // ---------------- lifecycle ----------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final raw = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> args =
    (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    email    = (args['email'] as String?)?.trim().toLowerCase() ?? '';
    mode     = (args['mode'] as String?)?.trim().toLowerCase() == 'reset' ? 'reset' : 'register';
    name     = (args['name'] as String?) ?? '';
    password = (args['password'] as String?) ?? '';

    final resendAfter = (args['resendAfter'] is int) ? args['resendAfter'] as int : 60;
    final passedDev   = (args['devOtp'] as String?)?.trim() ?? '';

    if (passedDev.isNotEmpty) _setDevOtp(passedDev);
    if (_cooldown == 0 && resendAfter > 0) _startCooldown(resendAfter);

    // 🔧 dev-only auto fetch to ensure the OTP is visible on screen
    _fetchDevOtpIfNeeded();

    if (kDebugMode) {
      final expiresIn = (args['expiresIn'] is int) ? args['expiresIn'] as int : 300;
      debugPrint('OTP args: mode=$mode email=$email expiresIn=$expiresIn resendAfter=$resendAfter devOtp=$_devOtpHint');
    }
  }

  // ---------------- actions ----------------

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);
    final sw = Stopwatch()..start();

    try {
      final otp = otpController.text.trim();

      // Verify with a UI timeout so we never spin forever
      final token = await ApiService
          .verifyOtp(email: email, otp: otp)
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      if (mode == 'register') {
        // ✅ ALWAYS send user to Login after successful OTP
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verified. Please log in.')),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        return;
      } else {
        // reset/forgot flow unchanged
        final hasToken = token.isNotEmpty;
        Navigator.of(context).pushReplacementNamed(
          '/reset-password',
          arguments: hasToken
              ? {'email': email, 'token': token}
              : {'email': email},
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification timed out. Check network/API and try again.')),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().isNotEmpty ? e.toString() : 'Invalid or expired OTP.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
        if (kDebugMode) debugPrint('verifyOtp completed in ${sw.elapsed}');
      }
    }
  }


  Future<void> _resendOtp() async {
    if (_isResending || _cooldown > 0 || email.isEmpty) return;

    setState(() => _isResending = true);
    try {
      Map<String, dynamic> res = const {};

      if (mode == 'register') {
        res = await ApiService.resendOtp(email: email).timeout(const Duration(seconds: 10));
      } else {
        final ok = await ApiService.forgotPassword(email).timeout(const Duration(seconds: 10));
        res = {
          'success': ok,
          'message': ok
              ? 'If the email exists, we sent a new code.'
              : 'Could not resend code. Try again soon.'
        };
      }

      if (!mounted) return;

      final msg = (res['message'] as String?) ??
          (mode == 'register'
              ? 'We’ve sent a new code.'
              : 'If the email exists, we sent a new code.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      // DEV OTP (local only)
      final devOtp = ((res['otp'] ?? '') as String).trim();
      if (devOtp.isNotEmpty && kDebugMode) {
        _setDevOtp(devOtp);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('DEV OTP: $devOtp')));
      }

      final wait = (res['resend_after'] is int) ? res['resend_after'] as int : 60;
      _startCooldown(wait);
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resend timed out. Check network/API and try again.')),
      );
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

  // ---------------- teardown ----------------

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final resendLabel =
    _cooldown > 0 ? 'Resend in $_cooldown s' : "Didn't receive the code? Resend";

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
                Text(email, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 16),

                // ---------- DEV OTP banner (debug builds only) ----------
                if (kDebugMode && (_devOtpHint?.isNotEmpty ?? false)) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFC7BC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bug_report, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'DEV OTP: ${_devOtpHint!}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _devOtpHint!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('OTP copied')),
                            );
                          },
                          child: const Text('Copy'),
                        ),
                      ],
                    ),
                  ),
                ],

                // OTP input
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6), // 4–6 supported
                  ],
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.length < 4 || s.length > 6) return 'Enter the 4–6 digit code';
                    return null;
                  },
                  onChanged: (value) {
                    // Optional: auto-submit on 4 digits
                    if (value.length == 4 && !_isVerifying) {
                      FocusScope.of(context).unfocus();
                      // _verifyOtp(); // enable if you want auto-verify on 4 digits
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                      height: 22,
                      width: 22,
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
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(resendLabel, style: const TextStyle(color: Colors.blueAccent)),
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
