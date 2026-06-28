import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mtg_artwork_picker/data/db/app_database.dart';

import '../../providers/providers.dart';
import '../../data/models/provider_id.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  final int? projectId;

  const CreateProjectScreen({super.key, this.projectId});

  bool get isEditing => projectId != null;

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _nameCtrl = TextEditingController();
  final _cardsCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  bool _deckMode = false;
  bool _importTokensOnly = false;
  bool _loadedInitialData = false;

  bool _creating = false;
  String? _error;

  bool _fetchingUrl = false;
  String? _fetchError;
  String? _importedDeckName;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cardsCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.read(projectRepoProvider);
    final cardRepo = ref.read(cardRepoProvider);

    if (!_loadedInitialData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialData();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit project' : 'Create project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Project name',
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.playlist_add,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Cards',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Only new cards will be added. Existing cards in the project will be kept.',
              ),
            ],

            // ── URL Import ────────────────────────────────────────────────
            const SizedBox(height: 20),
            Text(
              'Import from URL',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlCtrl,
                    enabled: !_fetchingUrl && !_creating,
                    decoration: const InputDecoration(
                      hintText: 'Moxfield, Archidekt or MTGGoldfish deck URL',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.url,
                    onSubmitted: (_) => _fetchFromUrl(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed:
                      _fetchingUrl || _creating ? null : _fetchFromUrl,
                  child: _fetchingUrl
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Fetch'),
                ),
              ],
            ),
            if (_fetchError != null) ...[
              const SizedBox(height: 6),
              Text(
                _fetchError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
            if (_importedDeckName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Imported: "$_importedDeckName"',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ],

            // ── Manual input ──────────────────────────────────────────────
            const SizedBox(height: 20),
            Text(
              'Or paste manually',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      'Deck mode',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: _deckMode,
                    onChanged: _creating
                        ? null
                        : (v) => setState(() => _deckMode = v),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      'Import tokens only',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: _importTokensOnly,
                    onChanged: _creating
                        ? null
                        : (v) => setState(() => _importTokensOnly = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current configuration',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _deckMode
                        ? '• Deck mode: each line must be "N Card name" — quantity is ignored, duplicates are deduplicated.'
                        : '• Deck mode off: each non-empty line is one card name.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _importTokensOnly
                        ? '• Import tokens only: listed cards are looked up on Scryfall and only their tokens are added to the project.'
                        : '• Import tokens off: listed cards are added directly.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cardsCtrl,
              decoration: InputDecoration(
                labelText: _deckMode
                    ? 'Deck list (e.g. "4 Lightning Bolt")'
                    : 'MTG card names (one per line)',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 10,
              maxLines: 18,
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            FilledButton.icon(
              onPressed: _creating
                  ? null
                  : () async {
                      final name = _nameCtrl.text.trim();
                      if (name.isEmpty) {
                        setState(() => _error = 'Project name is required.');
                        return;
                      }

                      final parsedCards = _parseInputCards(_cardsCtrl.text);
                      final router = GoRouter.of(context);

                      setState(() {
                        _creating = true;
                        _error = null;
                      });

                      try {
                        final existingProjectId = widget.projectId;
                        late final int id;

                        if (existingProjectId == null) {
                          if (parsedCards.isEmpty) {
                            setState(() {
                              _error = _deckMode
                                  ? 'Please paste at least one valid deck line like "4 Lightning Bolt".'
                                  : 'Please paste at least one card name.';
                            });
                            return;
                          }

                          id = await projects.createProject(
                            name: name,
                            enabledProviders: [
                              SourceProviderId.scryfallMagicville,
                            ],
                          );

                          final storage = ref.read(storagePathsProvider);
                          await storage.projectImagesDir(id);
                          await storage.projectThumbsDir(id);

                          if (_importTokensOnly) {
                            await ref
                                .read(downloadPipelineProvider)
                                .importTokensFromCardNames(id, parsedCards);
                          } else {
                            await cardRepo.insertCardsFromLines(id, parsedCards);
                            final globalDao = ref.read(globalSettingsDaoProvider);
                            await globalDao.copyBasicsToProject(id, parsedCards);
                            await globalDao.applyGlobalFramesToProject(id);
                          }
                        } else {
                          id = existingProjectId;

                          final database = ref.read(dbProvider);

                          await (database.update(database.projects)
                                ..where((t) => t.id.equals(id)))
                              .write(ProjectsCompanion(name: Value(name)));

                          if (parsedCards.isNotEmpty) {
                            if (_importTokensOnly) {
                              await ref
                                  .read(downloadPipelineProvider)
                                  .importTokensFromCardNames(id, parsedCards);
                            } else {
                              final newCardsOnly =
                                  await _removeExistingProjectCards(
                                    id,
                                    parsedCards,
                                  );
                              if (newCardsOnly.isNotEmpty) {
                                await cardRepo.insertCardsFromLines(
                                  id,
                                  newCardsOnly,
                                );
                              }
                            }
                          }
                        }

                        if (!mounted) return;
                        router.go('/projects/$id');
                      } catch (e) {
                        setState(() => _error = 'Failed: $e');
                      } finally {
                        if (mounted) setState(() => _creating = false);
                      }
                    },
              icon: const Icon(Icons.check),
              label: Text(
                _creating
                    ? (widget.isEditing ? 'Saving…' : 'Creating…')
                    : (widget.isEditing
                          ? (_importTokensOnly
                              ? 'Import tokens'
                              : 'Save project / add cards')
                          : (_importTokensOnly
                              ? 'Create project & import tokens'
                              : 'Create project')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchFromUrl() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _fetchingUrl = true;
      _fetchError = null;
      _importedDeckName = null;
    });

    try {
      final service = ref.read(deckImportServiceProvider);
      final result = await service.importFromUrl(url);

      if (!mounted) return;
      setState(() {
        _cardsCtrl.text = result.cardLines.join('\n');
        _deckMode = true;
        _importedDeckName = result.deckName;
        // Pre-fill project name if empty
        if (_nameCtrl.text.trim().isEmpty) {
          _nameCtrl.text = result.deckName;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _fetchError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _fetchingUrl = false);
    }
  }

  List<String> _parseNormalLines(String input) {
    return input
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<String> _parseDeckLines(String input) {
    final result = <String>[];
    final regex = RegExp(r'^\s*(\d+)\s+(.+?)\s*$');

    for (final rawLine in input.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final match = regex.firstMatch(line);
      if (match == null) continue;

      final qty = int.tryParse(match.group(1)!);
      final cardName = match.group(2)!.trim();

      if (qty == null || qty <= 0 || cardName.isEmpty) continue;

      for (int i = 0; i < qty; i++) {
        result.add(cardName);
      }
    }

    return result;
  }

  List<String> _parseInputCards(String input) {
    final parsed = _deckMode
        ? _parseDeckLines(input)
        : _parseNormalLines(input);
    return _dedupePreserveOrder(parsed);
  }

  List<String> _dedupePreserveOrder(List<String> items) {
    final seen = <String>{};
    final result = <String>[];

    for (final item in items) {
      if (seen.add(item)) {
        result.add(item);
      }
    }

    return result;
  }

  Future<void> _loadInitialData() async {
    if (_loadedInitialData) return;
    _loadedInitialData = true;

    final projectId = widget.projectId;
    if (projectId == null) return;

    final database = ref.read(dbProvider);

    final project = await (database.select(
      database.projects,
    )..where((t) => t.id.equals(projectId))).getSingleOrNull();

    if (!mounted) return;

    _nameCtrl.text = project?.name ?? '';
    _cardsCtrl.text = '';
  }

  Future<List<String>> _removeExistingProjectCards(
    int projectId,
    List<String> parsedCards,
  ) async {
    final database = ref.read(dbProvider);

    final existingCards = await (database.select(
      database.cards,
    )..where((t) => t.projectId.equals(projectId))).get();

    final existingNormalized = existingCards
        .map((c) => c.normalizedName)
        .toSet();

    return parsedCards.where((name) {
      final normalized = normalizeCardName(name);
      return !existingNormalized.contains(normalized);
    }).toList();
  }

  String normalizeCardName(String input) {
    return input.trim().toLowerCase();
  }
}
