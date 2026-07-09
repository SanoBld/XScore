import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/widgets/adaptive_nav_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsProvider();
  await settings.init();
  runApp(XScoreApp(settings: settings));
}

class XScoreApp extends StatelessWidget {
  final SettingsProvider settings;
  const XScoreApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: settings,
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'XScore',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const AdaptiveNavShell(),
          );
        },
      ),
    );
  }
}