import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// **'Dashboard'**
  String get navDashboard;

  /// **'My Games'**
  String get navGames;

  /// **'Social'**
  String get navSocial;

  /// **'Media'**
  String get navMedia;

  /// **'Gamerscore'**
  String get dashboardGamerscore;

  /// **'Recent Activity'**
  String get dashboardRecentActivity;

  /// **'My Games'**
  String get gamesTitle;

  /// **'Social'**
  String get socialTitle;

  /// **'Media'**
  String get mediaTitle;

  /// **'Settings'**
  String get settingsTitle;

  /// **'API Key'**
  String get settingsApiKey;

  /// **'Enter your OpenXBL API key'**
  String get settingsApiKeyHint;

  /// **'Language'**
  String get settingsLanguage;

  /// **'Check for Updates'**
  String get settingsUpdates;

  /// **'Update available'**
  String get settingsUpdatesAvailable;

  /// **'You're up to date'**
  String get settingsUpdatesUpToDate;

  /// **'Download'**
  String get actionDownload;

  /// **'Connect'**
  String get actionConnect;

  /// **'Retry'**
  String get actionRetry;

  /// **'Connect your Xbox account'**
  String get setupTitle;

  /// **'Paste your OpenXBL API key to get started'**
  String get setupSubtitle;

  /// **'OpenXBL API key'**
  String get setupApiKeyHint;

  /// **'Get a free key on xbl.io'**
  String get setupGetKeyLink;

  /// **'Please enter your API key.'**
  String get setupErrorEmpty;

  /// **'This API key seems invalid.'**
  String get setupErrorInvalid;

  /// **'Connecting…'**
  String get setupConnecting;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
