import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/xbox_data_provider.dart';
import '../games/game_detail_page.dart';
import '../social/friend_profile_page.dart';

// Client-side search across already-loaded data (titles + friends) — no
// extra API calls, so it doesn't touch the OpenXBL quota.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<XboxDataProvider>();
    final scheme = Theme.of(context).colorScheme;
    final q = _query.trim().toLowerCase();

    final games = q.isEmpty
        ? const []
        : data.titles.where((t) => t.name.toLowerCase().contains(q)).toList();
    final friends = q.isEmpty
        ? const []
        : data.friends.where((f) => f.gamertag.toLowerCase().contains(q)).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Rechercher un jeu ou un profil…',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() {
                _ctrl.clear();
                _query = '';
              }),
            ),
        ],
      ),
      body: q.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Tape pour chercher parmi tes jeux et tes amis.')),
            )
          : (games.isEmpty && friends.isEmpty)
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Aucun résultat.')),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (games.isNotEmpty) ...[
                      Text('Jeux (${games.length})',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...games.map((g) => Card(
                            child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => GameDetailPage(title: g)),
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: g.boxArtUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: g.boxArtUrl!,
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => Container(
                                            width: 44,
                                            height: 44,
                                            color: scheme.surfaceContainerHigh),
                                      )
                                    : Container(
                                        width: 44,
                                        height: 44,
                                        color: scheme.surfaceContainerHigh,
                                        child: const Icon(Icons.videogame_asset)),
                              ),
                              title: Text(g.name),
                              subtitle: Text('${g.currentGamerscore}/${g.totalGamerscore} G'),
                            ),
                          )),
                      const SizedBox(height: 20),
                    ],
                    if (friends.isNotEmpty) ...[
                      Text('Profils (${friends.length})',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...friends.map((f) => Card(
                            child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => FriendProfilePage(friend: f)),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: scheme.primaryContainer,
                                backgroundImage: f.gamerpicUrl != null
                                    ? CachedNetworkImageProvider(f.gamerpicUrl!)
                                    : null,
                                child: f.gamerpicUrl == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(f.gamertag),
                              subtitle: Text('${f.gamerscore} G'),
                            ),
                          )),
                    ],
                  ],
                ),
    );
  }
}
