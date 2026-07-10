import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'settings_section.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Apparence')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSection(
            title: t.settingsLanguage,
            icon: Icons.language_rounded,
            children: [
              DropdownButton<Locale>(
                isExpanded: true,
                value: settings.locale,
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
                ],
                onChanged: (locale) {
                  if (locale != null) {
                    context.read<SettingsProvider>().setLocale(locale);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          SettingsSection(
            title: 'Thème',
            icon: Icons.brightness_6_rounded,
            children: [
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('Auto')),
                  ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Clair')),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Sombre')),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (s) =>
                    context.read<SettingsProvider>().setThemeMode(s.first),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SettingsSection(
            title: 'Couleur d\'accent',
            icon: Icons.palette_rounded,
            children: [
              if (settings.supportsSystemAccent) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Suivre la couleur d\'accent du système'),
                  subtitle: Text(
                    'Détectée sur ${Platform.isWindows ? "Windows" : "macOS"} : '
                    'change automatiquement si tu la modifies dans les réglages OS.',
                  ),
                  value: settings.useSystemAccent,
                  onChanged: (v) =>
                      context.read<SettingsProvider>().setUseSystemAccent(v),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'L\'accent système n\'est disponible que sur Windows/macOS. '
                    'Sur Android/iOS/Linux, choisis une couleur ci-dessous.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              if (!settings.supportsSystemAccent || !settings.useSystemAccent)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: accentPresets.map((c) {
                    final selected = settings.accentColor.toARGB32() == c.toARGB32();
                    return GestureDetector(
                      onTap: () => context.read<SettingsProvider>().setAccentColor(c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: scheme.onSurface, width: 2)
                              : null,
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
          const SizedBox(height: 16),

          SettingsSection(
            title: 'Jeux',
            icon: Icons.videogame_asset_rounded,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Disposition en grille'),
                subtitle: const Text('Sinon, liste classique'),
                value: settings.gamesGridLayout,
                onChanged: (v) => context.read<SettingsProvider>().setGamesGridLayout(v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

