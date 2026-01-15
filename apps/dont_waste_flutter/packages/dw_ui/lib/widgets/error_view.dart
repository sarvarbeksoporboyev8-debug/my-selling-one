import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Alias for ErrorView with Dw prefix
typedef DwErrorWidget = ErrorView;

/// Error view widget
class ErrorView extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
  });

  factory ErrorView.network({VoidCallback? onRetry}) {
    return ErrorView(
      message: 'Connection error',
      details: 'Please check your internet connection and try again',
      onRetry: onRetry,
    );
  }

  factory ErrorView.server({VoidCallback? onRetry}) {
    return ErrorView(
      message: 'Server error',
      details: 'Something went wrong on our end. Please try again later.',
      onRetry: onRetry,
    );
  }

  factory ErrorView.generic({String? message, VoidCallback? onRetry}) {
    return ErrorView(
      message: message ?? 'Something went wrong',
      details: 'Please try again',
      onRetry: onRetry,
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            AppSpacing.vGapXxl,
            Text(
              message,
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              AppSpacing.vGapSm,
              Text(
                details!,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              AppSpacing.vGapXxl,
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline error banner
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              color: AppColors.error,
            ),
        ],
      ),
    );
  }
}
