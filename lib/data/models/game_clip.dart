// Game clip / screenshot media model
class GameClip {
  final String id;
  final String titleName;
  final String thumbnailUrl;
  final String downloadUrl;
  final DateTime dateRecorded;
  final Duration duration;

  GameClip({
    required this.id,
    required this.titleName,
    required this.thumbnailUrl,
    required this.downloadUrl,
    required this.dateRecorded,
    required this.duration,
  });

  factory GameClip.fromJson(Map<String, dynamic> json) {
    final thumbnails = json['thumbnails'] as List? ?? [];
    final contentLocators = json['gameClipUris'] as List? ?? [];
    return GameClip(
      id: json['gameClipId'] ?? '',
      titleName: json['titleName'] ?? '',
      thumbnailUrl: thumbnails.isNotEmpty ? thumbnails[0]['uri'] ?? '' : '',
      downloadUrl:
          contentLocators.isNotEmpty ? contentLocators[0]['uri'] ?? '' : '',
      dateRecorded:
          DateTime.tryParse(json['dateRecorded'] ?? '') ?? DateTime.now(),
      duration: Duration(
        milliseconds: ((json['durationInSeconds'] ?? 0) as num).toInt() * 1000,
      ),
    );
  }
}
