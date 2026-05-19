import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/analytics_data.dart';
import '../../repositories/analytics_repository.dart';
import '../../repositories/user_profile_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAnalytics extends AnalyticsEvent {
  const LoadAnalytics(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class RefreshAnalytics extends AnalyticsEvent {
  const RefreshAnalytics(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class UpdateBalance extends AnalyticsEvent {
  const UpdateBalance({required this.userId, required this.newBalance});
  final String userId;
  final double newBalance;
  @override
  List<Object?> get props => [userId, newBalance];
}

class UpdateRiskSettings extends AnalyticsEvent {
  const UpdateRiskSettings({
    required this.userId,
    required this.dailyLossPercent,
    required this.maxLossPercent,
  });
  final String userId;
  final double dailyLossPercent;
  final double maxLossPercent;
  @override
  List<Object?> get props => [userId, dailyLossPercent, maxLossPercent];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  const AnalyticsLoaded(this.data);
  final AnalyticsData data;
  @override
  List<Object?> get props => [data];
}

class AnalyticsError extends AnalyticsState {
  const AnalyticsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({
    required AnalyticsRepository analyticsRepository,
    required UserProfileRepository profileRepository,
  })  : _analyticsRepo = analyticsRepository,
        _profileRepo = profileRepository,
        super(const AnalyticsLoading()) {
    on<LoadAnalytics>(_onLoad);
    on<RefreshAnalytics>(_onRefresh);
    on<UpdateBalance>(_onUpdateBalance);
    on<UpdateRiskSettings>(_onUpdateRiskSettings);
  }

  final AnalyticsRepository _analyticsRepo;
  final UserProfileRepository _profileRepo;

  Future<void> _onLoad(
      LoadAnalytics event, Emitter<AnalyticsState> emit) async {
    emit(const AnalyticsLoading());
    await _computeAndEmit(event.userId, emit);
  }

  Future<void> _onRefresh(
      RefreshAnalytics event, Emitter<AnalyticsState> emit) async {
    await _computeAndEmit(event.userId, emit);
  }

  Future<void> _onUpdateBalance(
      UpdateBalance event, Emitter<AnalyticsState> emit) async {
    try {
      final profile = await _profileRepo.getProfileById(event.userId);
      if (profile == null) return;
      await _profileRepo.updateProfile(
          profile.copyWith(balance: event.newBalance));
      await _computeAndEmit(event.userId, emit);
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onUpdateRiskSettings(
      UpdateRiskSettings event, Emitter<AnalyticsState> emit) async {
    try {
      final profile = await _profileRepo.getProfileById(event.userId);
      if (profile == null) return;
      await _profileRepo.updateProfile(profile.copyWith(
        dailyPermittedLossPercent: event.dailyLossPercent,
        maxPermittedLossPercent: event.maxLossPercent,
      ));
      await _computeAndEmit(event.userId, emit);
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _computeAndEmit(
      String userId, Emitter<AnalyticsState> emit) async {
    try {
      final profile = await _profileRepo.getProfileById(userId);
      if (profile == null) {
        emit(const AnalyticsError('Profile not found'));
        return;
      }
      final data = await _analyticsRepo.computeAnalytics(profile);
      emit(AnalyticsLoaded(data));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
