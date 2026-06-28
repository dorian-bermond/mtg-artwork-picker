import 'package:html/parser.dart' as hp;


class MagicVilleArtworkInfo {
  final String imid;
  final String imageUrl;
  final String artist;
  final List<String> discoveredRefs;
  /// Card name extracted from the img title attribute ("X art by Y" → "X").
  /// Null when no img has a title (rare). Used for DFC face filtering.
  final String? pageCardName;

  MagicVilleArtworkInfo({
    required this.imid,
    required this.imageUrl,
    required this.artist,
    required this.discoveredRefs,
    this.pageCardName,
  });
}

class MagicVilleParser {
  static const _base = 'https://www.magic-ville.com/fr/';

  // Returns (artworks, discoveredRefs).
  // artworks may be empty when the page exists but has no scan_art image.
  // discoveredRefs is always populated from the edition links on the page.
  (List<MagicVilleArtworkInfo>, List<String>) parseArtworkPage(String html) {
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

    // 2) Discovered refs (shared by all artworks on this page).
    // The print-edition links on carte_art pages use a relative query-only
    // form: <a href="?ref=uni010"> — i.e. just "?ref=xxx" with no path.
    // We also accept fully-qualified carte_art?ref= / carte?ref= links.
    final refs = <String>{};
    for (final a in doc.querySelectorAll('a[href]')) {
      final href = a.attributes['href'] ?? '';
      if (href.startsWith('?ref=')) {
        // Relative form used for alternate-edition print links.
        final ref = href.substring('?ref='.length).split('&').first.trim();
        if (ref.isNotEmpty) refs.add(ref);
        continue;
      }
      if (!href.contains('carte_art?ref=') && !href.contains('carte?ref=')) {
        continue;
      }
      final abs = href.startsWith('http')
          ? href
          : '$_base${href.replaceFirst(RegExp(r'^/'), '')}';
      final u = Uri.tryParse(abs);
      final ref = u?.queryParameters['ref']?.trim();
      if (ref != null && ref.isNotEmpty) refs.add(ref);
    }
    final refsList = refs.toList()..sort();

    // 3) Collect all scan_art images.
    // The page card name is shared across all artworks; extract it once from
    // the first img title that contains " art by ".
    String? pageCardName;
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
        if (idx >= 0) {
          // "Delver of Secrets art by Nils Hamm" → name before marker
          pageCardName ??= title.substring(0, idx).trim();
          artist = title.substring(idx + marker.length).trim();
        }
      }
      artist ??= globalArtist;

      results.add(MagicVilleArtworkInfo(
        imid: imid.trim(),
        imageUrl:
            'https://www.magic-ville.com/fr/scan_art?imid=${imid.trim()}',
        artist: (artist?.isNotEmpty == true) ? artist! : 'Unknown Artist',
        discoveredRefs: refsList,
        pageCardName: pageCardName,
      ));
    }

    return (results, refsList);
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
