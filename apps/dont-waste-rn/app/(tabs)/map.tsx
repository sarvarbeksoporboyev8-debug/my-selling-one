import { View, Text, TouchableOpacity, StyleSheet, Dimensions } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme, useAuth } from '../../src/contexts';
import { MapPin, Navigation, Layers, Search } from 'lucide-react-native';
import MapboxGL from '@rnmapbox/maps';
import { useEffect, useState } from 'react';

// Mapbox access token
const MAPBOX_TOKEN = 'pk.eyJ1Ijoic2FydmFyYmVrc29wb3Jib3lldjgiLCJhIjoiY205MHRlcjZyMDFhMjJqcHZ3NXVwdHdtYyJ9.BXAR2LSQP0Ey8V0djFdXjA';

MapboxGL.setAccessToken(MAPBOX_TOKEN);

const { width, height } = Dimensions.get('window');

// Mock markers for different roles
const buyerMarkers = [
  { id: '1', lat: 37.7849, lng: -122.4094, title: 'Green Farm', type: 'food', price: 15 },
  { id: '2', lat: 37.7899, lng: -122.4014, title: 'Tech Store', type: 'electronics', price: 699 },
  { id: '3', lat: 37.7799, lng: -122.4194, title: 'Fashion Hub', type: 'clothing', price: 89 },
  { id: '4', lat: 37.7749, lng: -122.4294, title: 'Home Goods', type: 'furniture', price: 45 },
];

const deliveryMarkers = [
  { id: '1', lat: 37.7849, lng: -122.4094, title: 'Pickup: Green Farm', type: 'pickup' },
  { id: '2', lat: 37.7749, lng: -122.4194, title: 'Dropoff: 123 Main St', type: 'dropoff' },
];

export default function MapScreen() {
  const { colors, isDark } = useTheme();
  const { user } = useAuth();
  const role = user?.role || 'buyer';
  const [selectedMarker, setSelectedMarker] = useState<string | null>(null);

  const markers = role === 'delivery' ? deliveryMarkers : buyerMarkers;
  const mapStyle = isDark ? 'mapbox://styles/mapbox/dark-v11' : 'mapbox://styles/mapbox/light-v11';

  const getMarkerColor = (type: string) => {
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
      default:
        return colors.brand.primary;
    }
  };

  return (
    <View style={{ flex: 1, backgroundColor: colors.background.primary }}>
      {/* Map */}
      <MapboxGL.MapView
        style={styles.map}
        styleURL={mapStyle}
        logoEnabled={false}
        attributionEnabled={false}
      >
        <MapboxGL.Camera
          zoomLevel={13}
          centerCoordinate={[-122.4094, 37.7849]}
          animationMode="flyTo"
          animationDuration={2000}
        />

        {/* User Location */}
        <MapboxGL.UserLocation visible={true} />

        {/* Markers */}
        {markers.map((marker) => (
          <MapboxGL.PointAnnotation
            key={marker.id}
            id={marker.id}
            coordinate={[marker.lng, marker.lat]}
            onSelected={() => setSelectedMarker(marker.id)}
          >
            <View
              style={[
                styles.marker,
                {
                  backgroundColor: getMarkerColor(marker.type),
                  borderColor: colors.background.primary,
                },
              ]}
            >
              <MapPin size={16} color="#FFFFFF" />
            </View>
            <MapboxGL.Callout title={marker.title} />
          </MapboxGL.PointAnnotation>
        ))}
      </MapboxGL.MapView>

      {/* Search Overlay */}
      <SafeAreaView style={styles.overlay}>
        <TouchableOpacity
          style={[
            styles.searchBar,
            {
              backgroundColor: colors.surface.primary,
              borderColor: colors.border.default,
            },
          ]}
        >
          <Search size={20} color={colors.text.tertiary} />
          <Text style={[styles.searchText, { color: colors.text.tertiary }]}>
            Search on map...
          </Text>
        </TouchableOpacity>
      </SafeAreaView>

      {/* Map Controls */}
      <View style={[styles.controls, { bottom: 120 }]}>
        <TouchableOpacity
          style={[
            styles.controlButton,
            {
              backgroundColor: colors.surface.primary,
              borderColor: colors.border.default,
            },
          ]}
        >
          <Layers size={20} color={colors.text.secondary} />
        </TouchableOpacity>
        <TouchableOpacity
          style={[
            styles.controlButton,
            {
              backgroundColor: colors.brand.primary,
              borderColor: colors.brand.primary,
            },
          ]}
        >
          <Navigation size={20} color="#FFFFFF" />
        </TouchableOpacity>
      </View>

      {/* Bottom Card */}
      {selectedMarker && (
        <View
          style={[
            styles.bottomCard,
            {
              backgroundColor: colors.surface.primary,
              borderColor: colors.border.default,
            },
          ]}
        >
          <View style={styles.cardHandle}>
            <View style={[styles.handle, { backgroundColor: colors.border.default }]} />
          </View>
          <View style={styles.cardContent}>
            <Text style={[styles.cardTitle, { color: colors.text.primary }]}>
              {markers.find((m) => m.id === selectedMarker)?.title}
            </Text>
            <Text style={[styles.cardSubtitle, { color: colors.text.tertiary }]}>
              0.5 km away • Open until 8 PM
            </Text>
            <View style={styles.cardActions}>
              <TouchableOpacity
                style={[styles.cardButton, { backgroundColor: colors.brand.primary }]}
              >
                <Text style={styles.cardButtonText}>View Details</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[
                  styles.cardButton,
                  {
                    backgroundColor: 'transparent',
                    borderWidth: 1,
                    borderColor: colors.border.default,
                  },
                ]}
              >
                <Text style={[styles.cardButtonText, { color: colors.text.primary }]}>
                  Directions
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      )}

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
  );
}

const styles = StyleSheet.create({
  map: {
    flex: 1,
  },
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    paddingHorizontal: 16,
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderRadius: 12,
    borderWidth: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  searchText: {
    marginLeft: 12,
    fontSize: 16,
  },
  controls: {
    position: 'absolute',
    right: 16,
    gap: 12,
  },
  controlButton: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  marker: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 4,
  },
  bottomCard: {
    position: 'absolute',
    bottom: 100,
    left: 16,
    right: 16,
    borderRadius: 20,
    borderWidth: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -4 },
    shadowOpacity: 0.1,
    shadowRadius: 12,
    elevation: 8,
  },
  cardHandle: {
    alignItems: 'center',
    paddingVertical: 12,
  },
  handle: {
    width: 40,
    height: 4,
    borderRadius: 2,
  },
  cardContent: {
    paddingHorizontal: 20,
    paddingBottom: 20,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  cardSubtitle: {
    fontSize: 14,
    marginTop: 4,
  },
  cardActions: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 16,
  },
  cardButton: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 10,
    alignItems: 'center',
  },
  cardButtonText: {
    color: '#FFFFFF',
    fontWeight: '600',
  },
  roleIndicator: {
    position: 'absolute',
    top: 100,
    left: 16,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
});
