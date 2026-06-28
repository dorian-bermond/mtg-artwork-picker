import 'package:flutter/services.dart';

import 'export_bundle.dart';

class AndroidSafExport {
  static const _channel = MethodChannel('proxystant/android_saf_export');

  static Future<bool> saveZip({
    required Uint8List bytes,
    required String suggestedName,
  }) async {
    final ok = await _channel.invokeMethod<bool>('saveZip', {
      'bytes': bytes,
      'suggestedName': suggestedName,
    });
    return ok ?? false;
  }

  static Future<bool> saveFolderExport({
    required String suggestedFolderName,
    required List<ExportBinaryFile> files,
  }) async {
    final ok = await _channel.invokeMethod<bool>('saveFolderExport', {
      'suggestedFolderName': suggestedFolderName,
      'files': files.map((f) => {'name': f.name, 'bytes': f.bytes}).toList(),
    });

    return ok ?? false;
  }
}
