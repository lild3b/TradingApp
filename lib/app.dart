import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'blocs/user_profile/user_profile_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/trade/trade_bloc.dart';
import 'blocs/analytics/analytics_bloc.dart';
import 'blocs/calendar/calendar_bloc.dart';
import 'blocs/journal/journal_bloc.dart';
import 'blocs/streak/streak_bloc.dart';
import 'blocs/risk_calculator/risk_calculator_bloc.dart';
import 'blocs/backup/backup_bloc.dart';
import 'blocs/notification/notification_bloc.dart';
import 'blocs/theme/theme_bloc.dart';
import 'database/app_database.dart';
import 'database/daos/user_profile_dao.dart';
import 'database/daos/trade_dao.dart';
import 'database/daos/tag_dao.dart';
import 'database/daos/notification_settings_dao.dart';
import 'repositories/user_profile_repository.dart';
import 'repositories/trade_repository.dart';
import 'repositories/analytics_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/backup_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/export_repository.dart';
import 'repositories/streak_repository.dart';
import 'services/database_service.dart';
import 'services/secure_storage_service.dart';
import 'services/file_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class TradingJournalApp extends StatefulWidget {
  const TradingJournalApp({super.key});

  @override
  State<TradingJournalApp> createState() => _TradingJournalAppState();
}

class _TradingJournalAppState extends State<TradingJournalApp> {
  // ─── Database & Services ────────────────────────────────────────────────────
  late final AppDatabase _db;
  late final UserProfileRepository _profileRepo;
  late final TradeRepository _tradeRepo;
  late final AnalyticsRepository _analyticsRepo;
  late final AuthRepository _authRepo;
  late final BackupRepository _backupRepo;
  late final NotificationRepository _notificationRepo;
  late final ExportRepository _exportRepo;
  late final StreakRepository _streakRepo;

  // ─── BLoCs ──────────────────────────────────────────────────────────────────
  late final UserProfileBloc _userProfileBloc;
  late final AuthBloc _authBloc;
  late final TradeBloc _tradeBloc;
  late final AnalyticsBloc _analyticsBloc;
  late final CalendarBloc _calendarBloc;
  late final JournalBloc _journalBloc;
  late final StreakBloc _streakBloc;
  late final RiskCalculatorBloc _riskCalculatorBloc;
  late final BackupBloc _backupBloc;
  late final NotificationBloc _notificationBloc;
  late final ThemeBloc _themeBloc;

  @override
  void initState() {
    super.initState();
    _initDependencies();
  }

  void _initDependencies() {
    _db = DatabaseService.instance.database;

    // Repositories
    _profileRepo = UserProfileRepository(
      dao: UserProfileDao(_db),
      tagDao: TagDao(_db),
    );
    _tradeRepo = TradeRepository(dao: TradeDao(_db));
    _analyticsRepo = AnalyticsRepository(tradeRepository: _tradeRepo);
    _authRepo = AuthRepository(storage: SecureStorageService.instance);
    _exportRepo = ExportRepository(fileService: FileService.instance);
    _backupRepo = BackupRepository(
      tradeRepository: _tradeRepo,
      profileRepository: _profileRepo,
      fileService: FileService.instance,
    );
    _notificationRepo = NotificationRepository(
        dao: NotificationSettingsDao(_db));
    _streakRepo = StreakRepository(tradeRepository: _tradeRepo);

    // BLoCs
    _userProfileBloc = UserProfileBloc(repository: _profileRepo);
    _authBloc = AuthBloc(repository: _authRepo);
    _tradeBloc = TradeBloc(
      tradeRepository: _tradeRepo,
      exportRepository: _exportRepo,
    );
    _analyticsBloc = AnalyticsBloc(
      analyticsRepository: _analyticsRepo,
      profileRepository: _profileRepo,
    );
    _calendarBloc = CalendarBloc(analyticsRepository: _analyticsRepo);
    _journalBloc = JournalBloc(
      tradeRepository: _tradeRepo,
      exportRepository: _exportRepo,
    );
    _streakBloc = StreakBloc(streakRepository: _streakRepo);
    _riskCalculatorBloc = RiskCalculatorBloc();
    _backupBloc = BackupBloc(
      backupRepository: _backupRepo,
    );
    _notificationBloc = NotificationBloc(
        notificationRepository: _notificationRepo);
    _themeBloc = ThemeBloc();
  }

  @override
  void dispose() {
    _userProfileBloc.close();
    _authBloc.close();
    _tradeBloc.close();
    _analyticsBloc.close();
    _calendarBloc.close();
    _journalBloc.close();
    _streakBloc.close();
    _riskCalculatorBloc.close();
    _backupBloc.close();
    _notificationBloc.close();
    _themeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _userProfileBloc),
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _tradeBloc),
        BlocProvider.value(value: _analyticsBloc),
        BlocProvider.value(value: _calendarBloc),
        BlocProvider.value(value: _journalBloc),
        BlocProvider.value(value: _streakBloc),
        BlocProvider.value(value: _riskCalculatorBloc),
        BlocProvider.value(value: _backupBloc),
        BlocProvider.value(value: _notificationBloc),
        BlocProvider.value(value: _themeBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        bloc: _themeBloc,
        builder: (context, themeState) {
          return _RouterWrapper(
            themeMode: themeState.themeMode,
            userProfileBloc: _userProfileBloc,
            authBloc: _authBloc,
          );
        },
      ),
    );
  }
}

/// Separate widget so GoRouter can access BLoCs via context.
class _RouterWrapper extends StatefulWidget {
  const _RouterWrapper({
    required this.themeMode,
    required this.userProfileBloc,
    required this.authBloc,
  });

  final ThemeMode themeMode;
  final UserProfileBloc userProfileBloc;
  final AuthBloc authBloc;

  @override
  State<_RouterWrapper> createState() => _RouterWrapperState();
}

class _RouterWrapperState extends State<_RouterWrapper> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    // Build router lazily once BLoCs are in the tree
    _router ??= createRouter(context);
    return MaterialApp.router(
      title: 'Trading Journal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: widget.themeMode,
      routerConfig: _router!,
    );
  }
}
