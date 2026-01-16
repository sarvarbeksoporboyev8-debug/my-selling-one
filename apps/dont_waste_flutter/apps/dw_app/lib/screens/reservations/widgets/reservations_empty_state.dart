import 'package:flutter/material.dart';
import 'package:dw_ui/dw_ui.dart';

import 'reservations_filter_bar.dart';

class ReservationsEmptyState extends StatelessWidget {
  final ReservationTab tab;
  final VoidCallback? onAction;

  const ReservationsEmptyState({
    super.key,
    required this.tab,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, title, message, actionLabel, color) = _getContent(tab);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DwDarkTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: color.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: DwDarkTheme.spacingLg),

            // Title
            Text(
              title,
              style: DwDarkTheme.headlineSmall.copyWith(
                color: DwDarkTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DwDarkTheme.spacingSm),

            // Message
            Text(
              message,
              style: DwDarkTheme.bodyMedium.copyWith(
                color: DwDarkTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: DwDarkTheme.spacingLg),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DwDarkTheme.spacingLg,
                      vertical: DwDarkTheme.spacingMd,
                    ),
                    decoration: BoxDecoration(
                      gradient: DwDarkTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: DwDarkTheme.accent.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.explore_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: DwDarkTheme.spacingSm),
                        Text(
                          actionLabel,
                          style: DwDarkTheme.titleSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (IconData, String, String, String?, Color) _getContent(ReservationTab tab) {
    return switch (tab) {
      ReservationTab.upcoming => (
          Icons.receipt_long_outlined,
          'No upcoming reservations',
          'Browse the marketplace to find surplus inventory and make your first reservation.',
          'Browse Discover',
          DwDarkTheme.accent,
        ),
      ReservationTab.completed => (
          Icons.check_circle_outline,
          'No completed reservations',
          'Your completed orders will appear here once you pick them up.',
          null,
          DwDarkTheme.accentGreen,
        ),
      ReservationTab.cancelled => (
          Icons.cancel_outlined,
          'No cancelled reservations',
          'Cancelled reservations will appear here.',
          null,
          DwDarkTheme.textMuted,
        ),
    };
  }
}

class ReservationsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ReservationsErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DwDarkTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF85149).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 36,
                color: const Color(0xFFF85149).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: DwDarkTheme.spacingLg),

            // Title
            Text(
              'Something went wrong',
              style: DwDarkTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DwDarkTheme.spacingSm),

            // Message
            Text(
              message,
              style: DwDarkTheme.bodyMedium.copyWith(
                color: DwDarkTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: DwDarkTheme.spacingLg),

            // Retry button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DwDarkTheme.spacingLg,
                    vertical: DwDarkTheme.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    color: DwDarkTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
                    border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh,
                        size: 18,
                        color: DwDarkTheme.textSecondary,
                      ),
                      const SizedBox(width: DwDarkTheme.spacingSm),
                      Text(
                        'Try Again',
                        style: DwDarkTheme.titleSmall.copyWith(
                          color: DwDarkTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
