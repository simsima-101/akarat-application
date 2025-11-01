// // class Env {
// //   /// Reads at compile time. Default is your local server for Simulator.
// //   static const baseUrl = String.fromEnvironment(
// //     'API_BASE_URL',
// //     defaultValue: 'http://127.0.0.1:8000',
// //   );
// // }
//
//
//
// // lib/env.dart
// class Env {
//   /// Full base URL to your API, injected at build time.
//   /// Example:
//   ///  - Local (default): http://127.0.0.1:8021/api
//   ///  - QA (dart-define): https://qa.akarat.com/api
//   static const apiBase = String.fromEnvironment(
//     'API_BASE_URL',
//     defaultValue: 'http://127.0.0.1:8021/api',
//   );
//
//   static Uri get baseUri => Uri.parse(apiBase);
//
//   /// e.g. '127.0.0.1' or 'qa.akarat.com'
//   static String get hostKey => baseUri.host;
//
//   /// Helper to build endpoint URLs safely.
//   static Uri path(String path) {
//     final base = baseUri.toString().endsWith('/')
//         ? baseUri.toString().substring(0, baseUri.toString().length - 1)
//         : baseUri.toString();
//     final p = path.startsWith('/') ? path : '/$path';
//     return Uri.parse('$base$p');
//   }
// }
