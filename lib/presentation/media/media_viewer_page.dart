import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/game_clip.dart';

class MediaViewerPage extends StatefulWidget {
  final GameClip media;
  final bool isClip;
  const MediaViewerPage({super.key, required this.media, required this.isClip});

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  VideoPlayerController? _controller;
  String? _videoError;
  bool _downloading = false;

  String get _sourceUrl => widget.media.mediaUrl.isNotEmpty
      ? widget.media.mediaUrl
      : widget.media.thumbnailUrl;

  @override
  void initState() {
    super.initState();
    if (widget.isClip && widget.media.mediaUrl.isNotEmpty) {
      _initVideo(widget.media.mediaUrl);
    }
  }

  void _initVideo(String url) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller!.play();
      }).catchError((e) {
        if (mounted) setState(() => _videoError = '$e');
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Downloads the file locally (mobile/desktop) then opens the OS share/save
  // dialog isn't wired here to avoid extra deps; on desktop it saves to the
  // Downloads folder, on mobile to the app documents dir and opens it.
  Future<void> _download() async {
    if (_sourceUrl.isEmpty || _downloading) return;
    setState(() => _downloading = true);
    try {
      final res = await http.get(Uri.parse(_sourceUrl));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');

      final ext = widget.isClip ? 'mp4' : 'png';
      final fileName = '${widget.media.id.isNotEmpty ? widget.media.id : DateTime.now().millisecondsSinceEpoch}.$ext';

      Directory dir;
      if (Platform.isAndroid || Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      } else {
        dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(res.bodyBytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enregistré : ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Téléchargement impossible : $e')),
      );
      // Fallback: let the browser/OS handle it directly
      try {
        await launchUrl(Uri.parse(_sourceUrl), mode: LaunchMode.externalApplication);
      } catch (_) {}
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.media.titleName, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Télécharger',
            icon: _downloading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_outlined),
            onPressed: _downloading ? null : _download,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: widget.isClip ? _buildVideo() : _buildImage(),
        ),
      ),
      bottomNavigationBar: widget.isClip && _controller?.value.isInitialized == true
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: VideoProgressIndicator(_controller!, allowScrubbing: true),
              ),
            )
          : null,
      floatingActionButton: widget.isClip && _controller?.value.isInitialized == true
          ? FloatingActionButton(
              onPressed: () => setState(() {
                _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
              }),
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
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
    // Full mediaUrl (original quality) instead of the compressed thumbnail.
    // LayoutBuilder + SizedBox.expand instead of a bare InteractiveViewer:
    // without a bounded/expanded size, InteractiveViewer's child sizes
    // itself to the image's natural resolution first, causing the visible
    // "frame"/jump before it settles — this keeps it filling the screen
    // immediately from the first frame.
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
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
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