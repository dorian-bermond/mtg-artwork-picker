import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../core/constants.dart';
import 'http_client.dart';

class SetIconService {
  final AppHttpClient http;

  // set code → icon URL
  Map<String, String>? _urlMap;
  // set code → SVG bytes (session cache)
  final Map<String, Uint8List?> _svgCache = {};

  SetIconService(this.http);

  // Returns SVG bytes for [setCode], downloading and caching to disk on first call.
  Future<Uint8List?> getIconBytes(String setCode) async {
    final code = setCode.toLowerCase();

    if (_svgCache.containsKey(code)) return _svgCache[code];

    final svgFile = await _svgFile(code);
    if (svgFile.existsSync()) {
      final bytes = svgFile.readAsBytesSync();
      _svgCache[code] = bytes;
      return bytes;
    }

    // Need the URL map to know where to download from.
    final urlMap = await _loadUrlMap();
    final url = urlMap[code];
    if (url == null) {
      _svgCache[code] = null;
      return null;
    }

    try {
      final res = await http.getUrl(url);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        _svgCache[code] = null;
        return null;
      }
      final bytes = res.bodyBytes;
      _svgCache[code] = bytes;
      svgFile.writeAsBytesSync(bytes);
      return bytes;
    } catch (_) {
      _svgCache[code] = null;
      return null;
    }
  }

  Future<Map<String, String>> _loadUrlMap() async {
    if (_urlMap != null) return _urlMap!;

    final cached = await _readUrlMapFromDisk();
    if (cached != null) {
      _urlMap = cached;
      return cached;
    }

    final fetched = await _fetchUrlMapFromApi();
    _urlMap = fetched;
    _writeUrlMapToDisk(fetched);
    return fetched;
  }

  Future<Map<String, String>?> _readUrlMapFromDisk() async {
    try {
      final file = await _urlMapFile();
      if (!file.existsSync()) return null;

      final raw = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final ts = raw['ts'] as int? ?? 0;
      if (DateTime.now().millisecondsSinceEpoch - ts >
          const Duration(days: 7).inMilliseconds) {
        return null;
      }
      return (raw['data'] as Map<String, dynamic>).cast<String, String>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeUrlMapToDisk(Map<String, String> data) async {
    try {
      final file = await _urlMapFile();
      file.writeAsStringSync(jsonEncode({
        'ts': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      }));
    } catch (_) {}
  }

  Future<Map<String, String>> _fetchUrlMapFromApi() async {
    final res = await http.get(
      Uri.https('api.scryfall.com', '/sets'),
      headers: kScryfallHeaders,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Scryfall /sets failed: ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final sets = (body['data'] as List).cast<Map<String, dynamic>>();
    final result = <String, String>{};
    for (final s in sets) {
      final code = s['code'] as String?;
      final icon = s['icon_svg_uri'] as String?;
      if (code != null && icon != null) {
        result[code.toLowerCase()] = icon;
      }
    }
    return result;
  }

  Future<Directory> _svgDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/set_icons');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<File> _svgFile(String setCode) async {
    final dir = await _svgDir();
    return File('${dir.path}/$setCode.svg');
  }

  Future<File> _urlMapFile() async {
    final base = await getApplicationSupportDirectory();
    return File('${base.path}/scryfall_sets_icons.json');
  }
}
