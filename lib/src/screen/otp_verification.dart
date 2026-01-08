import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../core/utils/secure_storage.dart';
import '../core/services/api_service.dart';
import '../core/utils/session_manager.dart';
import 'home.dart';
import 'login.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isVerifying = false;
  bool _isResending = false;
  int _cooldown = 0;
  bool _inited = false;

  // Flow args
  String mode = 'register';
  String email = '';
  String name = '';
  String password = '';
  String firstName = '';
  String lastName = '';
  String phoneCode = '';
  String phone = '';
  String? _devOtpHint;

  String _provisionalTokenFromArgs = '';

  final otp1Controller = TextEditingController();
  final otp2Controller = TextEditingController();
  final otp3Controller = TextEditingController();
  final otp4Controller = TextEditingController();



  // ---- helpers ----
  ({String first, String last}) _splitName(String full) {
    final parts = full.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return (first: '', last: '');
    if (parts.length == 1) return (first: parts.first, last: '');
    return (first: parts.first, last: parts.sublist(1).join(' '));
  }

  String? _extractTokenFromAny(Map<String, dynamic> m) {
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

  // ---- cooldown ----
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

  // ---- lifecycle ----
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    final raw = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> args =
    (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    email = (args['email'] as String?)?.trim().toLowerCase() ?? '';
    mode = (args['mode'] as String?) == 'reset' ? 'reset' : 'register';
    name = (args['name'] as String?)?.trim() ?? '';
    password = (args['password'] as String?)?.trim() ?? '';
    firstName = (args['firstName'] as String?)?.trim() ?? '';
    lastName = (args['lastName'] as String?)?.trim() ?? '';
    phone = (args['phone'] as String?)?.trim() ?? '';
    phoneCode = (args['phoneCode'] as String?)?.trim() ?? '';
    _provisionalTokenFromArgs = (args['token'] as String?)?.trim() ?? '';

    final resendAfter = (args['resendAfter'] is int) ? args['resendAfter'] as int : 60;
    final passedDev = (args['devOtp'] as String?)?.trim() ?? '';
    if (passedDev.isNotEmpty) _devOtpHint = passedDev;
    if (_cooldown == 0 && resendAfter > 0) _startCooldown(resendAfter);

    if (kDebugMode) {
      final expiresIn = (args['expiresIn'] is int) ? args['expiresIn'] as int : 300;
      debugPrint(
        'OTP args: mode=$mode email=$email first=$firstName last=$lastName '
            'phone=$phoneCode$phone expiresIn=$expiresIn '
            'resendAfter=$resendAfter devOtp=$_devOtpHint tokenFromArgs=${_provisionalTokenFromArgs.isNotEmpty}',
      );
    }
  }

  // ---- verify OTP ----
  Future<void> _verifyOtp() async {
    if (_isVerifying) return;

    // Collect OTP from the 4 separate input boxes
    final String otp =
        otp1Controller.text.trim() +
            otp2Controller.text.trim() +
            otp3Controller.text.trim() +
            otp4Controller.text.trim();

    // Validate: Must be exactly 4 digits
    if (otp.length != 4 || !RegExp(r'^\d{4}$').hasMatch(otp)) {
      _err('Please enter a valid 4-digit code');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final resp = await ApiService.verifyOtp(email: email, otp: otp)
          .timeout(const Duration(seconds: 180));

      final int code = resp['__status'] as int? ?? 500;

      if (code == 200) {
        await HapticFeedback.lightImpact();

        final Map<String, dynamic> body = (resp['__raw'] is Map<String, dynamic>)
            ? (resp['__raw'] as Map<String, dynamic>)
            : <String, dynamic>{};

        String? token = _extractTokenFromAny(body);
        token ??= _provisionalTokenFromArgs.isNotEmpty ? _provisionalTokenFromArgs : null;

        // Extract name/email if backend provided
        String fullName = ((body['user'] ?? body['name']) ?? '').toString().trim();
        String emailFromApi = (body['email'] ?? '').toString().trim();

        if (fullName.isEmpty) {
          if (firstName.isNotEmpty || lastName.isNotEmpty) {
            fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
          } else if (name.isNotEmpty) {
            fullName = name;
          } else if (email.isNotEmpty) {
            fullName = email.split('@').first;
          }
        }

        if (emailFromApi.isEmpty) emailFromApi = email;

        // Persist user identity
        if ((token ?? '').isNotEmpty) {
          await SecureStorage.setToken(token!);
          await SecureStorage.setUserProfile(
            name: fullName,
            email: emailFromApi,
            firstName: firstName,
            lastName: lastName,
          );

          SessionManager().setAuth(
            token: token!,
            userName: fullName,
            userEmail: emailFromApi,
            firstName: firstName,
            lastName: lastName,
          );

          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const Home()),
                (_) => false,
          );
          return;
        }

        // If no token, redirect to login
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginDemo(initialEmail: email)),
              (_) => false,
        );
      } else {
        _err(resp['message']?.toString() ?? 'Invalid or expired OTP.');
      }
    } on TimeoutException {
      _err('Verification timed out. Please try again.');
    } catch (e) {
      final txt = e.toString().toLowerCase();
      if (txt.contains('expired')) {
        _err('Your code has expired. Tap “Resend” to get a new one.');
      } else if (txt.contains('invalid') || txt.contains('mismatch')) {
        _err('Incorrect code. Please try again.');
      } else if (txt.contains('429') || txt.contains('too many')) {
        _err('Too many attempts. Please wait and try again.');
      } else {
        _err(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending || _cooldown > 0 || email.isEmpty) return;

    setState(() => _isResending = true);
    try {
      final ok = await ApiService.resendOtp(email: email);
      if (ok) {
        _startCooldown(60);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('We’ve sent a new code.')),
          );
        }
      } else {
        _err('Could not resend code. Try again soon.');
      }
    } catch (e) {
      _err(e.toString());
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _err(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  void dispose() {

    otpController.dispose();
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resendLabel =
    _cooldown > 0 ? 'Resend in $_cooldown s' : "Didn't receive the code? Resend";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Verify OTP'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black),

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

                if (kDebugMode && (_devOtpHint?.isNotEmpty ?? false))
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFC7BC)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.bug_report, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'DEV OTP: ${_devOtpHint!}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, color: Colors.red),
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
                    ]),
                  ),

                // 4-Box OTP Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 64,
                      height: 64,
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.length == 1) {
                            // Move to next field
                            if (index < 3) {
                              FocusScope.of(context).nextFocus();
                            } else {
                              FocusScope.of(context).unfocus(); // Hide keyboard on last digit
                            }
                          } else if (value.isEmpty) {
                            // Move back if deleted
                            if (index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          }
                        },
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 20),
                          counterText: '', // Hide character counter
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.black, width: 2.5), // Red when focused
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.black, width: 2),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // White background
                      foregroundColor: Colors.black, // Text/icon color
                      elevation: 2, // Slight shadow for depth
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18), // Adjust radius as needed
                        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1), // Light border
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                      ),
                    )
                        : const Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
                        : Text(resendLabel,
                        style: const TextStyle(color: Colors.blueAccent)),
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
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => LoginDemo(initialEmail: email))),
                    child: const Text(
                      'Already verified? Login',
                      style: TextStyle(decoration: TextDecoration.underline),
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
