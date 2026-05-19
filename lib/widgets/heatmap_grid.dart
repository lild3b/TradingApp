import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({super.key, required this.data});
  // data: Map<DateTime, String> — 'win'/'loss'/'none'
  final Map<DateTime, String> data;

  @override
  Widget build(BuildContext context) {
    final sortedKeys = data.keys.toList()..sort();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 13, // ~7 weeks
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final day = sortedKeys[index];
        final status = data[day] ?? 'none';
        return AspectRatio(
          aspectRatio: 1,
          child: Tooltip(
            message: '${day.month}/${day.day}: $status',
            child: Container(
              decoration: BoxDecoration(
                color: _colorFor(status),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _colorFor(String status) {
    switch (status) {
      case 'win':
        return AppColors.profit.withValues(alpha: 0.75);
      case 'loss':
        return AppColors.loss.withValues(alpha: 0.75);
      default:
        return AppColors.neutral.withValues(alpha: 0.2);
    }
  }
}
