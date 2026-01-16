import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

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
            'Notifications',
            style: DwDarkTheme.headlineSmall,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
          children: [
            // Orders section
            _buildSection(
              title: 'Orders',
              icon: Icons.shopping_bag_outlined,
              color: DwDarkTheme.accentGreen,
              items: [
                _NotificationItem(
                  title: 'Reservation Updates',
                  subtitle: 'Get notified about reservation status changes',
                  value: _reservationUpdates,
                  onChanged: (value) {
                    setState(() => _reservationUpdates = value);
                  },
                ),
                _NotificationItem(
                  title: 'Seller Messages',
                  subtitle: 'Messages from sellers about your orders',
                  value: _sellerMessages,
                  onChanged: (value) {
                    setState(() => _sellerMessages = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),

            // Watchlist section
            _buildSection(
              title: 'Watchlist',
              icon: Icons.bookmark_outline,
              color: DwDarkTheme.accent,
              items: [
                _NotificationItem(
                  title: 'Price Drops',
                  subtitle: 'When items in your watchlist drop in price',
                  value: _priceDrops,
                  onChanged: (value) {
                    setState(() => _priceDrops = value);
                  },
                ),
                _NotificationItem(
                  title: 'Expiring Soon',
                  subtitle: 'When watchlist items are about to expire',
                  value: _expiringWatchlist,
                  onChanged: (value) {
                    setState(() => _expiringWatchlist = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),

            // Discovery section
            _buildSection(
              title: 'Discovery',
              icon: Icons.explore_outlined,
              color: DwDarkTheme.accentPurple,
              items: [
                _NotificationItem(
                  title: 'New Listings Nearby',
                  subtitle: 'When new surplus food is listed near you',
                  value: _newListingsNearby,
                  onChanged: (value) {
                    setState(() => _newListingsNearby = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: DwDarkTheme.spacingMd),

            // Marketing section
            _buildSection(
              title: 'Marketing',
              icon: Icons.campaign_outlined,
              color: DwDarkTheme.accentOrange,
              items: [
                _NotificationItem(
                  title: 'Promotions & Offers',
                  subtitle: 'Special deals and promotional content',
                  value: _promotions,
                  onChanged: (value) {
                    setState(() => _promotions = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: DwDarkTheme.spacingXl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<_NotificationItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(
            left: DwDarkTheme.spacingXs,
            bottom: DwDarkTheme.spacingSm,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: color,
                ),
              ),
              const SizedBox(width: DwDarkTheme.spacingSm),
              Text(
                title,
                style: DwDarkTheme.titleSmall.copyWith(
                  color: DwDarkTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Items card
        Container(
          decoration: BoxDecoration(
            color: DwDarkTheme.cardBackground,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
            border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  _buildNotificationTile(item),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.only(left: DwDarkTheme.spacingMd),
                      child: Container(
                        height: 1,
                        color: DwDarkTheme.cardBorder.withOpacity(0.5),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(_NotificationItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DwDarkTheme.spacingMd,
        vertical: DwDarkTheme.spacingMd - 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: DwDarkTheme.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: DwDarkTheme.bodySmall.copyWith(
                    color: DwDarkTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DwDarkTheme.spacingMd),
          Switch(
            value: item.value,
            onChanged: item.onChanged,
            activeColor: DwDarkTheme.accentGreen,
            activeTrackColor: DwDarkTheme.accentGreen.withOpacity(0.3),
            inactiveThumbColor: DwDarkTheme.textMuted,
            inactiveTrackColor: DwDarkTheme.surfaceHighlight,
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}
