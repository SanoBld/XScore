import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/game_info.dart';

// Optional enrichment layer on top of OpenXBL. Requires a free Twitch
// Developer app (id.twitch.tv/oauth2/token, client_credentials grant) —
// entirely separate account/keys from the Xbox/OpenXBL API key. If not
// configured, callers should just skip enrichment; this service throws
// rather than silently degrading, so the UI can decide what to show.
class IgdbService {
  final String clientId;
  final String clientSecret;
  String? _accessToken;
  DateTime? _tokenExpiry;

  IgdbService({required this.clientId, required this.clientSecret});

  Future<String> _getToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }
    final res = await http.post(Uri.parse(ApiConstants.twitchTokenUrl), body: {
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'client_credentials',
    });
    if (res.statusCode != 200) {
      throw Exception('Twitch auth failed (${res.statusCode}) — vérifie le Client ID/Secret');
    }
    final json = jsonDecode(res.body);
    _accessToken = json['access_token'];
    _tokenExpiry =
        DateTime.now().add(Duration(seconds: (json['expires_in'] as int) - 60));
    return _accessToken!;
  }

  // Best-effort name match: IGDB doesn't know Xbox titleIds, only names —
  // search returns the closest matches, we take the first.
  Future<GameInfo?> findByName(String name) async {
    if (clientId.isEmpty || clientSecret.isEmpty) {
      throw Exception('IGDB non configuré (Client ID/Secret manquants)');
    }
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('${ApiConstants.igdbBase}/games'),
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $token',
        'Content-Type': 'text/plain',
      },
      body: 'search "$name"; '
          'fields summary,rating,first_release_date,genres.name,cover.url; '
          'limit 1;',
    );
    if (res.statusCode != 200) {
      throw Exception('IGDB error ${res.statusCode}');
    }
    final list = jsonDecode(res.body) as List;
    if (list.isEmpty) return null;
    return GameInfo.fromJson(list.first);
  }
}
