import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl_country_data/intl_country_data.dart';

import '../../l10n/app_localizations.dart';
import '../core/services/api_service.dart';
import '../core/utils/secure_storage.dart';
import '../features/property/data/datasources/favorite_remote_datasource.dart';
import '../utils/fav_logout.dart';
import '../utils/shared_preference_manager.dart';
import 'ContactFormScreen.dart';
import 'home.dart';
import 'login.dart';
import 'my_account.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  String selectedCountryCode = "+971"; // default UAE

  int _maxPhoneLength = 9;

  bool _isLoading = false;

  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;
  int pageIndex = 0;

  final SharedPreferencesManager prefManager = SharedPreferencesManager();

  @override
  void initState() {
    super.initState();
    readData();
  }

  Future<void> readData() async {
    token = await prefManager.readStringFromPref();
    email = await prefManager.readStringFromPrefemail();
    result = await prefManager.readStringFromPrefresult();
    if (mounted) {
      setState(() {
        isDataRead = true;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  // ---------------- Validators ----------------
  String? _required(String? v, String label, BuildContext context) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) {
      return AppLocalizations.of(context)!
          .myAccountSupportValidationRequired(label);
    }
    return null;
  }

  String? _validateEmail(String? v, BuildContext context) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) {
      return AppLocalizations.of(context)!
          .myAccountSupportValidationEmailRequired;
    }

    final re = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!re.hasMatch(t)) {
      return AppLocalizations.of(context)!
          .myAccountSupportValidationEmailRequired;
    }

    return null;
  }

  // ---------------- Submit ----------------
  Future<void> sendMessage() async {
    final form = _formKey.currentState;
    if (form == null) {
      debugPrint(
          'FormState is null: make sure fields are wrapped in Form(key: _formKey).');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form not ready. Please try again.')),
      );
      return;
    }
    if (!form.validate()) return;

    setState(() => _isLoading = true);

    try {
      final ok = await submitContactForm(
        name: nameController.text,
        email: emailController.text,
        phone:
            "${selectedCountryCode.replaceFirst('+', '')}${phoneController.text}",
        subject: subjectController.text,
        message: messageController.text,
      );

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );

        nameController.clear();
        emailController.clear();
        phoneController.clear();
        subjectController.clear();
        messageController.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const My_Account()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send. Please try again.')),
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out. Please try again.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validatePhone(BuildContext context, String? v) {
    final input = v?.trim() ?? '';
    final l10n = AppLocalizations.of(context)!;

    if (input.isEmpty) {
      return l10n.myAccountSupportValidationEnterPhone;
    }

    // Check if all digits
    if (!RegExp(r'^\d+$').hasMatch(input)) {
      return l10n.myAccountSupportValidationPhoneDigitsOnly;
    }

    // Check length based on selected country
    if (input.length != _maxPhoneLength) {
      return l10n.myAccountSupportValidationPhoneLength(
        _maxPhoneLength,
        selectedCountryCode,
      );
    }

    return null; // valid
  }

  static Future<bool> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) async {
    final resp = await _postForm('/contact', {
      'name': name.trim(),
      'email': _normEmail(email),
      'phone': phone.trim(),
      'subject': subject.trim(),
      'message': message.trim(),
    });
    if (kDebugMode) {
      print(
          '[POST-FORM] ${resp.request?.url} -> ${resp.statusCode} ${resp.body}');
    }
    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  static Future<http.Response> _postForm(
    String endpoint,
    Map<String, String> fields,
  ) async {
    final url = ApiService.buildUri(endpoint);
    // final resp = await http
    //     .post(url, headers: _formHeaders, body: fields)
    //     .timeout(_timeout);

    final resp = await ApiService.post(
      endpoint,
      body: fields,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    ).timeout(const Duration(seconds: 25));

    if (kDebugMode) {
      print('[POST-FORM] $url -> ${resp.statusCode} ${resp.body}');
    }
    return resp;
  }

  // --- Laravel-friendly form posts ---
  static const Map<String, String> _formHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
    'X-Requested-With': 'XMLHttpRequest',
  };

  static String _normEmail(String email) => email.trim().toLowerCase();
  static const _timeout = Duration(seconds: 25);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final appLocalization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.red),
        title: Text(
          appLocalization.myAccountSupportTitle,
          // "Contact Us",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),

      // ✅ Let content scroll naturally, no fixed heights
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalization.myAccountSupportSubTitle,
              // "Ask us anything?",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // 🔒 Wrap all fields in a Form so validators run
            Form(
              key: _formKey,
              child: Container(
                // ❌ NO fixed height here – this was causing overflow
                width: screenSize.width, // let padding manage insets
                margin: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    _label(appLocalization.myAccountSupportNameLabel),
                    _boxedField(
                      child: TextFormField(
                        controller: nameController,
                        keyboardType: TextInputType.name,
                        validator: (v) => _required(v,
                            appLocalization.myAccountSupportNameLabel, context),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    // Email
                    _label(appLocalization.myAccountSupportEmailLabel),
                    _boxedField(
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            _validateEmail(v, context), // pass context here
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    // Phone
                    _label(appLocalization.myAccountSupportPhoneLabel),
                    _boxedField(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Country Code Picker
                          CountryCodePicker(
                            onChanged: (code) {
                              setState(() {
                                selectedCountryCode = code.dialCode ?? "+971";
                                final intlCountry =
                                    IntlCountryData.fromCountryCodeAlpha2(
                                        code.code ?? "AE");

                                phoneController.clear();

                                _maxPhoneLength =
                                    intlCountry.telephoneMaxLength;
                              });
                            },

                            initialSelection: 'AE', // UAE default
                            favorite: const [],
                            showDropDownButton: false,
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            margin: EdgeInsetsGeometry.only(left: 8, right: 8),
                            padding: EdgeInsetsGeometry.all(0),
                            headerTextStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                            closeIcon: Icon(
                              Icons.close,
                              size: 25,
                            ),
                            dialogSize: Size(double.infinity, 700),

                            searchDecoration: InputDecoration(
                              hintText: appLocalization.searchCountryHint,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            dialogItemPadding: EdgeInsetsGeometry.symmetric(
                                horizontal: 12, vertical: 13),
                            // topBarPadding: EdgeInsets.only(bottom: 20),
                            searchPadding: EdgeInsetsGeometry.only(
                                bottom: 10, left: 10, right: 10),
                          ),

                          // Phone number Input
                          Expanded(
                            child: TextFormField(
                              controller: phoneController,

                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: _maxPhoneLength ??
                                  9, // Fallback default if no country selected
                              keyboardType: TextInputType.phone,
                              validator: (value) =>
                                  _validatePhone(context, value),
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Subject
                    _label(appLocalization.myAccountSupportSubjectLabel),
                    _boxedField(
                      child: TextFormField(
                        controller: subjectController,
                        keyboardType: TextInputType.text,
                        validator: (v) => _required(
                            v,
                            appLocalization.myAccountSupportSubjectLabel,
                            context),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    // Message
                    _label(appLocalization.myAccountSupportMessageLabel),
                    _boxedField(
                      child: TextFormField(
                        controller: messageController,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        validator: (v) => _required(
                            v,
                            appLocalization.myAccountSupportMessageLabel,
                            context),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height:
                          48, // ✅ fixed control height; no screenSize dependency
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                appLocalization
                                    .myAccountSupportSubmitButtonText,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _label(String text) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, top: 8, bottom: 4, right: 10.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
      ),
    );
  }

  Widget _boxedField({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.3, 0.3),
              blurRadius: 0.3,
              spreadRadius: 0.3,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(0.0, 0.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  // ---------- Bottom nav ----------
  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // ✅ distributes space correctly
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Image(
                image: AssetImage("assets/images/home.png"),
                height: 25,
              ),
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () async {
              final token = await SecureStorage.getToken();

              if (token == null || token.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white, // white container
                    title: const Text("Login Required",
                        style: TextStyle(color: Colors.black)),
                    content: const Text(
                      "Please login to access favorites.",
                      style: TextStyle(color: Colors.black),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginDemo()),
                          );
                        },
                        child: const Text("Login",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              } else {
                // ✅ Logged in – go to favorites
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Fav_Logout()),
                ).then((_) async {
                  // 🔁 Re-sync when coming back
                  final updatedFavorites =
                      await FavoriteService.fetchApiFavorites(token);
                  if (mounted) {
                    setState(() {
                      FavoriteService.loggedInFavorites = updatedFavorites;
                    });
                  }
                });
              }
            },
            icon: pageIndex == 2
                ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                : const Icon(Icons.favorite_border_outlined,
                    color: Colors.red, size: 30),
          ),
          IconButton(
            tooltip: "Email",
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
            onPressed: () => showHomeContactDialog(context),
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 20.0), // consistent spacing from right edge
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const My_Account()),
                );
              },
              icon: pageIndex == 3
                  ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                  : const Icon(Icons.dehaze_outlined,
                      color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}
