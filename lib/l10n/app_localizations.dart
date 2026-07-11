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
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navGames.
  ///
  /// In en, this message translates to:
  /// **'My Games'**
  String get navGames;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get navSocial;

  /// No description provided for @navMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get navMedia;

  /// No description provided for @dashboardGamerscore.
  ///
  /// In en, this message translates to:
  /// **'Gamerscore'**
  String get dashboardGamerscore;

  /// No description provided for @dashboardRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get dashboardRecentActivity;

  /// No description provided for @gamesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Games'**
  String get gamesTitle;

  /// No description provided for @socialTitle.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get socialTitle;

  /// No description provided for @mediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get mediaTitle;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a game or a profile…'**
  String get searchHint;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get settingsActivity;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsApiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get settingsApiKey;

  /// No description provided for @settingsApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your OpenXBL API key'**
  String get settingsApiKeyHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get settingsUpdates;

  /// No description provided for @settingsUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get settingsUpdatesAvailable;

  /// No description provided for @settingsUpdatesUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date'**
  String get settingsUpdatesUpToDate;

  /// No description provided for @actionDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get actionDownload;

  /// No description provided for @actionConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get actionConnect;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your Xbox account'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste your OpenXBL API key to get started'**
  String get setupSubtitle;

  /// No description provided for @setupApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'OpenXBL API key'**
  String get setupApiKeyHint;

  /// No description provided for @setupGetKeyLink.
  ///
  /// In en, this message translates to:
  /// **'Get a free key on xbl.io'**
  String get setupGetKeyLink;

  /// No description provided for @setupErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your API key.'**
  String get setupErrorEmpty;

  /// No description provided for @setupErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'This API key seems invalid.'**
  String get setupErrorInvalid;

  /// No description provided for @setupConnecting.
  ///
  /// In en, this message translates to:
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
  // Lookup logic when only language code is specified.
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
