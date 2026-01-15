import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Alias for EmptyState with Dw prefix
typedef DwEmptyState = EmptyState;

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  final String? message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.message,
    this.actionText,
    this.onAction,
    this.action,
  });

  // Preset empty states
  factory EmptyState.noListings({VoidCallback? onRefresh}) {
    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No listings found',
      subtitle: 'Try adjusting your filters or search area',
      actionText: 'Refresh',
      onAction: onRefresh,
    );
  }

  factory EmptyState.noReservations({VoidCallback? onExplore}) {
    return EmptyState(
      icon: Icons.bookmark_border,
      title: 'No reservations yet',
      subtitle: 'Reserve surplus items to see them here',
      actionText: 'Explore Listings',
      onAction: onExplore,
    );
  }

  factory EmptyState.noWatches({VoidCallback? onCreate}) {
    return EmptyState(
      icon: Icons.notifications_none,
      title: 'No watchlists',
      subtitle: 'Create a watchlist to get notified about matching deals',
      actionText: 'Create Watch',
      onAction: onCreate,
    );
  }

  factory EmptyState.noSearchResults({VoidCallback? onClear}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No results',
      subtitle: 'Try different search terms or filters',
      actionText: 'Clear Filters',
      onAction: onClear,
    );
  }

  factory EmptyState.locationRequired({VoidCallback? onEnable}) {
    return EmptyState(
      icon: Icons.location_off,
      title: 'Location required',
      subtitle: 'Enable location to find nearby surplus deals',
      actionText: 'Enable Location',
      onAction: onEnable,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            AppSpacing.vGapXxl,
            Text(
              title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null || message != null) ...[
              AppSpacing.vGapSm,
              Text(
                subtitle ?? message ?? '',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: DwSpacing.xl),
              action!,
            ] else if (actionText != null && onAction != null) ...[
              AppSpacing.vGapXxl,
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
