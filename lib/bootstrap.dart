// // lib/bootstrap.dart
// import 'package:shared_preferences/shared_preferences.dart';
// import 'env.dart';
// import 'storage_keys.dart';
// import 'secure_storage.dart';
//
// Future<void> boot() async {
//   final prefs = await SharedPreferences.getInstance();
//   final lastHost = prefs.getString(lastHostKey());
//   if (lastHost != Env.hostKey) {
//     // Env changed → wipe old env data to avoid 401s & stale favorites
//     await SecureStorage.delete(tokenKey());
//     await prefs.remove(favSetKey());
//     await prefs.setString(lastHostKey(), Env.hostKey);
//   }
//   // Optional: print to verify at startup
//   // debugPrint('API_BASE_URL=${Env.apiBase} host=${Env.hostKey}');
// }
