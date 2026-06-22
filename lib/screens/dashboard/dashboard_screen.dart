import 'dart:math';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/streak/streak_bloc.dart';
import '../../blocs/user_profile/user_profile_bloc.dart';
import '../../models/analytics_data.dart';
import '../../models/user_profile.dart';
import '../../services/economic_news_service.dart';
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
      itemCount: metrics.length + 1,
      itemBuilder: (context, i) {
        if (i == metrics.length) {
          return const _HighImpactNewsTile();
        }

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

class _HighImpactNewsTile extends StatefulWidget {
  const _HighImpactNewsTile();

  @override
  State<_HighImpactNewsTile> createState() => _HighImpactNewsTileState();
}

class _HighImpactNewsTileState extends State<_HighImpactNewsTile> {
  final _service = EconomicNewsService();
  final _timeFormat = DateFormat('HH:mm');
  late final Future<List<EconomicNewsEvent>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchCalendar();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: FutureBuilder<List<EconomicNewsEvent>>(
        future: _future,
        builder: (context, snapshot) {
          final events = _upcomingHighImpact(snapshot.data ?? const []);
          final next = events.isNotEmpty ? events.first : null;
          final following = events.length > 1 ? events[1] : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.priority_high_rounded,
                    size: 14,
                    color: next == null
                        ? theme.hintColor
                        : _impactColor(next, theme),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'News',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (snapshot.hasError && next == null)
                Text(
                  'Unavailable',
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else if (next == null)
                Text(
                  snapshot.connectionState == ConnectionState.waiting
                      ? 'Loading...'
                      : 'No upcoming news',
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else ...[
                Text(
                  '${_timeFormat.format(next.dateTime!.toLocal())} ${next.currency}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _impactColor(next, theme),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  next.title.trim().isEmpty ? 'Untitled event' : next.title,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (following != null) ...[
                  const Spacer(),
                  Text(
                    'Next: ${_timeFormat.format(following.dateTime!.toLocal())} ${following.currency}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _impactColor(following, theme),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  List<EconomicNewsEvent> _upcomingHighImpact(
    List<EconomicNewsEvent> events,
  ) {
    final now = DateTime.now();
    return events.where((event) {
      final dateTime = event.dateTime?.toLocal();
      if (dateTime == null || dateTime.isBefore(now)) return false;
      final impact = event.impact.toLowerCase();
      return impact.contains('high') || impact.contains('red');
    }).toList()
      ..sort((a, b) => a.dateTime!.toLocal().compareTo(b.dateTime!.toLocal()));
  }

  Color _impactColor(EconomicNewsEvent event, ThemeData theme) {
    final impact = event.impact.toLowerCase();
    if (impact.contains('high') || impact.contains('red')) {
      return AppColors.loss;
    }
    if (impact.contains('medium') || impact.contains('yellow')) {
      return AppColors.warningYellow;
    }
    return theme.colorScheme.onSurface;
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
              Text('Account performance',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              TextButton(
                onPressed: onToggle,
                child: Text(showBarChart ? 'Line' : 'Bar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final profileState = context.watch<UserProfileBloc>().state;
            final isPropFirm = profileState is ProfileSelected &&
                profileState.selectedProfile.accountType ==
                    AccountType.propFirm;
            final startingBalance = data.balance;
            final cumulativeEntries = <MapEntry<DateTime, double>>[];
            var runningBalance = startingBalance;
            for (final entry in data.last30DaysPnl) {
              runningBalance += entry.value;
              cumulativeEntries.add(MapEntry(entry.key, runningBalance));
            }
            final dailyLossLimit = startingBalance - data.dailyPermittedLoss;
            final maxDrawdownLimit = startingBalance - data.maxPermittedLoss;
            final profitTarget = startingBalance + data.maxPermittedLoss;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _ChartBadge(
                      label: 'Equity',
                      value: AppFormatters.currency(data.equity),
                      color: AppColors.profit,
                    ),
                    _ChartBadge(
                      label: 'Account size',
                      value: AppFormatters.currency(startingBalance),
                      color: AppColors.neutral,
                    ),
                    _ChartBadge(
                      label: 'Max loss',
                      value: AppFormatters.currency(data.maxPermittedLoss),
                      color: AppColors.loss,
                    ),
                    _ChartBadge(
                      label: 'Daily max loss',
                      value: AppFormatters.currency(data.dailyPermittedLoss),
                      color: AppColors.warningYellow,
                    ),
                    _ChartBadge(
                      label: 'Profit target',
                      value: AppFormatters.currency(profitTarget),
                      color: AppColors.profit,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240,
                  child: data.last30DaysPnl.isEmpty
                      ? Center(
                          child: Text('No trade data yet',
                              style: Theme.of(context).textTheme.bodySmall))
                      : showBarChart
                          ? _BarChart(
                              entries: cumulativeEntries,
                              startingBalance: startingBalance,
                              isPropFirm: isPropFirm,
                              dailyLossLimit: dailyLossLimit,
                              maxDrawdownLimit: maxDrawdownLimit,
                              profitTargetLine:
                                  isPropFirm ? profitTarget : null,
                            )
                          : _LineChart(
                              entries: cumulativeEntries,
                              startingBalance: startingBalance,
                              isPropFirm: isPropFirm,
                              dailyLossLimit: dailyLossLimit,
                              maxDrawdownLimit: maxDrawdownLimit,
                              profitTargetLine:
                                  isPropFirm ? profitTarget : null,
                            ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.entries,
    required this.startingBalance,
    required this.isPropFirm,
    required this.dailyLossLimit,
    required this.maxDrawdownLimit,
    required this.profitTargetLine,
  });

  final List<MapEntry<DateTime, double>> entries;
  final double startingBalance;
  final bool isPropFirm;
  final double dailyLossLimit;
  final double maxDrawdownLimit;
  final double? profitTargetLine;

  double _minY() {
    final values = entries.map((e) => e.value).toList();
    final minValue = values.isEmpty ? startingBalance : values.reduce(min);
    var minY = min(startingBalance, minValue);
    if (isPropFirm) {
      minY = min(minY, dailyLossLimit);
      minY = min(minY, maxDrawdownLimit);
    }
    return minY * 0.95;
  }

  double _maxY() {
    final values = entries.map((e) => e.value).toList();
    final maxValue = values.isEmpty ? startingBalance : values.reduce(max);
    var maxY = max(startingBalance, maxValue);
    if (profitTargetLine != null) {
      maxY = max(maxY, profitTargetLine!);
    }
    return maxY * 1.05;
  }

  List<HorizontalLine> _buildLines() {
    final lines = <HorizontalLine>[
      HorizontalLine(
        y: startingBalance,
        color: AppColors.neutral.withValues(alpha: 0.4),
        strokeWidth: 1,
      ),
    ];

    if (isPropFirm) {
      lines.addAll([
        HorizontalLine(
          y: dailyLossLimit,
          color: AppColors.loss.withValues(alpha: 0.8),
          strokeWidth: 1.5,
          dashArray: [4, 4],
        ),
        HorizontalLine(
          y: maxDrawdownLimit,
          color: AppColors.loss.withValues(alpha: 0.95),
          strokeWidth: 2,
          dashArray: [2, 4],
        ),
      ]);
      if (profitTargetLine != null) {
        lines.add(HorizontalLine(
          y: profitTargetLine!,
          color: AppColors.profit.withValues(alpha: 0.8),
          strokeWidth: 1.5,
          dashArray: [4, 4],
        ));
      }
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gridColor = (isDark ? AppColors.darkDivider : AppColors.lightDivider)
        .withValues(alpha: 0.15);

    return LineChart(
      LineChartData(
        minY: _minY(),
        maxY: _maxY(),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: (_maxY() - _minY()) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: gridColor,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  AppFormatters.currency(value),
                  style: theme.textTheme.bodySmall,
                ),
              ),
              reservedSize: 70,
              interval: (_maxY() - _minY()) / 4,
            ),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
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
          horizontalLines: _buildLines(),
        ),
      ),
    );
  }
}

class _ChartBadge extends StatelessWidget {
  const _ChartBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.entries,
    required this.startingBalance,
    required this.isPropFirm,
    required this.dailyLossLimit,
    required this.maxDrawdownLimit,
    required this.profitTargetLine,
  });

  final List<MapEntry<DateTime, double>> entries;
  final double startingBalance;
  final bool isPropFirm;
  final double dailyLossLimit;
  final double maxDrawdownLimit;
  final double? profitTargetLine;

  double _minY() {
    final values = entries.map((e) => e.value).toList();
    final minValue = values.isEmpty ? startingBalance : values.reduce(min);
    var minY = min(startingBalance, minValue);
    if (isPropFirm) {
      minY = min(minY, dailyLossLimit);
      minY = min(minY, maxDrawdownLimit);
    }
    return minY * 0.95;
  }

  double _maxY() {
    final values = entries.map((e) => e.value).toList();
    final maxValue = values.isEmpty ? startingBalance : values.reduce(max);
    var maxY = max(startingBalance, maxValue);
    if (profitTargetLine != null) {
      maxY = max(maxY, profitTargetLine!);
    }
    return maxY * 1.05;
  }

  List<HorizontalLine> _buildLines() {
    final lines = <HorizontalLine>[
      HorizontalLine(
        y: startingBalance,
        color: AppColors.neutral.withValues(alpha: 0.4),
        strokeWidth: 1,
      ),
    ];

    if (isPropFirm) {
      lines.addAll([
        HorizontalLine(
          y: dailyLossLimit,
          color: AppColors.loss.withValues(alpha: 0.8),
          strokeWidth: 1.5,
          dashArray: [4, 4],
        ),
        HorizontalLine(
          y: maxDrawdownLimit,
          color: AppColors.loss.withValues(alpha: 0.95),
          strokeWidth: 2,
          dashArray: [2, 4],
        ),
      ]);
      if (profitTargetLine != null) {
        lines.add(HorizontalLine(
          y: profitTargetLine!,
          color: AppColors.profit.withValues(alpha: 0.8),
          strokeWidth: 1.5,
          dashArray: [4, 4],
        ));
      }
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gridColor = (isDark ? AppColors.darkDivider : AppColors.lightDivider)
        .withValues(alpha: 0.15);

    return BarChart(
      BarChartData(
        minY: _minY(),
        maxY: _maxY(),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: (_maxY() - _minY()) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: gridColor,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  AppFormatters.currency(value),
                  style: theme.textTheme.bodySmall,
                ),
              ),
              reservedSize: 70,
              interval: (_maxY() - _minY()) / 4,
            ),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((e) {
          final value = e.value.value;
          final fromY = min(startingBalance, value);
          final toY = max(startingBalance, value);
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                fromY: fromY,
                toY: toY,
                color: value >= startingBalance
                    ? AppColors.profit
                    : AppColors.loss,
                width: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          );
        }).toList(),
        extraLinesData: ExtraLinesData(
          horizontalLines: _buildLines(),
        ),
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
