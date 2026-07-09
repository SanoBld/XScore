import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/storage_keys.dart';
import '../providers/settings_provider.dart';
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

          // Notifications section
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
        ],
      ),
    );
  }
}