import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Generic local cache for raw API JSON, keyed by string, with a TTL per
// read. This is the actual fix for "trop d'appels API" — most screens
// (dashboard, friend profile, game detail) re-fetch the same endpoints
// every time they're opened; caching the raw decoded JSON here means a
// revisit within the TTL costs zero requests instead of 1-3.
class CacheService {
  static const _prefix = 'apicache:';

  Future<dynamic> read(String key, {required Duration ttl}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      final wrapper = jsonDecode(raw) as Map<String, dynamic>;
      final ts = DateTime.tryParse(wrapper['ts'] as String? ?? '');
      if (ts == null || DateTime.now().difference(ts) > ttl) return null;
      return wrapper['data'];
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString(
        '$_prefix$key',
        jsonEncode({'ts': DateTime.now().toIso8601String(), 'data': data}),
      );
    } catch (_) {
      // Cache is best-effort — if data isn't JSON-encodable for some
      // reason, just skip caching it rather than crash the call.
    }
  }

  Future<void> invalidate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
  }

  // Used by "Se déconnecter" so a different account doesn't see stale data.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
