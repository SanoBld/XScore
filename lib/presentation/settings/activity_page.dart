import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'settings_section.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  Future<void> _confirmEnable(BuildContext context, bool value) async {
    final settings = context.read<SettingsProvider>();
    if (!value) {
      await settings.setShowAchievementActivity(false);
      return;
    }
    if (settings.hasSeenAchievementQuotaWarning) {
      await settings.setShowAchievementActivity(true);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ça va consommer du quota'),
        content: const Text(
          'Afficher tes vrais succès récents demande un appel API par jeu '
          'récemment joué (jusqu\'à 6 requêtes à chaque actualisation), sur '
          'ton quota gratuit de 150 requêtes/heure. Tu peux le désactiver à '
          'tout moment ici.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Activer')),
        ],
      ),
    );
    if (confirmed == true) {
      await settings.markAchievementQuotaWarningSeen();
      await settings.setShowAchievementActivity(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Activité')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSection(
            title: 'Tableau de bord',
            icon: Icons.emoji_events_rounded,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vrais succès récents'),
                subtitle: const Text('Coûte du quota API — voir la note ci-dessous'),
                value: settings.showAchievementActivity,
                onChanged: (v) => _confirmEnable(context, v),
              ),
              const SizedBox(height: 4),
              Text(
                'Sans cette option, le tableau de bord se contente d\'une '
                'estimation basée sur les jeux joués récemment et les médias, '
                'sans requête supplémentaire.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
