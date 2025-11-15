// lib/services/auth_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';

enum LoginMethod {
  password,
  google,
}

class AuthPrefs {
  static const _kLoginMethod = 'login_method';

  static Future<void> setLoginMethod(LoginMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLoginMethod, method.name); // 'password' or 'google'
  }

  static Future<LoginMethod?> getLoginMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kLoginMethod);
    if (value == LoginMethod.password.name) return LoginMethod.password;
    if (value == LoginMethod.google.name) return LoginMethod.google;
    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoginMethod);
  }
}
