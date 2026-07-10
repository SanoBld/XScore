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

    // Some responses nest gamerscore/progress under "achievement",
    // others put it flat on the title object — support both.
    final achievement = json['achievement'] as Map<String, dynamic>?;
    final current = achievement?['currentGamerscore'] ?? json['currentGamerscore'];
    final total = achievement?['totalGamerscore'] ??
        achievement?['maxGamerscore'] ??
        json['maxGamerscore'];
    final progress = achievement?['progressPercentage'] ??
        json['progressPercentage'];

    final lastPlayedRaw = json['titleHistory']?['lastTimePlayed'] ??
        json['lastTimePlayed'];

    return TitleSummary(
      titleId: '${json['titleId'] ?? ''}',
      name: json['name'] ?? '',
      boxArtUrl: boxArt != null ? boxArt['url'] as String? : null,
      currentGamerscore: int.tryParse('${current ?? 0}') ?? 0,
      totalGamerscore: int.tryParse('${total ?? 0}') ?? 0,
      progressPercentage: double.tryParse('${progress ?? 0}') ?? 0,
      lastPlayed: lastPlayedRaw != null ? DateTime.tryParse(lastPlayedRaw) : null,
    );
  }
}