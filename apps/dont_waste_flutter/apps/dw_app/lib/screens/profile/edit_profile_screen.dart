import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authStateProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated'),
            backgroundColor: DwDarkTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: DwDarkTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
            ),
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
    final user = ref.watch(currentUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: DwDarkTheme.background,
        appBar: AppBar(
          backgroundColor: DwDarkTheme.background,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DwDarkTheme.surfaceHighlight,
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: DwDarkTheme.textSecondary,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Edit Profile',
            style: DwDarkTheme.headlineSmall,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: DwDarkTheme.spacingSm),
              child: TextButton(
                onPressed: _isLoading ? null : _handleSave,
                style: TextButton.styleFrom(
                  backgroundColor: DwDarkTheme.accent.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DwDarkTheme.spacingMd,
                    vertical: DwDarkTheme.spacingSm,
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            DwDarkTheme.accent,
                          ),
                        ),
                      )
                    : Text(
                        'Save',
                        style: DwDarkTheme.labelLarge.copyWith(
                          color: DwDarkTheme.accent,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar section
                _buildAvatarSection(user),
                const SizedBox(height: DwDarkTheme.spacingXl),

                // Form fields
                _buildFormSection(user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(user) {
    final initial = user?.name.isNotEmpty == true
        ? user!.name.substring(0, 1).toUpperCase()
        : '?';
    final hasAvatar = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;

    return Center(
      child: Stack(
        children: [
          // Avatar with gradient border
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: DwDarkTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: DwDarkTheme.accent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: DwDarkTheme.surface,
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: hasAvatar
                    ? CachedNetworkImage(
                        imageUrl: user!.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildInitialAvatar(initial),
                        errorWidget: (_, __, ___) => _buildInitialAvatar(initial),
                      )
                    : _buildInitialAvatar(initial),
              ),
            ),
          ),

          // Camera button
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // TODO: Pick image
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Photo upload coming soon'),
                    backgroundColor: DwDarkTheme.surfaceElevated,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                    ),
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: DwDarkTheme.primaryGradient,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DwDarkTheme.background,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar(String initial) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DwDarkTheme.surfaceHighlight,
            DwDarkTheme.surfaceElevated,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: DwDarkTheme.headlineLarge.copyWith(
            color: DwDarkTheme.accent,
            fontSize: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(user) {
    return Container(
      padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
      decoration: BoxDecoration(
        color: DwDarkTheme.cardBackground,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusLg),
        border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Personal Information',
            style: DwDarkTheme.titleSmall.copyWith(
              color: DwDarkTheme.textSecondary,
            ),
          ),
          const SizedBox(height: DwDarkTheme.spacingMd),

          // Name field
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your name',
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: DwDarkTheme.spacingMd),

          // Email field (read-only)
          _buildTextField(
            initialValue: user?.email ?? '',
            label: 'Email',
            hint: '',
            icon: Icons.email_outlined,
            enabled: false,
          ),
          const SizedBox(height: DwDarkTheme.spacingMd),

          // Phone field
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DwDarkTheme.labelMedium.copyWith(
            color: DwDarkTheme.textSecondary,
          ),
        ),
        const SizedBox(height: DwDarkTheme.spacingSm),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          enabled: enabled,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: DwDarkTheme.bodyLarge.copyWith(
            color: enabled ? DwDarkTheme.textPrimary : DwDarkTheme.textMuted,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: DwDarkTheme.bodyLarge.copyWith(
              color: DwDarkTheme.textMuted,
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: enabled ? DwDarkTheme.textTertiary : DwDarkTheme.textMuted,
            ),
            filled: true,
            fillColor: enabled
                ? DwDarkTheme.surfaceHighlight
                : DwDarkTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
              borderSide: BorderSide(color: DwDarkTheme.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
              borderSide: BorderSide(color: DwDarkTheme.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
              borderSide: BorderSide(color: DwDarkTheme.accent, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
              borderSide: BorderSide(color: DwDarkTheme.cardBorder.withOpacity(0.5)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
              borderSide: BorderSide(color: DwDarkTheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
              borderSide: BorderSide(color: DwDarkTheme.error, width: 1.5),
            ),
            errorStyle: DwDarkTheme.labelSmall.copyWith(
              color: DwDarkTheme.error,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DwDarkTheme.spacingMd,
              vertical: DwDarkTheme.spacingMd,
            ),
          ),
        ),
      ],
    );
  }
}
