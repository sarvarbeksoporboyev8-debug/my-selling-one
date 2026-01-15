import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Chip for displaying status
class StatusChip extends StatelessWidget {
  final String status;
  final StatusType type;

  const StatusChip({
    super.key,
    required this.status,
    this.type = StatusType.reservation,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: colors.border),
      ),
      child: Text(
        _formatStatus(),
        style: AppTypography.labelSmall.copyWith(
          color: colors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatStatus() {
    return status.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  _StatusColors _getColors() {
    switch (status.toLowerCase()) {
      case 'active':
        return _StatusColors(
          background: AppColors.statusActive.withOpacity(0.1),
          border: AppColors.statusActive.withOpacity(0.3),
          text: AppColors.statusActive,
        );
      case 'pending':
        return _StatusColors(
          background: AppColors.statusPending.withOpacity(0.1),
          border: AppColors.statusPending.withOpacity(0.3),
          text: AppColors.statusPending,
        );
      case 'accepted':
        return _StatusColors(
          background: AppColors.statusAccepted.withOpacity(0.1),
          border: AppColors.statusAccepted.withOpacity(0.3),
          text: AppColors.statusAccepted,
        );
      case 'rejected':
      case 'cancelled':
        return _StatusColors(
          background: AppColors.statusRejected.withOpacity(0.1),
          border: AppColors.statusRejected.withOpacity(0.3),
          text: AppColors.statusRejected,
        );
      case 'expired':
        return _StatusColors(
          background: AppColors.statusExpired.withOpacity(0.1),
          border: AppColors.statusExpired.withOpacity(0.3),
          text: AppColors.statusExpired,
        );
      case 'converted':
        return _StatusColors(
          background: AppColors.primary.withOpacity(0.1),
          border: AppColors.primary.withOpacity(0.3),
          text: AppColors.primary,
        );
      default:
        return _StatusColors(
          background: AppColors.surfaceVariant,
          border: AppColors.border,
          text: AppColors.textSecondary,
        );
    }
  }
}

class _StatusColors {
  final Color background;
  final Color border;
  final Color text;

  const _StatusColors({
    required this.background,
    required this.border,
    required this.text,
  });
}

enum StatusType {
  reservation,
  offer,
  listing,
}
