import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';
import 'widgets/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final watchlistCount = ref.watch(watchlistCountProvider);
    final reservations = ref.watch(reservationsProvider);
    
    final reservationsCount = reservations.maybeWhen(
      data: (items) => items.length,
      orElse: () => 0,
    );

    // Check if profile is incomplete
    final isProfileIncomplete = user?.name.isEmpty == true || 
        user?.name == 'Demo User';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: DwDarkTheme.background,
        body: CustomScrollView(
          slivers: [
            // Custom app bar
            SliverAppBar(
              backgroundColor: DwDarkTheme.background,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 60,
              title: Text(
                'Profile',
                style: DwDarkTheme.headlineSmall,
              ),
              actions: [
                IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: DwDarkTheme.surfaceHighlight,
                      borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: DwDarkTheme.textSecondary,
                    ),
                  ),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
                const SizedBox(width: DwDarkTheme.spacingSm),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Profile header
                  ProfileHeader(
                    user: user,
                    onEditProfile: () => context.push(AppRoutes.editProfile),
                    isVerified: true,
                    accountType: 'Business Account',
                  ),
                  const SizedBox(height: DwDarkTheme.spacingMd),

                  // Profile completion card (if incomplete)
                  if (isProfileIncomplete) ...[
                    ProfileCompletionCard(
                      onComplete: () => context.push(AppRoutes.editProfile),
                      completionPercent: 60,
                    ),
                    const SizedBox(height: DwDarkTheme.spacingMd),
                  ],

                  // Stats card
                  StatsCard(
                    stats: [
                      StatItem(
                        id: 'watchlist',
                        value: watchlistCount.toString(),
                        label: 'Watchlist',
                        icon: Icons.bookmark_outline,
                        color: DwDarkTheme.accent,
                      ),
                      StatItem(
                        id: 'reservations',
                        value: reservationsCount.toString(),
                        label: 'Reservations',
                        icon: Icons.shopping_bag_outlined,
                        color: DwDarkTheme.accentGreen,
                      ),
                      StatItem(
                        id: 'listings',
                        value: '3',
                        label: 'Listings',
                        icon: Icons.store_outlined,
                        color: DwDarkTheme.accentPurple,
                      ),
                    ],
                    onStatTap: (stat) => _handleStatTap(context, stat),
                  ),
                  const SizedBox(height: DwDarkTheme.spacingLg),

                  // Quick actions
                  QuickActionGrid(
                    actions: [
                      QuickAction(
                        title: 'My Reservations',
                        subtitle: '$reservationsCount active',
                        icon: Icons.receipt_long_outlined,
                        color: DwDarkTheme.accentGreen,
                        onTap: () => context.go(AppRoutes.reservations),
                      ),
                      QuickAction(
                        title: 'My Listings',
                        subtitle: 'Manage inventory',
                        icon: Icons.inventory_2_outlined,
                        color: DwDarkTheme.accentPurple,
                        onTap: () => context.push(AppRoutes.myListings),
                      ),
                      QuickAction(
                        title: 'Create Listing',
                        subtitle: 'Sell surplus',
                        icon: Icons.add_circle_outline,
                        color: DwDarkTheme.accent,
                        onTap: () => context.push(AppRoutes.createListing),
                      ),
                      QuickAction(
                        title: 'Saved Items',
                        subtitle: '$watchlistCount saved',
                        icon: Icons.bookmark_border,
                        color: DwDarkTheme.accentOrange,
                        onTap: () => context.go(AppRoutes.watchlist),
                      ),
                    ],
                  ),
                  const SizedBox(height: DwDarkTheme.spacingLg),

                  // Account settings
                  SettingsSectionCard(
                    title: 'Account',
                    items: [
                      SettingsItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Name, photo, contact info',
                        iconColor: DwDarkTheme.accent,
                        onTap: () => context.push(AppRoutes.editProfile),
                      ),
                      SettingsItem(
                        icon: Icons.business_outlined,
                        title: 'Business Details',
                        subtitle: 'Company, address, tax ID',
                        iconColor: DwDarkTheme.accentPurple,
                        onTap: () {
                          // TODO: Navigate to business details
                          _showComingSoon(context);
                        },
                      ),
                      SettingsItem(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'English',
                        iconColor: DwDarkTheme.accentGreen,
                        trailing: Text(
                          'EN',
                          style: DwDarkTheme.labelMedium.copyWith(
                            color: DwDarkTheme.textMuted,
                          ),
                        ),
                        onTap: () {
                          // TODO: Language picker
                          _showComingSoon(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: DwDarkTheme.spacingMd),

                  // Notifications
                  SettingsSectionCard(
                    title: 'Notifications',
                    items: [
                      SettingsItem(
                        icon: Icons.notifications_outlined,
                        title: 'Push Notifications',
                        subtitle: 'Manage alerts and updates',
                        iconColor: DwDarkTheme.accentOrange,
                        onTap: () => context.push(AppRoutes.notifications),
                      ),
                    ],
                  ),
                  const SizedBox(height: DwDarkTheme.spacingMd),

                  // Support
                  SettingsSectionCard(
                    title: 'Support',
                    items: [
                      SettingsItem(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        subtitle: 'FAQs and guides',
                        iconColor: DwDarkTheme.accent,
                        onTap: () {
                          // TODO: Open help center
                          _showComingSoon(context);
                        },
                      ),
                      SettingsItem(
                        icon: Icons.bug_report_outlined,
                        title: 'Report a Problem',
                        subtitle: 'Send feedback or report issues',
                        iconColor: DwDarkTheme.error,
                        onTap: () {
                          // TODO: Open report form
                          _showComingSoon(context);
                        },
                      ),
                      SettingsItem(
                        icon: Icons.description_outlined,
                        title: 'Terms & Privacy',
                        subtitle: 'Legal information',
                        iconColor: DwDarkTheme.textTertiary,
                        onTap: () {
                          // TODO: Open terms
                          _showComingSoon(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: DwDarkTheme.spacingMd),

                  // App info
                  SettingsSectionCard(
                    title: 'App',
                    items: [
                      SettingsItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Theme',
                        subtitle: 'Dark mode enabled',
                        iconColor: DwDarkTheme.accentPink,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DwDarkTheme.spacingSm,
                            vertical: DwDarkTheme.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            color: DwDarkTheme.accentPink.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                          ),
                          child: Text(
                            'Dark',
                            style: DwDarkTheme.labelSmall.copyWith(
                              color: DwDarkTheme.accentPink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        showChevron: false,
                        onTap: () {
                          // Theme is fixed to dark for now
                        },
                      ),
                      SettingsItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'Version 1.0.0',
                        iconColor: DwDarkTheme.textTertiary,
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: DwDarkTheme.spacingLg),

                  // Sign out button
                  _buildSignOutButton(context, ref),
                  const SizedBox(height: DwDarkTheme.spacingXl),

                  // Footer
                  Center(
                    child: Text(
                      "Don't Waste • Reduce Food Waste",
                      style: DwDarkTheme.labelSmall.copyWith(
                        color: DwDarkTheme.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: DwDarkTheme.spacingMd),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStatTap(BuildContext context, StatItem stat) {
    switch (stat.id) {
      case 'watchlist':
        context.go(AppRoutes.watchlist);
        break;
      case 'reservations':
        context.go(AppRoutes.reservations);
        break;
      case 'listings':
        context.push(AppRoutes.myListings);
        break;
    }
  }

  void _showComingSoon(BuildContext context) {
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DwDarkTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusLg),
        ),
        title: Text(
          "Don't Waste",
          style: DwDarkTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: DwDarkTheme.bodyMedium,
            ),
            const SizedBox(height: DwDarkTheme.spacingSm),
            Text(
              'A B2B marketplace for surplus inventory. Reduce waste, save money, help the planet.',
              style: DwDarkTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: DwDarkTheme.labelLarge.copyWith(
                color: DwDarkTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleLogout(context, ref),
        borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: DwDarkTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: DwDarkTheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
            border: Border.all(
              color: DwDarkTheme.error.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                size: 20,
                color: DwDarkTheme.error,
              ),
              const SizedBox(width: DwDarkTheme.spacingSm),
              Text(
                'Sign Out',
                style: DwDarkTheme.titleSmall.copyWith(
                  color: DwDarkTheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DwDarkTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusLg),
        ),
        title: Text(
          'Sign Out',
          style: DwDarkTheme.headlineSmall,
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: DwDarkTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: DwDarkTheme.labelLarge.copyWith(
                color: DwDarkTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sign Out',
              style: DwDarkTheme.labelLarge.copyWith(
                color: DwDarkTheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}
