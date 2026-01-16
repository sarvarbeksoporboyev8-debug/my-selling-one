import 'package:flutter/material.dart';
import 'package:dw_ui/dw_ui.dart';

class SkeletonReservationCard extends StatefulWidget {
  const SkeletonReservationCard({super.key});

  @override
  State<SkeletonReservationCard> createState() => _SkeletonReservationCardState();
}

class _SkeletonReservationCardState extends State<SkeletonReservationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
          decoration: BoxDecoration(
            color: DwDarkTheme.cardBackground,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
            border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail skeleton
                  _buildShimmer(
                    width: 72,
                    height: 72,
                    borderRadius: DwDarkTheme.radiusSm,
                  ),
                  const SizedBox(width: DwDarkTheme.spacingMd),

                  // Info skeleton
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmer(width: 160, height: 18),
                        const SizedBox(height: 8),
                        _buildShimmer(width: 100, height: 14),
                        const SizedBox(height: DwDarkTheme.spacingSm),
                        Row(
                          children: [
                            _buildShimmer(width: 60, height: 22, borderRadius: 4),
                            const SizedBox(width: DwDarkTheme.spacingSm),
                            _buildShimmer(width: 70, height: 22, borderRadius: 4),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status skeleton
                  _buildShimmer(width: 80, height: 24, borderRadius: DwDarkTheme.radiusSm),
                ],
              ),

              const SizedBox(height: DwDarkTheme.spacingMd),

              // Pickup info skeleton
              _buildShimmer(
                width: double.infinity,
                height: 40,
                borderRadius: DwDarkTheme.radiusSm,
              ),

              const SizedBox(height: DwDarkTheme.spacingMd),

              // Action buttons skeleton
              Row(
                children: [
                  Expanded(
                    child: _buildShimmer(
                      width: double.infinity,
                      height: 38,
                      borderRadius: DwDarkTheme.radiusSm,
                    ),
                  ),
                  const SizedBox(width: DwDarkTheme.spacingSm),
                  _buildShimmer(
                    width: 100,
                    height: 38,
                    borderRadius: DwDarkTheme.radiusSm,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmer({
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            DwDarkTheme.surfaceHighlight,
            DwDarkTheme.surfaceElevated.withOpacity(0.8),
            DwDarkTheme.surfaceHighlight,
          ],
          stops: [
            (_animation.value - 0.3).clamp(0.0, 1.0),
            _animation.value.clamp(0.0, 1.0),
            (_animation.value + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}

class SkeletonReservationList extends StatelessWidget {
  final int itemCount;

  const SkeletonReservationList({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: DwDarkTheme.spacingMd),
      itemBuilder: (_, __) => const SkeletonReservationCard(),
    );
  }
}
