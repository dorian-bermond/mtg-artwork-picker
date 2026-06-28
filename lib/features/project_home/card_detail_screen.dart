import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:drift/drift.dart' hide Column;

import '../../core/template_registry.dart';
import '../../core/thumb_path.dart';
import 'frame_fullscreen_page.dart';
import '../../data/db/app_database.dart' as db;
import '../../data/models/provider_id.dart';
import '../../providers/providers.dart';
import '../../services/discard_service.dart';
import '../../services/download_pipeline.dart';

class CardDetailScreen extends ConsumerStatefulWidget {
  final int projectId;
  final int cardId;

  const CardDetailScreen({
    super.key,
    required this.projectId,
    required this.cardId,
  });

  @override
  ConsumerState<CardDetailScreen> createState() => _CardDetailScreenState();
}

enum _RefreshAction { nameOnly, token }

class _CardDetailScreenState extends ConsumerState<CardDetailScreen> {
  bool _showDiscarded = false;
  StreamSubscription<DownloadProgress>? _refreshSub;
  bool _refreshing = false;
  String? _refreshMsg;
  bool _showLogsDuringRefresh = false;
  int _refreshRunId = 0;
  final ValueNotifier<List<String>> _refreshLogsVN =
      ValueNotifier<List<String>>(<String>[]);

  @override
  Widget build(BuildContext context) {
    final database = ref.read(dbProvider);

    return StreamBuilder<db.Card>(
      stream: (database.select(
        database.cards,
      )..where((t) => t.id.equals(widget.cardId))).watchSingle(),
      builder: (context, cardSnap) {
        final card = cardSnap.data;

        if (card == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasArtwork = card.preferredArtworkId != null;

        final hasFlavorSelection =
            card.noFlavorText ||
            card.selectedFlavorTextId != null ||
            card.selectedSetIsVoid ||
            ((card.customFlavorText ?? '').trim().isNotEmpty);

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(card.name, overflow: TextOverflow.ellipsis),
                  ),
                  if (hasArtwork && hasFlavorSelection)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                    ),
                  if (hasArtwork != hasFlavorSelection)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.yellow,
                        size: 18,
                      ),
                    ),
                ],
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Artworks'),
                  Tab(text: 'Version'),
                  Tab(text: 'Print Data'),
                  Tab(text: 'Frame'),
                ],
              ),
              actions: [
                if (card.dfcSiblingId != null)
                  IconButton(
                    tooltip: 'Go to other side',
                    onPressed: () => context.go(
                      '/projects/${widget.projectId}/cards/${card.dfcSiblingId}',
                    ),
                    icon: const Icon(Icons.flip),
                  ),
                IconButton(
                  tooltip: _showDiscarded
                      ? 'Hide discarded artworks'
                      : 'Show discarded artworks',
                  onPressed: () =>
                      setState(() => _showDiscarded = !_showDiscarded),
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.delete_outline),
                      Icon(
                        _showDiscarded
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh this card',
                  onPressed: _refreshing
                      ? null
                      : () => _showRefreshDialog(card),
                  icon: _refreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: 'Delete this card from the project',
                  onPressed: _refreshing
                      ? null
                      : () => _confirmDeleteCard(card),
                  icon: const Icon(Icons.delete_forever_outlined),
                ),
              ],
            ),
            body: TabBarView(
              children: [
                _ArtworksTab(
                  projectId: widget.projectId,
                  card: card,
                  showDiscarded: _showDiscarded,
                ),
                _ExtensionsTab(card: card),
                _PrintDataTab(card: card),
                _FrameTab(card: card, projectId: widget.projectId),
              ],
            ),
          ),
        );
      },
    );
  }

  void _log(String line) {
    final ts = TimeOfDay.now().format(context);
    final next = List<String>.from(_refreshLogsVN.value)..add('[$ts] $line');
    _refreshLogsVN.value = next;
  }

  @override
  void dispose() {
    _refreshSub?.cancel();
    _refreshLogsVN.dispose();
    super.dispose();
  }

  Future<void> _showRefreshDialog(db.Card card) async {
    bool showLogs = _showLogsDuringRefresh;
    bool scryfallFallback = true;

    final isToken =
        card.layout == 'token' || card.layout == 'emblem';

    final action = await showDialog<_RefreshAction>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) => AlertDialog(
            title: const Text('Refresh card'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: showLogs,
                  onChanged: (v) => setLocal(() => showLogs = v ?? false),
                  title: const Text('Show logs'),
                  subtitle: const Text(
                    'Display a live log view during refresh',
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: scryfallFallback,
                  onChanged: (v) =>
                      setLocal(() => scryfallFallback = v ?? false),
                  title: const Text('Scryfall art fallback'),
                  subtitle: const Text(
                    'Use Scryfall art images when MagicVille has nothing',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Cancel'),
              ),
              if (isToken)
                FilledButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(_RefreshAction.token),
                  child: const Text('Refresh token'),
                )
              else
                FilledButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(_RefreshAction.nameOnly),
                  child: const Text('Refresh'),
                ),
            ],
          ),
        );
      },
    );

    if (action == null) return;

    setState(() => _showLogsDuringRefresh = showLogs);

    switch (action) {
      case _RefreshAction.nameOnly:
        _startRefresh(
          showLogs: showLogs,
          run: () => ref
              .read(downloadPipelineProvider)
              .runForSingleCardNameOnly(
                projectId: widget.projectId,
                cardId: widget.cardId,
                useScryfallFallback: scryfallFallback,
              ),
        );
        break;

      case _RefreshAction.token:
        _startRefresh(
          showLogs: showLogs,
          run: () => ref
              .read(downloadPipelineProvider)
              .runForSingleCard(
                projectId: widget.projectId,
                cardId: widget.cardId,
                useScryfallFallback: scryfallFallback,
              ),
        );
        break;
    }
  }

  void _startRefresh({
    required bool showLogs,
    required Stream<DownloadProgress> Function() run,
  }) {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
      _refreshMsg = 'Refreshing…';
      _refreshRunId++;
    });

    final runId = _refreshRunId;
    _refreshLogsVN.value = <String>[];

    if (showLogs) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (runId != _refreshRunId) return;
        _openLogsSheet(title: 'Refresh logs');
      });
    }

    _refreshSub?.cancel();
    _refreshSub = run().listen(
      (p) {
        if (!mounted) return;
        setState(() => _refreshMsg = p.message);

        final msg = p.message;
        if (msg != null && msg.trim().isNotEmpty) {
          _log(msg);
        }
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _refreshMsg = 'Refresh failed: $e');
        _log('ERROR: $e');
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _refreshing = false);

        if (showLogs) {
          _log('Done.');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_refreshMsg ?? 'Refresh done')),
          );
        }
      },
    );
  }

  void _openLogsSheet({required String title}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (ctx, controller) {
            return Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: [
                  IconButton(
                    tooltip: 'Clear',
                    onPressed: () => _refreshLogsVN.value = <String>[],
                    icon: const Icon(Icons.clear_all),
                  ),
                ],
              ),
              body: ValueListenableBuilder<List<String>>(
                valueListenable: _refreshLogsVN,
                builder: (context, logs, _) {
                  return ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.all(12),
                    itemCount: logs.length,
                    itemBuilder: (_, i) => SelectableText(
                      logs[i],
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteCard(db.Card card) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete card'),
            content: Text(
              'Remove "${card.name}" from this project?\n\n'
              'This will also remove its artworks and flavor texts.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok || !mounted) return;

    try {
      final database = ref.read(dbProvider);

      await database.transaction(() async {
        await (database.delete(
          database.artworks,
        )..where((t) => t.cardId.equals(card.id))).go();

        await (database.delete(
          database.flavorTextOptions,
        )..where((t) => t.cardId.equals(card.id))).go();

        await (database.delete(
          database.cardDiscoveredSets,
        )..where((t) => t.cardId.equals(card.id))).go();

        await (database.delete(
          database.cardDiscoveredPrintings,
        )..where((t) => t.cardId.equals(card.id))).go();

        await (database.delete(
          database.cardPrintData,
        )..where((t) => t.cardId.equals(card.id))).go();

        await (database.delete(
          database.cardUsedPrintData,
        )..where((t) => t.cardId.equals(card.id))).go();

        await (database.delete(
          database.cards,
        )..where((t) => t.id.equals(card.id))).go();
      });

      if (!mounted) return;
      context.go('/projects/${widget.projectId}/cards');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete card: $e')));
    }
  }
}

class _ArtworksTab extends ConsumerStatefulWidget {
  final int projectId;
  final db.Card card;
  final bool showDiscarded;

  const _ArtworksTab({
    required this.projectId,
    required this.card,
    required this.showDiscarded,
  });

  @override
  ConsumerState<_ArtworksTab> createState() => _ArtworksTabState();
}

class _ArtworksTabState extends ConsumerState<_ArtworksTab> {
  bool _adding = false;

  Future<void> _autoSelectVersion(db.Artwork artwork) async {
    final database = ref.read(dbProvider);
    final settingsDao = ref.read(globalSettingsDaoProvider);

    final defaultLang = await settingsDao.getDefaultLanguage();
    final preferNewest = await settingsDao.getDefaultVersionNewest();

    var printings = await database.printDataDao
        .getDiscoveredPrintingsForCard(widget.card.id);
    if (printings.isEmpty) return;

    if (preferNewest) printings = printings.reversed.toList();

    final artistNorm = artwork.artist.toLowerCase().trim();

    // 1. Printing whose artist set includes the artwork artist, in default lang
    Map<String, Object?>? target = printings.firstWhereOrNull((p) {
      if ((p['lang'] as String?) != defaultLang) return false;
      final raw = (p['artists'] as String?) ?? '';
      return raw.split(',').any((a) => a.toLowerCase().trim() == artistNorm);
    });

    // 2. Any printing in default language
    target ??= printings.firstWhereOrNull(
      (p) => (p['lang'] as String?) == defaultLang,
    );

    // 3. Any printing
    target ??= printings.first;

    final setCode = target['set_code'] as String;
    final lang = target['lang'] as String;
    final collectorNumber = target['collector_number'] as String?;

    await database.cardsDao.setSelectedSet(
      cardId: widget.card.id,
      setCode: setCode,
      lang: lang,
      isVoid: true,
      collectorNumber: collectorNumber,
    );
    await database.printDataDao.populateUsedFromPrinting(
      cardId: widget.card.id,
      setCode: setCode,
      lang: lang,
    );
  }

  Future<void> _addCustomArtwork() async {
    if (_adding) return;

    const typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null || !mounted) return;

    final artistInput = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Artist name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Unknown Artist'),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (artistInput == null || !mounted) return;

    setState(() => _adding = true);
    try {
      final bytes = await file.readAsBytes();
      final artistName =
          artistInput.trim().isEmpty ? 'Unknown Artist' : artistInput.trim();
      final imageStore = ref.read(imageStoreProvider);
      final artworkRepo = ref.read(artworkRepoProvider);
      final database = ref.read(dbProvider);

      final occurrenceIndex = await artworkRepo.countArtistOccurrencesForCard(
        widget.card.id,
        artistName,
      );

      final result = await imageStore.saveArtwork(
        projectId: widget.projectId,
        cardName: widget.card.name,
        artistName: artistName,
        bytes: bytes,
        contentType: 'application/octet-stream',
        occurrenceIndexForSameArtist: occurrenceIndex,
      );

      await database.artworksDao.insertArtwork(
        db.ArtworksCompanion.insert(
          cardId: widget.card.id,
          sourceProviderId: SourceProviderId.custom.dbValue,
          artist: artistName,
          width: result.width,
          height: result.height,
          sourceUrl: result.originalFile.path,
          localPath: result.originalFile.path,
          downloadedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add artwork: $e')));
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  static const _scryfallFallbackProviderId = 'scryfall_artcrop';

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.75,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  );

  Widget _artworkCard(
    db.Artwork a,
    int globalIndex,
    db.AppDatabase database,
    DiscardService discard,
    ThumbPath thumbPath,
  ) {
    final isPreferred = widget.card.preferredArtworkId == a.id;
    return InkWell(
      onTap: () {
        final uri = Uri(
          path:
              '/projects/${widget.projectId}/cards/${widget.card.id}/artworks/view',
          queryParameters: {
            'index': '$globalIndex',
            'title': widget.card.name,
            'showDiscarded': widget.showDiscarded ? '1' : '0',
          },
        );
        context.push(uri.toString());
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: FutureBuilder<String>(
                future: thumbPath.thumbForOriginal(
                  projectId: widget.projectId,
                  originalPath: a.localPath,
                ),
                builder: (context, thumbSnap) {
                  final tp = thumbSnap.data;
                  if (tp == null) {
                    return Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Image.file(
                    File(tp),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '${a.width}×${a.height}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            if (isPreferred)
              const Positioned(
                top: 8,
                left: 8,
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
            if (a.isDiscarded)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.delete_forever, color: Colors.red),
              ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Set preferred',
                    onPressed: a.isDiscarded
                        ? null
                        : () async {
                            await database.cardsDao
                                .setPreferredArtwork(widget.card.id, a.id);
                            await _autoSelectVersion(a);
                          },
                    icon: const Icon(Icons.star),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Discard',
                    onPressed: a.isDiscarded
                        ? null
                        : () async {
                            await discard.discardArtwork(
                              projectId: widget.projectId,
                              artworkId: a.id,
                            );
                            if (widget.card.preferredArtworkId == a.id) {
                              await database.cardsDao.setPreferredArtwork(
                                widget.card.id,
                                null,
                              );
                            }
                          },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.read(dbProvider);
    final discard = ref.read(discardServiceProvider);
    final thumbPath = ref.read(thumbPathProvider);

    return StreamBuilder<List<db.Artwork>>(
      stream: database.artworksDao.watchArtworksForCard(
        widget.card.id,
        includeDiscarded: widget.showDiscarded,
      ),
      builder: (context, snap) {
        final arts = snap.data ?? const [];
        final primaryArts = arts
            .where((a) => a.sourceProviderId != _scryfallFallbackProviderId)
            .toList();
        final fallbackArts = arts
            .where((a) => a.sourceProviderId == _scryfallFallbackProviderId)
            .toList();

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate: _gridDelegate,
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i == 0) {
                      return InkWell(
                        onTap: _adding ? null : _addCustomArtwork,
                        child: Card(
                          child: Center(
                            child: _adding
                                ? const CircularProgressIndicator()
                                : const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 48,
                                  ),
                          ),
                        ),
                      );
                    }
                    final a = primaryArts[i - 1];
                    return _artworkCard(
                      a,
                      arts.indexOf(a),
                      database,
                      discard,
                      thumbPath,
                    );
                  },
                  childCount: primaryArts.length + 1,
                ),
              ),
            ),
            if (fallbackArts.isNotEmpty)
              SliverToBoxAdapter(
                child: ExpansionTile(
                  title: Text(
                    'Scryfall art (${fallbackArts.length})',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate: _gridDelegate,
                        itemCount: fallbackArts.length,
                        itemBuilder: (context, i) {
                          final a = fallbackArts[i];
                          return _artworkCard(
                            a,
                            arts.indexOf(a),
                            database,
                            discard,
                            thumbPath,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

const _kAllowedLangs = ['en', 'fr'];

class _ExtensionsTab extends ConsumerStatefulWidget {
  final db.Card card;

  const _ExtensionsTab({required this.card});

  @override
  ConsumerState<_ExtensionsTab> createState() => _ExtensionsTabState();
}

class _ExtensionsTabState extends ConsumerState<_ExtensionsTab> {
  final ScrollController _scrollCtrl = ScrollController();
  bool _hideNoFlavor = false;
  final Set<String> _langFilter = {};
  String? _selectedArtist;

  @override
  void initState() {
    super.initState();
    _loadArtist();
  }

  @override
  void didUpdateWidget(covariant _ExtensionsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.preferredArtworkId != oldWidget.card.preferredArtworkId) {
      _loadArtist();
    }
  }

  Future<void> _loadArtist() async {
    final artworkId = widget.card.preferredArtworkId;
    if (artworkId == null) {
      if (mounted) setState(() => _selectedArtist = null);
      return;
    }
    final artwork = await ref.read(dbProvider).artworksDao.getById(artworkId);
    if (mounted) setState(() => _selectedArtist = artwork?.artist);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.read(dbProvider);
    final iconService = ref.read(setIconServiceProvider);
    final selectedArtist = _selectedArtist;

    return StreamBuilder<List<db.CardDiscoveredPrinting>>(
      stream: database.cardDiscoveredPrintingsDao.watchForCard(widget.card.id),
      builder: (context, printingsSnap) {
        final printings = printingsSnap.data ?? const [];

        return StreamBuilder<List<db.FlavorTextOption>>(
          stream: database.flavorTextDao.watchFlavorOptionsForCard(
            widget.card.id,
          ),
          builder: (context, flavorSnap) {
            final options = flavorSnap.data ?? const [];

            if (printings.isEmpty) {
              return const Center(child: Text('No discovered sets found yet.'));
            }

            // Aggregate per set: collect langs + artists, keep setName/releasedAt from first seen
            final bySet = <String, _SetEntry>{};
            for (final p in printings) {
              final entry = bySet.putIfAbsent(
                p.setCode,
                () => _SetEntry(
                  setCode: p.setCode,
                  setName: p.setName,
                  releasedAt: p.releasedAt,
                ),
              );
              entry.langs.add(p.lang);
              final raw = p.artists;
              if (raw != null && raw.isNotEmpty) {
                entry.artists.addAll(
                  raw.split(',').map((a) => a.trim()).where((a) => a.isNotEmpty),
                );
              }
            }

            // Group flavor options by setCode → lang → list
            final flavorBySetLang =
                <String, Map<String, List<db.FlavorTextOption>>>{};
            for (final o in options) {
              final s = (o.printingSet ?? '').trim().toLowerCase();
              final l = (o.lang ?? '').trim().toLowerCase();
              (flavorBySetLang[s] ??= {})[l] ??= [];
              flavorBySetLang[s]![l]!.add(o);
            }

            bool setHasFlavor(_SetEntry e) =>
                flavorBySetLang[e.setCode]?.values.any((v) => v.isNotEmpty) ??
                false;

            final sets = bySet.values
                .where((e) => !_hideNoFlavor || setHasFlavor(e))
                .where((e) =>
                    _langFilter.isEmpty ||
                    e.langs.any(_langFilter.contains))
                .toList()
              ..sort((a, b) => a.releasedAt.compareTo(b.releasedAt));

            return Column(
              children: [
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Tooltip(
                          message: 'Has flavor text',
                          child: _hideNoFlavor
                              ? IconButton.filledTonal(
                                  icon: const Icon(Icons.format_quote),
                                  onPressed: () =>
                                      setState(() => _hideNoFlavor = false),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.format_quote),
                                  onPressed: () =>
                                      setState(() => _hideNoFlavor = true),
                                ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          tooltip: 'Filter by language',
                          icon: Badge(
                            isLabelVisible: _langFilter.isNotEmpty,
                            label: Text('${_langFilter.length}'),
                            child: const Icon(Icons.language),
                          ),
                          itemBuilder: (_) => _kAllowedLangs
                              .map(
                                (lang) => CheckedPopupMenuItem(
                                  value: lang,
                                  checked: _langFilter.contains(lang),
                                  child: Text(_langLabel(lang)),
                                ),
                              )
                              .toList(),
                          onSelected: (lang) => setState(() {
                            if (!_langFilter.remove(lang)) {
                              _langFilter.add(lang);
                            }
                          }),
                        ),
                        const Spacer(),
                        if (_hideNoFlavor || _langFilter.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear all filters',
                            icon: const Icon(Icons.filter_alt_off_outlined),
                            onPressed: () => setState(() {
                              _hideNoFlavor = false;
                              _langFilter.clear();
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Scrollbar(
              controller: _scrollCtrl,
              thumbVisibility: true,
              child: ListView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(12),
                children: [
                  for (final entry in sets)
                    Builder(
                      builder: (context) {
                        final setCode = entry.setCode;
                        final langsForSet = flavorBySetLang[setCode];
                        final orderedLangs = entry.langs.toList()..sort();

                        final subtitle = orderedLangs.map((l) {
                          final hasFlavor = langsForSet != null &&
                              (langsForSet[l]?.isNotEmpty ?? false);
                          return hasFlavor ? _langLabel(l) : '${_langLabel(l)}*';
                        }).join('  ');

                        final title = _setTitle(
                          entry.setName,
                          setCode,
                          entry.releasedAt,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                FutureBuilder<Uint8List?>(
                                  future: iconService.getIconBytes(setCode),
                                  builder: (context, snap) {
                                    final bytes = snap.data;
                                    if (bytes == null) {
                                      return const SizedBox(width: 20);
                                    }
                                    return SvgPicture.memory(
                                      bytes,
                                      width: 20,
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                        Theme.of(context).colorScheme.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: _langGroupColor(
                                          entry.langGroup, context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (selectedArtist != null &&
                                    entry.artists.contains(selectedArtist))
                                  Tooltip(
                                    message: selectedArtist,
                                    child: const Icon(
                                      Icons.palette_outlined,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(subtitle),
                            children: [
                              for (final lang in orderedLangs) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    4,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _langLabel(lang),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                  ),
                                ),
                                if (langsForSet == null ||
                                    langsForSet[lang] == null ||
                                    langsForSet[lang]!.isEmpty)
                                  Builder(
                                    builder: (context) {
                                      final isVoidSelected =
                                          widget.card.selectedSetIsVoid &&
                                          widget.card.selectedSetCode ==
                                              setCode &&
                                          widget.card.selectedSetLang ==
                                              lang;

                                      return ListTile(
                                        leading: Icon(
                                          isVoidSelected
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: isVoidSelected
                                              ? Colors.green
                                              : null,
                                        ),
                                        title: const Text('*void*'),
                                        onTap: () async {
                                          await database.cardsDao
                                              .setSelectedSet(
                                                cardId: widget.card.id,
                                                setCode: setCode,
                                                lang: lang,
                                                isVoid: true,
                                                flavorTextId: null,
                                                customFlavorText: '',
                                              );
                                          await database.printDataDao
                                              .populateUsedFromPrinting(
                                                cardId: widget.card.id,
                                                setCode: setCode,
                                                lang: lang,
                                              );
                                          if (widget.card.preferredArtworkId == null) {
                                            final arts = await database.artworksDao
                                                .getNonDiscardedArtworksForCard(widget.card.id);
                                            if (arts.length == 1) {
                                              await database.cardsDao.setPreferredArtwork(
                                                widget.card.id, arts.first.id);
                                            }
                                          }
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Empty flavor text selected',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                else
                                  ...langsForSet[lang]!.map((o) {
                                    final flavorText = o.flavor.trim();
                                    final displayText = flavorText.isEmpty
                                        ? '*void*'
                                        : flavorText;

                                    final isSelected =
                                        widget.card.selectedFlavorTextId ==
                                            o.id &&
                                        widget.card.selectedSetCode ==
                                            setCode &&
                                        widget.card.selectedSetLang ==
                                            lang &&
                                        !widget.card.selectedSetIsVoid;

                                    final missingLoc =
                                        lang != 'en' &&
                                        o.hasLocalization == false;
                                    return ListTile(
                                      leading: Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: isSelected ? Colors.green : null,
                                      ),
                                      title: Text(displayText),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            (o.printingCollectorNumber ?? '')
                                                .trim(),
                                          ),
                                          if (missingLoc) ...[
                                            const SizedBox(width: 6),
                                            Tooltip(
                                              message:
                                                  'Scryfall has no localized text for this printing',
                                              child: const Icon(
                                                Icons.warning_amber_rounded,
                                                size: 14,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      onTap: () async {
                                        await database.cardsDao
                                            .setSelectedSet(
                                              cardId: widget.card.id,
                                              setCode: setCode,
                                              lang: lang,
                                              isVoid: false,
                                              flavorTextId: o.id,
                                              customFlavorText: flavorText,
                                              collectorNumber: o.printingCollectorNumber,
                                            );
                                        await database.printDataDao
                                            .populateUsedFromPrinting(
                                              cardId: widget.card.id,
                                              setCode: setCode,
                                              lang: lang,
                                            );
                                        if (widget.card.preferredArtworkId == null) {
                                          final arts = await database.artworksDao
                                              .getNonDiscardedArtworksForCard(widget.card.id);
                                          if (arts.length == 1) {
                                            await database.cardsDao.setPreferredArtwork(
                                              widget.card.id, arts.first.id);
                                          }
                                        }
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Version selected'),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _langLabel(String lang) {
    switch (lang.toLowerCase()) {
      case 'en': return '🇺🇸';
      case 'fr': return '🇫🇷';
      default: return lang.toUpperCase();
    }
  }

  Color _langGroupColor(int group, BuildContext context) {
    switch (group) {
      case 0: return Colors.teal;          // EN + FR
      case 1: return Colors.indigo;        // FR only
      case 2: return Colors.orange;        // EN only
      default: return Theme.of(context).colorScheme.onSurface;
    }
  }

  String _setTitle(String setName, String setCode, String releasedAt) {
    final code = setCode.toUpperCase();
    final namePart = setName.isEmpty ? code : '$setName ($code)';
    final year = releasedAt.length >= 4 ? releasedAt.substring(0, 4) : releasedAt;
    return year.isEmpty ? namePart : '$namePart — $year';
  }
}

class _SetEntry {
  final String setCode;
  final String setName;
  final String releasedAt;
  final Set<String> langs = {};
  final Set<String> artists = {};

  _SetEntry({
    required this.setCode,
    required this.setName,
    required this.releasedAt,
  });

  // 0 = EN+FR, 1 = FR only, 2 = EN only, 3 = other
  int get langGroup {
    final hasEn = langs.contains('en');
    final hasFr = langs.contains('fr');
    if (hasEn && hasFr) return 0;
    if (hasFr) return 1;
    if (hasEn) return 2;
    return 3;
  }
}

class _FrameTab extends ConsumerWidget {
  final db.Card card;
  final int projectId;
  const _FrameTab({required this.card, required this.projectId});

  String _previewKey(TemplateInfo info) {
    final keys = templateLayoutKeys(card.layout);
    for (final k in keys) {
      if (info.layouts.containsKey(k)) return k;
    }
    return info.layouts.containsKey('normal') ? 'normal' : info.layouts.keys.first;
  }

  String _previewPath(TemplateInfo info) {
    final k = _previewKey(info);
    return info.layouts[k]!;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.read(dbProvider);
    final cs = Theme.of(context).colorScheme;

    final frameStream = database.customSelect(
      'SELECT frame FROM cards WHERE id = ?',
      variables: [Variable(card.id)],
      readsFrom: {database.cards},
    ).watch().map((rows) =>
        rows.isEmpty ? null : rows.first.data['frame'] as String?);

    final defaultStream = database.customSelect(
      'SELECT frame FROM project_layout_frames WHERE project_id = ? AND layout = ?',
      variables: [Variable(projectId), Variable(card.layout ?? 'normal')],
    ).watch().map((rows) =>
        rows.isEmpty ? null : rows.first.data['frame'] as String?);

    return StreamBuilder<String?>(
      stream: frameStream,
      builder: (context, snap) {
        final currentFrame = snap.data;

        return StreamBuilder<String?>(
          stream: defaultStream,
          builder: (context, defaultSnap) {
            final projectDefault = defaultSnap.data;

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentFrame != null
                            ? 'Frame: $currentFrame'
                            : projectDefault != null
                                ? 'Frame: $projectDefault (project default)'
                                : 'Frame: Normal (project default)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (currentFrame != null)
                      TextButton.icon(
                        onPressed: () =>
                            database.cardsDao.setFrame(card.id, null),
                        icon: const Icon(Icons.undo, size: 16),
                        label: const Text('Reset to default'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: templateRegistry.entries
                      .where((e) => frameCompatible(
                          e.value, {card.layout ?? 'normal'}))
                      .map((e) {
                    final previewKey = _previewKey(e.value);
                    final previewPath = _previewPath(e.value);
                    final name = templateFolderName(previewPath);
                    final isSelected = currentFrame == name;
                    final isDefault = projectDefault == name;
                    return GestureDetector(
                      onTap: () => database.cardsDao.setFrame(card.id, name),
                      onLongPress: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          fullscreenDialog: true,
                          builder: (ctx) => FrameFullscreenPage(
                            frameName: name,
                            layouts: e.value.layouts,
                            initialKey: previewKey,
                          ),
                        ),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: 88,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? cs.primary
                                : isDefault
                                    ? cs.primary.withValues(alpha: 0.45)
                                    : cs.outlineVariant,
                            width: isSelected ? 2.5 : isDefault ? 1.5 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(isSelected ? 5.5 : 7),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AspectRatio(
                                aspectRatio: 5 / 7,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      previewPath,
                                      fit: BoxFit.cover,
                                      cacheWidth: 176,
                                      errorBuilder: (_, _, _) => Container(
                                        color: cs.surfaceContainerHighest,
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: cs.outlineVariant,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: cs.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            size: 11,
                                            color: cs.onPrimary,
                                          ),
                                        ),
                                      )
                                    else if (isDefault)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: cs.primary.withValues(alpha: 0.85),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.star,
                                            size: 11,
                                            color: cs.onPrimary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                color: isSelected
                                    ? cs.primaryContainer
                                    : isDefault
                                        ? cs.primaryContainer.withValues(alpha: 0.4)
                                        : cs.surfaceContainerHighest,
                                padding:
                                    const EdgeInsets.fromLTRB(6, 5, 6, 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: isSelected
                                                ? cs.onPrimaryContainer
                                                : null,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : null,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      e.value.author,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontSize: 9,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Print Data tab ────────────────────────────────────────────────────────────

class _PrintDataTab extends ConsumerStatefulWidget {
  final db.Card card;
  const _PrintDataTab({required this.card});

  @override
  ConsumerState<_PrintDataTab> createState() => _PrintDataTabState();
}

class _PrintDataTabState extends ConsumerState<_PrintDataTab> {
  final _nameCtrl = TextEditingController();
  final _flavorNameCtrl = TextEditingController();
  final _manaCostCtrl = TextEditingController();
  final _typeLineCtrl = TextEditingController();
  final _oracleTextCtrl = TextEditingController();
  final _flavorTextCtrl = TextEditingController();
  final _powerCtrl = TextEditingController();
  final _toughnessCtrl = TextEditingController();
  final _loyaltyCtrl = TextEditingController();
  final _colorsCtrl = TextEditingController();
  final _colorIdentityCtrl = TextEditingController();
  final _keywordsCtrl = TextEditingController();
  final _collectorNumberCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _rarityCtrl = TextEditingController();

  String? _setCode;
  String? _setName;
  String? _lang;

  bool _loaded = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadUsed();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> get _controllers => [
        _nameCtrl, _flavorNameCtrl, _manaCostCtrl, _typeLineCtrl,
        _oracleTextCtrl, _flavorTextCtrl, _powerCtrl, _toughnessCtrl,
        _loyaltyCtrl, _colorsCtrl, _colorIdentityCtrl, _keywordsCtrl,
        _collectorNumberCtrl, _artistCtrl, _rarityCtrl,
      ];

  Future<void> _loadUsed() async {
    final database = ref.read(dbProvider);
    final used = await database.printDataDao.getUsed(widget.card.id);
    if (!mounted) return;
    if (used != null) _applyUsed(used);
    setState(() => _loaded = true);
  }

  void _applyUsed(db.UsedPrintData used) {
    _nameCtrl.text = used.name ?? '';
    _flavorNameCtrl.text = used.flavorName ?? '';
    _manaCostCtrl.text = used.manaCost ?? '';
    _typeLineCtrl.text = used.typeLine ?? '';
    _oracleTextCtrl.text = used.oracleText ?? '';
    _flavorTextCtrl.text = used.flavorText ?? '';
    _powerCtrl.text = used.power ?? '';
    _toughnessCtrl.text = used.toughness ?? '';
    _loyaltyCtrl.text = used.loyalty ?? '';
    _colorsCtrl.text = used.colors ?? '';
    _colorIdentityCtrl.text = used.colorIdentity ?? '';
    _keywordsCtrl.text = used.keywords ?? '';
    _collectorNumberCtrl.text = used.collectorNumber ?? '';
    _artistCtrl.text = used.artist ?? '';
    _rarityCtrl.text = used.rarity ?? '';
    _setCode = used.setCode;
    _setName = used.setName;
    _lang = used.lang;
  }

  String? _n(String v) => v.trim().isEmpty ? null : v.trim();

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _save);
  }

  Future<void> _save() async {
    final database = ref.read(dbProvider);
    await database.printDataDao.setUsed(
      db.CardUsedPrintDataCompanion(
        cardId: Value(widget.card.id),
        lang: Value(_n(_lang ?? '')),
        name: Value(_n(_nameCtrl.text)),
        flavorName: Value(_n(_flavorNameCtrl.text)),
        manaCost: Value(_n(_manaCostCtrl.text)),
        typeLine: Value(_n(_typeLineCtrl.text)),
        oracleText: Value(_n(_oracleTextCtrl.text)),
        flavorText: Value(_n(_flavorTextCtrl.text)),
        power: Value(_n(_powerCtrl.text)),
        toughness: Value(_n(_toughnessCtrl.text)),
        loyalty: Value(_n(_loyaltyCtrl.text)),
        colors: Value(_n(_colorsCtrl.text)),
        colorIdentity: Value(_n(_colorIdentityCtrl.text)),
        keywords: Value(_n(_keywordsCtrl.text)),
        layout: Value(widget.card.layout),
        setCode: Value(_setCode),
        setName: Value(_setName),
        collectorNumber: Value(_n(_collectorNumberCtrl.text)),
        rarity: Value(_n(_rarityCtrl.text)),
        artist: Value(_n(_artistCtrl.text)),
      ),
    );
  }

  void _applyTemplate(db.PrintData pd, {String? setCode, String? setName}) {
    _nameCtrl.text = pd.name;
    _flavorNameCtrl.text = pd.flavorName ?? '';
    _manaCostCtrl.text = pd.manaCost ?? '';
    _typeLineCtrl.text = pd.typeLine ?? '';
    _oracleTextCtrl.text = pd.oracleText ?? '';
    _flavorTextCtrl.text = pd.flavorText ?? '';
    _powerCtrl.text = pd.power ?? '';
    _toughnessCtrl.text = pd.toughness ?? '';
    _loyaltyCtrl.text = pd.loyalty ?? '';
    _colorsCtrl.text = pd.colors ?? '';
    _colorIdentityCtrl.text = pd.colorIdentity ?? '';
    _keywordsCtrl.text = pd.keywords ?? '';
    setState(() {
      _lang = pd.lang;
      if (setCode != null) {
        _setCode = setCode;
        _setName = setName;
      }
    });
    _scheduleSave();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.read(dbProvider);
    final cs = Theme.of(context).colorScheme;

    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<db.PrintData>>(
      stream: database.printDataDao.watchForCard(widget.card.id),
      builder: (context, pdSnap) {
        final printDatas = pdSnap.data ?? [];

        return StreamBuilder<List<db.CardDiscoveredPrinting>>(
          stream: database.cardDiscoveredPrintingsDao
              .watchForCard(widget.card.id),
          builder: (context, printingsSnap) {
            final printings = printingsSnap.data ?? [];
            final knownSets = {
              for (final p in printings) p.setCode: p.setName,
            };

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // ── Available print data templates ───────────────────────
                if (printDatas.isNotEmpty) ...[
                  Text(
                    'Available versions',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: printDatas.map((pd) {
                      final label =
                          '${pd.lang.toUpperCase()} · ${pd.name}';
                      return ActionChip(
                        label: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () => _applyTemplate(pd),
                        tooltip: 'Apply this version to all fields',
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                ],

                // ── Set picker ───────────────────────────────────────────
                _FieldRow(
                  label: 'Set',
                  child: knownSets.isEmpty
                      ? TextField(
                          controller:
                              TextEditingController(text: _setCode ?? ''),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) {
                            _setCode = v.trim().isEmpty ? null : v.trim();
                            _scheduleSave();
                          },
                        )
                      : DropdownButtonFormField<String>(
                          value: knownSets.containsKey(_setCode)
                              ? _setCode
                              : null,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Select set'),
                          items: knownSets.entries.map((e) {
                            return DropdownMenuItem(
                              value: e.key,
                              child: Text(
                                '${e.key.toUpperCase()} — ${e.value}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setState(() {
                              _setCode = v;
                              _setName = v != null ? knownSets[v] : null;
                            });
                            _scheduleSave();
                          },
                        ),
                ),

                // ── Text fields ──────────────────────────────────────────
                _EditableField(
                  label: 'Name',
                  ctrl: _nameCtrl,
                  onChanged: (_) => _scheduleSave(),
                  availableValues: printDatas
                      .map((p) => p.name)
                      .toSet()
                      .toList(),
                  onPickValue: (v) {
                    _nameCtrl.text = v;
                    _scheduleSave();
                  },
                ),
                _EditableField(
                  label: 'Flavor name',
                  ctrl: _flavorNameCtrl,
                  onChanged: (_) => _scheduleSave(),
                  availableValues: printDatas
                      .map((p) => p.flavorName)
                      .whereType<String>()
                      .toSet()
                      .toList(),
                  onPickValue: (v) {
                    _flavorNameCtrl.text = v;
                    _scheduleSave();
                  },
                ),
                _EditableField(
                  label: 'Mana cost',
                  ctrl: _manaCostCtrl,
                  onChanged: (_) => _scheduleSave(),
                  availableValues: printDatas
                      .map((p) => p.manaCost)
                      .whereType<String>()
                      .toSet()
                      .toList(),
                  onPickValue: (v) {
                    _manaCostCtrl.text = v;
                    _scheduleSave();
                  },
                ),
                _EditableField(
                  label: 'Type line',
                  ctrl: _typeLineCtrl,
                  onChanged: (_) => _scheduleSave(),
                  availableValues: printDatas
                      .map((p) => p.typeLine)
                      .whereType<String>()
                      .toSet()
                      .toList(),
                  onPickValue: (v) {
                    _typeLineCtrl.text = v;
                    _scheduleSave();
                  },
                ),
                _EditableField(
                  label: 'Oracle text',
                  ctrl: _oracleTextCtrl,
                  onChanged: (_) => _scheduleSave(),
                  maxLines: 5,
                  availableValues: printDatas
                      .map((p) => p.oracleText)
                      .whereType<String>()
                      .toSet()
                      .toList(),
                  onPickValue: (v) {
                    _oracleTextCtrl.text = v;
                    _scheduleSave();
                  },
                ),
                _EditableField(
                  label: 'Flavor text',
                  ctrl: _flavorTextCtrl,
                  onChanged: (_) => _scheduleSave(),
                  maxLines: 4,
                  availableValues: printDatas
                      .map((p) => p.flavorText)
                      .whereType<String>()
                      .toSet()
                      .toList(),
                  onPickValue: (v) {
                    _flavorTextCtrl.text = v;
                    _scheduleSave();
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: _EditableField(
                        label: 'Power',
                        ctrl: _powerCtrl,
                        onChanged: (_) => _scheduleSave(),
                        availableValues: printDatas
                            .map((p) => p.power)
                            .whereType<String>()
                            .toSet()
                            .toList(),
                        onPickValue: (v) {
                          _powerCtrl.text = v;
                          _scheduleSave();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EditableField(
                        label: 'Toughness',
                        ctrl: _toughnessCtrl,
                        onChanged: (_) => _scheduleSave(),
                        availableValues: printDatas
                            .map((p) => p.toughness)
                            .whereType<String>()
                            .toSet()
                            .toList(),
                        onPickValue: (v) {
                          _toughnessCtrl.text = v;
                          _scheduleSave();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EditableField(
                        label: 'Loyalty',
                        ctrl: _loyaltyCtrl,
                        onChanged: (_) => _scheduleSave(),
                        availableValues: printDatas
                            .map((p) => p.loyalty)
                            .whereType<String>()
                            .toSet()
                            .toList(),
                        onPickValue: (v) {
                          _loyaltyCtrl.text = v;
                          _scheduleSave();
                        },
                      ),
                    ),
                  ],
                ),
                _EditableField(
                  label: 'Artist',
                  ctrl: _artistCtrl,
                  onChanged: (_) => _scheduleSave(),
                  availableValues: printings
                      .expand((p) => (p.artists ?? '')
                          .split(',')
                          .map((a) => a.trim())
                          .where((a) => a.isNotEmpty))
                      .toSet()
                      .toList(),
                  onPickValue: (v) {
                    _artistCtrl.text = v;
                    _scheduleSave();
                  },
                ),
                _EditableField(
                  label: 'Collector #',
                  ctrl: _collectorNumberCtrl,
                  onChanged: (_) => _scheduleSave(),
                  availableValues: printings
                      .map((p) => p.collectorNumber)
                      .whereType<String>()
                      .toSet()
                      .toList(),
                  onPickValue: (v) {
                    _collectorNumberCtrl.text = v;
                    _scheduleSave();
                  },
                ),
                _EditableField(
                  label: 'Rarity',
                  ctrl: _rarityCtrl,
                  onChanged: (_) => _scheduleSave(),
                  availableValues: printings
                      .map((p) => p.rarity)
                      .whereType<String>()
                      .toSet()
                      .toList(),
                  onPickValue: (v) {
                    _rarityCtrl.text = v;
                    _scheduleSave();
                  },
                ),

                if (printDatas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      'No print data yet. Run "Fetch Data" to populate.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final List<String> availableValues;
  final ValueChanged<String> onPickValue;

  const _EditableField({
    required this.label,
    required this.ctrl,
    required this.onChanged,
    this.maxLines = 1,
    required this.availableValues,
    required this.onPickValue,
  });

  @override
  Widget build(BuildContext context) {
    return _FieldRow(
      label: label,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              onChanged: onChanged,
              maxLines: maxLines,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (availableValues.isNotEmpty) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              tooltip: 'Pick a value',
              icon: const Icon(Icons.arrow_drop_down),
              padding: EdgeInsets.zero,
              itemBuilder: (_) => availableValues
                  .map(
                    (v) => PopupMenuItem(
                      value: v,
                      child: Text(
                        v,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onSelected: onPickValue,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Flavor text tab (legacy, kept for flavor_text_options DB writes) ───────────

class _FlavorTab extends ConsumerStatefulWidget {
  final db.Card card;

  const _FlavorTab({required this.card});

  @override
  ConsumerState<_FlavorTab> createState() => _FlavorTabState();
}

class _FlavorTabState extends ConsumerState<_FlavorTab> {
  final _customCtrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _customCtrl.text = widget.card.customFlavorText ?? '';
  }

  @override
  void didUpdateWidget(covariant _FlavorTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newText = widget.card.customFlavorText ?? '';
    if (_focusNode.hasFocus) return;

    if (_customCtrl.text != newText) {
      _customCtrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  void _onCustomChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final database = ref.read(dbProvider);
      await database.cardsDao.clearSelectedSet(widget.card.id);
      await database.cardsDao.setCustomFlavorText(
        widget.card.id,
        v.trim().isEmpty ? null : v,
      );
    });
  }

  void _flushCustomText() async {
    _debounce?.cancel();
    final database = ref.read(dbProvider);
    await database.cardsDao.clearSelectedSet(widget.card.id);
    await database.cardsDao.setCustomFlavorText(
      widget.card.id,
      _customCtrl.text.trim().isEmpty ? null : _customCtrl.text,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.read(dbProvider);
    final noFlavorText = widget.card.noFlavorText;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Flavor text', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: noFlavorText,
            onChanged: (v) async {
              final checked = v ?? false;
              await database.cardsDao.clearSelectedSet(widget.card.id);
              await database.cardsDao.setNoFlavorText(widget.card.id, checked);

              if (checked) {
                await database.cardsDao.setSelectedFlavorText(
                  widget.card.id,
                  null,
                );
                await database.cardsDao.setCustomFlavorText(
                  widget.card.id,
                  null,
                );
                _customCtrl.text = '';
              }
            },
            title: const Text('No flavor text'),
            subtitle: const Text('Force this card to have no flavor text'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customCtrl,
            focusNode: _focusNode,
            enabled: !noFlavorText,
            decoration: const InputDecoration(
              labelText: 'Custom flavor text',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
            onChanged: noFlavorText ? null : _onCustomChanged,
            onEditingComplete: noFlavorText ? null : _flushCustomText,
            onTapOutside: noFlavorText ? null : (_) => _flushCustomText(),
          ),
        ],
      ),
    );
  }
}
