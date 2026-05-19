import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'observer.dart';
import 'services/database_service.dart';
import 'repositories/notification_repository.dart';
import 'database/daos/notification_settings_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the SQLite database singleton
  DatabaseService.instance.initialize();

  // Initialize local notifications (registers channels, permissions)
  final notificationRepo = NotificationRepository(
    dao: NotificationSettingsDao(DatabaseService.instance.database),
  );
  await notificationRepo.initialize();

  // Install BLoC debug observer
  Bloc.observer = const AppBlocObserver();

  runApp(const TradingJournalApp());
}
