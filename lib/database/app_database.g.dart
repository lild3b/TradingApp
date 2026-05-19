// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTableTable extends UserProfilesTable
    with TableInfo<$UserProfilesTableTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarColorHexMeta =
      const VerificationMeta('avatarColorHex');
  @override
  late final GeneratedColumn<String> avatarColorHex = GeneratedColumn<String>(
      'avatar_color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#2D6BE4'));
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
      'balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(10000.0));
  static const VerificationMeta _accountTypeMeta =
      const VerificationMeta('accountType');
  @override
  late final GeneratedColumn<String> accountType = GeneratedColumn<String>(
      'account_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('personal'));
  static const VerificationMeta _dailyPermittedLossPercentMeta =
      const VerificationMeta('dailyPermittedLossPercent');
  @override
  late final GeneratedColumn<double> dailyPermittedLossPercent =
      GeneratedColumn<double>(
          'daily_permitted_loss_percent', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(5.0));
  static const VerificationMeta _maxPermittedLossPercentMeta =
      const VerificationMeta('maxPermittedLossPercent');
  @override
  late final GeneratedColumn<double> maxPermittedLossPercent =
      GeneratedColumn<double>('max_permitted_loss_percent', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(10.0));
  static const VerificationMeta _pinEnabledMeta =
      const VerificationMeta('pinEnabled');
  @override
  late final GeneratedColumn<bool> pinEnabled = GeneratedColumn<bool>(
      'pin_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("pin_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _biometricEnabledMeta =
      const VerificationMeta('biometricEnabled');
  @override
  late final GeneratedColumn<bool> biometricEnabled = GeneratedColumn<bool>(
      'biometric_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("biometric_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lockAfterSecondsMeta =
      const VerificationMeta('lockAfterSeconds');
  @override
  late final GeneratedColumn<int> lockAfterSeconds = GeneratedColumn<int>(
      'lock_after_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _defaultMarketsMeta =
      const VerificationMeta('defaultMarkets');
  @override
  late final GeneratedColumn<String> defaultMarkets = GeneratedColumn<String>(
      'default_markets', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _calendarStartDayMeta =
      const VerificationMeta('calendarStartDay');
  @override
  late final GeneratedColumn<String> calendarStartDay = GeneratedColumn<String>(
      'calendar_start_day', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('sunday'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        avatarColorHex,
        balance,
        accountType,
        dailyPermittedLossPercent,
        maxPermittedLossPercent,
        pinEnabled,
        biometricEnabled,
        lockAfterSeconds,
        defaultMarkets,
        calendarStartDay,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles_table';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfileRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_color_hex')) {
      context.handle(
          _avatarColorHexMeta,
          avatarColorHex.isAcceptableOrUnknown(
              data['avatar_color_hex']!, _avatarColorHexMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    }
    if (data.containsKey('account_type')) {
      context.handle(
          _accountTypeMeta,
          accountType.isAcceptableOrUnknown(
              data['account_type']!, _accountTypeMeta));
    }
    if (data.containsKey('daily_permitted_loss_percent')) {
      context.handle(
          _dailyPermittedLossPercentMeta,
          dailyPermittedLossPercent.isAcceptableOrUnknown(
              data['daily_permitted_loss_percent']!,
              _dailyPermittedLossPercentMeta));
    }
    if (data.containsKey('max_permitted_loss_percent')) {
      context.handle(
          _maxPermittedLossPercentMeta,
          maxPermittedLossPercent.isAcceptableOrUnknown(
              data['max_permitted_loss_percent']!,
              _maxPermittedLossPercentMeta));
    }
    if (data.containsKey('pin_enabled')) {
      context.handle(
          _pinEnabledMeta,
          pinEnabled.isAcceptableOrUnknown(
              data['pin_enabled']!, _pinEnabledMeta));
    }
    if (data.containsKey('biometric_enabled')) {
      context.handle(
          _biometricEnabledMeta,
          biometricEnabled.isAcceptableOrUnknown(
              data['biometric_enabled']!, _biometricEnabledMeta));
    }
    if (data.containsKey('lock_after_seconds')) {
      context.handle(
          _lockAfterSecondsMeta,
          lockAfterSeconds.isAcceptableOrUnknown(
              data['lock_after_seconds']!, _lockAfterSecondsMeta));
    }
    if (data.containsKey('default_markets')) {
      context.handle(
          _defaultMarketsMeta,
          defaultMarkets.isAcceptableOrUnknown(
              data['default_markets']!, _defaultMarketsMeta));
    }
    if (data.containsKey('calendar_start_day')) {
      context.handle(
          _calendarStartDayMeta,
          calendarStartDay.isAcceptableOrUnknown(
              data['calendar_start_day']!, _calendarStartDayMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      avatarColorHex: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}avatar_color_hex'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance'])!,
      accountType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_type'])!,
      dailyPermittedLossPercent: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}daily_permitted_loss_percent'])!,
      maxPermittedLossPercent: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}max_permitted_loss_percent'])!,
      pinEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pin_enabled'])!,
      biometricEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}biometric_enabled'])!,
      lockAfterSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}lock_after_seconds'])!,
      defaultMarkets: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_markets'])!,
      calendarStartDay: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}calendar_start_day'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UserProfilesTableTable createAlias(String alias) {
    return $UserProfilesTableTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final String id;
  final String name;
  final String avatarColorHex;
  final double balance;
  final String accountType;
  final double dailyPermittedLossPercent;
  final double maxPermittedLossPercent;
  final bool pinEnabled;
  final bool biometricEnabled;
  final int lockAfterSeconds;
  final String defaultMarkets;
  final String calendarStartDay;
  final DateTime createdAt;
  const UserProfileRow(
      {required this.id,
      required this.name,
      required this.avatarColorHex,
      required this.balance,
      required this.accountType,
      required this.dailyPermittedLossPercent,
      required this.maxPermittedLossPercent,
      required this.pinEnabled,
      required this.biometricEnabled,
      required this.lockAfterSeconds,
      required this.defaultMarkets,
      required this.calendarStartDay,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['avatar_color_hex'] = Variable<String>(avatarColorHex);
    map['balance'] = Variable<double>(balance);
    map['account_type'] = Variable<String>(accountType);
    map['daily_permitted_loss_percent'] =
        Variable<double>(dailyPermittedLossPercent);
    map['max_permitted_loss_percent'] =
        Variable<double>(maxPermittedLossPercent);
    map['pin_enabled'] = Variable<bool>(pinEnabled);
    map['biometric_enabled'] = Variable<bool>(biometricEnabled);
    map['lock_after_seconds'] = Variable<int>(lockAfterSeconds);
    map['default_markets'] = Variable<String>(defaultMarkets);
    map['calendar_start_day'] = Variable<String>(calendarStartDay);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesTableCompanion(
      id: Value(id),
      name: Value(name),
      avatarColorHex: Value(avatarColorHex),
      balance: Value(balance),
      accountType: Value(accountType),
      dailyPermittedLossPercent: Value(dailyPermittedLossPercent),
      maxPermittedLossPercent: Value(maxPermittedLossPercent),
      pinEnabled: Value(pinEnabled),
      biometricEnabled: Value(biometricEnabled),
      lockAfterSeconds: Value(lockAfterSeconds),
      defaultMarkets: Value(defaultMarkets),
      calendarStartDay: Value(calendarStartDay),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfileRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatarColorHex: serializer.fromJson<String>(json['avatarColorHex']),
      balance: serializer.fromJson<double>(json['balance']),
      accountType: serializer.fromJson<String>(json['accountType']),
      dailyPermittedLossPercent:
          serializer.fromJson<double>(json['dailyPermittedLossPercent']),
      maxPermittedLossPercent:
          serializer.fromJson<double>(json['maxPermittedLossPercent']),
      pinEnabled: serializer.fromJson<bool>(json['pinEnabled']),
      biometricEnabled: serializer.fromJson<bool>(json['biometricEnabled']),
      lockAfterSeconds: serializer.fromJson<int>(json['lockAfterSeconds']),
      defaultMarkets: serializer.fromJson<String>(json['defaultMarkets']),
      calendarStartDay: serializer.fromJson<String>(json['calendarStartDay']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'avatarColorHex': serializer.toJson<String>(avatarColorHex),
      'balance': serializer.toJson<double>(balance),
      'accountType': serializer.toJson<String>(accountType),
      'dailyPermittedLossPercent':
          serializer.toJson<double>(dailyPermittedLossPercent),
      'maxPermittedLossPercent':
          serializer.toJson<double>(maxPermittedLossPercent),
      'pinEnabled': serializer.toJson<bool>(pinEnabled),
      'biometricEnabled': serializer.toJson<bool>(biometricEnabled),
      'lockAfterSeconds': serializer.toJson<int>(lockAfterSeconds),
      'defaultMarkets': serializer.toJson<String>(defaultMarkets),
      'calendarStartDay': serializer.toJson<String>(calendarStartDay),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfileRow copyWith(
          {String? id,
          String? name,
          String? avatarColorHex,
          double? balance,
          String? accountType,
          double? dailyPermittedLossPercent,
          double? maxPermittedLossPercent,
          bool? pinEnabled,
          bool? biometricEnabled,
          int? lockAfterSeconds,
          String? defaultMarkets,
          String? calendarStartDay,
          DateTime? createdAt}) =>
      UserProfileRow(
        id: id ?? this.id,
        name: name ?? this.name,
        avatarColorHex: avatarColorHex ?? this.avatarColorHex,
        balance: balance ?? this.balance,
        accountType: accountType ?? this.accountType,
        dailyPermittedLossPercent:
            dailyPermittedLossPercent ?? this.dailyPermittedLossPercent,
        maxPermittedLossPercent:
            maxPermittedLossPercent ?? this.maxPermittedLossPercent,
        pinEnabled: pinEnabled ?? this.pinEnabled,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        lockAfterSeconds: lockAfterSeconds ?? this.lockAfterSeconds,
        defaultMarkets: defaultMarkets ?? this.defaultMarkets,
        calendarStartDay: calendarStartDay ?? this.calendarStartDay,
        createdAt: createdAt ?? this.createdAt,
      );
  UserProfileRow copyWithCompanion(UserProfilesTableCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatarColorHex: data.avatarColorHex.present
          ? data.avatarColorHex.value
          : this.avatarColorHex,
      balance: data.balance.present ? data.balance.value : this.balance,
      accountType:
          data.accountType.present ? data.accountType.value : this.accountType,
      dailyPermittedLossPercent: data.dailyPermittedLossPercent.present
          ? data.dailyPermittedLossPercent.value
          : this.dailyPermittedLossPercent,
      maxPermittedLossPercent: data.maxPermittedLossPercent.present
          ? data.maxPermittedLossPercent.value
          : this.maxPermittedLossPercent,
      pinEnabled:
          data.pinEnabled.present ? data.pinEnabled.value : this.pinEnabled,
      biometricEnabled: data.biometricEnabled.present
          ? data.biometricEnabled.value
          : this.biometricEnabled,
      lockAfterSeconds: data.lockAfterSeconds.present
          ? data.lockAfterSeconds.value
          : this.lockAfterSeconds,
      defaultMarkets: data.defaultMarkets.present
          ? data.defaultMarkets.value
          : this.defaultMarkets,
      calendarStartDay: data.calendarStartDay.present
          ? data.calendarStartDay.value
          : this.calendarStartDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarColorHex: $avatarColorHex, ')
          ..write('balance: $balance, ')
          ..write('accountType: $accountType, ')
          ..write('dailyPermittedLossPercent: $dailyPermittedLossPercent, ')
          ..write('maxPermittedLossPercent: $maxPermittedLossPercent, ')
          ..write('pinEnabled: $pinEnabled, ')
          ..write('biometricEnabled: $biometricEnabled, ')
          ..write('lockAfterSeconds: $lockAfterSeconds, ')
          ..write('defaultMarkets: $defaultMarkets, ')
          ..write('calendarStartDay: $calendarStartDay, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      avatarColorHex,
      balance,
      accountType,
      dailyPermittedLossPercent,
      maxPermittedLossPercent,
      pinEnabled,
      biometricEnabled,
      lockAfterSeconds,
      defaultMarkets,
      calendarStartDay,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatarColorHex == this.avatarColorHex &&
          other.balance == this.balance &&
          other.accountType == this.accountType &&
          other.dailyPermittedLossPercent == this.dailyPermittedLossPercent &&
          other.maxPermittedLossPercent == this.maxPermittedLossPercent &&
          other.pinEnabled == this.pinEnabled &&
          other.biometricEnabled == this.biometricEnabled &&
          other.lockAfterSeconds == this.lockAfterSeconds &&
          other.defaultMarkets == this.defaultMarkets &&
          other.calendarStartDay == this.calendarStartDay &&
          other.createdAt == this.createdAt);
}

class UserProfilesTableCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> avatarColorHex;
  final Value<double> balance;
  final Value<String> accountType;
  final Value<double> dailyPermittedLossPercent;
  final Value<double> maxPermittedLossPercent;
  final Value<bool> pinEnabled;
  final Value<bool> biometricEnabled;
  final Value<int> lockAfterSeconds;
  final Value<String> defaultMarkets;
  final Value<String> calendarStartDay;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserProfilesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarColorHex = const Value.absent(),
    this.balance = const Value.absent(),
    this.accountType = const Value.absent(),
    this.dailyPermittedLossPercent = const Value.absent(),
    this.maxPermittedLossPercent = const Value.absent(),
    this.pinEnabled = const Value.absent(),
    this.biometricEnabled = const Value.absent(),
    this.lockAfterSeconds = const Value.absent(),
    this.defaultMarkets = const Value.absent(),
    this.calendarStartDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesTableCompanion.insert({
    required String id,
    required String name,
    this.avatarColorHex = const Value.absent(),
    this.balance = const Value.absent(),
    this.accountType = const Value.absent(),
    this.dailyPermittedLossPercent = const Value.absent(),
    this.maxPermittedLossPercent = const Value.absent(),
    this.pinEnabled = const Value.absent(),
    this.biometricEnabled = const Value.absent(),
    this.lockAfterSeconds = const Value.absent(),
    this.defaultMarkets = const Value.absent(),
    this.calendarStartDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<UserProfileRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? avatarColorHex,
    Expression<double>? balance,
    Expression<String>? accountType,
    Expression<double>? dailyPermittedLossPercent,
    Expression<double>? maxPermittedLossPercent,
    Expression<bool>? pinEnabled,
    Expression<bool>? biometricEnabled,
    Expression<int>? lockAfterSeconds,
    Expression<String>? defaultMarkets,
    Expression<String>? calendarStartDay,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatarColorHex != null) 'avatar_color_hex': avatarColorHex,
      if (balance != null) 'balance': balance,
      if (accountType != null) 'account_type': accountType,
      if (dailyPermittedLossPercent != null)
        'daily_permitted_loss_percent': dailyPermittedLossPercent,
      if (maxPermittedLossPercent != null)
        'max_permitted_loss_percent': maxPermittedLossPercent,
      if (pinEnabled != null) 'pin_enabled': pinEnabled,
      if (biometricEnabled != null) 'biometric_enabled': biometricEnabled,
      if (lockAfterSeconds != null) 'lock_after_seconds': lockAfterSeconds,
      if (defaultMarkets != null) 'default_markets': defaultMarkets,
      if (calendarStartDay != null) 'calendar_start_day': calendarStartDay,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? avatarColorHex,
      Value<double>? balance,
      Value<String>? accountType,
      Value<double>? dailyPermittedLossPercent,
      Value<double>? maxPermittedLossPercent,
      Value<bool>? pinEnabled,
      Value<bool>? biometricEnabled,
      Value<int>? lockAfterSeconds,
      Value<String>? defaultMarkets,
      Value<String>? calendarStartDay,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return UserProfilesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarColorHex: avatarColorHex ?? this.avatarColorHex,
      balance: balance ?? this.balance,
      accountType: accountType ?? this.accountType,
      dailyPermittedLossPercent:
          dailyPermittedLossPercent ?? this.dailyPermittedLossPercent,
      maxPermittedLossPercent:
          maxPermittedLossPercent ?? this.maxPermittedLossPercent,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      lockAfterSeconds: lockAfterSeconds ?? this.lockAfterSeconds,
      defaultMarkets: defaultMarkets ?? this.defaultMarkets,
      calendarStartDay: calendarStartDay ?? this.calendarStartDay,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarColorHex.present) {
      map['avatar_color_hex'] = Variable<String>(avatarColorHex.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (accountType.present) {
      map['account_type'] = Variable<String>(accountType.value);
    }
    if (dailyPermittedLossPercent.present) {
      map['daily_permitted_loss_percent'] =
          Variable<double>(dailyPermittedLossPercent.value);
    }
    if (maxPermittedLossPercent.present) {
      map['max_permitted_loss_percent'] =
          Variable<double>(maxPermittedLossPercent.value);
    }
    if (pinEnabled.present) {
      map['pin_enabled'] = Variable<bool>(pinEnabled.value);
    }
    if (biometricEnabled.present) {
      map['biometric_enabled'] = Variable<bool>(biometricEnabled.value);
    }
    if (lockAfterSeconds.present) {
      map['lock_after_seconds'] = Variable<int>(lockAfterSeconds.value);
    }
    if (defaultMarkets.present) {
      map['default_markets'] = Variable<String>(defaultMarkets.value);
    }
    if (calendarStartDay.present) {
      map['calendar_start_day'] = Variable<String>(calendarStartDay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarColorHex: $avatarColorHex, ')
          ..write('balance: $balance, ')
          ..write('accountType: $accountType, ')
          ..write('dailyPermittedLossPercent: $dailyPermittedLossPercent, ')
          ..write('maxPermittedLossPercent: $maxPermittedLossPercent, ')
          ..write('pinEnabled: $pinEnabled, ')
          ..write('biometricEnabled: $biometricEnabled, ')
          ..write('lockAfterSeconds: $lockAfterSeconds, ')
          ..write('defaultMarkets: $defaultMarkets, ')
          ..write('calendarStartDay: $calendarStartDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TradesTableTable extends TradesTable
    with TableInfo<$TradesTableTable, TradeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES user_profiles_table (id)'));
  static const VerificationMeta _dateTimeTakenMeta =
      const VerificationMeta('dateTimeTaken');
  @override
  late final GeneratedColumn<DateTime> dateTimeTaken =
      GeneratedColumn<DateTime>('date_time_taken', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
      'market', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionTypeMeta =
      const VerificationMeta('positionType');
  @override
  late final GeneratedColumn<String> positionType = GeneratedColumn<String>(
      'position_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryPriceMeta =
      const VerificationMeta('entryPrice');
  @override
  late final GeneratedColumn<double> entryPrice = GeneratedColumn<double>(
      'entry_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _exitPriceMeta =
      const VerificationMeta('exitPrice');
  @override
  late final GeneratedColumn<double> exitPrice = GeneratedColumn<double>(
      'exit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _pnlMeta = const VerificationMeta('pnl');
  @override
  late final GeneratedColumn<double> pnl = GeneratedColumn<double>(
      'pnl', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _riskAmountMeta =
      const VerificationMeta('riskAmount');
  @override
  late final GeneratedColumn<double> riskAmount = GeneratedColumn<double>(
      'risk_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _rewardAmountMeta =
      const VerificationMeta('rewardAmount');
  @override
  late final GeneratedColumn<double> rewardAmount = GeneratedColumn<double>(
      'reward_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _entryStrategyMeta =
      const VerificationMeta('entryStrategy');
  @override
  late final GeneratedColumn<String> entryStrategy = GeneratedColumn<String>(
      'entry_strategy', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _commentsMeta =
      const VerificationMeta('comments');
  @override
  late final GeneratedColumn<String> comments = GeneratedColumn<String>(
      'comments', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _rulesFollowedMeta =
      const VerificationMeta('rulesFollowed');
  @override
  late final GeneratedColumn<String> rulesFollowed = GeneratedColumn<String>(
      'rules_followed', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('yes'));
  static const VerificationMeta _entryImagePathMeta =
      const VerificationMeta('entryImagePath');
  @override
  late final GeneratedColumn<String> entryImagePath = GeneratedColumn<String>(
      'entry_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultImagePathMeta =
      const VerificationMeta('resultImagePath');
  @override
  late final GeneratedColumn<String> resultImagePath = GeneratedColumn<String>(
      'result_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        dateTimeTaken,
        market,
        positionType,
        entryPrice,
        exitPrice,
        pnl,
        riskAmount,
        rewardAmount,
        entryStrategy,
        tags,
        comments,
        rulesFollowed,
        entryImagePath,
        resultImagePath,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trades_table';
  @override
  VerificationContext validateIntegrity(Insertable<TradeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date_time_taken')) {
      context.handle(
          _dateTimeTakenMeta,
          dateTimeTaken.isAcceptableOrUnknown(
              data['date_time_taken']!, _dateTimeTakenMeta));
    } else if (isInserting) {
      context.missing(_dateTimeTakenMeta);
    }
    if (data.containsKey('market')) {
      context.handle(_marketMeta,
          market.isAcceptableOrUnknown(data['market']!, _marketMeta));
    } else if (isInserting) {
      context.missing(_marketMeta);
    }
    if (data.containsKey('position_type')) {
      context.handle(
          _positionTypeMeta,
          positionType.isAcceptableOrUnknown(
              data['position_type']!, _positionTypeMeta));
    } else if (isInserting) {
      context.missing(_positionTypeMeta);
    }
    if (data.containsKey('entry_price')) {
      context.handle(
          _entryPriceMeta,
          entryPrice.isAcceptableOrUnknown(
              data['entry_price']!, _entryPriceMeta));
    } else if (isInserting) {
      context.missing(_entryPriceMeta);
    }
    if (data.containsKey('exit_price')) {
      context.handle(_exitPriceMeta,
          exitPrice.isAcceptableOrUnknown(data['exit_price']!, _exitPriceMeta));
    } else if (isInserting) {
      context.missing(_exitPriceMeta);
    }
    if (data.containsKey('pnl')) {
      context.handle(
          _pnlMeta, pnl.isAcceptableOrUnknown(data['pnl']!, _pnlMeta));
    } else if (isInserting) {
      context.missing(_pnlMeta);
    }
    if (data.containsKey('risk_amount')) {
      context.handle(
          _riskAmountMeta,
          riskAmount.isAcceptableOrUnknown(
              data['risk_amount']!, _riskAmountMeta));
    }
    if (data.containsKey('reward_amount')) {
      context.handle(
          _rewardAmountMeta,
          rewardAmount.isAcceptableOrUnknown(
              data['reward_amount']!, _rewardAmountMeta));
    }
    if (data.containsKey('entry_strategy')) {
      context.handle(
          _entryStrategyMeta,
          entryStrategy.isAcceptableOrUnknown(
              data['entry_strategy']!, _entryStrategyMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('comments')) {
      context.handle(_commentsMeta,
          comments.isAcceptableOrUnknown(data['comments']!, _commentsMeta));
    }
    if (data.containsKey('rules_followed')) {
      context.handle(
          _rulesFollowedMeta,
          rulesFollowed.isAcceptableOrUnknown(
              data['rules_followed']!, _rulesFollowedMeta));
    }
    if (data.containsKey('entry_image_path')) {
      context.handle(
          _entryImagePathMeta,
          entryImagePath.isAcceptableOrUnknown(
              data['entry_image_path']!, _entryImagePathMeta));
    }
    if (data.containsKey('result_image_path')) {
      context.handle(
          _resultImagePathMeta,
          resultImagePath.isAcceptableOrUnknown(
              data['result_image_path']!, _resultImagePathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TradeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradeRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      dateTimeTaken: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_time_taken'])!,
      market: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}market'])!,
      positionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}position_type'])!,
      entryPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}entry_price'])!,
      exitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exit_price'])!,
      pnl: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pnl'])!,
      riskAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}risk_amount'])!,
      rewardAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}reward_amount'])!,
      entryStrategy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_strategy'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      comments: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comments'])!,
      rulesFollowed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rules_followed'])!,
      entryImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}entry_image_path']),
      resultImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}result_image_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TradesTableTable createAlias(String alias) {
    return $TradesTableTable(attachedDatabase, alias);
  }
}

class TradeRow extends DataClass implements Insertable<TradeRow> {
  final String id;
  final String userId;
  final DateTime dateTimeTaken;
  final String market;
  final String positionType;
  final double entryPrice;
  final double exitPrice;
  final double pnl;
  final double riskAmount;
  final double rewardAmount;
  final String entryStrategy;
  final String tags;
  final String comments;
  final String rulesFollowed;
  final String? entryImagePath;
  final String? resultImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TradeRow(
      {required this.id,
      required this.userId,
      required this.dateTimeTaken,
      required this.market,
      required this.positionType,
      required this.entryPrice,
      required this.exitPrice,
      required this.pnl,
      required this.riskAmount,
      required this.rewardAmount,
      required this.entryStrategy,
      required this.tags,
      required this.comments,
      required this.rulesFollowed,
      this.entryImagePath,
      this.resultImagePath,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['date_time_taken'] = Variable<DateTime>(dateTimeTaken);
    map['market'] = Variable<String>(market);
    map['position_type'] = Variable<String>(positionType);
    map['entry_price'] = Variable<double>(entryPrice);
    map['exit_price'] = Variable<double>(exitPrice);
    map['pnl'] = Variable<double>(pnl);
    map['risk_amount'] = Variable<double>(riskAmount);
    map['reward_amount'] = Variable<double>(rewardAmount);
    map['entry_strategy'] = Variable<String>(entryStrategy);
    map['tags'] = Variable<String>(tags);
    map['comments'] = Variable<String>(comments);
    map['rules_followed'] = Variable<String>(rulesFollowed);
    if (!nullToAbsent || entryImagePath != null) {
      map['entry_image_path'] = Variable<String>(entryImagePath);
    }
    if (!nullToAbsent || resultImagePath != null) {
      map['result_image_path'] = Variable<String>(resultImagePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TradesTableCompanion toCompanion(bool nullToAbsent) {
    return TradesTableCompanion(
      id: Value(id),
      userId: Value(userId),
      dateTimeTaken: Value(dateTimeTaken),
      market: Value(market),
      positionType: Value(positionType),
      entryPrice: Value(entryPrice),
      exitPrice: Value(exitPrice),
      pnl: Value(pnl),
      riskAmount: Value(riskAmount),
      rewardAmount: Value(rewardAmount),
      entryStrategy: Value(entryStrategy),
      tags: Value(tags),
      comments: Value(comments),
      rulesFollowed: Value(rulesFollowed),
      entryImagePath: entryImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(entryImagePath),
      resultImagePath: resultImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(resultImagePath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TradeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TradeRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      dateTimeTaken: serializer.fromJson<DateTime>(json['dateTimeTaken']),
      market: serializer.fromJson<String>(json['market']),
      positionType: serializer.fromJson<String>(json['positionType']),
      entryPrice: serializer.fromJson<double>(json['entryPrice']),
      exitPrice: serializer.fromJson<double>(json['exitPrice']),
      pnl: serializer.fromJson<double>(json['pnl']),
      riskAmount: serializer.fromJson<double>(json['riskAmount']),
      rewardAmount: serializer.fromJson<double>(json['rewardAmount']),
      entryStrategy: serializer.fromJson<String>(json['entryStrategy']),
      tags: serializer.fromJson<String>(json['tags']),
      comments: serializer.fromJson<String>(json['comments']),
      rulesFollowed: serializer.fromJson<String>(json['rulesFollowed']),
      entryImagePath: serializer.fromJson<String?>(json['entryImagePath']),
      resultImagePath: serializer.fromJson<String?>(json['resultImagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'dateTimeTaken': serializer.toJson<DateTime>(dateTimeTaken),
      'market': serializer.toJson<String>(market),
      'positionType': serializer.toJson<String>(positionType),
      'entryPrice': serializer.toJson<double>(entryPrice),
      'exitPrice': serializer.toJson<double>(exitPrice),
      'pnl': serializer.toJson<double>(pnl),
      'riskAmount': serializer.toJson<double>(riskAmount),
      'rewardAmount': serializer.toJson<double>(rewardAmount),
      'entryStrategy': serializer.toJson<String>(entryStrategy),
      'tags': serializer.toJson<String>(tags),
      'comments': serializer.toJson<String>(comments),
      'rulesFollowed': serializer.toJson<String>(rulesFollowed),
      'entryImagePath': serializer.toJson<String?>(entryImagePath),
      'resultImagePath': serializer.toJson<String?>(resultImagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TradeRow copyWith(
          {String? id,
          String? userId,
          DateTime? dateTimeTaken,
          String? market,
          String? positionType,
          double? entryPrice,
          double? exitPrice,
          double? pnl,
          double? riskAmount,
          double? rewardAmount,
          String? entryStrategy,
          String? tags,
          String? comments,
          String? rulesFollowed,
          Value<String?> entryImagePath = const Value.absent(),
          Value<String?> resultImagePath = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TradeRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        dateTimeTaken: dateTimeTaken ?? this.dateTimeTaken,
        market: market ?? this.market,
        positionType: positionType ?? this.positionType,
        entryPrice: entryPrice ?? this.entryPrice,
        exitPrice: exitPrice ?? this.exitPrice,
        pnl: pnl ?? this.pnl,
        riskAmount: riskAmount ?? this.riskAmount,
        rewardAmount: rewardAmount ?? this.rewardAmount,
        entryStrategy: entryStrategy ?? this.entryStrategy,
        tags: tags ?? this.tags,
        comments: comments ?? this.comments,
        rulesFollowed: rulesFollowed ?? this.rulesFollowed,
        entryImagePath:
            entryImagePath.present ? entryImagePath.value : this.entryImagePath,
        resultImagePath: resultImagePath.present
            ? resultImagePath.value
            : this.resultImagePath,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TradeRow copyWithCompanion(TradesTableCompanion data) {
    return TradeRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      dateTimeTaken: data.dateTimeTaken.present
          ? data.dateTimeTaken.value
          : this.dateTimeTaken,
      market: data.market.present ? data.market.value : this.market,
      positionType: data.positionType.present
          ? data.positionType.value
          : this.positionType,
      entryPrice:
          data.entryPrice.present ? data.entryPrice.value : this.entryPrice,
      exitPrice: data.exitPrice.present ? data.exitPrice.value : this.exitPrice,
      pnl: data.pnl.present ? data.pnl.value : this.pnl,
      riskAmount:
          data.riskAmount.present ? data.riskAmount.value : this.riskAmount,
      rewardAmount: data.rewardAmount.present
          ? data.rewardAmount.value
          : this.rewardAmount,
      entryStrategy: data.entryStrategy.present
          ? data.entryStrategy.value
          : this.entryStrategy,
      tags: data.tags.present ? data.tags.value : this.tags,
      comments: data.comments.present ? data.comments.value : this.comments,
      rulesFollowed: data.rulesFollowed.present
          ? data.rulesFollowed.value
          : this.rulesFollowed,
      entryImagePath: data.entryImagePath.present
          ? data.entryImagePath.value
          : this.entryImagePath,
      resultImagePath: data.resultImagePath.present
          ? data.resultImagePath.value
          : this.resultImagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradeRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dateTimeTaken: $dateTimeTaken, ')
          ..write('market: $market, ')
          ..write('positionType: $positionType, ')
          ..write('entryPrice: $entryPrice, ')
          ..write('exitPrice: $exitPrice, ')
          ..write('pnl: $pnl, ')
          ..write('riskAmount: $riskAmount, ')
          ..write('rewardAmount: $rewardAmount, ')
          ..write('entryStrategy: $entryStrategy, ')
          ..write('tags: $tags, ')
          ..write('comments: $comments, ')
          ..write('rulesFollowed: $rulesFollowed, ')
          ..write('entryImagePath: $entryImagePath, ')
          ..write('resultImagePath: $resultImagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      dateTimeTaken,
      market,
      positionType,
      entryPrice,
      exitPrice,
      pnl,
      riskAmount,
      rewardAmount,
      entryStrategy,
      tags,
      comments,
      rulesFollowed,
      entryImagePath,
      resultImagePath,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradeRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.dateTimeTaken == this.dateTimeTaken &&
          other.market == this.market &&
          other.positionType == this.positionType &&
          other.entryPrice == this.entryPrice &&
          other.exitPrice == this.exitPrice &&
          other.pnl == this.pnl &&
          other.riskAmount == this.riskAmount &&
          other.rewardAmount == this.rewardAmount &&
          other.entryStrategy == this.entryStrategy &&
          other.tags == this.tags &&
          other.comments == this.comments &&
          other.rulesFollowed == this.rulesFollowed &&
          other.entryImagePath == this.entryImagePath &&
          other.resultImagePath == this.resultImagePath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TradesTableCompanion extends UpdateCompanion<TradeRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> dateTimeTaken;
  final Value<String> market;
  final Value<String> positionType;
  final Value<double> entryPrice;
  final Value<double> exitPrice;
  final Value<double> pnl;
  final Value<double> riskAmount;
  final Value<double> rewardAmount;
  final Value<String> entryStrategy;
  final Value<String> tags;
  final Value<String> comments;
  final Value<String> rulesFollowed;
  final Value<String?> entryImagePath;
  final Value<String?> resultImagePath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TradesTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.dateTimeTaken = const Value.absent(),
    this.market = const Value.absent(),
    this.positionType = const Value.absent(),
    this.entryPrice = const Value.absent(),
    this.exitPrice = const Value.absent(),
    this.pnl = const Value.absent(),
    this.riskAmount = const Value.absent(),
    this.rewardAmount = const Value.absent(),
    this.entryStrategy = const Value.absent(),
    this.tags = const Value.absent(),
    this.comments = const Value.absent(),
    this.rulesFollowed = const Value.absent(),
    this.entryImagePath = const Value.absent(),
    this.resultImagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TradesTableCompanion.insert({
    required String id,
    required String userId,
    required DateTime dateTimeTaken,
    required String market,
    required String positionType,
    required double entryPrice,
    required double exitPrice,
    required double pnl,
    this.riskAmount = const Value.absent(),
    this.rewardAmount = const Value.absent(),
    this.entryStrategy = const Value.absent(),
    this.tags = const Value.absent(),
    this.comments = const Value.absent(),
    this.rulesFollowed = const Value.absent(),
    this.entryImagePath = const Value.absent(),
    this.resultImagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        dateTimeTaken = Value(dateTimeTaken),
        market = Value(market),
        positionType = Value(positionType),
        entryPrice = Value(entryPrice),
        exitPrice = Value(exitPrice),
        pnl = Value(pnl);
  static Insertable<TradeRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? dateTimeTaken,
    Expression<String>? market,
    Expression<String>? positionType,
    Expression<double>? entryPrice,
    Expression<double>? exitPrice,
    Expression<double>? pnl,
    Expression<double>? riskAmount,
    Expression<double>? rewardAmount,
    Expression<String>? entryStrategy,
    Expression<String>? tags,
    Expression<String>? comments,
    Expression<String>? rulesFollowed,
    Expression<String>? entryImagePath,
    Expression<String>? resultImagePath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (dateTimeTaken != null) 'date_time_taken': dateTimeTaken,
      if (market != null) 'market': market,
      if (positionType != null) 'position_type': positionType,
      if (entryPrice != null) 'entry_price': entryPrice,
      if (exitPrice != null) 'exit_price': exitPrice,
      if (pnl != null) 'pnl': pnl,
      if (riskAmount != null) 'risk_amount': riskAmount,
      if (rewardAmount != null) 'reward_amount': rewardAmount,
      if (entryStrategy != null) 'entry_strategy': entryStrategy,
      if (tags != null) 'tags': tags,
      if (comments != null) 'comments': comments,
      if (rulesFollowed != null) 'rules_followed': rulesFollowed,
      if (entryImagePath != null) 'entry_image_path': entryImagePath,
      if (resultImagePath != null) 'result_image_path': resultImagePath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TradesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<DateTime>? dateTimeTaken,
      Value<String>? market,
      Value<String>? positionType,
      Value<double>? entryPrice,
      Value<double>? exitPrice,
      Value<double>? pnl,
      Value<double>? riskAmount,
      Value<double>? rewardAmount,
      Value<String>? entryStrategy,
      Value<String>? tags,
      Value<String>? comments,
      Value<String>? rulesFollowed,
      Value<String?>? entryImagePath,
      Value<String?>? resultImagePath,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TradesTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateTimeTaken: dateTimeTaken ?? this.dateTimeTaken,
      market: market ?? this.market,
      positionType: positionType ?? this.positionType,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      pnl: pnl ?? this.pnl,
      riskAmount: riskAmount ?? this.riskAmount,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      entryStrategy: entryStrategy ?? this.entryStrategy,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments,
      rulesFollowed: rulesFollowed ?? this.rulesFollowed,
      entryImagePath: entryImagePath ?? this.entryImagePath,
      resultImagePath: resultImagePath ?? this.resultImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (dateTimeTaken.present) {
      map['date_time_taken'] = Variable<DateTime>(dateTimeTaken.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (positionType.present) {
      map['position_type'] = Variable<String>(positionType.value);
    }
    if (entryPrice.present) {
      map['entry_price'] = Variable<double>(entryPrice.value);
    }
    if (exitPrice.present) {
      map['exit_price'] = Variable<double>(exitPrice.value);
    }
    if (pnl.present) {
      map['pnl'] = Variable<double>(pnl.value);
    }
    if (riskAmount.present) {
      map['risk_amount'] = Variable<double>(riskAmount.value);
    }
    if (rewardAmount.present) {
      map['reward_amount'] = Variable<double>(rewardAmount.value);
    }
    if (entryStrategy.present) {
      map['entry_strategy'] = Variable<String>(entryStrategy.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (comments.present) {
      map['comments'] = Variable<String>(comments.value);
    }
    if (rulesFollowed.present) {
      map['rules_followed'] = Variable<String>(rulesFollowed.value);
    }
    if (entryImagePath.present) {
      map['entry_image_path'] = Variable<String>(entryImagePath.value);
    }
    if (resultImagePath.present) {
      map['result_image_path'] = Variable<String>(resultImagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradesTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dateTimeTaken: $dateTimeTaken, ')
          ..write('market: $market, ')
          ..write('positionType: $positionType, ')
          ..write('entryPrice: $entryPrice, ')
          ..write('exitPrice: $exitPrice, ')
          ..write('pnl: $pnl, ')
          ..write('riskAmount: $riskAmount, ')
          ..write('rewardAmount: $rewardAmount, ')
          ..write('entryStrategy: $entryStrategy, ')
          ..write('tags: $tags, ')
          ..write('comments: $comments, ')
          ..write('rulesFollowed: $rulesFollowed, ')
          ..write('entryImagePath: $entryImagePath, ')
          ..write('resultImagePath: $resultImagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTableTable extends TagsTable
    with TableInfo<$TagsTableTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES user_profiles_table (id)'));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#3498DB'));
  @override
  List<GeneratedColumn> get $columns => [id, userId, label, colorHex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags_table';
  @override
  VerificationContext validateIntegrity(Insertable<TagRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
    );
  }

  @override
  $TagsTableTable createAlias(String alias) {
    return $TagsTableTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String userId;
  final String label;
  final String colorHex;
  const TagRow(
      {required this.id,
      required this.userId,
      required this.label,
      required this.colorHex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['label'] = Variable<String>(label);
    map['color_hex'] = Variable<String>(colorHex);
    return map;
  }

  TagsTableCompanion toCompanion(bool nullToAbsent) {
    return TagsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      label: Value(label),
      colorHex: Value(colorHex),
    );
  }

  factory TagRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      label: serializer.fromJson<String>(json['label']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'label': serializer.toJson<String>(label),
      'colorHex': serializer.toJson<String>(colorHex),
    };
  }

  TagRow copyWith(
          {String? id, String? userId, String? label, String? colorHex}) =>
      TagRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        label: label ?? this.label,
        colorHex: colorHex ?? this.colorHex,
      );
  TagRow copyWithCompanion(TagsTableCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      label: data.label.present ? data.label.value : this.label,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('colorHex: $colorHex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, label, colorHex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.label == this.label &&
          other.colorHex == this.colorHex);
}

class TagsTableCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> label;
  final Value<String> colorHex;
  final Value<int> rowid;
  const TagsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.label = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsTableCompanion.insert({
    required String id,
    required String userId,
    required String label,
    this.colorHex = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        label = Value(label);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? label,
    Expression<String>? colorHex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (label != null) 'label': label,
      if (colorHex != null) 'color_hex': colorHex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? label,
      Value<String>? colorHex,
      Value<int>? rowid}) {
    return TagsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      colorHex: colorHex ?? this.colorHex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('colorHex: $colorHex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationSettingsTableTable extends NotificationSettingsTable
    with TableInfo<$NotificationSettingsTableTable, NotificationSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dailyReminderEnabledMeta =
      const VerificationMeta('dailyReminderEnabled');
  @override
  late final GeneratedColumn<bool> dailyReminderEnabled = GeneratedColumn<bool>(
      'daily_reminder_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("daily_reminder_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _reminderHourMeta =
      const VerificationMeta('reminderHour');
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
      'reminder_hour', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(20));
  static const VerificationMeta _reminderMinuteMeta =
      const VerificationMeta('reminderMinute');
  @override
  late final GeneratedColumn<int> reminderMinute = GeneratedColumn<int>(
      'reminder_minute', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _summaryEnabledMeta =
      const VerificationMeta('summaryEnabled');
  @override
  late final GeneratedColumn<bool> summaryEnabled = GeneratedColumn<bool>(
      'summary_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("summary_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, dailyReminderEnabled, reminderHour, reminderMinute, summaryEnabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<NotificationSettingsRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('daily_reminder_enabled')) {
      context.handle(
          _dailyReminderEnabledMeta,
          dailyReminderEnabled.isAcceptableOrUnknown(
              data['daily_reminder_enabled']!, _dailyReminderEnabledMeta));
    }
    if (data.containsKey('reminder_hour')) {
      context.handle(
          _reminderHourMeta,
          reminderHour.isAcceptableOrUnknown(
              data['reminder_hour']!, _reminderHourMeta));
    }
    if (data.containsKey('reminder_minute')) {
      context.handle(
          _reminderMinuteMeta,
          reminderMinute.isAcceptableOrUnknown(
              data['reminder_minute']!, _reminderMinuteMeta));
    }
    if (data.containsKey('summary_enabled')) {
      context.handle(
          _summaryEnabledMeta,
          summaryEnabled.isAcceptableOrUnknown(
              data['summary_enabled']!, _summaryEnabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationSettingsRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationSettingsRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dailyReminderEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}daily_reminder_enabled'])!,
      reminderHour: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reminder_hour'])!,
      reminderMinute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reminder_minute'])!,
      summaryEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}summary_enabled'])!,
    );
  }

  @override
  $NotificationSettingsTableTable createAlias(String alias) {
    return $NotificationSettingsTableTable(attachedDatabase, alias);
  }
}

class NotificationSettingsRow extends DataClass
    implements Insertable<NotificationSettingsRow> {
  final String id;
  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool summaryEnabled;
  const NotificationSettingsRow(
      {required this.id,
      required this.dailyReminderEnabled,
      required this.reminderHour,
      required this.reminderMinute,
      required this.summaryEnabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['daily_reminder_enabled'] = Variable<bool>(dailyReminderEnabled);
    map['reminder_hour'] = Variable<int>(reminderHour);
    map['reminder_minute'] = Variable<int>(reminderMinute);
    map['summary_enabled'] = Variable<bool>(summaryEnabled);
    return map;
  }

  NotificationSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationSettingsTableCompanion(
      id: Value(id),
      dailyReminderEnabled: Value(dailyReminderEnabled),
      reminderHour: Value(reminderHour),
      reminderMinute: Value(reminderMinute),
      summaryEnabled: Value(summaryEnabled),
    );
  }

  factory NotificationSettingsRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationSettingsRow(
      id: serializer.fromJson<String>(json['id']),
      dailyReminderEnabled:
          serializer.fromJson<bool>(json['dailyReminderEnabled']),
      reminderHour: serializer.fromJson<int>(json['reminderHour']),
      reminderMinute: serializer.fromJson<int>(json['reminderMinute']),
      summaryEnabled: serializer.fromJson<bool>(json['summaryEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dailyReminderEnabled': serializer.toJson<bool>(dailyReminderEnabled),
      'reminderHour': serializer.toJson<int>(reminderHour),
      'reminderMinute': serializer.toJson<int>(reminderMinute),
      'summaryEnabled': serializer.toJson<bool>(summaryEnabled),
    };
  }

  NotificationSettingsRow copyWith(
          {String? id,
          bool? dailyReminderEnabled,
          int? reminderHour,
          int? reminderMinute,
          bool? summaryEnabled}) =>
      NotificationSettingsRow(
        id: id ?? this.id,
        dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
        reminderHour: reminderHour ?? this.reminderHour,
        reminderMinute: reminderMinute ?? this.reminderMinute,
        summaryEnabled: summaryEnabled ?? this.summaryEnabled,
      );
  NotificationSettingsRow copyWithCompanion(
      NotificationSettingsTableCompanion data) {
    return NotificationSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      dailyReminderEnabled: data.dailyReminderEnabled.present
          ? data.dailyReminderEnabled.value
          : this.dailyReminderEnabled,
      reminderHour: data.reminderHour.present
          ? data.reminderHour.value
          : this.reminderHour,
      reminderMinute: data.reminderMinute.present
          ? data.reminderMinute.value
          : this.reminderMinute,
      summaryEnabled: data.summaryEnabled.present
          ? data.summaryEnabled.value
          : this.summaryEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsRow(')
          ..write('id: $id, ')
          ..write('dailyReminderEnabled: $dailyReminderEnabled, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('summaryEnabled: $summaryEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, dailyReminderEnabled, reminderHour, reminderMinute, summaryEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationSettingsRow &&
          other.id == this.id &&
          other.dailyReminderEnabled == this.dailyReminderEnabled &&
          other.reminderHour == this.reminderHour &&
          other.reminderMinute == this.reminderMinute &&
          other.summaryEnabled == this.summaryEnabled);
}

class NotificationSettingsTableCompanion
    extends UpdateCompanion<NotificationSettingsRow> {
  final Value<String> id;
  final Value<bool> dailyReminderEnabled;
  final Value<int> reminderHour;
  final Value<int> reminderMinute;
  final Value<bool> summaryEnabled;
  final Value<int> rowid;
  const NotificationSettingsTableCompanion({
    this.id = const Value.absent(),
    this.dailyReminderEnabled = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.summaryEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationSettingsTableCompanion.insert({
    required String id,
    this.dailyReminderEnabled = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.summaryEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<NotificationSettingsRow> custom({
    Expression<String>? id,
    Expression<bool>? dailyReminderEnabled,
    Expression<int>? reminderHour,
    Expression<int>? reminderMinute,
    Expression<bool>? summaryEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyReminderEnabled != null)
        'daily_reminder_enabled': dailyReminderEnabled,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
      if (summaryEnabled != null) 'summary_enabled': summaryEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationSettingsTableCompanion copyWith(
      {Value<String>? id,
      Value<bool>? dailyReminderEnabled,
      Value<int>? reminderHour,
      Value<int>? reminderMinute,
      Value<bool>? summaryEnabled,
      Value<int>? rowid}) {
    return NotificationSettingsTableCompanion(
      id: id ?? this.id,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      summaryEnabled: summaryEnabled ?? this.summaryEnabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dailyReminderEnabled.present) {
      map['daily_reminder_enabled'] =
          Variable<bool>(dailyReminderEnabled.value);
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    if (reminderMinute.present) {
      map['reminder_minute'] = Variable<int>(reminderMinute.value);
    }
    if (summaryEnabled.present) {
      map['summary_enabled'] = Variable<bool>(summaryEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('dailyReminderEnabled: $dailyReminderEnabled, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('summaryEnabled: $summaryEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTableTable userProfilesTable =
      $UserProfilesTableTable(this);
  late final $TradesTableTable tradesTable = $TradesTableTable(this);
  late final $TagsTableTable tagsTable = $TagsTableTable(this);
  late final $NotificationSettingsTableTable notificationSettingsTable =
      $NotificationSettingsTableTable(this);
  late final UserProfileDao userProfileDao =
      UserProfileDao(this as AppDatabase);
  late final TradeDao tradeDao = TradeDao(this as AppDatabase);
  late final TagDao tagDao = TagDao(this as AppDatabase);
  late final NotificationSettingsDao notificationSettingsDao =
      NotificationSettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [userProfilesTable, tradesTable, tagsTable, notificationSettingsTable];
}

typedef $$UserProfilesTableTableCreateCompanionBuilder
    = UserProfilesTableCompanion Function({
  required String id,
  required String name,
  Value<String> avatarColorHex,
  Value<double> balance,
  Value<String> accountType,
  Value<double> dailyPermittedLossPercent,
  Value<double> maxPermittedLossPercent,
  Value<bool> pinEnabled,
  Value<bool> biometricEnabled,
  Value<int> lockAfterSeconds,
  Value<String> defaultMarkets,
  Value<String> calendarStartDay,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$UserProfilesTableTableUpdateCompanionBuilder
    = UserProfilesTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> avatarColorHex,
  Value<double> balance,
  Value<String> accountType,
  Value<double> dailyPermittedLossPercent,
  Value<double> maxPermittedLossPercent,
  Value<bool> pinEnabled,
  Value<bool> biometricEnabled,
  Value<int> lockAfterSeconds,
  Value<String> defaultMarkets,
  Value<String> calendarStartDay,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$UserProfilesTableTableReferences extends BaseReferences<
    _$AppDatabase, $UserProfilesTableTable, UserProfileRow> {
  $$UserProfilesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TradesTableTable, List<TradeRow>>
      _tradesTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tradesTable,
              aliasName: $_aliasNameGenerator(
                  db.userProfilesTable.id, db.tradesTable.userId));

  $$TradesTableTableProcessedTableManager get tradesTableRefs {
    final manager = $$TradesTableTableTableManager($_db, $_db.tradesTable)
        .filter((f) => f.userId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tradesTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TagsTableTable, List<TagRow>> _tagsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tagsTable,
          aliasName: $_aliasNameGenerator(
              db.userProfilesTable.id, db.tagsTable.userId));

  $$TagsTableTableProcessedTableManager get tagsTableRefs {
    final manager = $$TagsTableTableTableManager($_db, $_db.tagsTable)
        .filter((f) => f.userId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tagsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UserProfilesTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTableTable> {
  $$UserProfilesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarColorHex => $composableBuilder(
      column: $table.avatarColorHex,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get dailyPermittedLossPercent => $composableBuilder(
      column: $table.dailyPermittedLossPercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxPermittedLossPercent => $composableBuilder(
      column: $table.maxPermittedLossPercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pinEnabled => $composableBuilder(
      column: $table.pinEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lockAfterSeconds => $composableBuilder(
      column: $table.lockAfterSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultMarkets => $composableBuilder(
      column: $table.defaultMarkets,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get calendarStartDay => $composableBuilder(
      column: $table.calendarStartDay,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> tradesTableRefs(
      Expression<bool> Function($$TradesTableTableFilterComposer f) f) {
    final $$TradesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tradesTable,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TradesTableTableFilterComposer(
              $db: $db,
              $table: $db.tradesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tagsTableRefs(
      Expression<bool> Function($$TagsTableTableFilterComposer f) f) {
    final $$TagsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tagsTable,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableTableFilterComposer(
              $db: $db,
              $table: $db.tagsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UserProfilesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTableTable> {
  $$UserProfilesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarColorHex => $composableBuilder(
      column: $table.avatarColorHex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get dailyPermittedLossPercent => $composableBuilder(
      column: $table.dailyPermittedLossPercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxPermittedLossPercent => $composableBuilder(
      column: $table.maxPermittedLossPercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pinEnabled => $composableBuilder(
      column: $table.pinEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lockAfterSeconds => $composableBuilder(
      column: $table.lockAfterSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultMarkets => $composableBuilder(
      column: $table.defaultMarkets,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get calendarStartDay => $composableBuilder(
      column: $table.calendarStartDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UserProfilesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTableTable> {
  $$UserProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarColorHex => $composableBuilder(
      column: $table.avatarColorHex, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => column);

  GeneratedColumn<double> get dailyPermittedLossPercent => $composableBuilder(
      column: $table.dailyPermittedLossPercent, builder: (column) => column);

  GeneratedColumn<double> get maxPermittedLossPercent => $composableBuilder(
      column: $table.maxPermittedLossPercent, builder: (column) => column);

  GeneratedColumn<bool> get pinEnabled => $composableBuilder(
      column: $table.pinEnabled, builder: (column) => column);

  GeneratedColumn<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled, builder: (column) => column);

  GeneratedColumn<int> get lockAfterSeconds => $composableBuilder(
      column: $table.lockAfterSeconds, builder: (column) => column);

  GeneratedColumn<String> get defaultMarkets => $composableBuilder(
      column: $table.defaultMarkets, builder: (column) => column);

  GeneratedColumn<String> get calendarStartDay => $composableBuilder(
      column: $table.calendarStartDay, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> tradesTableRefs<T extends Object>(
      Expression<T> Function($$TradesTableTableAnnotationComposer a) f) {
    final $$TradesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tradesTable,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TradesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.tradesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> tagsTableRefs<T extends Object>(
      Expression<T> Function($$TagsTableTableAnnotationComposer a) f) {
    final $$TagsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tagsTable,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.tagsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UserProfilesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfilesTableTable,
    UserProfileRow,
    $$UserProfilesTableTableFilterComposer,
    $$UserProfilesTableTableOrderingComposer,
    $$UserProfilesTableTableAnnotationComposer,
    $$UserProfilesTableTableCreateCompanionBuilder,
    $$UserProfilesTableTableUpdateCompanionBuilder,
    (UserProfileRow, $$UserProfilesTableTableReferences),
    UserProfileRow,
    PrefetchHooks Function({bool tradesTableRefs, bool tagsTableRefs})> {
  $$UserProfilesTableTableTableManager(
      _$AppDatabase db, $UserProfilesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> avatarColorHex = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<String> accountType = const Value.absent(),
            Value<double> dailyPermittedLossPercent = const Value.absent(),
            Value<double> maxPermittedLossPercent = const Value.absent(),
            Value<bool> pinEnabled = const Value.absent(),
            Value<bool> biometricEnabled = const Value.absent(),
            Value<int> lockAfterSeconds = const Value.absent(),
            Value<String> defaultMarkets = const Value.absent(),
            Value<String> calendarStartDay = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesTableCompanion(
            id: id,
            name: name,
            avatarColorHex: avatarColorHex,
            balance: balance,
            accountType: accountType,
            dailyPermittedLossPercent: dailyPermittedLossPercent,
            maxPermittedLossPercent: maxPermittedLossPercent,
            pinEnabled: pinEnabled,
            biometricEnabled: biometricEnabled,
            lockAfterSeconds: lockAfterSeconds,
            defaultMarkets: defaultMarkets,
            calendarStartDay: calendarStartDay,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> avatarColorHex = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<String> accountType = const Value.absent(),
            Value<double> dailyPermittedLossPercent = const Value.absent(),
            Value<double> maxPermittedLossPercent = const Value.absent(),
            Value<bool> pinEnabled = const Value.absent(),
            Value<bool> biometricEnabled = const Value.absent(),
            Value<int> lockAfterSeconds = const Value.absent(),
            Value<String> defaultMarkets = const Value.absent(),
            Value<String> calendarStartDay = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesTableCompanion.insert(
            id: id,
            name: name,
            avatarColorHex: avatarColorHex,
            balance: balance,
            accountType: accountType,
            dailyPermittedLossPercent: dailyPermittedLossPercent,
            maxPermittedLossPercent: maxPermittedLossPercent,
            pinEnabled: pinEnabled,
            biometricEnabled: biometricEnabled,
            lockAfterSeconds: lockAfterSeconds,
            defaultMarkets: defaultMarkets,
            calendarStartDay: calendarStartDay,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserProfilesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {tradesTableRefs = false, tagsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tradesTableRefs) db.tradesTable,
                if (tagsTableRefs) db.tagsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tradesTableRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$UserProfilesTableTableReferences
                            ._tradesTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UserProfilesTableTableReferences(db, table, p0)
                                .tradesTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (tagsTableRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$UserProfilesTableTableReferences
                            ._tagsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UserProfilesTableTableReferences(db, table, p0)
                                .tagsTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UserProfilesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfilesTableTable,
    UserProfileRow,
    $$UserProfilesTableTableFilterComposer,
    $$UserProfilesTableTableOrderingComposer,
    $$UserProfilesTableTableAnnotationComposer,
    $$UserProfilesTableTableCreateCompanionBuilder,
    $$UserProfilesTableTableUpdateCompanionBuilder,
    (UserProfileRow, $$UserProfilesTableTableReferences),
    UserProfileRow,
    PrefetchHooks Function({bool tradesTableRefs, bool tagsTableRefs})>;
typedef $$TradesTableTableCreateCompanionBuilder = TradesTableCompanion
    Function({
  required String id,
  required String userId,
  required DateTime dateTimeTaken,
  required String market,
  required String positionType,
  required double entryPrice,
  required double exitPrice,
  required double pnl,
  Value<double> riskAmount,
  Value<double> rewardAmount,
  Value<String> entryStrategy,
  Value<String> tags,
  Value<String> comments,
  Value<String> rulesFollowed,
  Value<String?> entryImagePath,
  Value<String?> resultImagePath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$TradesTableTableUpdateCompanionBuilder = TradesTableCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<DateTime> dateTimeTaken,
  Value<String> market,
  Value<String> positionType,
  Value<double> entryPrice,
  Value<double> exitPrice,
  Value<double> pnl,
  Value<double> riskAmount,
  Value<double> rewardAmount,
  Value<String> entryStrategy,
  Value<String> tags,
  Value<String> comments,
  Value<String> rulesFollowed,
  Value<String?> entryImagePath,
  Value<String?> resultImagePath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$TradesTableTableReferences
    extends BaseReferences<_$AppDatabase, $TradesTableTable, TradeRow> {
  $$TradesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserProfilesTableTable _userIdTable(_$AppDatabase db) =>
      db.userProfilesTable.createAlias(
          $_aliasNameGenerator(db.tradesTable.userId, db.userProfilesTable.id));

  $$UserProfilesTableTableProcessedTableManager? get userId {
    if ($_item.userId == null) return null;
    final manager =
        $$UserProfilesTableTableTableManager($_db, $_db.userProfilesTable)
            .filter((f) => f.id($_item.userId!));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TradesTableTableFilterComposer
    extends Composer<_$AppDatabase, $TradesTableTable> {
  $$TradesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateTimeTaken => $composableBuilder(
      column: $table.dateTimeTaken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get market => $composableBuilder(
      column: $table.market, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get positionType => $composableBuilder(
      column: $table.positionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get entryPrice => $composableBuilder(
      column: $table.entryPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exitPrice => $composableBuilder(
      column: $table.exitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pnl => $composableBuilder(
      column: $table.pnl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get riskAmount => $composableBuilder(
      column: $table.riskAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rewardAmount => $composableBuilder(
      column: $table.rewardAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryStrategy => $composableBuilder(
      column: $table.entryStrategy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comments => $composableBuilder(
      column: $table.comments, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rulesFollowed => $composableBuilder(
      column: $table.rulesFollowed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryImagePath => $composableBuilder(
      column: $table.entryImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultImagePath => $composableBuilder(
      column: $table.resultImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$UserProfilesTableTableFilterComposer get userId {
    final $$UserProfilesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.userProfilesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableTableFilterComposer(
              $db: $db,
              $table: $db.userProfilesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TradesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TradesTableTable> {
  $$TradesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateTimeTaken => $composableBuilder(
      column: $table.dateTimeTaken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get market => $composableBuilder(
      column: $table.market, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get positionType => $composableBuilder(
      column: $table.positionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get entryPrice => $composableBuilder(
      column: $table.entryPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exitPrice => $composableBuilder(
      column: $table.exitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pnl => $composableBuilder(
      column: $table.pnl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get riskAmount => $composableBuilder(
      column: $table.riskAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rewardAmount => $composableBuilder(
      column: $table.rewardAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryStrategy => $composableBuilder(
      column: $table.entryStrategy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comments => $composableBuilder(
      column: $table.comments, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rulesFollowed => $composableBuilder(
      column: $table.rulesFollowed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryImagePath => $composableBuilder(
      column: $table.entryImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultImagePath => $composableBuilder(
      column: $table.resultImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$UserProfilesTableTableOrderingComposer get userId {
    final $$UserProfilesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.userProfilesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableTableOrderingComposer(
              $db: $db,
              $table: $db.userProfilesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TradesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TradesTableTable> {
  $$TradesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dateTimeTaken => $composableBuilder(
      column: $table.dateTimeTaken, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get positionType => $composableBuilder(
      column: $table.positionType, builder: (column) => column);

  GeneratedColumn<double> get entryPrice => $composableBuilder(
      column: $table.entryPrice, builder: (column) => column);

  GeneratedColumn<double> get exitPrice =>
      $composableBuilder(column: $table.exitPrice, builder: (column) => column);

  GeneratedColumn<double> get pnl =>
      $composableBuilder(column: $table.pnl, builder: (column) => column);

  GeneratedColumn<double> get riskAmount => $composableBuilder(
      column: $table.riskAmount, builder: (column) => column);

  GeneratedColumn<double> get rewardAmount => $composableBuilder(
      column: $table.rewardAmount, builder: (column) => column);

  GeneratedColumn<String> get entryStrategy => $composableBuilder(
      column: $table.entryStrategy, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get comments =>
      $composableBuilder(column: $table.comments, builder: (column) => column);

  GeneratedColumn<String> get rulesFollowed => $composableBuilder(
      column: $table.rulesFollowed, builder: (column) => column);

  GeneratedColumn<String> get entryImagePath => $composableBuilder(
      column: $table.entryImagePath, builder: (column) => column);

  GeneratedColumn<String> get resultImagePath => $composableBuilder(
      column: $table.resultImagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UserProfilesTableTableAnnotationComposer get userId {
    final $$UserProfilesTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.userId,
            referencedTable: $db.userProfilesTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$UserProfilesTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.userProfilesTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$TradesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TradesTableTable,
    TradeRow,
    $$TradesTableTableFilterComposer,
    $$TradesTableTableOrderingComposer,
    $$TradesTableTableAnnotationComposer,
    $$TradesTableTableCreateCompanionBuilder,
    $$TradesTableTableUpdateCompanionBuilder,
    (TradeRow, $$TradesTableTableReferences),
    TradeRow,
    PrefetchHooks Function({bool userId})> {
  $$TradesTableTableTableManager(_$AppDatabase db, $TradesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TradesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TradesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TradesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> dateTimeTaken = const Value.absent(),
            Value<String> market = const Value.absent(),
            Value<String> positionType = const Value.absent(),
            Value<double> entryPrice = const Value.absent(),
            Value<double> exitPrice = const Value.absent(),
            Value<double> pnl = const Value.absent(),
            Value<double> riskAmount = const Value.absent(),
            Value<double> rewardAmount = const Value.absent(),
            Value<String> entryStrategy = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String> comments = const Value.absent(),
            Value<String> rulesFollowed = const Value.absent(),
            Value<String?> entryImagePath = const Value.absent(),
            Value<String?> resultImagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TradesTableCompanion(
            id: id,
            userId: userId,
            dateTimeTaken: dateTimeTaken,
            market: market,
            positionType: positionType,
            entryPrice: entryPrice,
            exitPrice: exitPrice,
            pnl: pnl,
            riskAmount: riskAmount,
            rewardAmount: rewardAmount,
            entryStrategy: entryStrategy,
            tags: tags,
            comments: comments,
            rulesFollowed: rulesFollowed,
            entryImagePath: entryImagePath,
            resultImagePath: resultImagePath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required DateTime dateTimeTaken,
            required String market,
            required String positionType,
            required double entryPrice,
            required double exitPrice,
            required double pnl,
            Value<double> riskAmount = const Value.absent(),
            Value<double> rewardAmount = const Value.absent(),
            Value<String> entryStrategy = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String> comments = const Value.absent(),
            Value<String> rulesFollowed = const Value.absent(),
            Value<String?> entryImagePath = const Value.absent(),
            Value<String?> resultImagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TradesTableCompanion.insert(
            id: id,
            userId: userId,
            dateTimeTaken: dateTimeTaken,
            market: market,
            positionType: positionType,
            entryPrice: entryPrice,
            exitPrice: exitPrice,
            pnl: pnl,
            riskAmount: riskAmount,
            rewardAmount: rewardAmount,
            entryStrategy: entryStrategy,
            tags: tags,
            comments: comments,
            rulesFollowed: rulesFollowed,
            entryImagePath: entryImagePath,
            resultImagePath: resultImagePath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TradesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$TradesTableTableReferences._userIdTable(db),
                    referencedColumn:
                        $$TradesTableTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TradesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TradesTableTable,
    TradeRow,
    $$TradesTableTableFilterComposer,
    $$TradesTableTableOrderingComposer,
    $$TradesTableTableAnnotationComposer,
    $$TradesTableTableCreateCompanionBuilder,
    $$TradesTableTableUpdateCompanionBuilder,
    (TradeRow, $$TradesTableTableReferences),
    TradeRow,
    PrefetchHooks Function({bool userId})>;
typedef $$TagsTableTableCreateCompanionBuilder = TagsTableCompanion Function({
  required String id,
  required String userId,
  required String label,
  Value<String> colorHex,
  Value<int> rowid,
});
typedef $$TagsTableTableUpdateCompanionBuilder = TagsTableCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> label,
  Value<String> colorHex,
  Value<int> rowid,
});

final class $$TagsTableTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTableTable, TagRow> {
  $$TagsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserProfilesTableTable _userIdTable(_$AppDatabase db) =>
      db.userProfilesTable.createAlias(
          $_aliasNameGenerator(db.tagsTable.userId, db.userProfilesTable.id));

  $$UserProfilesTableTableProcessedTableManager? get userId {
    if ($_item.userId == null) return null;
    final manager =
        $$UserProfilesTableTableTableManager($_db, $_db.userProfilesTable)
            .filter((f) => f.id($_item.userId!));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TagsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TagsTableTable> {
  $$TagsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  $$UserProfilesTableTableFilterComposer get userId {
    final $$UserProfilesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.userProfilesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableTableFilterComposer(
              $db: $db,
              $table: $db.userProfilesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TagsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TagsTableTable> {
  $$TagsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  $$UserProfilesTableTableOrderingComposer get userId {
    final $$UserProfilesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.userProfilesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserProfilesTableTableOrderingComposer(
              $db: $db,
              $table: $db.userProfilesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TagsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTableTable> {
  $$TagsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  $$UserProfilesTableTableAnnotationComposer get userId {
    final $$UserProfilesTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.userId,
            referencedTable: $db.userProfilesTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$UserProfilesTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.userProfilesTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$TagsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTableTable,
    TagRow,
    $$TagsTableTableFilterComposer,
    $$TagsTableTableOrderingComposer,
    $$TagsTableTableAnnotationComposer,
    $$TagsTableTableCreateCompanionBuilder,
    $$TagsTableTableUpdateCompanionBuilder,
    (TagRow, $$TagsTableTableReferences),
    TagRow,
    PrefetchHooks Function({bool userId})> {
  $$TagsTableTableTableManager(_$AppDatabase db, $TagsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsTableCompanion(
            id: id,
            userId: userId,
            label: label,
            colorHex: colorHex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String label,
            Value<String> colorHex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsTableCompanion.insert(
            id: id,
            userId: userId,
            label: label,
            colorHex: colorHex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TagsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$TagsTableTableReferences._userIdTable(db),
                    referencedColumn:
                        $$TagsTableTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TagsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTableTable,
    TagRow,
    $$TagsTableTableFilterComposer,
    $$TagsTableTableOrderingComposer,
    $$TagsTableTableAnnotationComposer,
    $$TagsTableTableCreateCompanionBuilder,
    $$TagsTableTableUpdateCompanionBuilder,
    (TagRow, $$TagsTableTableReferences),
    TagRow,
    PrefetchHooks Function({bool userId})>;
typedef $$NotificationSettingsTableTableCreateCompanionBuilder
    = NotificationSettingsTableCompanion Function({
  required String id,
  Value<bool> dailyReminderEnabled,
  Value<int> reminderHour,
  Value<int> reminderMinute,
  Value<bool> summaryEnabled,
  Value<int> rowid,
});
typedef $$NotificationSettingsTableTableUpdateCompanionBuilder
    = NotificationSettingsTableCompanion Function({
  Value<String> id,
  Value<bool> dailyReminderEnabled,
  Value<int> reminderHour,
  Value<int> reminderMinute,
  Value<bool> summaryEnabled,
  Value<int> rowid,
});

class $$NotificationSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTableTable> {
  $$NotificationSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dailyReminderEnabled => $composableBuilder(
      column: $table.dailyReminderEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderHour => $composableBuilder(
      column: $table.reminderHour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderMinute => $composableBuilder(
      column: $table.reminderMinute,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get summaryEnabled => $composableBuilder(
      column: $table.summaryEnabled,
      builder: (column) => ColumnFilters(column));
}

class $$NotificationSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTableTable> {
  $$NotificationSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dailyReminderEnabled => $composableBuilder(
      column: $table.dailyReminderEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderHour => $composableBuilder(
      column: $table.reminderHour,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderMinute => $composableBuilder(
      column: $table.reminderMinute,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get summaryEnabled => $composableBuilder(
      column: $table.summaryEnabled,
      builder: (column) => ColumnOrderings(column));
}

class $$NotificationSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTableTable> {
  $$NotificationSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get dailyReminderEnabled => $composableBuilder(
      column: $table.dailyReminderEnabled, builder: (column) => column);

  GeneratedColumn<int> get reminderHour => $composableBuilder(
      column: $table.reminderHour, builder: (column) => column);

  GeneratedColumn<int> get reminderMinute => $composableBuilder(
      column: $table.reminderMinute, builder: (column) => column);

  GeneratedColumn<bool> get summaryEnabled => $composableBuilder(
      column: $table.summaryEnabled, builder: (column) => column);
}

class $$NotificationSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationSettingsTableTable,
    NotificationSettingsRow,
    $$NotificationSettingsTableTableFilterComposer,
    $$NotificationSettingsTableTableOrderingComposer,
    $$NotificationSettingsTableTableAnnotationComposer,
    $$NotificationSettingsTableTableCreateCompanionBuilder,
    $$NotificationSettingsTableTableUpdateCompanionBuilder,
    (
      NotificationSettingsRow,
      BaseReferences<_$AppDatabase, $NotificationSettingsTableTable,
          NotificationSettingsRow>
    ),
    NotificationSettingsRow,
    PrefetchHooks Function()> {
  $$NotificationSettingsTableTableTableManager(
      _$AppDatabase db, $NotificationSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationSettingsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationSettingsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationSettingsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<bool> dailyReminderEnabled = const Value.absent(),
            Value<int> reminderHour = const Value.absent(),
            Value<int> reminderMinute = const Value.absent(),
            Value<bool> summaryEnabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationSettingsTableCompanion(
            id: id,
            dailyReminderEnabled: dailyReminderEnabled,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute,
            summaryEnabled: summaryEnabled,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<bool> dailyReminderEnabled = const Value.absent(),
            Value<int> reminderHour = const Value.absent(),
            Value<int> reminderMinute = const Value.absent(),
            Value<bool> summaryEnabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationSettingsTableCompanion.insert(
            id: id,
            dailyReminderEnabled: dailyReminderEnabled,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute,
            summaryEnabled: summaryEnabled,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotificationSettingsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $NotificationSettingsTableTable,
        NotificationSettingsRow,
        $$NotificationSettingsTableTableFilterComposer,
        $$NotificationSettingsTableTableOrderingComposer,
        $$NotificationSettingsTableTableAnnotationComposer,
        $$NotificationSettingsTableTableCreateCompanionBuilder,
        $$NotificationSettingsTableTableUpdateCompanionBuilder,
        (
          NotificationSettingsRow,
          BaseReferences<_$AppDatabase, $NotificationSettingsTableTable,
              NotificationSettingsRow>
        ),
        NotificationSettingsRow,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableTableManager get userProfilesTable =>
      $$UserProfilesTableTableTableManager(_db, _db.userProfilesTable);
  $$TradesTableTableTableManager get tradesTable =>
      $$TradesTableTableTableManager(_db, _db.tradesTable);
  $$TagsTableTableTableManager get tagsTable =>
      $$TagsTableTableTableManager(_db, _db.tagsTable);
  $$NotificationSettingsTableTableTableManager get notificationSettingsTable =>
      $$NotificationSettingsTableTableTableManager(
          _db, _db.notificationSettingsTable);
}
