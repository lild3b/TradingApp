import 'package:equatable/equatable.dart';

class StreakData extends Equatable {
  const StreakData({
    required this.currentWinStreak,
    required this.longestWinStreak,
    required this.currentLossStreak,
    required this.longestLossStreak,
    required this.last90DaysMap,
  });

  final int currentWinStreak;
  final int longestWinStreak;
  final int currentLossStreak;
  final int longestLossStreak;
  // Values: 'win', 'loss', 'none'
  final Map<DateTime, String> last90DaysMap;

  static const StreakData empty = StreakData(
    currentWinStreak: 0,
    longestWinStreak: 0,
    currentLossStreak: 0,
    longestLossStreak: 0,
    last90DaysMap: {},
  );

  @override
  List<Object?> get props => [
    currentWinStreak,
    longestWinStreak,
    currentLossStreak,
    longestLossStreak,
    last90DaysMap,
  ];
}
