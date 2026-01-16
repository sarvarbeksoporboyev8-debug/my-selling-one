import 'package:flutter/material.dart';
import 'package:dw_domain/dw_domain.dart';
import 'package:dw_ui/dw_ui.dart';

class ReservationStatusPill extends StatelessWidget {
  final ReservationStatus status;
  final bool compact;

  const ReservationStatusPill({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, icon) = _getStatusStyle(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? DwDarkTheme.spacingSm : DwDarkTheme.spacingSm + 4,
        vertical: compact ? 3 : DwDarkTheme.spacingXs + 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 10 : 12,
            color: color,
          ),
          SizedBox(width: compact ? 3 : 5),
          Text(
            status.displayName,
            style: (compact ? DwDarkTheme.labelSmall : DwDarkTheme.labelMedium).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) _getStatusStyle(ReservationStatus status) {
    return switch (status) {
      ReservationStatus.pending => (
          const Color(0xFFD29922),
          const Color(0xFFD29922).withOpacity(0.15),
          Icons.schedule,
        ),
      ReservationStatus.confirmed => (
          DwDarkTheme.accent,
          DwDarkTheme.accent.withOpacity(0.15),
          Icons.check_circle_outline,
        ),
      ReservationStatus.completed => (
          DwDarkTheme.accentGreen,
          DwDarkTheme.accentGreen.withOpacity(0.15),
          Icons.done_all,
        ),
      ReservationStatus.cancelled => (
          const Color(0xFFF85149),
          const Color(0xFFF85149).withOpacity(0.12),
          Icons.cancel_outlined,
        ),
      ReservationStatus.expired => (
          DwDarkTheme.textMuted,
          DwDarkTheme.surfaceHighlight,
          Icons.timer_off_outlined,
        ),
    };
  }
}
