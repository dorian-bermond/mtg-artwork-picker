import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/template_registry.dart';
import '../../providers/providers.dart';
import 'frame_fullscreen_page.dart';

// All layout keys present in any registered template, sorted.
final _allLayouts = (templateRegistry.values
        .expand((info) => info.layouts.keys)
        .toSet()
        .toList()
      ..sort())
    .toList();

// Types used for frame defaults.
// Excluded:
//   - Planeswalker / Battle → covered by their own layout chips (planeswalker / battle)
//   - Phenomenon / Plane   → covered by planar layout
//   - Dungeon / Scheme / Vanguard → never proxied
const _allTypes = [
  'Artifact',
  'Conspiracy',
  'Creature',
  'Enchantment',
  'Instant',
  'Land',
  'Sorcery',
  'Tribal',
];

class FrameSelectionScreen extends ConsumerStatefulWidget {
  final int projectId;
  const FrameSelectionScreen({super.key, required this.projectId});

  @override
  ConsumerState<FrameSelectionScreen> createState() =>
      _FrameSelectionScreenState();
}

class _FrameSelectionScreenState extends ConsumerState<FrameSelectionScreen> {
  String? _selectedFrame;
  final Set<String> _selectedLayouts = {};
  final Set<String> _selectedTypes = {};
  bool _overwriteAll = false;
  bool _applying = false;
  Map<String, String> _layoutFrames = {};
  Map<String, String> _typeFrames = {};

  @override
  void initState() {
    super.initState();
    _loadFrameDefaults();
  }

  Future<void> _loadFrameDefaults() async {
    final db = ref.read(dbProvider);
    final layouts = await db.projectsDao.getLayoutFrames(widget.projectId);
    final types = await db.projectsDao.getTypeFrames(widget.projectId);
    if (mounted) {
      setState(() {
        _layoutFrames = layouts;
        _typeFrames = types;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Frame Selection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Current configuration ───────────────────────────────────────
          Text(
            'Current configuration',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_layoutFrames.isEmpty && _typeFrames.isEmpty)
            Text(
              'No defaults set yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          else ...[
            if (_layoutFrames.isNotEmpty)
              _configTable(context, 'By layout', [
                for (final e in _layoutFrames.entries) (e.key, e.value),
              ]),
            if (_typeFrames.isNotEmpty) ...[
              const SizedBox(height: 8),
              _configTable(context, 'By type', [
                for (final e in _typeFrames.entries) (e.key, e.value),
              ]),
            ],
          ],

          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 16),

          // ── Apply frame ─────────────────────────────────────────────────
          Text(
            'Apply frame',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // Layout chips
          Text(
            'Apply to layout',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          _chipWrap(
            context: context,
            items: _allLayouts,
            selected: _selectedLayouts,
            onTap: (l) => setState(() {
              if (_selectedLayouts.contains(l)) {
                _selectedLayouts.remove(l);
              } else {
                _selectedLayouts.add(l);
                if (_selectedFrame == null && _layoutFrames.containsKey(l)) {
                  _selectedFrame = _layoutFrames[l];
                }
              }
            }),
          ),
          const SizedBox(height: 12),

          // Type chips
          Text(
            'Apply to type',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          _chipWrap(
            context: context,
            items: _allTypes,
            selected: _selectedTypes,
            onTap: (t) => setState(() {
              if (_selectedTypes.contains(t)) {
                _selectedTypes.remove(t);
              } else {
                _selectedTypes.add(t);
                if (_selectedFrame == null && _typeFrames.containsKey(t)) {
                  _selectedFrame = _typeFrames[t];
                }
              }
            }),
          ),
          const SizedBox(height: 12),

          // Frame gallery
          Text(
            'Frame',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          _frameGallery(context),
          const SizedBox(height: 12),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Overwrite custom frames'),
            subtitle: const Text(
              'When off, only cards without a frame are updated.',
            ),
            value: _overwriteAll,
            onChanged: (v) => setState(() => _overwriteAll = v),
          ),
          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: _applying ||
                    _selectedFrame == null ||
                    (_selectedLayouts.isEmpty && _selectedTypes.isEmpty)
                ? null
                : _apply,
            icon: const Icon(Icons.check),
            label: Text(_applying ? 'Applying…' : 'Apply'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _configTable(
    BuildContext context,
    String label,
    List<(String, String)> rows,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          rows[i].$1,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        rows[i].$2,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _chipWrap({
    required BuildContext context,
    required List<String> items,
    required Set<String> selected,
    required void Function(String) onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected.contains(item);
        return GestureDetector(
          onTap: () => onTap(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.check, size: 14, color: cs.primary),
                  ),
                Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? cs.onPrimaryContainer : null,
                        fontWeight:
                            isSelected ? FontWeight.w600 : null,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _frameGallery(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: templateRegistry.entries
          .where((e) => frameCompatible(e.value, _selectedLayouts))
          .map((e) {
        final previewKey = e.value.layouts.containsKey('normal')
            ? 'normal'
            : e.value.layouts.keys.first;
        final previewPath = e.value.layouts[previewKey]!;
        final name = templateFolderName(previewPath);
        final isSelected = _selectedFrame == name;
        return GestureDetector(
          onTap: () => setState(() => _selectedFrame = name),
          onLongPress: () =>
              _showFrameFullscreen(name, e.value.layouts, previewKey),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outlineVariant,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSelected ? 5.5 : 7),
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
                          ),
                      ],
                    ),
                  ),
                  Container(
                    color: isSelected
                        ? cs.primaryContainer
                        : cs.surfaceContainerHighest,
                    padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
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
                                fontWeight:
                                    isSelected ? FontWeight.w600 : null,
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
    );
  }

  void _showFrameFullscreen(
      String frameName, Map<String, String> layouts, String initialKey) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => FrameFullscreenPage(
          frameName: frameName,
          layouts: layouts,
          initialKey: initialKey,
        ),
      ),
    );
  }

  Future<void> _apply() async {
    final frame = _selectedFrame!;
    final selectedLayouts = _selectedLayouts.toList();
    final selectedTypes = _selectedTypes.toList();
    setState(() => _applying = true);
    try {
      final db = ref.read(dbProvider);
      var totalCount = 0;

      if (selectedLayouts.isNotEmpty && selectedTypes.isNotEmpty) {
        // Intersection: only cards matching BOTH a selected layout AND type.
        totalCount += await db.cardsDao.applyFrameToLayoutAndType(
          projectId: widget.projectId,
          layouts: selectedLayouts,
          types: selectedTypes,
          frame: frame,
          overwriteAll: _overwriteAll,
        );
      } else {
        for (final layout in selectedLayouts) {
          totalCount += await db.cardsDao.applyFrameToLayout(
            projectId: widget.projectId,
            layout: layout,
            frame: frame,
            overwriteAll: _overwriteAll,
          );
        }
        for (final type in selectedTypes) {
          totalCount += await db.cardsDao.applyFrameToType(
            projectId: widget.projectId,
            cardType: type,
            frame: frame,
            overwriteAll: _overwriteAll,
          );
        }
      }

      // Always store defaults for all selected layouts and types.
      for (final layout in selectedLayouts) {
        await db.projectsDao.setLayoutFrame(widget.projectId, layout, frame);
      }
      for (final type in selectedTypes) {
        await db.projectsDao.setTypeFrame(widget.projectId, type, frame);
      }

      await _loadFrameDefaults();
      if (!mounted) return;

      final parts = [
        if (selectedLayouts.isNotEmpty)
          selectedLayouts.length == 1
              ? 'layout "${selectedLayouts.first}"'
              : '${selectedLayouts.length} layouts',
        if (selectedTypes.isNotEmpty)
          selectedTypes.length == 1
              ? 'type "${selectedTypes.first}"'
              : '${selectedTypes.length} types',
      ];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$totalCount card(s) updated — ${parts.join(' + ')} → "$frame"',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Apply failed: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }
}
