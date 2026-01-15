import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Quantity stepper widget for selecting amounts
class QuantityStepper extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final double step;
  final String unit;
  final ValueChanged<double> onChanged;
  final String? errorMessage;

  const QuantityStepper({
    super.key,
    required this.value,
    this.min = 0,
    required this.max,
    this.step = 1,
    required this.unit,
    required this.onChanged,
    this.errorMessage,
  });

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    final newValue = widget.value + widget.step;
    if (newValue <= widget.max) {
      HapticFeedback.selectionClick();
      widget.onChanged(newValue);
    }
  }

  void _decrement() {
    final newValue = widget.value - widget.step;
    if (newValue >= widget.min) {
      HapticFeedback.selectionClick();
      widget.onChanged(newValue);
    }
  }

  void _onTextChanged(String text) {
    final value = double.tryParse(text);
    if (value != null && value >= widget.min && value <= widget.max) {
      widget.onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDecrement = widget.value > widget.min;
    final canIncrement = widget.value < widget.max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppSpacing.borderRadiusMd,
            border: widget.errorMessage != null
                ? Border.all(color: AppColors.error)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrement button
              _buildButton(
                icon: Icons.remove,
                onPressed: canDecrement ? _decrement : null,
              ),
              // Value input
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: AppTypography.titleMedium,
                  onChanged: _onTextChanged,
                ),
              ),
              // Unit label
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text(
                  widget.unit,
                  style: AppTypography.bodyMedium,
                ),
              ),
              // Increment button
              _buildButton(
                icon: Icons.add,
                onPressed: canIncrement ? _increment : null,
              ),
            ],
          ),
        ),
        if (widget.errorMessage != null) ...[
          AppSpacing.vGapXs,
          Text(
            widget.errorMessage!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
        AppSpacing.vGapXs,
        Text(
          'Available: ${widget.max.toStringAsFixed(0)} ${widget.unit}',
          style: AppTypography.bodySmall,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onPressed != null
                ? AppColors.primary
                : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
