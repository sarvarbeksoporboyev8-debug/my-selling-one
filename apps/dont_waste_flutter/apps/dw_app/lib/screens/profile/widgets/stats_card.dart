import 'package:flutter/material.dart';
import 'package:dw_ui/dw_ui.dart';

class StatsCard extends StatelessWidget {
  final List<StatItem> stats;
  final Function(StatItem)? onStatTap;

  const StatsCard({
    super.key,
    required this.stats,
    this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DwDarkTheme.spacingSm,
        vertical: DwDarkTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: DwDarkTheme.cardBackground,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusLg),
        border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
      ),
      child: Row(
        children: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          final isLast = index == stats.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _StatItemWidget(
                    stat: stat,
                    onTap: onStatTap != null ? () => onStatTap!(stat) : null,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 40,
                    color: DwDarkTheme.cardBorder,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatItemWidget extends StatelessWidget {
  final StatItem stat;
  final VoidCallback? onTap;

  const _StatItemWidget({
    required this.stat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DwDarkTheme.spacingSm,
            vertical: DwDarkTheme.spacingSm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                ),
                child: Icon(
                  stat.icon,
                  size: 18,
                  color: stat.color,
                ),
              ),
              const SizedBox(height: DwDarkTheme.spacingSm),

              // Value
              Text(
                stat.value,
                style: DwDarkTheme.statValue.copyWith(
                  color: DwDarkTheme.textPrimary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 2),

              // Label
              Text(
                stat.label,
                style: DwDarkTheme.statLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatItem {
  final String id;
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatItem({
    required this.id,
    required this.value,
    required this.label,
    required this.icon,
    this.color = DwDarkTheme.accent,
  });
}
