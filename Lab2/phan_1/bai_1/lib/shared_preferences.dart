import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const _keyName = 'name';
  static const _keyEmail = 'email';
  static const _keyPhone = 'phone';
  static const _keyPassword = 'password';
  static const _keyBirthDate = 'birthDate';
  static const _keyGender = 'gender';

  static Future<void> saveUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required DateTime birthDate,
    required String gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyPassword, password);
    await prefs.setString(_keyBirthDate, birthDate.toIso8601String());
    await prefs.setString(_keyGender, gender);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyName);
    final email = prefs.getString(_keyEmail);
    final phone = prefs.getString(_keyPhone);
    final password = prefs.getString(_keyPassword);
    final birthDateStr = prefs.getString(_keyBirthDate);
    final gender = prefs.getString(_keyGender);
    if ([name, email, phone, password, birthDateStr, gender].contains(null)) {
      return null;
    }
    final birthDate = DateTime.tryParse(birthDateStr!);
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'birthDate': birthDate,
      'gender': gender,
    };
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyBirthDate);
    await prefs.remove(_keyGender);
  }
}