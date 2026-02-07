import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalizationRepository {
  final _storage = const FlutterSecureStorage();

  Future<void> addLanguageToSecureStorage(String language) async {
    await _storage.write(key: 'Language', value: language);
  }

  Future<void> saveLanguage(String lang) async {
    await _storage.write(key: 'app_language', value: lang);
  }

  Future<String?> getSavedLanguage() async {
    return await _storage.read(key: 'app_language');
  }

  Future<void> setOverriddenFlag(bool value) async {
    await _storage.write(key: 'lang_overridden', value: value.toString());
  }

  Future<bool> getIsOverriddenFlag() async {
    final v = await _storage.read(key: 'lang_overridden');
    return v == 'true';
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
