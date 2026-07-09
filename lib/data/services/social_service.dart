import '../../core/constants/api_constants.dart';
import 'api_client.dart';
import '../models/friend.dart';

// Friends list & comparison service
class SocialService {
  final ApiClient client;
  SocialService(this.client);

  Future<List<Friend>> getFriends() async {
    final json = await client.get(ApiConstants.friends);
    final list = (json['people'] as List?) ?? [];
    return list.map((e) => Friend.fromJson(e)).toList();
  }
}
