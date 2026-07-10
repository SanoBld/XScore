import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../providers/xbox_data_provider.dart';
import 'friend_profile_page.dart';

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final data = context.watch<XboxDataProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.socialTitle)),
      body: RefreshIndicator(
        onRefresh: () => context.read<XboxDataProvider>().loadAll(force: true),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // OpenXBL n'expose pas d'endpoint de messagerie classique côté
            // amis (le chat Xbox existe côté /v2/conversations mais nécessite
            // un flux SSO app, pas une clé perso) — non implémenté ici.
            Card(
              color: scheme.surfaceContainerLow,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Messagerie Xbox non disponible avec une clé personnelle.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
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
            else if (data.friends.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('—')),
              )
            else
              ...data.sortedFriends.map((f) => Card(
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
                                  border: Border.all(
                                      color: scheme.surface, width: 2),
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
        ),
      ),
    );
  }
}