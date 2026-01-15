import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../screens/screens.dart';
import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// App router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateHelperProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

      // Show splash while checking auth
      if (authState.isLoading && isSplash) {
        return null;
      }

      // After auth check, redirect appropriately
      if (!authState.isLoading) {
        if (!isLoggedIn && !isLoggingIn && !isOnboarding) {
          return AppRoutes.login;
        }
        if (isLoggedIn && (isLoggingIn || isSplash)) {
          return AppRoutes.home;
        }
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.discover,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DiscoverScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.map,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MapScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.watchlist,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WatchlistScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.reservations,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReservationsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Listing detail (outside shell for full-screen)
      GoRoute(
        path: AppRoutes.listingDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ListingDetailScreen(listingId: id);
        },
        routes: [
          GoRoute(
            path: 'reserve',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ReserveScreen(listingId: id);
            },
          ),
          GoRoute(
            path: 'offer',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return MakeOfferScreen(listingId: id);
            },
          ),
        ],
      ),

      // Reservation detail
      GoRoute(
        path: AppRoutes.reservationDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ReservationDetailScreen(reservationId: id);
        },
      ),

      // Seller routes
      GoRoute(
        path: AppRoutes.myListings,
        builder: (context, state) => const MyListingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createListing,
        builder: (context, state) => const CreateListingScreen(),
      ),
      GoRoute(
        path: AppRoutes.editListing,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditListingScreen(listingId: id);
        },
      ),

      // Profile sub-routes
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Search & Filter
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.filters,
        builder: (context, state) => const FiltersScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});
