import 'package:flutter/material.dart';
import '../../theme/premium_theme.dart';

/// Category chip data model
class CategoryChipData {
  final String id;
  final String label;
  final IconData icon;
  final Color? color;

  const CategoryChipData({
    required this.id,
    required this.label,
    required this.icon,
    this.color,
  });
}

/// Premium horizontal category chips row
/// Circular icons with labels, modern selection state
class CategoryChipsRow extends StatelessWidget {
  final List<CategoryChipData> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final EdgeInsets padding;

  const CategoryChipsRow({
    super.key,
    required this.categories,
    this.selectedId,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: PremiumTheme.space16),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: PremiumTheme.space12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedId == category.id;
          return _CategoryChip(
            data: category,
            isSelected: isSelected,
            onTap: () => onSelected(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryChipData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.premium;
    final chipColor = data.color ?? theme.accent;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected 
                    ? chipColor.withOpacity(0.15)
                    : theme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? chipColor : theme.border,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : theme.shadowSm,
              ),
              child: Icon(
                data.icon,
                size: 26,
                color: isSelected ? chipColor : theme.textSecondary,
              ),
            ),
            const SizedBox(height: PremiumTheme.space8),

            // Label
            Text(
              data.label,
              style: theme.labelSmall.copyWith(
                color: isSelected ? theme.textPrimary : theme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
