import { View, Text, TouchableOpacity, StyleSheet, Dimensions, Image } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme, useAuth } from '../../src/contexts';
import { MapPin, Navigation, Search, Layers, Plus, Minus, Compass, X, Star, Clock } from 'lucide-react-native';
import Mapbox, { Camera, MapView, PointAnnotation, UserLocation, MarkerView } from '@rnmapbox/maps';
import { useState, useRef, useEffect } from 'react';

// Mapbox public access token
const MAPBOX_ACCESS_TOKEN = 'pk.eyJ1Ijoic2FydmFyYmVrc29wb3Jib3lldjgiLCJhIjoiY205MHRlcjZyMDFhMjJqcHZ3NXVwdHdtYyJ9.BXAR2LSQP0Ey8V0djFdXjA';

Mapbox.setAccessToken(MAPBOX_ACCESS_TOKEN);

const { width, height } = Dimensions.get('window');

// Default camera settings for cinematic 3D view
const DEFAULT_CENTER: [number, number] = [-122.4194, 37.7749]; // San Francisco
const DEFAULT_ZOOM = 14;
const DEFAULT_PITCH = 45;
const DEFAULT_BEARING = -17.6;

// Mock listings data
const mockListings = [
  {
    id: '1',
    title: 'Organic Vegetables Bundle',
    price: 15,
    originalPrice: 30,
    image: 'https://picsum.photos/seed/veggies/200/200',
    seller: { name: 'Green Farm', rating: 4.7 },
    category: 'food',
    coordinates: [-122.4094, 37.7849] as [number, number],
    expiresIn: '3 hours',
    distance: 0.8,
  },
  {
    id: '2',
    title: 'iPhone 13 Pro - Like New',
    price: 699,
    originalPrice: 999,
    image: 'https://picsum.photos/seed/iphone/200/200',
    seller: { name: 'Tech Store', rating: 4.9 },
    category: 'electronics',
    coordinates: [-122.4014, 37.7899] as [number, number],
    distance: 1.2,
  },
  {
    id: '3',
    title: 'Vintage Leather Jacket',
    price: 89,
    originalPrice: 150,
    image: 'https://picsum.photos/seed/jacket/200/200',
    seller: { name: 'Fashion Hub', rating: 4.5 },
    category: 'clothing',
    coordinates: [-122.4194, 37.7799] as [number, number],
    distance: 2.5,
  },
  {
    id: '4',
    title: 'IKEA Desk - Great Condition',
    price: 45,
    originalPrice: 120,
    image: 'https://picsum.photos/seed/desk/200/200',
    seller: { name: 'Home Goods', rating: 4.8 },
    category: 'furniture',
    coordinates: [-122.4294, 37.7749] as [number, number],
    distance: 3.1,
  },
  {
    id: '5',
    title: 'Fresh Bakery Items',
    price: 8,
    originalPrice: 20,
    image: 'https://picsum.photos/seed/bakery/200/200',
    seller: { name: 'Local Bakery', rating: 4.9 },
    category: 'food',
    coordinates: [-122.4144, 37.7819] as [number, number],
    expiresIn: '1 hour',
    distance: 0.5,
  },
];

// Delivery route mock data
const deliveryRoute = {
  pickup: {
    id: 'pickup',
    name: 'Green Farm',
    address: '123 Farm Road',
    coordinates: [-122.4094, 37.7849] as [number, number],
  },
  dropoff: {
    id: 'dropoff',
    name: 'John D.',
    address: '456 Main St, Apt 12',
    coordinates: [-122.4194, 37.7699] as [number, number],
  },
};

type Listing = typeof mockListings[0];

export default function MapScreen() {
  const { colors, isDark } = useTheme();
  const { user } = useAuth();
  const role = user?.role || 'buyer';
  
  const cameraRef = useRef<Camera>(null);
  const [selectedListing, setSelectedListing] = useState<Listing | null>(null);
  const [mapReady, setMapReady] = useState(false);

  const mapStyle = isDark ? Mapbox.StyleURL.Dark : Mapbox.StyleURL.Light;

  const getCategoryColor = (category: string) => {
    switch (category) {
      case 'food':
        return colors.category.food;
      case 'electronics':
        return colors.category.electronics;
      case 'clothing':
        return '#EC4899';
      case 'furniture':
        return colors.category.furniture;
      default:
        return colors.brand.primary;
    }
  };

  const handleMarkerPress = (listing: Listing) => {
    setSelectedListing(listing);
    cameraRef.current?.setCamera({
      centerCoordinate: listing.coordinates,
      zoomLevel: 16,
      pitch: 50,
      animationDuration: 1000,
    });
  };

  const handleMapPress = () => {
    setSelectedListing(null);
  };

  const zoomIn = () => {
    cameraRef.current?.zoomTo(DEFAULT_ZOOM + 2, 300);
  };

  const zoomOut = () => {
    cameraRef.current?.zoomTo(DEFAULT_ZOOM - 2, 300);
  };

  const centerOnUser = () => {
    cameraRef.current?.setCamera({
      centerCoordinate: DEFAULT_CENTER,
      zoomLevel: DEFAULT_ZOOM,
      pitch: DEFAULT_PITCH,
      bearing: DEFAULT_BEARING,
      animationDuration: 1000,
    });
  };

  const resetNorth = () => {
    cameraRef.current?.setCamera({
      bearing: 0,
      animationDuration: 500,
    });
  };

  return (
    <View style={{ flex: 1, backgroundColor: colors.background.primary }}>
      {/* Mapbox Map */}
      <MapView
        style={styles.map}
        styleURL={mapStyle}
        logoEnabled={false}
        attributionEnabled={false}
        compassEnabled={false}
        scaleBarEnabled={false}
        onPress={handleMapPress}
        onDidFinishLoadingMap={() => setMapReady(true)}
      >
        <Camera
          ref={cameraRef}
          defaultSettings={{
            centerCoordinate: DEFAULT_CENTER,
            zoomLevel: DEFAULT_ZOOM,
            pitch: DEFAULT_PITCH,
            bearing: DEFAULT_BEARING,
          }}
          animationDuration={2000}
        />

        {/* User Location */}
        <UserLocation
          visible={true}
          showsUserHeadingIndicator={true}
          puckBearing="heading"
          puckBearingEnabled={true}
        />

        {/* Listing Markers - Buyer View */}
        {role === 'buyer' && mockListings.map((listing) => (
          <MarkerView
            key={listing.id}
            coordinate={listing.coordinates}
            allowOverlap={true}
          >
            <TouchableOpacity
              onPress={() => handleMarkerPress(listing)}
              style={[
                styles.marker,
                {
                  backgroundColor: getCategoryColor(listing.category),
                  borderColor: selectedListing?.id === listing.id ? '#FFFFFF' : 'transparent',
                  borderWidth: selectedListing?.id === listing.id ? 3 : 0,
                  transform: [{ scale: selectedListing?.id === listing.id ? 1.2 : 1 }],
                },
              ]}
            >
              <Text style={styles.markerPrice}>${listing.price}</Text>
            </TouchableOpacity>
          </MarkerView>
        ))}

        {/* Delivery Markers */}
        {role === 'delivery' && (
          <>
            <MarkerView
              key="pickup"
              coordinate={deliveryRoute.pickup.coordinates}
              allowOverlap={true}
            >
              <View style={[styles.deliveryMarker, { backgroundColor: colors.brand.primary }]}>
                <Text style={styles.deliveryMarkerText}>P</Text>
              </View>
            </MarkerView>
            <MarkerView
              key="dropoff"
              coordinate={deliveryRoute.dropoff.coordinates}
              allowOverlap={true}
            >
              <View style={[styles.deliveryMarker, { backgroundColor: colors.status.error }]}>
                <Text style={styles.deliveryMarkerText}>D</Text>
              </View>
            </MarkerView>
          </>
        )}
      </MapView>

      {/* Search Bar Overlay */}
      <SafeAreaView style={styles.searchOverlay}>
        <TouchableOpacity
          style={[
            styles.searchBar,
            {
              backgroundColor: isDark ? 'rgba(26, 26, 27, 0.9)' : 'rgba(255, 255, 255, 0.9)',
              borderColor: colors.border.default,
            },
          ]}
        >
          <Search size={20} color={colors.text.tertiary} />
          <Text style={[styles.searchText, { color: colors.text.tertiary }]}>
            Search nearby listings...
          </Text>
        </TouchableOpacity>
      </SafeAreaView>

      {/* Right Controls */}
      <View style={[styles.rightControls, { top: 140 }]}>
        <TouchableOpacity
          style={[styles.controlButton, { backgroundColor: colors.surface.primary }]}
          onPress={zoomIn}
        >
          <Plus size={20} color={colors.text.secondary} />
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.controlButton, { backgroundColor: colors.surface.primary }]}
          onPress={zoomOut}
        >
          <Minus size={20} color={colors.text.secondary} />
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.controlButton, { backgroundColor: colors.surface.primary }]}
        >
          <Layers size={20} color={colors.text.secondary} />
        </TouchableOpacity>
      </View>

      {/* Bottom Left - Compass */}
      <TouchableOpacity
        style={[
          styles.compassButton,
          {
            backgroundColor: colors.surface.primary,
            bottom: selectedListing ? 220 : 100,
          },
        ]}
        onPress={resetNorth}
      >
        <Compass size={22} color={colors.text.secondary} />
      </TouchableOpacity>

      {/* Bottom Right - Location */}
      <TouchableOpacity
        style={[
          styles.locationButton,
          {
            backgroundColor: colors.brand.primary,
            bottom: selectedListing ? 220 : 100,
          },
        ]}
        onPress={centerOnUser}
      >
        <Navigation size={22} color="#FFFFFF" />
      </TouchableOpacity>

      {/* Role Indicator */}
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
          {role === 'seller' ? 'Seller View' : role === 'delivery' ? 'Delivery View' : 'Nearby Deals'}
        </Text>
      </View>

      {/* Selected Listing Card */}
      {selectedListing && (
        <View
          style={[
            styles.listingCard,
            {
              backgroundColor: colors.surface.primary,
              borderColor: colors.border.default,
            },
          ]}
        >
          {/* Close button */}
          <TouchableOpacity
            style={[styles.closeButton, { backgroundColor: colors.surface.secondary }]}
            onPress={() => setSelectedListing(null)}
          >
            <X size={16} color={colors.text.secondary} />
          </TouchableOpacity>

          <View style={styles.cardContent}>
            <Image
              source={{ uri: selectedListing.image }}
              style={styles.cardImage}
            />
            <View style={styles.cardInfo}>
              <Text style={[styles.cardTitle, { color: colors.text.primary }]} numberOfLines={2}>
                {selectedListing.title}
              </Text>
              <View style={styles.cardMeta}>
                <Star size={12} color="#F59E0B" fill="#F59E0B" />
                <Text style={[styles.cardMetaText, { color: colors.text.tertiary }]}>
                  {selectedListing.seller.rating} • {selectedListing.seller.name}
                </Text>
              </View>
              <View style={styles.cardMeta}>
                <MapPin size={12} color={colors.text.muted} />
                <Text style={[styles.cardMetaText, { color: colors.text.muted }]}>
                  {selectedListing.distance} km away
                </Text>
                {selectedListing.expiresIn && (
                  <>
                    <Clock size={12} color={colors.status.warning} style={{ marginLeft: 8 }} />
                    <Text style={[styles.cardMetaText, { color: colors.status.warning }]}>
                      {selectedListing.expiresIn}
                    </Text>
                  </>
                )}
              </View>
              <View style={styles.cardPriceRow}>
                <Text style={[styles.cardPrice, { color: colors.brand.primary }]}>
                  ${selectedListing.price}
                </Text>
                {selectedListing.originalPrice && (
                  <Text style={[styles.cardOriginalPrice, { color: colors.text.muted }]}>
                    ${selectedListing.originalPrice}
                  </Text>
                )}
              </View>
            </View>
          </View>

          <View style={styles.cardActions}>
            <TouchableOpacity
              style={[styles.cardButton, { backgroundColor: colors.surface.secondary }]}
            >
              <Navigation size={16} color={colors.text.secondary} />
              <Text style={[styles.cardButtonText, { color: colors.text.secondary }]}>
                Directions
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.cardButton, { backgroundColor: colors.brand.primary, flex: 2 }]}
            >
              <Text style={[styles.cardButtonText, { color: '#FFFFFF' }]}>View Details</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  map: {
    flex: 1,
  },
  searchOverlay: {
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
    borderRadius: 16,
    borderWidth: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    elevation: 8,
  },
  searchText: {
    marginLeft: 12,
    fontSize: 16,
  },
  rightControls: {
    position: 'absolute',
    right: 16,
    gap: 8,
  },
  controlButton: {
    width: 44,
    height: 44,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 4,
  },
  compassButton: {
    position: 'absolute',
    left: 16,
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 4,
  },
  locationButton: {
    position: 'absolute',
    right: 16,
    width: 52,
    height: 52,
    borderRadius: 26,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 8,
  },
  roleIndicator: {
    position: 'absolute',
    top: 100,
    left: 16,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  marker: {
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 6,
  },
  markerPrice: {
    color: '#FFFFFF',
    fontWeight: '700',
    fontSize: 13,
  },
  deliveryMarker: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 3,
    borderColor: '#FFFFFF',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 6,
  },
  deliveryMarkerText: {
    color: '#FFFFFF',
    fontWeight: '700',
    fontSize: 14,
  },
  listingCard: {
    position: 'absolute',
    bottom: 24,
    left: 16,
    right: 16,
    borderRadius: 20,
    borderWidth: 1,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -4 },
    shadowOpacity: 0.15,
    shadowRadius: 16,
    elevation: 12,
  },
  closeButton: {
    position: 'absolute',
    top: 12,
    right: 12,
    width: 28,
    height: 28,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 1,
  },
  cardContent: {
    flexDirection: 'row',
  },
  cardImage: {
    width: 80,
    height: 80,
    borderRadius: 12,
  },
  cardInfo: {
    flex: 1,
    marginLeft: 12,
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  cardMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  cardMetaText: {
    fontSize: 12,
    marginLeft: 4,
  },
  cardPriceRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 8,
  },
  cardPrice: {
    fontSize: 20,
    fontWeight: '700',
  },
  cardOriginalPrice: {
    fontSize: 14,
    marginLeft: 8,
    textDecorationLine: 'line-through',
  },
  cardActions: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 16,
  },
  cardButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    borderRadius: 12,
    gap: 6,
  },
  cardButtonText: {
    fontWeight: '600',
    fontSize: 14,
  },
});
