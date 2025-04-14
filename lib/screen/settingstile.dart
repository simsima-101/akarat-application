import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String iconPath;
  final String? trailingText;

  const SettingsTile({
    super.key,
    required this.title,
    required this.iconPath,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.045,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Image.asset(iconPath, height: 35),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Text(
                  trailingText!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 13),
          ],
        ),
      ),
    );
  }
}