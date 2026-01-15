import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Widget for displaying price with optional discount
class PriceDisplay extends StatelessWidget {
  final double currentPrice;
  final double? basePrice;
  final String currency;
  final String unit;
  final bool showPerUnit;
  final bool isLarge;

  const PriceDisplay({
    super.key,
    required this.currentPrice,
    this.basePrice,
    required this.currency,
    required this.unit,
    this.showPerUnit = true,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = basePrice != null && currentPrice < basePrice!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$currency ${currentPrice.toStringAsFixed(2)}',
              style: isLarge
                  ? AppTypography.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    )
                  : AppTypography.priceMain,
            ),
            if (showPerUnit) ...[
              AppSpacing.hGapXs,
              Text(
                '/$unit',
                style: AppTypography.bodySmall,
              ),
            ],
          ],
        ),
        if (hasDiscount) ...[
          AppSpacing.vGapXs,
          Row(
            children: [
              Text(
                '$currency ${basePrice!.toStringAsFixed(2)}',
                style: AppTypography.priceStrikethrough,
              ),
              AppSpacing.hGapSm,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondarySurface,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  '-${_calculateDiscount().toStringAsFixed(0)}%',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  double _calculateDiscount() {
    if (basePrice == null || basePrice == 0) return 0;
    return ((basePrice! - currentPrice) / basePrice! * 100);
  }
}
