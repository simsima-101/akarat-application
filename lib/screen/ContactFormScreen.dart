import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Open this from anywhere:
/// showEmailAgentDialog(context,
///   subtitle: 'Low Floor | Ready to Move-in | Available October 2025',
///   initialMessage: 'Hi, I found your property with ref: P20250910-RPQY on Akarat. Please contact me. Thank you.',
/// );
Future<void> showEmailAgentDialog(
    BuildContext context, {
      required String subtitle,
      String? initialMessage,
    }) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _EmailAgentDialog(),
    // Use Inherited to pass arguments down
    routeSettings: RouteSettings(arguments: {
      'subtitle': subtitle,
      'initialMessage': initialMessage,
    }),
  );
}

class _EmailAgentDialog extends StatefulWidget {
  const _EmailAgentDialog();

  @override
  State<_EmailAgentDialog> createState() => _EmailAgentDialogState();
}

class _EmailAgentDialogState extends State<_EmailAgentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String? initial = args['initialMessage'] as String?;
    if ((_msgCtrl.text.isEmpty) && initial != null) {
      _msgCtrl.text = initial;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  // ====== Validators ======
  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final re = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    return re.hasMatch(v.trim()) ? null : 'Enter a valid email';
  }
  String? _phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final re = RegExp(r'^\d{7,15}$');
    return re.hasMatch(v.trim()) ? null : 'Digits only (7–15)';
  }

  // ====== Mail sender ======
  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = '+971 ${_phoneCtrl.text.trim()}';
    final msg = _msgCtrl.text.trim();

    final body = '''
Name: $name
Email: $email
Phone: $phone

Message:
$msg
''';

    final uri = Uri(
      scheme: 'mailto',
      path: 'info@akarat.com',
      queryParameters: {
        'subject': 'Property Inquiry from $name',
        'body': body,
      },
    );

    final can = await canLaunchUrl(uri);
    if (can) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) Navigator.pop(context); // close dialog on success
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Email not available', style: TextStyle(color: Colors.black)),
          content: const Text(
            'No email app is configured on this device. Please add a mail account first.',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );

  Widget _uaePrefixChip() {
    // Small rounded block with 🇦🇪 and +971 like the mock
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('🇦🇪', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Text('+971', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _phoneField() {
    // Composite control to visually look like a single field
    return Row(
      children: [
        _uaePrefixChip(),
        Expanded(
          child: Container(
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(18)),
            ),
            child: TextFormField(
              controller: _phoneCtrl,
              validator: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              decoration: const InputDecoration(
                hintText: 'Phone',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(18)),
                  borderSide: BorderSide(color: Color(0xFFE6E6E6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(18)),
                  borderSide: BorderSide(color: Color(0xFFE6E6E6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(18)),
                  borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final subtitle = (args['subtitle'] as String?) ?? '';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 30, spreadRadius: 0, offset: Offset(0, 12),
                  color: Color(0x1A000000),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title row with close X
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            'Email agent',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.red, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subtitle,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Fields
                    TextFormField(
                      controller: _nameCtrl,
                      validator: _req,
                      textInputAction: TextInputAction.next,
                      decoration: _input('Name'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailCtrl,
                      validator: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _input('Email'),
                    ),
                    const SizedBox(height: 14),
                    _phoneField(),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _msgCtrl,
                      validator: _req,
                      minLines: 4,
                      maxLines: 6,
                      decoration: _input(
                        'Hi, I found your property with ref: P20250910-RPQY on Akarat. '
                            'Please contact me. Thank you.',
                      ),
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 20),

                    // Gradient button
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFFF2D2D), Color(0xFFFF9AA2)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ElevatedButton(
                          onPressed: _send,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Send Email',
                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
