import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/title_summary.dart';
import '../providers/xbox_data_provider.dart';
import '../providers/settings_provider.dart';
import 'game_detail_page.dart';

enum _GameFilter { recent, completed, gamerscore, alpha, inProgress }

const _filterLabels = {
  _GameFilter.recent: 'Récents',
  _GameFilter.completed: 'Terminés (100%)',
  _GameFilter.inProgress: 'En cours',
  _GameFilter.gamerscore: 'Gamerscore',
  _GameFilter.alpha: 'A-Z',
};

const _filterIcons = {
  _GameFilter.recent: Icons.history,
  _GameFilter.completed: Icons.check_circle_outline,
  _GameFilter.inProgress: Icons.timelapse,
  _GameFilter.gamerscore: Icons.emoji_events_outlined,
  _GameFilter.alpha: Icons.sort_by_alpha,
};

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

  Future<void> _openFilterSheet() async {
    final chosen = await showModalBottomSheet<_GameFilter>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Trier / filtrer',
                    style: Theme.of(ctx).textTheme.titleMedium),
              ),
            ),
            ..._GameFilter.values.map((f) => ListTile(
                  leading: Icon(_filterIcons[f]),
                  title: Text(_filterLabels[f]!),
                  trailing: _filter == f ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(ctx, f),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _filter = chosen);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final data = context.watch<XboxDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final titles = _apply(data.titles);
    final isGrid = settings.gamesGridLayout;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.gamesTitle),
        actions: [
          IconButton(
            tooltip: isGrid ? 'Vue liste' : 'Vue grille',
            icon: Icon(isGrid ? Icons.view_list_outlined : Icons.grid_view_outlined),
            onPressed: () => context
                .read<SettingsProvider>()
                .setGamesGridLayout(!isGrid),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _openFilterSheet,
                icon: Icon(_filterIcons[_filter], size: 18),
                label: Text(_filterLabels[_filter]!),
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
                      : isGrid
                          ? _GamesGrid(titles: titles, scheme: scheme)
                          : _GamesList(titles: titles, scheme: scheme),
            ),
          ),
        ],
      ),
    );
  }
}

class _GamesList extends StatelessWidget {
  final List<TitleSummary> titles;
  final ColorScheme scheme;
  const _GamesList({required this.titles, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: titles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final g = titles[i];
        return Card(
          child: ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GameDetailPage(title: g)),
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
                          width: 48, height: 48, color: scheme.surfaceContainerHigh),
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
                    color: g.progressPercentage >= 100 ? Colors.amber : null,
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
    );
  }
}

// Alternate display mode requested by the user, persisted via SettingsProvider
class _GamesGrid extends StatelessWidget {
  final List<TitleSummary> titles;
  final ColorScheme scheme;
  const _GamesGrid({required this.titles, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: titles.length,
      itemBuilder: (context, i) {
        final g = titles[i];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => GameDetailPage(title: g)),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  g.boxArtUrl != null
                      ? CachedNetworkImage(
                          imageUrl: g.boxArtUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Container(color: scheme.surfaceContainerHigh),
                        )
                      : Container(
                          color: scheme.surfaceContainerHigh,
                          child: const Icon(Icons.videogame_asset),
                        ),
                  // Darken the art so a white, left-aligned title stays
                  // readable regardless of the cover's own colors — poster
                  // grids read better with the label baked over the image
                  // than as separate text underneath it. Two stops instead
                  // of one gives a softer, more premium falloff.
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black54,
                          Colors.black87,
                        ],
                        stops: [0.0, 0.45, 0.75, 1.0],
                      ),
                    ),
                  ),
                  if (g.progressPercentage >= 100)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 12, color: Colors.black),
                      ),
                    ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          g.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                          ),
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (g.progressPercentage / 100).clamp(0, 1),
                            minHeight: 3.5,
                            backgroundColor: Colors.white24,
                            color: g.progressPercentage >= 100 ? Colors.amber : scheme.primary,
                          ),
                        ),
                      ],
                    ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}
