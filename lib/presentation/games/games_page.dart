import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../providers/xbox_data_provider.dart';

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
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: g.boxArtUrl != null
                                ? Image.network(g.boxArtUrl!,
                                    width: 48, height: 48, fit: BoxFit.cover)
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