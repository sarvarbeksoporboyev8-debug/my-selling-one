import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Badge showing countdown to expiry
class CountdownBadge extends StatefulWidget {
  final DateTime expiresAt;
  final bool isUrgent;
  final bool isCompact;

  const CountdownBadge({
    super.key,
    required this.expiresAt,
    this.isUrgent = false,
    this.isCompact = false,
  });

  @override
  State<CountdownBadge> createState() => _CountdownBadgeState();
}

class _CountdownBadgeState extends State<CountdownBadge> {
  Timer? _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeLeft();
    });
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    setState(() {
      _timeLeft = widget.expiresAt.difference(now);
      if (_timeLeft.isNegative) {
        _timeLeft = Duration.zero;
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _timeLeft <= Duration.zero;
    final isUrgent = !isExpired && _timeLeft.inHours < 2;
    final isExpiringSoon = !isExpired && !isUrgent && _timeLeft.inHours < 24;

    Color backgroundColor;
    Color textColor;

    if (isExpired) {
      backgroundColor = AppColors.textTertiary;
      textColor = Colors.white;
    } else if (isUrgent) {
      backgroundColor = AppColors.urgent;
      textColor = Colors.white;
    } else if (isExpiringSoon) {
      backgroundColor = AppColors.expiringSoon;
      textColor = Colors.white;
    } else {
      backgroundColor = AppColors.available;
      textColor = Colors.white;
    }

    final text = _formatTimeLeft();

    if (widget.isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: textColor,
            fontSize: 10,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.timer_off : Icons.timer,
            size: 14,
            color: textColor,
          ),
          AppSpacing.hGapXs,
          Text(
            text,
            style: AppTypography.countdown.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  String _formatTimeLeft() {
    if (_timeLeft <= Duration.zero) {
      return 'Expired';
    }

    if (_timeLeft.inDays > 0) {
      return '${_timeLeft.inDays}d ${_timeLeft.inHours % 24}h';
    } else if (_timeLeft.inHours > 0) {
      return '${_timeLeft.inHours}h ${_timeLeft.inMinutes % 60}m';
    } else if (_timeLeft.inMinutes > 0) {
      return '${_timeLeft.inMinutes}m ${_timeLeft.inSeconds % 60}s';
    } else {
      return '${_timeLeft.inSeconds}s';
    }
  }
}
