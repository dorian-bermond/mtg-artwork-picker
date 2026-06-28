import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../providers/providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final int projectId;
  const ExportScreen({super.key, required this.projectId});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _running = false;
  String? _status;

  Future<void> _export() async {
    final exporter = ref.read(exportServiceProvider);

    setState(() {
      _running = true;
      _status = null;
    });

    try {
      final zipBytes = await exporter.buildCheckedCardsZipBytes(
        projectId: widget.projectId,
      );

      if (zipBytes.isEmpty) {
        setState(() => _status = 'Nothing to export.');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final tempZipPath = p.join(
        tempDir.path,
        'project_${widget.projectId}.zip',
      );

      final tempZipFile = File(tempZipPath);
      await tempZipFile.writeAsBytes(zipBytes, flush: true);

      final savedPath = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          sourceFilePath: tempZipFile.path,
          fileName: 'project_${widget.projectId}.zip',
        ),
      );

      setState(() {
        _status = savedPath == null
            ? 'Export cancelled.'
            : 'Exported ZIP:\n$savedPath';
      });
    } catch (e) {
      setState(() => _status = 'Export failed: $e');
    } finally {
      if (mounted) {
        setState(() => _running = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export checked cards only'),
            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: _running ? null : _export,
              icon: const Icon(Icons.upload_file),
              label: Text(_running ? 'Exporting…' : 'Export'),
            ),

            const SizedBox(height: 16),
            if (_status != null)
              Text(
                _status!,
                style: TextStyle(
                  color: _status!.startsWith('Export failed')
                      ? Colors.red
                      : null,
                ),
              ),

            const Spacer(),
            const Text(
              'The export contains the preferred artwork for each checked card + flavor_texts.csv.',
            ),
          ],
        ),
      ),
    );
  }
}
