import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../providers/xbox_data_provider.dart';
import '../setup/setup_screen.dart';
import 'settings_section.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final TextEditingController _apiKeyCtrl;
  late final TextEditingController _igdbIdCtrl;
  late final TextEditingController _igdbSecretCtrl;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _apiKeyCtrl = TextEditingController(text: settings.apiKey ?? '');
    _igdbIdCtrl = TextEditingController(text: settings.igdbClientId ?? '');
    _igdbSecretCtrl = TextEditingController(text: settings.igdbClientSecret ?? '');
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _igdbIdCtrl.dispose();
    _igdbSecretCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Compte')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSection(
            title: t.settingsApiKey,
            icon: Icons.vpn_key_rounded,
            children: [
              TextField(
                controller: _apiKeyCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: t.settingsApiKeyHint,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save_outlined),
                    onPressed: () =>
                        context.read<SettingsProvider>().setApiKey(_apiKeyCtrl.text),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => launchUrl(Uri.parse('https://xbl.io')),
                  icon: const Icon(Icons.open_in_new, size: 15),
                  label: const Text('Obtenir une clé gratuite sur xbl.io'),
                ),
              ),
              const SizedBox(height: 12),
              const _QuotaBar(),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Afficher le quota sur le tableau de bord'),
                subtitle: const Text('Petite ligne discrète sous l\'en-tête'),
                value: settings.showQuotaOnDashboard,
                onChanged: (v) => context.read<SettingsProvider>().setShowQuotaOnDashboard(v),
              ),
              Text(
                'Le quota affiché est propre à cet appareil : OpenXBL ne '
                'permet pas de le synchroniser en temps réel entre PC et mobile.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SettingsSection(
            title: 'Enrichissement IGDB (optionnel)',
            icon: Icons.auto_awesome_rounded,
            children: [
              Text(
                'Ajoute genre, note, synopsis et date de sortie sur la fiche '
                'des jeux. Nécessite un compte Twitch Developer gratuit, '
                'séparé de ta clé OpenXBL.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      launchUrl(Uri.parse('https://dev.twitch.tv/console/apps')),
                  icon: const Icon(Icons.open_in_new, size: 15),
                  label: const Text('Créer une app sur dev.twitch.tv'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _igdbIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Client ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _igdbSecretCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Client Secret',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => context
                      .read<SettingsProvider>()
                      .setIgdbCredentials(_igdbIdCtrl.text.trim(), _igdbSecretCtrl.text.trim()),
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Se déconnecter ?'),
                  content: const Text('Ta clé API sera supprimée de l\'appareil.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Annuler')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Se déconnecter')),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<SettingsProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SetupScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _QuotaBar extends StatelessWidget {
  const _QuotaBar();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<XboxDataProvider>();
    final scheme = Theme.of(context).colorScheme;

    final limit = data.quotaLimit;
    final spent = data.quotaSpent;
    final remaining = data.quotaRemaining;

    if (limit == null || spent == null) {
      return Text(
        'Quota gratuit OpenXBL : 150 requêtes / heure. Le chiffre exact '
        's\'affichera après le premier appel.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    final ratio = (spent / limit).clamp(0, 1).toDouble();
    final color = ratio > 0.85
        ? scheme.error
        : ratio > 0.6
            ? Colors.orange
            : scheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quota OpenXBL', style: Theme.of(context).textTheme.labelMedium),
            Text('$spent / $limit  (reste $remaining)',
                style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            color: color,
            backgroundColor: scheme.surfaceContainerHigh,
          ),
        ),
      ],
    );
  }
}
