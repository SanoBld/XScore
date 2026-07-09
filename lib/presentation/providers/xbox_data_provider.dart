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
  // Per-section errors so one broken endpoint doesn't hide the others
  String? profileError;
  String? titlesError;
  String? friendsError;
  String? mediaError;
  DateTime? _lastLoad;

  bool get isStale =>
      _lastLoad == null || DateTime.now().difference(_lastLoad!) > _cacheTtl;

  // Loads everything needed across tabs. Each section is fetched and
  // caught independently: a broken endpoint no longer blanks everything.
  Future<void> loadAll({bool force = false}) async {
    if (!force && !isStale && profile != null) return;

    loading = true;
    profileError = null;
    titlesError = null;
    friendsError = null;
    mediaError = null;
    notifyListeners();

    try {
      profile = await _profileService.getMyProfile();
      debugPrint(
          'XScore profile loaded: gamertag="${profile!.gamertag}" xuid=${profile!.xuid} gamerscore=${profile!.gamerscore}');
    } catch (e) {
      profileError = '$e';
      debugPrint('XScore profile ERROR: $e');
    }

    if (profile != null) {
      try {
        titles = await _achievementsService.getTitleHistory(profile!.xuid);
      } catch (e) {
        titlesError = '$e';
        debugPrint('XScore titleHistory ERROR: $e');
      }
    }

    try {
      friends = await _socialService.getFriends();
    } catch (e) {
      friendsError = '$e';
      debugPrint('XScore friends ERROR: $e');
    }

    try {
      final media = await Future.wait([
        _mediaService.getGameClips(),
        _mediaService.getScreenshots(),
      ]);
      gameClips = media[0];
      screenshots = media[1];
    } catch (e) {
      mediaError = '$e';
      debugPrint('XScore media ERROR: $e');
    }

    _lastLoad = DateTime.now();
    loading = false;
    notifyListeners();
  }

  // Kept for pages still referencing a single generic error
  String? get error => profileError;

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