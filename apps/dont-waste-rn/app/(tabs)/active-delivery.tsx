import { View, Text, ScrollView, TouchableOpacity, Image, Dimensions } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme } from '../../src/contexts';
import { Navigation, Phone, MessageCircle, Package, MapPin, Clock, CheckCircle } from 'lucide-react-native';

const { width } = Dimensions.get('window');

// Mock active delivery
const activeDelivery = {
  id: '1001',
  status: 'picked_up', // 'accepted' | 'picked_up' | 'near_destination'
  order: {
    id: '1001',
    title: 'Organic Vegetables Bundle',
    image: 'https://picsum.photos/seed/veggies/200/200',
    quantity: 2,
    total: 30,
  },
  pickup: {
    name: 'Green Farm',
    address: '123 Farm Road, San Francisco',
    phone: '+1 234 567 8900',
  },
  dropoff: {
    name: 'John D.',
    address: '456 Main Street, Apt 12, San Francisco',
    phone: '+1 234 567 8901',
  },
  fee: 8,
  distance: 2.5,
  estimatedTime: 12,
};

export default function ActiveDeliveryScreen() {
  const { colors } = useTheme();

  if (!activeDelivery) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', padding: 32 }}>
          <Text style={{ fontSize: 64, marginBottom: 16 }}>🚗</Text>
          <Text style={{ color: colors.text.primary, fontSize: 20, fontWeight: '600', textAlign: 'center' }}>
            No Active Delivery
          </Text>
          <Text style={{ color: colors.text.tertiary, marginTop: 8, textAlign: 'center' }}>
            Accept a delivery request from the Available tab to start earning
          </Text>
        </View>
      </SafeAreaView>
    );
  }

  const steps = [
    { key: 'accepted', label: 'Accepted', completed: true },
    { key: 'picked_up', label: 'Picked Up', completed: activeDelivery.status !== 'accepted' },
    { key: 'delivered', label: 'Delivered', completed: false },
  ];

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
      <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={{ paddingHorizontal: 16, paddingTop: 16 }}>
          <Text style={{ color: colors.text.primary, fontSize: 28, fontWeight: '700' }}>
            Active Delivery
          </Text>
          <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>
            Order #{activeDelivery.order.id}
          </Text>
        </View>

        {/* Progress Steps */}
        <View
          style={{
            flexDirection: 'row',
            paddingHorizontal: 16,
            marginTop: 24,
            alignItems: 'center',
          }}
        >
          {steps.map((step, index) => (
            <View key={step.key} style={{ flex: 1, flexDirection: 'row', alignItems: 'center' }}>
              <View
                style={{
                  width: 28,
                  height: 28,
                  borderRadius: 14,
                  backgroundColor: step.completed ? colors.status.success : colors.surface.primary,
                  borderWidth: step.completed ? 0 : 2,
                  borderColor: colors.border.default,
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                {step.completed ? (
                  <CheckCircle size={16} color="#FFFFFF" />
                ) : (
                  <Text style={{ color: colors.text.tertiary, fontSize: 12, fontWeight: '600' }}>
                    {index + 1}
                  </Text>
                )}
              </View>
              <Text
                style={{
                  color: step.completed ? colors.status.success : colors.text.tertiary,
                  fontSize: 12,
                  marginLeft: 8,
                  fontWeight: step.completed ? '600' : '400',
                }}
              >
                {step.label}
              </Text>
              {index < steps.length - 1 && (
                <View
                  style={{
                    flex: 1,
                    height: 2,
                    backgroundColor: step.completed ? colors.status.success : colors.border.default,
                    marginHorizontal: 8,
                  }}
                />
              )}
            </View>
          ))}
        </View>

        {/* Order Info */}
        <View
          style={{
            marginHorizontal: 16,
            marginTop: 24,
            backgroundColor: colors.surface.primary,
            borderRadius: 16,
            padding: 16,
            borderWidth: 1,
            borderColor: colors.border.default,
          }}
        >
          <View style={{ flexDirection: 'row' }}>
            <Image
              source={{ uri: activeDelivery.order.image }}
              style={{ width: 60, height: 60, borderRadius: 12 }}
            />
            <View style={{ flex: 1, marginLeft: 12 }}>
              <Text style={{ color: colors.text.primary, fontSize: 16, fontWeight: '500' }}>
                {activeDelivery.order.title}
              </Text>
              <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>
                Qty: {activeDelivery.order.quantity}
              </Text>
            </View>
            <Text style={{ color: colors.brand.primary, fontSize: 18, fontWeight: '700' }}>
              ${activeDelivery.fee}
            </Text>
          </View>
        </View>

        {/* Pickup Location */}
        <View style={{ paddingHorizontal: 16, marginTop: 24 }}>
          <Text style={{ color: colors.text.tertiary, fontSize: 12, fontWeight: '600', marginBottom: 12 }}>
            PICKUP FROM
          </Text>
          <View
            style={{
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              padding: 16,
              borderWidth: 1,
              borderColor:
                activeDelivery.status === 'accepted' ? colors.brand.primary : colors.border.default,
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'flex-start' }}>
              <View
                style={{
                  width: 40,
                  height: 40,
                  borderRadius: 20,
                  backgroundColor: colors.brand.primaryLight + '30',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <Package size={20} color={colors.brand.primary} />
              </View>
              <View style={{ flex: 1, marginLeft: 12 }}>
                <Text style={{ color: colors.text.primary, fontSize: 16, fontWeight: '600' }}>
                  {activeDelivery.pickup.name}
                </Text>
                <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>
                  {activeDelivery.pickup.address}
                </Text>
              </View>
            </View>
            <View style={{ flexDirection: 'row', marginTop: 16, gap: 12 }}>
              <TouchableOpacity
                style={{
                  flex: 1,
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'center',
                  backgroundColor: colors.surface.secondary,
                  paddingVertical: 12,
                  borderRadius: 10,
                }}
              >
                <Phone size={18} color={colors.text.secondary} />
                <Text style={{ color: colors.text.secondary, marginLeft: 8, fontWeight: '500' }}>
                  Call
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={{
                  flex: 1,
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'center',
                  backgroundColor: colors.brand.primary,
                  paddingVertical: 12,
                  borderRadius: 10,
                }}
              >
                <Navigation size={18} color="#FFFFFF" />
                <Text style={{ color: '#FFFFFF', marginLeft: 8, fontWeight: '500' }}>Navigate</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>

        {/* Dropoff Location */}
        <View style={{ paddingHorizontal: 16, marginTop: 24 }}>
          <Text style={{ color: colors.text.tertiary, fontSize: 12, fontWeight: '600', marginBottom: 12 }}>
            DELIVER TO
          </Text>
          <View
            style={{
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              padding: 16,
              borderWidth: 1,
              borderColor:
                activeDelivery.status === 'picked_up' ? colors.status.error : colors.border.default,
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'flex-start' }}>
              <View
                style={{
                  width: 40,
                  height: 40,
                  borderRadius: 20,
                  backgroundColor: colors.status.errorLight,
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <MapPin size={20} color={colors.status.error} />
              </View>
              <View style={{ flex: 1, marginLeft: 12 }}>
                <Text style={{ color: colors.text.primary, fontSize: 16, fontWeight: '600' }}>
                  {activeDelivery.dropoff.name}
                </Text>
                <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>
                  {activeDelivery.dropoff.address}
                </Text>
              </View>
            </View>
            <View style={{ flexDirection: 'row', marginTop: 16, gap: 12 }}>
              <TouchableOpacity
                style={{
                  flex: 1,
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'center',
                  backgroundColor: colors.surface.secondary,
                  paddingVertical: 12,
                  borderRadius: 10,
                }}
              >
                <Phone size={18} color={colors.text.secondary} />
                <Text style={{ color: colors.text.secondary, marginLeft: 8, fontWeight: '500' }}>
                  Call
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={{
                  flex: 1,
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'center',
                  backgroundColor: colors.surface.secondary,
                  paddingVertical: 12,
                  borderRadius: 10,
                }}
              >
                <MessageCircle size={18} color={colors.text.secondary} />
                <Text style={{ color: colors.text.secondary, marginLeft: 8, fontWeight: '500' }}>
                  Message
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>

        {/* Stats */}
        <View style={{ flexDirection: 'row', paddingHorizontal: 16, marginTop: 24, gap: 12 }}>
          <View
            style={{
              flex: 1,
              backgroundColor: colors.surface.primary,
              borderRadius: 12,
              padding: 16,
              alignItems: 'center',
              borderWidth: 1,
              borderColor: colors.border.default,
            }}
          >
            <Text style={{ color: colors.text.tertiary, fontSize: 12 }}>Distance</Text>
            <Text style={{ color: colors.text.primary, fontSize: 20, fontWeight: '700', marginTop: 4 }}>
              {activeDelivery.distance} km
            </Text>
          </View>
          <View
            style={{
              flex: 1,
              backgroundColor: colors.surface.primary,
              borderRadius: 12,
              padding: 16,
              alignItems: 'center',
              borderWidth: 1,
              borderColor: colors.border.default,
            }}
          >
            <Text style={{ color: colors.text.tertiary, fontSize: 12 }}>ETA</Text>
            <Text style={{ color: colors.text.primary, fontSize: 20, fontWeight: '700', marginTop: 4 }}>
              {activeDelivery.estimatedTime} min
            </Text>
          </View>
          <View
            style={{
              flex: 1,
              backgroundColor: colors.surface.primary,
              borderRadius: 12,
              padding: 16,
              alignItems: 'center',
              borderWidth: 1,
              borderColor: colors.border.default,
            }}
          >
            <Text style={{ color: colors.text.tertiary, fontSize: 12 }}>Earnings</Text>
            <Text style={{ color: colors.brand.primary, fontSize: 20, fontWeight: '700', marginTop: 4 }}>
              ${activeDelivery.fee}
            </Text>
          </View>
        </View>

        {/* Bottom spacing */}
        <View style={{ height: 120 }} />
      </ScrollView>

      {/* Action Button */}
      <View
        style={{
          position: 'absolute',
          bottom: 0,
          left: 0,
          right: 0,
          padding: 16,
          paddingBottom: 32,
          backgroundColor: colors.background.primary,
          borderTopWidth: 1,
          borderTopColor: colors.border.default,
        }}
      >
        <TouchableOpacity
          style={{
            backgroundColor:
              activeDelivery.status === 'accepted' ? colors.brand.primary : colors.status.success,
            paddingVertical: 16,
            borderRadius: 12,
            alignItems: 'center',
          }}
        >
          <Text style={{ color: '#FFFFFF', fontSize: 16, fontWeight: '600' }}>
            {activeDelivery.status === 'accepted'
              ? 'Confirm Pickup'
              : activeDelivery.status === 'picked_up'
              ? 'Complete Delivery'
              : 'Mark as Delivered'}
          </Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}
