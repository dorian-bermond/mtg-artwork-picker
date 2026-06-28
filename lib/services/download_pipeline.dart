import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:mtg_artwork_picker/core/normalize.dart';
import 'package:mtg_artwork_picker/services/magicville_parser.dart';

import '../data/db/app_database.dart' as db;
import '../data/db/daos.dart' show PrintDataDao;
import '../data/models/provider_id.dart';
import '../data/repositories/artwork_repository.dart';
import '../services/image_store.dart';
import '../services/magicville_client.dart';
import '../services/scryfall_client.dart';
import '../services/set_icon_service.dart';

class DownloadProgress {
  final int totalCards;
  final int processedCards;
  final int artworksDiscovered;
  final int artworksDownloaded;
  final String? currentCardName;
  final String? message;

  const DownloadProgress({
    required this.totalCards,
    required this.processedCards,
    required this.artworksDiscovered,
    required this.artworksDownloaded,
    this.currentCardName,
    this.message,
  });

  DownloadProgress copyWith({
    int? totalCards,
    int? processedCards,
    int? artworksDiscovered,
    int? artworksDownloaded,
    String? currentCardName,
    String? message,
  }) {
    return DownloadProgress(
      totalCards: totalCards ?? this.totalCards,
      processedCards: processedCards ?? this.processedCards,
      artworksDiscovered: artworksDiscovered ?? this.artworksDiscovered,
      artworksDownloaded: artworksDownloaded ?? this.artworksDownloaded,
      currentCardName: currentCardName ?? this.currentCardName,
      message: message ?? this.message,
    );
  }
}

class _CardRunEvent {
  final String? message;
  final int discoveredDelta;
  final int downloadedDelta;

  const _CardRunEvent({
    this.message,
    this.discoveredDelta = 0,
    this.downloadedDelta = 0,
  });
}

class DownloadRunLog {
  final List<String> _lines = [];
  File? _logFile;

  /// Call before starting a run to persist logs to [file] (overwrites existing).
  void setFile(File file) {
    _logFile = file;
    try {
      file.writeAsStringSync('', flush: true);
    } catch (_) {}
  }

  void add(String line) {
    final ts = DateTime.now().toIso8601String().substring(11, 19);
    final entry = '[$ts] $line';
    _lines.add(entry);
    final f = _logFile;
    if (f != null) {
      f.writeAsString('$entry\n', mode: FileMode.append, flush: true).ignore();
    }
  }

  List<String> get lines => List.unmodifiable(_lines);

  void clear() {
    _lines.clear();
    _logFile = null;
  }
}

class _PrintingMeta {
  final String setName;
  final String releasedAt;
  final Set<String> artists = {};
  String? collectorNumber;
  String? rarity;
  Map<String, dynamic>? lastPrinting; // most recently seen printing for this set+lang
  int? printDataId;                   // FK to card_print_data, filled after upsert
  _PrintingMeta(this.setName, this.releasedAt);
}

class DownloadPipeline {
  final db.AppDatabase database;
  final ScryfallClient scryfall;
  final MagicVilleClient magicville;
  final ImageStore imageStore;
  final ArtworkRepository artworkRepo;
  final SetIconService setIconService;

  DownloadPipeline({
    required this.database,
    required this.scryfall,
    required this.magicville,
    required this.imageStore,
    required this.artworkRepo,
    required this.setIconService,
  });

  static final _dfcSeparator = RegExp(r'\s*(?://|\|\||\\\\)\s*');

  List<String> _splitFaceNames(String name) {
    final parts = name
        .split(_dfcSeparator)
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.length > 1 ? parts : [name];
  }

  String _buildMagicVilleRef({
    required String set,
    required String collectorNumber,
  }) {
    final s = set.toLowerCase().trim();
    final cn = collectorNumber.trim();

    final digitsOnly = RegExp(r'^\d+$').hasMatch(cn);
    final padded = digitsOnly ? cn.padLeft(3, '0') : cn;
    return '$s$padded';
  }

  String _addLangFilterToPrintsUri(String printsUri) {
    // Your requested injection:
    // replace "&unique=prints" with "+(lang:en+OR+lang:fr)&unique=prints"
    // IMPORTANT: assign result; strings are immutable.
    return printsUri.replaceAll(
      "&unique=prints",
      "+(lang:en+OR+lang:fr)&unique=prints",
    );
  }

  /// Extracts functional print data from a Scryfall card object, applies
  /// printed_X overrides, and upserts into card_print_data. Returns the row ID.
  Future<int> _upsertPrintDataForCard(
    int cardId,
    Map<String, dynamic> p,
  ) async {
    final lang = (p['lang'] as String?)?.trim() ?? 'en';

    // Apply printed_X overrides for non-English printings.
    final rawName = (p['name'] as String?)?.trim() ?? '';
    final printedName = (p['printed_name'] as String?)?.trim();
    final name = (printedName != null && printedName.isNotEmpty)
        ? printedName
        : rawName;

    final rawTypeLine = (p['type_line'] as String?)?.trim();
    final printedTypeLine = (p['printed_type_line'] as String?)?.trim();
    final topTypeLine =
        (printedTypeLine != null && printedTypeLine.isNotEmpty)
            ? printedTypeLine
            : rawTypeLine;

    final rawOracleText = (p['oracle_text'] as String?)?.trim();
    final printedText = (p['printed_text'] as String?)?.trim();
    final topOracleText =
        (printedText != null && printedText.isNotEmpty)
            ? printedText
            : rawOracleText;

    // For DFCs, prefer face[0] for oracle_text, type_line, flavor_text.
    final faces = p['card_faces'] as List<dynamic>?;
    final String? typeLine;
    final String? oracleText;
    final String? flavorText;
    if (faces != null && faces.isNotEmpty) {
      final f0 = faces[0] as Map<String, dynamic>;
      final f0TypeLine = (f0['printed_type_line'] as String?)?.trim();
      typeLine = (f0TypeLine != null && f0TypeLine.isNotEmpty)
          ? f0TypeLine
          : (f0['type_line'] as String?)?.trim() ?? topTypeLine;
      final f0OracleText = (f0['printed_text'] as String?)?.trim();
      oracleText = (f0OracleText != null && f0OracleText.isNotEmpty)
          ? f0OracleText
          : (f0['oracle_text'] as String?)?.trim() ?? topOracleText;
      flavorText = (f0['flavor_text'] as String?)?.trim();
    } else {
      typeLine = topTypeLine;
      oracleText = topOracleText;
      flavorText = (p['flavor_text'] as String?)?.trim();
    }

    final flavorName = (p['flavor_name'] as String?)?.trim();
    final manaCost = (p['mana_cost'] as String?)?.trim();
    final power = (p['power'] as String?)?.trim();
    final toughness = (p['toughness'] as String?)?.trim();
    final loyalty = (p['loyalty'] as String?)?.trim();
    final layout = (p['layout'] as String?)?.trim();

    // Encode array fields as JSON strings.
    final colorsRaw = p['colors'] as List<dynamic>?;
    final colorIdentityRaw = p['color_identity'] as List<dynamic>?;
    final keywordsRaw = p['keywords'] as List<dynamic>?;
    final colors =
        colorsRaw != null ? jsonEncode(colorsRaw.cast<String>()) : null;
    final colorIdentity = colorIdentityRaw != null
        ? jsonEncode(colorIdentityRaw.cast<String>())
        : null;
    final keywords = keywordsRaw != null
        ? jsonEncode(keywordsRaw.cast<String>())
        : null;

    final hash = PrintDataDao.computeHash(
      lang: lang,
      name: name,
      flavorName: flavorName,
      manaCost: manaCost,
      typeLine: typeLine,
      oracleText: oracleText,
      flavorText: flavorText,
      power: power,
      toughness: toughness,
      loyalty: loyalty,
      colors: colors,
      colorIdentity: colorIdentity,
      keywords: keywords,
      layout: layout,
    );

    return database.printDataDao.upsertGetId(
      db.CardPrintDataCompanion.insert(
        cardId: cardId,
        contentHash: hash,
        lang: lang,
        name: name,
        flavorName: Value(flavorName),
        manaCost: Value(manaCost),
        typeLine: Value(typeLine),
        oracleText: Value(oracleText),
        flavorText: Value(flavorText?.isEmpty == true ? null : flavorText),
        power: Value(power),
        toughness: Value(toughness),
        loyalty: Value(loyalty),
        colors: Value(colors),
        colorIdentity: Value(colorIdentity),
        keywords: Value(keywords),
        layout: Value(layout),
      ),
    );
  }

  /// MagicVille seed-finding + artwork download for one face card.
  /// [faceName] is the resolved single-face name used for name-search and file naming.
  Stream<_CardRunEvent> _downloadMagicVilleArtworks({
    required int projectId,
    required db.Card card,
    required String faceName,
    required String providerId,
    required List<Map<String, dynamic>> printings,
    required bool seedFromNameOnly,
    bool isToken = false,
  }) async* {
    List<MagicVilleArtworkInfo>? seed;
    String? seedRef;
    // For tokens we get all illustrations at once — user sorts them out.
    Set<String>? tokenRefQueue;

    if (isToken) {
      // Use MagicVille's advanced search (POST /fr/resultats) to find all refs
      // for this token name. This returns the actual MagicVille refs regardless
      // of whether Scryfall set codes match MagicVille's numbering.
      final searchName = faceName
          .replaceFirst(RegExp(r'\s+Token$', caseSensitive: false), '')
          .trim();

      yield _CardRunEvent(
        message: 'Searching MagicVille for token "$searchName"…',
      );
      var seedRefs = await magicville.findAllTokenRefsForName(searchName);
      yield _CardRunEvent(
        message: '${seedRefs.length} ref(s) found${seedRefs.isNotEmpty ? ": ${seedRefs.join(", ")}" : ""}',
      );

      // Fallback: simple name search when the advanced search returns nothing.
      if (seedRefs.isEmpty) {
        final fallback = await magicville.tryFindCardRefByName(searchName);
        if (fallback != null) {
          yield _CardRunEvent(message: 'Name search fallback ref=$fallback');
          seedRefs = [fallback];
        }
      }

      if (seedRefs.isEmpty) {
        yield _CardRunEvent(
          message: 'No MagicVille refs found for token "$searchName"',
        );
        return;
      }

      tokenRefQueue = seedRefs.toSet();
    } else if (seedFromNameOnly) {
      yield const _CardRunEvent(message: 'Searching MagicVille by name…');
      final ref = await magicville.tryFindCardRefByName(faceName);
      if (ref == null) {
        yield _CardRunEvent(message: 'No MagicVille ref found for $faceName');
        return;
      }
      yield _CardRunEvent(message: 'Name search matched ref=$ref');
      final mv = await magicville.tryFetchArtworkInfo(ref: ref);
      if (mv == null) {
        yield _CardRunEvent(message: 'Found ref=$ref but artwork page failed.');
        return;
      }
      seed = mv;
      seedRef = ref;
    } else {
      yield const _CardRunEvent(message: 'Finding MagicVille seed…');

      for (final p in printings) {
        final set = (p['set'] as String?)?.trim().toLowerCase();
        final collector = (p['collector_number'] as String?)?.trim();

        if (set == null || set.isEmpty || collector == null || collector.isEmpty) {
          continue;
        }
        // PLST (The List) and SLD (Secret Lair Drop) use Scryfall-only numbering
        // that has no correspondence in MagicVille.
        if (set == 'plst' || set == 'sld') continue;

        final ref = _buildMagicVilleRef(set: set, collectorNumber: collector);
        yield _CardRunEvent(message: 'Trying $ref...');
        final mv = await magicville.tryFetchArtworkInfo(ref: ref);
        if (mv != null) {
          yield _CardRunEvent(message: 'Matched $ref...');
          seed = mv;
          seedRef = ref;
          break;
        }
      }

      if (seed == null) {
        yield const _CardRunEvent(message: 'No MagicVille seed page found.');
        return;
      }
    }

    final refQueue = tokenRefQueue ?? <String>{
      ?seedRef,
      ...seed!.first.discoveredRefs,
    };

    final seenImids = <String>{};
    int tokenRefsMatched = 0;
    int tokenRefsMissed = 0;

    for (final ref in refQueue) {
      try {
        final mvList = await magicville.tryFetchArtworkInfo(ref: ref);
        if (mvList == null) {
          if (isToken) tokenRefsMissed++;
          continue;
        }

        if (isToken) {
          tokenRefsMatched++;
          yield _CardRunEvent(message: '$ref: found ${mvList.length} artwork(s)');
        }

        for (final mv in mvList) {
          final remoteId = mv.imid;
          if (!seenImids.add(remoteId)) {
            if (isToken) yield _CardRunEvent(message: '$ref: imid=$remoteId duplicate, skipping');
            continue;
          }

          final exists = await database.artworksDao.artworkExistsByRemoteId(
            cardId: card.id,
            providerId: providerId,
            remoteId: remoteId,
          );
          if (exists) {
            if (isToken) yield _CardRunEvent(message: '$ref: imid=$remoteId already saved');
            continue;
          }

          yield _CardRunEvent(
            message: 'Downloading imid=$remoteId from $ref…',
            discoveredDelta: 1,
          );

          final referer =
              'https://www.magic-ville.com/fr/carte_art?ref=$ref';
          final (bytes, contentType) = await magicville.downloadImage(
            mv.imageUrl,
            referer: referer,
          );

          final artist =
              mv.artist.trim().isEmpty ? 'Unknown Artist' : mv.artist.trim();

          final occurrence = await artworkRepo.countArtistOccurrencesForCard(
            card.id,
            artist,
          );

          final stored = await imageStore.saveArtwork(
            projectId: projectId,
            cardName: faceName,
            artistName: artist,
            bytes: Uint8List.fromList(bytes),
            contentType: contentType,
            occurrenceIndexForSameArtist: occurrence,
          );

          await database.artworksDao.insertArtwork(
            db.ArtworksCompanion.insert(
              cardId: card.id,
              sourceProviderId: providerId,
              remoteId: Value(remoteId),
              magicVilleRef: Value(ref),
              artist: artist,
              width: stored.width,
              height: stored.height,
              sourceUrl: mv.imageUrl,
              localPath: stored.originalFile.path,
              downloadedAt: DateTime.now(),
              isDiscarded: const Value(false),
            ),
          );

          yield const _CardRunEvent(message: 'Saved.', downloadedDelta: 1);
        }
      } catch (e) {
        yield _CardRunEvent(message: 'Skipped $ref: $e');
      }
    }

    if (isToken && (tokenRefsMatched > 0 || tokenRefsMissed > 0)) {
      yield _CardRunEvent(
        message: 'Token probe complete: $tokenRefsMatched ref(s) with artwork, $tokenRefsMissed ref(s) not on MagicVille',
      );
    }
  }

  /// Returns the raw scryfall_id stored for [cardId], or null.
  Future<String?> _readScryfallId(int cardId) async {
    try {
      final rows = await database.customSelect(
        'SELECT scryfall_id FROM cards WHERE id = ?',
        variables: [Variable(cardId)],
      ).get();
      return rows.isNotEmpty ? rows.first.data['scryfall_id'] as String? : null;
    } catch (_) {
      return null;
    }
  }

  /// Return an existing token card for this project (by scryfall_id or
  /// normalized name), inserting a new row only when none is found.
  Future<db.Card?> _insertOrGetTokenCard(
    int projectId,
    String name,
    String scryfallId,
  ) async {
    final normalized = normalizeCardName(name);

    // Check by scryfall_id first (most precise), then by normalized name.
    var rows = await database.customSelect(
      'SELECT * FROM cards WHERE project_id = ? AND scryfall_id = ?',
      variables: [Variable(projectId), Variable(scryfallId)],
    ).get();

    if (rows.isEmpty) {
      rows = await database.customSelect(
        'SELECT * FROM cards WHERE project_id = ? AND normalized_name = ?',
        variables: [Variable(projectId), Variable(normalized)],
      ).get();
    }

    if (rows.isNotEmpty) return database.cards.map(rows.first.data);

    // Not found — insert and return the new row.
    await database.customStatement(
      'INSERT INTO cards'
      ' (project_id, name, normalized_name, no_flavor_text, selected_extension_is_void, scryfall_id)'
      ' VALUES (?, ?, ?, 0, 0, ?)',
      [projectId, name, normalized, scryfallId],
    );
    rows = await database.customSelect(
      'SELECT * FROM cards WHERE project_id = ? AND scryfall_id = ?',
      variables: [Variable(projectId), Variable(scryfallId)],
    ).get();
    if (rows.isEmpty) return null;
    return database.cards.map(rows.first.data);
  }

  Stream<_CardRunEvent> _runForCard({
    required int projectId,
    required db.Card card,
    required String providerId,
    String? overrideScryfallId,
    bool seedFromNameOnly = false,
    bool importTokens = false,
  }) async* {
    // --------------------------------------------------
    // 1) Scryfall lookup — by ID for tokens, fuzzy for regular cards
    // --------------------------------------------------
    Map<String, dynamic> named;
    try {
      final scryfallId = overrideScryfallId ?? await _readScryfallId(card.id);
      if (scryfallId != null) {
        yield const _CardRunEvent(message: 'Scryfall fetch by ID…');
        named = await scryfall.fetchById(scryfallId);
      } else {
        yield const _CardRunEvent(message: 'Scryfall named (fuzzy)…');
        named = await scryfall.namedFuzzy(card.name);
      }
    } catch (e) {
      yield _CardRunEvent(message: 'Scryfall lookup failed: $e');
      return;
    }

    // Detect tokens via Scryfall layout — all Scryfall cards use object:"card";
    // tokens are distinguished by layout:"token" (or "emblem" for planeswalkers).
    final bool isToken =
        overrideScryfallId != null ||
        (named['layout'] as String?) == 'token' ||
        (named['layout'] as String?) == 'emblem';

    final printsUri = named['prints_search_uri'] as String?;
    if (printsUri == null) {
      yield const _CardRunEvent(message: 'No prints_search_uri; skipping.');
      return;
    }

    final filteredPrintsUri = _addLangFilterToPrintsUri(printsUri);

    final printings = <Map<String, dynamic>>[];
    final discoveredSets = <String>{};
    final printingData = <String, _PrintingMeta>{};
    // Deferred flavor entries: (set, collector, lang, perFaceFlavors).
    // perFaceFlavors[0] = front face / single card, [1] = back face.
    final flavorEntries = <(String, String, String?, List<String?>, bool)>[];
    String? actualCardName;
    final scryfallLayout = (named['layout'] as String?)?.trim();
    final scryfallCardType = _extractCardType((named['type_line'] as String?)?.trim());

    yield const _CardRunEvent(message: 'Fetching all printings (en/fr)…');

    try {
      await for (final p in scryfall.fetchAllPrintings(filteredPrintsUri)) {
        printings.add(p);

        actualCardName ??= (p['name'] as String?)?.trim();

        final set = (p['set'] as String?)?.trim().toLowerCase();
        final collector = (p['collector_number'] as String?)?.trim();
        final lang = (p['lang'] as String?)?.trim().toLowerCase();
        final setName = (p['set_name'] as String?)?.trim() ?? '';
        final releasedAt = (p['released_at'] as String?)?.trim() ?? '';

        if (set != null && set.isNotEmpty) {
          discoveredSets.add(set);

          if (lang != null && lang.isNotEmpty) {
            final key = '$set|$lang';
            final meta = printingData.putIfAbsent(
              key,
              () => _PrintingMeta(setName, releasedAt),
            );
            // Collect artist(s): top-level field + per-face for DFCs.
            final topArtist = (p['artist'] as String?)?.trim();
            if (topArtist != null && topArtist.isNotEmpty) {
              meta.artists.add(topArtist);
            }
            final faces = p['card_faces'] as List<dynamic>?;
            if (faces != null) {
              for (final f in faces) {
                final fa =
                    ((f as Map<String, dynamic>)['artist'] as String?)?.trim();
                if (fa != null && fa.isNotEmpty) meta.artists.add(fa);
              }
            }
            // Track collector number, rarity, and the raw printing object for
            // print_data extraction (last-seen per set+lang wins).
            if (collector != null && collector.isNotEmpty) {
              meta.collectorNumber = collector;
            }
            final rawRarity = (p['rarity'] as String?)?.trim();
            if (rawRarity != null && rawRarity.isNotEmpty) {
              meta.rarity = rawRarity;
            }
            meta.lastPrinting = p;
          }

          if (collector != null && collector.isNotEmpty) {
            // Prefer per-face flavor text (DFCs); fall back to top-level.
            final faces = p['card_faces'] as List<dynamic>?;
            final List<String?> faceFlavors;
            if (faces != null && faces.isNotEmpty) {
              faceFlavors = [
                for (final f in faces)
                  ((f as Map<String, dynamic>)['flavor_text'] as String?)
                      ?.trim(),
              ];
            } else {
              faceFlavors = [(p['flavor_text'] as String?)?.trim()];
            }
            if (faceFlavors.any((f) => f != null && f.isNotEmpty)) {
              // Localization: en is always localized; for other langs, check
              // whether Scryfall has a printed_type_line that differs from the
              // English type_line for this specific print.
              final bool hasLoc;
              if (lang == null || lang == 'en') {
                hasLoc = true;
              } else {
                final typeLine = (p['type_line'] as String?)?.trim() ?? '';
                final printedTypeLine =
                    (p['printed_type_line'] as String?)?.trim();
                hasLoc = printedTypeLine != null &&
                    printedTypeLine.isNotEmpty &&
                    printedTypeLine != typeLine;
              }
              flavorEntries.add((set, collector, lang, faceFlavors, hasLoc));
            }
          }
        }
      }
    } catch (e) {
      yield _CardRunEvent(message: 'Printings fetch partially failed: $e');
    }

    if (printings.isEmpty) {
      yield const _CardRunEvent(
        message: 'No printings found (en/fr filter may be too strict).',
      );
      return;
    }

    // Upsert print data entries for each (set, lang) combination.
    for (final entry in printingData.entries) {
      final meta = entry.value;
      final p = meta.lastPrinting;
      if (p == null) continue;
      try {
        meta.printDataId = await _upsertPrintDataForCard(card.id, p);
      } catch (e) {
        yield _CardRunEvent(message: 'Print data upsert failed: $e');
      }
    }

    // Build printing rows now that all artists/localization per (set, lang) are collected.
    final printingRows = printingData.entries.map((e) {
      final parts = e.key.split('|');
      final meta = e.value;
      return db.CardDiscoveredPrintingsCompanion.insert(
        cardId: card.id,
        setCode: parts[0],
        lang: parts[1],
        setName: meta.setName,
        releasedAt: meta.releasedAt,
        artists: Value(meta.artists.isEmpty ? null : meta.artists.join(',')),
        printDataId: Value(meta.printDataId),
        collectorNumber: Value(meta.collectorNumber),
        rarity: Value(meta.rarity),
      );
    }).toList();

    // Replace discovered sets and printings for this card
    await database.cardDiscoveredSetsDao.replaceSetsForCard(
      card.id,
      discoveredSets,
    );
    await database.cardDiscoveredPrintingsDao.replaceForCard(
      card.id,
      printingRows,
    );

    if (discoveredSets.isNotEmpty) {
      final setsList = discoveredSets.toList()..sort();
      yield _CardRunEvent(message: 'Sets found: ${setsList.join(', ')}');
      for (final setCode in discoveredSets) {
        unawaited(setIconService.getIconBytes(setCode));
      }
    }

    // --------------------------------------------------
    // 2) Resolve face cards (DFC split or simple rename)
    // --------------------------------------------------
    // List of (db.Card, faceName, faceIndex) triples.
    final faceCards = <(db.Card, String, int)>[];

    if (actualCardName != null) {
      final faceNames = _splitFaceNames(actualCardName);

      if (faceNames.length > 1) {
        // If this card's name already matches one of the faces, it was
        // previously split — skip re-splitting to avoid reverting the name.
        final cardNorm = normalizeCardName(card.name);
        final existingIndex = faceNames.indexWhere(
          (f) => normalizeCardName(f) == cardNorm,
        );

        if (existingIndex >= 0) {
          faceCards.add((card, card.name, existingIndex));
        } else {
          yield _CardRunEvent(
            message: 'DFC detected, splitting into: ${faceNames.join(' / ')}',
          );

          // Rename the original card to face 0.
          await database.cardsDao.renameCard(
            cardId: card.id,
            newName: faceNames[0],
            normalizedName: normalizeCardName(faceNames[0]),
          );
          faceCards.add((card, faceNames[0], 0));

          // Create a DB card for each remaining face (insertOrIgnore).
          for (int i = 1; i < faceNames.length; i++) {
            final faceName = faceNames[i];
            await database.cardsDao.insertCardsBulk(
              projectId,
              [(faceName, normalizeCardName(faceName))],
            );
            final faceCard = await (database.select(database.cards)
                  ..where(
                    (c) =>
                        c.projectId.equals(projectId) &
                        c.normalizedName.equals(normalizeCardName(faceName)),
                  ))
                .getSingleOrNull();
            if (faceCard != null) faceCards.add((faceCard, faceName, i));
          }
        }
      } else {
        if (actualCardName != card.name) {
          await database.cardsDao.renameCard(
            cardId: card.id,
            newName: actualCardName,
            normalizedName: normalizeCardName(actualCardName),
          );
          yield _CardRunEvent(message: 'Renamed card to: $actualCardName');
        }
        faceCards.add((card, actualCardName, 0));
      }
    } else {
      faceCards.add((card, card.name, 0));
    }

    // Insert per-face flavor texts now that we know the face card IDs.
    for (final (fSet, fCollector, fLang, faceFlavors, hasLoc) in flavorEntries) {
      for (final (faceCard, _, faceIndex) in faceCards) {
        final flavor =
            faceIndex < faceFlavors.length ? faceFlavors[faceIndex] : null;
        if (flavor == null || flavor.isEmpty) continue;
        await database.flavorTextDao.upsertFlavorOptions([
          db.FlavorTextOptionsCompanion.insert(
            cardId: faceCard.id,
            sourceProviderId: providerId,
            flavor: flavor,
            printingSet: Value(fSet),
            printingCollectorNumber: Value(fCollector),
            lang: Value(fLang),
            hasLocalization: Value(hasLoc),
          ),
        ]);
      }
    }

    // Persist the Scryfall layout and card type on every face card.
    if (scryfallLayout != null && scryfallLayout.isNotEmpty) {
      for (final (fc, _, _) in faceCards) {
        await database.cardsDao.setLayout(fc.id, scryfallLayout);
        if (scryfallCardType != null) {
          await database.cardsDao.setCardType(fc.id, scryfallCardType);
        }
      }
    }

    // --------------------------------------------------
    // 3) MagicVille download for each face card
    // --------------------------------------------------
    for (final (faceCard, faceName, _) in faceCards) {
      if (faceCards.length > 1) {
        yield _CardRunEvent(message: 'Downloading artworks for face: $faceName');
      }
      yield* _downloadMagicVilleArtworks(
        projectId: projectId,
        card: faceCard,
        faceName: faceName,
        providerId: providerId,
        printings: printings,
        seedFromNameOnly: seedFromNameOnly,
        isToken: isToken,
      );

      // Auto-select the single artwork if none was chosen yet; mark up to date.
      final fresh = await (database.select(database.cards)
            ..where((t) => t.id.equals(faceCard.id)))
          .getSingleOrNull();
      final arts = await database.artworksDao
          .getNonDiscardedArtworksForCard(faceCard.id);
      if (fresh != null && fresh.preferredArtworkId == null && arts.length == 1) {
        await database.cardsDao.setPreferredArtwork(faceCard.id, arts.first.id);
      }
      if (arts.isNotEmpty) {
        await database.cardsDao.setUpToDate(faceCard.id, true);
      }
    }

    // --------------------------------------------------
    // 4) Discover and import related tokens
    // --------------------------------------------------
    if (importTokens) {
      final allParts = named['all_parts'] as List<dynamic>?;
      if (allParts != null) {
        // `all_parts` often lists the same token once per source-card printing,
        // so deduplicate by normalized name — process each token type once.
        final processedTokenNames = <String>{};
        for (final part in allParts) {
          if (part['object'] != 'related_card' ||
              part['component'] != 'token') {
            continue;
          }
          final tokenName = (part['name'] as String?)?.trim();
          final tokenScryfallId = part['id'] as String?;
          if (tokenName == null || tokenScryfallId == null) continue;
          if (!processedTokenNames.add(normalizeCardName(tokenName))) continue;

          final tokenCard = await _insertOrGetTokenCard(
            projectId, tokenName, tokenScryfallId,
          );
          if (tokenCard == null) continue;

          // Skip tokens that already have artworks (re-run dedup).
          final existingArts = await database.artworksDao
              .getNonDiscardedArtworksForCard(tokenCard.id);
          if (existingArts.isNotEmpty) {
            yield _CardRunEvent(
              message: 'Token $tokenName: artworks already downloaded, skipping.',
            );
            continue;
          }

          yield _CardRunEvent(message: 'Token found: $tokenName — fetching…');
          try {
            yield* _runForCard(
              projectId: projectId,
              card: tokenCard,
              providerId: providerId,
              overrideScryfallId: tokenScryfallId,
              seedFromNameOnly: false,
              importTokens: false,
            );
          } catch (e) {
            yield _CardRunEvent(message: 'Token $tokenName failed: $e');
          }
        }
      }
    }
  }

  /// For each card name in [names], fetch from Scryfall and insert any tokens
  /// referenced in [all_parts] into [projectId]. The source cards themselves
  /// are NOT inserted. Returns the total number of token rows upserted.
  Future<int> importTokensFromCardNames(
    int projectId,
    List<String> names,
  ) async {
    final seenTokenIds = <String>{};
    int count = 0;

    for (final name in names) {
      final Map<String, dynamic> card;
      try {
        card = await scryfall.namedFuzzy(name);
      } catch (_) {
        continue;
      }
      final allParts = card['all_parts'] as List<dynamic>?;
      if (allParts == null) continue;

      for (final part in allParts) {
        if (part['object'] != 'related_card' ||
            part['component'] != 'token') {
          continue;
        }
        final tokenName = (part['name'] as String?)?.trim();
        final tokenId = part['id'] as String?;
        if (tokenName == null || tokenId == null) continue;
        if (!seenTokenIds.add(tokenId)) continue;

        // Derive layout from type_line ("Emblem …" → emblem, else token).
        final typeLine = (part['type_line'] as String?)?.trim() ?? '';
        final layout = typeLine.startsWith('Emblem') ? 'emblem' : 'token';
        final tokenCardType = _extractCardType(typeLine);

        final result = await _insertOrGetTokenCard(projectId, tokenName, tokenId);
        if (result == null) continue;
        await database.cardsDao.setLayout(result.id, layout);
        if (tokenCardType != null) {
          await database.cardsDao.setCardType(result.id, tokenCardType);
        }
        count++;
      }
    }

    return count;
  }

  Stream<DownloadProgress> runForSingleCard({
    required int projectId,
    required int cardId,
    DownloadRunLog? log,
  }) async* {
    final providerId = SourceProviderId.scryfallMagicville.dbValue;

    final card = await (database.select(
      database.cards,
    )..where((t) => t.id.equals(cardId))).getSingleOrNull();

    if (card == null) {
      yield const DownloadProgress(
        totalCards: 1,
        processedCards: 1,
        artworksDiscovered: 0,
        artworksDownloaded: 0,
        message: 'Card not found.',
      );
      return;
    }

    int discovered = 0;
    int downloaded = 0;

    yield DownloadProgress(
      totalCards: 1,
      processedCards: 0,
      artworksDiscovered: 0,
      artworksDownloaded: 0,
      currentCardName: card.name,
      message: 'Refreshing…',
    );

    await for (final ev in _runForCard(
      projectId: projectId,
      card: card,
      providerId: providerId,
    )) {
      discovered += ev.discoveredDelta;
      downloaded += ev.downloadedDelta;

      if (ev.message != null) {
        log?.add('${card.name}: ${ev.message}');
      }

      yield DownloadProgress(
        totalCards: 1,
        processedCards: 0,
        artworksDiscovered: discovered,
        artworksDownloaded: downloaded,
        currentCardName: card.name,
        message: ev.message,
      );
    }

    yield DownloadProgress(
      totalCards: 1,
      processedCards: 1,
      artworksDiscovered: discovered,
      artworksDownloaded: downloaded,
      currentCardName: card.name,
      message: 'Refresh complete.',
    );
  }

  Stream<DownloadProgress> runForSingleCardNameOnly({
    required int projectId,
    required int cardId,
    DownloadRunLog? log,
  }) async* {
    final providerId = SourceProviderId.scryfallMagicville.dbValue;

    final card = await (database.select(
      database.cards,
    )..where((t) => t.id.equals(cardId))).getSingleOrNull();

    if (card == null) {
      yield const DownloadProgress(
        totalCards: 1,
        processedCards: 1,
        artworksDiscovered: 0,
        artworksDownloaded: 0,
        message: 'Card not found.',
      );
      return;
    }

    int discovered = 0;
    int downloaded = 0;

    yield DownloadProgress(
      totalCards: 1,
      processedCards: 0,
      artworksDiscovered: 0,
      artworksDownloaded: 0,
      currentCardName: card.name,
      message: 'Refreshing (name only)…',
    );

    await for (final ev in _runForCard(
      projectId: projectId,
      card: card,
      providerId: providerId,
      seedFromNameOnly: true,
    )) {
      discovered += ev.discoveredDelta;
      downloaded += ev.downloadedDelta;

      if (ev.message != null) log?.add('${card.name}: ${ev.message}');

      yield DownloadProgress(
        totalCards: 1,
        processedCards: 0,
        artworksDiscovered: discovered,
        artworksDownloaded: downloaded,
        currentCardName: card.name,
        message: ev.message,
      );
    }

    yield DownloadProgress(
      totalCards: 1,
      processedCards: 1,
      artworksDiscovered: discovered,
      artworksDownloaded: downloaded,
      currentCardName: card.name,
      message: 'Refresh complete.',
    );
  }

  Stream<DownloadProgress> runForProject(
    int projectId, {
    DownloadRunLog? log,
    bool runFromNameOnly = false,
    bool importTokens = false,
  }) async* {
    log?.add('Starting project download (all cards)');
    final providerId = SourceProviderId.scryfallMagicville.dbValue;

    final cards = await (database.select(
      database.cards,
    )..where((t) => t.projectId.equals(projectId))).get();

    int processed = 0;
    int discovered = 0;
    int downloaded = 0;

    yield DownloadProgress(
      totalCards: cards.length,
      processedCards: 0,
      artworksDiscovered: 0,
      artworksDownloaded: 0,
      message: 'Starting…',
    );

    for (final card in cards) {
      yield DownloadProgress(
        totalCards: cards.length,
        processedCards: processed,
        artworksDiscovered: discovered,
        artworksDownloaded: downloaded,
        currentCardName: card.name,
        message: 'Starting card…',
      );

      await for (final ev in _runForCard(
        projectId: projectId,
        card: card,
        providerId: providerId,
        seedFromNameOnly: runFromNameOnly,
        importTokens: importTokens,
      )) {
        discovered += ev.discoveredDelta;
        downloaded += ev.downloadedDelta;

        if (ev.message != null) {
          log?.add('${card.name}: ${ev.message}');
        }

        yield DownloadProgress(
          totalCards: cards.length,
          processedCards: processed,
          artworksDiscovered: discovered,
          artworksDownloaded: downloaded,
          currentCardName: card.name,
          message: ev.message,
        );
      }

      processed++;
      yield DownloadProgress(
        totalCards: cards.length,
        processedCards: processed,
        artworksDiscovered: discovered,
        artworksDownloaded: downloaded,
        currentCardName: card.name,
        message: 'Card done.',
      );
    }

    yield DownloadProgress(
      totalCards: cards.length,
      processedCards: processed,
      artworksDiscovered: discovered,
      artworksDownloaded: downloaded,
      message: 'All done.',
    );
  }

  Stream<DownloadProgress> runForProjectMissingOnly(
    int projectId, {
    DownloadRunLog? log,
    bool runFromNameOnly = false,
    bool importTokens = false,
  }) async* {
    log?.add('Starting project download (missing cards)');
    final providerId = SourceProviderId.scryfallMagicville.dbValue;

    final cards = await database.cardsDao.getCardsMissingArtworks(projectId);

    int processed = 0;
    int discovered = 0;
    int downloaded = 0;

    yield DownloadProgress(
      totalCards: cards.length,
      processedCards: 0,
      artworksDiscovered: 0,
      artworksDownloaded: 0,
      message: 'Starting…',
    );

    for (final card in cards) {
      await for (final ev in _runForCard(
        projectId: projectId,
        card: card,
        providerId: providerId,
        seedFromNameOnly: runFromNameOnly,
        importTokens: importTokens,
      )) {
        discovered += ev.discoveredDelta;
        downloaded += ev.downloadedDelta;

        if (ev.message != null) {
          log?.add('${card.name}: ${ev.message}');
        }

        yield DownloadProgress(
          totalCards: cards.length,
          processedCards: processed,
          artworksDiscovered: discovered,
          artworksDownloaded: downloaded,
          currentCardName: card.name,
          message: ev.message,
        );
      }

      processed++;
      yield DownloadProgress(
        totalCards: cards.length,
        processedCards: processed,
        artworksDiscovered: discovered,
        artworksDownloaded: downloaded,
        currentCardName: card.name,
        message: 'Card done.',
      );
    }

    yield DownloadProgress(
      totalCards: cards.length,
      processedCards: processed,
      artworksDiscovered: discovered,
      artworksDownloaded: downloaded,
      message: 'All done.',
    );
  }

  Stream<DownloadProgress> runForProjectPendingOnly(
    int projectId, {
    DownloadRunLog? log,
    bool runFromNameOnly = false,
    bool importTokens = false,
  }) async* {
    log?.add('Starting project download (pending cards only)');
    final providerId = SourceProviderId.scryfallMagicville.dbValue;

    final cards = await database.cardsDao.getCardsPending(projectId);

    int processed = 0;
    int discovered = 0;
    int downloaded = 0;

    yield DownloadProgress(
      totalCards: cards.length,
      processedCards: 0,
      artworksDiscovered: 0,
      artworksDownloaded: 0,
      message: 'Starting…',
    );

    for (final card in cards) {
      await for (final ev in _runForCard(
        projectId: projectId,
        card: card,
        providerId: providerId,
        seedFromNameOnly: runFromNameOnly,
        importTokens: importTokens,
      )) {
        discovered += ev.discoveredDelta;
        downloaded += ev.downloadedDelta;

        if (ev.message != null) {
          log?.add('${card.name}: ${ev.message}');
        }

        yield DownloadProgress(
          totalCards: cards.length,
          processedCards: processed,
          artworksDiscovered: discovered,
          artworksDownloaded: downloaded,
          currentCardName: card.name,
          message: ev.message,
        );
      }

      processed++;
      yield DownloadProgress(
        totalCards: cards.length,
        processedCards: processed,
        artworksDiscovered: discovered,
        artworksDownloaded: downloaded,
        currentCardName: card.name,
        message: 'Card done.',
      );
    }

    yield DownloadProgress(
      totalCards: cards.length,
      processedCards: processed,
      artworksDiscovered: discovered,
      artworksDownloaded: downloaded,
      message: 'All done.',
    );
  }

  /// Extracts the canonical card type from a Scryfall type line.
  /// "Legendary Artifact Creature — Golem" → "Artifact Creature"
  /// "Basic Land" → "Land"
  String? _extractCardType(String? typeLine) {
    if (typeLine == null || typeLine.isEmpty) return null;
    const mainTypes = {
      'Artifact', 'Battle', 'Conspiracy', 'Creature', 'Dungeon',
      'Enchantment', 'Instant', 'Land', 'Phenomenon', 'Plane',
      'Planeswalker', 'Scheme', 'Sorcery', 'Tribal', 'Vanguard',
    };
    final dashIdx = typeLine.indexOf(' — ');
    final beforeDash =
        (dashIdx >= 0 ? typeLine.substring(0, dashIdx) : typeLine).trim();
    final types =
        beforeDash.split(' ').where((w) => mainTypes.contains(w)).toList();
    return types.isEmpty ? null : types.join(' ');
  }
}
