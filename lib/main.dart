import 'dart:io' show Platform;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
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

// Ported from a working reference project instead of the ad-hoc
// "grayscale detection" this file used before, which was flagging real
// (but pastel) Material You palettes as monochrome and forcing blue
// almost permanently — that was the actual bug. This just guards the two
// genuinely degenerate seeds (near-black / near-white give ColorScheme.
// fromSeed almost no room to derive tones from) and otherwise trusts the
// color as-is.
Color _seedColorForScheme(Color c) {
  final luminance = c.computeLuminance();
  if (luminance < 0.008) return const Color(0xFF455A64);
  if (luminance > 0.97) return const Color(0xFF90A4AE);
  return c;
}

class XScoreApp extends StatelessWidget {
  final SettingsProvider settings;
  const XScoreApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: settings,
      // DynamicColorBuilder only ever returns non-null on Android 12+ (it's
      // a no-op elsewhere), so there's no need for a manual Platform check
      // to decide whether it applies.
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              final useDynamic = settings.useSystemAccent && lightDynamic != null;
              final useDesktopSystemAccent = settings.useSystemAccent &&
                  !kIsWeb &&
                  (Platform.isWindows || Platform.isMacOS);

              ColorScheme lightScheme;
              ColorScheme darkScheme;

              if (useDynamic) {
                // .harmonized() nudges the app's own palette (error, etc.)
                // toward the dynamic hue so nothing clashes — matches how
                // Android's own Settings/first-party apps blend Material You.
                lightScheme = lightDynamic!.harmonized();
                darkScheme = (darkDynamic ??
                        ColorScheme.fromSeed(
                            seedColor: _seedColorForScheme(settings.accentColor),
                            brightness: Brightness.dark))
                    .harmonized();
              } else if (useDesktopSystemAccent) {
                final seed = _seedColorForScheme(SystemTheme.accentColor.accent);
                lightScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
                darkScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
              } else {
                final seed = _seedColorForScheme(settings.accentColor);
                lightScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
                darkScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
              }

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
