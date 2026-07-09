import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/game_clip.dart';
import '../providers/xbox_data_provider.dart';

class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.mediaTitle),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.videocam_outlined), text: 'Clips'),
            Tab(icon: Icon(Icons.photo_camera_outlined), text: 'Captures'),
          ]),
        ),
        body: Consumer<XboxDataProvider>(
          builder: (context, data, _) {
            return RefreshIndicator(
              onRefresh: () => data.loadAll(force: true),
              child: TabBarView(children: [
                _MediaGrid(items: data.gameClips, loading: data.loading),
                _MediaGrid(items: data.screenshots, loading: data.loading),
              ]),
            );
          },
        ),
      ),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  final List<GameClip> items;
  final bool loading;
  const _MediaGrid({required this.items, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return ListView(children: const [
        Padding(padding: EdgeInsets.all(32), child: Center(child: Text('—')))
      ]);
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 16 / 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final m = items[i];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              m.thumbnailUrl.isNotEmpty
                  ? Image.network(m.thumbnailUrl, fit: BoxFit.cover)
                  : Container(color: Theme.of(context).colorScheme.surfaceContainerHigh),
              Positioned(
                left: 6,
                bottom: 6,
                right: 6,
                child: Text(
                  m.titleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}