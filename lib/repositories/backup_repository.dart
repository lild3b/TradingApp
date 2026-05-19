import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import '../models/user_profile.dart';
import '../repositories/trade_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../services/file_service.dart';

class BackupRepository {
  BackupRepository({
    required TradeRepository tradeRepository,
    required UserProfileRepository profileRepository,
    required FileService fileService,
  })  : _tradeRepo = tradeRepository,
        _profileRepo = profileRepository,
        _fileService = fileService;

  final TradeRepository _tradeRepo;
  final UserProfileRepository _profileRepo;
  final FileService _fileService;

  Future<String> exportUserBackup(String userId) async {
    final profile = await _profileRepo.getProfileById(userId);
    if (profile == null) throw Exception('Profile not found');
    final trades = await _tradeRepo.getTradesByUser(userId);

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': _profileToJson(profile),
      'trades': trades.map(_tradeToJson).toList(),
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = utf8.encode(json);
    final filename =
        'backup_${profile.name}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';
    final path = await _fileService.saveFile(
        filename: filename, bytes: bytes, mimeType: 'application/json');
    return path ?? '';
  }

  Future<String> exportAllUsersBackup() async {
    final profiles = await _profileRepo.getAllProfiles();
    final allData = <Map<String, dynamic>>[];

    for (final p in profiles) {
      final trades = await _tradeRepo.getTradesByUser(p.id);
      allData.add({
        'profile': _profileToJson(p),
        'trades': trades.map(_tradeToJson).toList(),
      });
    }

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'users': allData,
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = utf8.encode(json);
    final filename =
        'backup_all_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';
    final path = await _fileService.saveFile(
        filename: filename, bytes: bytes, mimeType: 'application/json');
    return path ?? '';
  }

  Future<void> importBackup(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    if (data.containsKey('users')) {
      // All-users backup
      for (final userData in data['users'] as List) {
        await _importUserData(userData as Map<String, dynamic>);
      }
    } else if (data.containsKey('profile')) {
      // Single user backup
      await _importUserData(data);
    }
  }

  Future<void> _importUserData(Map<String, dynamic> data) async {
    final profile = _profileFromJson(data['profile'] as Map<String, dynamic>);
    await _profileRepo.createProfile(profile);

    for (final tradeJson in data['trades'] as List) {
      final trade = _tradeFromJson(tradeJson as Map<String, dynamic>);
      await _tradeRepo.insertTrade(trade);
    }
  }

  Map<String, dynamic> _profileToJson(UserProfile p) => {
        'id': p.id,
        'name': p.name,
        'avatarColorHex': p.avatarColorHex,
        'balance': p.balance,
        'accountType':
            p.accountType == AccountType.propFirm ? 'propFirm' : 'personal',
        'dailyPermittedLossPercent': p.dailyPermittedLossPercent,
        'maxPermittedLossPercent': p.maxPermittedLossPercent,
        'pinEnabled': p.pinEnabled,
        'biometricEnabled': p.biometricEnabled,
        'lockAfterSeconds': p.lockAfterSeconds,
        'defaultMarkets': p.defaultMarkets,
        'calendarStartDay': p.calendarStartDay == CalendarStartDay.monday
            ? 'monday'
            : 'sunday',
        'createdAt': p.createdAt.toIso8601String(),
      };

  UserProfile _profileFromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        avatarColorHex: j['avatarColorHex'] as String,
        balance: (j['balance'] as num).toDouble(),
        accountType: j['accountType'] == 'propFirm'
            ? AccountType.propFirm
            : AccountType.personal,
        dailyPermittedLossPercent:
            (j['dailyPermittedLossPercent'] as num).toDouble(),
        maxPermittedLossPercent:
            (j['maxPermittedLossPercent'] as num).toDouble(),
        pinEnabled: j['pinEnabled'] as bool,
        biometricEnabled: j['biometricEnabled'] as bool,
        lockAfterSeconds: j['lockAfterSeconds'] as int,
        defaultMarkets: List<String>.from(j['defaultMarkets'] as List),
        calendarStartDay: j['calendarStartDay'] == 'monday'
            ? CalendarStartDay.monday
            : CalendarStartDay.sunday,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  Map<String, dynamic> _tradeToJson(Trade t) => {
        'id': t.id,
        'userId': t.userId,
        'dateTimeTaken': t.dateTimeTaken.toIso8601String(),
        'market': t.market,
        'positionType': t.positionType == PositionType.long ? 'long' : 'short',
        'entryPrice': t.entryPrice,
        'exitPrice': t.exitPrice,
        'pnl': t.pnl,
        'riskAmount': t.riskAmount,
        'rewardAmount': t.rewardAmount,
        'entryStrategy': t.entryStrategy,
        'tags': t.tags,
        'comments': t.comments,
        'rulesFollowed': t.rulesFollowed.name,
        'entryImagePath': t.entryImagePath,
        'resultImagePath': t.resultImagePath,
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
      };

  Trade _tradeFromJson(Map<String, dynamic> j) => Trade(
        id: j['id'] as String,
        userId: j['userId'] as String,
        dateTimeTaken: DateTime.parse(j['dateTimeTaken'] as String),
        market: j['market'] as String,
        positionType: j['positionType'] == 'short'
            ? PositionType.short
            : PositionType.long,
        entryPrice: (j['entryPrice'] as num).toDouble(),
        exitPrice: (j['exitPrice'] as num).toDouble(),
        pnl: (j['pnl'] as num).toDouble(),
        riskAmount: (j['riskAmount'] as num).toDouble(),
        rewardAmount: (j['rewardAmount'] as num).toDouble(),
        entryStrategy: j['entryStrategy'] as String,
        tags: List<String>.from(j['tags'] as List),
        comments: j['comments'] as String,
        rulesFollowed: _parseRulesFollowed(j['rulesFollowed'] as String),
        entryImagePath: j['entryImagePath'] as String?,
        resultImagePath: j['resultImagePath'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );

  RulesFollowed _parseRulesFollowed(String s) {
    switch (s) {
      case 'partial':
        return RulesFollowed.partial;
      case 'no':
        return RulesFollowed.no;
      default:
        return RulesFollowed.yes;
    }
  }
}
