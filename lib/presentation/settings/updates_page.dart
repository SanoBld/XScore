import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../data/services/update_service.dart';
import 'settings_section.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  bool _checking = false;
  UpdateInfo? _updateInfo;

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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.settingsUpdates)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSection(
            title: t.settingsUpdates,
            icon: Icons.system_update_rounded,
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
                        onPressed: () => launchUrl(Uri.parse(_updateInfo!.downloadUrl)),
                        child: Text(t.actionDownload),
                      )
                    : null,
                onTap: _checking ? null : _checkUpdate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
