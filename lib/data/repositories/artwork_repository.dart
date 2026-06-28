import 'package:drift/drift.dart'; // <-- IMPORTANT
import '../db/app_database.dart';

class ArtworkRepository {
  final AppDatabase db;
  ArtworkRepository(this.db);

  Future<int> countArtistOccurrencesForCard(int cardId, String artist) async {
    final rows =
        await (db.select(db.artworks)..where(
              (t) => Expression.and([
                t.cardId.equals(cardId),
                t.artist.equals(artist),
              ]),
            ))
            .get();
    return rows.length;
  }
}
