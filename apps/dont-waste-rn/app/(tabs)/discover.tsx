import { View, Text, TextInput, ScrollView, TouchableOpacity, Image } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Search, Filter, MapPin, Star, Clock } from 'lucide-react-native';
import { useTheme } from '../../src/contexts';

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
  {
    id: '5',
    title: 'Fresh Bakery Items',
    category: 'food',
    price: 8,
    originalPrice: 20,
    image: 'https://picsum.photos/seed/bakery/400/300',
    seller: { name: 'Local Bakery', rating: 4.9 },
    distance: 0.5,
    expiresIn: '1 hour',
  },
  {
    id: '6',
    title: 'Gaming Console Bundle',
    category: 'electronics',
    price: 350,
    originalPrice: 500,
    image: 'https://picsum.photos/seed/gaming/400/300',
    seller: { name: 'Game Zone', rating: 4.6 },
    distance: 4.2,
  },
];

const filters = ['All', 'Food', 'Electronics', 'Clothing', 'Furniture', 'Books'];

export default function DiscoverScreen() {
  const { colors } = useTheme();

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
      {/* Header */}
      <View style={{ paddingHorizontal: 16, paddingTop: 16 }}>
        <Text style={{ color: colors.text.primary, fontSize: 28, fontWeight: '700' }}>Discover</Text>
        <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>Find great deals near you</Text>
      </View>

      {/* Search Bar */}
      <View
        style={{
          flexDirection: 'row',
          paddingHorizontal: 16,
          marginTop: 16,
          gap: 12,
        }}
      >
        <View
          style={{
            flex: 1,
            flexDirection: 'row',
            alignItems: 'center',
            backgroundColor: colors.surface.primary,
            borderRadius: 12,
            paddingHorizontal: 16,
            borderWidth: 1,
            borderColor: colors.border.default,
          }}
        >
          <Search size={20} color={colors.text.tertiary} />
          <TextInput
            placeholder="Search items..."
            placeholderTextColor={colors.text.tertiary}
            style={{
              flex: 1,
              paddingVertical: 14,
              marginLeft: 12,
              color: colors.text.primary,
              fontSize: 16,
            }}
          />
        </View>
        <TouchableOpacity
          style={{
            width: 52,
            height: 52,
            borderRadius: 12,
            backgroundColor: colors.surface.primary,
            borderWidth: 1,
            borderColor: colors.border.default,
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Filter size={20} color={colors.text.secondary} />
        </TouchableOpacity>
      </View>

      {/* Filter Chips */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        style={{ marginTop: 16 }}
        contentContainerStyle={{ paddingHorizontal: 16, gap: 8 }}
      >
        {filters.map((filter, index) => (
          <TouchableOpacity
            key={filter}
            style={{
              paddingHorizontal: 16,
              paddingVertical: 8,
              borderRadius: 20,
              backgroundColor: index === 0 ? colors.brand.primary : colors.surface.primary,
              borderWidth: index === 0 ? 0 : 1,
              borderColor: colors.border.default,
              marginRight: 8,
            }}
          >
            <Text
              style={{
                color: index === 0 ? '#FFFFFF' : colors.text.secondary,
                fontWeight: index === 0 ? '600' : '400',
              }}
            >
              {filter}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* Results */}
      <ScrollView
        style={{ flex: 1, marginTop: 16 }}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 100 }}
        showsVerticalScrollIndicator={false}
      >
        <Text style={{ color: colors.text.secondary, marginBottom: 12 }}>
          {mockListings.length} items found
        </Text>

        {/* Grid Layout */}
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 12 }}>
          {mockListings.map((listing) => (
            <TouchableOpacity
              key={listing.id}
              style={{
                width: '48%',
                backgroundColor: colors.surface.primary,
                borderRadius: 16,
                overflow: 'hidden',
                borderWidth: 1,
                borderColor: colors.border.default,
              }}
            >
              <Image
                source={{ uri: listing.image }}
                style={{ width: '100%', height: 140 }}
              />
              {listing.expiresIn && (
                <View
                  style={{
                    position: 'absolute',
                    top: 8,
                    left: 8,
                    backgroundColor: colors.status.warningLight,
                    paddingHorizontal: 8,
                    paddingVertical: 4,
                    borderRadius: 8,
                    flexDirection: 'row',
                    alignItems: 'center',
                  }}
                >
                  <Clock size={12} color={colors.status.warning} />
                  <Text style={{ color: colors.status.warning, fontSize: 10, marginLeft: 4, fontWeight: '500' }}>
                    {listing.expiresIn}
                  </Text>
                </View>
              )}
              <View style={{ padding: 12 }}>
                <Text
                  style={{ color: colors.text.primary, fontSize: 14, fontWeight: '500' }}
                  numberOfLines={2}
                >
                  {listing.title}
                </Text>
                <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 4 }}>
                  <MapPin size={12} color={colors.text.tertiary} />
                  <Text style={{ color: colors.text.tertiary, fontSize: 11, marginLeft: 4 }}>
                    {listing.distance} km
                  </Text>
                  <Star size={12} color="#F59E0B" fill="#F59E0B" style={{ marginLeft: 8 }} />
                  <Text style={{ color: colors.text.tertiary, fontSize: 11, marginLeft: 4 }}>
                    {listing.seller.rating}
                  </Text>
                </View>
                <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 8 }}>
                  <Text style={{ color: colors.brand.primary, fontSize: 16, fontWeight: '700' }}>
                    ${listing.price}
                  </Text>
                  {listing.originalPrice && (
                    <Text
                      style={{
                        color: colors.text.muted,
                        fontSize: 12,
                        marginLeft: 6,
                        textDecorationLine: 'line-through',
                      }}
                    >
                      ${listing.originalPrice}
                    </Text>
                  )}
                </View>
              </View>
            </TouchableOpacity>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
