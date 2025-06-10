import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppButton extends StatelessWidget {
  final String phoneNumber;
  final String message;

  const WhatsAppButton({
    Key? key,
    required this.phoneNumber,
    this.message = "Hello",
  }) : super(key: key);

  String formatWhatsAppNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d]'), '');
    if (input.startsWith('971')) return input;
    if (input.startsWith('00971')) return input.substring(2);
    if (input.startsWith('+971')) return input.substring(1);
    if (input.startsWith('0') && input.length == 10)
      return '971${input.substring(1)}';
    if (input.length == 9) return '971$input';
    return input; // fallback
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 1),
      height: 35,
      width: 35,
      padding: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: const Offset(0.5, 0.5),
            blurRadius: 1.0,
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: Colors.white,
            offset: const Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () async {
          String formattedPhone = formatWhatsAppNumber(phoneNumber);
          final encodedMessage = Uri.encodeComponent(message);
          final url = Uri.parse("https://wa.me/$formattedPhone?text=$encodedMessage");

          print("WhatsApp link: $url");

          if (await canLaunchUrl(url)) {
            try {
              final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
              if (!launched) {
                print("❌ Could not launch WhatsApp");
              }
            } catch (e) {
              print("❌ Exception: $e");
            }
          } else {
            print("❌ WhatsApp not available or URL not supported");
          }
        },
        child: Image.asset("assets/images/whats.png", height: 20),
      ),
    );
  }
}
