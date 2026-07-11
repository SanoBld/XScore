import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/game_clip.dart';
import '../providers/xbox_data_provider.dart';
import 'media_viewer_page.dart';

enum _SortOrder { recent, oldest }

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
                _MediaGrid(items: data.gameClips, loading: data.loading, isClip: true),
                _MediaGrid(items: data.screenshots, loading: data.loading, isClip: false),
              ]),
            );
          },
        ),
      ),
    );
  }
}

class _MediaGrid extends StatefulWidget {
  final List<GameClip> items;
  final bool loading;
  final bool isClip;
  const _MediaGrid({required this.items, required this.loading, required this.isClip});

  @override
  State<_MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<_MediaGrid> {
  String? _gameFilter; // null = tous les jeux
  _SortOrder _sort = _SortOrder.recent;
  final Set<String> _selected = {};
  bool get _selecting => _selected.isNotEmpty;
  bool _downloadingBulk = false;

  List<GameClip> get _filtered {
    var list = widget.items;
    if (_gameFilter != null) {
      list = list.where((m) => m.titleName == _gameFilter).toList();
    }
    list = [...list]..sort((a, b) =>
        _sort == _SortOrder.recent ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
    return list;
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<Directory> _resolveDownloadsDir() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) return dir;
      return await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    }
    if (Platform.isIOS) return getApplicationDocumentsDirectory();
    return await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  }

  Future<void> _downloadSelected() async {
    final items = widget.items.where((m) => _selected.contains(m.id)).toList();
    if (items.isEmpty || _downloadingBulk) return;
    setState(() => _downloadingBulk = true);
    final dir = await _resolveDownloadsDir();
    var ok = 0;
    for (final m in items) {
      final url = m.mediaUrl.isNotEmpty ? m.mediaUrl : m.thumbnailUrl;
      if (url.isEmpty) continue;
      try {
        final res = await http.get(Uri.parse(url));
        if (res.statusCode != 200) continue;
        final ext = widget.isClip ? 'mp4' : 'png';
        final file = File('${dir.path}/xscore_${m.id}.$ext');
        await file.writeAsBytes(res.bodyBytes);
        ok++;
      } catch (_) {
        // Skip failed items, keep going with the rest of the selection
      }
    }
    if (!mounted) return;
    setState(() {
      _downloadingBulk = false;
      _selected.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$ok/${items.length} téléchargés dans Téléchargements')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (widget.loading && widget.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.items.isEmpty) {
      return ListView(children: const [
        Padding(padding: EdgeInsets.all(32), child: Center(child: Text('—')))
      ]);
    }

    final games = widget.items.map((m) => m.titleName).toSet().toList()..sort();
    final filtered = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tous les jeux'),
                        selected: _gameFilter == null,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _gameFilter = null),
                      ),
                      const SizedBox(width: 8),
                      ...games.map((g) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(g, overflow: TextOverflow.ellipsis),
                              selected: _gameFilter == g,
                              showCheckmark: false,
                              onSelected: (_) => setState(() => _gameFilter = g),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: _sort == _SortOrder.recent ? 'Plus récent d\'abord' : 'Plus ancien d\'abord',
                icon: Icon(_sort == _SortOrder.recent
                    ? Icons.arrow_downward
                    : Icons.arrow_upward),
                onPressed: () => setState(() {
                  _sort = _sort == _SortOrder.recent ? _SortOrder.oldest : _SortOrder.recent;
                }),
              ),
            ],
          ),
        ),
        if (_selecting)
          Container(
            width: double.infinity,
            color: scheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Text('${_selected.length} sélectionné(s)',
                    style: TextStyle(color: scheme.onPrimaryContainer)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() =>
                      _selected..clear()..addAll(filtered.map((m) => m.id))),
                  child: const Text('Tout sélectionner'),
                ),
                TextButton(
                  onPressed: () => setState(() => _selected.clear()),
                  child: const Text('Annuler'),
                ),
                FilledButton.icon(
                  onPressed: _downloadingBulk ? null : _downloadSelected,
                  icon: _downloadingBulk
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Télécharger'),
                ),
              ],
            ),
          ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('—'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 16 / 10,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final m = filtered[i];
                    final selected = _selected.contains(m.id);
                    return GestureDetector(
                      onLongPress: () => _toggleSelect(m.id),
                      onTap: _selecting
                          ? () => _toggleSelect(m.id)
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => MediaViewerPage(
                                        items: filtered,
                                        initialIndex: i,
                                        isClip: widget.isClip)),
                              ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            m.thumbnailUrl.isNotEmpty
                                ? CachedNetworkImage(imageUrl: m.thumbnailUrl, fit: BoxFit.cover)
                                : Container(color: scheme.surfaceContainerHigh),
                            if (widget.isClip && !_selecting)
                              const Center(
                                child: Icon(Icons.play_circle_fill,
                                    color: Colors.white70, size: 36),
                              ),
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
                            if (_selecting)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Icon(
                                  selected ? Icons.check_circle : Icons.circle_outlined,
                                  color: selected ? scheme.primary : Colors.white,
                                ),
                              ),
                            if (selected)
                              Container(color: scheme.primary.withValues(alpha: 0.25)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
