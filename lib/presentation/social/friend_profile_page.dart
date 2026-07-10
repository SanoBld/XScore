import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/xbox_data_provider.dart';
import '../../data/models/friend.dart';
import '../../data/models/player_profile.dart';

class FriendProfilePage extends StatefulWidget {
  final Friend friend;
  const FriendProfilePage({super.key, required this.friend});

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  PlayerProfile? _profile;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Reuses cached gamertag search rather than a dedicated xuid lookup
      final data = context.read<XboxDataProvider>();
      final p = await data.achievementsService.client
          .get('/account/${widget.friend.xuid}');
      if (mounted) {
        setState(() => _profile = PlayerProfile.fromAccountJson(p));
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.friend;
    final scheme = Theme.of(context).colorScheme;

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
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: const Text('Gamerscore'),
              subtitle: Text('${f.gamerscore}'),
            ),
          ),
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
