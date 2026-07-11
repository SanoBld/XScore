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
import '../../data/models/achievement.dart';

// Central cache for all Xbox data. Loaded once, refreshed manually,
// so the free 150 req/h OpenXBL quota isn't burned by every tab switch.
class XboxDataProvider extends ChangeNotifier {
  static const _cacheTtl = Duration(minutes: 5);

  late final ApiClient client;
  late final XboxProfileService profileService;
  late final AchievementsService achievementsService;
  late final SocialService _socialService;
  late final MediaService _mediaService;

  XboxDataProvider(String apiKey) {
    client = ApiClient(apiKey: apiKey);
    profileService = XboxProfileService(client);
    achievementsService = AchievementsService(client);
    _socialService = SocialService(client);
    _mediaService = MediaService(client);
    client.rateLimit.addListener(notifyListeners);
  }

  PlayerProfile? profile;
  List<TitleSummary> titles = [];
  List<Friend> friends = [];
  List<GameClip> gameClips = [];
  List<GameClip> screenshots = [];

  bool loading = false;
  String? profileError;
  String? titlesError;
  String? friendsError;
  String? mediaError;
  DateTime? _lastLoad;

  bool get isStale =>
      _lastLoad == null || DateTime.now().difference(_lastLoad!) > _cacheTtl;

  // Quota OpenXBL (150/h gratuit)
  int? get quotaLimit => client.rateLimit.limit;
  int? get quotaSpent => client.rateLimit.spent;
  int? get quotaRemaining => client.rateLimit.remaining;

  Future<void> loadAll({bool force = false}) async {
    if (!force && !isStale && profile != null) return;

    loading = true;
    profileError = null;
    titlesError = null;
    friendsError = null;
    mediaError = null;
    notifyListeners();

    try {
      profile = await profileService.getMyProfile(force: force);
    } catch (e) {
      profileError = '$e';
    }

    if (profile != null) {
      try {
        titles = await achievementsService.getTitleHistory(profile!.xuid, force: force);
      } catch (e) {
        titlesError = '$e';
      }
    }

    try {
      friends = await _socialService.getFriends(force: force);
    } catch (e) {
      friendsError = '$e';
    }

    try {
      final media = await Future.wait([
        _mediaService.getGameClips(force: force),
        _mediaService.getScreenshots(force: force),
      ]);
      gameClips = media[0];
      screenshots = media[1];
    } catch (e) {
      mediaError = '$e';
    }

    _lastLoad = DateTime.now();
    loading = false;
    notifyListeners();
  }

  // ── Recent achievements activity ──────────────────────────────────────
  // Not loaded automatically: each title needs its own request, so this is
  // gated behind an explicit user action + a one-time warning (see
  // SettingsProvider.hasSeenAchievementQuotaWarning / dashboard toggle).
  List<Achievement> recentAchievements = [];
  bool loadingAchievementsActivity = false;
  String? achievementsActivityError;

  Future<void> loadRecentAchievementsActivity({int titleLimit = 6}) async {
    if (profile == null) return;
    loadingAchievementsActivity = true;
    achievementsActivityError = null;
    notifyListeners();

    final xuid = profile!.xuid;
    final scan = recentTitles.take(titleLimit).toList();
    final collected = <Achievement>[];

    for (final t in scan) {
      try {
        final list = await achievementsService.getAchievements(xuid, t.titleId);
        collected.addAll(list.where((a) => a.unlocked));
      } catch (_) {
        // Skip titles the endpoint doesn't support (e.g. legacy Xbox 360
        // games) instead of failing the whole activity feed.
      }
    }

    collected.sort((a, b) {
      final ad = a.unlockedAt ?? DateTime(2000);
      final bd = b.unlockedAt ?? DateTime(2000);
      return bd.compareTo(ad);
    });

    recentAchievements = collected.take(15).toList();
    loadingAchievementsActivity = false;
    notifyListeners();
  }

  String? get error => profileError;

  List<TitleSummary> get recentTitles => titles.take(5).toList();

  List<Friend> get sortedFriends {
    final list = [...friends];
    list.sort((a, b) => a.isOnline == b.isOnline
        ? a.gamertag.compareTo(b.gamertag)
        : (a.isOnline ? -1 : 1));
    return list;
  }

  int get onlineFriendsCount => friends.where((f) => f.isOnline).length;

  @override
  void dispose() {
    client.rateLimit.removeListener(notifyListeners);
    client.dispose();
    super.dispose();
  }
}