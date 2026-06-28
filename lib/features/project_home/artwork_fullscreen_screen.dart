import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../providers/providers.dart';
import '../../data/db/app_database.dart' as db;

class ArtworkFullscreenScreen extends ConsumerStatefulWidget {
  final int projectId;
  final int cardId;
  final int initialIndex;
  final String title;
  final bool showDiscarded;

  const ArtworkFullscreenScreen({
    super.key,
    required this.projectId,
    required this.cardId,
    required this.initialIndex,
    required this.title,
    required this.showDiscarded,
  });

  @override
  ConsumerState<ArtworkFullscreenScreen> createState() =>
      _ArtworkFullscreenScreenState();
}

class _ArtworkFullscreenScreenState
    extends ConsumerState<ArtworkFullscreenScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.read(dbProvider);
    final discard = ref.read(discardServiceProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: StreamBuilder<List<db.Artwork>>(
        stream: database.artworksDao.watchArtworksForCard(
          widget.cardId,
          includeDiscarded: widget.showDiscarded,
        ),
        builder: (context, snap) {
          final arts = snap.data ?? const [];
          if (arts.isEmpty) {
            return const Center(
              child: Text('No artworks', style: TextStyle(color: Colors.white)),
            );
          }

          // Keep current index in range if list changes.
          final safeIndex = _currentIndex.clamp(0, arts.length - 1);
          if (safeIndex != _currentIndex) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _currentIndex = safeIndex);
              if (_pageController.hasClients) {
                _pageController.jumpToPage(safeIndex);
              }
            });
          }

          return StreamBuilder<db.Card>(
            stream: (database.select(
              database.cards,
            )..where((t) => t.id.equals(widget.cardId))).watchSingle(),
            builder: (context, cardSnap) {
              final card = cardSnap.data;

              final currentIndex = _currentIndex.clamp(0, arts.length - 1);
              final current = arts[currentIndex];

              final counterText = '${currentIndex + 1} / ${arts.length}';
              final artistText = (current.artist ?? '').trim();

              final isPreferred = (card?.preferredArtworkId == current.id);
              final canAct = !current.isDiscarded;

              return Stack(
                children: [
                  PhotoViewGallery.builder(
                    pageController: _pageController,
                    itemCount: arts.length,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    builder: (context, index) {
                      final file = File(arts[index].localPath);

                      return PhotoViewGalleryPageOptions.customChild(
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 3.0,
                        child: FutureBuilder<bool>(
                          future: file.exists(),
                          builder: (context, existsSnap) {
                            final exists = existsSnap.data ?? false;
                            if (!exists) {
                              return const Center(
                                child: Text(
                                  'File not found',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                            return Image.file(
                              file,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loadingBuilder: (context, event) {
                      final value =
                          (event == null || event.expectedTotalBytes == null)
                          ? null
                          : (event.cumulativeBytesLoaded /
                                event.expectedTotalBytes!);
                      return Center(
                        child: CircularProgressIndicator(value: value),
                      );
                    },
                  ),

                  // Top-right actions (favorite + discard)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: SafeArea(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filledTonal(
                            tooltip: isPreferred
                                ? 'Preferred artwork'
                                : 'Set as preferred',
                            onPressed: canAct
                                ? () async {
                                    final newValue = isPreferred
                                        ? null
                                        : current.id; // toggle
                                    await database.cardsDao.setPreferredArtwork(
                                      widget.cardId,
                                      newValue,
                                    );
                                  }
                                : null,
                            icon: Icon(
                              isPreferred ? Icons.star : Icons.star_border,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            tooltip: current.isDiscarded
                                ? 'Discarded'
                                : 'Discard artwork',
                            onPressed: canAct
                                ? () async {
                                    final ok =
                                        await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                              'Discard this artwork?',
                                            ),
                                            content: const Text(
                                              'This will remove it from normal selection (it can be restored later).',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              FilledButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(true),
                                                child: const Text('Discard'),
                                              ),
                                            ],
                                          ),
                                        ) ??
                                        false;

                                    if (!ok) return;

                                    await discard.discardArtwork(
                                      projectId: widget.projectId,
                                      artworkId: current.id,
                                    );

                                    if (card?.preferredArtworkId ==
                                        current.id) {
                                      await database.cardsDao
                                          .setPreferredArtwork(
                                            widget.cardId,
                                            null,
                                          );
                                    }

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Artwork discarded'),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom overlay (counter + optional artist)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: SafeArea(
                      top: false,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Text(
                                counterText,
                                style: const TextStyle(color: Colors.white),
                              ),
                              if (artistText.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                const Expanded(child: SizedBox()),
                                Flexible(
                                  child: Text(
                                    artistText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
