import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Akarat/services/api_service.dart';
import '../secure_storage.dart';
import 'login.dart';

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
  int _cooldown = 0;
  bool _inited = false;

  // flow + payload from previous screen
  String mode = 'register'; // 'register' | 'reset'
  String email = '';
  String name = '';
  String password = '';
  String firstName = '';
  String lastName  = '';
  String phoneCode = '';
  String phone     = '';

  String? _devOtpHint;

  // ---------------- helpers ----------------
  void _setDevOtp(String otp) {
    setState(() => _devOtpHint = otp);
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
    if (!kDebugMode || email.isEmpty || (_devOtpHint?.isNotEmpty ?? false)) return;
    try {
      final res = await ApiService.resendOtp(email: email).timeout(const Duration(seconds: 160));
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

    if (_inited) return; // ✅ prevent re-initializing on rebuild/hot reload
    _inited = true;

    final raw = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> args =
    (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    email     = (args['email'] as String?)?.trim().toLowerCase() ?? '';
    mode      = (args['mode'] as String?)?.trim().toLowerCase() == 'reset' ? 'reset' : 'register';
    name      = (args['name'] as String?)?.trim() ?? '';
    password  = (args['password'] as String?)?.trim() ?? '';
    firstName = (args['firstName'] as String?)?.trim() ?? '';
    lastName  = (args['lastName']  as String?)?.trim() ?? '';
    phone     = (args['phone']     as String?)?.trim() ?? '';
    phoneCode = (args['phoneCode'] as String?)?.trim() ?? '';

    final resendAfter = (args['resendAfter'] is int) ? args['resendAfter'] as int : 60;
    final passedDev   = (args['devOtp'] as String?)?.trim() ?? '';

    if (passedDev.isNotEmpty) _setDevOtp(passedDev); // ✅ show DEV OTP if backend already sent it
    if (_cooldown == 0 && resendAfter > 0) _startCooldown(resendAfter);

    if (kDebugMode) {
      final expiresIn = (args['expiresIn'] is int) ? args['expiresIn'] as int : 300;
      debugPrint('OTP args: mode=$mode email=$email first=$firstName last=$lastName '
          'phone=$phoneCode$phone expiresIn=$expiresIn resendAfter=$resendAfter devOtp=$_devOtpHint');
    }

    // ❌ DO NOT auto-call resend here
  }

  // ---------------- actions ----------------
  Future<void> _verifyOtp() async {
    if (_isVerifying) return;

    // Basic form + format validation
    if (!_formKey.currentState!.validate()) return;
    final raw = otpController.text.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(raw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 4-digit code.')),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final sw = Stopwatch()..start();

    try {
      final otp = raw;
      final normalizedEmail = email.trim().toLowerCase();

      // Ensure there is no stale local session
      try { await SecureStorage.signOutLocal(); } catch (_) {}

      // Step 1: verify OTP → returns a short-lived token (for register/reset flow)
      final verifyToken = await ApiService
          .verifyOtp(email: normalizedEmail, otp: otp)
          .timeout(const Duration(seconds: 180));

      if (!mounted) return;

      if (mode == 'register') {
        // Step 2: complete registration on server (don’t log the user in)
        try {
          await ApiService.completeRegistration(
            name: (name.isNotEmpty ? name : '$firstName $lastName').trim(),
            firstName: firstName,
            lastName:  lastName,
            email: normalizedEmail,
            password: password,
            token: verifyToken,
            phoneCountryCode: phoneCode.isEmpty ? null : phoneCode,
            phone:            phone.isEmpty     ? null : phone,
          );
        } catch (e) {
          // If backend says "already completed/verified", proceed to Login anyway.
          debugPrint('completeRegistration warning: $e');
        }

        // Cache minimal identity for later screens (no token = not logged in)
        try {
          if (firstName.isNotEmpty) await SecureStorage.write('user_first_name', firstName);
          if (lastName.isNotEmpty)  await SecureStorage.write('user_last_name',  lastName);
          final full = (name.isNotEmpty ? name : '$firstName $lastName').trim();
          if (full.isNotEmpty)      await SecureStorage.write('user_name', full);
          await SecureStorage.write('user_email', normalizedEmail);
        } catch (e) {
          debugPrint('SecureStorage write failed: $e');
        }

        // Success UX + navigate to Login (email pre-filled) and clear history
        await HapticFeedback.lightImpact();
        // Success UX + navigate to Login (email pre-filled) and clear history
        await HapticFeedback.lightImpact();
        if (!mounted) return;

// Use rootNavigator to escape any nested navigators.
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginDemo(initialEmail: normalizedEmail)),
              (route) => false,
        );
        return;

      }

      // ===== Reset-password flow =====
      final hasToken = (verifyToken is String) && verifyToken.isNotEmpty;
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        '/reset-password',
        arguments: hasToken
            ? {'email': normalizedEmail, 'token': verifyToken}
            : {'email': normalizedEmail},
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification timed out. Check network/API and try again.')),
      );
    } catch (e) {
      if (!mounted) return;
      final low = e.toString().toLowerCase();
      String msg;
      if (low.contains('expired')) {
        msg = 'Your code has expired. Tap “Resend” to get a new one.';
      } else if (low.contains('invalid') || low.contains('mismatch')) {
        msg = 'Incorrect code. Please try again.';
      } else if (low.contains('too many') || low.contains('429') || low.contains('throttle')) {
        msg = 'Too many attempts. Please wait a minute and try again.';
      } else {
        msg = e.toString().isNotEmpty ? e.toString() : 'Invalid or expired OTP.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
        debugPrint('verifyOtp completed in ${sw.elapsed}');
      }
    }
  }


  Future<void> _resendOtp() async {
    if (_isResending || _cooldown > 0 || email.isEmpty) return;

    setState(() => _isResending = true);
    try {
      Map<String, dynamic> res = const {};

      if (mode == 'register') {
        res = await ApiService.resendOtp(email: email).timeout(const Duration(seconds: 200));
      } else {
        final ok = await ApiService.forgotPassword(email).timeout(const Duration(seconds: 200));
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

      final devOtp = ((res['otp'] ?? '') as String).trim();
      if (devOtp.isNotEmpty && kDebugMode) {
        _setDevOtp(devOtp);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('DEV OTP: $devOtp')));
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

                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (!RegExp(r'^\d{4}$').hasMatch(s)) return 'Enter the 4-digit code';
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (value) {
                    if (value.length == 4 && !_isVerifying) {
                      FocusScope.of(context).unfocus();
                      // _verifyOtp(); // enable auto-submit if desired
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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

                const SizedBox(height: 16),

// 🔗 Login link
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      children: [
                        const TextSpan(text: 'Already verified? '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: TextButton(
                            onPressed: () {
                              final prefEmail = email.trim().toLowerCase();
                              // Use rootNavigator to avoid nested navigator issues
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) => LoginDemo(initialEmail: prefEmail),
                                ),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
