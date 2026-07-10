import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.isClip && widget.media.mediaUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.media.mediaUrl))
        ..initialize().then((_) {
          if (mounted) setState(() {});
          _controller!.play();
        }).catchError((e) {
          if (mounted) setState(() => _videoError = '$e');
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.media.titleName),
      ),
      body: Center(
        child: widget.isClip ? _buildVideo() : _buildImage(),
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
        child: Text('Lecture impossible : $_videoError',
            style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
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
    // Full mediaUrl (original quality) instead of the compressed thumbnail
    final url = widget.media.mediaUrl.isNotEmpty
        ? widget.media.mediaUrl
        : widget.media.thumbnailUrl;
    return InteractiveViewer(
      maxScale: 4,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        placeholder: (_, __) => const CircularProgressIndicator(),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
      ),
    );
  }
}