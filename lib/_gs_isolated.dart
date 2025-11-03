// // lib/_gs_isolated.dart
// import 'package:google_sign_in/google_sign_in.dart';
//
// final GoogleSignIn _g = GoogleSignIn(scopes: const ['email']);
//
// Future<void> _probe() async {
//   final user = await _g.signIn();
//   if (user == null) return;
//   final auth = await user.authentication;
//   print(auth.idToken); // just to use the value
// }
