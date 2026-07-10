import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../games/games_page.dart';
import '../search/search_page.dart';
import '../social/social_page.dart';
import '../media/media_page.dart';
import '../../l10n/app_localizations.dart';

// Adaptive shell: NavigationRail on wide screens, NavigationBar on mobile
class AdaptiveNavShell extends StatefulWidget {
  const AdaptiveNavShell({super.key});

  @override
  State<AdaptiveNavShell> createState() => _AdaptiveNavShellState();
}

class _AdaptiveNavShellState extends State<AdaptiveNavShell> {
  int _index = 0;

  static const _pages = [
    DashboardPage(),
    GamesPage(),
    SearchPage(),
    SocialPage(),
    MediaPage(),
  ];

  // Short, fixed French labels — the localized strings (t.navDashboard,
  // etc.) were too long for the bottom bar on small screens. If you also
  // ship English, update the matching keys in the ARB files to shorter
  // values instead of reverting this.
  List<NavigationDestination> _destinations(AppLocalizations t) => [
        const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Accueil'),
        const NavigationDestination(
            icon: Icon(Icons.videogame_asset_outlined),
            selectedIcon: Icon(Icons.videogame_asset),
            label: 'Jeux'),
        const NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Recherche'),
        const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Amis'),
        const NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Médias'),
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
