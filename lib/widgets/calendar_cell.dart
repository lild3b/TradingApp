import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class CalendarCell extends StatelessWidget {
  const CalendarCell({
    super.key,
    required this.day,
    required this.pnl,
    required this.tradeCount,
    required this.isToday,
    required this.isCurrentMonth,
    required this.onTap,
    this.isSelected = false,
  });

  final int day;
  final double? pnl;
  final int tradeCount;
  final bool isToday;
  final bool isCurrentMonth;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor = Colors.transparent;
    Color textColor = isCurrentMonth
        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted);

    if (pnl != null && isCurrentMonth) {
      if (pnl! > 0) {
        bgColor = AppColors.profit.withValues(alpha: isDark ? 0.25 : 0.15);
        textColor = isDark ? AppColors.profit : const Color(0xFF1A8A4A);
      } else if (pnl! < 0) {
        bgColor = AppColors.loss.withValues(alpha: isDark ? 0.25 : 0.15);
        textColor = AppColors.loss;
      }
    }

    return GestureDetector(
      onTap: isCurrentMonth ? onTap : null,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.25)
                : bgColor,
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: AppColors.primary, width: 2)
                : isSelected
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                  color: isToday ? AppColors.primary : textColor,
                ),
              ),
              if (pnl != null && pnl != 0 && isCurrentMonth) ...[
                const SizedBox(height: 2),
                Text(
                  _formatPnlValue(pnl!),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
              if (tradeCount > 0 && isCurrentMonth) ...[
                const SizedBox(height: 2),
                Text(
                  '$tradeCount ${tradeCount == 1 ? 'trade' : 'trades'}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatPnlValue(double pnl) {
    final absValue = pnl.abs();
    final formattedValue = absValue == absValue.roundToDouble()
        ? absValue.toStringAsFixed(0)
        : absValue.toStringAsFixed(2);
    return pnl >= 0 ? '+$formattedValue' : '-$formattedValue';
  }
}
