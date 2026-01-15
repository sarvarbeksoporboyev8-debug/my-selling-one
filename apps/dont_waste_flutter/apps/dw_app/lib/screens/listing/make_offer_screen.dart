import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dw_ui/dw_ui.dart';

import '../../providers/providers.dart';

/// Make offer screen
class MakeOfferScreen extends ConsumerStatefulWidget {
  final int listingId;

  const MakeOfferScreen({super.key, required this.listingId});

  @override
  ConsumerState<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends ConsumerState<MakeOfferScreen> {
  final _priceController = TextEditingController();
  final _messageController = TextEditingController();
  double _quantity = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitOffer() async {
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an offer price'),
          backgroundColor: DwColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement offer submission via API
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer submitted!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: DwColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make an Offer'),
      ),
      body: listingAsync.when(
        data: (listing) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(DwSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Listing summary
                DwListingListTile(
                  listing: listing,
                  onTap: () => context.pop(),
                ),
                const SizedBox(height: DwSpacing.lg),

                // Current price info
                Container(
                  padding: const EdgeInsets.all(DwSpacing.md),
                  decoration: BoxDecoration(
                    color: DwColors.infoLight,
                    borderRadius: BorderRadius.circular(DwRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: DwColors.info),
                      const SizedBox(width: DwSpacing.sm),
                      Expanded(
                        child: Text(
                          'Listed price: \$${listing.price.toStringAsFixed(2)} per ${listing.unit}',
                          style: DwTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DwSpacing.xl),

                // Quantity selector
                Text('Quantity', style: DwTextStyles.titleMedium),
                const SizedBox(height: DwSpacing.sm),
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Expanded(
                      child: Slider(
                        value: _quantity,
                        min: 1,
                        max: listing.quantity.toDouble(),
                        divisions: listing.quantity.toInt() - 1,
                        label: _quantity.toStringAsFixed(0),
                        onChanged: (value) {
                          setState(() => _quantity = value);
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _quantity < listing.quantity
                          ? () => setState(() => _quantity++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    '${_quantity.toStringAsFixed(0)} ${listing.unit}',
                    style: DwTextStyles.titleLarge,
                  ),
                ),
                const SizedBox(height: DwSpacing.lg),

                // Offer price
                Text('Your Offer Price', style: DwTextStyles.titleMedium),
                const SizedBox(height: DwSpacing.sm),
                DwTextField(
                  controller: _priceController,
                  hint: 'Enter your offer per ${listing.unit}',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.attach_money,
                ),
                const SizedBox(height: DwSpacing.lg),

                // Message
                Text('Message to Seller', style: DwTextStyles.titleMedium),
                const SizedBox(height: DwSpacing.sm),
                DwTextField(
                  controller: _messageController,
                  hint: 'Explain your offer (optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: DwSpacing.xl),

                // Offer summary
                if (_priceController.text.isNotEmpty)
                  Builder(builder: (context) {
                    final offerPrice = double.tryParse(_priceController.text) ?? 0;
                    final totalOffer = offerPrice * _quantity;
                    final savings = (listing.price - offerPrice) * _quantity;

                    return Container(
                      padding: const EdgeInsets.all(DwSpacing.md),
                      decoration: BoxDecoration(
                        color: DwColors.surface,
                        borderRadius: BorderRadius.circular(DwRadius.md),
                        border: Border.all(color: DwColors.border),
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Your offer per ${listing.unit}',
                            value: '\$${offerPrice.toStringAsFixed(2)}',
                          ),
                          _SummaryRow(
                            label: 'Quantity',
                            value: '${_quantity.toStringAsFixed(0)} ${listing.unit}',
                          ),
                          const Divider(),
                          _SummaryRow(
                            label: 'Total offer',
                            value: '\$${totalOffer.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                          if (savings > 0)
                            _SummaryRow(
                              label: 'You save',
                              value: '\$${savings.toStringAsFixed(2)}',
                              valueColor: DwColors.success,
                            ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: DwSpacing.lg),

                // Submit button
                DwButton(
                  onPressed: _isLoading ? null : _handleSubmitOffer,
                  isLoading: _isLoading,
                  child: const Text('Submit Offer'),
                ),
                const SizedBox(height: DwSpacing.sm),

                // Note
                Text(
                  'The seller will review your offer and respond within 24 hours.',
                  style: DwTextStyles.bodySmall.copyWith(
                    color: DwColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DwErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(listingDetailProvider(widget.listingId)),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DwSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? DwTextStyles.titleSmall : DwTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: (isBold ? DwTextStyles.titleSmall : DwTextStyles.bodyMedium).copyWith(
              color: valueColor ?? (isBold ? DwColors.primary : null),
            ),
          ),
        ],
      ),
    );
  }
}
