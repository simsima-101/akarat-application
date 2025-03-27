import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  final String stringKey = "token";
  final String stringemail = "email";
  final String stringresult = "result";


  Future<void> addStringToPref(stringData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(stringKey, stringData);
  }
  Future<void> addStringToPrefemail(stringData1) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(stringemail, stringData1);
  }
  Future<void> addStringToPrefresult(stringData2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(stringresult, stringData2);
  }



  Future<String> readStringFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(stringKey) ?? '';
  }
  Future<String> readStringFromPrefemail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(stringemail) ?? '';
  }
  Future<String> readStringFromPrefresult() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(stringresult) ?? '';
  }
}