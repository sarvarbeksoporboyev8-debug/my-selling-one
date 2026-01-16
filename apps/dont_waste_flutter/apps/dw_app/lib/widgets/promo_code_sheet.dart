import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dw_ui/dw_ui.dart';

/// Bottom sheet for entering and applying promo codes.
class PromoCodeSheet extends StatefulWidget {
  const PromoCodeSheet({
    super.key,
    this.onApply,
    this.currentCode,
  });

  /// Callback when a promo code is applied.
  final void Function(String code)? onApply;

  /// Currently applied promo code, if any.
  final String? currentCode;

  /// Shows the promo code bottom sheet and returns the applied code.
  static Future<String?> show(BuildContext context, {String? currentCode}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PromoCodeSheet(
        currentCode: currentCode,
        onApply: (code) => Navigator.pop(context, code),
      ),
    );
  }

  @override
  State<PromoCodeSheet> createState() => _PromoCodeSheetState();
}

class _PromoCodeSheetState extends State<PromoCodeSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValidating = false;
  String? _error;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentCode != null) {
      _controller.text = widget.currentCode!;
      _isValid = true;
    }
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter a promo code');
      return;
    }

    setState(() {
      _isValidating = true;
      _error = null;
    });

    // Simulate API validation
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock validation - in real app, call API
    final validCodes = ['SAVE10', 'WELCOME', 'SURPLUS20', 'FIRSTORDER'];
    final isValid = validCodes.contains(code);

    if (mounted) {
      setState(() {
        _isValidating = false;
        if (isValid) {
          _isValid = true;
          _error = null;
        } else {
          _isValid = false;
          _error = 'Invalid promo code';
        }
      });

      if (isValid) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _applyCode() {
    if (_isValid) {
      widget.onApply?.call(_controller.text.trim().toUpperCase());
    }
  }

  void _removeCode() {
    setState(() {
      _controller.clear();
      _isValid = false;
      _error = null;
    });
    widget.onApply?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_offer_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Promo Code',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Enter code to get discount',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Input field
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.characters,
                style: theme.textTheme.titleMedium?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'ENTER CODE',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.black26,
                    letterSpacing: 2,
                  ),
                  filled: true,
                  fillColor: isDark 
                      ? Colors.white.withOpacity(0.08) 
                      : Colors.black.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _isValid 
                          ? AppColors.success 
                          : (_error != null ? AppColors.error : Colors.transparent),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _isValid 
                          ? AppColors.success 
                          : (_error != null ? AppColors.error : AppColors.primary),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  suffixIcon: _isValidating
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _isValid
                          ? IconButton(
                              icon: Icon(Icons.check_circle, color: AppColors.success),
                              onPressed: null,
                            )
                          : IconButton(
                              icon: const Icon(Icons.arrow_forward_rounded),
                              onPressed: _validateCode,
                            ),
                ),
                onSubmitted: (_) => _validateCode(),
                onChanged: (_) {
                  if (_error != null || _isValid) {
                    setState(() {
                      _error = null;
                      _isValid = false;
                    });
                  }
                },
              ),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: 6),
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],

              // Success message
              if (_isValid) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 20, color: AppColors.success),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Code applied! You\'ll save 10% on this order.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  if (widget.currentCode != null && widget.currentCode!.isNotEmpty)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _removeCode,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Remove',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  if (widget.currentCode != null && widget.currentCode!.isNotEmpty)
                    const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isValid ? _applyCode : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: isDark 
                            ? Colors.white12 
                            : Colors.black12,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isValid ? 'Apply Code' : 'Validate',
                        style: TextStyle(
                          color: _isValid ? Colors.white : (isDark ? Colors.white38 : Colors.black38),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Available codes hint
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.white.withOpacity(0.05) 
                      : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Try: WELCOME, SAVE10, SURPLUS20',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }
}
