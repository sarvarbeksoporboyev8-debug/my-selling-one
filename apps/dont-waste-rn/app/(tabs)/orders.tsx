import { View, Text, ScrollView, TouchableOpacity, Image } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme } from '../../src/contexts';
import { Package, Truck, CheckCircle, XCircle, Clock, MapPin, ChevronRight } from 'lucide-react-native';
import { useState } from 'react';

type OrderTab = 'active' | 'completed' | 'cancelled';

const mockOrders = {
  active: [
    {
      id: '1001',
      title: 'Organic Vegetables Bundle',
      image: 'https://picsum.photos/seed/veggies/200/200',
      seller: 'Green Farm',
      status: 'in_delivery',
      statusText: 'Out for delivery',
      total: 23,
      deliveryPerson: { name: 'Mike D.', eta: '15 min' },
    },
    {
      id: '1002',
      title: 'iPhone 13 Pro - Like New',
      image: 'https://picsum.photos/seed/iphone/200/200',
      seller: 'Tech Store',
      status: 'ready_for_pickup',
      statusText: 'Ready for pickup',
      total: 699,
      pickupTime: '2-4 PM today',
    },
  ],
  completed: [
    {
      id: '1003',
      title: 'Vintage Leather Jacket',
      image: 'https://picsum.photos/seed/jacket/200/200',
      seller: 'Fashion Hub',
      status: 'completed',
      statusText: 'Delivered',
      total: 89,
      completedAt: 'Jan 15, 2024',
    },
    {
      id: '1004',
      title: 'IKEA Desk',
      image: 'https://picsum.photos/seed/desk/200/200',
      seller: 'Home Goods',
      status: 'completed',
      statusText: 'Picked up',
      total: 45,
      completedAt: 'Jan 12, 2024',
    },
  ],
  cancelled: [
    {
      id: '1005',
      title: 'Gaming Console',
      image: 'https://picsum.photos/seed/gaming/200/200',
      seller: 'Game Zone',
      status: 'cancelled',
      statusText: 'Cancelled by seller',
      total: 350,
      cancelledAt: 'Jan 10, 2024',
    },
  ],
};

const getStatusIcon = (status: string, colors: any) => {
  switch (status) {
    case 'in_delivery':
      return <Truck size={16} color={colors.status.info} />;
    case 'ready_for_pickup':
      return <Package size={16} color={colors.role.seller} />;
    case 'completed':
      return <CheckCircle size={16} color={colors.status.success} />;
    case 'cancelled':
      return <XCircle size={16} color={colors.status.error} />;
    default:
      return <Clock size={16} color={colors.status.warning} />;
  }
};

const getStatusColor = (status: string, colors: any) => {
  switch (status) {
    case 'in_delivery':
      return { bg: colors.status.infoLight, text: colors.status.info };
    case 'ready_for_pickup':
      return { bg: colors.role.sellerLight, text: colors.role.seller };
    case 'completed':
      return { bg: colors.status.successLight, text: colors.status.success };
    case 'cancelled':
      return { bg: colors.status.errorLight, text: colors.status.error };
    default:
      return { bg: colors.status.warningLight, text: colors.status.warning };
  }
};

export default function OrdersScreen() {
  const { colors } = useTheme();
  const [activeTab, setActiveTab] = useState<OrderTab>('active');

  const tabs: { key: OrderTab; label: string; count: number }[] = [
    { key: 'active', label: 'Active', count: mockOrders.active.length },
    { key: 'completed', label: 'Completed', count: mockOrders.completed.length },
    { key: 'cancelled', label: 'Cancelled', count: mockOrders.cancelled.length },
  ];

  const orders = mockOrders[activeTab];

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
      {/* Header */}
      <View style={{ paddingHorizontal: 16, paddingTop: 16 }}>
        <Text style={{ color: colors.text.primary, fontSize: 28, fontWeight: '700' }}>Orders</Text>
        <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>Track your purchases</Text>
      </View>

      {/* Tabs */}
      <View
        style={{
          flexDirection: 'row',
          paddingHorizontal: 16,
          marginTop: 20,
          gap: 8,
        }}
      >
        {tabs.map((tab) => (
          <TouchableOpacity
            key={tab.key}
            onPress={() => setActiveTab(tab.key)}
            style={{
              flex: 1,
              paddingVertical: 12,
              borderRadius: 12,
              backgroundColor: activeTab === tab.key ? colors.brand.primary : colors.surface.primary,
              borderWidth: activeTab === tab.key ? 0 : 1,
              borderColor: colors.border.default,
              alignItems: 'center',
            }}
          >
            <Text
              style={{
                color: activeTab === tab.key ? '#FFFFFF' : colors.text.secondary,
                fontWeight: '600',
              }}
            >
              {tab.label} ({tab.count})
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Orders List */}
      <ScrollView
        style={{ flex: 1, marginTop: 16 }}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 100 }}
        showsVerticalScrollIndicator={false}
      >
        {orders.length === 0 ? (
          <View style={{ alignItems: 'center', paddingTop: 60 }}>
            <Text style={{ fontSize: 48, marginBottom: 16 }}>📦</Text>
            <Text style={{ color: colors.text.primary, fontSize: 18, fontWeight: '600' }}>
              No {activeTab} orders
            </Text>
            <Text style={{ color: colors.text.tertiary, marginTop: 8, textAlign: 'center' }}>
              {activeTab === 'active'
                ? 'Start shopping to see your orders here'
                : `Your ${activeTab} orders will appear here`}
            </Text>
          </View>
        ) : (
          orders.map((order) => {
            const statusColors = getStatusColor(order.status, colors);
            return (
              <TouchableOpacity
                key={order.id}
                style={{
                  backgroundColor: colors.surface.primary,
                  borderRadius: 16,
                  marginBottom: 12,
                  borderWidth: 1,
                  borderColor: colors.border.default,
                  overflow: 'hidden',
                }}
              >
                <View style={{ flexDirection: 'row', padding: 16 }}>
                  <Image
                    source={{ uri: order.image }}
                    style={{ width: 80, height: 80, borderRadius: 12 }}
                  />
                  <View style={{ flex: 1, marginLeft: 12 }}>
                    <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
                      <Text style={{ color: colors.text.tertiary, fontSize: 12 }}>
                        Order #{order.id}
                      </Text>
                      <View
                        style={{
                          flexDirection: 'row',
                          alignItems: 'center',
                          backgroundColor: statusColors.bg,
                          paddingHorizontal: 8,
                          paddingVertical: 4,
                          borderRadius: 8,
                        }}
                      >
                        {getStatusIcon(order.status, colors)}
                        <Text
                          style={{
                            color: statusColors.text,
                            fontSize: 11,
                            fontWeight: '500',
                            marginLeft: 4,
                          }}
                        >
                          {order.statusText}
                        </Text>
                      </View>
                    </View>
                    <Text
                      style={{ color: colors.text.primary, fontSize: 16, fontWeight: '500', marginTop: 4 }}
                      numberOfLines={1}
                    >
                      {order.title}
                    </Text>
                    <Text style={{ color: colors.text.tertiary, fontSize: 13, marginTop: 2 }}>
                      {order.seller}
                    </Text>
                    <Text style={{ color: colors.brand.primary, fontSize: 16, fontWeight: '700', marginTop: 8 }}>
                      ${order.total}
                    </Text>
                  </View>
                </View>

                {/* Action bar for active orders */}
                {order.status === 'in_delivery' && 'deliveryPerson' in order && order.deliveryPerson && (
                  <View
                    style={{
                      flexDirection: 'row',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      paddingHorizontal: 16,
                      paddingVertical: 12,
                      backgroundColor: colors.status.infoLight,
                      borderTopWidth: 1,
                      borderTopColor: colors.border.subtle,
                    }}
                  >
                    <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                      <Truck size={16} color={colors.status.info} />
                      <Text style={{ color: colors.status.info, marginLeft: 8, fontWeight: '500' }}>
                        {(order as any).deliveryPerson.name} • ETA {(order as any).deliveryPerson.eta}
                      </Text>
                    </View>
                    <TouchableOpacity>
                      <Text style={{ color: colors.status.info, fontWeight: '600' }}>Track</Text>
                    </TouchableOpacity>
                  </View>
                )}

                {'pickupTime' in order && order.status === 'ready_for_pickup' && order.pickupTime && (
                  <View
                    style={{
                      flexDirection: 'row',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      paddingHorizontal: 16,
                      paddingVertical: 12,
                      backgroundColor: colors.role.sellerLight,
                      borderTopWidth: 1,
                      borderTopColor: colors.border.subtle,
                    }}
                  >
                    <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                      <MapPin size={16} color={colors.role.seller} />
                      <Text style={{ color: colors.role.seller, marginLeft: 8, fontWeight: '500' }}>
                        Pickup: {(order as any).pickupTime}
                      </Text>
                    </View>
                    <TouchableOpacity>
                      <Text style={{ color: colors.role.seller, fontWeight: '600' }}>Directions</Text>
                    </TouchableOpacity>
                  </View>
                )}
              </TouchableOpacity>
            );
          })
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
