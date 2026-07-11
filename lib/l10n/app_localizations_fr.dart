// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navHome => 'Accueil';

  @override
  String get navGames => 'Jeux';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navSocial => 'Amis';

  @override
  String get navMedia => 'Médias';

  @override
  String get dashboardGamerscore => 'Gamerscore';

  @override
  String get dashboardRecentActivity => 'Activité récente';

  @override
  String get gamesTitle => 'Mes jeux';

  @override
  String get socialTitle => 'Amis';

  @override
  String get mediaTitle => 'Médias';

  @override
  String get searchTitle => 'Recherche';

  @override
  String get searchHint => 'Rechercher un jeu ou un profil…';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsActivity => 'Activité';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsApiKey => 'Clé API';

  @override
  String get settingsApiKeyHint => 'Entrez votre clé API OpenXBL';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsUpdates => 'Vérifier les mises à jour';

  @override
  String get settingsUpdatesAvailable => 'Mise à jour disponible';

  @override
  String get settingsUpdatesUpToDate => 'Vous êtes à jour';

  @override
  String get actionDownload => 'Télécharger';

  @override
  String get actionConnect => 'Connexion';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get setupTitle => 'Connecte ton compte Xbox';

  @override
  String get setupSubtitle => 'Colle ta clé API OpenXBL pour commencer';

  @override
  String get setupApiKeyHint => 'Clé API OpenXBL';

  @override
  String get setupGetKeyLink => 'Obtenir une clé gratuite sur xbl.io';

  @override
  String get setupErrorEmpty => 'Merci de saisir ta clé API.';

  @override
  String get setupErrorInvalid => 'Cette clé API semble invalide.';

  @override
  String get setupConnecting => 'Connexion en cours…';
}
