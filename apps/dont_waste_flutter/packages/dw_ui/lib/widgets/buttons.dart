import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/radius.dart';

/// Primary button widget
class DwButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isFullWidth;

  const DwButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: DwColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DwColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DwRadius.md),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : child,
      ),
    );
  }
}

/// Outlined button widget
class DwOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isFullWidth;

  const DwOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: DwColors.primary,
          side: const BorderSide(color: DwColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DwRadius.md),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(DwColors.primary),
                ),
              )
            : child,
      ),
    );
  }
}

/// Filter chip widget
class DwFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final int? badge;
  final VoidCallback? onTap;

  const DwFilterChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DwSpacing.md,
          vertical: DwSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? DwColors.primary : DwColors.surface,
          borderRadius: BorderRadius.circular(DwRadius.full),
          border: Border.all(
            color: isSelected ? DwColors.primary : DwColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : DwColors.textSecondary,
              ),
              const SizedBox(width: DwSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : DwColors.textPrimary,
                fontSize: 14,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: DwSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : DwColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    color: isSelected ? DwColors.primary : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
