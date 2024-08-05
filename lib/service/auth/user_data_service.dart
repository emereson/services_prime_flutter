import 'package:shared_preferences/shared_preferences.dart';

class UserDataService {
  static Future<void> saveUserData(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', data);
  }

  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userData');
  }

  static Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }
}
