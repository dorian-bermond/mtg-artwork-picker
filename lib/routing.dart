import 'package:go_router/go_router.dart';

import 'features/projects/projects_list_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/projects/create_project_screen.dart';
import 'features/project_home/project_home_screen.dart';
import 'features/project_home/download_screen.dart';
import 'features/project_home/cards_grid_screen.dart';
import 'features/project_home/card_detail_screen.dart';
import 'features/project_home/export_screen.dart';
import 'features/project_home/artwork_fullscreen_screen.dart';
import 'features/project_home/frame_selection_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const ProjectsListScreen(),
        routes: [
          GoRoute(
            path: 'projects/create',
            builder: (_, __) => const CreateProjectScreen(),
          ),
          GoRoute(
            path: '/projects/:projectId/edit',
            builder: (context, state) {
              final projectId = int.parse(state.pathParameters['projectId']!);
              return CreateProjectScreen(projectId: projectId);
            },
          ),
          GoRoute(
            path: 'projects/:projectId',
            builder: (_, state) => ProjectHomeScreen(
              projectId: int.parse(state.pathParameters['projectId']!),
            ),
            routes: [
              GoRoute(
                path: 'download',
                builder: (_, state) => DownloadScreen(
                  projectId: int.parse(state.pathParameters['projectId']!),
                ),
              ),
              GoRoute(
                path: 'cards',
                builder: (_, state) => CardsGridScreen(
                  projectId: int.parse(state.pathParameters['projectId']!),
                ),
              ),
              GoRoute(
                path: 'cards/:cardId',
                builder: (_, state) => CardDetailScreen(
                  projectId: int.parse(state.pathParameters['projectId']!),
                  cardId: int.parse(state.pathParameters['cardId']!),
                ),
                routes: [
                  GoRoute(
                    path: 'artworks/view',
                    builder: (context, state) {
                      final projectId = int.parse(
                        state.pathParameters['projectId']!,
                      );
                      final cardId = int.parse(state.pathParameters['cardId']!);

                      final initialIndex =
                          int.tryParse(
                            state.uri.queryParameters['index'] ?? '0',
                          ) ??
                          0;

                      final title =
                          state.uri.queryParameters['title'] ?? 'Artwork';
                      final showDiscarded =
                          (state.uri.queryParameters['showDiscarded'] ?? '0') ==
                          '1';

                      return ArtworkFullscreenScreen(
                        projectId: projectId,
                        cardId: cardId,
                        initialIndex: initialIndex,
                        title: title,
                        showDiscarded: showDiscarded,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'export',
                builder: (_, state) => ExportScreen(
                  projectId: int.parse(state.pathParameters['projectId']!),
                ),
              ),
              GoRoute(
                path: 'frames',
                builder: (_, state) => FrameSelectionScreen(
                  projectId: int.parse(state.pathParameters['projectId']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
