import 'package:flutter/material.dart';
import 'package:dw_ui/dw_ui.dart';

class QuickActionGrid extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionGrid({
    super.key,
    required this.actions,
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
            'Quick Actions',
            style: DwDarkTheme.titleSmall.copyWith(
              color: DwDarkTheme.textSecondary,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: DwDarkTheme.spacingSm,
            crossAxisSpacing: DwDarkTheme.spacingSm,
            childAspectRatio: 1.6,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _QuickActionCard(action: actions[index]);
          },
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
          decoration: BoxDecoration(
            color: DwDarkTheme.cardBackground,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
            border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon with gradient background
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      action.color.withOpacity(0.2),
                      action.color.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                ),
                child: Icon(
                  action.icon,
                  size: 20,
                  color: action.color,
                ),
              ),

              // Title and subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: DwDarkTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (action.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      action.subtitle!,
                      style: DwDarkTheme.labelSmall.copyWith(
                        color: DwDarkTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickAction {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.title,
    this.subtitle,
    required this.icon,
    this.color = DwDarkTheme.accent,
    required this.onTap,
  });
}
