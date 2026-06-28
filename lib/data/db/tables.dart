import 'package:drift/drift.dart';

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get frame => text().nullable()();
}

class ProjectSources extends Table {
  IntColumn get projectId => integer()();
  TextColumn get sourceProviderId => text()();

  @override
  Set<Column> get primaryKey => {projectId, sourceProviderId};
}

class Cards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer()();

  TextColumn get name => text()();
  TextColumn get normalizedName => text()();

  IntColumn get preferredArtworkId => integer().nullable()();
  IntColumn get selectedFlavorTextId => integer().nullable()();
  TextColumn get customFlavorText => text().nullable()();
  BoolColumn get noFlavorText => boolean().withDefault(const Constant(false))();
  TextColumn get selectedSetCode => text().nullable().named('selected_extension_set')();
  TextColumn get selectedSetLang => text().nullable().named('selected_extension_lang')();
  BoolColumn get selectedSetIsVoid =>
      boolean().withDefault(const Constant(false)).named('selected_extension_is_void')();
  TextColumn get layout => text().nullable()();
  TextColumn get cardType => text().nullable()();
  TextColumn get frame => text().nullable()();
  TextColumn get scryfallId => text().nullable()();
  BoolColumn get isUpToDate => boolean().nullable()();
  // Collector number of the selected printing (set by Fetch Data / version selection).
  TextColumn get selectedCollectorNumber => text().nullable()();
  // For DFC cards: points to the card row representing the other face.
  IntColumn get dfcSiblingId => integer().nullable()();
}

class CardDiscoveredSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer()();
  TextColumn get setCode => text()();

  @override
  List<String> get customConstraints => ['UNIQUE(card_id, set_code)'];
}

class CardDiscoveredPrintings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer()();
  TextColumn get setCode => text()();
  TextColumn get lang => text()();
  TextColumn get setName => text()();
  TextColumn get releasedAt => text()();
  // Comma-separated artist names found in this set/lang (may be >1 for alternate art).
  TextColumn get artists => text().nullable()();
  // FK to card_print_data.id for the functional reading of this printing.
  IntColumn get printDataId => integer().nullable()();
  // Representative collector number and rarity for this set/lang combination.
  TextColumn get collectorNumber => text().nullable()();
  TextColumn get rarity => text().nullable()();

  @override
  List<String> get customConstraints => ['UNIQUE(card_id, set_code, lang)'];
}

class Artworks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer()();

  TextColumn get sourceProviderId => text()();
  TextColumn get remoteId => text().nullable()();

  TextColumn get printingSet => text().nullable()();
  TextColumn get printingCollectorNumber => text().nullable()();
  TextColumn get magicVilleRef => text().nullable()();

  TextColumn get artist => text()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();

  TextColumn get sourceUrl => text()();
  TextColumn get localPath => text()();

  DateTimeColumn get downloadedAt => dateTime()();

  BoolColumn get isDiscarded => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
    'UNIQUE(card_id, source_provider_id, remote_id)',
  ];
}

/// Deduplicated functional readings of a card (one row per unique content per card).
/// Uniqueness key: (card_id, content_hash) where content_hash = SHA-256 of
/// all functional fields. artist / set / collector_number / rarity are excluded
/// from the hash — two printings that read identically share one row here.
@DataClassName('PrintData')
class CardPrintData extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer()();
  TextColumn get contentHash => text()();
  TextColumn get lang => text()();
  TextColumn get name => text()();
  TextColumn get flavorName => text().nullable()();
  TextColumn get manaCost => text().nullable()();
  TextColumn get typeLine => text().nullable()();
  TextColumn get oracleText => text().nullable()();
  TextColumn get flavorText => text().nullable()();
  TextColumn get power => text().nullable()();
  TextColumn get toughness => text().nullable()();
  TextColumn get loyalty => text().nullable()();
  TextColumn get colors => text().nullable()();        // JSON array e.g. '["W","U"]'
  TextColumn get colorIdentity => text().nullable()(); // JSON array
  TextColumn get keywords => text().nullable()();      // JSON array
  TextColumn get layout => text().nullable()();

  @override
  List<String> get customConstraints => ['UNIQUE(card_id, content_hash)'];
}

/// Mutable per-card working copy of the selected print data.
/// One row per card — auto-filled when a version is chosen and editable by the user.
@DataClassName('UsedPrintData')
class CardUsedPrintData extends Table {
  IntColumn get cardId => integer()();
  TextColumn get lang => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get flavorName => text().nullable()();
  TextColumn get manaCost => text().nullable()();
  TextColumn get typeLine => text().nullable()();
  TextColumn get oracleText => text().nullable()();
  TextColumn get flavorText => text().nullable()();
  TextColumn get power => text().nullable()();
  TextColumn get toughness => text().nullable()();
  TextColumn get loyalty => text().nullable()();
  TextColumn get colors => text().nullable()();
  TextColumn get colorIdentity => text().nullable()();
  TextColumn get keywords => text().nullable()();
  TextColumn get layout => text().nullable()();
  TextColumn get setCode => text().nullable()();
  TextColumn get setName => text().nullable()();
  TextColumn get collectorNumber => text().nullable()();
  TextColumn get rarity => text().nullable()();
  TextColumn get artist => text().nullable()();

  @override
  Set<Column> get primaryKey => {cardId};
}

class FlavorTextOptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer()();
  TextColumn get sourceProviderId => text()();

  // IMPORTANT: avoid getter name "text"
  TextColumn get flavor => text()();

  TextColumn get printingSet => text().nullable()();
  TextColumn get printingCollectorNumber => text().nullable()();
  TextColumn get lang => text().nullable()();
  // null = old data; false = Scryfall has no localized text for this specific print.
  BoolColumn get hasLocalization => boolean().nullable()();

  @override
  List<String> get customConstraints => [
    'UNIQUE(card_id, printing_set, lang, flavor)',
  ];
}
