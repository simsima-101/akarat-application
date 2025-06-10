import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({Key? key, required this.email, required this.token}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  Future<void> _submitResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('https://akarat.com/api/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": widget.email,
          "token": widget.token,
          "password": passwordController.text.trim(),
          "password_confirmation": confirmPasswordController.text.trim(),
        }),
      );

      setState(() => _isSubmitting = false);

      final data = jsonDecode(response.body);
      final success = (response.statusCode == 200) &&
          (data['success'] == true || data['status'] == 'success');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Password reset successful!'
              : (data['message'] ?? 'Failed to reset password.')),
        ),
      );

      if (success) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    print('ResetPasswordScreen loaded with email: ${widget.email}, token: ${widget.token}');
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: screenSize.width * 0.85,
                decoration: _boxDecoration(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  obscureText: obscurePassword,
                  validator: (value) =>
                  value == null || value.length < 6 ? 'Password too short' : null,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: screenSize.width * 0.85,
                decoration: _boxDecoration(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Confirm New Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                    ),
                  ),
                  obscureText: obscureConfirmPassword,
                  validator: (value) =>
                  value != passwordController.text ? 'Passwords do not match' : null,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitResetPassword,
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Reset Password'),
                ),
              ),

              // Back to Login Button
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton.icon(
                  icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  label: const Text(
                    'Back to Login',
                    style: TextStyle(
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
      ),
    );
  }
}