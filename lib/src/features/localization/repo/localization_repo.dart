import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalizationRepository {
  final _storage = const FlutterSecureStorage();

  Future<void> addLanguageToSecureStorage(String language) async {
    await _storage.write(key: 'Language', value: language);
  }

  Future<String> getLanguageFromSecureStorage(String defaultLanguage) async {
    String? language = await _storage.read(key: 'Language');
    if (language == null) {
      await _storage.write(key: 'Language', value: defaultLanguage);
      return defaultLanguage;
    }
    return language;
  }
}
