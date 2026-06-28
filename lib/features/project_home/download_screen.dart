import 'dart:async' show StreamSubscription, unawaited;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/foreground_download_service.dart';
import '../../providers/providers.dart';
import '../../services/download_pipeline.dart';

enum DownloadMode { all, missingOnly, pendingOnly }

enum GetDataMode { collectorNumber, nameOnly }

class DownloadScreen extends ConsumerStatefulWidget {
  final int projectId;
  const DownloadScreen({super.key, required this.projectId});

  @override
  ConsumerState<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends ConsumerState<DownloadScreen> {
  StreamSubscription<DownloadProgress>? _sub;
  DownloadProgress? _progress;
  Object? _error;
  bool _running = false;
  GetDataMode _getDataMode = GetDataMode.nameOnly;
  bool _importTokens = true;
  DownloadMode _mode = DownloadMode.all;
  final _log = DownloadRunLog();
  File? _logFile;
  bool _hasPersistedLogs = false;

  @override
  void initState() {
    super.initState();
    _initLogFile();
  }

  Future<void> _initLogFile() async {
    final paths = ref.read(storagePathsProvider);
    final file = await paths.projectLogFile(widget.projectId);
    final hasContent = await file.exists() && (await file.length()) > 0;
    if (mounted) {
      setState(() {
        _logFile = file;
        _hasPersistedLogs = hasContent;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    if (_running) return;

    _log.clear();
    final file = _logFile;
    if (file != null) _log.setFile(file);

    setState(() {
      _running = true;
      _error = null;
      _progress = null;
    });

    // Fire-and-forget: don't block the download on the foreground service start.
    // Internal plugin null-checks can throw when the service isn't yet initialized;
    // keeping it unawaited ensures those errors stay isolated.
    unawaited(ForegroundDownloadService.start());

    final pipeline = ref.read(downloadPipelineProvider);
    await _sub?.cancel();

    final Stream<DownloadProgress> stream;
    switch (_mode) {
      case DownloadMode.all:
        stream = pipeline.runForProject(
          widget.projectId,
          log: _log,
          runFromNameOnly: _getDataMode == GetDataMode.nameOnly,
          importTokens: _importTokens,
        );
      case DownloadMode.missingOnly:
        stream = pipeline.runForProjectMissingOnly(
          widget.projectId,
          log: _log,
          runFromNameOnly: _getDataMode == GetDataMode.nameOnly,
          importTokens: _importTokens,
        );
      case DownloadMode.pendingOnly:
        stream = pipeline.runForProjectPendingOnly(
          widget.projectId,
          log: _log,
          runFromNameOnly: _getDataMode == GetDataMode.nameOnly,
          importTokens: _importTokens,
        );
    }

    _sub = stream.listen(
      (p) {
        setState(() => _progress = p);
        if (p.currentCardName != null) {
          ForegroundDownloadService.update(p.currentCardName!);
        }
      },
      onError: (e, StackTrace st) {
        debugPrint('Download error: $e\n$st');
        setState(() {
          _error = e;
          _running = false;
        });
        ForegroundDownloadService.stop();
      },
      onDone: () {
        setState(() {
          _running = false;
          _hasPersistedLogs = _log.lines.isNotEmpty;
        });
        ForegroundDownloadService.stop();
      },
      cancelOnError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _progress;

    final totalCards = p?.totalCards ?? 0;
    final processedCards = p?.processedCards ?? 0;
    final progressValue = (totalCards == 0)
        ? null
        : (processedCards.toDouble() / totalCards.toDouble()).clamp(0.0, 1.0);

    final canViewLogs = _log.lines.isNotEmpty || _hasPersistedLogs;

    return Scaffold(
      appBar: AppBar(title: const Text('Fetch Data')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Download scope',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: SegmentedButton<DownloadMode>(
                  segments: const [
                    ButtonSegment(
                      value: DownloadMode.all,
                      icon: Icon(Icons.all_inclusive),
                      label: Text('All'),
                    ),
                    ButtonSegment(
                      value: DownloadMode.missingOnly,
                      icon: Icon(Icons.hide_image_outlined),
                      label: Text('Missing'),
                    ),
                    ButtonSegment(
                      value: DownloadMode.pendingOnly,
                      icon: Icon(Icons.pending_outlined),
                      label: Text('Pending'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: _running
                      ? null
                      : (s) => setState(() => _mode = s.first),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: SegmentedButton<GetDataMode>(
                  segments: const [
                    ButtonSegment(
                      value: GetDataMode.collectorNumber,
                      icon: Icon(Icons.confirmation_num_outlined),
                      label: Text('Collector\'s number'),
                    ),
                    ButtonSegment(
                      value: GetDataMode.nameOnly,
                      icon: Icon(Icons.drive_file_rename_outline_outlined),
                      label: Text('Card name'),
                    ),
                  ],
                  selected: {_getDataMode},
                  onSelectionChanged: _running
                      ? null
                      : (s) => setState(() => _getDataMode = s.first),
                ),
              ),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Import related tokens'),
                value: _importTokens,
                onChanged: _running
                    ? null
                    : (v) => setState(() => _importTokens = v ?? true),
              ),

              const SizedBox(height: 16),

              if (p != null) ...[
                Text(
                  p.currentCardName ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progressValue),
                const SizedBox(height: 8),
                Text(p.message ?? ''),
                const SizedBox(height: 8),
                Text('Cards: ${p.processedCards}/${p.totalCards}'),
                Text('Artworks discovered: ${p.artworksDiscovered}'),
                Text('Artworks downloaded: ${p.artworksDownloaded}'),
              ] else ...[
                Text(
                  switch (_mode) {
                    DownloadMode.all =>
                      'Downloads artworks for every card in this project.',
                    DownloadMode.missingOnly =>
                      'Downloads artworks only for cards that currently have none.',
                    DownloadMode.pendingOnly =>
                      'Downloads artworks only for cards not yet processed (no prior successful run).',
                  },
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],

              const SizedBox(height: 12),
              if (_error != null)
                Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),

              const Spacer(),

              FilledButton.icon(
                onPressed: _running ? null : _start,
                icon: const Icon(Icons.play_arrow),
                label: Text(_running ? 'Running…' : 'Start / Resume'),
              ),
              OutlinedButton.icon(
                onPressed: canViewLogs ? () => _showLogs(context) : null,
                icon: const Icon(Icons.article_outlined),
                label: const Text('View logs'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogs(BuildContext context) async {
    final lines = _log.lines.isNotEmpty
        ? _log.lines
        : await _readPersistedLogs();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        builder: (context, controller) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Download logs'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy all',
                  onPressed: () {
                    final text = lines.join('\n');
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logs copied')),
                    );
                  },
                ),
              ],
            ),
            body: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.all(12),
              itemCount: lines.length,
              itemBuilder: (_, i) => SelectableText(
                lines[i],
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<String>> _readPersistedLogs() async {
    final file = _logFile;
    if (file == null || !await file.exists()) return [];
    try {
      final content = await file.readAsString();
      return content.split('\n').where((l) => l.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }
}
