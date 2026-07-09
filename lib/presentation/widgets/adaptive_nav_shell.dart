import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dashboard/dashboard_page.dart';
import '../games/games_page.dart';
import '../social/social_page.dart';
import '../media/media_page.dart';
import '../providers/settings_provider.dart';
import '../providers/xbox_data_provider.dart';
import '../../l10n/app_localizations.dart';

// Adaptive shell: NavigationRail on wide screens, NavigationBar on mobile
class AdaptiveNavShell extends StatelessWidget {
  const AdaptiveNavShell({super.key});

  @override
  Widget build(BuildContext context) {
    final apiKey = context.read<SettingsProvider>().apiKey;
    // Provider créé ici (pas dans main.dart) : évite le crash "écran gris"
    // qui survenait quand XboxDataProvider n'était pas dans l'arbre.
    return ChangeNotifierProvider<XboxDataProvider>(
      create: (_) => XboxDataProvider(apiKey ?? ''),
      child: const _NavShellBody(),
    );
  }
}

class _NavShellBody extends StatefulWidget {
  const _NavShellBody();

  @override
  State<_NavShellBody> createState() => _NavShellBodyState();
}

class _NavShellBodyState extends State<_NavShellBody> {
  int _index = 0;

  static const _pages = [
    DashboardPage(),
    GamesPage(),
    SocialPage(),
    MediaPage(),
  ];

  List<NavigationDestination> _destinations(AppLocalizations t) => [
        NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: t.navDashboard),
        NavigationDestination(
            icon: const Icon(Icons.videogame_asset_outlined),
            selectedIcon: const Icon(Icons.videogame_asset),
            label: t.navGames),
        NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: t.navSocial),
        NavigationDestination(
            icon: const Icon(Icons.movie_outlined),
            selectedIcon: const Icon(Icons.movie),
            label: t.navMedia),
      ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width >= 700;
    final destinations = _destinations(t);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: d.icon,
                        selectedIcon: d.selectedIcon,
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _pages[_index]),
          ],
        ),
      );
    }

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: destinations,
      ),
    );
  }
}