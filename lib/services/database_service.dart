import '../database/app_database.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService _instance = DatabaseService._();
  static DatabaseService get instance => _instance;

  late final AppDatabase database;

  void initialize() {
    database = AppDatabase();
  }
}
