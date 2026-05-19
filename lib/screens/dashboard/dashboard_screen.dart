import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/streak/streak_bloc.dart';
import '../../blocs/user_profile/user_profile_bloc.dart';
import '../../models/analytics_data.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/prop_firm_banner.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/empty_state.dart';
import '../trade_detail/trade_detail_modal.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showBarChart = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final profileState = context.read<UserProfileBloc>().state;
    if (profileState is ProfileSelected) {
      context
          .read<AnalyticsBloc>()
          .add(LoadAnalytics(profileState.selectedProfile.id));
      context
          .read<StreakBloc>()
          .add(LoadStreaks(profileState.selectedProfile.id));
    }
  }

  void _showNewTradeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const TradeDetailModal(tradeId: null),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Switch profile',
            onPressed: () =>
                context.read<UserProfileBloc>().add(const SelectProfile(null)),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewTradeModal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Trade'),
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return LayoutBuilder(builder: (ctx, c) {
              final cols = c.maxWidth >= 1024
                  ? 4
                  : c.maxWidth >= 600
                      ? 3
                      : 2;
              return ShimmerGrid(count: 10, columns: cols);
            });
          }
          if (state is AnalyticsError) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Failed to load analytics',
              subtitle: state.message,
              actionLabel: 'Retry',
              onAction: _loadData,
            );
          }
          if (state is AnalyticsLoaded) {
            return _DashboardContent(
              data: state.data,
              showBarChart: _showBarChart,
              onToggleChart: () =>
                  setState(() => _showBarChart = !_showBarChart),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.data,
    required this.showBarChart,
    required this.onToggleChart,
  });

  final AnalyticsData data;
  final bool showBarChart;
  final VoidCallback onToggleChart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth >= 1024
          ? 4
          : constraints.maxWidth >= 600
              ? 3
              : 2;
      return RefreshIndicator(
        onRefresh: () async {
          final profileState = context.read<UserProfileBloc>().state;
          if (profileState is ProfileSelected) {
            context
                .read<AnalyticsBloc>()
                .add(RefreshAnalytics(profileState.selectedProfile.id));
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prop firm banner
              PropFirmBanner(level: data.propFirmWarningLevel),
              // Metric cards grid
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _MetricGrid(data: data, columns: cols),
              ),
              // PnL Chart
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _ChartSection(
                  data: data,
                  showBarChart: showBarChart,
                  onToggle: onToggleChart,
                ),
              ),
              // Streak
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _StreakSection(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    });
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.data, required this.columns});
  final AnalyticsData data;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _Metric('Balance', AppFormatters.currency(data.balance),
          Icons.account_balance_wallet_outlined, null, true),
      _Metric(
          'Equity',
          AppFormatters.currency(data.equity),
          Icons.trending_up_rounded,
          data.equity >= data.balance ? AppColors.profit : AppColors.loss,
          false),
      _Metric(
          'Win Rate',
          AppFormatters.percent(data.winRate),
          Icons.percent_rounded,
          data.winRate >= 50 ? AppColors.profit : AppColors.loss,
          false),
      _Metric('Avg Profit', AppFormatters.currency(data.avgProfit),
          Icons.arrow_upward_rounded, AppColors.profit, false),
      _Metric('Avg Loss', AppFormatters.currency(data.avgLoss),
          Icons.arrow_downward_rounded, AppColors.loss, false),
      _Metric('Total Trades', '${data.totalTrades}', Icons.bar_chart_rounded,
          null, false),
      _Metric('Daily Max Loss', AppFormatters.currency(data.dailyPermittedLoss),
          Icons.warning_amber_outlined, AppColors.warningYellow, false),
      _Metric('Max Drawdown', AppFormatters.currency(data.maxPermittedLoss),
          Icons.block_rounded, AppColors.warningOrange, false),
      _Metric(
          'Daily PnL',
          AppFormatters.pnl(data.dailyProfit),
          Icons.today_rounded,
          data.dailyProfit >= 0 ? AppColors.profit : AppColors.loss,
          false),
      _Metric(
          'Profit Factor',
          data.profitFactor.toStringAsFixed(2),
          Icons.calculate_outlined,
          data.profitFactor >= 1 ? AppColors.profit : AppColors.loss,
          false),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, i) {
        final m = metrics[i];
        return MetricCard(
          label: m.label,
          value: m.value,
          icon: m.icon,
          valueColor: m.color,
          onTap: m.editable ? () => _showBalanceEdit(context) : null,
        );
      },
    );
  }

  void _showBalanceEdit(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Balance'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration:
              const InputDecoration(labelText: 'New Balance', prefixText: '\$'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null) {
                final profileState = context.read<UserProfileBloc>().state;
                if (profileState is ProfileSelected) {
                  context.read<AnalyticsBloc>().add(UpdateBalance(
                      userId: profileState.selectedProfile.id,
                      newBalance: val));
                }
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value, this.icon, this.color, this.editable);
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final bool editable;
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.data,
    required this.showBarChart,
    required this.onToggle,
  });
  final AnalyticsData data;
  final bool showBarChart;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('PnL — Last 30 Days',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              TextButton(
                onPressed: onToggle,
                child: Text(showBarChart ? 'Line' : 'Bar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: data.last30DaysPnl.isEmpty
                ? Center(
                    child: Text('No trade data yet',
                        style: Theme.of(context).textTheme.bodySmall))
                : showBarChart
                    ? _BarChart(entries: data.last30DaysPnl)
                    : _LineChart(entries: data.last30DaysPnl),
          ),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.entries});
  final List<MapEntry<DateTime, double>> entries;

  @override
  Widget build(BuildContext context) {
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
                y: 0,
                color: AppColors.neutral.withValues(alpha: 0.4),
                strokeWidth: 1),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.entries});
  final List<MapEntry<DateTime, double>> entries;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((e) {
          final pnl = e.value.value;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: pnl,
                fromY: pnl < 0 ? pnl : 0,
                color: pnl >= 0 ? AppColors.profit : AppColors.loss,
                width: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _StreakSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        if (state is StreaksLoaded) {
          final d = state.data;
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
                Text('Streaks', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StreakStat('🔥', 'Win Streak', d.currentWinStreak,
                        AppColors.profit),
                    const SizedBox(width: 12),
                    _StreakStat('📈', 'Best Ever', d.longestWinStreak,
                        AppColors.profit),
                    const SizedBox(width: 12),
                    _StreakStat('📉', 'Loss Streak', d.currentLossStreak,
                        AppColors.loss),
                    const SizedBox(width: 12),
                    _StreakStat('⬇️', 'Worst Ever', d.longestLossStreak,
                        AppColors.loss),
                  ],
                ),
                const SizedBox(height: 16),
                // Mini bar chart of last 14 days
                _Mini14DayChart(last90: d.last90DaysMap),
              ],
            ),
          );
        }
        return const ShimmerCard(height: 140);
      },
    );
  }
}

class _StreakStat extends StatelessWidget {
  const _StreakStat(this.emoji, this.label, this.value, this.color);
  final String emoji;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          Text(
            '$value',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Mini14DayChart extends StatelessWidget {
  const _Mini14DayChart({required this.last90});
  final Map<DateTime, String> last90;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final last14 = List.generate(14, (i) {
      final day = DateTime(now.year, now.month, now.day - (13 - i));
      return last90[day] ?? 'none';
    });

    final groups = last14.asMap().entries.map((e) {
      final status = e.value;
      final color = status == 'win'
          ? AppColors.profit
          : status == 'loss'
              ? AppColors.loss
              : AppColors.neutral.withValues(alpha: 0.3);
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
              toY: 1,
              color: color,
              width: 12,
              borderRadius: BorderRadius.circular(4)),
        ],
      );
    }).toList();

    return SizedBox(
      height: 40,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: groups,
          barTouchData: BarTouchData(enabled: false),
        ),
      ),
    );
  }
}
