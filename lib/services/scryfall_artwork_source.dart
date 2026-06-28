import 'dart:io';

import 'package:flutter/foundation.dart';

import 'artwork_source.dart';

/// Fallback artwork source: fetches [image_uris.art_crop] from Scryfall.
/// Covers all printings returned by the pipeline's Scryfall lookup, so
/// every edition gets one art_crop image even when MagicVille has nothing.
class ScryfallArtworkSource implements ArtworkSource {
  final HttpClient _http;

  ScryfallArtworkSource({HttpClient? http}) : _http = http ?? HttpClient() {
    _http.connectionTimeout = const Duration(seconds: 15);
    _http.idleTimeout = const Duration(seconds: 15);
  }

  @override
  String get providerId => 'scryfall_artcrop';

  @override
  Future<List<SourcedArtwork>?> tryFetch({
    required String faceName,
    required List<Map<String, dynamic>> printings,
    required int faceIndex,
  }) async {
    final results = <SourcedArtwork>[];
    for (final p in printings) {
      String? url;
      String artist = 'Unknown Artist';

      // DFC: prefer the matching face's image_uris.
      final faces = p['card_faces'] as List?;
      if (faces != null && faceIndex < faces.length) {
        final face = faces[faceIndex] as Map<String, dynamic>;
        url = (face['image_uris'] as Map?)?['art_crop'] as String?;
        artist = (face['artist'] as String?)?.trim() ?? artist;
      }

      // Fallback to top-level image_uris (single-face cards).
      if (url == null) {
        url = (p['image_uris'] as Map?)?['art_crop'] as String?;
        artist = (p['artist'] as String?)?.trim() ?? artist;
      }

      if (url == null) continue;

      // Prefix the Scryfall printing ID so it's clearly namespaced.
      final remoteId = 'scryfall:${p['id'] ?? url}';
      results.add(SourcedArtwork(
        remoteId: remoteId,
        imageUrl: url,
        artist: artist.isEmpty ? 'Unknown Artist' : artist,
      ));
    }
    return results.isEmpty ? null : results;
  }

  @override
  Future<(List<int>, String)> downloadImage(SourcedArtwork artwork) async {
    final uri = Uri.parse(artwork.imageUrl);
    final req = await _http.getUrl(uri);
    req.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 (Android; Flutter)');
    final res = await req.close();
    if (res.statusCode != 200) {
      throw HttpException('Scryfall art_crop HTTP ${res.statusCode}', uri: uri);
    }
    final bytes = await consolidateHttpClientResponseBytes(res);
    final mime = res.headers.contentType?.mimeType ?? 'image/jpeg';
    return (bytes, mime);
  }

  void close() => _http.close(force: true);
}
