import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables.dart';
import 'daos/user_profile_dao.dart';
import 'daos/trade_dao.dart';
import 'daos/tag_dao.dart';
import 'daos/notification_settings_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [UserProfilesTable, TradesTable, TagsTable, NotificationSettingsTable],
  daos: [UserProfileDao, TradeDao, TagDao, NotificationSettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Named constructor for testing — uses positional param via super
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'trading_journal.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
