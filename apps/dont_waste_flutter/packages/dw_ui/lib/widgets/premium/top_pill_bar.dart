import 'package:flutter/material.dart';
import '../../theme/premium_theme.dart';

/// Premium top pill bar with location, info, and action button
/// Matches modern iOS-style app headers
class TopPillBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final String? trailingInfo;
  final IconData? trailingInfoIcon;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const TopPillBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon = Icons.location_on_rounded,
    this.trailingInfo,
    this.trailingInfoIcon,
    this.onLeadingTap,
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.premium;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.space16,
        vertical: PremiumTheme.space8,
      ),
      child: Row(
        children: [
          // Main pill with location/search
          Expanded(
            child: GestureDetector(
              onTap: onLeadingTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PremiumTheme.space14,
                  vertical: PremiumTheme.space10,
                ),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
                  boxShadow: theme.shadowSm,
                  border: Border.all(color: theme.border, width: 1),
                ),
                child: Row(
                  children: [
                    // Leading icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.accentLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        leadingIcon,
                        size: 18,
                        color: theme.accent,
                      ),
                    ),
                    const SizedBox(width: PremiumTheme.space10),

                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: theme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: theme.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),

                    // Trailing info (like temperature)
                    if (trailingInfo != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PremiumTheme.space8,
                          vertical: PremiumTheme.space4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surfaceSecondary,
                          borderRadius: BorderRadius.circular(PremiumTheme.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (trailingInfoIcon != null) ...[
                              Icon(
                                trailingInfoIcon,
                                size: 14,
                                color: theme.textTertiary,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              trailingInfo!,
                              style: theme.labelSmall.copyWith(
                                color: theme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: PremiumTheme.space12),

          // Notification button
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.surface,
                shape: BoxShape.circle,
                boxShadow: theme.shadowSm,
                border: Border.all(color: theme.border, width: 1),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 22,
                    color: theme.textSecondary,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: theme.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.surface, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            notificationCount > 9 ? '9+' : '$notificationCount',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
