import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

/// Profile screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DwSpacing.md),
        child: Column(
          children: [
            // Profile header
            _ProfileHeader(user: user),
            const SizedBox(height: DwSpacing.xl),

            // Stats
            _StatsRow(),
            const SizedBox(height: DwSpacing.xl),

            // Menu items
            _MenuItem(
              icon: Icons.store_outlined,
              title: 'My Listings',
              subtitle: 'Manage your surplus food listings',
              onTap: () => context.push(AppRoutes.myListings),
            ),
            _MenuItem(
              icon: Icons.add_circle_outline,
              title: 'Create Listing',
              subtitle: 'List surplus food for sale',
              onTap: () => context.push(AppRoutes.createListing),
            ),
            _MenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () => context.push(AppRoutes.notifications),
            ),
            _MenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs and contact support',
              onTap: () {
                // TODO: Open help
              },
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and legal info',
              onTap: () {
                // TODO: Open about
              },
            ),
            const SizedBox(height: DwSpacing.lg),

            // Logout button
            DwOutlinedButton(
              onPressed: () => _handleLogout(context, ref),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: DwColors.error),
                  const SizedBox(width: DwSpacing.sm),
                  Text('Sign Out', style: TextStyle(color: DwColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out', style: TextStyle(color: DwColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final User? user;

  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 50,
          backgroundColor: DwColors.primaryLight,
          backgroundImage: user?.avatarUrl != null
              ? NetworkImage(user!.avatarUrl!)
              : null,
          child: user?.avatarUrl == null
              ? Text(
                  user?.name.substring(0, 1).toUpperCase() ?? '?',
                  style: DwTextStyles.headlineLarge.copyWith(
                    color: DwColors.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(height: DwSpacing.md),

        // Name
        Text(
          user?.name ?? 'Guest',
          style: DwTextStyles.headlineSmall,
        ),
        const SizedBox(height: DwSpacing.xs),

        // Email
        Text(
          user?.email ?? '',
          style: DwTextStyles.bodyMedium.copyWith(
            color: DwColors.textSecondary,
          ),
        ),
        const SizedBox(height: DwSpacing.md),

        // Edit profile button
        TextButton.icon(
          onPressed: () => context.push(AppRoutes.editProfile),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit Profile'),
        ),
      ],
    );
  }
}

class _StatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // These would come from actual user stats
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(value: '12', label: 'Saved'),
        _StatItem(value: '8', label: 'Purchased'),
        _StatItem(value: '24kg', label: 'Food Saved'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: DwTextStyles.headlineSmall.copyWith(
            color: DwColors.primary,
          ),
        ),
        Text(
          label,
          style: DwTextStyles.bodySmall.copyWith(
            color: DwColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DwColors.primaryLight,
          borderRadius: BorderRadius.circular(DwRadius.sm),
        ),
        child: Icon(icon, color: DwColors.primary),
      ),
      title: Text(title, style: DwTextStyles.titleSmall),
      subtitle: Text(
        subtitle,
        style: DwTextStyles.bodySmall.copyWith(
          color: DwColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
