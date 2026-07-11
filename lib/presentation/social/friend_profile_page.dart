import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/xbox_data_provider.dart';
import '../../data/models/friend.dart';
import '../../data/models/player_profile.dart';
import '../../data/models/title_summary.dart';
import '../games/game_detail_page.dart';

class FriendProfilePage extends StatefulWidget {
  final Friend friend;
  const FriendProfilePage({super.key, required this.friend});

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  PlayerProfile? _profile;
  List<TitleSummary>? _titles;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = context.read<XboxDataProvider>();
    try {
      final p = await data.achievementsService.client
          .get('/account/${widget.friend.xuid}');
      if (mounted) setState(() => _profile = PlayerProfile.fromAccountJson(p));
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
    try {
      final titles = await data.achievementsService.getTitleHistory(widget.friend.xuid);
      if (mounted) setState(() => _titles = titles);
    } catch (_) {
      // Stats optionnelles, on n'affiche juste rien si ça échoue
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.friend;
    final scheme = Theme.of(context).colorScheme;
    final titles = _titles ?? [];
    final recentTitles = titles.take(6).toList();
    final completed = titles.where((t) => t.progressPercentage >= 100).length;
    final avgCompletion = titles.isEmpty
        ? 0.0
        : titles.map((t) => t.progressPercentage).reduce((a, b) => a + b) / titles.length;

    return Scaffold(
      appBar: AppBar(title: Text(f.gamertag)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: scheme.primaryContainer,
                  backgroundImage: f.gamerpicUrl != null
                      ? CachedNetworkImageProvider(f.gamerpicUrl!)
                      : null,
                  child: f.gamerpicUrl == null ? const Icon(Icons.person, size: 40) : null,
                ),
                const SizedBox(height: 12),
                Text(f.gamertag, style: Theme.of(context).textTheme.titleLarge),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle,
                        size: 10, color: f.isOnline ? Colors.green : scheme.outline),
                    const SizedBox(width: 6),
                    Text(f.isOnline ? 'En ligne' : 'Hors ligne'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4 stats instead of just 2 — gamerscore/jeux was quite bare
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _StatTile(
                icon: Icons.emoji_events_outlined,
                label: 'Gamerscore',
                value: '${f.gamerscore}',
              ),
              _StatTile(
                icon: Icons.videogame_asset_outlined,
                label: 'Jeux',
                value: _titles != null ? '${_titles!.length}' : '—',
              ),
              _StatTile(
                icon: Icons.workspace_premium_outlined,
                label: 'Terminés (100%)',
                value: _titles != null ? '$completed' : '—',
              ),
              _StatTile(
                icon: Icons.donut_large_outlined,
                label: 'Complétion moy.',
                value: _titles != null ? '${avgCompletion.toStringAsFixed(0)}%' : '—',
              ),
            ],
          ),

          if (recentTitles.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Jeux récents', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...recentTitles.map((g) => Card(
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => GameDetailPage(title: g)),
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: g.boxArtUrl != null
                          ? CachedNetworkImage(
                              imageUrl: g.boxArtUrl!, width: 44, height: 44, fit: BoxFit.cover)
                          : Container(
                              width: 44,
                              height: 44,
                              color: scheme.surfaceContainerHigh,
                              child: const Icon(Icons.videogame_asset)),
                    ),
                    title: Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${g.progressPercentage.toStringAsFixed(0)}% · '
                        '${g.currentGamerscore}/${g.totalGamerscore} G'),
                  ),
                )),
          ],

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Détails indisponibles : $_error',
                  style: TextStyle(color: scheme.error, fontSize: 12)),
            )
          else if (_profile?.bio != null && _profile!.bio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_profile!.bio!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleMedium),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
