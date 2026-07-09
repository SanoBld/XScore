// Player profile data model
class PlayerProfile {
  final String xuid;
  final String gamertag;
  final int gamerscore;
  final String gamerpicUrl;
  final String accountTier;

  PlayerProfile({
    required this.xuid,
    required this.gamertag,
    required this.gamerscore,
    required this.gamerpicUrl,
    required this.accountTier,
  });

  // Parse OpenXBL /account response shape
  factory PlayerProfile.fromAccountJson(Map<String, dynamic> json) {
    final user = (json['profileUsers'] as List).first;
    final settings = <String, String>{
      for (final s in user['settings']) s['id']: s['value'].toString(),
    };
    return PlayerProfile(
      xuid: user['id'],
      gamertag: settings['Gamertag'] ?? '',
      gamerscore: int.tryParse(settings['Gamerscore'] ?? '0') ?? 0,
      gamerpicUrl: settings['GameDisplayPicRaw'] ?? '',
      accountTier: settings['AccountTier'] ?? '',
    );
  }
}
