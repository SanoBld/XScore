import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.socialTitle)),
      body: Center(child: Text(t.socialTitle)),
    );
  }
}
