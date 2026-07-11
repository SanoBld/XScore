import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_page.dart';
import '../providers/xbox_data_provider.dart';
import '../providers/settings_provider.dart';
import '../games/game_detail_page.dart';
import '../social/social_page.dart';
import '../games/games_page.dart';
import '../media/media_page.dart';
import '../media/media_viewer_page.dart';
import '../../data/models/game_clip.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = context.read<XboxDataProvider>();
      await data.loadAll();
      if (!mounted) return;
      if (context.read<SettingsProvider>().showAchievementActivity) {
        data.loadRecentAchievementsActivity();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Consumer<XboxDataProvider>(
          builder: (context, data, _) {
            final p = data.profile;
            return Row(
              children: [
                _GradientAvatar(imageUrl: p?.gamerpicUrl, radius: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p?.gamertag.isNotEmpty == true ? p!.gamertag : 'XScore',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
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
        if (profile != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _GradientAvatar(imageUrl: profile.gamerpicUrl, radius: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.gamertag.isEmpty ? '—' : profile.gamertag,
                            style: Theme.of(context).textTheme.titleLarge),
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
        if (context.watch<SettingsProvider>().showQuotaOnDashboard)
          _QuotaLine(data: data),
        const SizedBox(height: 12),

        // Quick stats row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events_outlined,
                label: t.dashboardGamerscore,
                value: '${profile?.gamerscore ?? '--'}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.videogame_asset_outlined,
                label: 'Jeux',
                value: '${data.titles.length}',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GamesPage()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.people_outline,
                label: 'Amis en ligne',
                value: '${data.onlineFriendsCount}/${data.friends.length}',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SocialPage()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _RecordsRow(data: data),
        const SizedBox(height: 20),

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
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.recentTitles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final title = data.recentTitles[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => GameDetailPage(title: title)),
                  ),
                  child: SizedBox(
                    width: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: title.boxArtUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: title.boxArtUrl!,
                                  height: 110,
                                  width: 110,
                                  fit: BoxFit.cover,
                                )
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
                        Text('${title.progressPercentage.toStringAsFixed(0)}%',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: scheme.primary)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 20),
        Text('Activité récente', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _RecentActivity(data: data),

        if (data.sortedFriends.any((f) => f.isOnline)) ...[
          const SizedBox(height: 20),
          Text('Amis en ligne', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: data.sortedFriends.where((f) => f.isOnline).map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: scheme.primaryContainer,
                        backgroundImage: f.gamerpicUrl != null
                            ? CachedNetworkImageProvider(f.gamerpicUrl!)
                            : null,
                        child: f.gamerpicUrl == null
                            ? const Icon(Icons.person, size: 18)
                            : null,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 60,
                        child: Text(f.gamertag,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// Unified feed combining recently-played titles and recent media (clips /
// screenshots). Note: OpenXBL's title history doesn't expose individual
// achievement-unlock timestamps without an extra call per game (which would
// burn the free 150 req/h quota fast), so "activity" here is approximated
// from what's already loaded: last time played per title + recent captures.
class _RecentActivity extends StatelessWidget {
  final XboxDataProvider data;
  const _RecentActivity({required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final useRealAchievements = context.watch<SettingsProvider>().showAchievementActivity;

    final items = <_ActivityEntry>[
      if (useRealAchievements)
        ...data.recentAchievements.map((a) => _ActivityEntry(
              date: a.unlockedAt ?? DateTime(2000),
              icon: Icons.emoji_events,
              title: a.name,
              subtitle: 'Succès débloqué · ${a.gamerscore} G',
              imageUrl: a.iconUrl,
              onTap: () {},
            ))
      else
        ...data.titles
            .where((t) => t.lastPlayed != null)
            .map((t) => _ActivityEntry(
                  date: t.lastPlayed!,
                  icon: Icons.videogame_asset,
                  title: t.name,
                  subtitle: '${t.progressPercentage.toStringAsFixed(0)}% de progression',
                  imageUrl: t.boxArtUrl,
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => GameDetailPage(title: t))),
                )),
      ...data.gameClips.map((c) => _ActivityEntry(
            date: c.date,
            icon: Icons.videocam,
            title: c.titleName,
            subtitle: 'Nouveau clip',
            imageUrl: c.thumbnailUrl,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MediaViewerPage.single(media: c, isClip: true))),
          )),
      ...data.screenshots.map((c) => _ActivityEntry(
            date: c.date,
            icon: Icons.photo_camera,
            title: c.titleName,
            subtitle: 'Nouvelle capture',
            imageUrl: c.thumbnailUrl,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MediaViewerPage.single(media: c, isClip: false))),
          )),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final top = items.take(10).toList();

    if (data.loadingAchievementsActivity && top.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (top.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('—')),
      );
    }

    return Column(
      children: top
          .map((e) => Card(
                child: ListTile(
                  onTap: e.onTap,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: e.imageUrl != null && e.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: e.imageUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                                width: 44, height: 44, color: scheme.surfaceContainerHigh),
                          )
                        : Container(
                            width: 44,
                            height: 44,
                            color: scheme.surfaceContainerHigh,
                            child: Icon(e.icon)),
                  ),
                  title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(e.subtitle),
                  trailing: Icon(e.icon, size: 16, color: scheme.primary),
                ),
              ))
          .toList(),
    );
  }
}

class _ActivityEntry {
  final DateTime date;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onTap;
  _ActivityEntry({
    required this.date,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.imageUrl,
  });
}

// Extra "at a glance" row — completed games, average completion, total clips
// — all computed from data already loaded, no extra requests. Uses the
// same _StatCard as the row above (was a visually different _MiniStat
// before — unified so every stat on the dashboard looks consistent).
class _RecordsRow extends StatelessWidget {
  final XboxDataProvider data;
  const _RecordsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final titles = data.titles;
    final completed = titles.where((t) => t.progressPercentage >= 100).length;
    final avg = titles.isEmpty
        ? 0.0
        : titles.map((t) => t.progressPercentage).reduce((a, b) => a + b) / titles.length;
    final mediaCount = data.gameClips.length + data.screenshots.length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
              icon: Icons.workspace_premium_outlined, label: 'Terminés', value: '$completed'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
              icon: Icons.donut_large_outlined,
              label: 'Complétion moy.',
              value: '${avg.toStringAsFixed(0)}%'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
              icon: Icons.perm_media_outlined, label: 'Médias', value: '$mediaCount'),
        ),
      ],
    );
  }
}

// Circular avatar with a brand gradient fallback instead of a flat grey
// disc + person icon when there's no gamerpic yet.
class _GradientAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  const _GradientAvatar({required this.imageUrl, required this.radius});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(imageUrl!),
      );
    }
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: Icon(Icons.person, color: scheme.onPrimary, size: radius),
    );
  }
}

class _QuotaLine extends StatelessWidget {
  final XboxDataProvider data;
  const _QuotaLine({required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (data.quotaLimit == null || data.quotaSpent == null) {
      return const SizedBox.shrink();
    }
    return Text(
      'Quota OpenXBL (cet appareil) : ${data.quotaSpent}/${data.quotaLimit} · reste ${data.quotaRemaining}',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _StatCard({required this.icon, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: scheme.primary, size: 20),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              Text(label,
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}