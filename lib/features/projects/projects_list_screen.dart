import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';

class ProjectsListScreen extends ConsumerWidget {
  const ProjectsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(projectRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/projects/create'),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: StreamBuilder(
        stream: repo.watchProjects(),
        builder: (context, snapshot) {
          final allProjects = snapshot.data ?? const [];
          final basicsId = switch (ref.watch(basicsProjectIdProvider)) {
            AsyncData(:final value) => value,
            _ => null,
          };
          final framesId = switch (ref.watch(globalFramesProjectIdProvider)) {
            AsyncData(:final value) => value,
            _ => null,
          };
          final hiddenIds = <int>{if (basicsId != null) basicsId, if (framesId != null) framesId};
          final projects = hiddenIds.isNotEmpty
              ? allProjects.where((p) => !hiddenIds.contains(p.id)).toList()
              : allProjects;
          if (projects.isEmpty) {
            return const Center(child: Text('No projects yet.'));
          }

          return ListView.separated(
            itemCount: projects.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = projects[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text('Created: ${p.createdAt.toLocal()}'),
                onTap: () => context.go('/projects/${p.id}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete project?'),
                        content: const Text(
                          'This permanently deletes the project and all downloaded artwork files.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    final storage = ref.read(storagePathsProvider);

                    // delete folder first
                    await storage.deleteProjectDir(p.id);

                    // then delete DB
                    await repo.deleteProject(p.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

