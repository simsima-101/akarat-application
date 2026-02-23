// lib/screen/ContactFormScreen.dart

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_country_data/intl_country_data.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../core/services/api_service.dart';

typedef EmailAgentSubmitCallback = Future<void> Function({
  required String name,
  required String email,
  required String phone,
  required String message,
});

/// Open from anywhere
Future<void> showEmailAgentDialog(
  BuildContext context, {
  String subtitle = '',
  String? initialMessage,
  String? initialPhone,
  EmailAgentSubmitCallback? onSubmit,
  VoidCallback? onSuccess,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _EmailAgentDialog(),
    routeSettings: RouteSettings(arguments: {
      'subtitle': subtitle,
      'initialMessage': initialMessage,
      'initialPhone': initialPhone,
      'onSubmit': onSubmit,
      'onSuccess': onSuccess,
    }),
  );
}

/// HOME CONTACT FORM – Sends to your real API (WORKS 100%)
Future<void> showHomeContactDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final bool? success = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _EmailAgentDialog(),
    routeSettings: RouteSettings(arguments: {
      'subtitle': l10n.weWillGetBackSoon,
      'onSubmit': ({
        required String name,
        required String email,
        required String phone,
        required String message,
      }) async {
        try {
          // final response = await http.post(
          //   ApiService.buildUri('contact-akarat'),
          //   headers: {
          //     "Accept": "application/json",
          //     "X-Device-ID": "8B368203-14FE-47F6-98C8-9933CB0AE73D",
          //     "Authorization": "Bearer 1092|fsHg2fMib653xIThnBMHMgtzl8Q7rILysRpFJbrb",
          //   },
          //   body: jsonEncode({
          //     "name": name.trim(),
          //     "email": email.trim(),
          //     "phone": phone.trim(),
          //     "message": message.trim(),
          //   }),
          // );

          final response = await ApiService.post(
            'contact-akarat',
            body: {
              "name": name.trim(),
              "email": email.trim(),
              "phone": phone.trim(),
              "message": message.trim(),
            },
            headers: {
              "X-Device-ID": "8B368203-14FE-47F6-98C8-9933CB0AE73D",
              "Authorization":
                  "Bearer 1092|fsHg2fMib653xIThnBMHMgtzl8Q7rILysRpFJbrb",
            },
          ).timeout(const Duration(seconds: 25)); // optional but recommended

          if (response.statusCode == 200 || response.statusCode == 201) {
            return; // success
          } else {
            throw Exception(
              "Contact form failed: ${response.statusCode} - ${response.body}",
            );
          }
        } catch (e) {
          debugPrint("Contact API error: $e");
          rethrow; // or handle error as needed in your UI
        }
      },
    }),
  );

  // Show result AFTER dialog closes
  if (success == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(l10n.thankYouMessageSent),
          backgroundColor: Colors.green),
    );
  } else if (success == false) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(l10n.failedToSend),
          backgroundColor: Colors.red),
    );
  }
}

/// Opens email app only (no backend)
Future<void> showBlankEmailDialog(BuildContext context) async {
  await showEmailAgentDialog(context);
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

  String selectedCountryCode = "+971"; // default UAE
  int _maxPhoneLength = 9;

  EmailAgentSubmitCallback? _externalSubmit;
  VoidCallback? _onSuccess;
  String _subtitle = '';

  @override
  void didChangeDependencies() {

    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    _subtitle = args['subtitle'] as String? ?? '';
    final initialMsg = args['initialMessage'] as String?;
    final initialPhone = args['initialPhone'] as String?;

    _externalSubmit = args['onSubmit'] as EmailAgentSubmitCallback?;
    _onSuccess = args['onSuccess'] as VoidCallback?;

    if (_msgCtrl.text.isEmpty && initialMsg != null) _msgCtrl.text = initialMsg;
    if (_phoneCtrl.text.isEmpty && initialPhone != null)
      _phoneCtrl.text = initialPhone;
  }

  @override
  void dispose() {


    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }



  String? _req(String? v) {
    final l10n = AppLocalizations.of(context)!;
    return (v == null || v.trim().isEmpty) ? l10n.requiredField : null;
  }

  String? _email(String? v) {
    final l10n = AppLocalizations.of(context)!;
    if (v == null || v.trim().isEmpty) return l10n.requiredField;

    final trimmed = v.trim();
    return RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(trimmed)
        ? null
        : l10n.invalidEmail;
  }

  String? _phone(String? v) {
    final l10n = AppLocalizations.of(context)!;
    final input = v?.trim() ?? '';

    if (v == null || input.isEmpty) return l10n.requiredField;

    // Check length based on selected country
    if (input.length != _maxPhoneLength) {
      return 'Phone number must be $_maxPhoneLength digits for ${selectedCountryCode}';
    }

    return RegExp(r'^\d{7,15}$').hasMatch(input) ? null : l10n.phoneDigitsOnly;
  }

  /// MAIN SEND METHOD – NOW 100% WORKING
  /// MAIN SEND METHOD – NOW 100% WORKING
  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    // IMPORTANT: get l10n FIRST - before any usage
    final l10n = AppLocalizations.of(context)!;

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final localPhone = _phoneCtrl.text.trim();
    final fullPhone = '$selectedCountryCode$localPhone'; // usually better without space
    final msg = _msgCtrl.text.trim();

    // 1. Custom backend (Home contact form)
    if (_externalSubmit != null) {
      try {
        await _externalSubmit!(
          name: name,
          email: email,
          phone: localPhone,
          message: msg,
        );
        if (!mounted) return;
        Navigator.of(context).pop(true); // Success
        return;
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop(false); // Failure
        return;
      }
    }

    // 2. Fallback - open email client
    final uri = Uri(
      scheme: 'mailto',
      path: 'info@akarat.com',
      queryParameters: {
        'subject': 'Inquiry from $name',
        'body': 'Name: $name\nEmail: $email\nPhone: $fullPhone\n\nMessage:\n$msg',
      },
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.noEmailApp),
            content: Text(l10n.installEmailApp),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok ?? 'OK'), // fallback if neot translated
              ),
            ],
          ),
        );
        return;
      }

      // Small delay helps prevent black screen on some Android versions
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotOpenEmail),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        //  vertical: 18 → 10 (shorter fields)
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), // 18 → 14
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      );

  Widget _uaePrefixChip() => Container(

        height: 48, // 56 → 48
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE6E6E6)),
          borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(14)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CountryCodePicker(
          onChanged: (code) {
            setState(() {
              selectedCountryCode = code.dialCode ?? "+971";
              final intlCountry =
                  IntlCountryData.fromCountryCodeAlpha2(code.code ?? "AE");

              _phoneCtrl.clear();

              _maxPhoneLength = intlCountry.telephoneMaxLength;
            });
          },
          initialSelection: 'AE', // UAE default
          favorite: const [],
          showDropDownButton: false,
          showCountryOnly: false,
          showOnlyCountryWhenClosed: false,
          alignLeft: false,
          margin: EdgeInsetsGeometry.only(left: 0, right: 8),
          padding: EdgeInsetsGeometry.all(0),
          headerTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          closeIcon: Icon(
            Icons.close,
            size: 25,
          ),
          dialogSize: Size(double.infinity, 700),

          searchDecoration: InputDecoration(
            hintText: 'Search country',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          dialogItemPadding:
              EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 13),
          // topBarPadding: EdgeInsets.only(bottom: 20),
          searchPadding:
              EdgeInsetsGeometry.only(bottom: 10, left: 10, right: 10),
        ),
      );

  Widget _phoneField() {
    final l10n = AppLocalizations.of(context)!;   // ← add this line

    return Row(


        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _uaePrefixChip(),
          Expanded(

            child: TextFormField(
              controller: _phoneCtrl,
              validator: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: _maxPhoneLength ??
                  9, // Fallback default if no country selected

                decoration: _input(l10n.phone).copyWith(
                  counterText: '',
                  border: const OutlineInputBorder(
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFFE6E6E6)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFFE6E6E6)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
                ),
              ),
            ),
          ),
        ],
      );
    }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      // More padding from the screen edges (dialog looks smaller)
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        // Reduce width from 560 → 420
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          // Reduce internal padding a bit
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                blurRadius: 24,
                offset: Offset(0, 10),
                color: Color(0x1A000000),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.emailAgent,
                        style: const TextStyle(
                          fontSize: 20, // 24 → 20
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child:
                          const Icon(Icons.close, color: Colors.red, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_subtitle.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _subtitle,
                      style: const TextStyle(
                        fontSize: 14, // 16 → 14
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),

                // Name
                TextFormField(
                  controller: _nameCtrl,
                  validator: _req,
                  decoration: _input(l10n.name),
                ),
                const SizedBox(height: 10),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  validator: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _input(l10n.email),
                ),
                const SizedBox(height: 10),

                // Phone
                _phoneField(),
                const SizedBox(height: 10),

                // Message
                TextFormField(
                  controller: _msgCtrl,
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? l10n.messageRequired : null,
                  minLines: 3, // 5 → 3 (shorter)
                  maxLines: 6, // 8 → 6
                  decoration: _input(l10n.writeYourMessageHere).copyWith(
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Send button – solid red
                SizedBox(

                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2D2D), // solid red
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(

                      l10n.sendEmail,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
