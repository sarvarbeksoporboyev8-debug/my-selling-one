import 'package:flutter/material.dart';
import 'package:dw_ui/dw_ui.dart';

class ProfileCompletionCard extends StatelessWidget {
  final VoidCallback onComplete;
  final int completionPercent;

  const ProfileCompletionCard({
    super.key,
    required this.onComplete,
    this.completionPercent = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DwDarkTheme.accentOrange.withOpacity(0.15),
            DwDarkTheme.accentOrange.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        border: Border.all(
          color: DwDarkTheme.accentOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Progress indicator
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: completionPercent / 100,
                  strokeWidth: 4,
                  backgroundColor: DwDarkTheme.surfaceHighlight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DwDarkTheme.accentOrange,
                  ),
                ),
                Text(
                  '$completionPercent%',
                  style: DwDarkTheme.labelSmall.copyWith(
                    color: DwDarkTheme.accentOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DwDarkTheme.spacingMd),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Your Profile',
                  style: DwDarkTheme.titleSmall.copyWith(
                    color: DwDarkTheme.accentOrange,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Add business details to unlock all features',
                  style: DwDarkTheme.bodySmall.copyWith(
                    color: DwDarkTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Action button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onComplete,
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DwDarkTheme.spacingSm + 4,
                  vertical: DwDarkTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: DwDarkTheme.accentOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                ),
                child: Text(
                  'Complete',
                  style: DwDarkTheme.labelMedium.copyWith(
                    color: DwDarkTheme.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
