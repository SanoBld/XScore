import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/constants/api_constants.dart';

class UpdateInfo {
  final bool updateAvailable;
  final String latestVersion;
  final String currentVersion;
  final String downloadUrl;
  final String releaseNotes;

  UpdateInfo({
    required this.updateAvailable,
    required this.latestVersion,
    required this.currentVersion,
    required this.downloadUrl,
    required this.releaseNotes,
  });
}

// Checks GitHub latest release and compare semver
class UpdateService {
  Future<UpdateInfo> checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();
    final res = await http.get(Uri.parse(ApiConstants.latestReleaseUrl));

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch release info');
    }

    final json = jsonDecode(res.body);
    final tag = (json['tag_name'] as String).replaceFirst('v', '');
    final assets = json['assets'] as List;

    // Find APK asset
    final apkAsset = assets.firstWhere(
      (a) => (a['name'] as String).endsWith('.apk'),
      orElse: () => null,
    );

    final isNewer = _isVersionNewer(tag, info.version);

    return UpdateInfo(
      updateAvailable: isNewer,
      latestVersion: tag,
      currentVersion: info.version,
      downloadUrl: apkAsset != null ? apkAsset['browser_download_url'] : '',
      releaseNotes: json['body'] ?? '',
    );
  }

  // Compare dot-separated semver strings
  bool _isVersionNewer(String remote, String local) {
    final r = remote.split('.').map(int.parse).toList();
    final l = local.split('.').map(int.parse).toList();
    for (var i = 0; i < r.length; i++) {
      final lv = i < l.length ? l[i] : 0;
      if (r[i] > lv) return true;
      if (r[i] < lv) return false;
    }
    return false;
  }
}
