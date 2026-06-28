import '../../core/normalize.dart';
import '../db/app_database.dart';
import '../db/daos.dart';

class CardRepository {
  final AppDatabase db;
  CardRepository(this.db);

  Stream<int> watchTotal(int projectId) =>
      db.cardsDao.watchTotalCount(projectId);
  Stream<int> watchChecked(int projectId) =>
      db.cardsDao.watchCheckedCount(projectId);

  Stream<List<Card>> watchCards(int projectId, CardFilter filter) =>
      db.cardsDao.watchCards(projectId, filter: filter);

  Future<void> insertCardsFromLines(int projectId, List<String> lines) async {
    final cleaned = lines
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final items = cleaned
        .map((name) => (name, normalizeCardName(name)))
        .toList();
    await db.cardsDao.insertCardsBulk(projectId, items);
  }
}
