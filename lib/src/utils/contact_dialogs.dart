// // lib/utils/contact_dialogs.dart
// import 'package:flutter/material.dart';
// import 'package:Akarat/screen/ContactFormScreen.dart';
//
// /// Global function — works in EVERY screen
// void showHomeContactDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => const _EmailAgentDialog(),
//     routeSettings: RouteSettings(
//       arguments: {
//         'subtitle': 'We will get back to you as soon as possible',
//         'onSubmit': ({
//           required String name,
//           required String email,
//           required String phone,
//           required String message,
//         }) async {
//           // Your real API call (kept exactly from your ContactFormScreen.dart)
//           try {
//             final response = await http.post(
//               Uri.parse("https://qa.akarat.com/api/contact-akarat"),
//               headers: {
//                 "Accept": "application/json",
//                 "X-Device-ID": "8B368203-14FE-47F6-98C8-9933CB0AE73D",
//                 "Authorization": "Bearer 1092|fsHg2fMib653xIThnBMHMgtzl8Q7rILysRpFJbrb",
//               },
//               body: {
//                 "name": name.trim(),
//                 "email": email.trim(),
//                 "phone": phone.trim(),
//                 "message": message.trim(),
//               },
//             );
//             return response.statusCode == 200 || response.statusCode == 201;
//           } catch (e) {
//             return false;
//           }
//         },
//       },
//     ),
//   ).then((success) {
//     if (success == true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Thank you! Message sent!"), backgroundColor: Colors.green),
//       );
//     } else if (success == false) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to send. Try again."), backgroundColor: Colors.red),
//       );
//     }
//   });
// }