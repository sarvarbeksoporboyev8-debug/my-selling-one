import { View, Text, ScrollView, TouchableOpacity, Image } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { MapPin, Clock, Star, ChevronRight, Package, TrendingUp } from 'lucide-react-native';
import { useTheme, useAuth } from '../../src/contexts';

// Mock data for listings
const mockListings = [
  {
    id: '1',
    title: 'iPhone 13 Pro - Like New',
    category: 'electronics',
    price: 699,
    originalPrice: 999,
    image: 'https://picsum.photos/seed/iphone/400/300',
    seller: { name: 'Tech Store', rating: 4.9 },
    distance: 1.2,
    pickupTime: '2-4 PM',
  },
  {
    id: '2',
    title: 'Organic Vegetables Bundle',
    category: 'food',
    price: 15,
    originalPrice: 30,
    image: 'https://picsum.photos/seed/veggies/400/300',
    seller: { name: 'Green Farm', rating: 4.7 },
    distance: 0.8,
    expiresIn: '3 hours',
  },
  {
    id: '3',
    title: 'Vintage Leather Jacket',
    category: 'clothing',
    price: 89,
    originalPrice: 150,
    image: 'https://picsum.photos/seed/jacket/400/300',
    seller: { name: 'Fashion Hub', rating: 4.5 },
    distance: 2.5,
  },
  {
    id: '4',
    title: 'IKEA Desk - Great Condition',
    category: 'furniture',
    price: 45,
    originalPrice: 120,
    image: 'https://picsum.photos/seed/desk/400/300',
    seller: { name: 'Home Goods', rating: 4.8 },
    distance: 3.1,
  },
];

const categories = [
  { id: 'food', name: 'Food', icon: '🍎', color: '#10B981' },
  { id: 'electronics', name: 'Electronics', icon: '📱', color: '#3B82F6' },
  { id: 'clothing', name: 'Clothing', icon: '👕', color: '#EC4899' },
  { id: 'furniture', name: 'Furniture', icon: '🪑', color: '#F59E0B' },
  { id: 'books', name: 'Books', icon: '📚', color: '#8B5CF6' },
  { id: 'other', name: 'Other', icon: '📦', color: '#6B7280' },
];

function BuyerHome() {
  const { colors } = useTheme();
  const router = useRouter();

  return (
    <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false}>
      {/* Header */}
      <View style={{ paddingHorizontal: 16, paddingTop: 16, paddingBottom: 8 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
          <View>
            <Text style={{ color: colors.text.tertiary, fontSize: 14 }}>Your location</Text>
            <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 4 }}>
              <MapPin size={16} color={colors.brand.primary} />
              <Text style={{ color: colors.text.primary, fontSize: 16, fontWeight: '600', marginLeft: 4 }}>
                San Francisco, CA
              </Text>
            </View>
          </View>
          <TouchableOpacity
            style={{
              width: 44,
              height: 44,
              borderRadius: 22,
              backgroundColor: colors.surface.primary,
              borderWidth: 1,
              borderColor: colors.border.default,
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Text style={{ fontSize: 18 }}>👤</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Search Bar */}
      <TouchableOpacity
        onPress={() => router.push('/(tabs)/discover' as any)}
        style={{
          marginHorizontal: 16,
          marginVertical: 16,
          backgroundColor: colors.surface.primary,
          borderRadius: 12,
          padding: 16,
          borderWidth: 1,
          borderColor: colors.border.default,
          flexDirection: 'row',
          alignItems: 'center',
        }}
      >
        <Text style={{ color: colors.text.tertiary, flex: 1 }}>Search for items...</Text>
      </TouchableOpacity>

      {/* Categories */}
      <View style={{ paddingHorizontal: 16, marginBottom: 24 }}>
        <Text style={{ color: colors.text.primary, fontSize: 18, fontWeight: '600', marginBottom: 12 }}>
          Categories
        </Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {categories.map((cat) => (
            <TouchableOpacity
              key={cat.id}
              style={{
                alignItems: 'center',
                marginRight: 16,
                width: 70,
              }}
            >
              <View
                style={{
                  width: 56,
                  height: 56,
                  borderRadius: 16,
                  backgroundColor: `${cat.color}20`,
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginBottom: 8,
                }}
              >
                <Text style={{ fontSize: 24 }}>{cat.icon}</Text>
              </View>
              <Text style={{ color: colors.text.secondary, fontSize: 12 }}>{cat.name}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      {/* Nearby Deals */}
      <View style={{ paddingHorizontal: 16, marginBottom: 24 }}>
        <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
          <Text style={{ color: colors.text.primary, fontSize: 18, fontWeight: '600' }}>Nearby Deals</Text>
          <TouchableOpacity style={{ flexDirection: 'row', alignItems: 'center' }}>
            <Text style={{ color: colors.brand.primary, fontSize: 14 }}>See all</Text>
            <ChevronRight size={16} color={colors.brand.primary} />
          </TouchableOpacity>
        </View>

        {mockListings.map((listing) => (
          <TouchableOpacity
            key={listing.id}
            style={{
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              marginBottom: 12,
              borderWidth: 1,
              borderColor: colors.border.default,
              overflow: 'hidden',
            }}
          >
            <View style={{ flexDirection: 'row' }}>
              <Image
                source={{ uri: listing.image }}
                style={{ width: 120, height: 120 }}
              />
              <View style={{ flex: 1, padding: 12 }}>
                <Text style={{ color: colors.text.primary, fontSize: 16, fontWeight: '500' }} numberOfLines={2}>
                  {listing.title}
                </Text>
                <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 4 }}>
                  <Star size={14} color="#F59E0B" fill="#F59E0B" />
                  <Text style={{ color: colors.text.secondary, fontSize: 12, marginLeft: 4 }}>
                    {listing.seller.rating} • {listing.seller.name}
                  </Text>
                </View>
                <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 4 }}>
                  <MapPin size={14} color={colors.text.tertiary} />
                  <Text style={{ color: colors.text.tertiary, fontSize: 12, marginLeft: 4 }}>
                    {listing.distance} km away
                  </Text>
                  {listing.expiresIn && (
                    <>
                      <Clock size={14} color={colors.status.warning} style={{ marginLeft: 8 }} />
                      <Text style={{ color: colors.status.warning, fontSize: 12, marginLeft: 4 }}>
                        {listing.expiresIn}
                      </Text>
                    </>
                  )}
                </View>
                <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 8 }}>
                  <Text style={{ color: colors.brand.primary, fontSize: 18, fontWeight: '700' }}>
                    ${listing.price}
                  </Text>
                  {listing.originalPrice && (
                    <Text
                      style={{
                        color: colors.text.muted,
                        fontSize: 14,
                        marginLeft: 8,
                        textDecorationLine: 'line-through',
                      }}
                    >
                      ${listing.originalPrice}
                    </Text>
                  )}
                </View>
              </View>
            </View>
          </TouchableOpacity>
        ))}
      </View>

      {/* Bottom spacing */}
      <View style={{ height: 100 }} />
    </ScrollView>
  );
}

function SellerDashboard() {
  const { colors } = useTheme();

  const stats = [
    { label: 'Active Listings', value: '12', icon: Package, color: colors.brand.primary },
    { label: 'Pending Orders', value: '5', icon: Clock, color: colors.status.warning },
    { label: 'This Month', value: '$1,234', icon: TrendingUp, color: colors.status.success },
  ];

  return (
    <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false}>
      <View style={{ paddingHorizontal: 16, paddingTop: 16 }}>
        <Text style={{ color: colors.text.primary, fontSize: 28, fontWeight: '700' }}>Dashboard</Text>
        <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>Manage your store</Text>
      </View>

      {/* Stats */}
      <View style={{ flexDirection: 'row', paddingHorizontal: 16, marginTop: 24, gap: 12 }}>
        {stats.map((stat, index) => (
          <View
            key={index}
            style={{
              flex: 1,
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              padding: 16,
              borderWidth: 1,
              borderColor: colors.border.default,
            }}
          >
            <stat.icon size={24} color={stat.color} />
            <Text style={{ color: colors.text.primary, fontSize: 24, fontWeight: '700', marginTop: 8 }}>
              {stat.value}
            </Text>
            <Text style={{ color: colors.text.tertiary, fontSize: 12, marginTop: 4 }}>{stat.label}</Text>
          </View>
        ))}
      </View>

      {/* Recent Orders */}
      <View style={{ paddingHorizontal: 16, marginTop: 24 }}>
        <Text style={{ color: colors.text.primary, fontSize: 18, fontWeight: '600', marginBottom: 12 }}>
          Recent Orders
        </Text>
        {[1, 2, 3].map((i) => (
          <View
            key={i}
            style={{
              backgroundColor: colors.surface.primary,
              borderRadius: 12,
              padding: 16,
              marginBottom: 12,
              borderWidth: 1,
              borderColor: colors.border.default,
            }}
          >
            <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
              <Text style={{ color: colors.text.primary, fontWeight: '500' }}>Order #{1000 + i}</Text>
              <View
                style={{
                  backgroundColor: colors.status.warningLight,
                  paddingHorizontal: 8,
                  paddingVertical: 4,
                  borderRadius: 8,
                }}
              >
                <Text style={{ color: colors.status.warning, fontSize: 12, fontWeight: '500' }}>Pending</Text>
              </View>
            </View>
            <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>2 items • $45.00</Text>
          </View>
        ))}
      </View>

      <View style={{ height: 100 }} />
    </ScrollView>
  );
}

function DeliveryAvailable() {
  const { colors } = useTheme();

  const deliveries = [
    { id: '1', pickup: 'Green Farm', dropoff: '123 Main St', distance: 2.5, fee: 8, time: 15 },
    { id: '2', pickup: 'Tech Store', dropoff: '456 Oak Ave', distance: 4.2, fee: 12, time: 25 },
    { id: '3', pickup: 'Fashion Hub', dropoff: '789 Pine Rd', distance: 1.8, fee: 6, time: 10 },
  ];

  return (
    <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false}>
      <View style={{ paddingHorizontal: 16, paddingTop: 16 }}>
        <Text style={{ color: colors.text.primary, fontSize: 28, fontWeight: '700' }}>Available</Text>
        <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>Deliveries near you</Text>
      </View>

      {/* Online Toggle */}
      <View
        style={{
          marginHorizontal: 16,
          marginTop: 16,
          backgroundColor: colors.status.successLight,
          borderRadius: 12,
          padding: 16,
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <View>
          <Text style={{ color: colors.status.success, fontWeight: '600' }}>You're Online</Text>
          <Text style={{ color: colors.status.success, fontSize: 12, opacity: 0.8 }}>
            Accepting delivery requests
          </Text>
        </View>
        <View
          style={{
            width: 12,
            height: 12,
            borderRadius: 6,
            backgroundColor: colors.status.success,
          }}
        />
      </View>

      {/* Available Deliveries */}
      <View style={{ paddingHorizontal: 16, marginTop: 24 }}>
        <Text style={{ color: colors.text.primary, fontSize: 18, fontWeight: '600', marginBottom: 12 }}>
          {deliveries.length} deliveries available
        </Text>

        {deliveries.map((delivery) => (
          <TouchableOpacity
            key={delivery.id}
            style={{
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              padding: 16,
              marginBottom: 12,
              borderWidth: 1,
              borderColor: colors.border.default,
            }}
          >
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <View style={{ flex: 1 }}>
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                  <View
                    style={{
                      width: 8,
                      height: 8,
                      borderRadius: 4,
                      backgroundColor: colors.brand.primary,
                    }}
                  />
                  <Text style={{ color: colors.text.primary, marginLeft: 8, fontWeight: '500' }}>
                    {delivery.pickup}
                  </Text>
                </View>
                <View
                  style={{
                    width: 1,
                    height: 20,
                    backgroundColor: colors.border.default,
                    marginLeft: 3.5,
                    marginVertical: 4,
                  }}
                />
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                  <View
                    style={{
                      width: 8,
                      height: 8,
                      borderRadius: 4,
                      backgroundColor: colors.status.error,
                    }}
                  />
                  <Text style={{ color: colors.text.secondary, marginLeft: 8 }}>{delivery.dropoff}</Text>
                </View>
              </View>
              <View style={{ alignItems: 'flex-end' }}>
                <Text style={{ color: colors.brand.primary, fontSize: 20, fontWeight: '700' }}>
                  ${delivery.fee}
                </Text>
                <Text style={{ color: colors.text.tertiary, fontSize: 12 }}>
                  {delivery.distance} km • {delivery.time} min
                </Text>
              </View>
            </View>
            <TouchableOpacity
              style={{
                backgroundColor: colors.brand.primary,
                borderRadius: 8,
                padding: 12,
                alignItems: 'center',
                marginTop: 12,
              }}
            >
              <Text style={{ color: '#FFFFFF', fontWeight: '600' }}>Accept Delivery</Text>
            </TouchableOpacity>
          </TouchableOpacity>
        ))}
      </View>

      <View style={{ height: 100 }} />
    </ScrollView>
  );
}

export default function HomeScreen() {
  const { colors } = useTheme();
  const { user } = useAuth();
  const role = user?.role || 'buyer';

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
      {role === 'buyer' && <BuyerHome />}
      {role === 'seller' && <SellerDashboard />}
      {role === 'delivery' && <DeliveryAvailable />}
    </SafeAreaView>
  );
}
