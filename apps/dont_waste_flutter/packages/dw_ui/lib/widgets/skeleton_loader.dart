import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Skeleton loader for loading states with dark mode support
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppSpacing.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1C1C1F) : AppColors.surfaceVariant;
    final highlightColor = isDark ? const Color(0xFF27272A) : AppColors.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for listing card
class ListingCardSkeleton extends StatelessWidget {
  final bool isCompact;

  const ListingCardSkeleton({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactSkeleton();
    }
    return _buildFullSkeleton();
  }

  Widget _buildFullSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(
            height: 180,
            borderRadius: AppSpacing.radiusLg,
          ),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: SkeletonLoader(height: 20),
                    ),
                    AppSpacing.hGapMd,
                    const SkeletonLoader(width: 80, height: 24),
                  ],
                ),
                AppSpacing.vGapSm,
                const SkeletonLoader(width: 150, height: 14),
                AppSpacing.vGapMd,
                Row(
                  children: [
                    const SkeletonLoader(width: 100, height: 24),
                    AppSpacing.hGapMd,
                    const SkeletonLoader(width: 120, height: 24),
                  ],
                ),
                AppSpacing.vGapMd,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SkeletonLoader(width: 100, height: 28),
                    const SkeletonLoader(width: 80, height: 36),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSkeleton() {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(
            height: 120,
            borderRadius: AppSpacing.radiusLg,
          ),
          Padding(
            padding: AppSpacing.cardPaddingSmall,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(height: 16),
                AppSpacing.vGapXs,
                const SkeletonLoader(width: 100, height: 12),
                AppSpacing.vGapSm,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SkeletonLoader(width: 60, height: 20),
                    const SkeletonLoader(width: 50, height: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton list for multiple items
class ListingListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool isCompact;

  const ListingListSkeleton({
    super.key,
    this.itemCount = 3,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: itemCount,
          itemBuilder: (context, index) =>
              const ListingCardSkeleton(isCompact: true),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ListingCardSkeleton(),
    );
  }
}
