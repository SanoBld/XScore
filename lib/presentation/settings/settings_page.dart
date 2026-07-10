import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/storage_keys.dart';
import '../providers/settings_provider.dart';
import '../providers/xbox_data_provider.dart';
import '../setup/setup_screen.dart';
import '../../data/services/update_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _apiKeyCtrl;
  bool _checking = false;
  UpdateInfo? _updateInfo;

  bool _notifEnabled = true;
  bool _notifAchievements = true;
  bool _notifFriendOnline = false;
  bool _notifClips = true;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _apiKeyCtrl = TextEditingController(text: settings.apiKey ?? '');
    _loadNotifPrefs();
  }

  Future<void> _loadNotifPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifEnabled = prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
      _notifAchievements = prefs.getBool(StorageKeys.notifyAchievements) ?? true;
      _notifFriendOnline = prefs.getBool(StorageKeys.notifyFriendOnline) ?? false;
      _notifClips = prefs.getBool(StorageKeys.notifyGameClips) ?? true;
      _prefsLoaded = true;
    });
  }

  Future<void> _setNotifPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _checkUpdate() async {
    setState(() => _checking = true);
    try {
      final info = await UpdateService().checkForUpdate();
      setState(() => _updateInfo = info);
    } catch (_) {
    } finally {
      setState(() => _checking = false);
    }
  }

  Future<void> _confirmEnableAchievementActivity(bool value) async {
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
    final t = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            icon: Icons.vpn_key_rounded,
            title: t.settingsApiKey,
            children: [
              TextField(
                controller: _apiKeyCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: t.settingsApiKeyHint,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save_outlined),
                    onPressed: () => context
                        .read<SettingsProvider>()
                        .setApiKey(_apiKeyCtrl.text),
                  ),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _SectionCard(
            icon: Icons.language_rounded,
            title: t.settingsLanguage,
            children: [
              DropdownButton<Locale>(
                isExpanded: true,
                value: settings.locale,
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
                ],
                onChanged: (locale) {
                  if (locale != null) {
                    context.read<SettingsProvider>().setLocale(locale);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          _SectionCard(
            icon: Icons.palette_rounded,
            title: 'Couleur d\'accent',
            children: [
              if (settings.supportsSystemAccent) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Utiliser la couleur du système'),
                  subtitle: const Text('Reprend l\'accent Windows/macOS'),
                  value: settings.useSystemAccent,
                  onChanged: (v) =>
                      context.read<SettingsProvider>().setUseSystemAccent(v),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'L\'accent système n\'est disponible que sur Windows/macOS. '
                    'Sur Android/iOS/Linux, choisis une couleur ci-dessous.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              if (!settings.supportsSystemAccent || !settings.useSystemAccent)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: accentPresets.map((c) {
                    final selected =
                        settings.accentColor.toARGB32() == c.toARGB32();
                    return GestureDetector(
                      onTap: () =>
                          context.read<SettingsProvider>().setAccentColor(c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  width: 2)
                              : null,
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
          const SizedBox(height: 16),

          _SectionCard(
            icon: Icons.emoji_events_rounded,
            title: 'Activité',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vrais succès récents sur le tableau de bord'),
                subtitle: const Text('Coûte du quota API — voir la note ci-dessus'),
                value: settings.showAchievementActivity,
                onChanged: _confirmEnableAchievementActivity,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_prefsLoaded)
            _SectionCard(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activer les notifications'),
                  value: _notifEnabled,
                  onChanged: (v) {
                    setState(() => _notifEnabled = v);
                    _setNotifPref(StorageKeys.notificationsEnabled, v);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Nouveaux succès débloqués'),
                  value: _notifAchievements,
                  onChanged: !_notifEnabled
                      ? null
                      : (v) {
                          setState(() => _notifAchievements = v);
                          _setNotifPref(StorageKeys.notifyAchievements, v);
                        },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ami en ligne'),
                  value: _notifFriendOnline,
                  onChanged: !_notifEnabled
                      ? null
                      : (v) {
                          setState(() => _notifFriendOnline = v);
                          _setNotifPref(StorageKeys.notifyFriendOnline, v);
                        },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Nouveaux clips / captures'),
                  value: _notifClips,
                  onChanged: !_notifEnabled
                      ? null
                      : (v) {
                          setState(() => _notifClips = v);
                          _setNotifPref(StorageKeys.notifyGameClips, v);
                        },
                ),
              ],
            ),
          const SizedBox(height: 16),

          _SectionCard(
            icon: Icons.system_update_rounded,
            title: t.settingsUpdates,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _checking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.system_update_outlined),
                title: Text(_updateInfo == null
                    ? t.settingsUpdates
                    : _updateInfo!.updateAvailable
                        ? '${t.settingsUpdatesAvailable}: ${_updateInfo!.latestVersion}'
                        : t.settingsUpdatesUpToDate),
                trailing: _updateInfo != null && _updateInfo!.updateAvailable
                    ? TextButton(
                        onPressed: () =>
                            launchUrl(Uri.parse(_updateInfo!.downloadUrl)),
                        child: Text(t.actionDownload),
                      )
                    : null,
                onTap: _checking ? null : _checkUpdate,
              ),
            ],
          ),
          const SizedBox(height: 24),

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

// Modernized section card: rounded icon chip + title, matching the app's
// accent color instead of a flat leading Icon.
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// Live OpenXBL quota bar (150 req/h on the free tier), driven by the
// X-RateLimit-* response headers captured in ApiClient. Local to this
// device only — see the note under the toggle above.
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
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: scheme.onSurfaceVariant),
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