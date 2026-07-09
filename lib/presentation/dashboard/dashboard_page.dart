import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.navDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: t.settingsTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: const _DashboardBody(),
    );
  }
}

// Placeholder dashboard content
class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: Text(t.dashboardGamerscore),
            subtitle: const Text('--'),
          ),
        ),
        const SizedBox(height: 12),
        Text(t.dashboardRecentActivity,
            style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
