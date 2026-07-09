import '../../core/constants/api_constants.dart';
import 'api_client.dart';
import '../models/achievement.dart';

// Achievements per title service
class AchievementsService {
  final ApiClient client;
  AchievementsService(this.client);

  Future<List<Achievement>> getAchievements(String titleId) async {
    final json =
        await client.get('${ApiConstants.achievements}/player/$titleId');
    final list = (json['achievements'] as List?) ?? [];
    return list.map((e) => Achievement.fromJson(e)).toList();
  }
}
