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

  // Alt gateway (fallback / future use)
  static const xapiBase = 'https://xapi.us';

  // Xbox CDNs
  static const gamerpicCdn = 'https://images-eds-ssl.xboxlive.com';
  static const gameArtCdn = 'https://images-eds.xboxlive.com';

  // GitHub self-update
  // TODO: replace with your repo
  static const latestReleaseUrl =
      'https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/releases/latest';
}
