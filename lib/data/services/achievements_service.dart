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
  // Cached 20 min: achievements only change while actively playing that
  // game, so re-fetching them every time a page reopens is pure waste.
  Future<List<Achievement>> getAchievements(
    String xuid,
    String titleId, {
    bool force = false,
  }) async {
    final json = await client.get(
      ApiConstants.achievementsForTitle(xuid, titleId),
      cacheKey: 'achievements:$xuid:$titleId',
      cacheTtl: const Duration(minutes: 20),
      bypassCache: force,
    );
    final list = (json['achievements'] as List?) ?? [];
    return list.map((e) => Achievement.fromJson(e)).toList();
  }

  // Games tab: all played titles with gamerscore progress
  Future<List<TitleSummary>> getTitleHistory(String xuid, {bool force = false}) async {
    final json = await client.get(
      ApiConstants.titleHistory(xuid),
      cacheKey: 'titles:$xuid',
      cacheTtl: const Duration(minutes: 10),
      bypassCache: force,
    );
    final list = (json['titles'] as List?) ?? [];
    return list.map((e) => TitleSummary.fromJson(e)).toList()
      ..sort((a, b) {
        final ad = a.lastPlayed ?? DateTime(2000);
        final bd = b.lastPlayed ?? DateTime(2000);
        return bd.compareTo(ad);
      });
  }
}
