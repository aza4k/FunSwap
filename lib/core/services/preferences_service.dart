import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Language
  static String getLanguage() {
    return _prefs.getString('language') ?? 'English';
  }

  static Future<void> setLanguage(String value) async {
    await _prefs.setString('language', value);
  }

  // Theme (Dark Mode)
  static bool getDarkMode() {
    return _prefs.getBool('dark_mode') ?? true;
  }

  static Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('dark_mode', value);
  }

  // Notifications
  static bool getNotifications() {
    return _prefs.getBool('notifications') ?? true;
  }

  static Future<void> setNotifications(bool value) async {
    await _prefs.setBool('notifications', value);
  }

  // Storage Location
  static String getStorageLocation() {
    return _prefs.getString('storage_location') ?? 'internal';
  }

  static Future<void> setStorageLocation(String value) async {
    await _prefs.setString('storage_location', value);
  }

  // Auto Delete
  static String getAutoDelete() {
    return _prefs.getString('auto_delete') ?? '7d';
  }

  static Future<void> setAutoDelete(String value) async {
    await _prefs.setString('auto_delete', value);
  }

  // Onboarding completed
  static bool isOnboardingCompleted() {
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool('onboarding_completed', value);
  }
}
