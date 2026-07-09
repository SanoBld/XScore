import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _apiKeyCtrl = TextEditingController(text: settings.apiKey ?? '');
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
