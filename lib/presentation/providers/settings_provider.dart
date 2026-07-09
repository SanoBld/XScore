import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';

// App-wide settings state: API key, language, theme
class SettingsProvider extends ChangeNotifier {
  final _secureStorage = const FlutterSecureStorage();

  String? _apiKey;
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  String? get apiKey => _apiKey;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get hasApiKey => (_apiKey ?? '').isNotEmpty;

  // Load persisted settings at startup
  Future<void> init() async {
    _apiKey = await _secureStorage.read(key: StorageKeys.apiKey);
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(StorageKeys.languageCode);
    if (lang != null) _locale = Locale(lang);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await _secureStorage.write(key: StorageKeys.apiKey, value: key);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.languageCode, locale.languageCode);
    notifyListeners();
  }
}
