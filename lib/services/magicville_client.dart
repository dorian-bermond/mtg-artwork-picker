import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'magicville_parser.dart';

class MagicVilleClient {
  final MagicVilleParser parser;
  final HttpClient _http;

  MagicVilleClient(this.parser, {HttpClient? http})
    : _http = http ?? HttpClient() {
    // Prevent indefinite hangs
    _http.connectionTimeout = const Duration(seconds: 12);
    _http.idleTimeout = const Duration(seconds: 15);
  }

  static const _base = 'https://www.magic-ville.com/fr/';

  static const Duration _requestTimeout = Duration(seconds: 15);

  Future<String> _getHtml(Uri uri) async {
    final req = await _http
        .getUrl(uri)
        .timeout(
          _requestTimeout,
          onTimeout: () {
            throw TimeoutException(
              'MagicVille getUrl timeout',
              _requestTimeout,
            );
          },
        );

    req.headers.set(
      HttpHeaders.userAgentHeader,
      'Mozilla/5.0 (Android; Flutter)',
    );

    final res = await req.close().timeout(
      _requestTimeout,
      onTimeout: () {
        throw TimeoutException('MagicVille close timeout', _requestTimeout);
      },
    );

    // Read bytes first (avoids decodeStream hanging + lets us pick encoding)
    final bytes = await consolidateHttpClientResponseBytes(res).timeout(
      _requestTimeout,
      onTimeout: () {
        throw TimeoutException(
          'MagicVille read bytes timeout',
          _requestTimeout,
        );
      },
    );

    if (res.statusCode != 200) {
      throw HttpException('MagicVille HTTP ${res.statusCode}', uri: uri);
    }

    // Decode according to declared charset (Magic-Ville often isn’t UTF-8)
    final charset = res.headers.contentType?.charset?.toLowerCase().trim();
    final Encoding enc =
        (charset == 'iso-8859-1' ||
            charset == 'iso_8859-1' ||
            charset == 'latin1' ||
            charset == 'windows-1252')
        ? latin1
        : utf8;

    try {
      return enc.decode(bytes);
    } catch (_) {
      return utf8.decode(bytes, allowMalformed: true);
    }
  }

  Future<List<MagicVilleArtworkInfo>> fetchArtworkInfo({
    required String ref,
  }) async {
    final uri = Uri.parse('${_base}carte_art?ref=$ref');
    final htmlText = await _getHtml(uri);
    return parser.parseArtworkPage(htmlText);
  }

  /// Non-throwing probe: returns null if 404/parse/network/timeout error.
  Future<List<MagicVilleArtworkInfo>?> tryFetchArtworkInfo({
    required String ref,
  }) async {
    try {
      return await fetchArtworkInfo(ref: ref);
    } catch (_) {
      return null;
    }
  }

  /// POST to the advanced search with `spe_type=TK` and return every ref found
  /// in the results page. The caller downloads all of them so the user can
  /// choose the illustration they prefer.
  Future<List<String>> findAllTokenRefsForName(String name) async {
    final formUri = Uri.parse('${_base}rech_avancee');
    final postUri = Uri.parse('${_base}resultats');

    // Pre-flight GET to establish a session cookie before the POST.
    try {
      await _getHtml(formUri);
    } catch (_) {}

    final params = <String, String>{
      'manachecksum': '',
      'spe_options': 'selected',
      'manaonly': '1',
      'color_search': '1',
      'type_search': '1',
      'spe_type': 'TK',
      'graph_aff': '1',
      'fra': '1',
      'eng': '1',
      'recherche_titre': name.toLowerCase(),
      'recherche_type': '',
      'recherche_texte': '',
      'costx': '1',
      'forx': '1',
      'endx': '1',
      'x': '0',
      'y': '0',
      'dci': '',
    };

    final body = params.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final bodyBytes = utf8.encode(body);

    final request = await _http.postUrl(postUri).timeout(
      _requestTimeout,
      onTimeout: () =>
          throw TimeoutException('MagicVille token search timeout', _requestTimeout),
    );
    request.headers
      ..set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 (Android; Flutter)')
      ..set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded')
      ..set(HttpHeaders.contentLengthHeader, '${bodyBytes.length}')
      ..set(HttpHeaders.refererHeader, '${_base}rech_avancee');
    request.add(bodyBytes);

    final response = await request.close().timeout(
      _requestTimeout,
      onTimeout: () =>
          throw TimeoutException('MagicVille token search close timeout', _requestTimeout),
    );
    debugPrint('MV token search POST status=${response.statusCode} location=${response.headers.value(HttpHeaders.locationHeader)}');
    if (response.statusCode != HttpStatus.ok) return [];

    final bytes = await consolidateHttpClientResponseBytes(response)
        .timeout(_requestTimeout);
    final charset = response.headers.contentType?.charset?.toLowerCase().trim();
    final enc =
        (charset == 'iso-8859-1' || charset == 'latin1' || charset == 'windows-1252')
            ? latin1
            : utf8;
    final html = _safeDecode(enc, bytes);

    debugPrint('MV token search HTML[0..300]: ${html.length > 300 ? html.substring(0, 300) : html}');

    // Gallery results link to artwork pages (carte_art?ref=xxx) or card pages
    // (carte?ref=xxx), with or without a leading slash. Match both forms.
    final seen = <String>{};
    for (final m in RegExp(
      r'carte(?:_art)?\?ref=([a-z0-9]+)',
      caseSensitive: false,
    ).allMatches(html)) {
      final ref = m.group(1);
      if (ref != null) seen.add(ref);
    }
    debugPrint('MV token search refs found: ${seen.toList()}');
    return seen.toList();
  }

  String _safeDecode(Encoding enc, List<int> bytes) {
    try {
      return enc.decode(bytes);
    } catch (_) {
      return utf8.decode(bytes, allowMalformed: true);
    }
  }

  Future<String?> tryFindCardRefByName(String name) async {
    final refs = await findAllCardRefsByName(name);
    return refs.isEmpty ? null : refs.first;
  }

  /// Returns ALL card refs found in MagicVille's name-search results.
  Future<List<String>> findAllCardRefsByName(String name) async {
    final uri = Uri.parse(
      'https://www.magic-ville.com/fr/upn_search',
    ).replace(queryParameters: {'n': name.toLowerCase()});

    final request = await _http.postUrl(uri);
    request.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0');
    request.headers.set(HttpHeaders.acceptHeader, 'text/html,*/*');
    request.headers.set(HttpHeaders.refererHeader, 'https://www.magic-ville.com/');

    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) return [];

    final body = await response.transform(utf8.decoder).join();
    final seen = <String>{};
    for (final m in RegExp(
      r'carte(?:_art)?\?ref=([a-z0-9]+)',
      caseSensitive: false,
    ).allMatches(body)) {
      final ref = m.group(1);
      if (ref != null && ref.isNotEmpty) seen.add(ref);
    }
    return seen.toList();
  }

  /// Fetches the card page (carte?ref=) and extracts all artwork/card refs
  /// linked from it. This discovers alternate-edition refs that the artwork
  /// page cross-links don't include.
  Future<List<String>> findRefsFromCardPage(String ref) async {
    final uri = Uri.parse('${_base}carte?ref=$ref');
    try {
      final html = await _getHtml(uri);
      final seen = <String>{};
      for (final m in RegExp(
        r'carte(?:_art)?\?ref=([a-z0-9]+)',
        caseSensitive: false,
      ).allMatches(html)) {
        final r = m.group(1);
        if (r != null && r.isNotEmpty) seen.add(r);
      }
      return seen.toList();
    } catch (_) {
      return [];
    }
  }

  Future<(List<int> bytes, String contentType)> downloadImage(
    String imageUrl, {
    String? referer,
  }) async {
    final uri = Uri.parse(imageUrl);

    final req = await _http
        .getUrl(uri)
        .timeout(
          _requestTimeout,
          onTimeout: () {
            throw TimeoutException(
              'MagicVille image getUrl timeout',
              _requestTimeout,
            );
          },
        );

    req.headers.set(
      HttpHeaders.userAgentHeader,
      'Mozilla/5.0 (Android; Flutter)',
    );

    if (referer != null && referer.isNotEmpty) {
      req.headers.set(HttpHeaders.refererHeader, referer);
    }

    final res = await req.close().timeout(
      _requestTimeout,
      onTimeout: () {
        throw TimeoutException(
          'MagicVille image close timeout',
          _requestTimeout,
        );
      },
    );

    if (res.statusCode != 200) {
      throw HttpException(
        'Failed to download image: HTTP ${res.statusCode}',
        uri: uri,
      );
    }

    final mime =
        res.headers.contentType?.mimeType ?? 'application/octet-stream';
    final bytes = await consolidateHttpClientResponseBytes(res).timeout(
      _requestTimeout,
      onTimeout: () {
        throw TimeoutException(
          'MagicVille image read timeout',
          _requestTimeout,
        );
      },
    );

    if (bytes.isEmpty) throw Exception('Downloaded image is empty');
    return (bytes, mime);
  }

  void close() {
    _http.close(force: true);
  }
}
