import 'package:html/parser.dart' as hp;

import '../core/errors.dart';

class MagicVilleArtworkInfo {
  final String imid;
  final String imageUrl;
  final String artist;
  final List<String> discoveredRefs;

  MagicVilleArtworkInfo({
    required this.imid,
    required this.imageUrl,
    required this.artist,
    required this.discoveredRefs,
  });
}

class MagicVilleParser {
  static const _base = 'https://www.magic-ville.com/fr/';

  // Returns one entry per distinct artwork on the page (pages can have multiple).
  List<MagicVilleArtworkInfo> parseArtworkPage(String html) {
    final doc = hp.parse(html);

    // 1) Global artist fallback (used when a specific img has no title)
    final globalArtist = doc
        .querySelectorAll('a[href]')
        .where(
          (a) => (a.attributes['href'] ?? '').startsWith(
            'rech_art_cards.php?art=',
          ),
        )
        .map((a) => a.text.trim())
        .where((t) => t.isNotEmpty)
        .cast<String?>()
        .firstOrNull;

    // 2) Discovered refs (shared by all artworks on this page)
    final refs = <String>{};
    for (final a in doc.querySelectorAll('a[href]')) {
      final href = a.attributes['href'] ?? '';
      if (!href.contains('carte_art?ref=')) continue;
      final abs = href.startsWith('http')
          ? href
          : '$_base${href.replaceFirst(RegExp(r'^/'), '')}';
      final u = Uri.tryParse(abs);
      final ref = u?.queryParameters['ref']?.trim();
      if (ref != null && ref.isNotEmpty) refs.add(ref);
    }
    final refsList = refs.toList()..sort();

    // 3) Collect all scan_art images
    final results = <MagicVilleArtworkInfo>[];
    final seenImids = <String>{};

    for (final e in doc.querySelectorAll('img')) {
      final s = e.attributes['src'];
      if (s == null) continue;
      if (!s.startsWith('scan_art?imid=') && !s.contains('scan_art?imid=')) {
        continue;
      }

      final uri = Uri.parse(s.startsWith('http') ? s : '$_base$s');
      final imid =
          uri.queryParameters['imid'] ??
          (() {
            final idx = s.indexOf('scan_art?imid=');
            return idx >= 0
                ? s.substring(idx + 'scan_art?imid='.length).split('&').first
                : null;
          })();

      if (imid == null || imid.trim().isEmpty) continue;
      if (!seenImids.add(imid.trim())) continue;

      String? artist;
      final title = e.attributes['title'];
      if (title != null) {
        const marker = ' art by ';
        final idx = title.toLowerCase().indexOf(marker);
        if (idx >= 0) artist = title.substring(idx + marker.length).trim();
      }
      artist ??= globalArtist;

      results.add(MagicVilleArtworkInfo(
        imid: imid.trim(),
        imageUrl:
            'https://www.magic-ville.com/fr/scan_art?imid=${imid.trim()}',
        artist: (artist?.isNotEmpty == true) ? artist! : 'Unknown Artist',
        discoveredRefs: refsList,
      ));
    }

    if (results.isEmpty) {
      throw ParseException('MagicVille: scan_art image not found');
    }

    return results;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
