// Achievement data model
class Achievement {
  final String id;
  final String name;
  final String description;
  final int gamerscore;
  final bool unlocked;
  final String iconUrl;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.gamerscore,
    required this.unlocked,
    required this.iconUrl,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    final reward = (json['rewards'] as List?)?.firstWhere(
      (r) => r['type'] == 'Gamerscore',
      orElse: () => {'value': '0'},
    );
    return Achievement(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      gamerscore: int.tryParse(reward?['value']?.toString() ?? '0') ?? 0,
      unlocked: (json['progressState'] ?? '') == 'Achieved',
      iconUrl: json['mediaAssets'] != null &&
              (json['mediaAssets'] as List).isNotEmpty
          ? json['mediaAssets'][0]['url'] ?? ''
          : '',
    );
  }
}
