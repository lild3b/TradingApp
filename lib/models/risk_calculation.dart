import 'package:equatable/equatable.dart';

class RiskCalculation extends Equatable {
  const RiskCalculation({
    required this.balance,
    required this.riskPercent,
    required this.entryPrice,
    required this.stopLossPrice,
    required this.rewardRatio,
    required this.isLong,
  });

  final double balance;
  final double riskPercent;
  final double entryPrice;
  final double stopLossPrice;
  final double rewardRatio;
  final bool isLong;

  double get dollarRisk => balance * riskPercent / 100;

  double get stopLossDistance => (entryPrice - stopLossPrice).abs();

  double get positionSize =>
      stopLossDistance > 0 ? dollarRisk / stopLossDistance : 0;

  double get takeProfitPrice {
    if (entryPrice == 0 || stopLossPrice == 0) return 0;
    final distance = (entryPrice - stopLossPrice).abs() * rewardRatio;
    return isLong ? entryPrice + distance : entryPrice - distance;
  }

  double get potentialProfit => dollarRisk * rewardRatio;

  static const RiskCalculation initial = RiskCalculation(
    balance: 10000,
    riskPercent: 1.0,
    entryPrice: 0,
    stopLossPrice: 0,
    rewardRatio: 2.0,
    isLong: true,
  );

  RiskCalculation copyWith({
    double? balance,
    double? riskPercent,
    double? entryPrice,
    double? stopLossPrice,
    double? rewardRatio,
    bool? isLong,
  }) {
    return RiskCalculation(
      balance: balance ?? this.balance,
      riskPercent: riskPercent ?? this.riskPercent,
      entryPrice: entryPrice ?? this.entryPrice,
      stopLossPrice: stopLossPrice ?? this.stopLossPrice,
      rewardRatio: rewardRatio ?? this.rewardRatio,
      isLong: isLong ?? this.isLong,
    );
  }

  @override
  List<Object?> get props => [
    balance, riskPercent, entryPrice, stopLossPrice, rewardRatio, isLong,
  ];
}
