import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/user_profile/user_profile_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../screens/profile_selection/profile_selection_screen.dart';
import '../screens/lock/lock_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/trade_detail/trade_detail_screen.dart';
import '../screens/tools/tools_hub/tools_hub_screen.dart';
import '../screens/tools/risk_calculator/risk_calculator_screen.dart';
import '../screens/tools/streak/streak_screen.dart';
import '../screens/tools/backup/backup_screen.dart';
import '../screens/tools/settings/settings_screen.dart';
import '../screens/tools/settings/pin_setup_screen.dart';
import '../screens/shell/app_shell.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellKey = GlobalKey(debugLabel: 'shell');

GoRouter createRouter(BuildContext context) {
  final userProfileBloc = context.read<UserProfileBloc>();
  final authBloc = context.read<AuthBloc>();

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: _MultiListenable([
      GoRouterRefreshStream(userProfileBloc.stream),
      GoRouterRefreshStream(authBloc.stream),
    ]),
    redirect: (ctx, state) {
      final profileState = userProfileBloc.state;
      final authState = authBloc.state;
      final loc = state.uri.toString();

      // Always allow lock and profile selection
      if (loc == '/' || loc == '/lock') return null;

      // No profile selected → go to profile selection
      if (profileState is ProfilesLoading || profileState is ProfilesLoaded) {
        return '/';
      }

      // Profile selected but locked → go to lock screen
      if (profileState is ProfileSelected) {
        if (authState is AuthLocked) return '/lock';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _fade(
          state,
          const ProfileSelectionScreen(),
        ),
      ),
      GoRoute(
        path: '/lock',
        pageBuilder: (context, state) => _fade(
          state,
          const LockScreen(),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => _fade(state, const DashboardScreen()),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => _fade(state, const CalendarScreen()),
          ),
          GoRoute(
            path: '/journal',
            pageBuilder: (context, state) => _fade(state, const JournalScreen()),
          ),
          GoRoute(
            path: '/tools',
            pageBuilder: (context, state) => _fade(state, const ToolsHubScreen()),
          ),
        ],
      ),
      // Full-screen routes (no shell)
      GoRoute(
        path: '/journal/trade/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slide(state, TradeDetailScreen(tradeId: id == 'new' ? null : id));
        },
      ),
      GoRoute(
        path: '/trade/new',
        pageBuilder: (context, state) =>
            _slide(state, const TradeDetailScreen(tradeId: null)),
      ),
      GoRoute(
        path: '/tools/risk-calculator',
        pageBuilder: (context, state) =>
            _slide(state, const RiskCalculatorScreen()),
      ),
      GoRoute(
        path: '/tools/streak',
        pageBuilder: (context, state) => _slide(state, const StreakScreen()),
      ),
      GoRoute(
        path: '/tools/backup',
        pageBuilder: (context, state) => _slide(state, const BackupScreen()),
      ),
      GoRoute(
        path: '/tools/settings',
        pageBuilder: (context, state) => _slide(state, const SettingsScreen()),
      ),
      GoRoute(
        path: '/tools/settings/pin-setup',
        pageBuilder: (context, state) => _slide(state, const PinSetupScreen()),
      ),
    ],
  );
}

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, c) =>
        FadeTransition(opacity: animation, child: c),
    transitionDuration: const Duration(milliseconds: 200),
  );
}

CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, c) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: c,
    ),
    transitionDuration: const Duration(milliseconds: 280),
  );
}

/// Combines multiple [Listenable]s into one.
class _MultiListenable extends ChangeNotifier {
  _MultiListenable(this._listenables) {
    for (final l in _listenables) {
      l.addListener(notifyListeners);
    }
  }
  final List<Listenable> _listenables;

  @override
  void dispose() {
    for (final l in _listenables) {
      l.removeListener(notifyListeners);
    }
    super.dispose();
  }
}

/// Converts a BLoC stream to a [Listenable] for GoRouter refresh.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
