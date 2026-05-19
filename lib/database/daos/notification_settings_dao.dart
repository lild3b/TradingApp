import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'notification_settings_dao.g.dart';

@DriftAccessor(tables: [NotificationSettingsTable])
class NotificationSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationSettingsDaoMixin {
  NotificationSettingsDao(super.db);

  static const _deviceId = 'device';

  Future<NotificationSettingsRow?> getSettings() =>
      (select(notificationSettingsTable)
            ..where((t) => t.id.equals(_deviceId)))
          .getSingleOrNull();

  Future<void> upsertSettings(NotificationSettingsTableCompanion entry) async {
    await into(notificationSettingsTable).insertOnConflictUpdate(entry);
  }
}
