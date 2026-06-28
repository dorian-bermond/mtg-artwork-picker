import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../core/storage_paths.dart';

class StoredImageResult {
  final File originalFile;
  final File thumbFile;
  final int width;
  final int height;

  StoredImageResult({
    required this.originalFile,
    required this.thumbFile,
    required this.width,
    required this.height,
  });
}

class ImageStore {
  final StoragePaths paths;
  ImageStore(this.paths);

  static const int thumbMaxSize = 512;
  static const int thumbJpegQuality = 85;

  String _sanitizeFileName(String input) {
    return input
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _extFromContentTypeOrSniff(String contentType, Uint8List bytes) {
    final ct = contentType.toLowerCase();
    if (ct.contains('image/jpeg')) return 'jpg';
    if (ct.contains('image/png')) return 'png';
    if (ct.contains('image/webp')) return 'webp';

    if (bytes.length >= 12) {
      // JPEG
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'jpg';
      // PNG
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return 'png';
      }
      // WEBP
      if (String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
          String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
        return 'webp';
      }
    }
    return 'jpg';
  }

  Future<StoredImageResult> saveArtwork({
    required int projectId,
    required String cardName,
    required String artistName,
    required Uint8List bytes,
    required String contentType,
    required int occurrenceIndexForSameArtist,
  }) async {
    final imagesDir = await paths.projectImagesDir(projectId);
    final thumbsDir = await paths.projectThumbsDir(projectId);

    final base = occurrenceIndexForSameArtist == 0
        ? '$cardName ($artistName)'
        : '$cardName ($artistName)_$occurrenceIndexForSameArtist';

    final safeBase = _sanitizeFileName(base);

    final ext = _extFromContentTypeOrSniff(contentType, bytes);
    final originalPath = p.join(imagesDir.path, '$safeBase.$ext');
    final originalFile = File(originalPath);
    await originalFile.writeAsBytes(bytes, flush: true);

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      // keep original but no thumb/dims -> throw (pipeline can catch and mark)
      throw Exception('Failed to decode image');
    }

    final w = decoded.width;
    final h = decoded.height;

    final thumb = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? thumbMaxSize : null,
      height: decoded.height > decoded.width ? thumbMaxSize : null,
      interpolation: img.Interpolation.average,
    );

    final thumbBytes = img.encodeJpg(thumb, quality: thumbJpegQuality);
    final thumbPath = p.join(thumbsDir.path, '$safeBase.jpg');
    final thumbFile = File(thumbPath);
    await thumbFile.writeAsBytes(thumbBytes, flush: true);

    return StoredImageResult(
      originalFile: originalFile,
      thumbFile: thumbFile,
      width: w,
      height: h,
    );
  }

  Future<void> deleteFileIfExists(String path) async {
    final f = File(path);
    if (await f.exists()) await f.delete();
  }
}
