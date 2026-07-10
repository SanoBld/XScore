import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/xbox_data_provider.dart';
import '../../data/models/friend.dart';
import '../../data/models/player_profile.dart';
import '../../data/models/title_summary.dart';

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
    final topGame = (_titles != null && _titles!.isNotEmpty) ? _titles!.first : null;

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

          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.emoji_events_outlined,
                  label: 'Gamerscore',
                  value: '${f.gamerscore}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.videogame_asset_outlined,
                  label: 'Jeux',
                  value: _titles != null ? '${_titles!.length}' : '—',
                ),
              ),
            ],
          ),

          if (topGame != null) ...[
            const SizedBox(height: 20),
            Text('Jeu le plus récent', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: topGame.boxArtUrl != null
                      ? CachedNetworkImage(
                          imageUrl: topGame.boxArtUrl!, width: 44, height: 44, fit: BoxFit.cover)
                      : Container(
                          width: 44,
                          height: 44,
                          color: scheme.surfaceContainerHigh,
                          child: const Icon(Icons.videogame_asset)),
                ),
                title: Text(topGame.name),
                subtitle: Text('${topGame.progressPercentage.toStringAsFixed(0)}% terminé'),
              ),
            ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary, size: 20),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}