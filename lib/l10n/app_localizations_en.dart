// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'XScore';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navGames => 'My Games';

  @override
  String get navSocial => 'Social';

  @override
  String get navMedia => 'Media';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsApiKey => 'API Key';

  @override
  String get settingsApiKeyHint => 'Enter your OpenXBL API key';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsUpdates => 'Check for Updates';

  @override
  String get settingsUpdatesUpToDate => 'You are up to date';

  @override
  String get settingsUpdatesAvailable => 'New version available';

  @override
  String get dashboardGamerscore => 'Gamerscore';

  @override
  String get dashboardRecentActivity => 'Recent Activity';

  @override
  String get gamesTitle => 'My Games';

  @override
  String get socialTitle => 'Friends';

  @override
  String get mediaTitle => 'Game Clips & Screenshots';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDownload => 'Download';

  @override
  String get actionCancel => 'Cancel';
}
