import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.mediaTitle)),
      body: Center(child: Text(t.mediaTitle)),
    );
  }
}
