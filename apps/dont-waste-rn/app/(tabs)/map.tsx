import { View, Text, TouchableOpacity, StyleSheet, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme, useAuth } from '../../src/contexts';
import { MapPin, Navigation, Search, Store, Truck, Package } from 'lucide-react-native';
import { useState } from 'react';

// Mock locations for different roles
const buyerLocations = [
  { id: '1', name: 'Green Farm', type: 'food', distance: '0.8 km', address: '123 Farm Road', rating: 4.7 },
  { id: '2', name: 'Tech Store', type: 'electronics', distance: '1.2 km', address: '456 Tech Ave', rating: 4.9 },
  { id: '3', name: 'Fashion Hub', type: 'clothing', distance: '2.5 km', address: '789 Style St', rating: 4.5 },
  { id: '4', name: 'Home Goods', type: 'furniture', distance: '3.1 km', address: '321 Home Blvd', rating: 4.8 },
  { id: '5', name: 'Local Bakery', type: 'food', distance: '0.5 km', address: '555 Baker Lane', rating: 4.9 },
];

const deliveryLocations = [
  { id: '1', name: 'Pickup: Green Farm', type: 'pickup', distance: '1.2 km', address: '123 Farm Road' },
  { id: '2', name: 'Dropoff: John D.', type: 'dropoff', distance: '2.5 km', address: '456 Main St, Apt 12' },
];

const sellerLocations = [
  { id: '1', name: 'Your Store Location', type: 'store', distance: '0 km', address: '123 Your Address' },
  { id: '2', name: 'Delivery Zone 1', type: 'zone', distance: '5 km radius', address: 'Downtown Area' },
  { id: '3', name: 'Delivery Zone 2', type: 'zone', distance: '10 km radius', address: 'Extended Area' },
];

export default function MapScreen() {
  const { colors } = useTheme();
  const { user } = useAuth();
  const role = user?.role || 'buyer';
  const [selectedLocation, setSelectedLocation] = useState<string | null>(null);

  const locations = role === 'delivery' ? deliveryLocations : role === 'seller' ? sellerLocations : buyerLocations;

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'food':
        return colors.category.food;
      case 'electronics':
        return colors.category.electronics;
      case 'clothing':
        return '#EC4899';
      case 'furniture':
        return colors.category.furniture;
      case 'pickup':
        return colors.brand.primary;
      case 'dropoff':
        return colors.status.error;
      case 'store':
        return colors.role.seller;
      case 'zone':
        return colors.status.info;
      default:
        return colors.brand.primary;
    }
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'pickup':
        return <Package size={18} color="#FFFFFF" />;
      case 'dropoff':
        return <MapPin size={18} color="#FFFFFF" />;
      case 'store':
        return <Store size={18} color="#FFFFFF" />;
      case 'zone':
        return <Navigation size={18} color="#FFFFFF" />;
      default:
        return <Store size={18} color="#FFFFFF" />;
    }
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
      {/* Header */}
      <View style={{ paddingHorizontal: 16, paddingTop: 16 }}>
        <Text style={{ color: colors.text.primary, fontSize: 28, fontWeight: '700' }}>Map</Text>
        <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>
          {role === 'buyer' ? 'Find sellers near you' : role === 'delivery' ? 'Delivery route' : 'Your coverage area'}
        </Text>
      </View>

      {/* Search Bar */}
      <TouchableOpacity
        style={[
          styles.searchBar,
          {
            backgroundColor: colors.surface.primary,
            borderColor: colors.border.default,
            marginHorizontal: 16,
            marginTop: 16,
          },
        ]}
      >
        <Search size={20} color={colors.text.tertiary} />
        <Text style={{ color: colors.text.tertiary, marginLeft: 12, fontSize: 16 }}>
          Search locations...
        </Text>
      </TouchableOpacity>

      {/* Map Placeholder */}
      <View
        style={[
          styles.mapPlaceholder,
          {
            backgroundColor: colors.surface.primary,
            borderColor: colors.border.default,
            marginHorizontal: 16,
            marginTop: 16,
          },
        ]}
      >
        <View style={[styles.mapGrid, { borderColor: colors.border.subtle }]}>
          {/* Grid lines to simulate map */}
          {[...Array(5)].map((_, i) => (
            <View
              key={`h-${i}`}
              style={[
                styles.gridLineH,
                { backgroundColor: colors.border.subtle, top: `${(i + 1) * 16.66}%` },
              ]}
            />
          ))}
          {[...Array(5)].map((_, i) => (
            <View
              key={`v-${i}`}
              style={[
                styles.gridLineV,
                { backgroundColor: colors.border.subtle, left: `${(i + 1) * 16.66}%` },
              ]}
            />
          ))}
          
          {/* Mock markers */}
          <View style={[styles.mockMarker, { backgroundColor: colors.brand.primary, top: '30%', left: '40%' }]}>
            <MapPin size={14} color="#FFFFFF" />
          </View>
          <View style={[styles.mockMarker, { backgroundColor: colors.category.electronics, top: '50%', left: '60%' }]}>
            <MapPin size={14} color="#FFFFFF" />
          </View>
          <View style={[styles.mockMarker, { backgroundColor: '#EC4899', top: '70%', left: '30%' }]}>
            <MapPin size={14} color="#FFFFFF" />
          </View>
          <View style={[styles.mockMarker, { backgroundColor: colors.category.furniture, top: '40%', left: '70%' }]}>
            <MapPin size={14} color="#FFFFFF" />
          </View>
          
          {/* Center marker (user location) */}
          <View style={[styles.userMarker, { borderColor: colors.brand.primary }]}>
            <View style={[styles.userMarkerInner, { backgroundColor: colors.brand.primary }]} />
          </View>
        </View>
        
        {/* Map controls */}
        <View style={styles.mapControls}>
          <TouchableOpacity
            style={[styles.controlButton, { backgroundColor: colors.surface.secondary }]}
          >
            <Navigation size={20} color={colors.text.secondary} />
          </TouchableOpacity>
        </View>

        {/* Role indicator */}
        <View
          style={[
            styles.roleIndicator,
            {
              backgroundColor:
                role === 'seller'
                  ? colors.role.sellerLight
                  : role === 'delivery'
                  ? colors.role.deliveryLight
                  : colors.role.buyerLight,
            },
          ]}
        >
          <Text
            style={{
              color:
                role === 'seller'
                  ? colors.role.seller
                  : role === 'delivery'
                  ? colors.role.delivery
                  : colors.role.buyer,
              fontWeight: '600',
              fontSize: 12,
            }}
          >
            {role === 'seller' ? 'Seller View' : role === 'delivery' ? 'Delivery View' : 'Buyer View'}
          </Text>
        </View>
      </View>

      {/* Locations List */}
      <View style={{ flex: 1, marginTop: 16 }}>
        <Text style={{ color: colors.text.primary, fontSize: 18, fontWeight: '600', paddingHorizontal: 16, marginBottom: 12 }}>
          {role === 'buyer' ? 'Nearby Sellers' : role === 'delivery' ? 'Route Stops' : 'Your Locations'}
        </Text>
        <ScrollView
          style={{ flex: 1 }}
          contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 100 }}
          showsVerticalScrollIndicator={false}
        >
          {locations.map((location: any) => (
            <TouchableOpacity
              key={location.id}
              onPress={() => setSelectedLocation(location.id)}
              style={[
                styles.locationCard,
                {
                  backgroundColor: colors.surface.primary,
                  borderColor: selectedLocation === location.id ? getTypeColor(location.type) : colors.border.default,
                  borderWidth: selectedLocation === location.id ? 2 : 1,
                },
              ]}
            >
              <View
                style={[
                  styles.locationIcon,
                  { backgroundColor: getTypeColor(location.type) },
                ]}
              >
                {getTypeIcon(location.type)}
              </View>
              <View style={{ flex: 1, marginLeft: 12 }}>
                <Text style={{ color: colors.text.primary, fontSize: 16, fontWeight: '500' }}>
                  {location.name}
                </Text>
                <Text style={{ color: colors.text.tertiary, fontSize: 13, marginTop: 2 }}>
                  {location.address}
                </Text>
                <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 4 }}>
                  <MapPin size={12} color={colors.text.muted} />
                  <Text style={{ color: colors.text.muted, fontSize: 12, marginLeft: 4 }}>
                    {location.distance}
                  </Text>
                  {location.rating && (
                    <>
                      <Text style={{ color: colors.text.muted, marginHorizontal: 8 }}>•</Text>
                      <Text style={{ color: '#F59E0B', fontSize: 12 }}>★ {location.rating}</Text>
                    </>
                  )}
                </View>
              </View>
              <TouchableOpacity
                style={[styles.directionsButton, { backgroundColor: colors.brand.primary }]}
              >
                <Navigation size={16} color="#FFFFFF" />
              </TouchableOpacity>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderRadius: 12,
    borderWidth: 1,
  },
  mapPlaceholder: {
    height: 200,
    borderRadius: 16,
    borderWidth: 1,
    overflow: 'hidden',
    position: 'relative',
  },
  mapGrid: {
    flex: 1,
    position: 'relative',
  },
  gridLineH: {
    position: 'absolute',
    left: 0,
    right: 0,
    height: 1,
  },
  gridLineV: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    width: 1,
  },
  mockMarker: {
    position: 'absolute',
    width: 28,
    height: 28,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 4,
  },
  userMarker: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    marginTop: -16,
    marginLeft: -16,
    width: 32,
    height: 32,
    borderRadius: 16,
    borderWidth: 3,
    backgroundColor: 'rgba(16, 185, 129, 0.2)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  userMarkerInner: {
    width: 12,
    height: 12,
    borderRadius: 6,
  },
  mapControls: {
    position: 'absolute',
    right: 12,
    bottom: 12,
  },
  controlButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  roleIndicator: {
    position: 'absolute',
    top: 12,
    left: 12,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  locationCard: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderRadius: 16,
    marginBottom: 12,
  },
  locationIcon: {
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: 'center',
    justifyContent: 'center',
  },
  directionsButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
