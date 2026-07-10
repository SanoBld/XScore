import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../providers/xbox_data_provider.dart';
import 'game_detail_page.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final data = context.watch<XboxDataProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.gamesTitle)),
      body: RefreshIndicator(
        onRefresh: () => context.read<XboxDataProvider>().loadAll(force: true),
        child: data.loading && data.titles.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : data.titles.isEmpty
                ? ListView(children: const [
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('—')),
                    )
                  ])
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: data.titles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final g = data.titles[i];
                      return Card(
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => GameDetailPage(title: g)),
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: g.boxArtUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: g.boxArtUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                        width: 48,
                                        height: 48,
                                        color: scheme.surfaceContainerHigh),
                                  )
                                : Container(
                                    width: 48,
                                    height: 48,
                                    color: scheme.surfaceContainerHigh,
                                    child: const Icon(Icons.videogame_asset),
                                  ),
                          ),
                          title: Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (g.progressPercentage / 100).clamp(0, 1),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${g.currentGamerscore}/${g.totalGamerscore}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}