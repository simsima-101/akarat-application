// import 'package:dio/dio.dart';
// import '../utils/locale_utils.dart';
//
// class ApiClient {
//   static final Dio dio = Dio(
//     BaseOptions(
//       baseUrl: 'https://qa.akarat.com/api',
//       connectTimeout: const Duration(seconds: 15),
//       receiveTimeout: const Duration(seconds: 15),
//     ),
//   )..interceptors.add(
//     InterceptorsWrapper(
//       onRequest: (options, handler) {
//         final lang = getCurrentLanguageCodeWithoutContext();
//
//         options.headers['Accept-Language'] = lang;
//
//         // Optional debug log
//         print('API LANG => $lang');
//
//         print('REQUEST HEADERS => ${options.headers}');
//
//         return handler.next(options);
//       },
//     ),
//   );
// }
