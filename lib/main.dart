import 'dart:io' show Platform;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      // DynamicColorBuilder reads the real Material You / device accent
      // color on Android 12+ (and does nothing — returns null — anywhere
      // else, in which case we fall back to system_theme on Windows/macOS,
      // or the manual preset). This is the piece that was missing before:
      // system_theme alone never worked on Android.
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              final useAndroidDynamic = settings.useSystemAccent &&
                  !kIsWeb &&
                  Platform.isAndroid &&
                  lightDynamic != null;

              final lightScheme = useAndroidDynamic
                  ? lightDynamic
                  : AppTheme.light(settings.accentColor).colorScheme;
              final darkScheme = useAndroidDynamic
                  ? (darkDynamic ?? AppTheme.dark(settings.accentColor).colorScheme)
                  : AppTheme.dark(settings.accentColor).colorScheme;

              return MaterialApp(
                title: 'XScore',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(settings.accentColor).copyWith(colorScheme: lightScheme),
                darkTheme: AppTheme.dark(settings.accentColor).copyWith(colorScheme: darkScheme),
                themeMode: settings.themeMode,
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
          );
        },
      ),
    );
  }
}
