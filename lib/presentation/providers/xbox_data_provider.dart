import 'package:flutter/material.dart';
import '../../data/services/api_client.dart';
import '../../data/services/xbox_profile_service.dart';
import '../../data/services/achievements_service.dart';
import '../../data/services/social_service.dart';
import '../../data/services/media_service.dart';
import '../../data/models/player_profile.dart';
import '../../data/models/title_summary.dart';
import '../../data/models/friend.dart';
import '../../data/models/game_clip.dart';

// Central cache for all Xbox data. Loaded once, refreshed manually,
// so the free 150 req/h OpenXBL quota isn't burned by every tab switch.
class XboxDataProvider extends ChangeNotifier {
  static const _cacheTtl = Duration(minutes: 5);

  late final ApiClient _client;
  late final XboxProfileService _profileService;
  late final AchievementsService _achievementsService;
  late final SocialService _socialService;
  late final MediaService _mediaService;

  XboxDataProvider(String apiKey) {
    _client = ApiClient(apiKey: apiKey);
    _profileService = XboxProfileService(_client);
    _achievementsService = AchievementsService(_client);
    _socialService = SocialService(_client);
    _mediaService = MediaService(_client);
  }

  PlayerProfile? profile;
  List<TitleSummary> titles = [];
  List<Friend> friends = [];
  List<GameClip> gameClips = [];
  List<GameClip> screenshots = [];

  bool loading = false;
  String? error;
  DateTime? _lastLoad;

  bool get isStale =>
      _lastLoad == null || DateTime.now().difference(_lastLoad!) > _cacheTtl;

  // Loads everything needed across tabs in one pass. Pass force=true
  // for pull-to-refresh; otherwise cached data is reused if fresh.
  Future<void> loadAll({bool force = false}) async {
    if (!force && !isStale && profile != null) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      profile = await _profileService.getMyProfile();
      final results = await Future.wait([
        _achievementsService.getTitleHistory(profile!.xuid),
        _socialService.getFriends(),
        _mediaService.getGameClips(),
        _mediaService.getScreenshots(),
      ]);
      titles = results[0] as List<TitleSummary>;
      friends = results[1] as List<Friend>;
      gameClips = results[2] as List<GameClip>;
      screenshots = results[3] as List<GameClip>;
      _lastLoad = DateTime.now();
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Dashboard: top 5 recently played
  List<TitleSummary> get recentTitles => titles.take(5).toList();

  // Social: online friends first
  List<Friend> get sortedFriends {
    final list = [...friends];
    list.sort((a, b) => a.isOnline == b.isOnline
        ? a.gamertag.compareTo(b.gamertag)
        : (a.isOnline ? -1 : 1));
    return list;
  }

  void dispose2() => _client.dispose();
}
