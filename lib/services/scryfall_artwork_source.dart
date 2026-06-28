import 'dart:io';

import 'package:flutter/foundation.dart';

import 'artwork_source.dart';
import 'scryfall_client.dart';

/// Fallback artwork source: fetches [image_uris.art_crop] from Scryfall.
///
/// Unlike the main pipeline fetch (which is filtered to en/fr), this queries
/// ALL language printings via the unfiltered [printsSearchUri] so that
/// language-exclusive artworks (e.g. Japanese promos) are included.
/// Artworks are deduplicated by their art_crop URL so identical art shared
/// across language variants is not downloaded twice.
class ScryfallArtworkSource implements ArtworkSource {
  final ScryfallClient _scryfall;
  final String _printsSearchUri;
  final HttpClient _http;

  ScryfallArtworkSource({
    required ScryfallClient scryfall,
    required String printsSearchUri,
    HttpClient? http,
  })  : _scryfall = scryfall,
        _printsSearchUri = printsSearchUri,
        _http = http ?? HttpClient() {
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
    final seenUrls = <String>{};

    await for (final p in _scryfall.fetchAllPrintings(_printsSearchUri)) {
      String? url;
      String artist = 'Unknown Artist';

      // DFC: prefer the matching face's image_uris.
      final faces = p['card_faces'] as List?;
      if (faces != null && faceIndex < faces.length) {
        final face = faces[faceIndex] as Map<String, dynamic>;
        url = (face['image_uris'] as Map?)?['art_crop'] as String?;
        artist = (face['artist'] as String?)?.trim() ?? artist;
      }

      // Single-face or DFC without per-face image_uris.
      if (url == null) {
        url = (p['image_uris'] as Map?)?['art_crop'] as String?;
        artist = (p['artist'] as String?)?.trim() ?? artist;
      }

      if (url == null || !seenUrls.add(url)) continue;

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
