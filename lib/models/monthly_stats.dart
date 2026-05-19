import 'package:equatable/equatable.dart';

class MonthlyStats extends Equatable {
  const MonthlyStats({
    required this.totalTradingDays,
    required this.totalPnl,
    required this.bestDay,
    required this.worstDay,
    required this.winRate,
  });

  final int totalTradingDays;
  final double totalPnl;
  final double bestDay;
  final double worstDay;
  final double winRate;

  static const MonthlyStats empty = MonthlyStats(
    totalTradingDays: 0,
    totalPnl: 0,
    bestDay: 0,
    worstDay: 0,
    winRate: 0,
  );

  @override
  List<Object?> get props => [totalTradingDays, totalPnl, bestDay, worstDay, winRate];
}
