import 'dart:async';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:Akarat/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../secure_storage.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../utils/fav_logout.dart';
import 'login.dart';

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
  String? _required(String? v, String label) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Please enter $label';
    return null;
  }

  String? _validateEmail(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Please enter Email';
    final re = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!re.hasMatch(t)) return 'Please enter a valid email';
    return null;
  }

  // ---------------- Submit ----------------
  Future<void> sendMessage() async {
    final form = _formKey.currentState;
    if (form == null) {
      debugPrint('FormState is null: make sure fields are wrapped in Form(key: _formKey).');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form not ready. Please try again.')),
      );
      return;
    }
    if (!form.validate()) return;

    setState(() => _isLoading = true);

    try {
      final ok = await ApiService.submitContactForm(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const My_Account()),
        );
        return false; // prevent default pop
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.red),
          title: const Text(
            "Contact Us",
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
              const Text(
                "Ask us anything?",
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name
                      _label("Name"),
                      _boxedField(
                        child: TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          validator: (v) => _required(v, 'Name'),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      // Email
                      _label("Email Address"),
                      _boxedField(
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      // Phone
                      _label("Phone Number"),
                      _boxedField(
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) => _required(v, 'Phone Number'),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      // Subject
                      _label("Subject"),
                      _boxedField(
                        child: TextFormField(
                          controller: subjectController,
                          keyboardType: TextInputType.text,
                          validator: (v) => _required(v, 'Subject'),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      // Message
                      _label("Message"),
                      _boxedField(
                        child: TextFormField(
                          controller: messageController,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          validator: (v) => _required(v, 'Message'),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 48, // ✅ fixed control height; no screenSize dependency
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
                              : const Text(
                            "Submit",
                            style: TextStyle(color: Colors.white, fontSize: 15),
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
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 8, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _boxedField({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        padding: const EdgeInsets.only(left: 10),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ distributes space correctly
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
                    title: const Text("Login Required", style: TextStyle(color: Colors.black)),
                    content: const Text(
                      "Please login to access favorites.",
                      style: TextStyle(color: Colors.black),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginDemo()),
                          );
                        },
                        child: const Text("Login", style: TextStyle(color: Colors.red)),
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
                  final updatedFavorites = await FavoriteService.fetchApiFavorites(token);
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
                : const Icon(Icons.favorite_border_outlined, color: Colors.red, size: 30),
          ),

          IconButton(
            tooltip: "Email",
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
            onPressed: () async {
              final Uri emailUri = Uri.parse(
                'mailto:info@akarat.com?subject=Property%20Inquiry&body=Hi,%20I%20saw%20your%20agent%20profile%20on%20Akarat.',
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
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
            },
          ),

          Padding(
            padding: const EdgeInsets.only(right: 20.0), // consistent spacing from right edge
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
                  : const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}
