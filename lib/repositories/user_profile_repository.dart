import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/daos/user_profile_dao.dart';
import '../database/daos/tag_dao.dart';
import '../models/user_profile.dart';
import '../models/tag.dart';

class UserProfileRepository {
  UserProfileRepository({
    required UserProfileDao dao,
    required TagDao tagDao,
  })  : _dao = dao,
        _tagDao = tagDao;

  final UserProfileDao _dao;
  final TagDao _tagDao;

  Future<List<UserProfile>> getAllProfiles() async {
    final rows = await _dao.getAllProfiles();
    return rows.map(_fromRow).toList();
  }

  Future<UserProfile?> getProfileById(String id) async {
    final row = await _dao.getProfileById(id);
    return row != null ? _fromRow(row) : null;
  }

  Future<void> createProfile(UserProfile profile) async {
    await _dao.insertProfile(_toCompanion(profile));
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _dao.updateProfile(_toCompanion(profile));
  }

  Future<void> deleteProfile(String id) async {
    await _tagDao.deleteTagsByUser(id);
    await _dao.deleteProfile(id);
  }

  Future<List<Tag>> getTagsForUser(String userId) async {
    final rows = await _tagDao.getTagsByUser(userId);
    return rows
        .map((r) => Tag(
            id: r.id, userId: r.userId, label: r.label, colorHex: r.colorHex))
        .toList();
  }

  Future<void> createTag(Tag tag) async {
    await _tagDao.insertTag(TagsTableCompanion(
      id: Value(tag.id),
      userId: Value(tag.userId),
      label: Value(tag.label),
      colorHex: Value(tag.colorHex),
    ));
  }

  Future<void> deleteTag(String tagId) async {
    await _tagDao.deleteTag(tagId);
  }

  UserProfile _fromRow(UserProfileRow r) => UserProfile(
        id: r.id,
        name: r.name,
        avatarColorHex: r.avatarColorHex,
        balance: r.balance,
        accountType: r.accountType == 'propFirm'
            ? AccountType.propFirm
            : AccountType.personal,
        dailyPermittedLossPercent: r.dailyPermittedLossPercent,
        maxPermittedLossPercent: r.maxPermittedLossPercent,
        pinEnabled: r.pinEnabled,
        biometricEnabled: r.biometricEnabled,
        lockAfterSeconds: r.lockAfterSeconds,
        defaultMarkets: List<String>.from(jsonDecode(r.defaultMarkets)),
        calendarStartDay: r.calendarStartDay == 'monday'
            ? CalendarStartDay.monday
            : CalendarStartDay.sunday,
        createdAt: r.createdAt,
      );

  UserProfilesTableCompanion _toCompanion(UserProfile p) =>
      UserProfilesTableCompanion(
        id: Value(p.id),
        name: Value(p.name),
        avatarColorHex: Value(p.avatarColorHex),
        balance: Value(p.balance),
        accountType: Value(
            p.accountType == AccountType.propFirm ? 'propFirm' : 'personal'),
        dailyPermittedLossPercent: Value(p.dailyPermittedLossPercent),
        maxPermittedLossPercent: Value(p.maxPermittedLossPercent),
        pinEnabled: Value(p.pinEnabled),
        biometricEnabled: Value(p.biometricEnabled),
        lockAfterSeconds: Value(p.lockAfterSeconds),
        defaultMarkets: Value(jsonEncode(p.defaultMarkets)),
        calendarStartDay: Value(p.calendarStartDay == CalendarStartDay.monday
            ? 'monday'
            : 'sunday'),
        createdAt: Value(p.createdAt),
      );
}
