// Product/Listing types
export type Category =
  | 'food'
  | 'electronics'
  | 'clothing'
  | 'furniture'
  | 'books'
  | 'sports'
  | 'beauty'
  | 'automotive'
  | 'other';

export type ListingStatus = 'active' | 'reserved' | 'sold' | 'expired' | 'cancelled';

export type Listing = {
  id: string;
  title: string;
  description: string;
  category: Category;
  images: string[];
  price: number;
  originalPrice?: number;
  currency: string;
  quantity: number;
  unit: string;
  condition: 'new' | 'like_new' | 'good' | 'fair';
  status: ListingStatus;
  // Location
  latitude: number;
  longitude: number;
  address: string;
  city: string;
  // Pickup/Delivery
  pickupAvailable: boolean;
  deliveryAvailable: boolean;
  pickupStartAt?: string;
  pickupEndAt?: string;
  // Expiry (for food items)
  expiresAt?: string;
  // Seller info
  seller: SellerSummary;
  // Timestamps
  createdAt: string;
  updatedAt: string;
  // Computed
  distance?: number;
};

export type SellerSummary = {
  id: string;
  name: string;
  storeName?: string;
  avatarUrl?: string;
  isVerified: boolean;
  rating: number;
  reviewCount: number;
};

// Order types
export type OrderStatus =
  | 'pending'
  | 'confirmed'
  | 'ready_for_pickup'
  | 'awaiting_delivery'
  | 'in_delivery'
  | 'delivered'
  | 'completed'
  | 'cancelled';

export type DeliveryMethod = 'pickup' | 'delivery';

export type Order = {
  id: string;
  listing: Listing;
  buyer: BuyerSummary;
  seller: SellerSummary;
  deliveryPerson?: DeliveryPersonSummary;
  // Order details
  quantity: number;
  unitPrice: number;
  subtotal: number;
  deliveryFee: number;
  serviceFee: number;
  total: number;
  currency: string;
  // Delivery
  deliveryMethod: DeliveryMethod;
  deliveryAddress?: Address;
  pickupAddress?: Address;
  // Status
  status: OrderStatus;
  statusHistory: OrderStatusHistory[];
  // Timestamps
  createdAt: string;
  confirmedAt?: string;
  readyAt?: string;
  pickedUpAt?: string;
  deliveredAt?: string;
  completedAt?: string;
  cancelledAt?: string;
  // Notes
  buyerNotes?: string;
  sellerNotes?: string;
  cancellationReason?: string;
};

export type OrderStatusHistory = {
  status: OrderStatus;
  timestamp: string;
  note?: string;
};

export type BuyerSummary = {
  id: string;
  name: string;
  avatarUrl?: string;
  rating: number;
  reviewCount: number;
};

export type DeliveryPersonSummary = {
  id: string;
  name: string;
  avatarUrl?: string;
  phone?: string;
  vehicleType: string;
  licensePlate?: string;
  rating: number;
  reviewCount: number;
  currentLocation?: {
    latitude: number;
    longitude: number;
  };
};

export type Address = {
  id?: string;
  label?: string;
  address1: string;
  address2?: string;
  city: string;
  state: string;
  zipcode: string;
  country: string;
  latitude: number;
  longitude: number;
};

// Delivery types (for delivery person)
export type DeliveryRequest = {
  id: string;
  order: Order;
  pickupLocation: Address;
  deliveryLocation: Address;
  distance: number;
  estimatedTime: number; // minutes
  deliveryFee: number;
  status: 'available' | 'accepted' | 'picked_up' | 'delivered' | 'cancelled';
  createdAt: string;
  expiresAt: string;
};

// Review types
export type Review = {
  id: string;
  orderId: string;
  reviewerId: string;
  reviewerName: string;
  reviewerAvatar?: string;
  targetId: string;
  targetType: 'seller' | 'buyer' | 'delivery';
  rating: number;
  comment?: string;
  createdAt: string;
};

// Notification types
export type NotificationType =
  | 'order_placed'
  | 'order_confirmed'
  | 'order_ready'
  | 'delivery_assigned'
  | 'delivery_picked_up'
  | 'delivery_nearby'
  | 'order_delivered'
  | 'order_completed'
  | 'order_cancelled'
  | 'new_review'
  | 'price_drop'
  | 'listing_expiring';

export type Notification = {
  id: string;
  type: NotificationType;
  title: string;
  message: string;
  data?: Record<string, unknown>;
  read: boolean;
  createdAt: string;
};

// Filter types
export type ListingFilters = {
  category?: Category;
  minPrice?: number;
  maxPrice?: number;
  condition?: Listing['condition'][];
  deliveryAvailable?: boolean;
  pickupAvailable?: boolean;
  maxDistance?: number;
  sortBy?: 'price_asc' | 'price_desc' | 'distance' | 'newest' | 'expiring_soon';
};
