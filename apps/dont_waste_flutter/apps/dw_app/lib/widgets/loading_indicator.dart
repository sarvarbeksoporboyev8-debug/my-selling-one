import 'package:flutter/material.dart';
import 'package:dw_ui/dw_ui.dart';

/// Animated loading indicator with optional message.
/// Uses a custom animation that matches the app's design language.
class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 80,
    this.showBackground = false,
  });

  /// Optional message to display below the indicator.
  final String? message;

  /// Size of the loading indicator.
  final double size;

  /// Whether to show a semi-transparent background overlay.
  final bool showBackground;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget indicator = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: widget.size * 0.6,
                  height: widget.size * 0.6,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: widget.size * 0.35,
                      height: widget.size * 0.35,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: widget.size * 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.message != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (widget.showBackground) {
      return Container(
        color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
        child: Center(child: indicator),
      );
    }

    return Center(child: indicator);
  }
}

/// Full-screen loading overlay.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    this.message,
  });

  final String? message;

  /// Shows a loading overlay on top of the current screen.
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => LoadingOverlay(message: message),
    );
  }

  /// Hides the loading overlay.
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: LoadingIndicator(
            message: message,
            size: 60,
          ),
        ),
      ),
    );
  }
}
