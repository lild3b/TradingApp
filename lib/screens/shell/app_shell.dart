import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/chat_modal.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _destinations = [
    _NavDest(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        label: 'Dashboard',
        route: '/dashboard'),
    _NavDest(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
        label: 'Calendar',
        route: '/calendar'),
    _NavDest(
        icon: Icons.book_outlined,
        activeIcon: Icons.book_rounded,
        label: 'Journal',
        route: '/journal'),
    _NavDest(
        icon: Icons.construction_outlined,
        activeIcon: Icons.construction_rounded,
        label: 'Tools',
        route: '/tools'),
  ];

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _destinations.length; i++) {
      if (loc.startsWith(_destinations[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      if (width >= 1024)
        return _DesktopLayout(
            child: child,
            destinations: _destinations,
            selectedIndex: _selectedIndex(context));
      if (width >= 600)
        return _TabletLayout(
            child: child,
            destinations: _destinations,
            selectedIndex: _selectedIndex(context));
      return _MobileLayout(
          child: child,
          destinations: _destinations,
          selectedIndex: _selectedIndex(context));
    });
  }
}

class _NavDest {
  const _NavDest(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.route});
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

// ─── Mobile ───────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout(
      {required this.child,
      required this.destinations,
      required this.selectedIndex});
  final Widget child;
  final List<_NavDest> destinations;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => context.go(destinations[i].route),
        destinations: destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.activeIcon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

// ─── Tablet ───────────────────────────────────────────────────────────────────

class _TabletLayout extends StatelessWidget {
  const _TabletLayout(
      {required this.child,
      required this.destinations,
      required this.selectedIndex});
  final Widget child;
  final List<_NavDest> destinations;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 200,
            child: Column(
              children: [
                Expanded(
                  child: NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (i) =>
                        context.go(destinations[i].route),
                    destinations: destinations
                        .map((d) => NavigationRailDestination(
                              icon: Icon(d.icon),
                              selectedIcon: Icon(d.activeIcon),
                              label: Text(d.label),
                            ))
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const ChatModal(),
                        );
                      },
                      icon: const Icon(Icons.chat_rounded),
                      label: const Text('Chat'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ─── Desktop ──────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout(
      {required this.child,
      required this.destinations,
      required this.selectedIndex});
  final Widget child;
  final List<_NavDest> destinations;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 220,
            child: Drawer(
              elevation: 0,
              shape: const RoundedRectangleBorder(),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.candlestick_chart_rounded,
                            color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'TradingJournal',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: destinations.asMap().entries.map((entry) {
                          final i = entry.key;
                          final d = entry.value;
                          final selected = i == selectedIndex;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            child: ListTile(
                              leading: Icon(selected ? d.activeIcon : d.icon,
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : null),
                              title: Text(d.label,
                                  style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : null,
                                  )),
                              selected: selected,
                              selectedTileColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onTap: () => context.go(d.route),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const ChatModal(),
                          );
                        },
                        icon: const Icon(Icons.chat_rounded),
                        label: const Text('Chat'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
