import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

// Thin wrapper around http client with auth header injection
class ApiClient {
  final http.Client _client;
  final String? apiKey;

  ApiClient({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        ApiConstants.authHeader: apiKey ?? '',
        'Accept': 'application/json',
        'X-Contract': '100',
      };

  // GET against OpenXBL base
  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('${ApiConstants.openXblBase}$path')
        .replace(queryParameters: query);
    final res = await _client.get(uri, headers: _headers);
    return _handle(res);
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