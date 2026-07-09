import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.gamesTitle)),
      body: Center(child: Text(t.gamesTitle)),
    );
  }
}
