// Friend / follower entry
class Friend {
  final String xuid;
  final String gamertag;
  final String? gamerpicUrl;
  final int gamerscore;
  final bool isOnline;

  Friend({
    required this.xuid,
    required this.gamertag,
    required this.gamerscore,
    this.gamerpicUrl,
    this.isOnline = false,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    // OpenXBL isn't consistent: /friends uses lowercase "gamerscore",
    // /search/{gamertag} uses "gamerScore" — support both.
    final scoreRaw = json['gamerscore'] ?? json['gamerScore'] ?? json['Gamerscore'];

    return Friend(
      xuid: '${json['xuid'] ?? json['id'] ?? ''}',
      gamertag: json['gamertag'] ?? json['modernGamertag'] ?? '',
      gamerpicUrl: json['displayPicRaw'] ?? json['gamerpic'],
      gamerscore: int.tryParse('$scoreRaw') ?? 0,
      isOnline: (json['presenceState'] ?? '') == 'Online',
    );
  }
}