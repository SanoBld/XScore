import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/xbox_data_provider.dart';
import '../../data/models/title_summary.dart';
import '../../data/models/achievement.dart';

class GameDetailPage extends StatefulWidget {
  final TitleSummary title;
  const GameDetailPage({super.key, required this.title});

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  List<Achievement>? _achievements;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
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
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
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