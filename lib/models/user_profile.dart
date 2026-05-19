import 'package:equatable/equatable.dart';

enum AccountType { personal, propFirm }

enum CalendarStartDay { sunday, monday }

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
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
    required this.createdAt,
  });

  final String id;
  final String name;
  final String avatarColorHex;
  final double balance;
  final AccountType accountType;
  final double dailyPermittedLossPercent;
  final double maxPermittedLossPercent;
  final bool pinEnabled;
  final bool biometricEnabled;
  final int lockAfterSeconds;
  final List<String> defaultMarkets;
  final CalendarStartDay calendarStartDay;
  final DateTime createdAt;

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarColorHex,
    double? balance,
    AccountType? accountType,
    double? dailyPermittedLossPercent,
    double? maxPermittedLossPercent,
    bool? pinEnabled,
    bool? biometricEnabled,
    int? lockAfterSeconds,
    List<String>? defaultMarkets,
    CalendarStartDay? calendarStartDay,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarColorHex: avatarColorHex ?? this.avatarColorHex,
      balance: balance ?? this.balance,
      accountType: accountType ?? this.accountType,
      dailyPermittedLossPercent: dailyPermittedLossPercent ?? this.dailyPermittedLossPercent,
      maxPermittedLossPercent: maxPermittedLossPercent ?? this.maxPermittedLossPercent,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      lockAfterSeconds: lockAfterSeconds ?? this.lockAfterSeconds,
      defaultMarkets: defaultMarkets ?? this.defaultMarkets,
      calendarStartDay: calendarStartDay ?? this.calendarStartDay,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id, name, avatarColorHex, balance, accountType,
    dailyPermittedLossPercent, maxPermittedLossPercent,
    pinEnabled, biometricEnabled, lockAfterSeconds,
    defaultMarkets, calendarStartDay, createdAt,
  ];
}
