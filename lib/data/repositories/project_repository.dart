import '../db/app_database.dart';
import '../models/provider_id.dart';

class ProjectRepository {
  final AppDatabase db;
  ProjectRepository(this.db);

  Stream<List<Project>> watchProjects() => db.projectsDao.watchProjects();

  Future<int> createProject({
    required String name,
    required List<SourceProviderId> enabledProviders,
  }) async {
    final id = await db.projectsDao.insertProject(name, DateTime.now());
    for (final p in enabledProviders) {
      await db.projectsDao.insertProjectSource(id, p.dbValue);
    }
    return id;
  }

  Future<void> deleteProject(int projectId) =>
      db.projectsDao.deleteProjectById(projectId);
}
