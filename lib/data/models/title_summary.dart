// One played game with achievement progress, used by Games tab
class TitleSummary {
  final String titleId;
  final String name;
  final String? boxArtUrl;
  final int currentGamerscore;
  final int totalGamerscore;
  final double progressPercentage;
  final DateTime? lastPlayed;

  TitleSummary({
    required this.titleId,
    required this.name,
    required this.currentGamerscore,
    required this.totalGamerscore,
    required this.progressPercentage,
    this.boxArtUrl,
    this.lastPlayed,
  });

  factory TitleSummary.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?) ?? [];
    final boxArt = images.firstWhere(
      (i) => i['type'] == 'BoxArt',
      orElse: () => images.isNotEmpty ? images.first : null,
    );

    return TitleSummary(
      titleId: '${json['titleId'] ?? ''}',
      name: json['name'] ?? '',
      boxArtUrl: boxArt != null ? boxArt['url'] as String? : null,
      currentGamerscore:
          int.tryParse('${json['currentGamerscore'] ?? 0}') ?? 0,
      totalGamerscore: int.tryParse('${json['maxGamerscore'] ?? 0}') ?? 0,
      progressPercentage:
          double.tryParse('${json['progressPercentage'] ?? 0}') ?? 0,
      lastPlayed: DateTime.tryParse(json['titleHistory']?['lastTimePlayed'] ?? ''),
    );
  }
}
