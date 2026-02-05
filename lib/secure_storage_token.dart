// // lib/secure_storage_token.dart
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class AuthStorage {
//   // Key for the bearer token
//   static const String _kToken = 'token';
//
//   // Platform options
//   static const AndroidOptions _aOpts = AndroidOptions(
//     encryptedSharedPreferences: true,
//     resetOnError: true,
//   );
//   static const IOSOptions _iOpts = IOSOptions(
//     accessibility: KeychainAccessibility.first_unlock,
//   );
//
//   static const FlutterSecureStorage _storage =
//   FlutterSecureStorage(aOptions: _aOpts, iOptions: _iOpts);
//
//   /// Read the saved token, or null if none.
//   static Future<String?> readToken() => _storage.read(key: _kToken);
//
//   /// Save (or clear if blank) the token.
//   static Future<void> saveToken(String token) async {
//     final t = token.trim();
//     if (t.isEmpty) {
//       await clear();
//     } else {
//       await _storage.write(key: _kToken, value: t);
//     }
//   }
//
//   /// Clear only the token.
//   static Future<void> clear() => _storage.delete(key: _kToken);
// }
