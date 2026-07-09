// Own or looked-up player profile
class PlayerProfile {
  final String xuid;
  final String gamertag;
  final String? gamerpicUrl;
  final int gamerscore;
  final String? bio;

  PlayerProfile({
    required this.xuid,
    required this.gamertag,
    required this.gamerscore,
    this.gamerpicUrl,
    this.bio,
  });

  factory PlayerProfile.fromAccountJson(Map<String, dynamic> json) {
    final users = (json['profileUsers'] as List?) ?? [json];
    final user = users.isNotEmpty ? users.first as Map<String, dynamic> : json;
    final settings = (user['settings'] as List?) ?? [];

    String? find(String id) {
      final match = settings.firstWhere(
        (s) => s['id'] == id,
        orElse: () => null,
      );
      return match?['value'];
    }

    return PlayerProfile(
      xuid: '${user['id'] ?? user['xuid'] ?? ''}',
      gamertag: find('Gamertag') ?? user['gamertag'] ?? '',
      gamerpicUrl: find('GameDisplayPicRaw'),
      gamerscore: int.tryParse(find('Gamerscore') ?? '0') ?? 0,
      bio: find('Bio'),
    );
  }
}
