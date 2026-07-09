import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/widgets/adaptive_nav_shell.dart';
import 'presentation/setup/setup_screen.dart';

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
            // Accent color: system color or user-picked preset (Settings)
            theme: AppTheme.light(settings.accentColor),
            darkTheme: AppTheme.dark(settings.accentColor),
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Gate: no API key yet -> setup screen
            home: settings.hasApiKey
                ? const AdaptiveNavShell()
                : const SetupScreen(),
          );
        },
      ),
    );
  }
}