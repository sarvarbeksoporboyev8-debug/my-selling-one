import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/premium_theme.dart';

/// Premium feature card with large image, overlay badge, and page indicator
class FeatureCard extends StatelessWidget {
  final String? imageUrl;
  final String? badge;
  final Color? badgeColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final double height;
  final double borderRadius;

  const FeatureCard({
    super.key,
    this.imageUrl,
    this.badge,
    this.badgeColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.height = 200,
    this.borderRadius = PremiumTheme.radiusXl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.premium;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: theme.shadowMd,
          border: Border.all(color: theme.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badge overlay
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius - 1),
              ),
              child: Stack(
                children: [
                  // Image
                  SizedBox(
                    height: height,
                    width: double.infinity,
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _buildPlaceholder(theme),
                            errorWidget: (_, __, ___) => _buildPlaceholder(theme),
                          )
                        : _buildPlaceholder(theme),
                  ),

                  // Gradient overlay for better text readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Badge
                  if (badge != null)
                    Positioned(
                      top: PremiumTheme.space12,
                      left: PremiumTheme.space12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PremiumTheme.space10,
                          vertical: PremiumTheme.space6,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor ?? theme.accent,
                          borderRadius: BorderRadius.circular(PremiumTheme.radiusSm),
                          boxShadow: [
                            BoxShadow(
                              color: (badgeColor ?? theme.accent).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(PremiumTheme.space14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: PremiumTheme.space4),
                    Text(
                      subtitle!,
                      style: theme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(PremiumTheme theme) {
    return Container(
      color: theme.surfaceSecondary,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: theme.textMuted,
        ),
      ),
    );
  }
}

/// Feature card carousel with page indicator
class FeatureCardCarousel extends StatefulWidget {
  final List<FeatureCardData> items;
  final double height;
  final Function(FeatureCardData)? onItemTap;

  const FeatureCardCarousel({
    super.key,
    required this.items,
    this.height = 280,
    this.onItemTap,
  });

  @override
  State<FeatureCardCarousel> createState() => _FeatureCardCarouselState();
}

class _FeatureCardCarouselState extends State<FeatureCardCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.premium;

    return Column(
      children: [
        // Cards
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.space6),
                child: FeatureCard(
                  imageUrl: item.imageUrl,
                  badge: item.badge,
                  badgeColor: item.badgeColor,
                  title: item.title,
                  subtitle: item.subtitle,
                  onTap: () => widget.onItemTap?.call(item),
                  height: widget.height - 80,
                ),
              );
            },
          ),
        ),

        // Page indicator
        const SizedBox(height: PremiumTheme.space12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? theme.accent
                    : theme.textMuted,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Data model for feature card
class FeatureCardData {
  final String id;
  final String? imageUrl;
  final String? badge;
  final Color? badgeColor;
  final String title;
  final String? subtitle;

  const FeatureCardData({
    required this.id,
    this.imageUrl,
    this.badge,
    this.badgeColor,
    required this.title,
    this.subtitle,
  });
}
