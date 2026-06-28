/// A single downloadable artwork returned by an [ArtworkSource].
class SourcedArtwork {
  final String remoteId;
  final String imageUrl;
  final String artist;
  final String? referer;

  const SourcedArtwork({
    required this.remoteId,
    required this.imageUrl,
    required this.artist,
    this.referer,
  });
}

/// Implement this to plug in a new artwork source to the fallback chain.
/// The pipeline tries each source in order and stops at the first that
/// returns at least one artwork.
abstract class ArtworkSource {
  /// Identifier stored in the DB as [Artworks.sourceProviderId].
  String get providerId;

  /// Returns artworks for [faceName], or null if this source has nothing.
  /// [printings] is the list of raw Scryfall card objects.
  /// [faceIndex] selects the correct DFC face (0 = front / single-face).
  Future<List<SourcedArtwork>?> tryFetch({
    required String faceName,
    required List<Map<String, dynamic>> printings,
    required int faceIndex,
  });

  /// Downloads the image bytes for [artwork].
  Future<(List<int> bytes, String contentType)> downloadImage(
    SourcedArtwork artwork,
  );
}
