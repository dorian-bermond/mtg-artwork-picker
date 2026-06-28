// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$ProjectsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProjectsTable get projects => attachedDatabase.projects;
  $ProjectSourcesTable get projectSources => attachedDatabase.projectSources;
  ProjectsDaoManager get managers => ProjectsDaoManager(this);
}

class ProjectsDaoManager {
  final _$ProjectsDaoMixin _db;
  ProjectsDaoManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db.attachedDatabase, _db.projects);
  $$ProjectSourcesTableTableManager get projectSources =>
      $$ProjectSourcesTableTableManager(
        _db.attachedDatabase,
        _db.projectSources,
      );
}

mixin _$CardsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardsTable get cards => attachedDatabase.cards;
  CardsDaoManager get managers => CardsDaoManager(this);
}

class CardsDaoManager {
  final _$CardsDaoMixin _db;
  CardsDaoManager(this._db);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db.attachedDatabase, _db.cards);
}

mixin _$CardDiscoveredPrintingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardDiscoveredPrintingsTable get cardDiscoveredPrintings =>
      attachedDatabase.cardDiscoveredPrintings;
  CardDiscoveredPrintingsDaoManager get managers =>
      CardDiscoveredPrintingsDaoManager(this);
}

class CardDiscoveredPrintingsDaoManager {
  final _$CardDiscoveredPrintingsDaoMixin _db;
  CardDiscoveredPrintingsDaoManager(this._db);
  $$CardDiscoveredPrintingsTableTableManager get cardDiscoveredPrintings =>
      $$CardDiscoveredPrintingsTableTableManager(
        _db.attachedDatabase,
        _db.cardDiscoveredPrintings,
      );
}

mixin _$CardDiscoveredSetsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardDiscoveredSetsTable get cardDiscoveredSets =>
      attachedDatabase.cardDiscoveredSets;
  CardDiscoveredSetsDaoManager get managers =>
      CardDiscoveredSetsDaoManager(this);
}

class CardDiscoveredSetsDaoManager {
  final _$CardDiscoveredSetsDaoMixin _db;
  CardDiscoveredSetsDaoManager(this._db);
  $$CardDiscoveredSetsTableTableManager get cardDiscoveredSets =>
      $$CardDiscoveredSetsTableTableManager(
        _db.attachedDatabase,
        _db.cardDiscoveredSets,
      );
}

mixin _$ArtworksDaoMixin on DatabaseAccessor<AppDatabase> {
  $ArtworksTable get artworks => attachedDatabase.artworks;
  ArtworksDaoManager get managers => ArtworksDaoManager(this);
}

class ArtworksDaoManager {
  final _$ArtworksDaoMixin _db;
  ArtworksDaoManager(this._db);
  $$ArtworksTableTableManager get artworks =>
      $$ArtworksTableTableManager(_db.attachedDatabase, _db.artworks);
}

mixin _$FlavorTextDaoMixin on DatabaseAccessor<AppDatabase> {
  $FlavorTextOptionsTable get flavorTextOptions =>
      attachedDatabase.flavorTextOptions;
  FlavorTextDaoManager get managers => FlavorTextDaoManager(this);
}

class FlavorTextDaoManager {
  final _$FlavorTextDaoMixin _db;
  FlavorTextDaoManager(this._db);
  $$FlavorTextOptionsTableTableManager get flavorTextOptions =>
      $$FlavorTextOptionsTableTableManager(
        _db.attachedDatabase,
        _db.flavorTextOptions,
      );
}

mixin _$PrintDataDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardPrintDataTable get cardPrintData => attachedDatabase.cardPrintData;
  $CardUsedPrintDataTable get cardUsedPrintData =>
      attachedDatabase.cardUsedPrintData;
  PrintDataDaoManager get managers => PrintDataDaoManager(this);
}

class PrintDataDaoManager {
  final _$PrintDataDaoMixin _db;
  PrintDataDaoManager(this._db);
  $$CardPrintDataTableTableManager get cardPrintData =>
      $$CardPrintDataTableTableManager(_db.attachedDatabase, _db.cardPrintData);
  $$CardUsedPrintDataTableTableManager get cardUsedPrintData =>
      $$CardUsedPrintDataTableTableManager(
        _db.attachedDatabase,
        _db.cardUsedPrintData,
      );
}
