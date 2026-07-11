import '../../core/constants/api_constants.dart';
import 'api_client.dart';
import '../models/game_clip.dart';

// Game clips & screenshots service
class MediaService {
  final ApiClient client;
  MediaService(this.client);

  Future<List<GameClip>> getGameClips({bool force = false}) async {
    final json = await client.get(
      ApiConstants.gameClips,
      cacheKey: 'gameclips',
      cacheTtl: const Duration(minutes: 10),
      bypassCache: force,
    );
    final list = (json['gameClips'] as List?) ?? [];
    return list.map((e) => GameClip.fromJson(e)).toList();
  }

  Future<List<GameClip>> getScreenshots({bool force = false}) async {
    final json = await client.get(
      ApiConstants.screenshots,
      cacheKey: 'screenshots',
      cacheTtl: const Duration(minutes: 10),
      bypassCache: force,
    );
    final list = (json['screenshots'] as List?) ?? [];
    return list.map((e) => GameClip.fromJson(e)).toList();
  }
}
