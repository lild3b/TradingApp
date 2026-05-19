import 'package:drift/drift.dart';

@DataClassName('UserProfileRow')
class UserProfilesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get avatarColorHex => text().withDefault(const Constant('#2D6BE4'))();
  RealColumn get balance => real().withDefault(const Constant(10000.0))();
  TextColumn get accountType => text().withDefault(const Constant('personal'))();
  RealColumn get dailyPermittedLossPercent => real().withDefault(const Constant(5.0))();
  RealColumn get maxPermittedLossPercent => real().withDefault(const Constant(10.0))();
  BoolColumn get pinEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get biometricEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get lockAfterSeconds => integer().withDefault(const Constant(0))();
  TextColumn get defaultMarkets => text().withDefault(const Constant('[]'))();
  TextColumn get calendarStartDay => text().withDefault(const Constant('sunday'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TradeRow')
class TradesTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(UserProfilesTable, #id)();
  DateTimeColumn get dateTimeTaken => dateTime()();
  TextColumn get market => text()();
  TextColumn get positionType => text()();
  RealColumn get entryPrice => real()();
  RealColumn get exitPrice => real()();
  RealColumn get pnl => real()();
  RealColumn get riskAmount => real().withDefault(const Constant(0.0))();
  RealColumn get rewardAmount => real().withDefault(const Constant(0.0))();
  TextColumn get entryStrategy => text().withDefault(const Constant(''))();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  TextColumn get comments => text().withDefault(const Constant(''))();
  TextColumn get rulesFollowed => text().withDefault(const Constant('yes'))();
  TextColumn get entryImagePath => text().nullable()();
  TextColumn get resultImagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TagRow')
class TagsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(UserProfilesTable, #id)();
  TextColumn get label => text()();
  TextColumn get colorHex => text().withDefault(const Constant('#3498DB'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NotificationSettingsRow')
class NotificationSettingsTable extends Table {
  TextColumn get id => text()();
  BoolColumn get dailyReminderEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get reminderHour => integer().withDefault(const Constant(20))();
  IntColumn get reminderMinute => integer().withDefault(const Constant(0))();
  BoolColumn get summaryEnabled => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
