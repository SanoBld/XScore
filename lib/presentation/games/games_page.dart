import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/title_summary.dart';
import '../providers/xbox_data_provider.dart';
import 'game_detail_page.dart';

enum _GameFilter { recent, completed, gamerscore, alpha, inProgress }

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  _GameFilter _filter = _GameFilter.recent;

  List<TitleSummary> _apply(List<TitleSummary> titles) {
    final list = [...titles];
    switch (_filter) {
      case _GameFilter.recent:
        list.sort((a, b) => (b.lastPlayed ?? DateTime(2000))
            .compareTo(a.lastPlayed ?? DateTime(2000)));
        break;
      case _GameFilter.completed:
        return list.where((g) => g.progressPercentage >= 100).toList();
      case _GameFilter.inProgress:
        return list
            .where((g) => g.progressPercentage > 0 && g.progressPercentage < 100)
            .toList();
      case _GameFilter.gamerscore:
        list.sort((a, b) => b.currentGamerscore.compareTo(a.currentGamerscore));
        break;
      case _GameFilter.alpha:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final data = context.watch<XboxDataProvider>();
    final scheme = Theme.of(context).colorScheme;
    final titles = _apply(data.titles);

    return Scaffold(
      appBar: AppBar(title: Text(t.gamesTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Récents',
                    icon: Icons.history,
                    selected: _filter == _GameFilter.recent,
                    onTap: () => setState(() => _filter = _GameFilter.recent),
                  ),
                  _FilterChip(
                    label: 'Terminés (100%)',
                    icon: Icons.check_circle_outline,
                    selected: _filter == _GameFilter.completed,
                    onTap: () => setState(() => _filter = _GameFilter.completed),
                  ),
                  _FilterChip(
                    label: 'En cours',
                    icon: Icons.timelapse,
                    selected: _filter == _GameFilter.inProgress,
                    onTap: () => setState(() => _filter = _GameFilter.inProgress),
                  ),
                  _FilterChip(
                    label: 'Gamerscore',
                    icon: Icons.emoji_events_outlined,
                    selected: _filter == _GameFilter.gamerscore,
                    onTap: () => setState(() => _filter = _GameFilter.gamerscore),
                  ),
                  _FilterChip(
                    label: 'A-Z',
                    icon: Icons.sort_by_alpha,
                    selected: _filter == _GameFilter.alpha,
                    onTap: () => setState(() => _filter = _GameFilter.alpha),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<XboxDataProvider>().loadAll(force: true),
              child: data.loading && data.titles.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : titles.isEmpty
                      ? ListView(children: const [
                          Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: Text('—')),
                          )
                        ])
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: titles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final g = titles[i];
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
                                          errorWidget: (_, __, ___) => Container(
                                              width: 48,
                                              height: 48,
                                              color: scheme.surfaceContainerHigh,
                                              child: const Icon(Icons.videogame_asset)),
                                        )
                                      : Container(
                                          width: 48,
                                          height: 48,
                                          color: scheme.surfaceContainerHigh,
                                          child: const Icon(Icons.videogame_asset),
                                        ),
                                ),
                                title: Text(g.name,
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (g.progressPercentage / 100).clamp(0, 1),
                                        minHeight: 6,
                                        color: g.progressPercentage >= 100
                                            ? Colors.amber
                                            : null,
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
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        avatar: Icon(icon, size: 16),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}