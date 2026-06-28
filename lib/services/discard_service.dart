import '../data/db/app_database.dart';
import 'image_store.dart';
import '../core/thumb_path.dart';

class DiscardService {
  final AppDatabase db;
  final ImageStore imageStore;
  final ThumbPath thumbPath;

  DiscardService({
    required this.db,
    required this.imageStore,
    required this.thumbPath,
  });

  Future<void> discardArtwork({
    required int projectId,
    required int artworkId,
  }) async {
    final art = await db.artworksDao.getById(artworkId);
    if (art == null) return;

    // delete original
    await imageStore.deleteFileIfExists(art.localPath);

    // delete thumb
    final thumb = await thumbPath.thumbForOriginal(
      projectId: projectId,
      originalPath: art.localPath,
    );
    await imageStore.deleteFileIfExists(thumb);

    // mark discarded
    await db.artworksDao.markDiscarded(artworkId, true);
  }
}
