import 'dart:convert';
import 'dart:io';

import '../core/constants.dart';
import '../core/errors.dart';
import '../core/retry.dart';
import 'http_client.dart';

class ScryfallClient {
  final AppHttpClient http;
  ScryfallClient(this.http);

  Future<Map<String, dynamic>> namedFuzzy(String name) async {
    final uri = Uri.https('api.scryfall.com', '/cards/named', {'fuzzy': name});

    await Future.delayed(kScryfallMinDelay);

    return retry(
      () async {
        final res = await http.get(uri, headers: kScryfallHeaders);
        if (res.statusCode == 429) {
          throw NetworkException('Scryfall rate limited (429).');
        }
        if (res.statusCode < 200 || res.statusCode >= 300) {
          throw NetworkException(
            'Scryfall named failed: ${res.statusCode} ${res.body}',
          );
        }
        return json.decode(res.body) as Map<String, dynamic>;
      },
      maxAttempts: kScryfallMaxRetries,
      retryIf: (e) => e is NetworkException || e is SocketException,
    );
  }

  Future<Map<String, dynamic>> fetchById(String scryfallId) async {
    final uri = Uri.https('api.scryfall.com', '/cards/$scryfallId');
    await Future.delayed(kScryfallMinDelay);
    return retry(
      () async {
        final res = await http.get(uri, headers: kScryfallHeaders);
        if (res.statusCode == 429) throw NetworkException('Scryfall rate limited (429).');
        if (res.statusCode < 200 || res.statusCode >= 300) {
          throw NetworkException('Scryfall fetchById failed: ${res.statusCode} ${res.body}');
        }
        return json.decode(res.body) as Map<String, dynamic>;
      },
      maxAttempts: kScryfallMaxRetries,
      retryIf: (e) => e is NetworkException || e is SocketException,
    );
  }

  /// Search cards by [query] using the /cards/search endpoint.
  /// [unique] controls deduplication (default: 'cards' = one per oracle_id).
  Stream<Map<String, dynamic>> search(
    String query, {
    String unique = 'cards',
  }) {
    final uri = Uri.https('api.scryfall.com', '/cards/search', {
      'q': query,
      'unique': unique,
      'order': 'name',
    });
    return fetchAllPrintings(uri.toString());
  }

  /// Follow prints_search_uri pagination.
  Stream<Map<String, dynamic>> fetchAllPrintings(
    String printsSearchUri,
  ) async* {
    String? next = printsSearchUri;

    while (next != null) {
      await Future.delayed(kScryfallMinDelay);

      final page = await retry(
        () async {
          final res = await http.getUrl(next!, headers: kScryfallHeaders);
          if (res.statusCode == 429) {
            throw NetworkException('Scryfall rate limited (429).');
          }
          if (res.statusCode < 200 || res.statusCode >= 300) {
            throw NetworkException(
              'Scryfall prints failed: ${res.statusCode} ${res.body}',
            );
          }
          return json.decode(res.body) as Map<String, dynamic>;
        },
        maxAttempts: kScryfallMaxRetries,
        retryIf: (e) => e is NetworkException || e is SocketException,
      );

      final data = (page['data'] as List).cast<Map<String, dynamic>>();
      for (final item in data) {
        yield item;
      }

      final hasMore = page['has_more'] == true;
      next = hasMore ? (page['next_page'] as String?) : null;
    }
  }
}
