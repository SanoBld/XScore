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

    return GameClip(
      id: '${json['gameClipId'] ?? json['screenshotId'] ?? ''}',
      titleName: json['titleName'] ?? '',
      thumbnailUrl: thumbs.isNotEmpty ? thumbs.first['uri'] ?? '' : '',
      mediaUrl: uris.isNotEmpty ? uris.first['uri'] ?? '' : '',
      date: DateTime.tryParse(json['dateRecorded'] ?? '') ?? DateTime.now(),
    );
  }
}
