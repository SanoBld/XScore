import '../../core/constants/api_constants.dart';
import 'api_client.dart';
import '../models/player_profile.dart';

// Profile & account service
class XboxProfileService {
  final ApiClient client;
  XboxProfileService(this.client);

  Future<PlayerProfile> getMyProfile() async {
    final json = await client.get(ApiConstants.account);
    return PlayerProfile.fromAccountJson(json);
  }

  Future<PlayerProfile> getProfileByGamertag(String gamertag) async {
    final json = await client.get(ApiConstants.friendSearch,
        query: {'gt': gamertag});
    return PlayerProfile.fromAccountJson(json);
  }
}