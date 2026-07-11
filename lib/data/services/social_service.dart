import '../../core/constants/api_constants.dart';
import 'api_client.dart';
import '../models/friend.dart';

// Friends list & comparison service
class SocialService {
  final ApiClient client;
  SocialService(this.client);

  // Short TTL on purpose: online/offline status is the one thing here
  // that's actually time-sensitive. Everything else (gamertag, gamerscore)
  // would be fine cached longer, but they're bundled in the same response.
  Future<List<Friend>> getFriends({bool force = false}) async {
    final json = await client.get(
      ApiConstants.friends,
      cacheKey: 'friends',
      cacheTtl: const Duration(minutes: 2),
      bypassCache: force,
    );
    final list = (json['people'] as List?) ?? [];
    return list.map((e) => Friend.fromJson(e)).toList();
  }
}
