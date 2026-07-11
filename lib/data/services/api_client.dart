import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'cache_service.dart';

// Tracks OpenXBL's X-RateLimit-* headers, updated after every request.
// Global singleton-ish notifier so Settings can display it live.
class RateLimitInfo extends ChangeNotifier {
  int? limit;
  int? spent;
  int? remaining;

  void update(http.Response res) {
    final l = res.headers['x-ratelimit-limit'];
    final s = res.headers['x-ratelimit-spent'];
    final r = res.headers['x-ratelimit-remaining'];
    if (l == null && s == null && r == null) return;
    limit = int.tryParse(l ?? '') ?? limit;
    spent = int.tryParse(s ?? '') ?? spent;
    remaining = int.tryParse(r ?? '') ?? remaining;
    notifyListeners();
  }
}

// Thin wrapper around http client with auth header injection + a caching
// layer. Every request that passes `cacheKey` is served from local storage
// when a fresh-enough copy exists — that's the actual quota saver, since
// it means a cache hit costs zero HTTP calls (not "call anyway but skip
// re-parsing"). Requests without a cacheKey behave exactly as before.
class ApiClient {
  final http.Client _client;
  final String? apiKey;
  final RateLimitInfo rateLimit = RateLimitInfo();
  final CacheService cache = CacheService();

  ApiClient({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        ApiConstants.authHeader: apiKey ?? '',
        'Accept': 'application/json',
        'X-Contract': '100',
      };

  // GET against OpenXBL base.
  // - cacheKey/cacheTtl: serve from cache if fresh, else fetch and store.
  // - bypassCache: force a real network call (pull-to-refresh) and refresh
  //   the cached copy for next time.
  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    String? cacheKey,
    Duration? cacheTtl,
    bool bypassCache = false,
  }) async {
    if (cacheKey != null && !bypassCache) {
      final cached = await cache.read(cacheKey, ttl: cacheTtl ?? const Duration(minutes: 5));
      if (cached != null) return cached;
    }

    final uri = Uri.parse('${ApiConstants.openXblBase}$path')
        .replace(queryParameters: query);
    final res = await _client.get(uri, headers: _headers);
    rateLimit.update(res);
    final data = _handle(res);

    if (cacheKey != null) {
      await cache.write(cacheKey, data);
    }
    return data;
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      final decoded = jsonDecode(res.body);
      // Current OpenXBL API wraps every payload as {"content": {...}, "code": 200}
      if (decoded is Map<String, dynamic> && decoded.containsKey('content')) {
        return decoded['content'];
      }
      return decoded;
    }
    throw ApiException(res.statusCode, res.body);
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}