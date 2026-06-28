import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StoragePaths {
  Future<Directory> appDocDir() async => getApplicationDocumentsDirectory();

  Future<Directory> projectsRootDir() async {
    final base = await appDocDir();
    final dir = Directory(p.join(base.path, 'projects'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> projectDir(int projectId) async {
    final root = await projectsRootDir();
    final dir = Directory(p.join(root.path, 'project_$projectId'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> projectImagesDir(int projectId) async {
    final base = await projectDir(projectId);
    final dir = Directory(p.join(base.path, 'images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> projectThumbsDir(int projectId) async {
    final base = await projectDir(projectId);
    final dir = Directory(p.join(base.path, 'thumbs'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> projectLogFile(int projectId) async {
    final dir = await projectDir(projectId);
    return File(p.join(dir.path, 'download_log.txt'));
  }

  Future<void> deleteProjectDir(int projectId) async {
    final dir = await projectDir(projectId);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
