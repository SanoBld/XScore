// Single achievement entry
class Achievement {
  final String id;
  final String name;
  final String description;
  final int gamerscore;
  final bool unlocked;
  final String? iconUrl;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.gamerscore,
    required this.unlocked,
    this.iconUrl,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    final rewards = (json['rewards'] as List?) ?? [];
    final gamerscore = rewards.isNotEmpty
        ? int.tryParse('${rewards.first['value']}') ?? 0
        : 0;
    final media = (json['mediaAssets'] as List?) ?? [];
    final icon = media.isNotEmpty ? media.first['url'] as String? : null;

    return Achievement(
      id: '${json['id']}',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      gamerscore: gamerscore,
      unlocked: json['progressState'] == 'Achieved',
      iconUrl: icon,
    );
  }
}
