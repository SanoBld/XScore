import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'appearance_page.dart';
import 'account_page.dart';
import 'activity_page.dart';
import 'notifications_page.dart';
import 'updates_page.dart';

class _SettingsCardData {
  final IconData icon;
  final Color Function(ColorScheme) iconBg;
  final Color Function(ColorScheme) iconFg;
  final String title;
  final String subtitle;
  final Widget Function() pageBuilder;

  const _SettingsCardData({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
    required this.pageBuilder,
  });
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  List<_SettingsCardData> _cards(BuildContext context) => [
        _SettingsCardData(
          icon: Icons.palette_rounded,
          iconBg: (s) => s.primaryContainer,
          iconFg: (s) => s.onPrimaryContainer,
          title: 'Apparence',
          subtitle: 'Langue, couleur d\'accent, disposition',
          pageBuilder: () => const AppearancePage(),
        ),
        _SettingsCardData(
          icon: Icons.vpn_key_rounded,
          iconBg: (s) => s.secondaryContainer,
          iconFg: (s) => s.onSecondaryContainer,
          title: 'Compte',
          subtitle: 'Clé API, quota OpenXBL, déconnexion',
          pageBuilder: () => const AccountPage(),
        ),
        _SettingsCardData(
          icon: Icons.emoji_events_rounded,
          iconBg: (s) => s.tertiaryContainer,
          iconFg: (s) => s.onTertiaryContainer,
          title: 'Activité',
          subtitle: 'Succès récents sur le tableau de bord',
          pageBuilder: () => const ActivityPage(),
        ),
        _SettingsCardData(
          icon: Icons.notifications_rounded,
          iconBg: (s) => Color.lerp(s.primaryContainer, s.tertiaryContainer, 0.5)!,
          iconFg: (s) => s.onPrimaryContainer,
          title: 'Notifications',
          subtitle: 'Succès, amis, clips',
          pageBuilder: () => const NotificationsPage(),
        ),
        _SettingsCardData(
          icon: Icons.system_update_rounded,
          iconBg: (s) => Color.lerp(s.secondaryContainer, s.tertiaryContainer, 0.5)!,
          iconFg: (s) => s.onSecondaryContainer,
          title: 'Mises à jour',
          subtitle: 'Vérifier une nouvelle version',
          pageBuilder: () => const UpdatesPage(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final cards = _cards(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.98,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _CategoryCard(
                  data: cards[i],
                  onTap: () => Navigator.of(ctx).push(
                    MaterialPageRoute(builder: (_) => cards[i].pageBuilder()),
                  ),
                ),
                childCount: cards.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 10),
                  Text('XScore',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _SettingsCardData data;
  final VoidCallback onTap;
  const _CategoryCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
          ),
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: data.iconBg(scheme),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data.icon, color: data.iconFg(scheme), size: 24),
                  ),
                  const Spacer(),
                  Text(data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(data.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant, height: 1.3)),
                ],
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
