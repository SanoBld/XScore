// Single achievement entry
class Achievement {
  final String id;
  final String name;
  final String description;
  final int gamerscore;
  final bool unlocked;
  final DateTime? unlockedAt;
  final String? iconUrl;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.gamerscore,
    required this.unlocked,
    this.unlockedAt,
    this.iconUrl,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    final rewards = (json['rewards'] as List?) ?? [];
    final gamerscore = rewards.isNotEmpty
        ? int.tryParse('${rewards.first['value']}') ?? 0
        : 0;
    final media = (json['mediaAssets'] as List?) ?? [];
    final icon = media.isNotEmpty ? media.first['url'] as String? : null;

    // OpenXBL doesn't return the exact same shape for every title: modern
    // Xbox One/Series games use progressState == 'Achieved', but some
    // (notably older/Xbox 360-era) titles use a plain boolean or nest it
    // under "progression". This was the "0 débloqué" bug — the strict
    // progressState check silently failed and every achievement read as
    // locked even when the API had it marked unlocked.
    final progression = json['progression'] as Map<String, dynamic>?;
    final unlocked = json['progressState'] == 'Achieved' ||
        json['unlocked'] == true ||
        json['isUnlocked'] == true ||
        progression?['progressState'] == 'Achieved';

    final unlockedAtRaw = progression?['timeUnlocked'] ??
        json['timeUnlocked'] ??
        json['unlockTime'];
    final unlockedAt = (unlocked && unlockedAtRaw != null)
        ? DateTime.tryParse('$unlockedAtRaw')
        : null;

    return Achievement(
      id: '${json['id']}',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      gamerscore: gamerscore,
      unlocked: unlocked,
      unlockedAt: unlockedAt,
      iconUrl: icon,
    );
  }
}
