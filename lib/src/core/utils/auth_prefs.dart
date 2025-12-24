// lib/core/utils/auth_prefs.dart

import 'secure_storage.dart';


enum LoginMethod { email, google }

class AuthPrefs {
  static const String _loginMethodKey = 'login_method'; // We'll store as a custom key

  static Future<void> setLoginMethod(LoginMethod method) async {
    // Use a dedicated setter or fallback to a generic one if available
    // Since SecureStorage likely doesn't have setString, store it via a custom approach
    // Option: Add a method to SecureStorage, or store as a separate field
    await SecureStorage.setLoginMethod(method.name); // Recommended: add this method to SecureStorage
  }

  static Future<LoginMethod?> getLoginMethod() async {
    final value = await SecureStorage.getLoginMethod(); // Recommended: add this method
    if (value == null) return null;
    return LoginMethod.values.firstWhere(
          (e) => e.name == value,
      orElse: () => LoginMethod.email,
    );
  }
}