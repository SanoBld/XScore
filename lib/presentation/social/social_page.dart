import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../providers/xbox_data_provider.dart';
import '../../data/models/friend.dart';
import 'friend_profile_page.dart';

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final data = context.watch<XboxDataProvider>();
    final scheme = Theme.of(context).colorScheme;
    final online = data.friends.where((f) => f.isOnline).toList();
    final all = data.sortedFriends;

    return Scaffold(
      appBar: AppBar(title: Text(t.socialTitle)),
      body: RefreshIndicator(
        onRefresh: () => context.read<XboxDataProvider>().loadAll(force: true),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (data.loading && data.friends.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (data.friendsError != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(data.friendsError!, style: TextStyle(color: scheme.error)),
              )
            else ...[
              // Online friends pinned first, horizontal highlight row
              if (online.isNotEmpty) ...[
                Text('En ligne (${online.length})',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: online.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final f = online[i];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FriendProfilePage(friend: f)),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: scheme.primaryContainer,
                                  backgroundImage: f.gamerpicUrl != null
                                      ? CachedNetworkImageProvider(f.gamerpicUrl!)
                                      : null,
                                  child: f.gamerpicUrl == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: scheme.surface, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 60,
                              child: Text(f.gamertag,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text('Tous les amis (${all.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (all.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('—')),
                )
              else
                ...all.map((f) => Card(
                      child: ListTile(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FriendProfilePage(friend: f)),
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: scheme.primaryContainer,
                              backgroundImage: f.gamerpicUrl != null
                                  ? CachedNetworkImageProvider(f.gamerpicUrl!)
                                  : null,
                              child: f.gamerpicUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            if (f.isOnline)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: scheme.surface, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(f.gamertag),
                        subtitle: Text('${f.gamerscore} G'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    )),
            ],

            const SizedBox(height: 20),
            if (data.profile != null)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    backgroundImage: data.profile!.gamerpicUrl != null
                        ? CachedNetworkImageProvider(data.profile!.gamerpicUrl!)
                        : null,
                    child: data.profile!.gamerpicUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text('Voir mon profil'),
                  subtitle: Text(data.profile!.gamertag),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final p = data.profile!;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FriendProfilePage(
                          friend: Friend(
                            xuid: p.xuid,
                            gamertag: p.gamertag,
                            gamerscore: p.gamerscore,
                            gamerpicUrl: p.gamerpicUrl,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}