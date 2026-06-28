import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../data/db/app_database.dart' as db;

class ProjectHomeScreen extends ConsumerWidget {
  final int projectId;
  const ProjectHomeScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardRepo = ref.read(cardRepoProvider);
    final database = ref.read(dbProvider);

    return StreamBuilder<db.Project>(
      stream: (database.select(
        database.projects,
      )..where((t) => t.id.equals(projectId))).watchSingle(),
      builder: (context, projectSnap) {
        final project = projectSnap.data;

        return Scaffold(
          appBar: AppBar(title: Text(project?.name ?? 'Project #$projectId')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                StreamBuilder<int>(
                  stream: cardRepo.watchChecked(projectId),
                  builder: (context, checkedSnap) {
                    final checked = checkedSnap.data ?? 0;
                    return StreamBuilder<int>(
                      stream: cardRepo.watchTotal(projectId),
                      builder: (context, totalSnap) {
                        final total = totalSnap.data ?? 0;
                        return ListTile(
                          leading: const Icon(Icons.check_circle_outline),
                          title: const Text('Progress'),
                          subtitle: Text('$checked / $total checked'),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.go('/projects/$projectId/edit'),
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Add cards'),
                ),
                FilledButton.icon(
                  onPressed: () => context.go('/projects/$projectId/download'),
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Fetch Data'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.go('/projects/$projectId/cards'),
                  icon: const Icon(Icons.grid_view),
                  label: const Text('Cards'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.go('/projects/$projectId/frames'),
                  icon: const Icon(Icons.style_outlined),
                  label: const Text('Frames'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.go('/projects/$projectId/export'),
                  icon: const Icon(Icons.archive),
                  label: const Text('Export'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
