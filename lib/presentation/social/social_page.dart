import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../providers/xbox_data_provider.dart';

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
            // OpenXBL n'expose pas d'endpoint de messagerie (chat Xbox non
            // disponible via cette API non-officielle) — impossible à implémenter.
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
                        "Le chat Xbox n'est pas accessible via cette API.",
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
            else if (data.friends.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('—')),
              )
            else
              ...data.sortedFriends.map((f) => Card(
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: scheme.primaryContainer,
                            backgroundImage: f.gamerpicUrl != null
                                ? NetworkImage(f.gamerpicUrl!)
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
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}