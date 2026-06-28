import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [Projects, ProjectSources])
class ProjectsDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectsDaoMixin {
  ProjectsDao(super.db);

  Stream<List<Project>> watchProjects() => select(projects).watch();

  Future<int> insertProject(String name, DateTime createdAt) {
    return into(
      projects,
    ).insert(ProjectsCompanion.insert(name: name, createdAt: createdAt));
  }

  Future<void> insertProjectSource(int projectId, String providerId) {
    return into(projectSources).insert(
      ProjectSourcesCompanion.insert(
        projectId: projectId,
        sourceProviderId: providerId,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> deleteProjectById(int projectId) async {
    await (delete(
      projectSources,
    )..where((t) => t.projectId.equals(projectId))).go();
    await (delete(projects)..where((t) => t.id.equals(projectId))).go();
  }

  Future<void> setFrame(int projectId, String? frame) async {
    await customUpdate(
      'UPDATE projects SET frame = ? WHERE id = ?',
      variables: [Variable(frame), Variable(projectId)],
      updates: {projects},
    );
  }

  Future<Map<String, String>> getLayoutFrames(int projectId) async {
    final rows = await customSelect(
      'SELECT layout, frame FROM project_layout_frames WHERE project_id = ?',
      variables: [Variable(projectId)],
    ).get();
    return {
      for (final r in rows)
        r.data['layout'] as String: r.data['frame'] as String,
    };
  }

  Future<void> setLayoutFrame(
    int projectId,
    String layout,
    String frame,
  ) async {
    await customStatement(
      'INSERT INTO project_layout_frames (project_id, layout, frame)'
      ' VALUES (?, ?, ?)'
      ' ON CONFLICT(project_id, layout) DO UPDATE SET frame = excluded.frame',
      [projectId, layout, frame],
    );
  }

  Future<Map<String, String>> getTypeFrames(int projectId) async {
    final rows = await customSelect(
      'SELECT type, frame FROM project_type_frames WHERE project_id = ?',
      variables: [Variable(projectId)],
    ).get();
    return {for (final r in rows) r.data['type'] as String: r.data['frame'] as String};
  }

  Future<void> setTypeFrame(int projectId, String type, String frame) async {
    await customStatement(
      'INSERT INTO project_type_frames (project_id, type, frame)'
      ' VALUES (?, ?, ?)'
      ' ON CONFLICT(project_id, type) DO UPDATE SET frame = excluded.frame',
      [projectId, type, frame],
    );
  }
}

enum CardFilter { all, checked, partial, unchecked, upToDate, pending }

@DriftAccessor(tables: [Cards])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(super.db);

  Future<void> insertCardsBulk(
    int projectId,
    List<(String name, String normalized)> items,
  ) async {
    await batch((b) {
      b.insertAll(
        cards,
        items
            .map(
              (e) => CardsCompanion.insert(
                projectId: projectId,
                name: e.$1,
                normalizedName: e.$2,
              ),
            )
            .toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<void> renameCard({
    required int cardId,
    required String newName,
    required String normalizedName,
  }) async {
    await (update(cards)..where((t) => t.id.equals(cardId))).write(
      CardsCompanion(
        name: Value(newName),
        normalizedName: Value(normalizedName),
      ),
    );
  }

  Future<void> setSiblingId({
    required int cardId,
    required int siblingId,
  }) {
    return (update(cards)..where((t) => t.id.equals(cardId)))
        .write(CardsCompanion(dfcSiblingId: Value(siblingId)));
  }

  Stream<List<Card>> watchCards(int projectId, {required CardFilter filter}) {
    final q = select(cards)..where((t) => t.projectId.equals(projectId));

    switch (filter) {
      case CardFilter.all:
        break;
      case CardFilter.checked:
        q.where(
          (t) =>
              t.preferredArtworkId.isNotNull() &
              (t.selectedSetCode.isNotNull() | t.selectedSetIsVoid.equals(true)),
        );
        break;
      case CardFilter.partial:
        q.where((t) {
          final hasArtwork = t.preferredArtworkId.isNotNull();
          final hasSet =
              t.selectedSetCode.isNotNull() | t.selectedSetIsVoid.equals(true);
          return (hasArtwork & hasSet.not()) | (hasArtwork.not() & hasSet);
        });
        break;
      case CardFilter.unchecked:
        q.where(
          (t) =>
              t.preferredArtworkId.isNull() &
              t.selectedSetCode.isNull() &
              t.selectedSetIsVoid.equals(false),
        );
        break;
      case CardFilter.upToDate:
        q.where((t) => t.isUpToDate.equals(true));
        break;
      case CardFilter.pending:
        q.where((t) => t.isUpToDate.isNull() | t.isUpToDate.equals(false));
        break;
    }

    q.orderBy([(t) => OrderingTerm(expression: t.name)]);
    return q.watch();
  }

  Future<int> applyFrameToLayout({
    required int projectId,
    required String layout,
    required String frame,
    required bool overwriteAll,
  }) async {
    final where = overwriteAll
        ? 'project_id = ? AND layout = ?'
        : 'project_id = ? AND layout = ? AND frame IS NULL';
    return customUpdate(
      'UPDATE cards SET frame = ? WHERE $where',
      variables: [Variable(frame), Variable(projectId), Variable(layout)],
      updates: {cards},
    );
  }

  /// Applies a frame only to cards matching ALL of the given layouts AND types
  /// (intersection). Used when the user selects both layout and type chips.
  Future<int> applyFrameToLayoutAndType({
    required int projectId,
    required List<String> layouts,
    required List<String> types,
    required String frame,
    required bool overwriteAll,
  }) async {
    final lp = List.filled(layouts.length, '?').join(', ');
    final tp = List.filled(types.length, '?').join(', ');
    final where = overwriteAll
        ? 'project_id = ? AND layout IN ($lp) AND card_type IN ($tp)'
        : 'project_id = ? AND layout IN ($lp) AND card_type IN ($tp) AND frame IS NULL';
    return customUpdate(
      'UPDATE cards SET frame = ? WHERE $where',
      variables: [
        Variable(frame),
        Variable(projectId),
        ...layouts.map(Variable.new),
        ...types.map(Variable.new),
      ],
      updates: {cards},
    );
  }

  Stream<List<String>> watchDistinctLayoutsForProject(int projectId) {
    return customSelect(
      'SELECT DISTINCT layout FROM cards'
      ' WHERE project_id = ? AND layout IS NOT NULL'
      ' ORDER BY layout',
      variables: [Variable(projectId)],
      readsFrom: {cards},
    ).watch().map(
      (rows) => rows.map((r) => r.data['layout'] as String).toList(),
    );
  }

  Stream<Map<int, String?>> watchLayoutMapForProject(int projectId) {
    return customSelect(
      'SELECT id, layout FROM cards WHERE project_id = ?',
      variables: [Variable(projectId)],
      readsFrom: {cards},
    ).watch().map(
      (rows) => {
        for (final r in rows)
          r.data['id'] as int: r.data['layout'] as String?,
      },
    );
  }

  Stream<int> watchTotalCount(int projectId) {
    final q = selectOnly(cards)
      ..addColumns([cards.id.count()])
      ..where(cards.projectId.equals(projectId));
    return q.watchSingle().map((row) => row.read(cards.id.count()) ?? 0);
  }

  Stream<int> watchCheckedCount(int projectId) {
    final q = selectOnly(cards)
      ..addColumns([cards.id.count()])
      ..where(
        Expression.and([
          cards.projectId.equals(projectId),
          cards.preferredArtworkId.isNotNull(),
          cards.selectedSetCode.isNotNull() |
              cards.selectedSetIsVoid.equals(true),
        ]),
      );
    return q.watchSingle().map((row) => row.read(cards.id.count()) ?? 0);
  }

  Future<void> setPreferredArtwork(int cardId, int? artworkId) async {
    await (update(cards)..where((t) => t.id.equals(cardId))).write(
      CardsCompanion(preferredArtworkId: Value(artworkId)),
    );
  }

  Future<void> setCardType(int cardId, String? cardType) async {
    await customStatement(
      'UPDATE cards SET card_type = ? WHERE id = ?',
      [cardType, cardId],
    );
  }

  Stream<List<String>> watchDistinctTypesForProject(int projectId) {
    return customSelect(
      'SELECT DISTINCT card_type FROM cards'
      ' WHERE project_id = ? AND card_type IS NOT NULL'
      ' ORDER BY card_type',
      variables: [Variable(projectId)],
      readsFrom: {cards},
    ).watch().map(
      (rows) => rows.map((r) => r.data['card_type'] as String).toList(),
    );
  }

  Future<int> applyFrameToType({
    required int projectId,
    required String cardType,
    required String frame,
    required bool overwriteAll,
  }) async {
    final where = overwriteAll
        ? 'project_id = ? AND card_type = ?'
        : 'project_id = ? AND card_type = ? AND frame IS NULL';
    return customUpdate(
      'UPDATE cards SET frame = ? WHERE $where',
      variables: [Variable(frame), Variable(projectId), Variable(cardType)],
      updates: {cards},
    );
  }

  Future<void> setLayout(int cardId, String? layout) async {
    await customUpdate(
      'UPDATE cards SET layout = ? WHERE id = ?',
      variables: [Variable(layout), Variable(cardId)],
      updates: {cards},
    );
  }

  Future<void> setFrame(int cardId, String? frame) async {
    await customUpdate(
      'UPDATE cards SET frame = ? WHERE id = ?',
      variables: [Variable(frame), Variable(cardId)],
      updates: {cards},
    );
  }

  Future<void> setSelectedFlavorText(int cardId, int? flavorId) async {
    await (update(cards)..where((t) => t.id.equals(cardId))).write(
      CardsCompanion(selectedFlavorTextId: Value(flavorId)),
    );
  }

  Future<void> setCustomFlavorText(int cardId, String? custom) async {
    await (update(cards)..where((t) => t.id.equals(cardId))).write(
      CardsCompanion(customFlavorText: Value(custom)),
    );
  }

  Future<void> setUpToDate(int cardId, bool value) async {
    await customUpdate(
      'UPDATE cards SET is_up_to_date = ? WHERE id = ?',
      variables: [Variable(value ? 1 : 0), Variable(cardId)],
      updates: {cards},
    );
  }

  Future<List<Card>> getCardsPending(int projectId) {
    return (select(cards)
          ..where(
            (t) =>
                t.projectId.equals(projectId) &
                (t.isUpToDate.isNull() | t.isUpToDate.equals(false)),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Future<List<Card>> getCardsMissingArtworks(int projectId) async {
    final rows = await customSelect(
      '''
    SELECT c.*
    FROM cards c
    LEFT JOIN artworks a
      ON a.card_id = c.id
     AND a.is_discarded = 0
    WHERE c.project_id = ?
    GROUP BY c.id
    HAVING COUNT(a.id) = 0
    ORDER BY c.name COLLATE NOCASE
    ''',
      variables: [Variable.withInt(projectId)],
    ).get();

    return rows.map((row) => cards.map(row.data)).toList();
  }

  Future<void> setNoFlavorText(int cardId, bool value) async {
    await (update(cards)..where((t) => t.id.equals(cardId))).write(
      CardsCompanion(noFlavorText: Value(value)),
    );
  }

  Future<void> setSelectedSet({
    required int cardId,
    required String setCode,
    required String lang,
    required bool isVoid,
    int? flavorTextId,
    String? customFlavorText,
    String? collectorNumber,
  }) async {
    await (update(cards)..where((t) => t.id.equals(cardId))).write(
      CardsCompanion(
        noFlavorText: const Value(false),
        selectedSetCode: Value(setCode),
        selectedSetLang: Value(lang),
        selectedSetIsVoid: Value(isVoid),
        selectedFlavorTextId: Value(flavorTextId),
        customFlavorText: Value(customFlavorText),
        selectedCollectorNumber: Value(collectorNumber),
      ),
    );
  }

  Future<void> clearSelectedSet(int cardId) async {
    await (update(cards)..where((t) => t.id.equals(cardId))).write(
      const CardsCompanion(
        selectedSetCode: Value(null),
        selectedSetLang: Value(null),
        selectedSetIsVoid: Value(false),
        selectedFlavorTextId: Value(null),
      ),
    );
  }
}

@DriftAccessor(tables: [CardDiscoveredPrintings])
class CardDiscoveredPrintingsDao extends DatabaseAccessor<AppDatabase>
    with _$CardDiscoveredPrintingsDaoMixin {
  CardDiscoveredPrintingsDao(super.db);

  Future<void> replaceForCard(
    int cardId,
    List<CardDiscoveredPrintingsCompanion> items,
  ) async {
    await transaction(() async {
      await (delete(cardDiscoveredPrintings)
            ..where((t) => t.cardId.equals(cardId)))
          .go();
      if (items.isEmpty) return;
      await batch((b) {
        b.insertAll(
          cardDiscoveredPrintings,
          items,
          mode: InsertMode.insertOrIgnore,
        );
      });
    });
  }

  Stream<List<CardDiscoveredPrinting>> watchForCard(int cardId) {
    return (select(cardDiscoveredPrintings)
          ..where((t) => t.cardId.equals(cardId)))
        .watch();
  }
}

@DriftAccessor(tables: [CardDiscoveredSets])
class CardDiscoveredSetsDao extends DatabaseAccessor<AppDatabase>
    with _$CardDiscoveredSetsDaoMixin {
  CardDiscoveredSetsDao(super.db);

  Future<void> replaceSetsForCard(int cardId, Iterable<String> sets) async {
    await transaction(() async {
      await (delete(
        cardDiscoveredSets,
      )..where((_) => cardDiscoveredSets.cardId.equals(cardId))).go();

      final uniqueSets =
          sets
              .map((e) => e.trim().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      if (uniqueSets.isEmpty) return;

      await batch((b) {
        b.insertAll(
          cardDiscoveredSets,
          uniqueSets.map((setCode) {
            return CardDiscoveredSetsCompanion.insert(
              cardId: cardId,
              setCode: setCode,
            );
          }).toList(),
          mode: InsertMode.insertOrIgnore,
        );
      });
    });
  }

  Stream<List<CardDiscoveredSet>> watchSetsForCard(int cardId) {
    return (select(cardDiscoveredSets)
          ..where((t) => t.cardId.equals(cardId))
          ..orderBy([(t) => OrderingTerm(expression: t.setCode)]))
        .watch();
  }
}

@DriftAccessor(tables: [Artworks])
class ArtworksDao extends DatabaseAccessor<AppDatabase>
    with _$ArtworksDaoMixin {
  ArtworksDao(super.db);

  Future<bool> artworkExistsByRemoteId({
    required int cardId,
    required String providerId,
    required String remoteId,
  }) async {
    final q = select(artworks)
      ..where(
        (t) => Expression.and([
          t.cardId.equals(cardId),
          t.sourceProviderId.equals(providerId),
          t.remoteId.equals(remoteId),
        ]),
      );
    return (await q.getSingleOrNull()) != null;
  }

  Future<int> insertArtwork(ArtworksCompanion companion) {
    return into(artworks).insert(companion, mode: InsertMode.insertOrIgnore);
  }

  Stream<List<Artwork>> watchArtworksForCard(
    int cardId, {
    required bool includeDiscarded,
  }) {
    final q = select(artworks)..where((t) => t.cardId.equals(cardId));
    if (!includeDiscarded) {
      q.where((t) => t.isDiscarded.equals(false));
    }
    q.orderBy([
      (t) => OrderingTerm(expression: t.downloadedAt, mode: OrderingMode.desc),
    ]);
    return q.watch();
  }

  Future<List<Artwork>> getNonDiscardedArtworksForCard(int cardId) {
    return (select(artworks)
          ..where(
            (t) => t.cardId.equals(cardId) & t.isDiscarded.equals(false),
          ))
        .get();
  }

  Future<Artwork?> getById(int artworkId) {
    return (select(
      artworks,
    )..where((t) => t.id.equals(artworkId))).getSingleOrNull();
  }

  Future<void> markDiscarded(int artworkId, bool discarded) async {
    await (update(artworks)..where((t) => t.id.equals(artworkId))).write(
      ArtworksCompanion(isDiscarded: Value(discarded)),
    );
  }

  /// Step 10 helper:
  /// - if preferredArtworkId points to a non-discarded artwork, use it
  /// - else pick the most recently downloaded non-discarded artwork (or null)
  Future<Artwork?> getPreferredOrFirstArtworkForCard(
    int cardId,
    int? preferredArtworkId,
  ) async {
    if (preferredArtworkId != null) {
      final pref = await (select(
        artworks,
      )..where((t) => t.id.equals(preferredArtworkId))).getSingleOrNull();
      if (pref != null && pref.isDiscarded == false) return pref;
    }

    final q = select(artworks)
      ..where(
        (t) => Expression.and([
          t.cardId.equals(cardId),
          t.isDiscarded.equals(false),
        ]),
      )
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.downloadedAt, mode: OrderingMode.desc),
      ])
      ..limit(1);

    return q.getSingleOrNull();
  }
}

class FlavorTextBySetAndLanguage {
  final String setCode;
  final String language;
  final List<FlavorTextOption> items;

  FlavorTextBySetAndLanguage({
    required this.setCode,
    required this.language,
    required this.items,
  });
}

@DriftAccessor(tables: [FlavorTextOptions])
class FlavorTextDao extends DatabaseAccessor<AppDatabase>
    with _$FlavorTextDaoMixin {
  FlavorTextDao(super.db);

  Future<void> upsertFlavorOptions(
    List<FlavorTextOptionsCompanion> items,
  ) async {
    await batch((b) {
      b.insertAll(flavorTextOptions, items, mode: InsertMode.insertOrIgnore);
    });
  }

  Stream<List<FlavorTextOption>> watchFlavorOptionsForCard(int cardId) {
    final q = select(flavorTextOptions)
      ..where((t) => t.cardId.equals(cardId))
      ..orderBy([(t) => OrderingTerm(expression: t.flavor)]);
    return q.watch();
  }

  Future<FlavorTextOption?> getById(int id) {
    return (select(
      flavorTextOptions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<FlavorTextBySetAndLanguage>> watchGroupedFlavorOptionsForCard(
    int cardId,
  ) {
    return watchFlavorOptionsForCard(cardId).map((options) {
      final grouped = <String, Map<String, List<FlavorTextOption>>>{};

      for (final o in options) {
        final setCode = (o.printingSet ?? '').trim().toLowerCase();
        final lang = (o.lang ?? '').trim().toLowerCase();

        grouped.putIfAbsent(setCode, () => <String, List<FlavorTextOption>>{});
        grouped[setCode]!.putIfAbsent(lang, () => <FlavorTextOption>[]);
        grouped[setCode]![lang]!.add(o);
      }

      final result = <FlavorTextBySetAndLanguage>[];

      final orderedSets = grouped.keys.toList()..sort();
      for (final setCode in orderedSets) {
        final langs = grouped[setCode]!;
        final orderedLangs = langs.keys.toList()..sort();

        for (final lang in orderedLangs) {
          result.add(
            FlavorTextBySetAndLanguage(
              setCode: setCode,
              language: lang,
              items: langs[lang]!,
            ),
          );
        }
      }

      return result;
    });
  }
}

@DriftAccessor(tables: [CardPrintData, CardUsedPrintData])
class PrintDataDao extends DatabaseAccessor<AppDatabase>
    with _$PrintDataDaoMixin {
  PrintDataDao(super.db);

  /// SHA-256 hash of all functional card fields (excluding artist/set/collector/rarity).
  /// NULL fields are represented as empty string; separator is \x00 to avoid collisions.
  static String computeHash({
    required String lang,
    required String name,
    required String? flavorName,
    required String? manaCost,
    required String? typeLine,
    required String? oracleText,
    required String? flavorText,
    required String? power,
    required String? toughness,
    required String? loyalty,
    required String? colors,
    required String? colorIdentity,
    required String? keywords,
    required String? layout,
  }) {
    final content = [
      lang,
      name,
      flavorName ?? '',
      manaCost ?? '',
      typeLine ?? '',
      oracleText ?? '',
      flavorText ?? '',
      power ?? '',
      toughness ?? '',
      loyalty ?? '',
      colors ?? '',
      colorIdentity ?? '',
      keywords ?? '',
      layout ?? '',
    ].join('\x00');
    return sha256.convert(utf8.encode(content)).toString();
  }

  /// INSERT OR IGNORE the given entry, then return the ID of the matching row
  /// (whether newly inserted or already existing).
  Future<int> upsertGetId(CardPrintDataCompanion entry) async {
    await into(cardPrintData).insert(entry, mode: InsertMode.insertOrIgnore);
    final row = await (select(cardPrintData)
          ..where(
            (t) =>
                t.cardId.equals(entry.cardId.value) &
                t.contentHash.equals(entry.contentHash.value),
          ))
        .getSingleOrNull();
    return row!.id;
  }

  Future<List<PrintData>> getForCard(int cardId) {
    return (select(cardPrintData)..where((t) => t.cardId.equals(cardId))).get();
  }

  Stream<List<PrintData>> watchForCard(int cardId) {
    return (select(cardPrintData)..where((t) => t.cardId.equals(cardId)))
        .watch();
  }

  Future<UsedPrintData?> getUsed(int cardId) {
    return (select(cardUsedPrintData)
          ..where((t) => t.cardId.equals(cardId)))
        .getSingleOrNull();
  }

  Stream<UsedPrintData?> watchUsed(int cardId) {
    return (select(cardUsedPrintData)
          ..where((t) => t.cardId.equals(cardId)))
        .watchSingleOrNull();
  }

  Future<void> setUsed(CardUsedPrintDataCompanion entry) async {
    await into(cardUsedPrintData).insertOnConflictUpdate(entry);
  }

  Future<void> clearUsed(int cardId) async {
    await (delete(cardUsedPrintData)
          ..where((t) => t.cardId.equals(cardId)))
        .go();
  }

  /// Auto-fill the mutable copy from the print_data linked to the (card, set, lang)
  /// discovered printing. No-op if no matching print_data exists.
  Future<void> populateUsedFromPrinting({
    required int cardId,
    required String setCode,
    required String lang,
  }) async {
    final printingRows = await db.customSelect(
      'SELECT print_data_id, set_name, collector_number, rarity, artists'
      ' FROM card_discovered_printings'
      ' WHERE card_id = ? AND set_code = ? AND lang = ?',
      variables: [Variable(cardId), Variable(setCode), Variable(lang)],
    ).get();

    if (printingRows.isEmpty) return;
    final pr = printingRows.first.data;
    final printDataId = pr['print_data_id'] as int?;
    if (printDataId == null) return;

    final pdRows = await db.customSelect(
      'SELECT * FROM card_print_data WHERE id = ?',
      variables: [Variable(printDataId)],
    ).get();
    if (pdRows.isEmpty) return;
    final pd = pdRows.first.data;

    // Use first artist from the comma-separated list.
    final rawArtists = pr['artists'] as String?;
    final artist = rawArtists?.split(',').firstOrNull?.trim();

    await setUsed(
      CardUsedPrintDataCompanion(
        cardId: Value(cardId),
        lang: Value(pd['lang'] as String?),
        name: Value(pd['name'] as String?),
        flavorName: Value(pd['flavor_name'] as String?),
        manaCost: Value(pd['mana_cost'] as String?),
        typeLine: Value(pd['type_line'] as String?),
        oracleText: Value(pd['oracle_text'] as String?),
        flavorText: Value(pd['flavor_text'] as String?),
        power: Value(pd['power'] as String?),
        toughness: Value(pd['toughness'] as String?),
        loyalty: Value(pd['loyalty'] as String?),
        colors: Value(pd['colors'] as String?),
        colorIdentity: Value(pd['color_identity'] as String?),
        keywords: Value(pd['keywords'] as String?),
        layout: Value(pd['layout'] as String?),
        setCode: Value(setCode),
        setName: Value(pr['set_name'] as String?),
        collectorNumber: Value(pr['collector_number'] as String?),
        rarity: Value(pr['rarity'] as String?),
        artist: Value(artist),
      ),
    );
  }
}

class GlobalSettingsDao {
  final AppDatabase _db;
  GlobalSettingsDao(this._db);

  Future<String?> getAppSetting(String key) async {
    final rows = await _db
        .customSelect(
          'SELECT value FROM app_settings WHERE key = ?',
          variables: [Variable(key)],
        )
        .get();
    return rows.isEmpty ? null : rows.first.data['value'] as String?;
  }

  Future<void> setAppSetting(String key, String value) async {
    await _db.customStatement(
      'INSERT INTO app_settings (key, value) VALUES (?, ?)'
      ' ON CONFLICT(key) DO UPDATE SET value = excluded.value',
      [key, value],
    );
  }

  Future<List<String>> getPreferredLanguages() async {
    final raw = await getAppSetting('preferred_languages');
    if (raw == null || raw.isEmpty) return const ['en'];
    return (jsonDecode(raw) as List<dynamic>).cast<String>();
  }

  Future<void> setPreferredLanguages(List<String> langs) async {
    final withEn = langs.contains('en') ? langs : ['en', ...langs];
    await setAppSetting('preferred_languages', jsonEncode(withEn));
  }

  Future<int> getOrCreateBasicsProjectId() async {
    final raw = await getAppSetting('basics_project_id');
    if (raw != null) return int.parse(raw);

    final id = await _db.projectsDao.insertProject(
      'Global Basics',
      DateTime.now(),
    );
    await _db.projectsDao.insertProjectSource(id, 'scryfall_magicville');

    const basics = [
      'Plains',
      'Island',
      'Swamp',
      'Mountain',
      'Forest',
      'Wastes',
    ];
    await _db.cardsDao.insertCardsBulk(
      id,
      basics.map((n) => (n, n.toLowerCase())).toList(),
    );

    await setAppSetting('basics_project_id', id.toString());
    return id;
  }

  Future<int> getOrCreateGlobalFramesProjectId() async {
    final raw = await getAppSetting('global_frames_project_id');
    if (raw != null) return int.parse(raw);

    final id = await _db.projectsDao.insertProject(
      'Global Frames',
      DateTime.now(),
    );
    await setAppSetting('global_frames_project_id', id.toString());
    return id;
  }

  Future<void> applyGlobalFramesToProject(int projectId) async {
    final framesId = await getOrCreateGlobalFramesProjectId();
    await _db.customStatement(
      'INSERT OR IGNORE INTO project_layout_frames (project_id, layout, frame)'
      ' SELECT ?, layout, frame FROM project_layout_frames WHERE project_id = ?',
      [projectId, framesId],
    );
    await _db.customStatement(
      'INSERT OR IGNORE INTO project_type_frames (project_id, type, frame)'
      ' SELECT ?, type, frame FROM project_type_frames WHERE project_id = ?',
      [projectId, framesId],
    );
  }

  Future<void> copyBasicsToProject(
    int newProjectId,
    List<String> cardNames,
  ) async {
    final basicsId = await getOrCreateBasicsProjectId();

    for (final name in cardNames) {
      final normalized = name.trim().toLowerCase();

      final basicCardRows = await _db
          .customSelect(
            'SELECT * FROM cards'
            ' WHERE project_id = ? AND normalized_name = ? AND is_up_to_date = 1',
            variables: [Variable(basicsId), Variable(normalized)],
          )
          .get();
      if (basicCardRows.isEmpty) continue;
      final basicCard = basicCardRows.first.data;
      final basicCardId = basicCard['id'] as int;

      final newCardRows = await _db
          .customSelect(
            'SELECT id FROM cards WHERE project_id = ? AND normalized_name = ?',
            variables: [Variable(newProjectId), Variable(normalized)],
          )
          .get();
      if (newCardRows.isEmpty) continue;
      final newCardId = newCardRows.first.data['id'] as int;

      // Copy artworks
      await _db.customStatement(
        'INSERT OR IGNORE INTO artworks'
        ' (card_id, source_provider_id, remote_id, printing_set,'
        '  printing_collector_number, magic_ville_ref, artist, width, height,'
        '  source_url, local_path, downloaded_at, is_discarded)'
        ' SELECT ?, source_provider_id, remote_id, printing_set,'
        '  printing_collector_number, magic_ville_ref, artist, width, height,'
        '  source_url, local_path, downloaded_at, is_discarded'
        ' FROM artworks WHERE card_id = ? AND is_discarded = 0',
        [newCardId, basicCardId],
      );

      // Map preferred artwork id
      int? newPreferredArtworkId;
      final prefArtId = basicCard['preferred_artwork_id'] as int?;
      if (prefArtId != null) {
        final prefRows = await _db
            .customSelect(
              'SELECT remote_id, source_provider_id FROM artworks WHERE id = ?',
              variables: [Variable(prefArtId)],
            )
            .get();
        if (prefRows.isNotEmpty) {
          final remoteId = prefRows.first.data['remote_id'];
          final providerId =
              prefRows.first.data['source_provider_id'] as String;
          final matchRows = await _db
              .customSelect(
                'SELECT id FROM artworks'
                ' WHERE card_id = ? AND source_provider_id = ? AND remote_id IS ?',
                variables: [
                  Variable(newCardId),
                  Variable(providerId),
                  Variable(remoteId),
                ],
              )
              .get();
          if (matchRows.isNotEmpty) {
            newPreferredArtworkId = matchRows.first.data['id'] as int?;
          }
        }
      }

      // Copy flavor texts
      await _db.customStatement(
        'INSERT OR IGNORE INTO flavor_text_options'
        ' (card_id, source_provider_id, flavor, printing_set,'
        '  printing_collector_number, lang, has_localization)'
        ' SELECT ?, source_provider_id, flavor, printing_set,'
        '  printing_collector_number, lang, has_localization'
        ' FROM flavor_text_options WHERE card_id = ?',
        [newCardId, basicCardId],
      );

      // Map preferred flavor text id
      int? newPreferredFlavorId;
      final prefFlavId = basicCard['selected_flavor_text_id'] as int?;
      if (prefFlavId != null) {
        final prefFlavRows = await _db
            .customSelect(
              'SELECT printing_set, lang, flavor FROM flavor_text_options WHERE id = ?',
              variables: [Variable(prefFlavId)],
            )
            .get();
        if (prefFlavRows.isNotEmpty) {
          final pSet = prefFlavRows.first.data['printing_set'];
          final pLang = prefFlavRows.first.data['lang'];
          final pFlav = prefFlavRows.first.data['flavor'] as String;
          final matchFlavRows = await _db
              .customSelect(
                'SELECT id FROM flavor_text_options'
                ' WHERE card_id = ? AND printing_set IS ? AND lang IS ? AND flavor = ?',
                variables: [
                  Variable(newCardId),
                  Variable(pSet),
                  Variable(pLang),
                  Variable(pFlav),
                ],
              )
              .get();
          if (matchFlavRows.isNotEmpty) {
            newPreferredFlavorId = matchFlavRows.first.data['id'] as int?;
          }
        }
      }

      // Copy discovered sets + printings (print_data_id is omitted — will be
      // populated on next Fetch Data; card_used_print_data is copied separately).
      await _db.customStatement(
        'INSERT OR IGNORE INTO card_discovered_sets (card_id, set_code)'
        ' SELECT ?, set_code FROM card_discovered_sets WHERE card_id = ?',
        [newCardId, basicCardId],
      );
      await _db.customStatement(
        'INSERT OR IGNORE INTO card_discovered_printings'
        ' (card_id, set_code, lang, set_name, released_at, artists,'
        '  collector_number, rarity)'
        ' SELECT ?, set_code, lang, set_name, released_at, artists,'
        '  collector_number, rarity'
        ' FROM card_discovered_printings WHERE card_id = ?',
        [newCardId, basicCardId],
      );

      // Copy print data entries with the new card_id.
      await _db.customStatement(
        'INSERT OR IGNORE INTO card_print_data'
        ' (card_id, content_hash, lang, name, flavor_name, mana_cost, type_line,'
        '  oracle_text, flavor_text, power, toughness, loyalty, colors,'
        '  color_identity, keywords, layout)'
        ' SELECT ?, content_hash, lang, name, flavor_name, mana_cost, type_line,'
        '  oracle_text, flavor_text, power, toughness, loyalty, colors,'
        '  color_identity, keywords, layout'
        ' FROM card_print_data WHERE card_id = ?',
        [newCardId, basicCardId],
      );

      // Copy mutable print data working copy.
      await _db.customStatement(
        'INSERT OR IGNORE INTO card_used_print_data'
        ' (card_id, lang, name, flavor_name, mana_cost, type_line, oracle_text,'
        '  flavor_text, power, toughness, loyalty, colors, color_identity,'
        '  keywords, layout, set_code, set_name, collector_number, rarity, artist)'
        ' SELECT ?, lang, name, flavor_name, mana_cost, type_line, oracle_text,'
        '  flavor_text, power, toughness, loyalty, colors, color_identity,'
        '  keywords, layout, set_code, set_name, collector_number, rarity, artist'
        ' FROM card_used_print_data WHERE card_id = ?',
        [newCardId, basicCardId],
      );

      // Update the new card with all settings
      await _db.customStatement(
        'UPDATE cards SET'
        '  selected_extension_set = ?,'
        '  selected_extension_lang = ?,'
        '  selected_extension_is_void = ?,'
        '  frame = ?,'
        '  preferred_artwork_id = ?,'
        '  selected_flavor_text_id = ?,'
        '  is_up_to_date = 1'
        ' WHERE id = ?',
        [
          basicCard['selected_extension_set'],
          basicCard['selected_extension_lang'],
          basicCard['selected_extension_is_void'],
          basicCard['frame'],
          newPreferredArtworkId,
          newPreferredFlavorId,
          newCardId,
        ],
      );
    }
  }
}
