import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';
import 'package:dw_ui/dw_ui.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onEditProfile;
  final bool isVerified;
  final String accountType;

  const ProfileHeader({
    super.key,
    this.user,
    required this.onEditProfile,
    this.isVerified = false,
    this.accountType = 'Business Account',
  });

  @override
  Widget build(BuildContext context) {
    final hasName = user?.name.isNotEmpty == true;
    final hasEmail = user?.email.isNotEmpty == true;

    return Container(
      padding: const EdgeInsets.all(DwDarkTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DwDarkTheme.surfaceElevated,
            DwDarkTheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusLg),
        border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          // Avatar with gradient border
          _buildAvatar(),
          const SizedBox(height: DwDarkTheme.spacingMd),

          // Name
          Text(
            hasName ? user!.name : 'Complete Your Profile',
            style: DwDarkTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DwDarkTheme.spacingXs),

          // Account type badge + verified
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DwDarkTheme.spacingSm + 4,
                  vertical: DwDarkTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: DwDarkTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                ),
                child: Text(
                  accountType,
                  style: DwDarkTheme.labelSmall.copyWith(
                    color: DwDarkTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: DwDarkTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DwDarkTheme.spacingSm,
                    vertical: DwDarkTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: DwDarkTheme.accentGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 12,
                        color: DwDarkTheme.accentGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: DwDarkTheme.labelSmall.copyWith(
                          color: DwDarkTheme.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: DwDarkTheme.spacingSm),

          // Email
          if (hasEmail)
            Text(
              user!.email,
              style: DwDarkTheme.bodyMedium.copyWith(
                color: DwDarkTheme.textTertiary,
              ),
            ),

          // Phone if available
          if (user?.phone != null && user!.phone!.isNotEmpty) ...[
            const SizedBox(height: DwDarkTheme.spacingXs),
            Text(
              user!.phone!,
              style: DwDarkTheme.bodySmall.copyWith(
                color: DwDarkTheme.textMuted,
              ),
            ),
          ],

          const SizedBox(height: DwDarkTheme.spacingMd),

          // Edit profile button
          _buildEditButton(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = user?.name.isNotEmpty == true
        ? user!.name.substring(0, 1).toUpperCase()
        : '?';
    final hasAvatar = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;

    return Container(
      width: 96,
      height: 96,
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
        decoration: BoxDecoration(
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
            fontSize: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEditProfile,
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusXl),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DwDarkTheme.spacingMd + 4,
            vertical: DwDarkTheme.spacingSm + 2,
          ),
          decoration: BoxDecoration(
            color: DwDarkTheme.surfaceHighlight,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusXl),
            border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_outlined,
                size: 16,
                color: DwDarkTheme.textSecondary,
              ),
              const SizedBox(width: DwDarkTheme.spacingSm),
              Text(
                'Edit Profile',
                style: DwDarkTheme.labelLarge.copyWith(
                  color: DwDarkTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
