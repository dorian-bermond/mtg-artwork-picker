import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../data/db/daos.dart';
import '../../data/db/app_database.dart' as db;

class CardsGridScreen extends ConsumerStatefulWidget {
  final int projectId;
  const CardsGridScreen({super.key, required this.projectId});

  @override
  ConsumerState<CardsGridScreen> createState() => _CardsGridScreenState();
}

class _CardsGridScreenState extends ConsumerState<CardsGridScreen> {
  CardFilter _filter = CardFilter.all;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _layoutFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardRepo = ref.read(cardRepoProvider);
    final database = ref.read(dbProvider);
    final thumbPath = ref.read(thumbPathProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards'),
        actions: [
          StreamBuilder<int>(
            stream: cardRepo.watchChecked(widget.projectId),
            builder: (context, checkedSnap) {
              final checked = checkedSnap.data ?? 0;
              return StreamBuilder<int>(
                stream: cardRepo.watchTotal(widget.projectId),
                builder: (context, totalSnap) {
                  final total = totalSnap.data ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(child: Text('$checked/$total')),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search cards…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                StreamBuilder<List<String>>(
                  stream: database.cardsDao
                      .watchDistinctLayoutsForProject(widget.projectId),
                  builder: (context, layoutSnap) {
                    final layouts = layoutSnap.data ?? [];
                    if (layouts.isEmpty) return const SizedBox.shrink();
                    return DropdownButton<String?>(
                      value: _layoutFilter,
                      hint: const Text('Layout'),
                      isDense: true,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All layouts'),
                        ),
                        ...layouts.map(
                          (l) => DropdownMenuItem(value: l, child: Text(l)),
                        ),
                      ],
                      onChanged: (v) => setState(() => _layoutFilter = v),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == CardFilter.all,
                onSelected: (_) => setState(() => _filter = CardFilter.all),
              ),
              ChoiceChip(
                label: const Text('Complete'),
                selected: _filter == CardFilter.checked,
                onSelected: (_) => setState(() => _filter = CardFilter.checked),
              ),
              ChoiceChip(
                label: const Text('Partial'),
                selected: _filter == CardFilter.partial,
                onSelected: (_) => setState(() => _filter = CardFilter.partial),
              ),
              ChoiceChip(
                label: const Text('Unchecked'),
                selected: _filter == CardFilter.unchecked,
                onSelected: (_) =>
                    setState(() => _filter = CardFilter.unchecked),
              ),
              ChoiceChip(
                label: const Text('Up to date'),
                selected: _filter == CardFilter.upToDate,
                onSelected: (_) =>
                    setState(() => _filter = CardFilter.upToDate),
              ),
              ChoiceChip(
                label: const Text('Pending'),
                selected: _filter == CardFilter.pending,
                onSelected: (_) =>
                    setState(() => _filter = CardFilter.pending),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<Map<int, String?>>(
              stream: database.cardsDao
                  .watchLayoutMapForProject(widget.projectId),
              builder: (context, layoutMapSnap) {
                final layoutMap = layoutMapSnap.data ?? {};
                return StreamBuilder<List<db.Card>>(
                  stream: cardRepo.watchCards(widget.projectId, _filter),
                  builder: (context, snapshot) {
                    final allCards = snapshot.data ?? const [];
                    final query = _searchQuery.trim().toLowerCase();
                    final lf = _layoutFilter;
                    final cards = allCards.where((c) {
                      if (query.isNotEmpty &&
                          !c.name.toLowerCase().contains(query)) return false;
                      if (lf != null && layoutMap[c.id] != lf) return false;
                      return true;
                    }).toList();
                    if (cards.isEmpty) {
                      return const Center(child: Text('No cards found.'));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: cards.length,
                      itemBuilder: (context, i) {
                        final c = cards[i];
                        final setSelected =
                            c.selectedSetCode != null ||
                            c.selectedSetIsVoid;
                        final hasArtwork = c.preferredArtworkId != null;
                        final isComplete = hasArtwork && setSelected;
                        final isPartial = hasArtwork ^ setSelected;

                        return InkWell(
                          onTap: () => context.push(
                            '/projects/${widget.projectId}/cards/${c.id}',
                          ),
                          child: Stack(
                            children: [
                              // pending indicator (top-right): shown when the
                              // pipeline has not yet run successfully for this card
                              if (c.isUpToDate != true)
                                const Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Icon(
                                    Icons.schedule,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ),
                              Card(
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: FutureBuilder<db.Artwork?>(
                                        future: database.artworksDao
                                            .getPreferredOrFirstArtworkForCard(
                                              c.id,
                                              c.preferredArtworkId,
                                            ),
                                        builder: (context, artSnap) {
                                          final art = artSnap.data;
                                          if (art == null) {
                                            return Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_outlined,
                                                ),
                                              ),
                                            );
                                          }

                                          return FutureBuilder<String>(
                                            future: thumbPath.thumbForOriginal(
                                              projectId: widget.projectId,
                                              originalPath: art.localPath,
                                            ),
                                            builder: (context, thumbSnap) {
                                              final tp = thumbSnap.data;
                                              if (tp == null) {
                                                return Container(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainerHighest,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              }

                                              return Image.file(
                                                File(tp),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) {
                                                  return Container(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainerHighest,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons
                                                            .broken_image_outlined,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        c.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (isComplete)
                                const Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                )
                              else if (isPartial)
                                const Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.orange,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
