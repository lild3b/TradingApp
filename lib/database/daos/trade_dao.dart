import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'trade_dao.g.dart';

@DriftAccessor(tables: [TradesTable])
class TradeDao extends DatabaseAccessor<AppDatabase> with _$TradeDaoMixin {
  TradeDao(super.db);

  Future<List<TradeRow>> getTradesByUser(String userId) =>
      (select(tradesTable)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.dateTimeTaken)]))
          .get();

  Stream<List<TradeRow>> watchTradesByUser(String userId) =>
      (select(tradesTable)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.dateTimeTaken)]))
          .watch();

  Future<List<TradeRow>> getTradesByDate(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(tradesTable)
          ..where((t) =>
              t.userId.equals(userId) &
              t.dateTimeTaken.isBiggerOrEqualValue(start) &
              t.dateTimeTaken.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.dateTimeTaken)]))
        .get();
  }

  Future<List<TradeRow>> getTradesByMonth(String userId, int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (select(tradesTable)
          ..where((t) =>
              t.userId.equals(userId) &
              t.dateTimeTaken.isBiggerOrEqualValue(start) &
              t.dateTimeTaken.isSmallerThanValue(end)))
        .get();
  }

  Future<TradeRow?> getTradeById(String id) =>
      (select(tradesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTrade(TradesTableCompanion entry) =>
      into(tradesTable).insert(entry);

  Future<bool> updateTrade(TradesTableCompanion entry) =>
      update(tradesTable).replace(entry);

  Future<int> deleteTrade(String id) =>
      (delete(tradesTable)..where((t) => t.id.equals(id))).go();

  Future<int> deleteTradesByUser(String userId) =>
      (delete(tradesTable)..where((t) => t.userId.equals(userId))).go();
}
