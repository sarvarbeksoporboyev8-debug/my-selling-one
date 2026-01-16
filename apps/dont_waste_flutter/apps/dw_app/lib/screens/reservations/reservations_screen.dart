import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';
import 'widgets/widgets.dart';

class ReservationsScreen extends ConsumerStatefulWidget {
  const ReservationsScreen({super.key});

  @override
  ConsumerState<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends ConsumerState<ReservationsScreen> {
  ReservationTab _selectedTab = ReservationTab.upcoming;
  String? _selectedCategory;
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final reservations = ref.watch(reservationsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: DwDarkTheme.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // App bar
            SliverAppBar(
              backgroundColor: DwDarkTheme.background,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: DwDarkTheme.spacingMd,
                    right: DwDarkTheme.spacingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reservations',
                        style: DwDarkTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your bookings and pickups',
                        style: DwDarkTheme.bodyMedium.copyWith(
                          color: DwDarkTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: Column(
            children: [
              // Filter bar with tabs
              reservations.when(
                data: (items) {
                  final upcoming = items.where((r) => r.isActive).toList();
                  final completed = items.where((r) => r.status == ReservationStatus.completed).toList();
                  final cancelled = items.where((r) => r.status == ReservationStatus.cancelled).toList();

                  return ReservationsFilterBar(
                    selectedTab: _selectedTab,
                    onTabChanged: (tab) => setState(() => _selectedTab = tab),
                    onFilterTap: () => _showFilterSheet(context),
                    upcomingCount: upcoming.length,
                    completedCount: completed.length,
                    cancelledCount: cancelled.length,
                  );
                },
                loading: () => ReservationsFilterBar(
                  selectedTab: _selectedTab,
                  onTabChanged: (tab) => setState(() => _selectedTab = tab),
                ),
                error: (_, __) => ReservationsFilterBar(
                  selectedTab: _selectedTab,
                  onTabChanged: (tab) => setState(() => _selectedTab = tab),
                ),
              ),

              // Content
              Expanded(
                child: reservations.when(
                  data: (items) => _buildContent(items),
                  loading: () => const SkeletonReservationList(),
                  error: (error, _) => ReservationsErrorState(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(reservationsProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<Reservation> items) {
    // Filter by tab
    final filteredItems = switch (_selectedTab) {
      ReservationTab.upcoming => items.where((r) => r.isActive).toList(),
      ReservationTab.completed => items.where((r) => r.status == ReservationStatus.completed).toList(),
      ReservationTab.cancelled => items.where((r) => r.status == ReservationStatus.cancelled).toList(),
    };

    // Apply additional filters
    var displayItems = filteredItems;
    if (_selectedCategory != null) {
      // Filter by category if we have category data
      // For now, this is a placeholder
    }
    if (_selectedDateRange != null) {
      displayItems = displayItems.where((r) {
        return r.createdAt.isAfter(_selectedDateRange!.start) &&
            r.createdAt.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (displayItems.isEmpty) {
      return ReservationsEmptyState(
        tab: _selectedTab,
        onAction: _selectedTab == ReservationTab.upcoming
            ? () => context.go(AppRoutes.discover)
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reservationsProvider);
        // Wait for the provider to reload
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: DwDarkTheme.accent,
      backgroundColor: DwDarkTheme.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
        itemCount: displayItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: DwDarkTheme.spacingMd),
        itemBuilder: (context, index) {
          final reservation = displayItems[index];
          return ReservationCard(
            reservation: reservation,
            onTap: () => context.push(
              AppRoutes.reservationDetailPath(reservation.id),
            ),
            onDirections: reservation.isActive
                ? () => _openDirections(reservation)
                : null,
            onReorder: reservation.status == ReservationStatus.completed ||
                    reservation.status == ReservationStatus.cancelled
                ? () => _reorder(reservation)
                : null,
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ReservationsFilterSheet(
        selectedCategory: _selectedCategory,
        selectedDateRange: _selectedDateRange,
        onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
        onDateRangeChanged: (range) => setState(() => _selectedDateRange = range),
        onApply: () {},
        onReset: () => setState(() {
          _selectedCategory = null;
          _selectedDateRange = null;
        }),
      ),
    );
  }

  void _openDirections(Reservation reservation) {
    // TODO: Open maps with directions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening directions...'),
        backgroundColor: DwDarkTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
        ),
      ),
    );
  }

  void _reorder(Reservation reservation) {
    // Navigate to listing detail to make a new reservation
    context.push(AppRoutes.listingDetailPath(reservation.listing.id));
  }
}
