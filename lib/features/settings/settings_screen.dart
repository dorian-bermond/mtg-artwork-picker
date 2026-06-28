import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/daos.dart';
import '../../providers/providers.dart';

const _kLanguages = [
  ('en', 'English'),
  ('fr', 'French'),
  ('de', 'German'),
  ('it', 'Italian'),
  ('es', 'Spanish'),
  ('pt', 'Portuguese'),
  ('ja', '日本語'),
  ('ko', '한국어'),
  ('ru', 'Русский'),
  ('zhs', '中文 (简)'),
  ('zht', '中文 (繁)'),
  ('ph', 'Phyrexian'),
];

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Set<String> _selectedLangs = const {'en'};
  String _defaultLang = 'en';
  bool _defaultVersionNewest = true;
  int? _basicsProjectId;
  int? _globalFramesProjectId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dao = ref.read(globalSettingsDaoProvider);
    final results = await Future.wait([
      dao.getPreferredLanguages(),
      dao.getOrCreateBasicsProjectId(),
      dao.getOrCreateGlobalFramesProjectId(),
      dao.getDefaultLanguage(),
      dao.getDefaultVersionNewest(),
    ]);
    if (mounted) {
      setState(() {
        _selectedLangs = Set<String>.from(results[0] as List<String>);
        _basicsProjectId = results[1] as int;
        _globalFramesProjectId = results[2] as int;
        _defaultLang = results[3] as String;
        _defaultVersionNewest = results[4] as bool;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Theme ─────────────────────────────────────────────────
                _sectionHeader(context, Icons.palette_outlined, 'Theme'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('Auto'),
                      ),
                    ],
                    selected: {
                      switch (ref.watch(themeModeProvider)) {
                        AsyncData(:final value) => value,
                        _ => ThemeMode.system,
                      }
                    },
                    onSelectionChanged: (s) =>
                        ref.read(themeModeProvider.notifier).setMode(s.first),
                  ),
                ),

                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 16),

                // ── Languages ─────────────────────────────────────────────
                _sectionHeader(context, Icons.language, 'Card Languages'),
                const SizedBox(height: 4),
                Text(
                  'Cards will be fetched in these languages. English is always included.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _kLanguages.map((entry) {
                    final code = entry.$1;
                    final label = entry.$2;
                    final isSelected = _selectedLangs.contains(code);
                    final isEn = code == 'en';
                    return FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: isEn
                          ? null
                          : (v) async {
                              setState(() {
                                if (v) {
                                  _selectedLangs.add(code);
                                } else {
                                  _selectedLangs.remove(code);
                                }
                              });
                              await ref
                                  .read(globalSettingsDaoProvider)
                                  .setPreferredLanguages(
                                    _selectedLangs.toList(),
                                  );
                            },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 16),

                // ── Version Defaults ──────────────────────────────────────
                _sectionHeader(context, Icons.tune, 'Version Defaults'),
                const SizedBox(height: 4),
                Text(
                  'When you star an artwork, these settings auto-select the matching version.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(child: Text('Default language')),
                    DropdownButton<String>(
                      value: _selectedLangs.contains(_defaultLang)
                          ? _defaultLang
                          : _selectedLangs.first,
                      items: _selectedLangs.map((code) {
                        final label = _kLanguages
                            .firstWhere(
                              (l) => l.$1 == code,
                              orElse: () => (code, code),
                            )
                            .$2;
                        return DropdownMenuItem(
                          value: code,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (v) async {
                        if (v == null) return;
                        setState(() => _defaultLang = v);
                        await ref
                            .read(globalSettingsDaoProvider)
                            .setDefaultLanguage(v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(child: Text('Default version')),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Oldest')),
                        ButtonSegment(value: true, label: Text('Newest')),
                      ],
                      selected: {_defaultVersionNewest},
                      onSelectionChanged: (s) async {
                        final v = s.first;
                        setState(() => _defaultVersionNewest = v);
                        await ref
                            .read(globalSettingsDaoProvider)
                            .setDefaultVersionNewest(v);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 16),

                // ── Global Basics ─────────────────────────────────────────
                _sectionHeader(
                  context,
                  Icons.auto_awesome_mosaic_outlined,
                  'Default Artworks',
                ),
                const SizedBox(height: 4),
                Text(
                  'Artworks for these cards are shared across all projects. '
                  'When you add one to a new project, its artwork and settings '
                  'are copied automatically.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                if (_basicsProjectId != null) ...[
                  _BasicsCardList(projectId: _basicsProjectId!),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.go('/projects/$_basicsProjectId'),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text('Manage Basics'),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 16),

                // ── Default Frames ────────────────────────────────────────
                _sectionHeader(
                  context,
                  Icons.style_outlined,
                  'Default Frames',
                ),
                const SizedBox(height: 4),
                Text(
                  'Applied to new projects when they are created. '
                  'Changing this will not affect existing projects.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                if (_globalFramesProjectId != null) ...[
                  _GlobalFramesSummary(projectId: _globalFramesProjectId!),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await context.push(
                              '/projects/$_globalFramesProjectId/frames',
                            );
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Default Frames'),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

// Shows the list of basics cards (name + checked state)
class _BasicsCardList extends ConsumerWidget {
  final int projectId;
  const _BasicsCardList({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(dbProvider);
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: db.cardsDao.watchCards(
        projectId,
        filter: CardFilter.all,
      ),
      builder: (context, snap) {
        final allCards = snap.data ?? [];
        if (allCards.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (int i = 0; i < allCards.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ListTile(
                  dense: true,
                  leading: Icon(
                    allCards[i].isUpToDate == true
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: allCards[i].isUpToDate == true
                        ? cs.primary
                        : cs.outlineVariant,
                  ),
                  title: Text(allCards[i].name),
                  subtitle: allCards[i].isUpToDate == true
                      ? null
                      : Text(
                          'Not downloaded yet',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Shows a summary of the current global frame defaults
class _GlobalFramesSummary extends ConsumerWidget {
  final int projectId;
  const _GlobalFramesSummary({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final db = ref.read(dbProvider);

    return FutureBuilder(
      future: Future.wait([
        db.projectsDao.getLayoutFrames(projectId),
        db.projectsDao.getTypeFrames(projectId),
      ]),
      builder: (context, snap) {
        if (snap.hasError) {
          return Text(
            'Error: ${snap.error}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.error,
                ),
          );
        }
        final layoutFrames = snap.data?[0] ?? <String, String>{};
        final typeFrames = snap.data?[1] ?? <String, String>{};

        if (layoutFrames.isEmpty && typeFrames.isEmpty) {
          return Text(
            'No defaults set yet.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              for (final e in layoutFrames.entries)
                _FrameRow(label: e.key, frame: e.value, cs: cs),
              for (final e in typeFrames.entries)
                _FrameRow(label: e.key, frame: e.value, cs: cs),
            ],
          ),
        );
      },
    );
  }
}

class _FrameRow extends StatelessWidget {
  final String label;
  final String frame;
  final ColorScheme cs;
  const _FrameRow({required this.label, required this.frame, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            frame,
            style: TextStyle(color: cs.primary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
