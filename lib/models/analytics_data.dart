import 'package:equatable/equatable.dart';

enum PropFirmWarningLevel { none, yellow, orange, red }

class AnalyticsData extends Equatable {
  const AnalyticsData({
    required this.balance,
    required this.equity,
    required this.winRate,
    required this.avgProfit,
    required this.avgLoss,
    required this.totalTrades,
    required this.dailyPermittedLoss,
    required this.maxPermittedLoss,
    required this.dailyProfit,
    required this.profitFactor,
    required this.propFirmWarningLevel,
    required this.last30DaysPnl,
  });

  final double balance;
  final double equity;
  final double winRate;
  final double avgProfit;
  final double avgLoss;
  final int totalTrades;
  final double dailyPermittedLoss;
  final double maxPermittedLoss;
  final double dailyProfit;
  final double profitFactor;
  final PropFirmWarningLevel propFirmWarningLevel;
  final List<MapEntry<DateTime, double>> last30DaysPnl;

  static const AnalyticsData empty = AnalyticsData(
    balance: 0,
    equity: 0,
    winRate: 0,
    avgProfit: 0,
    avgLoss: 0,
    totalTrades: 0,
    dailyPermittedLoss: 0,
    maxPermittedLoss: 0,
    dailyProfit: 0,
    profitFactor: 0,
    propFirmWarningLevel: PropFirmWarningLevel.none,
    last30DaysPnl: [],
  );

  @override
  List<Object?> get props => [
    balance, equity, winRate, avgProfit, avgLoss, totalTrades,
    dailyPermittedLoss, maxPermittedLoss, dailyProfit, profitFactor,
    propFirmWarningLevel, last30DaysPnl,
  ];
}

class DayPnlSummary extends Equatable {
  const DayPnlSummary({
    required this.date,
    required this.totalPnl,
    required this.tradeCount,
  });

  final DateTime date;
  final double totalPnl;
  final int tradeCount;

  @override
  List<Object?> get props => [date, totalPnl, tradeCount];
}
