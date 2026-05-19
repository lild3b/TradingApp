import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:trading_journal/database/app_database.dart';
import '../database/daos/notification_settings_dao.dart';
import '../models/notification_settings.dart';

class NotificationRepository {
  NotificationRepository({required NotificationSettingsDao dao}) : _dao = dao;

  final NotificationSettingsDao _dao;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _reminderId = 1;
  static const int _summaryId = 2;

  Future<void> initialize() async {
    tzdata.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    // Payload-based navigation handled at app level if needed
  }

  Future<NotificationSettings> getSettings() async {
    final row = await _dao.getSettings();
    if (row == null) return NotificationSettings.defaults;
    return NotificationSettings(
      dailyReminderEnabled: row.dailyReminderEnabled,
      reminderHour: row.reminderHour,
      reminderMinute: row.reminderMinute,
      summaryEnabled: row.summaryEnabled,
    );
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    await _dao.upsertSettings(NotificationSettingsTableCompanion(
      id: const Value('device'),
      dailyReminderEnabled: Value(settings.dailyReminderEnabled),
      reminderHour: Value(settings.reminderHour),
      reminderMinute: Value(settings.reminderMinute),
      summaryEnabled: Value(settings.summaryEnabled),
    ));
  }

  Future<void> scheduleReminder(int hour, int minute) async {
    await _plugin.cancel(_reminderId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // flutter_local_notifications v18 API
    await _plugin.zonedSchedule(
      _reminderId,
      'Trading Journal Reminder',
      "Don't forget to log today's trades.",
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Daily Reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'journal',
    );
  }

  Future<void> cancelReminder() async {
    await _plugin.cancel(_reminderId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> showSummaryNotification(String body) async {
    await _plugin.show(
      _summaryId,
      'Daily Trading Summary',
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'summary_channel',
          'Daily Summary',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'dashboard',
    );
  }
}
