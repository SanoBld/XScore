// Central place for all external API endpoints
class ApiConstants {
  ApiConstants._();

  // OpenXBL base
  static const openXblBase = 'https://api.xbl.io/v2';
  static const authHeader = 'X-Authorization';

  // OpenXBL routes
  static const account = '/account';
  static const friends = '/friends';
  static const friendSearch = '/friends/search';
  // Achievements for one title: /achievements/player/{xuid}/title/{titleId}
  static String achievementsForTitle(String xuid, String titleId) =>
      '/achievements/player/$xuid/title/$titleId';
  static const gameClips = '/dvr/gameclips';
  static const screenshots = '/dvr/screenshots';

  // Titles played + achievement progress per game (Games tab)
  static String titleHistory(String xuid) => '/player/titleHistory/$xuid';

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

  // IGDB (owned by Twitch) — optional enrichment: genres, summary, rating,
  // release date. Needs a free Twitch Developer app (Client ID + Secret),
  // separate from the OpenXBL key.
  static const twitchTokenUrl = 'https://id.twitch.tv/oauth2/token';
  static const igdbBase = 'https://api.igdb.com/v4';
}