import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dw_ui/dw_ui.dart';

/// Notifications preferences screen
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _reservationUpdates = true;
  bool _priceDrops = true;
  bool _newListingsNearby = true;
  bool _expiringWatchlist = true;
  bool _sellerMessages = true;
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          // Orders section
          _SectionHeader(title: 'Orders'),
          SwitchListTile(
            title: const Text('Reservation Updates'),
            subtitle: const Text('Get notified about reservation status changes'),
            value: _reservationUpdates,
            onChanged: (value) {
              setState(() => _reservationUpdates = value);
            },
          ),
          SwitchListTile(
            title: const Text('Seller Messages'),
            subtitle: const Text('Messages from sellers about your orders'),
            value: _sellerMessages,
            onChanged: (value) {
              setState(() => _sellerMessages = value);
            },
          ),

          // Watchlist section
          _SectionHeader(title: 'Watchlist'),
          SwitchListTile(
            title: const Text('Price Drops'),
            subtitle: const Text('When items in your watchlist drop in price'),
            value: _priceDrops,
            onChanged: (value) {
              setState(() => _priceDrops = value);
            },
          ),
          SwitchListTile(
            title: const Text('Expiring Soon'),
            subtitle: const Text('When watchlist items are about to expire'),
            value: _expiringWatchlist,
            onChanged: (value) {
              setState(() => _expiringWatchlist = value);
            },
          ),

          // Discovery section
          _SectionHeader(title: 'Discovery'),
          SwitchListTile(
            title: const Text('New Listings Nearby'),
            subtitle: const Text('When new surplus food is listed near you'),
            value: _newListingsNearby,
            onChanged: (value) {
              setState(() => _newListingsNearby = value);
            },
          ),

          // Marketing section
          _SectionHeader(title: 'Marketing'),
          SwitchListTile(
            title: const Text('Promotions & Offers'),
            subtitle: const Text('Special deals and promotional content'),
            value: _promotions,
            onChanged: (value) {
              setState(() => _promotions = value);
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DwSpacing.md,
        DwSpacing.lg,
        DwSpacing.md,
        DwSpacing.sm,
      ),
      child: Text(
        title,
        style: DwTextStyles.titleSmall.copyWith(
          color: DwColors.primary,
        ),
      ),
    );
  }
}
