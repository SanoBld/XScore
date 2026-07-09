import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/storage_keys.dart';
import '../providers/settings_provider.dart';
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
      _notifAchievements =
          prefs.getBool(StorageKeys.notifyAchievements) ?? true;
      _notifFriendOnline =
          prefs.getBool(StorageKeys.notifyFriendOnline) ?? false;
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
      // Silently ignore, could show snackbar
    } finally {
      setState(() => _checking = false);
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
          // API Key section
          Text(t.settingsApiKey, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
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
          const SizedBox(height: 6),
          // Free tier quota reminder — avoids surprise 429s
          Text(
            'Quota gratuit OpenXBL : 150 requêtes / heure. L\'app met en cache '
            'les données (5 min) pour l\'économiser.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Language section
          Text(t.settingsLanguage, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButton<Locale>(
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
          const SizedBox(height: 24),

          // Accent color section
          Text('Couleur d\'accent', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Utiliser la couleur du système'),
            subtitle: const Text('Reprend l\'accent Windows/macOS'),
            value: settings.useSystemAccent,
            onChanged: (v) => context.read<SettingsProvider>().setUseSystemAccent(v),
          ),
          if (!settings.useSystemAccent)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: accentPresets.map((c) {
                  final selected = settings.accentColor.toARGB32() == c.toARGB32();
                  return GestureDetector(
                    onTap: () => context.read<SettingsProvider>().setAccentColor(c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Redémarre l\'app pour appliquer entièrement la couleur.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
          if (_prefsLoaded) ...[
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
          const SizedBox(height: 24),

          // Updates section
          Text(t.settingsUpdates, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
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
          ),
          const SizedBox(height: 24),

          // Logout
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