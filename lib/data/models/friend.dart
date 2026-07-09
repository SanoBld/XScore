// Friend / social connection model
class Friend {
  final String xuid;
  final String gamertag;
  final int gamerscore;
  final String gamerpicUrl;
  final bool isFollowingCaller;

  Friend({
    required this.xuid,
    required this.gamertag,
    required this.gamerscore,
    required this.gamerpicUrl,
    required this.isFollowingCaller,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        xuid: json['xuid'].toString(),
        gamertag: json['gamertag'] ?? '',
        gamerscore: int.tryParse(json['gamerScore']?.toString() ?? '0') ?? 0,
        gamerpicUrl: json['displayPicRaw'] ?? '',
        isFollowingCaller: json['isFollowingCaller'] ?? false,
      );
}
