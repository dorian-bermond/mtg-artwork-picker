import 'package:path/path.dart' as p;

import 'storage_paths.dart';

class ThumbPath {
  final StoragePaths paths;
  ThumbPath(this.paths);

  Future<String> thumbForOriginal({
    required int projectId,
    required String originalPath,
  }) async {
    final thumbsDir = await paths.projectThumbsDir(projectId);
    final base = p.basenameWithoutExtension(originalPath);
    return p.join(thumbsDir.path, '$base.jpg');
  }
}
