import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/tag.dart';
import '../models/trade.dart';
import '../models/user_profile.dart';
import '../repositories/trade_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../services/file_service.dart';
import 'backup_image_data.dart';
import 'backup_file_reader.dart';

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
    final tags = await _profileRepo.getTagsForUser(userId);
    final tradeData = await Future.wait(trades.map(_tradeToJson));

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': _profileToJson(profile),
      'trades': tradeData,
      'tags': tags.map(_tagToJson).toList(),
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
      final tags = await _profileRepo.getTagsForUser(p.id);
      final tradeData = await Future.wait(trades.map(_tradeToJson));
      allData.add({
        'profile': _profileToJson(p),
        'trades': tradeData,
        'tags': tags.map(_tagToJson).toList(),
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

  Future<BackupImportResult> importBackup(String filePath) async {
    final content = await readBackupFile(filePath);
    return importBackupContent(content);
  }

  Future<BackupImportResult> importBackupBytes(List<int> bytes) async {
    final content = utf8.decode(bytes);
    return importBackupContent(content);
  }

  Future<BackupImportResult> importBackupContent(String content) async {
    final data = jsonDecode(content) as Map<String, dynamic>;

    final result = BackupImportResult();
    if (data.containsKey('users')) {
      // All-users backup
      for (final userData in data['users'] as List) {
        await _importUserData(userData as Map<String, dynamic>, result);
      }
    } else if (data.containsKey('profile')) {
      // Single user backup
      await _importUserData(data, result);
    } else {
      throw Exception('Invalid backup file: missing profile or users data.');
    }
    return result;
  }

  Future<void> _importUserData(
    Map<String, dynamic> data,
    BackupImportResult result,
  ) async {
    final profile = _profileFromJson(data['profile'] as Map<String, dynamic>);
    await _profileRepo.upsertProfile(profile);
    result.profileIds.add(profile.id);
    result.profileCount++;

    final tags = (data['tags'] as List?) ?? const [];
    for (final tagJson in tags) {
      final tag = _tagFromJson(tagJson as Map<String, dynamic>);
      await _profileRepo.upsertTag(tag);
      result.tagCount++;
    }

    final trades = (data['trades'] as List?) ?? const [];
    for (final tradeJson in trades) {
      final trade = _tradeFromJson(tradeJson as Map<String, dynamic>);
      await _tradeRepo.upsertTrade(trade);
      result.tradeCount++;
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

  Map<String, dynamic> _tagToJson(Tag tag) => {
        'id': tag.id,
        'userId': tag.userId,
        'label': tag.label,
        'colorHex': tag.colorHex,
      };

  Tag _tagFromJson(Map<String, dynamic> j) => Tag(
        id: j['id'] as String,
        userId: j['userId'] as String,
        label: j['label'] as String,
        colorHex: j['colorHex'] as String,
      );

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

  Future<Map<String, dynamic>> _tradeToJson(Trade t) async => {
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
        'entryImageData': await imagePathToDataUrl(t.entryImagePath),
        'resultImageData': await imagePathToDataUrl(t.resultImagePath),
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
        entryImagePath: (j['entryImageData'] as String?) ??
            (j['entryImagePath'] as String?),
        resultImagePath: (j['resultImageData'] as String?) ??
            (j['resultImagePath'] as String?),
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

class BackupImportResult {
  final List<String> profileIds = [];
  int profileCount = 0;
  int tradeCount = 0;
  int tagCount = 0;

  String? get firstProfileId =>
      profileIds.isEmpty ? null : profileIds.first;
}
