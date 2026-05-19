import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analytics_data.dart';
import '../theme/app_colors.dart';

class PropFirmBanner extends StatelessWidget {
  const PropFirmBanner({super.key, required this.level});
  final PropFirmWarningLevel level;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: level == PropFirmWarningLevel.none
          ? const SizedBox.shrink(key: ValueKey('none'))
          : _BannerContent(key: ValueKey(level), level: level),
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({super.key, required this.level});
  final PropFirmWarningLevel level;

  @override
  Widget build(BuildContext context) {
    final (color, icon, message) = _config();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _config() {
    switch (level) {
      case PropFirmWarningLevel.yellow:
        return (
          AppColors.warningYellow,
          Icons.warning_amber_rounded,
          'Approaching daily loss limit — trade with caution',
        );
      case PropFirmWarningLevel.orange:
        return (
          AppColors.warningOrange,
          Icons.error_outline_rounded,
          'Approaching max drawdown limit — reduce position sizes',
        );
      case PropFirmWarningLevel.red:
        return (
          AppColors.warningRed,
          Icons.block_rounded,
          'Daily loss limit reached — stop trading today',
        );
      case PropFirmWarningLevel.none:
        return (Colors.transparent, Icons.info, '');
    }
  }
}
