import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/calendar/calendar_bloc.dart';
import '../../blocs/trade/trade_bloc.dart';
import '../../blocs/user_profile/user_profile_bloc.dart';
import '../../models/monthly_stats.dart';
import '../../models/trade.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/calendar_cell.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/empty_state.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final profile = _getProfile();
    if (profile == null) return;
    final now = DateTime.now();
    context.read<CalendarBloc>().add(LoadCalendarMonth(
          userId: profile,
          year: now.year,
          month: now.month,
        ));
  }

  String? _getProfile() {
    final state = context.read<UserProfileBloc>().state;
    if (state is ProfileSelected) return state.selectedProfile.id;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PnL Calendar')),
      body: BlocConsumer<CalendarBloc, CalendarState>(
        listener: (context, state) {
          if (state is DateSelected) {
            _showDaySheet(context, state.date);
          }
        },
        builder: (context, state) {
          if (state is CalendarLoading) {
            return const ShimmerCard(height: 400);
          }
          CalendarLoaded? cal;
          if (state is CalendarLoaded) cal = state;
          if (state is DateSelected) cal = state.calendarData;
          if (cal == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Monthly stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _MonthlyStats(stats: cal.monthlyStats),
                ),
                const SizedBox(height: 8),
                // Month navigator
                _MonthHeader(cal: cal, userId: _getProfile() ?? ''),
                const SizedBox(height: 16),
                // Calendar grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _CalendarGrid(cal: cal),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDaySheet(BuildContext context, DateTime date) {
    final userId = _getProfile() ?? '';
    context.read<TradeBloc>().add(LoadTradesByDate(userId: userId, date: date));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<TradeBloc>()),
          BlocProvider.value(value: context.read<CalendarBloc>()),
        ],
        child: _DaySheet(date: date),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.cal, required this.userId});
  final CalendarLoaded cal;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => context
                .read<CalendarBloc>()
                .add(NavigateToPreviousMonth(userId)),
          ),
          Expanded(
            child: Text(
              AppFormatters.monthYear(
                  DateTime(cal.currentYear, cal.currentMonth)),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () =>
                context.read<CalendarBloc>().add(NavigateToNextMonth(userId)),
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.cal});
  final CalendarLoaded cal;

  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(cal.currentYear, cal.currentMonth, 1);
    final daysInMonth = DateTime(cal.currentYear, cal.currentMonth + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // 0=Sun
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final today = DateTime.now();

    return Column(
      children: [
        // Weekday headers
        Row(
          children: _weekdays
              .map((d) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        // Day cells
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: rows * 7,
          itemBuilder: (context, index) {
            final dayNum = index - startOffset + 1;
            if (dayNum < 1 || dayNum > daysInMonth) {
              return const SizedBox.shrink();
            }
            final date = DateTime(cal.currentYear, cal.currentMonth, dayNum);
            final pnl = cal.dailyPnlMap[date];
            final isToday = today.year == date.year &&
                today.month == date.month &&
                today.day == date.day;

            return CalendarCell(
              day: dayNum,
              pnl: pnl,
              tradeCount: cal.dailyTradeCountMap?[date] ?? 0,
              isToday: isToday,
              isCurrentMonth: true,
              onTap: () => context.read<CalendarBloc>().add(SelectDate(date)),
            );
          },
        ),
      ],
    );
  }
}

class _MonthlyStats extends StatelessWidget {
  const _MonthlyStats({required this.stats});
  final MonthlyStats stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Summary',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatTile('Trading Days', '${stats.totalTradingDays}'),
              _StatTile('Total PnL', AppFormatters.pnl(stats.totalPnl),
                  color:
                      stats.totalPnl >= 0 ? AppColors.profit : AppColors.loss),
              _StatTile('Best Day', AppFormatters.pnl(stats.bestDay),
                  color: AppColors.profit),
              _StatTile('Worst Day', AppFormatters.pnl(stats.worstDay),
                  color: AppColors.loss),
              _StatTile('Win Rate', AppFormatters.percent(stats.winRate)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.label, this.value, {this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _DaySheet extends StatelessWidget {
  const _DaySheet({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  AppFormatters.date(date),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<TradeBloc, TradeState>(
              builder: (context, state) {
                if (state is TradesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final trades = state is TradesLoaded ? state.trades : <Trade>[];
                if (trades.isEmpty) {
                  return const EmptyState(
                    icon: Icons.bar_chart_rounded,
                    title: 'No trades',
                    subtitle: 'No trades logged for this day',
                  );
                }
                final totalPnl = trades.fold(0.0, (s, t) => s + t.pnl);
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: trades.length,
                        itemBuilder: (_, i) {
                          final t = trades[i];
                          return ListTile(
                            title: Text(t.market,
                                style: Theme.of(context).textTheme.titleSmall),
                            subtitle:
                                Text(AppFormatters.timeOnly(t.dateTimeTaken)),
                            trailing: Text(
                              AppFormatters.pnl(t.pnl),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: t.pnl >= 0
                                    ? AppColors.profit
                                    : AppColors.loss,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              context.push('/journal/trade/${t.id}');
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).colorScheme.surface,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Daily Total',
                              style: Theme.of(context).textTheme.titleSmall),
                          Text(
                            AppFormatters.pnl(totalPnl),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: totalPnl >= 0
                                  ? AppColors.profit
                                  : AppColors.loss,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
