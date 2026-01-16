import 'package:flutter/material.dart';
import 'package:dw_ui/dw_ui.dart';

enum ReservationTab { upcoming, completed, cancelled }

class ReservationsFilterBar extends StatelessWidget {
  final ReservationTab selectedTab;
  final ValueChanged<ReservationTab> onTabChanged;
  final VoidCallback? onFilterTap;
  final int upcomingCount;
  final int completedCount;
  final int cancelledCount;

  const ReservationsFilterBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    this.onFilterTap,
    this.upcomingCount = 0,
    this.completedCount = 0,
    this.cancelledCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DwDarkTheme.spacingMd,
        vertical: DwDarkTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: DwDarkTheme.surface,
        border: Border(
          bottom: BorderSide(
            color: DwDarkTheme.cardBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Segmented tabs
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: DwDarkTheme.surfaceHighlight,
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
              ),
              child: Row(
                children: [
                  _buildTab(
                    ReservationTab.upcoming,
                    'Upcoming',
                    upcomingCount,
                  ),
                  _buildTab(
                    ReservationTab.completed,
                    'Completed',
                    completedCount,
                  ),
                  _buildTab(
                    ReservationTab.cancelled,
                    'Cancelled',
                    cancelledCount,
                  ),
                ],
              ),
            ),
          ),

          // Filter button
          if (onFilterTap != null) ...[
            const SizedBox(width: DwDarkTheme.spacingSm),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DwDarkTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                    border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
                  ),
                  child: const Icon(
                    Icons.tune,
                    size: 20,
                    color: DwDarkTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTab(ReservationTab tab, String label, int count) {
    final isSelected = selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: DwDarkTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? DwDarkTheme.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm - 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: DwDarkTheme.labelMedium.copyWith(
                  color: isSelected
                      ? DwDarkTheme.textPrimary
                      : DwDarkTheme.textTertiary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getTabColor(tab).withOpacity(0.2)
                        : DwDarkTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count.toString(),
                    style: DwDarkTheme.labelSmall.copyWith(
                      color: isSelected
                          ? _getTabColor(tab)
                          : DwDarkTheme.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTabColor(ReservationTab tab) {
    return switch (tab) {
      ReservationTab.upcoming => DwDarkTheme.accent,
      ReservationTab.completed => DwDarkTheme.accentGreen,
      ReservationTab.cancelled => const Color(0xFFF85149),
    };
  }
}

class ReservationsFilterSheet extends StatefulWidget {
  final String? selectedCategory;
  final DateTimeRange? selectedDateRange;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onApply;
  final VoidCallback onReset;

  const ReservationsFilterSheet({
    super.key,
    this.selectedCategory,
    this.selectedDateRange,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ReservationsFilterSheet> createState() => _ReservationsFilterSheetState();
}

class _ReservationsFilterSheetState extends State<ReservationsFilterSheet> {
  late String? _category;
  late DateTimeRange? _dateRange;

  final _categories = [
    'All Categories',
    'Food & Beverage',
    'Retail Overstock',
    'Construction',
    'Office & Corporate',
    'Hospitality',
  ];

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _dateRange = widget.selectedDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
      decoration: const BoxDecoration(
        color: DwDarkTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DwDarkTheme.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Reservations',
                style: DwDarkTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _category = null;
                    _dateRange = null;
                  });
                  widget.onReset();
                },
                child: Text(
                  'Reset',
                  style: DwDarkTheme.labelLarge.copyWith(
                    color: DwDarkTheme.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DwDarkTheme.spacingMd),

          // Category filter
          Text(
            'Category',
            style: DwDarkTheme.titleSmall.copyWith(
              color: DwDarkTheme.textSecondary,
            ),
          ),
          const SizedBox(height: DwDarkTheme.spacingSm),
          Wrap(
            spacing: DwDarkTheme.spacingSm,
            runSpacing: DwDarkTheme.spacingSm,
            children: _categories.map((cat) {
              final isSelected = _category == cat || (_category == null && cat == 'All Categories');
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _category = cat == 'All Categories' ? null : cat;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DwDarkTheme.spacingSm + 4,
                    vertical: DwDarkTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DwDarkTheme.accent.withOpacity(0.15)
                        : DwDarkTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                    border: Border.all(
                      color: isSelected
                          ? DwDarkTheme.accent.withOpacity(0.5)
                          : DwDarkTheme.cardBorder,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: DwDarkTheme.labelMedium.copyWith(
                      color: isSelected
                          ? DwDarkTheme.accent
                          : DwDarkTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DwDarkTheme.spacingLg),

          // Date range
          Text(
            'Date Range',
            style: DwDarkTheme.titleSmall.copyWith(
              color: DwDarkTheme.textSecondary,
            ),
          ),
          const SizedBox(height: DwDarkTheme.spacingSm),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  initialDateRange: _dateRange,
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: DwDarkTheme.accent,
                          surface: DwDarkTheme.surface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (range != null) {
                  setState(() => _dateRange = range);
                }
              },
              borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
              child: Container(
                padding: const EdgeInsets.all(DwDarkTheme.spacingMd),
                decoration: BoxDecoration(
                  color: DwDarkTheme.surfaceHighlight,
                  borderRadius: BorderRadius.circular(DwDarkTheme.radiusSm),
                  border: Border.all(color: DwDarkTheme.cardBorder, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: DwDarkTheme.textTertiary,
                    ),
                    const SizedBox(width: DwDarkTheme.spacingSm),
                    Expanded(
                      child: Text(
                        _dateRange != null
                            ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                            : 'Select date range',
                        style: DwDarkTheme.bodyMedium.copyWith(
                          color: _dateRange != null
                              ? DwDarkTheme.textPrimary
                              : DwDarkTheme.textMuted,
                        ),
                      ),
                    ),
                    if (_dateRange != null)
                      GestureDetector(
                        onTap: () => setState(() => _dateRange = null),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: DwDarkTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: DwDarkTheme.spacingLg),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  widget.onCategoryChanged(_category);
                  widget.onDateRangeChanged(_dateRange);
                  widget.onApply();
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: DwDarkTheme.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    gradient: DwDarkTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(DwDarkTheme.radiusMd),
                  ),
                  child: Center(
                    child: Text(
                      'Apply Filters',
                      style: DwDarkTheme.titleSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: DwDarkTheme.spacingMd),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
