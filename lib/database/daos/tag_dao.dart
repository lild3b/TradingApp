import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'tag_dao.g.dart';

@DriftAccessor(tables: [TagsTable])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Future<List<TagRow>> getTagsByUser(String userId) =>
      (select(tagsTable)..where((t) => t.userId.equals(userId))).get();

  Stream<List<TagRow>> watchTagsByUser(String userId) =>
      (select(tagsTable)..where((t) => t.userId.equals(userId))).watch();

  Future<int> insertTag(TagsTableCompanion entry) =>
      into(tagsTable).insert(entry);

  Future<bool> updateTag(TagsTableCompanion entry) =>
      update(tagsTable).replace(entry);

  Future<int> deleteTag(String id) =>
      (delete(tagsTable)..where((t) => t.id.equals(id))).go();

  Future<int> deleteTagsByUser(String userId) =>
      (delete(tagsTable)..where((t) => t.userId.equals(userId))).go();
}
