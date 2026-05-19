import 'package:equatable/equatable.dart';

enum PositionType { long, short }

enum RulesFollowed { yes, partial, no }

class Trade extends Equatable {
  const Trade({
    required this.id,
    required this.userId,
    required this.dateTimeTaken,
    required this.market,
    required this.positionType,
    required this.entryPrice,
    required this.exitPrice,
    required this.pnl,
    required this.riskAmount,
    required this.rewardAmount,
    required this.entryStrategy,
    required this.tags,
    required this.comments,
    required this.rulesFollowed,
    this.entryImagePath,
    this.resultImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final DateTime dateTimeTaken;
  final String market;
  final PositionType positionType;
  final double entryPrice;
  final double exitPrice;
  final double pnl;
  final double riskAmount;
  final double rewardAmount;
  final String entryStrategy;
  final List<String> tags;
  final String comments;
  final RulesFollowed rulesFollowed;
  final String? entryImagePath;
  final String? resultImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get rrRatio => riskAmount > 0 ? rewardAmount / riskAmount : 0;
  bool get isWin => pnl > 0;
  bool get isLoss => pnl < 0;

  Trade copyWith({
    String? id,
    String? userId,
    DateTime? dateTimeTaken,
    String? market,
    PositionType? positionType,
    double? entryPrice,
    double? exitPrice,
    double? pnl,
    double? riskAmount,
    double? rewardAmount,
    String? entryStrategy,
    List<String>? tags,
    String? comments,
    RulesFollowed? rulesFollowed,
    String? entryImagePath,
    String? resultImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trade(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateTimeTaken: dateTimeTaken ?? this.dateTimeTaken,
      market: market ?? this.market,
      positionType: positionType ?? this.positionType,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      pnl: pnl ?? this.pnl,
      riskAmount: riskAmount ?? this.riskAmount,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      entryStrategy: entryStrategy ?? this.entryStrategy,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments,
      rulesFollowed: rulesFollowed ?? this.rulesFollowed,
      entryImagePath: entryImagePath ?? this.entryImagePath,
      resultImagePath: resultImagePath ?? this.resultImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, dateTimeTaken, market, positionType,
    entryPrice, exitPrice, pnl, riskAmount, rewardAmount,
    entryStrategy, tags, comments, rulesFollowed,
    entryImagePath, resultImagePath, createdAt, updatedAt,
  ];
}
