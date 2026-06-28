import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';
import 'daos.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Projects,
    ProjectSources,
    Cards,
    Artworks,
    FlavorTextOptions,
    CardDiscoveredSets,
    CardDiscoveredPrintings,
    CardPrintData,
    CardUsedPrintData,
  ],
  daos: [
    ProjectsDao,
    CardsDao,
    ArtworksDao,
    FlavorTextDao,
    CardDiscoveredSetsDao,
    CardDiscoveredPrintingsDao,
    PrintDataDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 18;

  Future<void> _createCustomTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS project_layout_frames (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        layout TEXT NOT NULL,
        frame TEXT NOT NULL,
        UNIQUE(project_id, layout)
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS project_type_frames (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        frame TEXT NOT NULL,
        UNIQUE(project_id, type)
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createCustomTables();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        try {
          await m.addColumn(cards, cards.noFlavorText);
        } catch (_) {}
        try {
          await customStatement(
            'UPDATE cards SET no_flavor_text = 0 WHERE no_flavor_text IS NULL',
          );
        } catch (_) {}
      }
      if (from < 3) {
        try {
          await customStatement('''
            CREATE TABLE IF NOT EXISTS card_discovered_printings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              card_id INTEGER NOT NULL,
              set_code TEXT NOT NULL,
              lang TEXT NOT NULL,
              set_name TEXT NOT NULL,
              released_at TEXT NOT NULL,
              UNIQUE(card_id, set_code, lang)
            )
          ''');
        } catch (_) {}
      }
      if (from < 4) {
        try {
          await customStatement('ALTER TABLE cards ADD COLUMN layout TEXT');
        } catch (_) {}
      }
      if (from < 5) {
        try {
          await customStatement(
            'ALTER TABLE cards ADD COLUMN scryfall_id TEXT',
          );
        } catch (_) {}
      }
      if (from < 6) {
        try {
          await customStatement(
            'ALTER TABLE card_discovered_printings ADD COLUMN artists TEXT',
          );
        } catch (_) {}
      }
      if (from < 7) {
        try {
          await customStatement(
            'ALTER TABLE flavor_text_options ADD COLUMN has_localization INTEGER',
          );
        } catch (_) {}
      }
      if (from < 8) {
        try {
          await customStatement(
            'ALTER TABLE cards ADD COLUMN is_up_to_date INTEGER DEFAULT 0',
          );
        } catch (_) {}
        try {
          await customStatement(
            'UPDATE cards SET is_up_to_date = 0 WHERE is_up_to_date IS NULL',
          );
        } catch (_) {}
      }
      if (from < 9) {
        // 'selected_extension_is_void' was added to the Dart schema without a
        // migration, so it may not exist in older databases.
        try {
          await customStatement(
            'ALTER TABLE cards ADD COLUMN'
            ' selected_extension_is_void INTEGER NOT NULL DEFAULT 0',
          );
        } catch (_) {} // already exists — ignore
        try {
          await customStatement(
            'UPDATE cards SET selected_extension_is_void = 0'
            ' WHERE selected_extension_is_void IS NULL',
          );
        } catch (_) {}
        // no_flavor_text was added in v2 but back-fill defensively.
        try {
          await customStatement(
            'UPDATE cards SET no_flavor_text = 0 WHERE no_flavor_text IS NULL',
          );
        } catch (_) {}
      }
      if (from < 10) {
        // card_discovered_sets was added to the Dart schema without a migration.
        try {
          await customStatement('''
            CREATE TABLE IF NOT EXISTS card_discovered_sets (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              card_id INTEGER NOT NULL,
              set_code TEXT NOT NULL,
              UNIQUE(card_id, set_code)
            )
          ''');
        } catch (_) {}
      }
      if (from < 11) {
        // Defensive back-fill: has_localization may be missing if the v7
        // migration previously threw and was silently absorbed.
        try {
          await customStatement(
            'ALTER TABLE flavor_text_options ADD COLUMN has_localization INTEGER',
          );
        } catch (_) {} // already exists — ignore
      }
      if (from < 12) {
        try {
          await customStatement('ALTER TABLE projects ADD COLUMN frame TEXT');
        } catch (_) {}
        try {
          await customStatement('ALTER TABLE cards ADD COLUMN frame TEXT');
        } catch (_) {}
      }
      if (from < 13) {
        try {
          await customStatement('''
            CREATE TABLE IF NOT EXISTS project_layout_frames (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              project_id INTEGER NOT NULL,
              layout TEXT NOT NULL,
              frame TEXT NOT NULL,
              UNIQUE(project_id, layout)
            )
          ''');
        } catch (_) {}
      }
      if (from < 14) {
        try {
          await customStatement('ALTER TABLE cards ADD COLUMN card_type TEXT');
        } catch (_) {}
        try {
          await customStatement('''
            CREATE TABLE IF NOT EXISTS project_type_frames (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              project_id INTEGER NOT NULL,
              type TEXT NOT NULL,
              frame TEXT NOT NULL,
              UNIQUE(project_id, type)
            )
          ''');
        } catch (_) {}
      }
      if (from < 15) {
        try {
          await customStatement('''
            CREATE TABLE IF NOT EXISTS app_settings (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        } catch (_) {}
      }
      if (from < 16) {
        // Defensive: custom tables may be absent if the DB was created via
        // onCreate before this fix was added. IF NOT EXISTS makes this safe.
        try {
          await _createCustomTables();
        } catch (_) {}
      }
      if (from < 17) {
        // Defensive: these columns may be absent on databases created from an
        // older Dart schema before the columns were added to tables.dart.
        // ALTER TABLE … ADD COLUMN has no IF NOT EXISTS — suppress duplicates.
        try {
          await customStatement('ALTER TABLE cards ADD COLUMN frame TEXT');
        } catch (_) {}
        try {
          await customStatement('ALTER TABLE cards ADD COLUMN card_type TEXT');
        } catch (_) {}
        try {
          await customStatement('ALTER TABLE projects ADD COLUMN frame TEXT');
        } catch (_) {}
      }
      if (from < 18) {
        // New Drift-managed tables: card_print_data and card_used_print_data.
        try { await m.createTable(cardPrintData); } catch (_) {}
        try { await m.createTable(cardUsedPrintData); } catch (_) {}
        // New columns on card_discovered_printings.
        try {
          await customStatement(
            'ALTER TABLE card_discovered_printings ADD COLUMN print_data_id INTEGER',
          );
        } catch (_) {}
        try {
          await customStatement(
            'ALTER TABLE card_discovered_printings ADD COLUMN collector_number TEXT',
          );
        } catch (_) {}
        try {
          await customStatement(
            'ALTER TABLE card_discovered_printings ADD COLUMN rarity TEXT',
          );
        } catch (_) {}
        // New column on cards.
        try {
          await customStatement(
            'ALTER TABLE cards ADD COLUMN selected_collector_number TEXT',
          );
        } catch (_) {}
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return driftDatabase(name: 'mtg_artwork_picker.sqlite');
  });
}
