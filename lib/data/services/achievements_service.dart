import '../../core/constants/api_constants.dart';
import 'api_client.dart';
import '../models/achievement.dart';
import '../models/title_summary.dart';

// Achievements per title + played games list
class AchievementsService {
  final ApiClient client;
  AchievementsService(this.client);

  // Correct OpenXBL route is path-based, not /achievements/{xuid}?titleId=:
  // /achievements/player/{xuid}/title/{titleId}. The old query-param form
  // returned 200 with an empty list, which is why the UI showed "0/0".
  Future<List<Achievement>> getAchievements(String xuid, String titleId) async {
    final json = await client.get(
      ApiConstants.achievementsForTitle(xuid, titleId),
    );
    final list = (json['achievements'] as List?) ?? [];
    return list.map((e) => Achievement.fromJson(e)).toList();
  }

  // Games tab: all played titles with gamerscore progress
  Future<List<TitleSummary>> getTitleHistory(String xuid) async {
    final json = await client.get(ApiConstants.titleHistory(xuid));
    final list = (json['titles'] as List?) ?? [];
    return list.map((e) => TitleSummary.fromJson(e)).toList()
      ..sort((a, b) {
        final ad = a.lastPlayed ?? DateTime(2000);
        final bd = b.lastPlayed ?? DateTime(2000);
        return bd.compareTo(ad);
      });
  }
}