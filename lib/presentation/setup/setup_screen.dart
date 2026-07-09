import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../data/services/api_client.dart';
import '../../data/services/xbox_profile_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/adaptive_nav_shell.dart';

// ══════════════════════════════════════════════════════════════════════════
//  SetupScreen — OpenXBL API key entry (animated)
// ══════════════════════════════════════════════════════════════════════════

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with TickerProviderStateMixin {
  final _apiKeyCtrl = TextEditingController();
  bool _obscureKey = true;
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _entryCtrl; // staggered entry, once
  late final AnimationController _floatCtrl; // continuous logo float
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack)));
    _logoFade = CurvedAnimation(
        parent: _entryCtrl, curve: const Interval(0.0, 0.45, curve: Curves.easeOut));

    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.35, 0.95, curve: Curves.easeOutCubic)));
    _cardFade = CurvedAnimation(
        parent: _entryCtrl, curve: const Interval(0.35, 0.85, curve: Curves.easeOut));

    _entryCtrl.forward();

    // Logo float, repeating
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -5.5, end: 5.5).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  // Validate key against OpenXBL, then persist + navigate
  Future<void> _connect() async {
    final t = AppLocalizations.of(context)!;
    final key = _apiKeyCtrl.text.trim();

    if (key.isEmpty) {
      setState(() => _errorMessage = t.setupErrorEmpty);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ApiClient(apiKey: key);
      final profileService = XboxProfileService(client);
      await profileService.getMyProfile(); // throws on 401/invalid key

      if (!mounted) return;
      await context.read<SettingsProvider>().setApiKey(key);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdaptiveNavShell()),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('XScore setup error: $e'); // TEMP: check debug console
      setState(() => _errorMessage = '${t.setupErrorInvalid}\n($e)');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Floating logo
                  AnimatedBuilder(
                    animation: Listenable.merge([_entryCtrl, _floatCtrl]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoFade.value,
                        child: Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(Icons.videogame_asset_rounded,
                          size: 44, color: scheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(height: 28),

                  FadeTransition(
                    opacity: _cardFade,
                    child: Text(
                      t.setupTitle,
                      textAlign: TextAlign.center,
                      style: text.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _cardFade,
                    child: Text(
                      t.setupSubtitle,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Card
                  SlideTransition(
                    position: _cardSlide,
                    child: FadeTransition(
                      opacity: _cardFade,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: scheme.outlineVariant
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _apiKeyCtrl,
                              obscureText: _obscureKey,
                              decoration: InputDecoration(
                                hintText: t.setupApiKeyHint,
                                prefixIcon: const Icon(Icons.vpn_key_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureKey
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                  onPressed: () => setState(
                                      () => _obscureKey = !_obscureKey),
                                ),
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 16, color: scheme.error),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(_errorMessage!,
                                        style: text.bodySmall
                                            ?.copyWith(color: scheme.error)),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _connect,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.2))
                                    : Text(t.actionConnect),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () => launchUrl(
                                  Uri.parse('https://xbl.io')),
                              child: Text(t.setupGetKeyLink),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}