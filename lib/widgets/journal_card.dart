import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trade.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class JournalCard extends StatelessWidget {
  const JournalCard({
    super.key,
    required this.trade,
    required this.onTap,
  });

  final Trade trade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pnlColor = trade.pnl > 0
        ? AppColors.profit
        : trade.pnl < 0
            ? AppColors.loss
            : AppColors.neutral;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Market + position chip
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        trade.market,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      _PositionChip(positionType: trade.positionType),
                    ],
                  ),
                ),
                // PnL
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pnlColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppFormatters.pnl(trade.pnl),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: pnlColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              AppFormatters.dateTime(trade.dateTimeTaken),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            if (trade.entryStrategy.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                trade.entryStrategy,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (trade.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              _TagsRow(tags: trade.tags),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _RulesIcon(rulesFollowed: trade.rulesFollowed),
                const SizedBox(width: 6),
                Text(
                  _rulesLabel(trade.rulesFollowed),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'R:R ${AppFormatters.rrRatio(trade.rrRatio)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _rulesLabel(RulesFollowed r) {
    switch (r) {
      case RulesFollowed.yes:
        return 'Rules followed';
      case RulesFollowed.partial:
        return 'Partially followed';
      case RulesFollowed.no:
        return 'Rules broken';
    }
  }
}

class _PositionChip extends StatelessWidget {
  const _PositionChip({required this.positionType});
  final PositionType positionType;

  @override
  Widget build(BuildContext context) {
    final isLong = positionType == PositionType.long;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isLong ? AppColors.longPosition : AppColors.shortPosition).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isLong ? 'Long' : 'Short',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isLong ? AppColors.longPosition : AppColors.shortPosition,
        ),
      ),
    );
  }
}

class _TagsRow extends StatelessWidget {
  const _TagsRow({required this.tags});
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final visible = tags.take(3).toList();
    final extra = tags.length - visible.length;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ...visible.map((tag) => _TagBubble(label: tag)),
        if (extra > 0)
          _TagBubble(label: '+$extra', muted: true),
      ],
    );
  }
}

class _TagBubble extends StatelessWidget {
  const _TagBubble({required this.label, this.muted = false});
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: muted
            ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: muted
              ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
              : AppColors.primary,
        ),
      ),
    );
  }
}

class _RulesIcon extends StatelessWidget {
  const _RulesIcon({required this.rulesFollowed});
  final RulesFollowed rulesFollowed;

  @override
  Widget build(BuildContext context) {
    switch (rulesFollowed) {
      case RulesFollowed.yes:
        return const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.profit);
      case RulesFollowed.partial:
        return const Icon(Icons.remove_circle_rounded, size: 14, color: AppColors.warningYellow);
      case RulesFollowed.no:
        return const Icon(Icons.cancel_rounded, size: 14, color: AppColors.loss);
    }
  }
}
