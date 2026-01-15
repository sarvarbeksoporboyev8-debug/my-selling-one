import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';

/// Forgot password screen
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authStateProvider.notifier).requestPasswordReset(
            email: _emailController.text.trim(),
          );
      setState(() => _emailSent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: DwColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DwSpacing.lg),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: DwSpacing.xl),

          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DwColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset,
                size: 40,
                color: DwColors.primary,
              ),
            ),
          ),
          const SizedBox(height: DwSpacing.lg),

          // Title
          Text(
            'Forgot Password?',
            style: DwTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DwSpacing.sm),
          Text(
            "Enter your email and we'll send you instructions to reset your password.",
            style: DwTextStyles.bodyMedium.copyWith(
              color: DwColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DwSpacing.xxl),

          // Email field
          DwTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: DwSpacing.lg),

          // Submit button
          DwButton(
            onPressed: _isLoading ? null : _handleResetPassword,
            isLoading: _isLoading,
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: DwColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read,
            size: 50,
            color: DwColors.success,
          ),
        ),
        const SizedBox(height: DwSpacing.lg),

        // Title
        Text(
          'Check Your Email',
          style: DwTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DwSpacing.sm),
        Text(
          'We sent a password reset link to\n${_emailController.text}',
          style: DwTextStyles.bodyMedium.copyWith(
            color: DwColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DwSpacing.xxl),

        // Back to login button
        DwButton(
          onPressed: () => context.pop(),
          child: const Text('Back to Sign In'),
        ),
        const SizedBox(height: DwSpacing.md),

        // Resend link
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: const Text("Didn't receive email? Try again"),
        ),
      ],
    );
  }
}
