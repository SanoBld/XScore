import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/xbox_data_provider.dart';
import '../providers/settings_provider.dart';
import '../../data/models/title_summary.dart';
import '../../data/models/achievement.dart';
import '../../data/models/friend.dart';
import '../../data/models/game_info.dart';
import '../../data/services/igdb_service.dart';
import '../../data/services/api_client.dart' show ApiException;

class GameDetailPage extends StatefulWidget {
  final TitleSummary title;
  const GameDetailPage({super.key, required this.title});

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  List<Achievement>? _achievements;
  String? _error;

  Friend? _compareFriend;
  List<Achievement>? _friendAchievements;
  bool _comparing = false;
  String? _compareError;

  GameInfo? _igdbInfo;

  @override
  void initState() {
    super.initState();
    _load();
    _loadIgdbInfo();
  }

  // Silent by design: IGDB is an optional enrichment (needs its own free
  // Twitch Developer keys, separate from OpenXBL). If it's not configured
  // or the lookup fails, we just don't show the extra section — no error
  // banner, since the page is fully usable without it.
  Future<void> _loadIgdbInfo() async {
    final settings = context.read<SettingsProvider>();
    if (!settings.hasIgdbCredentials) return;
    try {
      final service = IgdbService(
        clientId: settings.igdbClientId!,
        clientSecret: settings.igdbClientSecret!,
      );
      final info = await service.findByName(widget.title.name);
      if (mounted && info != null) setState(() => _igdbInfo = info);
    } catch (_) {
      // Enrichment is best-effort — fail quietly
    }
  }

  Future<void> _load() async {
    try {
      final data = context.read<XboxDataProvider>();
      final xuid = data.profile?.xuid ?? '';
      final list = await data.achievementsService
          .getAchievements(xuid, widget.title.titleId);
      // Unlocked achievements first isn't ideal for hunting — show locked
      // (still to do) first, most people open this screen to see what's left
      list.sort((a, b) => a.unlocked == b.unlocked ? 0 : (a.unlocked ? 1 : -1));
      if (mounted) setState(() => _achievements = list);
    } on ApiException catch (e) {
      // OpenXBL answers unsupported/legacy titles with a 500 "NOT_FOUND"
      // envelope rather than an empty 200 list — that's not a real error
      // from the user's point of view, just "no data for this title", so
      // it goes through the same friendly empty-state message instead of
      // a raw stack trace.
      if (e.statusCode == 500 && e.message.contains('NOT_FOUND')) {
        if (mounted) setState(() => _achievements = []);
      } else {
        if (mounted) setState(() => _error = '$e');
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _pickFriendToCompare() async {
    final data = context.read<XboxDataProvider>();
    if (data.friends.isEmpty) return;
    final chosen = await showModalBottomSheet<Friend>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: data.friends
              .map((f) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: f.gamerpicUrl != null
                          ? CachedNetworkImageProvider(f.gamerpicUrl!)
                          : null,
                      child: f.gamerpicUrl == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(f.gamertag),
                    onTap: () => Navigator.pop(ctx, f),
                  ))
              .toList(),
        ),
      ),
    );
    if (chosen == null) return;

    setState(() {
      _compareFriend = chosen;
      _comparing = true;
      _compareError = null;
      _friendAchievements = null;
    });
    try {
      final data2 = context.read<XboxDataProvider>();
      final list = await data2.achievementsService
          .getAchievements(chosen.xuid, widget.title.titleId);
      if (mounted) setState(() => _friendAchievements = list);
    } catch (e) {
      if (mounted) setState(() => _compareError = '$e');
    } finally {
      if (mounted) setState(() => _comparing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.title;
    final scheme = Theme.of(context).colorScheme;
    final unlocked = _achievements?.where((a) => a.unlocked).length;
    final total = _achievements?.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(t.name, style: const TextStyle(fontSize: 14)),
              background: t.boxArtUrl != null
                  ? CachedNetworkImage(
                      imageUrl: t.boxArtUrl!,
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.35),
                      colorBlendMode: BlendMode.darken,
                      errorWidget: (_, __, ___) =>
                          Container(color: scheme.surfaceContainerHigh),
                    )
                  : Container(color: scheme.surfaceContainerHigh),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: scheme.primary, size: 20),
                      const SizedBox(width: 6),
                      Text('${t.currentGamerscore} / ${t.totalGamerscore} G'),
                      const Spacer(),
                      Text('${t.progressPercentage.toStringAsFixed(0)}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (t.progressPercentage / 100).clamp(0, 1),
                      minHeight: 8,
                    ),
                  ),
                  if (unlocked != null && total != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.military_tech_outlined, size: 18, color: scheme.primary),
                        const SizedBox(width: 6),
                        Text('$unlocked / $total succès débloqués'),
                      ],
                    ),
                  ],
                  if (_igdbInfo != null) ...[
                    const SizedBox(height: 14),
                    _IgdbInfoCard(info: _igdbInfo!),
                  ],
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _comparing ? null : _pickFriendToCompare,
                    icon: _comparing
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.compare_arrows, size: 18),
                    label: Text(_compareFriend == null
                        ? 'Comparer avec un ami'
                        : 'Comparer avec ${_compareFriend!.gamertag}'),
                  ),
                  if (_compareError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Comparaison indisponible : $_compareError',
                          style: TextStyle(color: scheme.error, fontSize: 12)),
                    ),
                  if (_compareFriend != null && _friendAchievements != null) ...[
                    const SizedBox(height: 12),
                    _ComparisonCard(
                      friend: _compareFriend!,
                      mine: _achievements ?? [],
                      theirs: _friendAchievements!,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text('Succès', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ),
          if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, style: TextStyle(color: scheme.error)),
              ),
            )
          else if (_achievements == null)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_achievements!.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'Aucun succès renvoyé par l\'API pour ce jeu.\n'
                    'C\'est fréquent sur les jeux Xbox 360 : OpenXBL ne '
                    'les expose pas toujours via cet endpoint.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: _achievements!.length,
              itemBuilder: (context, i) {
                final a = _achievements![i];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: a.iconUrl != null
                        ? CachedNetworkImage(
                            imageUrl: a.iconUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            color: a.unlocked ? null : Colors.grey,
                            colorBlendMode: a.unlocked ? null : BlendMode.saturation,
                            errorWidget: (_, __, ___) => Container(
                                width: 44, height: 44, color: scheme.surfaceContainerHigh),
                          )
                        : Container(
                            width: 44,
                            height: 44,
                            color: scheme.surfaceContainerHigh,
                            child: const Icon(Icons.emoji_events_outlined),
                          ),
                  ),
                  title: Text(a.name,
                      style: TextStyle(
                          color: a.unlocked
                              ? null
                              : scheme.onSurface.withValues(alpha: 0.5))),
                  subtitle: Text(a.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${a.gamerscore} G'),
                      if (a.unlocked)
                        Icon(Icons.check_circle, size: 14, color: scheme.primary),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _IgdbInfoCard extends StatelessWidget {
  final GameInfo info;
  const _IgdbInfoCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text('Infos', style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                Text('via IGDB',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            if (info.genres.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: info.genres
                    .map((g) => Chip(
                          label: Text(g, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            if (info.rating != null || info.firstReleaseDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (info.rating != null) ...[
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${(info.rating! / 10).toStringAsFixed(1)}/10'),
                    const SizedBox(width: 16),
                  ],
                  if (info.firstReleaseDate != null)
                    Text('Sorti en ${info.firstReleaseDate!.year}'),
                ],
              ),
            ],
            if (info.summary != null && info.summary!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                info.summary!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final Friend friend;
  final List<Achievement> mine;
  final List<Achievement> theirs;
  const _ComparisonCard({required this.friend, required this.mine, required this.theirs});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final myUnlocked = mine.where((a) => a.unlocked).length;
    final theirUnlocked = theirs.where((a) => a.unlocked).length;
    final total = theirs.isNotEmpty ? theirs.length : mine.length;

    final theirNames = theirs.where((a) => a.unlocked).map((a) => a.name).toSet();
    final myNames = mine.where((a) => a.unlocked).map((a) => a.name).toSet();
    final onlyThem = theirNames.difference(myNames);
    final onlyMe = myNames.difference(theirNames);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('$myUnlocked/$total', style: Theme.of(context).textTheme.titleLarge),
                    const Text('Toi'),
                  ],
                ),
                Icon(Icons.compare_arrows, color: scheme.onSurfaceVariant),
                Column(
                  children: [
                    Text('$theirUnlocked/$total', style: Theme.of(context).textTheme.titleLarge),
                    Text(friend.gamertag, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ],
            ),
            if (onlyThem.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('${friend.gamertag} a débloqué ${onlyThem.length} succès que tu n\'as pas',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            if (onlyMe.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Tu as débloqué ${onlyMe.length} succès que ${friend.gamertag} n\'a pas',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}