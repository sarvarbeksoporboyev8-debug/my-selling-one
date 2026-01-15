import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dw_domain/dw_domain.dart';

import '../../providers/providers.dart';
import '../../routing/app_routes.dart';

class ReserveScreen extends ConsumerStatefulWidget {
  final int listingId;
  const ReserveScreen({super.key, required this.listingId});

  @override
  ConsumerState<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends ConsumerState<ReserveScreen> {
  final _quantityController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  final _companyController = TextEditingController();
  DateTime? _pickupTime;
  bool _isLoading = false;
  int _selectedTier = 0;

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  double get _quantity => double.tryParse(_quantityController.text) ?? 1;

  double _getPriceForQuantity(SurplusListing listing, double qty) {
    if (qty >= 50) return listing.currentPrice * 0.8;
    if (qty >= 11) return listing.currentPrice * 0.9;
    return listing.currentPrice;
  }

  Future<void> _handleClaim() async {
    setState(() => _isLoading = true);
    try {
      final reservation = await ref.read(reservationsProvider.notifier).createReservation(
        listingId: widget.listingId, quantity: _quantity,
        notes: _noteController.text.isNotEmpty ? _noteController.text : null,
      );
      if (mounted) _showSuccessSheet(reservation);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSheet(Reservation reservation) {
    showModalBottomSheet(
      context: context, isDismissible: false, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 72, height: 72,
            decoration: BoxDecoration(color: const Color(0xFF1E3A5F).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Color(0xFF1E3A5F), size: 40)),
          const SizedBox(height: 20),
          const Text('Claim Submitted!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          const SizedBox(height: 8),
          Text('Reference #${reservation.id} - Supplier will confirm shortly', style: TextStyle(fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: () { Navigator.pop(ctx); context.go(AppRoutes.reservationDetailPath(reservation.id)); },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('View Claim Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
          const SizedBox(height: 12),
          TextButton(onPressed: () { Navigator.pop(ctx); context.go('/discover'); },
            child: const Text('Continue Browsing', style: TextStyle(color: Color(0xFF1E3A5F)))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: listingAsync.when(
        data: (listing) => _buildContent(listing),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A5F))),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(SurplusListing listing) {
    final unitPrice = _getPriceForQuantity(listing, _quantity);
    final total = unitPrice * _quantity;

    return Column(children: [
      Expanded(child: CustomScrollView(slivers: [
        _buildAppBar(listing),
        SliverToBoxAdapter(child: _buildProductSummary(listing)),
        SliverToBoxAdapter(child: _buildQuantitySection(listing)),
        SliverToBoxAdapter(child: _buildPricingTiers(listing)),
        SliverToBoxAdapter(child: _buildPickupSection(listing)),
        SliverToBoxAdapter(child: _buildBusinessInfo()),
        SliverToBoxAdapter(child: _buildNoteSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ])),
      _buildBottomBar(listing, unitPrice, total),
    ]);
  }

  Widget _buildAppBar(SurplusListing listing) {
    return SliverAppBar(
      expandedHeight: 180, pinned: true, backgroundColor: const Color(0xFF1E3A5F),
      leading: IconButton(
        icon: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20)),
        onPressed: () => context.pop()),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(fit: StackFit.expand, children: [
          listing.primaryPhotoUrl != null
              ? CachedNetworkImage(imageUrl: listing.primaryPhotoUrl!, fit: BoxFit.cover)
              : Container(color: const Color(0xFF1E3A5F)),
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)]))),
          Positioned(bottom: 16, left: 20, right: 20,
            child: Text('Claim Surplus', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
        ]),
      ),
    );
  }

  Widget _buildProductSummary(SurplusListing listing) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12),
          child: listing.primaryPhotoUrl != null
              ? CachedNetworkImage(imageUrl: listing.primaryPhotoUrl!, width: 64, height: 64, fit: BoxFit.cover)
              : Container(width: 64, height: 64, color: Colors.grey[200])),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(listing.displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(listing.enterprise.name, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text('${listing.quantityAvailable.toStringAsFixed(0)} ${listing.unit} available', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ]),
        ])),
      ]),
    );
  }

  Widget _buildQuantitySection(SurplusListing listing) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1E3A5F), size: 22),
          const SizedBox(width: 10),
          const Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          _buildQtyButton(Icons.remove_rounded, () {
            final q = _quantity;
            if (q > 1) { _quantityController.text = (q - 1).toStringAsFixed(0); setState(() {}); }
          }),
          const SizedBox(width: 16),
          Expanded(child: Container(height: 56,
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
            child: Center(child: TextField(
              controller: _quantityController, keyboardType: TextInputType.number, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
              decoration: InputDecoration(border: InputBorder.none, hintText: '1', hintStyle: TextStyle(color: Colors.grey[400]),
                suffixText: listing.unit, suffixStyle: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
            )))),
          const SizedBox(width: 16),
          _buildQtyButton(Icons.add_rounded, () {
            final q = _quantity;
            if (q < listing.quantityAvailable) { _quantityController.text = (q + 1).toStringAsFixed(0); setState(() {}); }
          }),
        ]),
      ]),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap,
      child: Container(width: 56, height: 56,
        decoration: BoxDecoration(color: const Color(0xFF1E3A5F).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF1E3A5F), size: 28)));
  }

  Widget _buildPricingTiers(SurplusListing listing) {
    final tiers = [
      {'range': '1-10', 'price': listing.currentPrice, 'discount': 0},
      {'range': '11-50', 'price': listing.currentPrice * 0.9, 'discount': 10},
      {'range': '50+', 'price': listing.currentPrice * 0.8, 'discount': 20},
    ];
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.local_offer_outlined, color: Color(0xFF1E3A5F), size: 22),
          const SizedBox(width: 10),
          const Text('Volume Pricing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
        ]),
        const SizedBox(height: 16),
        ...tiers.asMap().entries.map((e) {
          final i = e.key;
          final t = e.value;
          final isActive = (_quantity >= 1 && _quantity <= 10 && i == 0) ||
                          (_quantity >= 11 && _quantity <= 50 && i == 1) ||
                          (_quantity > 50 && i == 2);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1E3A5F).withOpacity(0.08) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: isActive ? Border.all(color: const Color(0xFF1E3A5F), width: 1.5) : null),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Text('${t['range']} ${listing.unit}', style: TextStyle(fontWeight: FontWeight.w500, color: isActive ? const Color(0xFF1E3A5F) : Colors.grey[700])),
                if ((t['discount'] as int) > 0) ...[const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(4)),
                    child: Text('-${t['discount']}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))],
              ]),
              Text('\$${(t['price'] as double).toStringAsFixed(2)}/${listing.unit}',
                style: TextStyle(fontWeight: FontWeight.w600, color: isActive ? const Color(0xFF1E3A5F) : Colors.grey[700])),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildPickupSection(SurplusListing listing) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.local_shipping_outlined, color: Color(0xFF1E3A5F), size: 22),
          const SizedBox(width: 10),
          const Text('Pickup Preference', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
            child: const Text('Optional', style: TextStyle(fontSize: 11, color: Color(0xFF1E3A5F), fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: listing.expiresAt);
            if (date != null && mounted) {
              final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (time != null) setState(() => _pickupTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12),
              border: _pickupTime != null ? Border.all(color: const Color(0xFF1E3A5F), width: 1.5) : null),
            child: Row(children: [
              Icon(Icons.calendar_today_rounded, size: 20, color: _pickupTime != null ? const Color(0xFF1E3A5F) : Colors.grey[400]),
              const SizedBox(width: 12),
              Text(_pickupTime != null ? _formatDateTime(_pickupTime!) : 'Select preferred pickup date & time',
                style: TextStyle(fontSize: 15, color: _pickupTime != null ? const Color(0xFF1E3A5F) : Colors.grey[500],
                  fontWeight: _pickupTime != null ? FontWeight.w500 : FontWeight.normal)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildBusinessInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.business_outlined, color: Color(0xFF1E3A5F), size: 22),
          const SizedBox(width: 10),
          const Text('Your Business', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
            child: const Text('Optional', style: TextStyle(fontSize: 11, color: Color(0xFF1E3A5F), fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 16),
        TextField(
          controller: _companyController,
          decoration: InputDecoration(
            hintText: 'Company name (for invoice)', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true, fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16)),
        ),
      ]),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.edit_note_rounded, color: Color(0xFF1E3A5F), size: 22),
          const SizedBox(width: 10),
          const Text('Message to Supplier', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
            child: const Text('Optional', style: TextStyle(fontSize: 11, color: Color(0xFF1E3A5F), fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 16),
        TextField(
          controller: _noteController, maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Questions, special requirements, or delivery notes...', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true, fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16)),
        ),
      ]),
    );
  }

  Widget _buildBottomBar(SurplusListing listing, double unitPrice, double total) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))]),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text('${_quantity.toStringAsFixed(0)} ${listing.unit}', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            Text(' × \$${unitPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ]),
          const SizedBox(height: 2),
          Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
        ])),
        const SizedBox(width: 20),
        Expanded(child: SizedBox(height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleClaim,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F),
              disabledBackgroundColor: const Color(0xFF1E3A5F).withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Submit Claim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))))),
      ]),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, $h:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}
