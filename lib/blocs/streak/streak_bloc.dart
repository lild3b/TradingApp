import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/streak_data.dart';
import '../../repositories/streak_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class StreakEvent extends Equatable {
  const StreakEvent();
  @override
  List<Object?> get props => [];
}

class LoadStreaks extends StreakEvent {
  const LoadStreaks(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class StreakState extends Equatable {
  const StreakState();
  @override
  List<Object?> get props => [];
}

class StreaksLoading extends StreakState {
  const StreaksLoading();
}

class StreaksLoaded extends StreakState {
  const StreaksLoaded(this.data);
  final StreakData data;
  @override
  List<Object?> get props => [data];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class StreakBloc extends Bloc<StreakEvent, StreakState> {
  StreakBloc({required StreakRepository streakRepository})
      : _streakRepo = streakRepository,
        super(const StreaksLoading()) {
    on<LoadStreaks>(_onLoad);
  }

  final StreakRepository _streakRepo;

  Future<void> _onLoad(LoadStreaks event, Emitter<StreakState> emit) async {
    emit(const StreaksLoading());
    try {
      final data = await _streakRepo.computeStreaks(event.userId);
      emit(StreaksLoaded(data));
    } catch (_) {
      emit(const StreaksLoaded(StreakData.empty));
    }
  }
}
