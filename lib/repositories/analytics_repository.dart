import '../models/analytics_data.dart';
import '../models/monthly_stats.dart';
import '../models/trade.dart';
import '../models/user_profile.dart';
import 'trade_repository.dart';

class AnalyticsRepository {
  AnalyticsRepository({required TradeRepository tradeRepository})
      : _tradeRepo = tradeRepository;

  final TradeRepository _tradeRepo;

  Future<AnalyticsData> computeAnalytics(UserProfile profile) async {
    final trades = await _tradeRepo.getTradesByUser(profile.id);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final wins = trades.where((t) => t.pnl > 0).toList();
    final losses = trades.where((t) => t.pnl < 0).toList();

    final winRate = trades.isEmpty ? 0.0 : (wins.length / trades.length) * 100;

    final avgProfit =
        wins.isEmpty ? 0.0 : wins.fold(0.0, (s, t) => s + t.pnl) / wins.length;

    final avgLoss = losses.isEmpty
        ? 0.0
        : (losses.fold(0.0, (s, t) => s + t.pnl) / losses.length).abs();

    final dailyTrades =
        trades.where((t) => t.dateTimeTaken.isAfter(todayStart)).toList();
    final dailyProfit = dailyTrades.fold(0.0, (s, t) => s + t.pnl);

    // Compute equity as balance + all-time PnL
    final totalPnl = trades.fold(0.0, (s, t) => s + t.pnl);
    final equity = profile.balance + totalPnl;

    final totalWins = wins.fold(0.0, (s, t) => s + t.pnl);
    final totalLosses = losses.fold(0.0, (s, t) => s + t.pnl.abs());
    final profitFactor = totalLosses > 0 ? totalWins / totalLosses : 0.0;

    final dailyPermittedLoss =
        profile.balance * profile.dailyPermittedLossPercent / 100;
    final maxPermittedLoss =
        profile.balance * profile.maxPermittedLossPercent / 100;

    // Prop firm warning level
    PropFirmWarningLevel warningLevel = PropFirmWarningLevel.none;
    if (profile.accountType == AccountType.propFirm) {
      final dailyLoss = dailyProfit < 0 ? dailyProfit.abs() : 0.0;
      final totalLoss = totalPnl < 0 ? totalPnl.abs() : 0.0;

      if (dailyLoss >= dailyPermittedLoss) {
        warningLevel = PropFirmWarningLevel.red;
      } else if (totalLoss >= maxPermittedLoss * 0.8) {
        warningLevel = PropFirmWarningLevel.orange;
      } else if (dailyLoss >= dailyPermittedLoss * 0.7) {
        warningLevel = PropFirmWarningLevel.yellow;
      }
    }

    // Last 30 days PnL
    final last30 = _buildLast30DaysPnl(trades);

    return AnalyticsData(
      balance: profile.balance,
      equity: equity,
      winRate: winRate,
      avgProfit: avgProfit,
      avgLoss: avgLoss,
      totalTrades: trades.length,
      dailyPermittedLoss: dailyPermittedLoss,
      maxPermittedLoss: maxPermittedLoss,
      dailyProfit: dailyProfit,
      profitFactor: profitFactor,
      propFirmWarningLevel: warningLevel,
      last30DaysPnl: last30,
    );
  }

  List<MapEntry<DateTime, double>> _buildLast30DaysPnl(List<Trade> trades) {
    final now = DateTime.now();
    final entries = <MapEntry<DateTime, double>>[];
    for (int i = 29; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final dayEnd = day.add(const Duration(days: 1));
      final dayTrades = trades.where((t) =>
          t.dateTimeTaken.isAfter(day) && t.dateTimeTaken.isBefore(dayEnd));
      final pnl = dayTrades.fold(0.0, (s, t) => s + t.pnl);
      entries.add(MapEntry(day, pnl));
    }
    return entries;
  }

  Future<MonthlyStats> computeMonthlyStats(
      String userId, int year, int month) async {
    final trades = await _tradeRepo.getTradesByMonth(userId, year, month);

    // Group by day
    final Map<String, double> dayPnl = {};
    for (final t in trades) {
      final key =
          '${t.dateTimeTaken.year}-${t.dateTimeTaken.month}-${t.dateTimeTaken.day}';
      dayPnl[key] = (dayPnl[key] ?? 0) + t.pnl;
    }

    final values = dayPnl.values.toList();
    final totalPnl = values.fold(0.0, (s, v) => s + v);
    final bestDay =
        values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final worstDay =
        values.isEmpty ? 0.0 : values.reduce((a, b) => a < b ? a : b);
    final winDays = values.where((v) => v > 0).length;
    final winRate = values.isEmpty ? 0.0 : winDays / values.length * 100;

    return MonthlyStats(
      totalTradingDays: dayPnl.length,
      totalPnl: totalPnl,
      bestDay: bestDay,
      worstDay: worstDay,
      winRate: winRate,
    );
  }

  Future<Map<DateTime, double>> getDailyPnlMap(
      String userId, int year, int month) async {
    final trades = await _tradeRepo.getTradesByMonth(userId, year, month);
    final Map<DateTime, double> map = {};
    for (final t in trades) {
      final day = DateTime(
          t.dateTimeTaken.year, t.dateTimeTaken.month, t.dateTimeTaken.day);
      map[day] = (map[day] ?? 0) + t.pnl;
    }
    return map;
  }

  Future<Map<DateTime, int>> getDailyTradeCountMap(
      String userId, int year, int month) async {
    final trades = await _tradeRepo.getTradesByMonth(userId, year, month);
    final Map<DateTime, int> map = {};
    for (final t in trades) {
      final day = DateTime(
          t.dateTimeTaken.year, t.dateTimeTaken.month, t.dateTimeTaken.day);
      map[day] = (map[day] ?? 0) + 1;
    }
    return map;
  }
}
