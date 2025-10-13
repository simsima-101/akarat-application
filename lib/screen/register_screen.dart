import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Akarat/services/api_service.dart';

import 'home.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  final firstController = TextEditingController();
  final lastController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  // Form + state
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hidePwd = true;
  bool _hideConfirm = true;
  bool _agree = false;

  // Password rules
  bool get _ruleLen => passwordController.text.trim().length >= 8;
  bool get _ruleUpper => RegExp(r'[A-Z]').hasMatch(passwordController.text);
  bool get _ruleNum => RegExp(r'\d').hasMatch(passwordController.text);
  bool get _ruleSpecial =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\]=;+`~]').hasMatch(passwordController.text);

  // Styles
  OutlineInputBorder get _fieldBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: Color(0xFFE9E9E9)),
  );

  InputDecoration _dec(String hint, {Widget? prefix, Widget? suffix}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: _fieldBorder,
    focusedBorder: _fieldBorder.copyWith(borderSide: const BorderSide(color: Color(0xFFDADADA))),
    prefixIconConstraints: const BoxConstraints(minWidth: 0),
    prefixIcon: prefix != null
        ? Padding(padding: const EdgeInsets.only(left: 12, right: 8), child: prefix)
        : null,
    suffixIcon: suffix,
  );

  LinearGradient get _cardGradient => const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFE2E0), Colors.white],
  );

  LinearGradient get _ctaGradient => const LinearGradient(
    colors: [Color(0xFFFF4C4C), Color(0xFFFF9A9A)],
  );

  // ---------- SUBMIT ----------

  Future<void> _submit() async {
    ApiService.debugPrintBaseUrl();

    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms and Conditions')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final first = firstController.text.trim();
    final last  = lastController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final phone = phoneController.text.trim();
    const phoneCode = '971';
    final pwd   = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    bool _isInt(v) => v is int;
    int _asInt(dynamic v, int fallback) => _isInt(v) ? (v as int) : fallback;

    try {
      // 1) Create user — backend should also generate+store OTP here
      final reg = await ApiService.registerStart(
        firstName: first,
        lastName:  last,
        email: email,
        phoneCountryCode: phoneCode,
        phone: phone,
        password: pwd,
        passwordConfirmation: confirm,
      );
      debugPrint('REGISTER RESP: $reg');

      // 2) DO NOT resend here — this used to overwrite the first OTP

      // timers from server if present
      final expiresIn   = _asInt(reg['expires_in'], 300);
      final resendAfter = _asInt(reg['resend_after'], 60);

      // surface DEV OTP if backend returns it (dev only)
      final devOtp = ((reg['otp'])?.toString() ?? '').trim();
      if (devOtp.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('DEV OTP: $devOtp')));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent. Please check your email.')),
      );

      // 3) Go to Verify OTP
      Navigator.of(context, rootNavigator: true).pushNamed(
        '/verify-otp',
        arguments: {
          'mode': 'register',
          'name': '$first $last',
          'email': email,
          'password': pwd,
          'phone': '$phoneCode$phone',
          'expiresIn': expiresIn,
          'resendAfter': resendAfter,
        },
      );
    } catch (e) {
      if (!mounted) return;
      String friendly = e.toString();
      final low = friendly.toLowerCase();
      if (low.contains('already been taken') || low.contains('already exists') || low.contains('conflict')) {
        friendly = 'This email is already registered. Please Login or use Forgot Password.';
      } else if (low.contains('too many') || low.contains('throttle') || low.contains('rate limit')) {
        friendly = 'Too many attempts. Please wait a minute and try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendly)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Future<void> _submit() async {
  //   ApiService.debugPrintBaseUrl();
  //
  //   if (!_formKey.currentState!.validate()) return;
  //   if (!_agree) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please agree to the Terms and Conditions')),
  //     );
  //     return;
  //   }
  //
  //   FocusScope.of(context).unfocus();
  //   setState(() => _isLoading = true);
  //
  //   final first = firstController.text.trim();
  //   final last  = lastController.text.trim();
  //   final email = emailController.text.trim().toLowerCase();
  //   final phone = phoneController.text.trim();
  //   const phoneCode = '971';
  //   final pwd   = passwordController.text.trim();
  //   final confirm = confirmController.text.trim();
  //
  //   // tiny helpers
  //   bool _isInt(v) => v is int;
  //   int _asInt(dynamic v, int fallback) => _isInt(v) ? (v as int) : fallback;
  //
  //   try {
  //     // 1) Hit /api/register (create/validate user)
  //     final reg = await ApiService.registerStart(
  //       firstName: first,
  //       lastName:  last,
  //       email: email,
  //       phoneCountryCode: phoneCode,
  //       phone: phone,
  //       password: pwd,
  //       passwordConfirmation: confirm,
  //     );
  //     debugPrint('REGISTER RESP: $reg');
  //
  //     // IMPORTANT: Ignore any token returned by /register for the register flow.
  //     // We ALWAYS go through OTP to verify the email/owner.
  //     // (Do NOT early-return to /home even if reg['token'] exists.)
  //
  //     // 2) Force an OTP send (Mailtrap in local, real email otherwise)
  //     Map<String, dynamic> otpMeta = const {};
  //     try {
  //       otpMeta = await ApiService.resendOtp(email: email);
  //       debugPrint('RESEND OTP RESP: $otpMeta');
  //     } catch (e) {
  //       // If resend endpoint fails, still try to continue if backend already sent one
  //       debugPrint('RESEND OTP failed: $e');
  //     }
  //
  //     // prefer server-provided timers; fall back to sane defaults
  //     final expiresIn   = _asInt(otpMeta['expires_in'] ?? reg['expires_in'], 300);
  //     final resendAfter = _asInt(otpMeta['resend_after'] ?? reg['resend_after'], 60);
  //
  //     // surface DEV OTP if backend returns it in local env
  //     final devOtp = ((otpMeta['otp'] ?? reg['otp'])?.toString() ?? '').trim();
  //     if (devOtp.isNotEmpty && mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('DEV OTP: $devOtp')));
  //     }
  //
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('OTP sent. Please check your email.')),
  //     );
  //
  //     // 3) Navigate to Verify OTP (always)
  //     Navigator.of(context, rootNavigator: true).pushNamed(
  //       '/verify-otp',
  //       arguments: {
  //         'mode': 'register',
  //         'name': '$first $last',
  //         'email': email,
  //         'password': pwd,
  //         'phone': '$phoneCode$phone',
  //         'expiresIn': expiresIn,
  //         'resendAfter': resendAfter,
  //       },
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     String friendly = e.toString();
  //     final low = friendly.toLowerCase();
  //     if (low.contains('already been taken') || low.contains('already exists') || low.contains('conflict')) {
  //       friendly = 'This email is already registered. Please Login or use Forgot Password.';
  //     } else if (low.contains('too many') || low.contains('throttle') || low.contains('rate limit')) {
  //       friendly = 'Too many attempts. Please wait a minute and try again.';
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendly)));
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }
  // ---------- /SUBMIT ----------

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() => setState(() {}));
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

  @override
  Widget build(BuildContext context) {
    final maxW = 380.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      gradient: _cardGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2A000000),
                          offset: Offset(0, 8),
                          blurRadius: 18,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: _buildFormContent(context),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Home()),
                      ),
                      child: const Icon(Icons.close, color: Colors.red, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Create Your Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),

        SizedBox(
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2))],
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google.png',
                    height: 22,
                    width: 22,
                    errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 28),
                  ),
                  const SizedBox(width: 8),
                  const Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),
        Row(
          children: const [
            Expanded(child: Divider(color: Color(0xFFE3E3E3))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('OR', style: TextStyle(color: Color(0xFF6B6B6B))),
            ),
            Expanded(child: Divider(color: Color(0xFFE3E3E3))),
          ],
        ),
        const SizedBox(height: 16),

        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: firstController,
                textInputAction: TextInputAction.next,
                decoration: _dec('First Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter first name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: lastController,
                textInputAction: TextInputAction.next,
                decoration: _dec('Last Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter last name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _dec('E-mail'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter email';
                  if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) return 'Invalid email';
                  return null;
                },
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('🇦🇪', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text('+971', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _dec('Phone'),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'Please enter phone';
                        if (!RegExp(r'^[0-9]{7,12}$').hasMatch(s)) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
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
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Please enter password';
                  if (!(_ruleLen && _ruleUpper && _ruleNum && _ruleSpecial)) {
                    return 'Password doesn’t meet requirements';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),
              _ruleRow(_ruleLen, 'At least 8 characters'),
              _ruleRow(_ruleUpper, 'One uppercase letter'),
              _ruleRow(_ruleNum, 'One number'),
              _ruleRow(_ruleSpecial, 'One special character'),
              const SizedBox(height: 12),

              TextFormField(
                controller: confirmController,
                obscureText: _hideConfirm,
                decoration: _dec(
                  'Confirm Password',
                  suffix: IconButton(
                    onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                    icon: Icon(_hideConfirm ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Please confirm password';
                  if (s != passwordController.text.trim()) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              FormField<bool>(
                initialValue: _agree,
                validator: (v) => (v ?? false) ? null : 'Please agree to the Terms and Conditions',
                builder: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: state.value ?? false,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          onChanged: (v) {
                            setState(() => _agree = v ?? false);
                            state.didChange(v);
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black, fontSize: 16),
                              children: [
                                const TextSpan(text: 'I agree '),
                                TextSpan(
                                  text: 'Terms and conditions',
                                  style: const TextStyle(
                                    color: Color(0xFF2F6FE4),
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()..onTap = () {/* open T&C */},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: w > 380 ? 320 : double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: _ctaGradient, borderRadius: BorderRadius.circular(18)),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  const Text('Already have an account?  ', style: TextStyle(color: Color(0xFF616161), fontSize: 16)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginDemo())),
                    child: const Text('Login Here',
                        style: TextStyle(
                          color: Color(0xFF2F6FE4),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ruleRow(bool ok, String text) => Row(
    children: [
      Icon(ok ? Icons.check_circle : Icons.circle, size: 14, color: ok ? Colors.green : Colors.red),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 13.5)),
    ],
  );
}
