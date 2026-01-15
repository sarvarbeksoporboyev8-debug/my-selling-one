import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/discover/screens/discover_screen.dart';
import '../features/discover/screens/filters_screen.dart';
import '../features/listing/screens/listing_detail_screen.dart';
import '../features/reservations/screens/reservations_screen.dart';
import '../features/watchlist/screens/watchlist_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../providers/auth_provider.dart';
import 'shell_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isOnboarding = state.matchedLocation == '/onboarding';

      // Allow onboarding without auth
      if (isOnboarding) return null;

      // If not logged in and not on login page, redirect to login
      // For now, allow browsing without auth
      // if (!isLoggedIn && !isLoggingIn) return '/login';

      // If logged in and on login page, redirect to home
      if (isLoggedIn && isLoggingIn) return '/';

      return null;
    },
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          // Discover tab
          GoRoute(
            path: '/',
            name: 'discover',
            builder: (context, state) => const DiscoverScreen(),
            routes: [
              GoRoute(
                path: 'filters',
                name: 'filters',
                builder: (context, state) => const FiltersScreen(),
              ),
            ],
          ),

          // Watchlist tab
          GoRoute(
            path: '/watchlist',
            name: 'watchlist',
            builder: (context, state) => const WatchlistScreen(),
          ),

          // Reservations tab
          GoRoute(
            path: '/reservations',
            name: 'reservations',
            builder: (context, state) => const ReservationsScreen(),
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Listing detail (outside shell for full screen)
      GoRoute(
        path: '/listing/:id',
        name: 'listing',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ListingDetailScreen(listingId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
