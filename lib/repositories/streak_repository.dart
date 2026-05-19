import '../models/streak_data.dart';
import 'trade_repository.dart';

class StreakRepository {
  StreakRepository({required TradeRepository tradeRepository})
      : _tradeRepo = tradeRepository;

  final TradeRepository _tradeRepo;

  Future<StreakData> computeStreaks(String userId) async {
    final trades = await _tradeRepo.getTradesByUser(userId);
    if (trades.isEmpty) return StreakData.empty;

    // Build daily PnL map
    final Map<DateTime, double> dailyPnl = {};
    for (final t in trades) {
      final day = DateTime(
          t.dateTimeTaken.year, t.dateTimeTaken.month, t.dateTimeTaken.day);
      dailyPnl[day] = (dailyPnl[day] ?? 0) + t.pnl;
    }

    // Sort days
    final sortedDays = dailyPnl.keys.toList()..sort();

    // Compute streaks
    int currentWin = 0, longestWin = 0;
    int currentLoss = 0, longestLoss = 0;

    // Compute forward
    for (final day in sortedDays) {
      final pnl = dailyPnl[day]!;
      if (pnl > 0) {
        currentWin++;
        currentLoss = 0;
        if (currentWin > longestWin) longestWin = currentWin;
      } else if (pnl < 0) {
        currentLoss++;
        currentWin = 0;
        if (currentLoss > longestLoss) longestLoss = currentLoss;
      } else {
        // zero — don't break streaks but don't add
      }
    }

    // Check if last days break current streak
    final reversedDays = sortedDays.reversed.toList();
    int activeWin = 0, activeLoss = 0;
    for (final day in reversedDays) {
      final pnl = dailyPnl[day]!;
      if (pnl > 0) {
        if (activeLoss > 0) break; // streak broken
        activeWin++;
      } else if (pnl < 0) {
        if (activeWin > 0) break;
        activeLoss++;
      }
    }
    currentWin = activeWin;
    currentLoss = activeLoss;

    // Build last 90 days map
    final now = DateTime.now();
    final Map<DateTime, String> last90 = {};
    for (int i = 89; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final pnl = dailyPnl[day];
      if (pnl == null || pnl == 0) {
        last90[day] = 'none';
      } else if (pnl > 0) {
        last90[day] = 'win';
      } else {
        last90[day] = 'loss';
      }
    }

    return StreakData(
      currentWinStreak: currentWin,
      longestWinStreak: longestWin,
      currentLossStreak: currentLoss,
      longestLossStreak: longestLoss,
      last90DaysMap: last90,
    );
  }
}
