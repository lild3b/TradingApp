import 'package:equatable/equatable.dart';

class NotificationSettings extends Equatable {
  const NotificationSettings({
    required this.dailyReminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.summaryEnabled,
  });

  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool summaryEnabled;

  static const NotificationSettings defaults = NotificationSettings(
    dailyReminderEnabled: false,
    reminderHour: 20,
    reminderMinute: 0,
    summaryEnabled: false,
  );

  NotificationSettings copyWith({
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? summaryEnabled,
  }) {
    return NotificationSettings(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      summaryEnabled: summaryEnabled ?? this.summaryEnabled,
    );
  }

  @override
  List<Object?> get props => [dailyReminderEnabled, reminderHour, reminderMinute, summaryEnabled];
}
