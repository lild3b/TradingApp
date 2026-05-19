import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../blocs/streak/streak_bloc.dart';
import '../../../blocs/user_profile/user_profile_bloc.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/animated_counter.dart';
import '../../../widgets/heatmap_grid.dart';
import '../../../widgets/shimmer_card.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  @override
  void initState() {
    super.initState();
    final profileState = context.read<UserProfileBloc>().state;
    if (profileState is ProfileSelected) {
      context.read<StreakBloc>().add(LoadStreaks(profileState.selectedProfile.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Win/Loss Streaks')),
      body: BlocBuilder<StreakBloc, StreakState>(
        builder: (context, state) {
          if (state is StreaksLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ShimmerCard(height: 140),
                  SizedBox(height: 16),
                  ShimmerCard(height: 300),
                ],
              ),
            );
          }
          if (state is StreaksLoaded) {
            final d = state.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current streak cards
                  LayoutBuilder(builder: (context, c) {
                    final cols = c.maxWidth >= 600 ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        _StreakCard(
                          label: 'Win Streak',
                          value: d.currentWinStreak,
                          color: AppColors.profit,
                          emoji: '🔥',
                        ),
                        _StreakCard(
                          label: 'Best Win Streak',
                          value: d.longestWinStreak,
                          color: AppColors.profit,
                          emoji: '🏆',
                        ),
                        _StreakCard(
                          label: 'Loss Streak',
                          value: d.currentLossStreak,
                          color: AppColors.loss,
                          emoji: '📉',
                        ),
                        _StreakCard(
                          label: 'Worst Loss Streak',
                          value: d.longestLossStreak,
                          color: AppColors.loss,
                          emoji: '⚠️',
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                  // Heatmap
                  _HeatmapSection(data: d.last90DaysMap),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.label,
    required this.value,
    required this.color,
    required this.emoji,
  });

  final String label;
  final int value;
  final Color color;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          AnimatedCounter(
            value: value,
            style: GoogleFonts.dmSans(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HeatmapSection extends StatelessWidget {
  const _HeatmapSection({required this.data});
  final Map<DateTime, String> data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 90 Days', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Each square = one trading day',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 16),
          HeatmapGrid(data: data),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: AppColors.profit, label: 'Win'),
              const SizedBox(width: 16),
              _LegendItem(color: AppColors.loss, label: 'Loss'),
              const SizedBox(width: 16),
              _LegendItem(
                color: AppColors.neutral.withValues(alpha: 0.3),
                label: 'No trades',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
