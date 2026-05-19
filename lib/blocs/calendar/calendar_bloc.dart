import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/monthly_stats.dart';
import '../../repositories/analytics_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();
  @override
  List<Object?> get props => [];
}

class LoadCalendarMonth extends CalendarEvent {
  const LoadCalendarMonth({
    required this.userId,
    required this.year,
    required this.month,
  });
  final String userId;
  final int year;
  final int month;
  @override
  List<Object?> get props => [userId, year, month];
}

class NavigateToNextMonth extends CalendarEvent {
  const NavigateToNextMonth(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class NavigateToPreviousMonth extends CalendarEvent {
  const NavigateToPreviousMonth(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class SelectDate extends CalendarEvent {
  const SelectDate(this.date);
  final DateTime date;
  @override
  List<Object?> get props => [date];
}

class ClearSelectedDate extends CalendarEvent {
  const ClearSelectedDate();
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class CalendarState extends Equatable {
  const CalendarState();
  @override
  List<Object?> get props => [];
}

class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

class CalendarLoaded extends CalendarState {
  const CalendarLoaded({
    required this.currentMonth,
    required this.currentYear,
    required this.dailyPnlMap,
    required this.dailyTradeCountMap,
    required this.monthlyStats,
    required this.userId,
  });
  final int currentMonth;
  final int currentYear;
  final Map<DateTime, double> dailyPnlMap;
  final Map<DateTime, int>? dailyTradeCountMap;
  final MonthlyStats monthlyStats;
  final String userId;
  @override
  List<Object?> get props => [
        currentMonth,
        currentYear,
        dailyPnlMap,
        dailyTradeCountMap,
        monthlyStats,
        userId
      ];
}

class DateSelected extends CalendarState {
  const DateSelected({
    required this.date,
    required this.calendarData,
  });
  final DateTime date;
  final CalendarLoaded calendarData;
  @override
  List<Object?> get props => [date, calendarData];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc({required AnalyticsRepository analyticsRepository})
      : _analyticsRepo = analyticsRepository,
        super(const CalendarLoading()) {
    on<LoadCalendarMonth>(_onLoad);
    on<NavigateToNextMonth>(_onNextMonth);
    on<NavigateToPreviousMonth>(_onPrevMonth);
    on<SelectDate>(_onSelectDate);
    on<ClearSelectedDate>(_onClearDate);
  }

  final AnalyticsRepository _analyticsRepo;

  Future<void> _onLoad(
      LoadCalendarMonth event, Emitter<CalendarState> emit) async {
    emit(const CalendarLoading());
    await _loadMonth(event.userId, event.year, event.month, emit);
  }

  Future<void> _onNextMonth(
      NavigateToNextMonth event, Emitter<CalendarState> emit) async {
    final current = _getCalendarLoaded();
    if (current == null) return;
    var month = current.currentMonth + 1;
    var year = current.currentYear;
    if (month > 12) {
      month = 1;
      year++;
    }
    await _loadMonth(event.userId, year, month, emit);
  }

  Future<void> _onPrevMonth(
      NavigateToPreviousMonth event, Emitter<CalendarState> emit) async {
    final current = _getCalendarLoaded();
    if (current == null) return;
    var month = current.currentMonth - 1;
    var year = current.currentYear;
    if (month < 1) {
      month = 12;
      year--;
    }
    await _loadMonth(event.userId, year, month, emit);
  }

  void _onSelectDate(SelectDate event, Emitter<CalendarState> emit) {
    final cal = _getCalendarLoaded();
    if (cal == null) return;
    emit(DateSelected(date: event.date, calendarData: cal));
  }

  void _onClearDate(ClearSelectedDate event, Emitter<CalendarState> emit) {
    final cal = _getCalendarLoaded();
    if (cal != null) emit(cal);
  }

  CalendarLoaded? _getCalendarLoaded() {
    final s = state;
    if (s is CalendarLoaded) return s;
    if (s is DateSelected) return s.calendarData;
    return null;
  }

  Future<void> _loadMonth(
      String userId, int year, int month, Emitter<CalendarState> emit) async {
    try {
      final dailyPnlMap =
          await _analyticsRepo.getDailyPnlMap(userId, year, month);
      final dailyTradeCountMap =
          await _analyticsRepo.getDailyTradeCountMap(userId, year, month);
      final monthlyStats =
          await _analyticsRepo.computeMonthlyStats(userId, year, month);
      emit(CalendarLoaded(
        currentMonth: month,
        currentYear: year,
        dailyPnlMap: dailyPnlMap,
        dailyTradeCountMap: dailyTradeCountMap,
        monthlyStats: monthlyStats,
        userId: userId,
      ));
    } catch (e) {
      // Emit empty calendar on error
      emit(CalendarLoaded(
        currentMonth: month,
        currentYear: year,
        dailyPnlMap: const {},
        dailyTradeCountMap: const {},
        monthlyStats: MonthlyStats.empty,
        userId: userId,
      ));
    }
  }
}
