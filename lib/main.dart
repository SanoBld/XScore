import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/xbox_data_provider.dart';
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
            theme: AppTheme.light(settings.accentColor),
            darkTheme: AppTheme.dark(settings.accentColor),
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Wraps the Navigator itself (not just `home`), so every pushed
            // route — settings, game detail, friend profile, etc. — can
            // read XboxDataProvider. Keyed on apiKey so a logout/re-login
            // with a different key rebuilds a fresh provider.
            builder: (context, child) {
              if (!settings.hasApiKey) return child!;
              return ChangeNotifierProvider<XboxDataProvider>(
                key: ValueKey(settings.apiKey),
                create: (_) => XboxDataProvider(settings.apiKey!),
                child: child!,
              );
            },
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