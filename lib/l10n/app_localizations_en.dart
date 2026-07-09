// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navGames => 'My Games';

  @override
  String get navSocial => 'Social';

  @override
  String get navMedia => 'Media';

  @override
  String get dashboardGamerscore => 'Gamerscore';

  @override
  String get dashboardRecentActivity => 'Recent Activity';

  @override
  String get gamesTitle => 'My Games';

  @override
  String get socialTitle => 'Social';

  @override
  String get mediaTitle => 'Media';

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
  String get settingsUpdatesAvailable => 'Update available';

  @override
  String get settingsUpdatesUpToDate => 'You\'re up to date';

  @override
  String get actionDownload => 'Download';

  @override
  String get actionConnect => 'Connect';

  @override
  String get actionRetry => 'Retry';

  @override
  String get setupTitle => 'Connect your Xbox account';

  @override
  String get setupSubtitle => 'Paste your OpenXBL API key to get started';

  @override
  String get setupApiKeyHint => 'OpenXBL API key';

  @override
  String get setupGetKeyLink => 'Get a free key on xbl.io';

  @override
  String get setupErrorEmpty => 'Please enter your API key.';

  @override
  String get setupErrorInvalid => 'This API key seems invalid.';

  @override
  String get setupConnecting => 'Connecting…';
}
