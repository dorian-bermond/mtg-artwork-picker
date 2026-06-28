import 'dart:convert';

import 'http_client.dart';

class DeckImportResult {
  final String deckName;
  final List<String> cardLines;
  DeckImportResult({required this.deckName, required this.cardLines});
}

class DeckImportService {
  final AppHttpClient _http;
  DeckImportService(this._http);

  Future<DeckImportResult> importFromUrl(String rawUrl) async {
    final url = rawUrl.trim();
    if (url.contains('moxfield.com/decks/')) return _importMoxfield(url);
    if (url.contains('archidekt.com/decks/')) return _importArchidekt(url);
    if (url.contains('mtggoldfish.com/deck/')) return _importMtgGoldfish(url);
    throw UnsupportedError(
      'Unsupported URL.\nSupported: Moxfield, Archidekt, MTGGoldfish.',
    );
  }

  Future<DeckImportResult> _importMoxfield(String url) async {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final idx = segments.indexOf('decks');
    if (idx < 0 || idx + 1 >= segments.length) {
      throw FormatException('Cannot extract deck ID from Moxfield URL.');
    }
    final deckId = segments[idx + 1];

    final resp = await _http.getUrl(
      'https://api2.moxfield.com/v3/decks/all/$deckId',
      headers: {
        'User-Agent':
            'Mozilla/5.0 (compatible; MTGArtworkPicker/1.0)',
        'Accept': 'application/json',
      },
    );

    if (resp.statusCode == 404) {
      throw Exception('Deck not found. Is it public?');
    }
    if (resp.statusCode != 200) {
      throw Exception('Moxfield returned HTTP ${resp.statusCode}.');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final deckName = json['name'] as String? ?? 'Moxfield Deck';
    final boards = json['boards'] as Map<String, dynamic>? ?? {};

    const wantBoards = ['commanders', 'companions', 'mainboard'];
    final counts = <String, int>{};

    for (final boardName in wantBoards) {
      final board = boards[boardName] as Map<String, dynamic>?;
      if (board == null) continue;
      final cards = board['cards'] as Map<String, dynamic>? ?? {};
      for (final entry in cards.values) {
        final e = entry as Map<String, dynamic>;
        final name =
            ((e['card'] as Map<String, dynamic>?)
                    ?['name'] as String?) ??
                '';
        final qty = e['quantity'] as int? ?? 1;
        if (name.isNotEmpty) counts[name] = (counts[name] ?? 0) + qty;
      }
    }

    return DeckImportResult(
      deckName: deckName,
      cardLines: counts.entries.map((e) => '${e.value} ${e.key}').toList(),
    );
  }

  Future<DeckImportResult> _importArchidekt(String url) async {
    final uri = Uri.parse(url);
    final segments =
        uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final idx = segments.indexOf('decks');
    if (idx < 0 || idx + 1 >= segments.length) {
      throw FormatException('Cannot extract deck ID from Archidekt URL.');
    }
    final deckId = segments[idx + 1];

    final resp = await _http.getUrl(
      'https://archidekt.com/api/decks/$deckId/',
      headers: {'Accept': 'application/json'},
    );

    if (resp.statusCode == 404) {
      throw Exception('Deck not found. Is it public?');
    }
    if (resp.statusCode != 200) {
      throw Exception('Archidekt returned HTTP ${resp.statusCode}.');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final deckName = json['name'] as String? ?? 'Archidekt Deck';
    final cards = json['cards'] as List<dynamic>? ?? [];
    final counts = <String, int>{};

    for (final raw in cards) {
      final e = raw as Map<String, dynamic>;

      // Skip cards in sideboard categories
      final cats = e['categories'] as List<dynamic>? ?? [];
      final isSideboard = cats.any((c) {
        if (c is String) return c.toLowerCase() == 'sideboard';
        if (c is Map<String, dynamic>) {
          return (c['name'] as String?)?.toLowerCase() == 'sideboard' &&
              c['includedInDeck'] != true;
        }
        return false;
      });
      if (isSideboard) continue;

      final cardObj = e['card'] as Map<String, dynamic>?;
      final oracle = cardObj?['oracleCard'] as Map<String, dynamic>?;
      final name = oracle?['name'] as String? ?? '';
      final qty = e['quantity'] as int? ?? 1;
      if (name.isNotEmpty) counts[name] = (counts[name] ?? 0) + qty;
    }

    return DeckImportResult(
      deckName: deckName,
      cardLines: counts.entries.map((e) => '${e.value} ${e.key}').toList(),
    );
  }

  Future<DeckImportResult> _importMtgGoldfish(String url) async {
    final uri = Uri.parse(url);
    final segments =
        uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final idx = segments.indexOf('deck');
    if (idx < 0 || idx + 1 >= segments.length) {
      throw FormatException('Cannot extract deck ID from MTGGoldfish URL.');
    }
    final deckId = segments[idx + 1].split('#').first;

    final resp = await _http.getUrl(
      'https://www.mtggoldfish.com/deck/download/$deckId',
      headers: {'User-Agent': 'Mozilla/5.0 (compatible; MTGArtworkPicker/1.0)'},
    );

    if (resp.statusCode == 404) {
      throw Exception('Deck not found. Is it public?');
    }
    if (resp.statusCode != 200) {
      throw Exception('MTGGoldfish returned HTTP ${resp.statusCode}.');
    }

    // Plain-text deck list: "N Card Name\n..." with optional "Sideboard\n" separator
    final lines = <String>[];
    var inSideboard = false;
    for (final raw in resp.body.split('\n')) {
      final line = raw.trim();
      if (line.toLowerCase() == 'sideboard') {
        inSideboard = true;
        continue;
      }
      if (inSideboard || line.isEmpty) continue;
      lines.add(line);
    }

    return DeckImportResult(deckName: 'MTGGoldfish Deck', cardLines: lines);
  }
}
