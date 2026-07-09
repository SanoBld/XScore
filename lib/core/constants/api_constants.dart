// OpenXBL API config
class ApiConstants {
  ApiConstants._();

  static const String openXblBase = 'https://xbl.io/api/v2';
  static const String xapiBase = 'https://xapi.us/v2';

  // Endpoints
  static const String account = '/account';
  static const String friends = '/friends';
  static const String friendSearch = '/friends/search';
  static const String achievements = '/achievements';
  static const String gameClips = '/dvr/gameclips';
  static const String screenshots = '/dvr/screenshots';
  static const String presence = '/presence';
  static const String titleHistory = '/player/titleHistory';

  // Image CDNs
  static const String gamerpicCdn = 'https://images-eds-ssl.xboxlive.com';
  static const String gameArtCdn = 'https://images-eds.xboxlive.com';

  // GitHub updates
  static const String githubOwner = 'YOUR_USERNAME';
  static const String githubRepo = 'YOUR_REPO';
  static String get latestReleaseUrl =>
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  static const String authHeader = 'X-Authorization';
}
