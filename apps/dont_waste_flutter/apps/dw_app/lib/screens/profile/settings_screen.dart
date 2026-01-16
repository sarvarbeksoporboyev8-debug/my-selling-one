import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import 'widgets/widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  String _distanceUnit = 'km';

  @override
  Widget build(BuildContext context) {
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
            'Settings',
            style: DwDarkTheme.headlineSmall,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
          children: [
            // Notifications section
            SettingsSectionCard(
              title: 'Notifications',
              items: [
                SettingsItem(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive push notifications',
                  iconColor: DwDarkTheme.accentOrange,
                  showChevron: false,
                  trailing: _buildSwitch(
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() => _pushNotifications = value);
                    },
                  ),
                ),
                SettingsItem(
                  icon: Icons.email_outlined,
                  title: 'Email Notifications',
                  subtitle: 'Receive email updates',
                  iconColor: DwDarkTheme.accent,
                  showChevron: false,
                  trailing: _buildSwitch(
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() => _emailNotifications = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),

            // Appearance section
            SettingsSectionCard(
              title: 'Appearance',
              items: [
                SettingsItem(
                  icon: getThemeModeIcon(ref.watch(themeModeProvider)),
                  title: 'Theme',
                  subtitle: getThemeModeLabel(ref.watch(themeModeProvider)),
                  iconColor: DwDarkTheme.accentPurple,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DwDarkTheme.spacingSm,
                      vertical: DwDarkTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: DwDarkTheme.accentPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                    ),
                    child: Text(
                      getThemeModeLabel(ref.watch(themeModeProvider)),
                      style: DwDarkTheme.labelSmall.copyWith(
                        color: DwDarkTheme.accentPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  onTap: () => _showThemePicker(ref),
                ),
              ],
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),

            // Units section
            SettingsSectionCard(
              title: 'Preferences',
              items: [
                SettingsItem(
                  icon: Icons.straighten_outlined,
                  title: 'Distance Unit',
                  subtitle: _distanceUnit == 'km' ? 'Kilometers' : 'Miles',
                  iconColor: DwDarkTheme.accentGreen,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DwDarkTheme.spacingSm,
                      vertical: DwDarkTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: DwDarkTheme.accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                    ),
                    child: Text(
                      _distanceUnit.toUpperCase(),
                      style: DwDarkTheme.labelSmall.copyWith(
                        color: DwDarkTheme.accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  onTap: () => _showDistanceUnitPicker(),
                ),
              ],
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),

            // Privacy section
            SettingsSectionCard(
              title: 'Legal',
              items: [
                SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  iconColor: DwDarkTheme.textTertiary,
                  onTap: () {
                    _showComingSoon();
                  },
                ),
                SettingsItem(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  iconColor: DwDarkTheme.textTertiary,
                  onTap: () {
                    _showComingSoon();
                  },
                ),
              ],
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),

            // Data section
            SettingsSectionCard(
              title: 'Data & Storage',
              items: [
                SettingsItem(
                  icon: Icons.cleaning_services_outlined,
                  title: 'Clear Cache',
                  subtitle: 'Free up storage space',
                  iconColor: DwDarkTheme.accentPurple,
                  onTap: () {
                    _showClearCacheDialog();
                  },
                ),
                SettingsItem(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  iconColor: DwDarkTheme.error,
                  titleColor: DwDarkTheme.error,
                  onTap: () {
                    _showDeleteAccountDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),

            // App info
            SettingsSectionCard(
              title: 'About',
              items: [
                SettingsItem(
                  icon: Icons.info_outline,
                  title: 'Version',
                  subtitle: '1.0.0 (1)',
                  iconColor: DwDarkTheme.textTertiary,
                  showChevron: false,
                ),
              ],
            ),
            const SizedBox(height: DwDarkTheme.spacingXl),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: DwDarkTheme.accentGreen,
      activeTrackColor: DwDarkTheme.accentGreen.withOpacity(0.3),
      inactiveThumbColor: DwDarkTheme.textMuted,
      inactiveTrackColor: DwDarkTheme.surfaceHighlight,
    );
  }

  void _showThemePicker(WidgetRef ref) {
    final currentTheme = ref.read(themeModeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: DwDarkTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DwDarkTheme.radiusLg),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DwDarkTheme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),
            Text(
              'Theme',
              style: DwDarkTheme.headlineSmall,
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),
            _buildThemeOption(
              ref: ref,
              title: 'Light',
              icon: Icons.light_mode,
              mode: ThemeMode.light,
              isSelected: currentTheme == ThemeMode.light,
            ),
            const SizedBox(height: DwDarkTheme.spacingSm),
            _buildThemeOption(
              ref: ref,
              title: 'Dark',
              icon: Icons.dark_mode,
              mode: ThemeMode.dark,
              isSelected: currentTheme == ThemeMode.dark,
            ),
            const SizedBox(height: DwDarkTheme.spacingSm),
            _buildThemeOption(
              ref: ref,
              title: 'System',
              icon: Icons.brightness_auto,
              mode: ThemeMode.system,
              isSelected: currentTheme == ThemeMode.system,
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
          decoration: BoxDecoration(
            color: isSelected
                ? DwDarkTheme.accentPurple.withOpacity(0.15)
                : DwDarkTheme.surfaceHighlight,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
            border: Border.all(
              color: isSelected
                  ? DwDarkTheme.accentPurple.withOpacity(0.5)
                  : DwDarkTheme.cardBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? DwDarkTheme.accentPurple
                    : DwDarkTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: DwDarkTheme.spacingMd),
              Expanded(
                child: Text(
                  title,
                  style: DwDarkTheme.bodyLarge.copyWith(
                    color: isSelected
                        ? DwDarkTheme.accentPurple
                        : DwDarkTheme.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: DwDarkTheme.accentPurple,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDistanceUnitPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: DwDarkTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DwDarkTheme.radiusLg),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DwDarkTheme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),
            Text(
              'Distance Unit',
              style: DwDarkTheme.headlineSmall,
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),
            _buildUnitOption(
              title: 'Kilometers',
              value: 'km',
              isSelected: _distanceUnit == 'km',
            ),
            const SizedBox(height: DwDarkTheme.spacingSm),
            _buildUnitOption(
              title: 'Miles',
              value: 'mi',
              isSelected: _distanceUnit == 'mi',
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitOption({
    required String title,
    required String value,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _distanceUnit = value);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
          decoration: BoxDecoration(
            color: isSelected
                ? DwDarkTheme.accent.withOpacity(0.15)
                : DwDarkTheme.surfaceHighlight,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
            border: Border.all(
              color: isSelected
                  ? DwDarkTheme.accent.withOpacity(0.5)
                  : DwDarkTheme.cardBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: DwDarkTheme.bodyLarge.copyWith(
                    color: isSelected
                        ? DwDarkTheme.accent
                        : DwDarkTheme.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: DwDarkTheme.accent,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DwDarkTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusLg),
        ),
        title: Text(
          'Clear Cache',
          style: DwDarkTheme.headlineSmall,
        ),
        content: Text(
          'This will clear all cached data. You may need to reload some content.',
          style: DwDarkTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: DwDarkTheme.labelLarge.copyWith(
                color: DwDarkTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared'),
                  backgroundColor: DwDarkTheme.accentGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                  ),
                ),
              );
            },
            child: Text(
              'Clear',
              style: DwDarkTheme.labelLarge.copyWith(
                color: DwDarkTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DwDarkTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusLg),
        ),
        title: Text(
          'Delete Account',
          style: DwDarkTheme.headlineSmall.copyWith(
            color: DwDarkTheme.error,
          ),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: DwDarkTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: DwDarkTheme.labelLarge.copyWith(
                color: DwDarkTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon();
            },
            child: Text(
              'Delete',
              style: DwDarkTheme.labelLarge.copyWith(
                color: DwDarkTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon'),
        backgroundColor: DwDarkTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
        ),
      ),
    );
  }
}
