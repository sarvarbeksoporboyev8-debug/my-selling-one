import 'package:flutter/material.dart';
import '../../theme/premium_theme.dart';

/// Premium bottom navigation bar with center floating action button
class PremiumBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PremiumNavItem> items;
  final PremiumNavItem? centerItem;
  final VoidCallback? onCenterTap;

  const PremiumBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.centerItem,
    this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.premium;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // If we have a center item, split items around it
    final hasCenter = centerItem != null;
    final leftItems = hasCenter ? items.take(items.length ~/ 2).toList() : items;
    final rightItems = hasCenter ? items.skip(items.length ~/ 2).toList() : [];

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: theme.borderSubtle, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64 + (bottomPadding > 0 ? 0 : 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Regular nav items
              Row(
                children: [
                  // Left items
                  ...leftItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Expanded(
                      child: _NavItem(
                        item: item,
                        isSelected: currentIndex == index,
                        onTap: () => onTap(index),
                      ),
                    );
                  }),

                  // Space for center button
                  if (hasCenter) const Expanded(child: SizedBox()),

                  // Right items
                  ...rightItems.asMap().entries.map((entry) {
                    final index = entry.key + leftItems.length;
                    final item = entry.value;
                    return Expanded(
                      child: _NavItem(
                        item: item,
                        isSelected: currentIndex == index,
                        onTap: () => onTap(index),
                      ),
                    );
                  }),
                ],
              ),

              // Center floating button
              if (hasCenter)
                Positioned(
                  top: -20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _CenterButton(
                      item: centerItem!,
                      onTap: onCenterTap ?? () {},
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final PremiumNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.premium;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumTheme.space12,
              vertical: PremiumTheme.space6,
            ),
            decoration: BoxDecoration(
              color: isSelected 
                  ? theme.accent.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 24,
              color: isSelected ? theme.accent : theme.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? theme.accent : theme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final PremiumNavItem item;
  final VoidCallback onTap;

  const _CenterButton({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.premium;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: theme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.accent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          item.icon,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Nav item data model
class PremiumNavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;

  const PremiumNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}
