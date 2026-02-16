import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  Future<void> _submitForgotPassword() async {

    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final email = emailController.text.trim();
    try {
      // final response = await http.post(
      //   ApiService.buildUri('forgot-password'),
      //   headers: {
      //     'Accept': 'application/json',
      //     'Content-Type': 'application/json; charset=UTF-8',
      //     'X-Requested-With': 'XMLHttpRequest',
      //   },
      //   body: jsonEncode({
      //     'email': email,
      //   }),
      // );

      final response = await ApiService.post(
        'forgot-password',
        body: {
          'email': email,
        },
      );

      final responseData = jsonDecode(response.body);
      setState(() => _isSubmitting = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  responseData['message'] ?? l10n.resetEmailSent)),
        );
        await Future.delayed(const Duration(seconds: 2));
        print('Navigating to /verify-otp with email: $email');
        Navigator.pushNamed(
          context,
          '/verify-otp',
          arguments: {'email': email},
        );
        print('Navigator.pushNamed called');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  responseData['message'] ?? l10n.failedToSendResetEmail)),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.somethingWentWrong)),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Icon
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Center(
                child: SizedBox(
                  width: 150,
                  height: 55,
                  child: Image.asset('assets/images/app_icon.png'),
                ),
              ),
            ),
            // Logo Text
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Center(
                child: SizedBox(
                  width: 150,
                  height: 40,
                  child: Image.asset('assets/images/logo-text.png'),
                ),
              ),
            ),
            // Form Container
            Padding(
              padding: const EdgeInsets.only(top: 25.0, left: 20, right: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: const Color(0xFFF5F5F5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 0.1,
                            spreadRadius: 0.1,
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.forgotPasswordTitle,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.forgotPasswordSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 28),
                          // Email Field
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: l10n.emailLabel,
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.emailRequired;
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return l10n.invalidEmailFormat;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed:
                                  _isSubmitting ? null : _submitForgotPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                disabledBackgroundColor: Colors.blue.shade200,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      l10n.submitButton,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          // Back to Login Button
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: TextButton.icon(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black54),
                              label: Text(
                                l10n.backToLogin,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
