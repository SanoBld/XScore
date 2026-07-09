import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_page.dart';
import '../providers/xbox_data_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<XboxDataProvider>().loadAll(),
    );
  }

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
      body: RefreshIndicator(
        onRefresh: () => context.read<XboxDataProvider>().loadAll(force: true),
        child: const _DashboardBody(),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final data = context.watch<XboxDataProvider>();
    final scheme = Theme.of(context).colorScheme;

    if (data.loading && data.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = data.profile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Debug: shows the real cause when something failed to load,
        // even if profile partially loaded. Safe to remove later.
        if (data.profileError != null)
          _ErrorBanner(label: 'Profil', message: data.profileError!),
        if (data.titlesError != null)
          _ErrorBanner(label: 'Jeux', message: data.titlesError!),
        if (data.friendsError != null)
          _ErrorBanner(label: 'Amis', message: data.friendsError!),
        if (data.mediaError != null)
          _ErrorBanner(label: 'Médias', message: data.mediaError!),

        if (profile == null && data.profileError == null)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('—')),
          ),

        if (profile != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: scheme.primaryContainer,
                    backgroundImage: profile.gamerpicUrl != null
                        ? NetworkImage(profile.gamerpicUrl!)
                        : null,
                    child: profile.gamerpicUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.gamertag.isEmpty
                              ? '(gamertag introuvable)'
                              : profile.gamertag,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (profile.bio != null && profile.bio!.isNotEmpty)
                          Text(profile.bio!,
                              style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: Text(t.dashboardGamerscore),
            subtitle: Text('${profile?.gamerscore ?? '--'}'),
          ),
        ),
        const SizedBox(height: 16),
        Text(t.dashboardRecentActivity,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (data.recentTitles.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('—')),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.recentTitles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final title = data.recentTitles[i];
                return SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: title.boxArtUrl != null
                            ? Image.network(title.boxArtUrl!,
                                height: 110, width: 110, fit: BoxFit.cover)
                            : Container(
                                height: 110,
                                width: 110,
                                color: scheme.surfaceContainerHigh,
                                child: const Icon(Icons.videogame_asset),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(title.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String label;
  final String message;
  const _ErrorBanner({required this.label, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: scheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$label : $message',
                  style: TextStyle(color: scheme.onErrorContainer, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}