// Enrichment data from IGDB — genre, description, rating, release date,
// none of which OpenXBL provides at all.
class GameInfo {
  final String? summary;
  final List<String> genres;
  final double? rating; // 0-100
  final DateTime? firstReleaseDate;
  final String? coverUrl;

  GameInfo({
    this.summary,
    this.genres = const [],
    this.rating,
    this.firstReleaseDate,
    this.coverUrl,
  });

  factory GameInfo.fromJson(Map<String, dynamic> json) {
    final genresList = (json['genres'] as List?)
            ?.map((g) => (g['name'] ?? '').toString())
            .where((g) => g.isNotEmpty)
            .toList() ??
        [];

    DateTime? release;
    final ts = json['first_release_date'];
    if (ts != null) {
      release = DateTime.fromMillisecondsSinceEpoch((ts as int) * 1000);
    }

    String? cover;
    final coverObj = json['cover'];
    if (coverObj != null && coverObj['url'] != null) {
      // IGDB returns protocol-relative thumbnail URLs at t_thumb size —
      // bump to a bigger size and force https.
      cover = 'https:${coverObj['url']}'.replaceFirst('t_thumb', 't_cover_big');
    }

    return GameInfo(
      summary: json['summary'],
      genres: genresList,
      rating: (json['rating'] as num?)?.toDouble(),
      firstReleaseDate: release,
      coverUrl: cover,
    );
  }
}
