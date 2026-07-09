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
    return Friend(
      xuid: '${json['xuid']}',
      gamertag: json['gamertag'] ?? json['modernGamertag'] ?? '',
      gamerpicUrl: json['displayPicRaw'],
      gamerscore: int.tryParse('${json['gamerscore']}') ?? 0,
      isOnline: (json['presenceState'] ?? '') == 'Online',
    );
  }
}
