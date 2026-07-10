import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/game_clip.dart';

class MediaViewerPage extends StatelessWidget {
  final GameClip media;
  final bool isClip;
  const MediaViewerPage({super.key, required this.media, required this.isClip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(media.titleName),
        actions: [
          if (isClip)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Ouvrir la vidéo',
              onPressed: () => launchUrl(Uri.parse(media.mediaUrl),
                  mode: LaunchMode.externalApplication),
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4,
          child: CachedNetworkImage(
            imageUrl: media.thumbnailUrl.isNotEmpty ? media.thumbnailUrl : media.mediaUrl,
            fit: BoxFit.contain,
            placeholder: (_, __) => const CircularProgressIndicator(),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
          ),
        ),
      ),
      bottomNavigationBar: isClip
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () => launchUrl(Uri.parse(media.mediaUrl),
                      mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Lire le clip'),
                ),
              ),
            )
          : null,
    );
  }
}
