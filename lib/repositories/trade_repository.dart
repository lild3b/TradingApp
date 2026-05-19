import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/daos/trade_dao.dart';
import '../models/trade.dart';

class TradeRepository {
  TradeRepository({required TradeDao dao}) : _dao = dao;

  final TradeDao _dao;

  Future<List<Trade>> getTradesByUser(String userId) async {
    final rows = await _dao.getTradesByUser(userId);
    return rows.map(_fromRow).toList();
  }

  Future<List<Trade>> getTradesByDate(String userId, DateTime date) async {
    final rows = await _dao.getTradesByDate(userId, date);
    return rows.map(_fromRow).toList();
  }

  Future<List<Trade>> getTradesByMonth(
      String userId, int year, int month) async {
    final rows = await _dao.getTradesByMonth(userId, year, month);
    return rows.map(_fromRow).toList();
  }

  Future<Trade?> getTradeById(String id) async {
    final row = await _dao.getTradeById(id);
    return row != null ? _fromRow(row) : null;
  }

  Future<void> insertTrade(Trade trade) async {
    await _dao.insertTrade(_toCompanion(trade));
  }

  Future<void> updateTrade(Trade trade) async {
    await _dao.updateTrade(_toCompanion(trade));
  }

  Future<void> deleteTrade(String id) async {
    await _dao.deleteTrade(id);
  }

  Trade _fromRow(TradeRow r) => Trade(
        id: r.id,
        userId: r.userId,
        dateTimeTaken: r.dateTimeTaken,
        market: r.market,
        positionType:
            r.positionType == 'short' ? PositionType.short : PositionType.long,
        entryPrice: r.entryPrice,
        exitPrice: r.exitPrice,
        pnl: r.pnl,
        riskAmount: r.riskAmount,
        rewardAmount: r.rewardAmount,
        entryStrategy: r.entryStrategy,
        tags: List<String>.from(jsonDecode(r.tags)),
        comments: r.comments,
        rulesFollowed: _parseRulesFollowed(r.rulesFollowed),
        entryImagePath: r.entryImagePath,
        resultImagePath: r.resultImagePath,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  TradesTableCompanion _toCompanion(Trade t) => TradesTableCompanion(
        id: Value(t.id),
        userId: Value(t.userId),
        dateTimeTaken: Value(t.dateTimeTaken),
        market: Value(t.market),
        positionType:
            Value(t.positionType == PositionType.short ? 'short' : 'long'),
        entryPrice: Value(t.entryPrice),
        exitPrice: Value(t.exitPrice),
        pnl: Value(t.pnl),
        riskAmount: Value(t.riskAmount),
        rewardAmount: Value(t.rewardAmount),
        entryStrategy: Value(t.entryStrategy),
        tags: Value(jsonEncode(t.tags)),
        comments: Value(t.comments),
        rulesFollowed: Value(_rulesFollowedToString(t.rulesFollowed)),
        entryImagePath: Value(t.entryImagePath),
        resultImagePath: Value(t.resultImagePath),
        createdAt: Value(t.createdAt),
        updatedAt: Value(t.updatedAt),
      );

  RulesFollowed _parseRulesFollowed(String s) {
    switch (s) {
      case 'partial':
        return RulesFollowed.partial;
      case 'no':
        return RulesFollowed.no;
      default:
        return RulesFollowed.yes;
    }
  }

  String _rulesFollowedToString(RulesFollowed r) {
    switch (r) {
      case RulesFollowed.partial:
        return 'partial';
      case RulesFollowed.no:
        return 'no';
      case RulesFollowed.yes:
        return 'yes';
    }
  }
}
