import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../services/export_service.dart';

class ExportFlow {
  final ExportService exportService;
  ExportFlow(this.exportService);

  Future<String> exportZip({required int projectId}) async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      final path = p.join(
        Directory.current.path,
        'mtg_artwork_picker_project_$projectId.zip',
      );

      final res = await exportService.exportCheckedCards(
        projectId: projectId,
        mode: ExportMode.zip,
        outputPath: path,
      );
      return res.outputPath;
    }

    // ✅ MOBILE: save locally (no picker, no share)
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'mtg_artwork_picker_project_$projectId.zip');

    final res = await exportService.exportCheckedCards(
      projectId: projectId,
      mode: ExportMode.zip,
      outputPath: path,
    );

    return res.outputPath;
  }
}
