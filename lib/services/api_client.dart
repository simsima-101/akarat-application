// // lib/services/api_client.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../env.dart';
// import '../secure_storage.dart';
// import '../storage_keys.dart';
//
// class ApiClient {
//   final http.Client _http;
//   ApiClient(this._http);
//
//   Future<Map<String, String>> _headers() async {
//     final token = await SecureStorage.read(tokenKey());
//     return {
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'X-Requested-With': 'XMLHttpRequest',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }
//
//   Future<http.Response> get(String path) async {
//     final uri = Env.path(path);
//     return _http.get(uri, headers: await _headers());
//   }
//
//   Future<http.Response> post(String path, Map<String, dynamic> body) async {
//     final uri = Env.path(path);
//     return _http.post(uri, headers: await _headers(), body: jsonEncode(body));
//   }
//
//   Future<http.Response> delete(String path) async {
//     final uri = Env.path(path);
//     return _http.delete(uri, headers: await _headers());
//   }
// }
