import '../../core/constants/api_constants.dart';
import 'api_client.dart';
import '../models/player_profile.dart';

// Profile & account service
class XboxProfileService {
  final ApiClient client;
  XboxProfileService(this.client);

  Future<PlayerProfile> getMyProfile({bool force = false}) async {
    final json = await client.get(
      ApiConstants.account,
      cacheKey: 'account:me',
      cacheTtl: const Duration(minutes: 10),
      bypassCache: force,
    );
    return PlayerProfile.fromAccountJson(json);
  }

  // Used for friend profiles — cached a bit longer since bios/gamerscore
  // don't change minute to minute.
  Future<PlayerProfile> getProfileByXuid(String xuid, {bool force = false}) async {
    final json = await client.get(
      '/account/$xuid',
      cacheKey: 'account:$xuid',
      cacheTtl: const Duration(minutes: 15),
      bypassCache: force,
    );
    return PlayerProfile.fromAccountJson(json);
  }

  Future<PlayerProfile> getProfileByGamertag(String gamertag, {bool force = false}) async {
    final json = await client.get(
      ApiConstants.friendSearch,
      query: {'gt': gamertag},
      cacheKey: 'gt:$gamertag',
      cacheTtl: const Duration(minutes: 15),
      bypassCache: force,
    );
    return PlayerProfile.fromAccountJson(json);
  }
}
