import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

class ToolsHubScreen extends StatelessWidget {
  const ToolsHubScreen({super.key});

  static const _tools = [
    _Tool(
      icon: Icons.calculate_outlined,
      label: 'Risk Calculator',
      subtitle: 'Position sizing & R:R',
      route: '/tools/risk-calculator',
      color: AppColors.primary,
    ),
    _Tool(
      icon: Icons.local_fire_department_rounded,
      label: 'Win/Loss Streaks',
      subtitle: '90-day performance heatmap',
      route: '/tools/streak',
      color: AppColors.profit,
    ),
    _Tool(
      icon: Icons.cloud_download_outlined,
      label: 'Backup & Restore',
      subtitle: 'Export & import your data',
      route: '/tools/backup',
      color: AppColors.warningYellow,
    ),
    _Tool(
      icon: Icons.settings_outlined,
      label: 'Settings',
      subtitle: 'Profile, security, preferences',
      route: '/tools/settings',
      color: AppColors.neutral,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: LayoutBuilder(builder: (context, constraints) {
        final cols = constraints.maxWidth >= 600 ? 2 : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: cols == 2 ? 2.2 : 3.5,
          ),
          itemCount: _tools.length,
          itemBuilder: (context, i) => _ToolCard(tool: _tools[i]),
        );
      }),
    );
  }
}

class _Tool {
  const _Tool({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final String route;
  final Color color;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});
  final _Tool tool;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(tool.route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(tool.icon, color: tool.color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tool.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tool.subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}
