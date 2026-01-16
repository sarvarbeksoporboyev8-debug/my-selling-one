import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../providers/providers.dart';
import '../routing/app_routes.dart';

/// Main shell with premium bottom navigation
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _navItems = [
    PremiumNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    PremiumNavItem(
      label: 'Discover',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
    ),
    // Map is the center button
    PremiumNavItem(
      label: 'Saved',
      icon: Icons.bookmark_outline_rounded,
      activeIcon: Icons.bookmark_rounded,
    ),
    PremiumNavItem(
      label: 'Orders',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    PremiumNavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  static const _centerItem = PremiumNavItem(
    label: 'Map',
    icon: Icons.map_rounded,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.premium;

    return Scaffold(
      backgroundColor: theme.background,
      body: child,
      extendBody: true,
      bottomNavigationBar: PremiumBottomNavBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: _navItems,
        centerItem: _centerItem,
        onCenterTap: () => context.go(AppRoutes.map),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.discover)) return 1;
    if (location.startsWith(AppRoutes.map)) return -1; // Center button
    if (location.startsWith(AppRoutes.watchlist)) return 2;
    if (location.startsWith(AppRoutes.reservations)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.discover);
        break;
      case 2:
        context.go(AppRoutes.watchlist);
        break;
      case 3:
        context.go(AppRoutes.reservations);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }
}
