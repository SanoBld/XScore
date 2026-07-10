import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import 'settings_section.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notifEnabled = true;
  bool _notifAchievements = true;
  bool _notifFriendOnline = false;
  bool _notifClips = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifEnabled = prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
      _notifAchievements = prefs.getBool(StorageKeys.notifyAchievements) ?? true;
      _notifFriendOnline = prefs.getBool(StorageKeys.notifyFriendOnline) ?? false;
      _notifClips = prefs.getBool(StorageKeys.notifyGameClips) ?? true;
      _loaded = true;
    });
  }

  Future<void> _set(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSection(
            title: 'Notifications',
            icon: Icons.notifications_rounded,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activer les notifications'),
                value: _notifEnabled,
                onChanged: (v) {
                  setState(() => _notifEnabled = v);
                  _set(StorageKeys.notificationsEnabled, v);
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
                        _set(StorageKeys.notifyAchievements, v);
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
                        _set(StorageKeys.notifyFriendOnline, v);
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
                        _set(StorageKeys.notifyGameClips, v);
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
