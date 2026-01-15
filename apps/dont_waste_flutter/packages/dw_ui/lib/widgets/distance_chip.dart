import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Chip showing distance to listing
class DistanceChip extends StatelessWidget {
  final double distanceKm;

  const DistanceChip({
    super.key,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on,
            size: 12,
            color: Colors.white,
          ),
          AppSpacing.hGapXs,
          Text(
            _formatDistance(),
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance() {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toInt()}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.toInt()}km';
    }
  }
}
