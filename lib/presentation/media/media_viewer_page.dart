import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/game_clip.dart';

// Full gallery viewer: swipe left/right between all items of the same type,
// like a normal phone gallery, instead of only ever showing the one that
// was tapped. Controls (top bar + bottom playback bar) share ONE visibility
// state owned here and passed down — a previous version had the bottom bar
// live inside the per-item widget with no toggle at all, so it never
// hid/faded in sync with the top bar. That mismatch is fixed below.
class MediaViewerPage extends StatefulWidget {
  final List<GameClip> items;
  final int initialIndex;
  final bool isClip;
  const MediaViewerPage({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.isClip,
  });

  factory MediaViewerPage.single({
    Key? key,
    required GameClip media,
    required bool isClip,
  }) =>
      MediaViewerPage(key: key, items: [media], initialIndex: 0, isClip: isClip);

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late final PageController _pageController;
  late int _index;
  bool _controlsVisible = true;
  bool _playing = true;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: _index);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _scheduleAutoHide();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleAutoHide() {
    if (!widget.isClip) return;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _playing) setState(() => _controlsVisible = false);
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleAutoHide();
  }

  void _setPlaying(bool playing) {
    _playing = playing;
    if (playing) _scheduleAutoHide();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.items[_index];
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _SingleMediaView(
              media: widget.items[i],
              isClip: widget.isClip,
              active: i == _index,
              controlsVisible: _controlsVisible,
              onTap: _toggleControls,
              onPlayingChanged: _setPlaying,
            ),
          ),

          // Top bar: back + title + page counter. Same fade/ignore logic
          // as the bottom bar so both move together.
          _ControlFade(
            visible: _controlsVisible,
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 4,
                left: 4,
                right: 4,
                bottom: 8,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          current.titleName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        if (widget.items.length > 1)
                          Text('${_index + 1} / ${widget.items.length}',
                              style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Shared fade + hit-test-blocking wrapper so the top and bottom bars behave
// identically instead of one being animated and the other static.
class _ControlFade extends StatelessWidget {
  final bool visible;
  final Alignment alignment;
  final Widget child;
  const _ControlFade({required this.visible, required this.alignment, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(ignoring: !visible, child: child),
      ),
    );
  }
}

class _SingleMediaView extends StatefulWidget {
  final GameClip media;
  final bool isClip;
  final bool active;
  final bool controlsVisible;
  final VoidCallback onTap;
  final ValueChanged<bool> onPlayingChanged;
  const _SingleMediaView({
    required this.media,
    required this.isClip,
    required this.active,
    required this.controlsVisible,
    required this.onTap,
    required this.onPlayingChanged,
  });

  @override
  State<_SingleMediaView> createState() => _SingleMediaViewState();
}

class _SingleMediaViewState extends State<_SingleMediaView> {
  VideoPlayerController? _controller;
  String? _videoError;
  bool _downloading = false;
  bool _muted = false;

  String get _sourceUrl =>
      widget.media.mediaUrl.isNotEmpty ? widget.media.mediaUrl : widget.media.thumbnailUrl;

  @override
  void initState() {
    super.initState();
    if (widget.isClip && widget.media.mediaUrl.isNotEmpty) {
      _initVideo(widget.media.mediaUrl);
    }
  }

  @override
  void didUpdateWidget(covariant _SingleMediaView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != null && _controller!.value.isInitialized) {
      if (widget.active) {
        _controller!.play();
        widget.onPlayingChanged(true);
      } else {
        _controller!.pause();
      }
    }
  }

  void _initVideo(String url) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        if (widget.active) {
          _controller!.play();
          widget.onPlayingChanged(true);
        }
      }).catchError((e) {
        if (mounted) setState(() => _videoError = '$e');
      });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        widget.onPlayingChanged(false);
      } else {
        _controller!.play();
        widget.onPlayingChanged(true);
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      _controller?.setVolume(_muted ? 0 : 1);
    });
  }

  Future<Directory> _resolveDownloadsDir() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) return dir;
      return await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    }
    if (Platform.isIOS) return getApplicationDocumentsDirectory();
    return await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  }

  Future<void> _download() async {
    if (_sourceUrl.isEmpty || _downloading) return;
    setState(() => _downloading = true);
    try {
      final res = await http.get(Uri.parse(_sourceUrl));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final ext = widget.isClip ? 'mp4' : 'png';
      final fileName =
          'xscore_${widget.media.id.isNotEmpty ? widget.media.id : DateTime.now().millisecondsSinceEpoch}.$ext';
      final dir = await _resolveDownloadsDir();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(res.bodyBytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enregistré dans Téléchargements : $fileName')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Téléchargement impossible : $e')),
      );
      try {
        await launchUrl(Uri.parse(_sourceUrl), mode: LaunchMode.externalApplication);
      } catch (_) {}
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Only the media itself toggles the controls on tap — the bottom
        // bar (below) is a sibling, not a child of this GestureDetector,
        // so scrubbing the progress bar or tapping a button never also
        // triggers a hide/show toggle underneath it.
        GestureDetector(
          onTap: widget.onTap,
          child: Center(child: widget.isClip ? _buildVideo() : _buildImage()),
        ),
        _ControlFade(
          visible: widget.controlsVisible,
          alignment: Alignment.bottomCenter,
          child: _bottomBar(scheme),
        ),
      ],
    );
  }

  Widget _bottomBar(ColorScheme scheme) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            if (widget.isClip && _controller?.value.isInitialized == true) ...[
              IconButton(
                icon: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
              Expanded(
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  colors: VideoProgressColors(
                    playedColor: scheme.primary,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(_muted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                onPressed: _toggleMute,
              ),
            ] else
              const Spacer(),
            IconButton(
              icon: _downloading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download_outlined, color: Colors.white),
              onPressed: _downloading ? null : _download,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideo() {
    if (_videoError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 40),
            const SizedBox(height: 12),
            Text('Lecture impossible : $_videoError',
                style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() => _videoError = null);
                _initVideo(widget.media.mediaUrl);
              },
              icon: const Icon(Icons.refresh, color: Colors.white70),
              label: const Text('Réessayer', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      );
    }
    if (_controller == null || !_controller!.value.isInitialized) {
      return const CircularProgressIndicator();
    }
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }

  Widget _buildImage() {
    final url = _sourceUrl;
    if (url.isEmpty) {
      return const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          maxScale: 4,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
              ),
            ),
          ),
        );
      },
    );
  }
}
