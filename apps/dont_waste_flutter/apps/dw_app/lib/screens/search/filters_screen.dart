import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';

/// Filters screen
class FiltersScreen extends ConsumerStatefulWidget {
  const FiltersScreen({super.key});

  @override
  ConsumerState<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  late ListingFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = ref.read(filtersProvider);
  }

  void _applyFilters() {
    final notifier = ref.read(filtersProvider.notifier);

    if (_filters.radiusKm != null) {
      notifier.updateRadius(_filters.radiusKm!);
    }
    if (_filters.minPrice != null || _filters.maxPrice != null) {
      notifier.updatePriceRange(_filters.minPrice, _filters.maxPrice);
    }
    if (_filters.expiresWithinHours != null) {
      notifier.updateExpiryFilter(_filters.expiresWithinHours);
    }
    notifier.updateSort(_filters.sortBy);

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final taxonsAsync = ref.watch(taxonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _filters = const ListingFilters());
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(DwSpacing.md),
        children: [
          // Distance
          _SectionHeader(title: 'Distance'),
          Text(
            '${_filters.radiusKm?.toInt() ?? 50} km',
            style: DwTextStyles.titleLarge,
            textAlign: TextAlign.center,
          ),
          Slider(
            value: _filters.radiusKm ?? 50,
            min: 1,
            max: 100,
            divisions: 99,
            label: '${_filters.radiusKm?.toInt() ?? 50} km',
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(radiusKm: value);
              });
            },
          ),
          const SizedBox(height: DwSpacing.lg),

          // Price range
          _SectionHeader(title: 'Price Range'),
          Row(
            children: [
              Expanded(
                child: DwTextField(
                  initialValue: _filters.minPrice?.toString() ?? '',
                  label: 'Min',
                  hint: '\$0',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(
                        minPrice: double.tryParse(value),
                      );
                    });
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: DwSpacing.md),
                child: Text('-'),
              ),
              Expanded(
                child: DwTextField(
                  initialValue: _filters.maxPrice?.toString() ?? '',
                  label: 'Max',
                  hint: '\$100',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(
                        maxPrice: double.tryParse(value),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: DwSpacing.lg),

          // Expiry filter
          _SectionHeader(title: 'Expires Within'),
          Wrap(
            spacing: DwSpacing.sm,
            children: [
              _ExpiryChip(
                label: 'Any',
                value: null,
                selected: _filters.expiresWithinHours == null,
                onSelected: () {
                  setState(() {
                    _filters = _filters.copyWith(expiresWithinHours: null);
                  });
                },
              ),
              _ExpiryChip(
                label: '24 hours',
                value: 24,
                selected: _filters.expiresWithinHours == 24,
                onSelected: () {
                  setState(() {
                    _filters = _filters.copyWith(expiresWithinHours: 24);
                  });
                },
              ),
              _ExpiryChip(
                label: '48 hours',
                value: 48,
                selected: _filters.expiresWithinHours == 48,
                onSelected: () {
                  setState(() {
                    _filters = _filters.copyWith(expiresWithinHours: 48);
                  });
                },
              ),
              _ExpiryChip(
                label: '1 week',
                value: 168,
                selected: _filters.expiresWithinHours == 168,
                onSelected: () {
                  setState(() {
                    _filters = _filters.copyWith(expiresWithinHours: 168);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: DwSpacing.lg),

          // Categories
          _SectionHeader(title: 'Categories'),
          taxonsAsync.when(
            data: (taxons) => Wrap(
              spacing: DwSpacing.sm,
              runSpacing: DwSpacing.sm,
              children: taxons.map((taxon) {
                final isSelected = _filters.taxonIds?.contains(taxon.id) ?? false;
                return FilterChip(
                  label: Text(taxon.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      final currentIds = _filters.taxonIds ?? [];
                      if (selected) {
                        _filters = _filters.copyWith(
                          taxonIds: [...currentIds, taxon.id],
                        );
                      } else {
                        _filters = _filters.copyWith(
                          taxonIds: currentIds.where((id) => id != taxon.id).toList(),
                        );
                      }
                    });
                  },
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Failed to load categories'),
          ),
          const SizedBox(height: DwSpacing.lg),

          // Sort by
          _SectionHeader(title: 'Sort By'),
          ...SortOption.values.map((option) {
            return RadioListTile<SortOption>(
              title: Text(option.displayName),
              value: option,
              groupValue: _filters.sortBy,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _filters = _filters.copyWith(sortBy: value);
                  });
                }
              },
            );
          }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DwSpacing.md),
          child: DwButton(
            onPressed: _applyFilters,
            child: const Text('Apply Filters'),
          ),
        ),
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
      padding: const EdgeInsets.only(bottom: DwSpacing.sm),
      child: Text(title, style: DwTextStyles.titleMedium),
    );
  }
}

class _ExpiryChip extends StatelessWidget {
  final String label;
  final int? value;
  final bool selected;
  final VoidCallback onSelected;

  const _ExpiryChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
