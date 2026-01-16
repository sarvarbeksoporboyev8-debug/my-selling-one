import 'package:flutter/material.dart';
import 'package:dw_ui/dw_ui.dart';

class SettingsSectionCard extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;

  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: DwDarkTheme.spacingXs,
            bottom: DwDarkTheme.spacingSm,
          ),
          child: Text(
            title,
            style: DwDarkTheme.titleSmall.copyWith(
              color: DwDarkTheme.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: DwDarkTheme.cardBackground,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
            border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isFirst = index == 0;
              final isLast = index == items.length - 1;

              return _SettingsItemTile(
                item: item,
                isFirst: isFirst,
                isLast: isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItemTile extends StatelessWidget {
  final SettingsItem item;
  final bool isFirst;
  final bool isLast;

  const _SettingsItemTile({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.vertical(
              top: isFirst ? const Radius.circular(DwDarkTheme.radiusMd) : Radius.zero,
              bottom: isLast ? const Radius.circular(DwDarkTheme.radiusMd) : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DwDarkTheme.spacingMd,
                vertical: DwDarkTheme.spacingMd - 2,
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (item.iconColor ?? DwDarkTheme.textTertiary).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                    ),
                    child: Icon(
                      item.icon,
                      size: 18,
                      color: item.iconColor ?? DwDarkTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(width: DwDarkTheme.spacingMd),

                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: DwDarkTheme.bodyLarge.copyWith(
                            color: item.titleColor ?? DwDarkTheme.textPrimary,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: DwDarkTheme.bodySmall.copyWith(
                              color: DwDarkTheme.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing widget or chevron
                  if (item.trailing != null)
                    item.trailing!
                  else if (item.showChevron)
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: DwDarkTheme.textMuted,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 68),
            child: Container(
              height: 1,
              color: DwDarkTheme.cardBorder.withOpacity(0.5),
            ),
          ),
      ],
    );
  }
}

class SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });
}
