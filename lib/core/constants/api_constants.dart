// Central place for all external API endpoints
class ApiConstants {
  ApiConstants._();

  // OpenXBL base
  static const openXblBase = 'https://xbl.io/api/v2';
  static const authHeader = 'X-Authorization';

  // OpenXBL routes
  static const account = '/account';
  static const friends = '/friends';
  static const friendSearch = '/friends/search';
  static const achievements = '/achievements';
  static const gameClips = '/dvr/gameclips';
  static const screenshots = '/dvr/screenshots';

  // Titles played + achievement progress per game (Games tab)
  static String titleHistory(String xuid) =>
      '/achievements/player/$xuid/titleHistory';

  // Bulk presence lookup (comma-separated xuids)
  static const presence = '/presence';

  // Alt gateway (fallback / future use)
  static const xapiBase = 'https://xapi.us';

  // Xbox CDNs
  static const gamerpicCdn = 'https://images-eds-ssl.xboxlive.com';
  static const gameArtCdn = 'https://images-eds.xboxlive.com';

  // GitHub self-update
  static const latestReleaseUrl =
      'https://api.github.com/repos/SanoBld/XScore/releases/latest';
}