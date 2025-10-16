// lib/screen/personal_information.dart
import 'package:flutter/material.dart';

class PersonalInformationScreen extends StatelessWidget {
  final String name;
  final String email;

  /// Required: call your real delete flow here (e.g., the deleteAccount() you already have)
  final VoidCallback onDeleteAccount;

  /// Optional: navigate to your edit screen (or open a dialog)
  final VoidCallback? onEdit;

  const PersonalInformationScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.onDeleteAccount,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget infoBox(String title, String value) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              value.isNotEmpty ? value : '—',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    Widget centerButton({
      required String label,
      required Color color,
      required VoidCallback onTap,
    }) {
      return Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    Future<void> _confirmAndDelete() async {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        onDeleteAccount();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Information',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            infoBox('Name', name),
            infoBox('Email', email),
            infoBox('Password', '••••••••'),

            const SizedBox(height: 12),

            // Centered "Edit" button
            centerButton(
              label: 'Edit',
              color: Colors.red,
              onTap: onEdit ??
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit tapped')),
                    );
                  },
            ),

            // Centered "Delete your account" button
            centerButton(
              label: 'Delete your account',
              color: Colors.black87,
              onTap: _confirmAndDelete,
            ),
          ],
        ),
      ),
    );
  }
}
