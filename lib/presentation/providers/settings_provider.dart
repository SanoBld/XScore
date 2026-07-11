import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';
import '../../core/constants/storage_keys.dart';
import '../../data/services/cache_service.dart';

// Preset accent colors offered in Settings, besides the system color
const List<Color> accentPresets = [
  Color(0xFF107C10), // Xbox green (default)
  Color(0xFF0078D4), // Blue
  Color(0xFF8764B8), // Purple
  Color(0xFFE3008C), // Magenta
  Color(0xFFD13438), // Red
  Color(0xFFFF8C00), // Orange
];

// App-wide settings state: API key, language, theme
class SettingsProvider extends ChangeNotifier {
  final _secureStorage = const FlutterSecureStorage();

  String? _apiKey;
  String? _igdbClientId;
  String? _igdbClientSecret;
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;
  Color? _accentColor; // null = use system accent color
  bool _useSystemAccent = true;
  bool _gamesGridLayout = false; // false = liste, true = grille
  bool _showAchievementActivity = false;
  bool _hasSeenAchievementQuotaWarning = false;
  bool _showQuotaOnDashboard = false;
  bool _showDashboardCoverBackground = true;

  String? get apiKey => _apiKey;
  String? get igdbClientId => _igdbClientId;
  String? get igdbClientSecret => _igdbClientSecret;
  bool get hasIgdbCredentials =>
      (_igdbClientId ?? '').isNotEmpty && (_igdbClientSecret ?? '').isNotEmpty;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get hasApiKey => (_apiKey ?? '').isNotEmpty;
  bool get useSystemAccent => _useSystemAccent;
  bool get gamesGridLayout => _gamesGridLayout;
  bool get showAchievementActivity => _showAchievementActivity;
  bool get hasSeenAchievementQuotaWarning => _hasSeenAchievementQuotaWarning;
  bool get showQuotaOnDashboard => _showQuotaOnDashboard;
  bool get showDashboardCoverBackground => _showDashboardCoverBackground;

  // Windows/macOS: read via system_theme. Android 12+: read via
  // dynamic_color/Material You (wired in main.dart, not here, since it
  // needs a BuildContext + DynamicColorBuilder). iOS/Linux/older Android:
  // no OS-level accent API exists, so we always fall back to a preset.
  bool get supportsSystemAccent =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isAndroid);

  // system_theme only knows how to read Windows/macOS — calling it on
  // Android silently returns its own generic default (a blue), which is
  // exactly the "always stuck on blue" bug: supportsSystemAccent covers
  // Android too (for the UI toggle), but the *actual* Android reading
  // happens via dynamic_color/DynamicColorBuilder in main.dart, which
  // bypasses this getter entirely. So this getter must stay Windows/macOS
  // only, and just return a sane preset fallback on Android — main.dart
  // is what substitutes the real Material You color at theme-build time.
  Color get accentColor {
    if (useSystemAccent && !kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
      return SystemTheme.accentColor.accent;
    }
    return _accentColor ?? accentPresets.first;
  }

  // Load persisted settings at startup
  Future<void> init() async {
    _apiKey = await _secureStorage.read(key: StorageKeys.apiKey);
    _igdbClientId = await _secureStorage.read(key: 'igdb_client_id');
    _igdbClientSecret = await _secureStorage.read(key: 'igdb_client_secret');
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(StorageKeys.languageCode);
    if (lang != null) _locale = Locale(lang);

    final themeStr = prefs.getString(StorageKeys.themeMode);
    _themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    _useSystemAccent = prefs.getBool('use_system_accent') ?? true;
    final storedColor = prefs.getInt('accent_color');
    if (storedColor != null) _accentColor = Color(storedColor);
    _gamesGridLayout = prefs.getBool('games_grid_layout') ?? false;
    _showAchievementActivity = prefs.getBool('show_achievement_activity') ?? false;
    _hasSeenAchievementQuotaWarning =
        prefs.getBool('seen_achievement_quota_warning') ?? false;
    _showQuotaOnDashboard = prefs.getBool('show_quota_on_dashboard') ?? false;
    _showDashboardCoverBackground = prefs.getBool('show_dashboard_cover_bg') ?? true;

    notifyListeners();
  }

  Future<void> setShowDashboardCoverBackground(bool value) async {
    _showDashboardCoverBackground = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_dashboard_cover_bg', value);
    notifyListeners();
  }

  Future<void> setGamesGridLayout(bool value) async {
    _gamesGridLayout = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('games_grid_layout', value);
    notifyListeners();
  }

  Future<void> setShowAchievementActivity(bool value) async {
    _showAchievementActivity = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_achievement_activity', value);
    notifyListeners();
  }

  Future<void> markAchievementQuotaWarningSeen() async {
    _hasSeenAchievementQuotaWarning = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_achievement_quota_warning', true);
  }

  Future<void> setShowQuotaOnDashboard(bool value) async {
    _showQuotaOnDashboard = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_quota_on_dashboard', value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.themeMode,
      mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system',
    );
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await _secureStorage.write(key: StorageKeys.apiKey, value: key);
    notifyListeners();
  }

  Future<void> setIgdbCredentials(String clientId, String clientSecret) async {
    _igdbClientId = clientId;
    _igdbClientSecret = clientSecret;
    await _secureStorage.write(key: 'igdb_client_id', value: clientId);
    await _secureStorage.write(key: 'igdb_client_secret', value: clientSecret);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.languageCode, locale.languageCode);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    _useSystemAccent = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.toARGB32());
    await prefs.setBool('use_system_accent', false);
    notifyListeners();
  }

  Future<void> setUseSystemAccent(bool value) async {
    _useSystemAccent = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_system_accent', value);
    notifyListeners();
  }

  // Clears the API key so the user is sent back to the setup screen
  Future<void> logout() async {
    _apiKey = null;
    await _secureStorage.delete(key: StorageKeys.apiKey);
    await CacheService().clearAll();
    notifyListeners();
  }
}