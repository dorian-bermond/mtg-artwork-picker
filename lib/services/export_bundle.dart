import 'dart:typed_data';

class ExportBinaryFile {
  final String name;
  final Uint8List bytes;

  const ExportBinaryFile({required this.name, required this.bytes});
}

class FolderExportBundle {
  final int exportedCards;
  final List<ExportBinaryFile> files;

  const FolderExportBundle({required this.exportedCards, required this.files});
}
