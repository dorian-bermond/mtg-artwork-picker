import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/storage_paths.dart';
import '../data/db/app_database.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/card_repository.dart';
import '../data/repositories/artwork_repository.dart';

import '../services/http_client.dart';
import '../services/scryfall_client.dart';
import '../services/magicville_parser.dart';
import '../services/magicville_client.dart';
import '../services/image_store.dart';
import '../services/download_pipeline.dart';

import '../core/thumb_path.dart';

import '../services/discard_service.dart';
import '../services/export_service.dart';
import '../services/set_icon_service.dart';
import '../services/deck_import_service.dart';
import '../data/db/daos.dart';

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  static const _fileName = 'theme_mode.txt';

  @override
  Future<ThemeMode> build() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, _fileName));
      if (await file.exists()) {
        return _parse(await file.readAsString());
      }
    } catch (_) {}
    return ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = AsyncData(mode);
    try {
      final dir = await getApplicationSupportDirectory();
      await File(p.join(dir.path, _fileName)).writeAsString(_serialize(mode));
    } catch (_) {}
  }

  static ThemeMode _parse(String s) => switch (s.trim()) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static String _serialize(ThemeMode m) => switch (m) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.read(dbProvider));
});

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final storagePathsProvider = Provider<StoragePaths>((ref) => StoragePaths());

final projectRepoProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepository(ref.read(dbProvider)),
);
final cardRepoProvider = Provider<CardRepository>(
  (ref) => CardRepository(ref.read(dbProvider)),
);
final artworkRepoProvider = Provider<ArtworkRepository>(
  (ref) => ArtworkRepository(ref.read(dbProvider)),
);

final httpClientProvider = Provider<AppHttpClient>((ref) {
  final c = AppHttpClient();
  ref.onDispose(c.close);
  return c;
});

final scryfallClientProvider = Provider<ScryfallClient>(
  (ref) => ScryfallClient(ref.read(httpClientProvider)),
);
final magicVilleParserProvider = Provider<MagicVilleParser>(
  (ref) => MagicVilleParser(),
);
final magicVilleClientProvider = Provider<MagicVilleClient>((ref) {
  return MagicVilleClient(ref.read(magicVilleParserProvider));
});

final imageStoreProvider = Provider<ImageStore>(
  (ref) => ImageStore(ref.read(storagePathsProvider)),
);

final downloadPipelineProvider = Provider<DownloadPipeline>((ref) {
  return DownloadPipeline(
    database: ref.read(dbProvider),
    scryfall: ref.read(scryfallClientProvider),
    magicville: ref.read(magicVilleClientProvider),
    imageStore: ref.read(imageStoreProvider),
    artworkRepo: ref.read(artworkRepoProvider),
    setIconService: ref.read(setIconServiceProvider),
  );
});

final thumbPathProvider = Provider<ThumbPath>((ref) {
  return ThumbPath(ref.read(storagePathsProvider));
});

final discardServiceProvider = Provider<DiscardService>((ref) {
  return DiscardService(
    db: ref.read(dbProvider),
    imageStore: ref.read(imageStoreProvider),
    thumbPath: ref.read(thumbPathProvider),
  );
});

final setIconServiceProvider = Provider<SetIconService>(
  (ref) => SetIconService(ref.read(httpClientProvider)),
);

final deckImportServiceProvider = Provider<DeckImportService>(
  (ref) => DeckImportService(ref.read(httpClientProvider)),
);

final globalSettingsDaoProvider = Provider<GlobalSettingsDao>((ref) {
  return GlobalSettingsDao(ref.read(dbProvider));
});

final basicsProjectIdProvider = FutureProvider<int>((ref) {
  return ref.read(globalSettingsDaoProvider).getOrCreateBasicsProjectId();
});

final globalFramesProjectIdProvider = FutureProvider<int>((ref) {
  return ref.read(globalSettingsDaoProvider).getOrCreateGlobalFramesProjectId();
});
