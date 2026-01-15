import 'package:dw_domain/dw_domain.dart';

bool isDemoMode = false;

// Categories for B2B Surplus Marketplace
class SurplusCategory {
  final String id;
  final String name;
  final String icon;
  final String color;
  const SurplusCategory({required this.id, required this.name, required this.icon, required this.color});
}

const surplusCategories = [
  SurplusCategory(id: 'food', name: 'Food & Beverage', icon: 'restaurant', color: '4CAF50'),
  SurplusCategory(id: 'retail', name: 'Retail Overstock', icon: 'shopping_bag', color: 'E91E63'),
  SurplusCategory(id: 'hospitality', name: 'Hospitality', icon: 'hotel', color: '9C27B0'),
  SurplusCategory(id: 'construction', name: 'Construction', icon: 'construction', color: 'FF9800'),
  SurplusCategory(id: 'office', name: 'Office & Corporate', icon: 'business', color: '2196F3'),
  SurplusCategory(id: 'industrial', name: 'Industrial', icon: 'factory', color: '607D8B'),
  SurplusCategory(id: 'packaging', name: 'Packaging', icon: 'inventory_2', color: '795548'),
  SurplusCategory(id: 'events', name: 'Event Materials', icon: 'celebration', color: 'FF5722'),
];

final List<SurplusListing> demoListings = [
  // FOOD & BEVERAGE
  SurplusListing(
    id: 1, title: 'Organic Produce Box', description: 'Mixed organic vegetables and fruits. Restaurant quality.',
    quantityAvailable: 50, unit: 'box', basePrice: 45.00, currentPrice: 22.50, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(hours: 18)),
    pickupStartAt: DateTime.now().add(const Duration(hours: 2)),
    pickupEndAt: DateTime.now().add(const Duration(hours: 8)),
    status: 'active', visibility: 'public', latitude: 37.7749, longitude: -122.4194, distanceKm: 0.5,
    enterprise: const EnterpriseSummary(id: 1, name: 'Metro Foods Distribution'),
    variant: const VariantSummary(id: 1, name: 'Mixed Organic', productName: 'Produce'),
    photoUrls: ['https://images.unsplash.com/photo-1542838132-92c53300491e?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1542838132-92c53300491e?w=400'],
  ),
  SurplusListing(
    id: 2, title: 'Artisan Bakery Surplus', description: 'Fresh bread, pastries, croissants. Baked today.',
    quantityAvailable: 100, unit: 'piece', basePrice: 4.50, currentPrice: 1.80, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(hours: 8)),
    pickupStartAt: DateTime.now(), pickupEndAt: DateTime.now().add(const Duration(hours: 4)),
    status: 'active', visibility: 'public', latitude: 37.7849, longitude: -122.4094, distanceKm: 1.2,
    enterprise: const EnterpriseSummary(id: 2, name: 'Golden Crust Bakery'),
    variant: const VariantSummary(id: 2, name: 'Assorted', productName: 'Bakery'),
    photoUrls: ['https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400'],
  ),
  // RETAIL OVERSTOCK
  SurplusListing(
    id: 3, title: 'Designer Clothing - Last Season', description: 'Premium brand clothing. New with tags. Mixed sizes.',
    quantityAvailable: 500, unit: 'piece', basePrice: 89.00, currentPrice: 25.00, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(days: 30)),
    pickupStartAt: DateTime.now(), pickupEndAt: DateTime.now().add(const Duration(days: 7)),
    status: 'active', visibility: 'public', latitude: 37.7649, longitude: -122.4294, distanceKm: 2.1,
    enterprise: const EnterpriseSummary(id: 3, name: 'Fashion Forward Retail'),
    variant: const VariantSummary(id: 3, name: 'Mixed Apparel', productName: 'Clothing'),
    photoUrls: ['https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=400'],
    qualityNotes: 'Condition: New with tags',
  ),
  SurplusListing(
    id: 4, title: 'Electronics Accessories Lot', description: 'Phone cases, chargers, cables. Retail packaging.',
    quantityAvailable: 1000, unit: 'unit', basePrice: 15.00, currentPrice: 3.50, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(days: 60)),
    pickupStartAt: DateTime.now(), pickupEndAt: DateTime.now().add(const Duration(days: 14)),
    status: 'active', visibility: 'public', latitude: 37.7899, longitude: -122.4044, distanceKm: 1.5,
    enterprise: const EnterpriseSummary(id: 4, name: 'TechMart Wholesale'),
    variant: const VariantSummary(id: 4, name: 'Mixed Electronics', productName: 'Accessories'),
    photoUrls: ['https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=400'],
    qualityNotes: 'Condition: New in box',
  ),
  // CONSTRUCTION
  SurplusListing(
    id: 5, title: 'Ceramic Floor Tiles', description: 'Premium porcelain tiles. Project overorder. 60x60cm.',
    quantityAvailable: 200, unit: 'sqm', basePrice: 35.00, currentPrice: 12.00, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(days: 90)),
    pickupStartAt: DateTime.now(), pickupEndAt: DateTime.now().add(const Duration(days: 30)),
    status: 'active', visibility: 'public', latitude: 37.7599, longitude: -122.4344, distanceKm: 3.2,
    enterprise: const EnterpriseSummary(id: 5, name: 'BuildRight Construction'),
    variant: const VariantSummary(id: 5, name: 'Porcelain', productName: 'Tiles'),
    photoUrls: ['https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=400'],
    qualityNotes: 'Condition: Unused, original packaging',
  ),
  SurplusListing(
    id: 6, title: 'Interior Paint - Premium', description: 'Unopened paint cans. Various colors. Interior latex.',
    quantityAvailable: 75, unit: 'gallon', basePrice: 55.00, currentPrice: 20.00, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(days: 180)),
    pickupStartAt: DateTime.now(), pickupEndAt: DateTime.now().add(const Duration(days: 14)),
    status: 'active', visibility: 'public', latitude: 37.7949, longitude: -122.3994, distanceKm: 1.8,
    enterprise: const EnterpriseSummary(id: 6, name: 'Premier Painting Co'),
    variant: const VariantSummary(id: 6, name: 'Interior Latex', productName: 'Paint'),
    photoUrls: ['https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400'],
    qualityNotes: 'Condition: Sealed, never opened',
  ),
  // OFFICE & CORPORATE
  SurplusListing(
    id: 7, title: 'Ergonomic Office Chairs', description: 'Herman Miller style chairs. Company downsizing.',
    quantityAvailable: 45, unit: 'piece', basePrice: 450.00, currentPrice: 120.00, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(days: 45)),
    pickupStartAt: DateTime.now(), pickupEndAt: DateTime.now().add(const Duration(days: 21)),
    status: 'active', visibility: 'public', latitude: 37.7699, longitude: -122.4144, distanceKm: 0.9,
    enterprise: const EnterpriseSummary(id: 7, name: 'TechCorp Inc'),
    variant: const VariantSummary(id: 7, name: 'Ergonomic', productName: 'Office Chairs'),
    photoUrls: ['https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=400'],
    qualityNotes: 'Condition: Used - Excellent',
  ),
  SurplusListing(
    id: 8, title: 'Standing Desks', description: 'Electric height-adjustable desks. Minor scratches.',
    quantityAvailable: 30, unit: 'piece', basePrice: 600.00, currentPrice: 180.00, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(days: 30)),
    pickupStartAt: DateTime.now(), pickupEndAt: DateTime.now().add(const Duration(days: 14)),
    status: 'active', visibility: 'public', latitude: 37.7799, longitude: -122.4244, distanceKm: 1.1,
    enterprise: const EnterpriseSummary(id: 8, name: 'StartupHub Offices'),
    variant: const VariantSummary(id: 8, name: 'Electric', productName: 'Standing Desks'),
    photoUrls: ['https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=400'],
    qualityNotes: 'Condition: Used - Good',
  ),
  // HOSPITALITY
  SurplusListing(
    id: 9, title: 'Hotel Bed Linens Set', description: 'Premium cotton sheets, pillowcases. Hotel renovation.',
    quantityAvailable: 200, unit: 'set', basePrice: 85.00, currentPrice: 28.00, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(days: 60)),
    pickupStartAt: DateTime.now(), pickupEndAt: DateTime.now().add(const Duration(days: 21)),
    status: 'active', visibility: 'public', latitude: 37.7549, longitude: -122.4394, distanceKm: 2.5,
    enterprise: const EnterpriseSummary(id: 9, name: 'Grand Plaza Hotel'),
    variant: const VariantSummary(id: 9, name: 'Premium Cotton', productName: 'Linens'),
    photoUrls: ['https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=400'],
    qualityNotes: 'Condition: Lightly used, professionally cleaned',
  ),
  SurplusListing(
    id: 10, title: 'Restaurant Tableware', description: 'Plates, bowls, glasses. Restaurant closing sale.',
    quantityAvailable: 500, unit: 'piece', basePrice: 12.00, currentPrice: 3.00, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(days: 21)),
    pickupStartAt: DateTime.now(), pickupEndAt: DateTime.now().add(const Duration(days: 7)),
    status: 'active', visibility: 'public', latitude: 37.7849, longitude: -122.3944, distanceKm: 1.3,
    enterprise: const EnterpriseSummary(id: 10, name: 'Bella Italia Restaurant'),
    variant: const VariantSummary(id: 10, name: 'Commercial Grade', productName: 'Tableware'),
    photoUrls: ['https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400'],
    qualityNotes: 'Condition: Used - Good',
  ),
  // PACKAGING & LOGISTICS
  SurplusListing(
    id: 11, title: 'Wooden Pallets', description: 'Standard EUR pallets. Good condition for reuse.',
    quantityAvailable: 150, unit: 'piece', basePrice: 25.00, currentPrice: 8.00, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(days: 90)),
    pickupStartAt: DateTime.now(), pickupEndAt: DateTime.now().add(const Duration(days: 30)),
    status: 'active', visibility: 'public', latitude: 37.8049, longitude: -122.4094, distanceKm: 3.2,
    enterprise: const EnterpriseSummary(id: 11, name: 'Bay Logistics Center'),
    variant: const VariantSummary(id: 11, name: 'EUR Standard', productName: 'Pallets'),
    photoUrls: ['https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400'],
    qualityNotes: 'Condition: Used - Good',
  ),
  SurplusListing(
    id: 12, title: 'Shipping Boxes - Various', description: 'Cardboard boxes, multiple sizes. Once-used.',
    quantityAvailable: 1000, unit: 'piece', basePrice: 3.00, currentPrice: 0.50, currency: 'USD',
    expiresAt: DateTime.now().add(const Duration(days: 60)),
    pickupStartAt: DateTime.now(), pickupEndAt: DateTime.now().add(const Duration(days: 14)),
    status: 'active', visibility: 'public', latitude: 37.7719, longitude: -122.4064, distanceKm: 0.7,
    enterprise: const EnterpriseSummary(id: 12, name: 'EcoShip Fulfillment'),
    variant: const VariantSummary(id: 12, name: 'Mixed Sizes', productName: 'Boxes'),
    photoUrls: ['https://images.unsplash.com/photo-1607166452427-7e4477079cb9?w=400'],
    imageUrls: ['https://images.unsplash.com/photo-1607166452427-7e4477079cb9?w=400'],
    qualityNotes: 'Condition: Used once, clean',
  ),
];

final List<Reservation> demoReservations = [
  Reservation(id: 101, listing: demoListings[0], quantity: 10, totalPrice: 225.00,
    status: ReservationStatus.confirmed, message: 'Will pick up with truck',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    expiresAt: DateTime.now().add(const Duration(hours: 4))),
  Reservation(id: 102, listing: demoListings[6], quantity: 5, totalPrice: 600.00,
    status: ReservationStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    expiresAt: DateTime.now().add(const Duration(hours: 24))),
  Reservation(id: 103, listing: demoListings[4], quantity: 20, totalPrice: 240.00,
    status: ReservationStatus.completed,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    expiresAt: DateTime.now().subtract(const Duration(days: 2))),
];

final List<WatchlistItem> demoWatchlist = [
  WatchlistItem(id: 201, listing: demoListings[2], addedAt: DateTime.now().subtract(const Duration(hours: 5))),
  WatchlistItem(id: 202, listing: demoListings[6], addedAt: DateTime.now().subtract(const Duration(days: 1))),
  WatchlistItem(id: 203, listing: demoListings[10], addedAt: DateTime.now().subtract(const Duration(hours: 12))),
];

final List<Taxon> demoTaxons = [
  const Taxon(id: 1, name: 'Food & Beverage', prettyName: 'Food & Beverage'),
  const Taxon(id: 2, name: 'Retail Overstock', prettyName: 'Retail Overstock'),
  const Taxon(id: 3, name: 'Hospitality', prettyName: 'Hospitality'),
  const Taxon(id: 4, name: 'Construction', prettyName: 'Construction'),
  const Taxon(id: 5, name: 'Office & Corporate', prettyName: 'Office & Corporate'),
  const Taxon(id: 6, name: 'Industrial', prettyName: 'Industrial'),
  const Taxon(id: 7, name: 'Packaging', prettyName: 'Packaging'),
  const Taxon(id: 8, name: 'Event Materials', prettyName: 'Event Materials'),
];
