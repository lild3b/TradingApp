import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/notification_settings.dart';
import '../../repositories/notification_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotificationSettings extends NotificationEvent {
  const LoadNotificationSettings();
}

class UpdateReminderTime extends NotificationEvent {
  const UpdateReminderTime({required this.hour, required this.minute});
  final int hour;
  final int minute;
  @override
  List<Object?> get props => [hour, minute];
}

class ToggleDailyReminder extends NotificationEvent {
  const ToggleDailyReminder(this.enabled);
  final bool enabled;
  @override
  List<Object?> get props => [enabled];
}

class ToggleSummaryNotification extends NotificationEvent {
  const ToggleSummaryNotification(this.enabled);
  final bool enabled;
  @override
  List<Object?> get props => [enabled];
}

class ScheduleNotifications extends NotificationEvent {
  const ScheduleNotifications();
}

class CancelNotifications extends NotificationEvent {
  const CancelNotifications();
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded(this.settings);
  final NotificationSettings settings;
  @override
  List<Object?> get props => [settings];
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({required NotificationRepository notificationRepository})
      : _repo = notificationRepository,
        super(const NotificationLoading()) {
    on<LoadNotificationSettings>(_onLoad);
    on<UpdateReminderTime>(_onUpdateTime);
    on<ToggleDailyReminder>(_onToggleReminder);
    on<ToggleSummaryNotification>(_onToggleSummary);
    on<ScheduleNotifications>(_onSchedule);
    on<CancelNotifications>(_onCancel);
  }

  final NotificationRepository _repo;

  Future<void> _onLoad(
      LoadNotificationSettings event, Emitter<NotificationState> emit) async {
    emit(const NotificationLoading());
    try {
      final settings = await _repo.getSettings();
      emit(NotificationLoaded(settings));
      // Auto-reschedule if enabled
      if (settings.dailyReminderEnabled) {
        await _repo.scheduleReminder(settings.reminderHour, settings.reminderMinute);
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onUpdateTime(
      UpdateReminderTime event, Emitter<NotificationState> emit) async {
    final current = state;
    if (current is! NotificationLoaded) return;
    final updated = current.settings
        .copyWith(reminderHour: event.hour, reminderMinute: event.minute);
    await _repo.saveSettings(updated);
    if (updated.dailyReminderEnabled) {
      await _repo.scheduleReminder(event.hour, event.minute);
    }
    emit(NotificationLoaded(updated));
  }

  Future<void> _onToggleReminder(
      ToggleDailyReminder event, Emitter<NotificationState> emit) async {
    final current = state;
    if (current is! NotificationLoaded) return;
    final updated = current.settings.copyWith(dailyReminderEnabled: event.enabled);
    await _repo.saveSettings(updated);
    if (event.enabled) {
      await _repo.scheduleReminder(updated.reminderHour, updated.reminderMinute);
    } else {
      await _repo.cancelReminder();
    }
    emit(NotificationLoaded(updated));
  }

  Future<void> _onToggleSummary(
      ToggleSummaryNotification event, Emitter<NotificationState> emit) async {
    final current = state;
    if (current is! NotificationLoaded) return;
    final updated = current.settings.copyWith(summaryEnabled: event.enabled);
    await _repo.saveSettings(updated);
    emit(NotificationLoaded(updated));
  }

  Future<void> _onSchedule(
      ScheduleNotifications event, Emitter<NotificationState> emit) async {
    final current = state;
    if (current is! NotificationLoaded) return;
    if (current.settings.dailyReminderEnabled) {
      await _repo.scheduleReminder(
          current.settings.reminderHour, current.settings.reminderMinute);
    }
  }

  Future<void> _onCancel(
      CancelNotifications event, Emitter<NotificationState> emit) async {
    await _repo.cancelAll();
  }
}
