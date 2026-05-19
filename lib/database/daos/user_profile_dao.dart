import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfilesTable])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  Future<List<UserProfileRow>> getAllProfiles() =>
      select(userProfilesTable).get();

  Stream<List<UserProfileRow>> watchAllProfiles() =>
      select(userProfilesTable).watch();

  Future<UserProfileRow?> getProfileById(String id) =>
      (select(userProfilesTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertProfile(UserProfilesTableCompanion entry) =>
      into(userProfilesTable).insert(entry);

  Future<bool> updateProfile(UserProfilesTableCompanion entry) =>
      update(userProfilesTable).replace(entry);

  Future<int> deleteProfile(String id) =>
      (delete(userProfilesTable)..where((t) => t.id.equals(id))).go();
}
