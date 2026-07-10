// Game clip or screenshot entry
class GameClip {
  final String id;
  final String titleName;
  final String thumbnailUrl;
  final String mediaUrl;
  final DateTime date;

  GameClip({
    required this.id,
    required this.titleName,
    required this.thumbnailUrl,
    required this.mediaUrl,
    required this.date,
  });

  factory GameClip.fromJson(Map<String, dynamic> json) {
    final thumbs = (json['thumbnails'] as List?) ?? [];
    final uris = (json['gameClipUris'] as List?) ??
        (json['screenshotUris'] as List?) ??
        [];

    // gameClipUris/screenshotUris mix several entries (thumbnails, previews,
    // full download) tagged by "uriType". Picking list.last isn't reliable —
    // OpenXBL doesn't guarantee ordering, so a low-res/broken preview URI
    // could be selected, which is what made playback fail. Prefer the
    // "Download" (full quality) entry explicitly, else fall back safely.
    String bestUrl(List list) {
      if (list.isEmpty) return '';
      final download = list.firstWhere(
        (e) => (e['uriType'] ?? '').toString().toLowerCase() == 'download',
        orElse: () => null,
      );
      if (download != null && (download['uri'] ?? '').toString().isNotEmpty) {
        return download['uri'];
      }
      return list.last['uri'] ?? list.first['uri'] ?? '';
    }

    return GameClip(
      id: '${json['gameClipId'] ?? json['screenshotId'] ?? ''}',
      titleName: json['titleName'] ?? '',
      thumbnailUrl: bestUrl(thumbs),
      mediaUrl: bestUrl(uris),
      date: DateTime.tryParse(json['dateRecorded'] ?? '') ?? DateTime.now(),
    );
  }
}