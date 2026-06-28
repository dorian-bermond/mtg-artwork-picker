import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:mtg_artwork_picker/services/export_bundle.dart';
import 'package:path/path.dart' as p;

import '../data/db/app_database.dart' as db;

enum ExportMode { folder, zip }

class ExportResult {
  final int exportedCards;
  final String outputPath;
  ExportResult({required this.exportedCards, required this.outputPath});
}

class ExportService {
  final db.AppDatabase database;
  ExportService(this.database);

  String _sanitize(String input) {
    return input
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _exportFolder(String? layout, String? frame) {
    final f = frame?.trim();
    final l = layout?.trim();
    final framePart = (f != null && f.isNotEmpty) ? _sanitize(f) : 'other';
    final layoutPart = (l != null && l.isNotEmpty) ? _sanitize(l) : 'other';
    return '$framePart/$layoutPart';
  }

  String _uniqueFileName(Set<String> used, String baseName, String ext) {
    var name = '${_sanitize(baseName)}.$ext';
    if (!used.contains(name)) {
      used.add(name);
      return name;
    }
    var i = 1;
    while (true) {
      final cand = '${_sanitize(baseName)}_$i.$ext';
      if (!used.contains(cand)) {
        used.add(cand);
        return cand;
      }
      i++;
    }
  }

  Future<String?> _loadProjectFrame(int projectId) async {
    final rows = await database.customSelect(
      'SELECT frame FROM projects WHERE id = ?',
      variables: [Variable(projectId)],
    ).get();
    if (rows.isEmpty) return null;
    return rows.first.data['frame'] as String?;
  }

  Future<Map<int, ({String? layout, String? frame})>> _loadCardMeta(
    int projectId,
  ) async {
    final results = await database.customSelect(
      'SELECT id, layout, frame FROM cards WHERE project_id = ?',
      variables: [Variable(projectId)],
    ).get();
    return {
      for (final row in results)
        row.data['id'] as int: (
          layout: row.data['layout'] as String?,
          frame: row.data['frame'] as String?,
        ),
    };
  }

  Future<List<_ExportRow>> _loadCheckedCardsWithPreferredArtwork(
    int projectId,
  ) async {
    final c = database.cards;
    final a = database.artworks;

    final query = database.select(c).join([
      innerJoin(a, a.id.equalsExp(c.preferredArtworkId)),
    ])..where(c.projectId.equals(projectId) & c.preferredArtworkId.isNotNull());

    final rows = await query.get();

    final out = <_ExportRow>[];
    for (final row in rows) {
      out.add(_ExportRow(card: row.readTable(c), artwork: row.readTable(a)));
    }
    return out;
  }

  Future<db.UsedPrintData?> _resolveUsedPrintData(int cardId) {
    return database.printDataDao.getUsed(cardId);
  }

  static List<dynamic>? _parseJsonList(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return jsonDecode(json) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _buildPrintDataEntry({
    required db.Card card,
    required db.Artwork artwork,
    required db.UsedPrintData? used,
    required String exportedFileName,
    required String? frame,
  }) {
    final entry = <String, dynamic>{
      'object': 'card',
      'exported_file_name': exportedFileName,
      'lang': used?.lang ?? '',
      'name': used?.name ?? card.name,
      'layout': used?.layout ?? card.layout ?? '',
      'artist': used?.artist ?? artwork.artist,
      'set': used?.setCode ?? card.selectedSetCode ?? '',
      'set_name': used?.setName ?? '',
      'collector_number': used?.collectorNumber ?? card.selectedCollectorNumber ?? '',
      'rarity': used?.rarity ?? '',
    };

    if (frame != null) entry['frame'] = frame;

    final mana = used?.manaCost;
    if (mana != null) entry['mana_cost'] = mana;

    final typeLine = used?.typeLine;
    if (typeLine != null) entry['type_line'] = typeLine;

    final oracle = used?.oracleText;
    if (oracle != null) entry['oracle_text'] = oracle;

    final flavor = used?.flavorText;
    if (flavor != null) entry['flavor_text'] = flavor;

    final flavorName = used?.flavorName;
    if (flavorName != null) entry['flavor_name'] = flavorName;

    final power = used?.power;
    if (power != null) entry['power'] = power;

    final toughness = used?.toughness;
    if (toughness != null) entry['toughness'] = toughness;

    final loyalty = used?.loyalty;
    if (loyalty != null) entry['loyalty'] = loyalty;

    final colors = _parseJsonList(used?.colors);
    entry['colors'] = colors ?? <dynamic>[];

    final colorIdentity = _parseJsonList(used?.colorIdentity);
    entry['color_identity'] = colorIdentity ?? <dynamic>[];

    final keywords = _parseJsonList(used?.keywords);
    entry['keywords'] = keywords ?? <dynamic>[];

    return entry;
  }

  static Uint8List _encodePrintDataJson(List<Map<String, dynamic>> data) {
    const encoder = JsonEncoder.withIndent('  ');
    final root = {
      'object': 'list',
      'total_cards': data.length,
      'data': data,
    };
    return utf8.encode(encoder.convert(root));
  }

  Future<ExportResult> exportCheckedCards({
    required int projectId,
    required ExportMode mode,
    required String outputPath,
  }) async {
    final rows = await _loadCheckedCardsWithPreferredArtwork(projectId);
    if (rows.isEmpty) {
      return ExportResult(exportedCards: 0, outputPath: outputPath);
    }

    final projectFrame = await _loadProjectFrame(projectId);
    final cardMeta = await _loadCardMeta(projectId);
    final usedNamesByFolder = <String, Set<String>>{};
    final jsonEntries = <Map<String, dynamic>>[];

    if (mode == ExportMode.folder) {
      final dir = Directory(outputPath);
      if (!await dir.exists()) await dir.create(recursive: true);

      for (final r in rows) {
        final artFile = File(r.artwork.localPath);
        if (!await artFile.exists()) continue;

        final used = await _resolveUsedPrintData(r.card.id);
        final ext = p.extension(artFile.path).replaceFirst('.', '').toLowerCase();
        final setLabel = (used?.setCode ?? r.card.selectedSetCode ?? 'UNKNOWN').toUpperCase();
        final collectorNumber = used?.collectorNumber ?? r.card.selectedCollectorNumber;
        final base = collectorNumber != null
            ? '${r.card.name} (${r.artwork.artist}) [$setLabel] {$collectorNumber}'
            : '${r.card.name} (${r.artwork.artist}) [$setLabel]';
        final meta = cardMeta[r.card.id];
        final resolvedFrame = meta?.frame ?? projectFrame;
        final folder = _exportFolder(meta?.layout, resolvedFrame);
        final folderNames = usedNamesByFolder.putIfAbsent(folder, () => <String>{});
        final exportedFileName = _uniqueFileName(folderNames, base, ext);

        final subDir = Directory(p.join(dir.path, folder));
        if (!await subDir.exists()) await subDir.create(recursive: true);
        await artFile.copy(p.join(subDir.path, exportedFileName));

        jsonEntries.add(_buildPrintDataEntry(
          card: r.card,
          artwork: r.artwork,
          used: used,
          exportedFileName: '$folder/$exportedFileName',
          frame: resolvedFrame,
        ));
      }

      final jsonFile = File(p.join(dir.path, 'print_data.json'));
      await jsonFile.writeAsBytes(_encodePrintDataJson(jsonEntries), flush: true);

      return ExportResult(exportedCards: jsonEntries.length, outputPath: dir.path);
    }

    // ZIP mode
    final archive = Archive();

    for (final r in rows) {
      final artFile = File(r.artwork.localPath);
      if (!await artFile.exists()) continue;

      final used = await _resolveUsedPrintData(r.card.id);
      final bytes = await artFile.readAsBytes();
      final ext = p.extension(artFile.path).replaceFirst('.', '').toLowerCase();
      final setLabel = (used?.setCode ?? r.card.selectedSetCode ?? 'UNKNOWN').toUpperCase();
      final collectorNumber = used?.collectorNumber ?? r.card.selectedCollectorNumber;
      final base = collectorNumber != null
          ? '${r.card.name} (${r.artwork.artist}) [$setLabel] {$collectorNumber}'
          : '${r.card.name} (${r.artwork.artist}) [$setLabel]';
      final meta = cardMeta[r.card.id];
      final resolvedFrame = meta?.frame ?? projectFrame;
      final folder = _exportFolder(meta?.layout, resolvedFrame);
      final folderNames = usedNamesByFolder.putIfAbsent(folder, () => <String>{});
      final exportedFileName = _uniqueFileName(folderNames, base, ext);
      final exportedPath = '$folder/$exportedFileName';

      archive.addFile(ArchiveFile(exportedPath, bytes.length, bytes));

      jsonEntries.add(_buildPrintDataEntry(
        card: r.card,
        artwork: r.artwork,
        used: used,
        exportedFileName: exportedPath,
        frame: resolvedFrame,
      ));
    }

    final jsonBytes = _encodePrintDataJson(jsonEntries);
    archive.addFile(ArchiveFile('print_data.json', jsonBytes.length, jsonBytes));

    final zipFile = File(outputPath);
    await zipFile.writeAsBytes(ZipEncoder().encode(archive), flush: true);

    return ExportResult(exportedCards: jsonEntries.length, outputPath: zipFile.path);
  }

  Future<Uint8List> buildCheckedCardsZipBytes({required int projectId}) async {
    final rows = await _loadCheckedCardsWithPreferredArtwork(projectId);
    final projectFrame = await _loadProjectFrame(projectId);
    final cardMeta = await _loadCardMeta(projectId);

    final usedNamesByFolder = <String, Set<String>>{};
    final jsonEntries = <Map<String, dynamic>>[];
    final archive = Archive();

    for (final r in rows) {
      final artFile = File(r.artwork.localPath);
      if (!await artFile.exists()) continue;

      final used = await _resolveUsedPrintData(r.card.id);
      final bytes = await artFile.readAsBytes();
      final ext = p.extension(artFile.path).replaceFirst('.', '').toLowerCase();
      final setLabel = (used?.setCode ?? r.card.selectedSetCode ?? 'UNKNOWN').toUpperCase();
      final collectorNumber = used?.collectorNumber ?? r.card.selectedCollectorNumber;
      final base = collectorNumber != null
          ? '${r.card.name} (${r.artwork.artist}) [$setLabel] {$collectorNumber}'
          : '${r.card.name} (${r.artwork.artist}) [$setLabel]';
      final meta = cardMeta[r.card.id];
      final resolvedFrame = meta?.frame ?? projectFrame;
      final folder = _exportFolder(meta?.layout, resolvedFrame);
      final folderNames = usedNamesByFolder.putIfAbsent(folder, () => <String>{});
      final exportedFileName = _uniqueFileName(folderNames, base, ext);
      final exportedPath = '$folder/$exportedFileName';

      archive.addFile(ArchiveFile(exportedPath, bytes.length, bytes));

      jsonEntries.add(_buildPrintDataEntry(
        card: r.card,
        artwork: r.artwork,
        used: used,
        exportedFileName: exportedPath,
        frame: resolvedFrame,
      ));
    }

    final jsonBytes = _encodePrintDataJson(jsonEntries);
    archive.addFile(ArchiveFile('print_data.json', jsonBytes.length, jsonBytes));

    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  Future<FolderExportBundle> buildCheckedCardsFolderBundle({
    required int projectId,
  }) async {
    final rows = await _loadCheckedCardsWithPreferredArtwork(projectId);
    if (rows.isEmpty) {
      return const FolderExportBundle(exportedCards: 0, files: []);
    }

    final projectFrame = await _loadProjectFrame(projectId);
    final cardMeta = await _loadCardMeta(projectId);
    final usedNamesByFolder = <String, Set<String>>{};
    final files = <ExportBinaryFile>[];
    final jsonEntries = <Map<String, dynamic>>[];

    for (final r in rows) {
      final artFile = File(r.artwork.localPath);
      if (!await artFile.exists()) continue;

      final used = await _resolveUsedPrintData(r.card.id);
      final ext = p.extension(artFile.path).replaceFirst('.', '').toLowerCase();
      final setLabel = (used?.setCode ?? r.card.selectedSetCode ?? 'UNKNOWN').toUpperCase();
      final collectorNumber = used?.collectorNumber ?? r.card.selectedCollectorNumber;
      final base = collectorNumber != null
          ? '${r.card.name} (${r.artwork.artist}) [$setLabel] {$collectorNumber}'
          : '${r.card.name} (${r.artwork.artist}) [$setLabel]';
      final meta = cardMeta[r.card.id];
      final resolvedFrame = meta?.frame ?? projectFrame;
      final folder = _exportFolder(meta?.layout, resolvedFrame);
      final folderNames = usedNamesByFolder.putIfAbsent(folder, () => <String>{});
      final exportedFileName = _uniqueFileName(folderNames, base, ext);
      final exportedPath = '$folder/$exportedFileName';

      files.add(ExportBinaryFile(
        name: exportedPath,
        bytes: Uint8List.fromList(await artFile.readAsBytes()),
      ));

      jsonEntries.add(_buildPrintDataEntry(
        card: r.card,
        artwork: r.artwork,
        used: used,
        exportedFileName: exportedPath,
        frame: resolvedFrame,
      ));
    }

    files.add(ExportBinaryFile(
      name: 'print_data.json',
      bytes: _encodePrintDataJson(jsonEntries),
    ));

    return FolderExportBundle(exportedCards: jsonEntries.length, files: files);
  }
}

class _ExportRow {
  final db.Card card;
  final db.Artwork artwork;
  _ExportRow({required this.card, required this.artwork});
}
