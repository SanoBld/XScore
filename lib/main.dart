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

// Vivid fallback used when the device's Material You palette is basically
// grayscale (e.g. a black & white / monochrome wallpaper) — Android still
// derives *a* color in that case, but it's so desaturated the whole app
// looks flat gray. A wallpaper-derived color this washed out isn't a
// meaningful "accent" choice, so we swap it for a vivid blue instead of
// honoring it literally.
const _monochromeFallback = Color(0xFF2962FF);

bool _isNearGrayscale(Color c) {
  final hsl = HSLColor.fromColor(c);
  return hsl.saturation < 0.12;
}

Color _sanitizeDynamicSeed(Color seed) => _isNearGrayscale(seed) ? _monochromeFallback : seed;

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

              // If the device palette is near-grayscale, rebuild a scheme
              // from the vivid fallback seed instead of using the flat
              // dynamic scheme as-is.
              final effectiveLightDynamic = (useAndroidDynamic && _isNearGrayscale(lightDynamic!.primary))
                  ? ColorScheme.fromSeed(seedColor: _monochromeFallback)
                  : lightDynamic;
              final effectiveDarkDynamic = (useAndroidDynamic &&
                      darkDynamic != null &&
                      _isNearGrayscale(darkDynamic.primary))
                  ? ColorScheme.fromSeed(
                      seedColor: _monochromeFallback, brightness: Brightness.dark)
                  : darkDynamic;

              final accentColor = _sanitizeDynamicSeed(settings.accentColor);

              final lightScheme = useAndroidDynamic
                  ? effectiveLightDynamic!
                  : AppTheme.light(accentColor).colorScheme;
              final darkScheme = useAndroidDynamic
                  ? (effectiveDarkDynamic ?? AppTheme.dark(accentColor).colorScheme)
                  : AppTheme.dark(accentColor).colorScheme;

              return MaterialApp(
                title: 'XScore',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(accentColor).copyWith(colorScheme: lightScheme),
                darkTheme: AppTheme.dark(accentColor).copyWith(colorScheme: darkScheme),
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
