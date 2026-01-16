import { View, Text, ScrollView, TouchableOpacity, Image } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme } from '../../src/contexts';
import { Check, X, Truck, Package, Clock, Phone, MessageCircle } from 'lucide-react-native';
import { useState } from 'react';

type OrderTab = 'pending' | 'active' | 'completed';

const mockOrders = {
  pending: [
    {
      id: '1001',
      title: 'Organic Vegetables Bundle',
      image: 'https://picsum.photos/seed/veggies/200/200',
      buyer: { name: 'John D.', avatar: '👤', rating: 4.8 },
      quantity: 2,
      total: 30,
      deliveryMethod: 'delivery',
      createdAt: '5 min ago',
    },
    {
      id: '1002',
      title: 'iPhone 13 Pro - Like New',
      image: 'https://picsum.photos/seed/iphone/200/200',
      buyer: { name: 'Sarah M.', avatar: '👤', rating: 4.9 },
      quantity: 1,
      total: 699,
      deliveryMethod: 'pickup',
      createdAt: '15 min ago',
    },
  ],
  active: [
    {
      id: '1003',
      title: 'Vintage Leather Jacket',
      image: 'https://picsum.photos/seed/jacket/200/200',
      buyer: { name: 'Mike R.', avatar: '👤', rating: 4.7 },
      quantity: 1,
      total: 89,
      status: 'ready_for_pickup',
      statusText: 'Ready for pickup',
      deliveryMethod: 'pickup',
    },
    {
      id: '1004',
      title: 'Fresh Bakery Items',
      image: 'https://picsum.photos/seed/bakery/200/200',
      buyer: { name: 'Lisa K.', avatar: '👤', rating: 4.6 },
      quantity: 3,
      total: 24,
      status: 'awaiting_delivery',
      statusText: 'Waiting for driver',
      deliveryMethod: 'delivery',
    },
  ],
  completed: [
    {
      id: '1005',
      title: 'Gaming Console Bundle',
      image: 'https://picsum.photos/seed/gaming/200/200',
      buyer: { name: 'Tom H.', avatar: '👤', rating: 4.9 },
      total: 350,
      completedAt: 'Jan 15, 2024',
    },
  ],
};

export default function SellerOrdersScreen() {
  const { colors } = useTheme();
  const [activeTab, setActiveTab] = useState<OrderTab>('pending');

  const tabs: { key: OrderTab; label: string; count: number }[] = [
    { key: 'pending', label: 'Pending', count: mockOrders.pending.length },
    { key: 'active', label: 'Active', count: mockOrders.active.length },
    { key: 'completed', label: 'Completed', count: mockOrders.completed.length },
  ];

  const orders = mockOrders[activeTab];

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
      {/* Header */}
      <View style={{ paddingHorizontal: 16, paddingTop: 16 }}>
        <Text style={{ color: colors.text.primary, fontSize: 28, fontWeight: '700' }}>Orders</Text>
        <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>Manage incoming orders</Text>
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
              backgroundColor: activeTab === tab.key ? colors.role.seller : colors.surface.primary,
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
              {tab.label}
              {tab.key === 'pending' && tab.count > 0 && (
                <Text style={{ color: activeTab === tab.key ? '#FFFFFF' : colors.status.warning }}>
                  {' '}
                  ({tab.count})
                </Text>
              )}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Orders */}
      <ScrollView
        style={{ flex: 1, marginTop: 16 }}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 100 }}
        showsVerticalScrollIndicator={false}
      >
        {orders.length === 0 ? (
          <View style={{ alignItems: 'center', paddingTop: 60 }}>
            <Text style={{ fontSize: 48, marginBottom: 16 }}>📋</Text>
            <Text style={{ color: colors.text.primary, fontSize: 18, fontWeight: '600' }}>
              No {activeTab} orders
            </Text>
          </View>
        ) : (
          orders.map((order: any) => (
            <View
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
              {/* Order Header */}
              <View style={{ flexDirection: 'row', padding: 16 }}>
                <Image
                  source={{ uri: order.image }}
                  style={{ width: 70, height: 70, borderRadius: 12 }}
                />
                <View style={{ flex: 1, marginLeft: 12 }}>
                  <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
                    <Text style={{ color: colors.text.tertiary, fontSize: 12 }}>
                      Order #{order.id}
                    </Text>
                    {order.createdAt && (
                      <Text style={{ color: colors.text.tertiary, fontSize: 12 }}>
                        {order.createdAt}
                      </Text>
                    )}
                  </View>
                  <Text
                    style={{ color: colors.text.primary, fontSize: 15, fontWeight: '500', marginTop: 4 }}
                    numberOfLines={1}
                  >
                    {order.title}
                  </Text>
                  {order.quantity && (
                    <Text style={{ color: colors.text.tertiary, fontSize: 13, marginTop: 2 }}>
                      Qty: {order.quantity}
                    </Text>
                  )}
                  <Text style={{ color: colors.brand.primary, fontSize: 16, fontWeight: '700', marginTop: 4 }}>
                    ${order.total}
                  </Text>
                </View>
              </View>

              {/* Buyer Info */}
              <View
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  paddingHorizontal: 16,
                  paddingVertical: 12,
                  backgroundColor: colors.background.secondary,
                  borderTopWidth: 1,
                  borderTopColor: colors.border.subtle,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                  <View
                    style={{
                      width: 36,
                      height: 36,
                      borderRadius: 18,
                      backgroundColor: colors.surface.primary,
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    <Text>{order.buyer.avatar}</Text>
                  </View>
                  <View style={{ marginLeft: 10 }}>
                    <Text style={{ color: colors.text.primary, fontWeight: '500' }}>
                      {order.buyer.name}
                    </Text>
                    <Text style={{ color: colors.text.tertiary, fontSize: 12 }}>
                      ⭐ {order.buyer.rating}
                    </Text>
                  </View>
                </View>
                <View style={{ flexDirection: 'row', gap: 8 }}>
                  <TouchableOpacity
                    style={{
                      width: 36,
                      height: 36,
                      borderRadius: 18,
                      backgroundColor: colors.surface.primary,
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    <Phone size={16} color={colors.text.secondary} />
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={{
                      width: 36,
                      height: 36,
                      borderRadius: 18,
                      backgroundColor: colors.surface.primary,
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    <MessageCircle size={16} color={colors.text.secondary} />
                  </TouchableOpacity>
                </View>
              </View>

              {/* Delivery Method */}
              {order.deliveryMethod && (
                <View
                  style={{
                    flexDirection: 'row',
                    alignItems: 'center',
                    paddingHorizontal: 16,
                    paddingVertical: 10,
                    borderTopWidth: 1,
                    borderTopColor: colors.border.subtle,
                  }}
                >
                  {order.deliveryMethod === 'delivery' ? (
                    <>
                      <Truck size={16} color={colors.role.delivery} />
                      <Text style={{ color: colors.text.secondary, marginLeft: 8, fontSize: 13 }}>
                        Delivery requested
                      </Text>
                    </>
                  ) : (
                    <>
                      <Package size={16} color={colors.role.seller} />
                      <Text style={{ color: colors.text.secondary, marginLeft: 8, fontSize: 13 }}>
                        Customer will pickup
                      </Text>
                    </>
                  )}
                </View>
              )}

              {/* Status for active orders */}
              {order.status && (
                <View
                  style={{
                    flexDirection: 'row',
                    alignItems: 'center',
                    paddingHorizontal: 16,
                    paddingVertical: 10,
                    backgroundColor:
                      order.status === 'ready_for_pickup'
                        ? colors.role.sellerLight
                        : colors.status.warningLight,
                    borderTopWidth: 1,
                    borderTopColor: colors.border.subtle,
                  }}
                >
                  <Clock
                    size={16}
                    color={order.status === 'ready_for_pickup' ? colors.role.seller : colors.status.warning}
                  />
                  <Text
                    style={{
                      color: order.status === 'ready_for_pickup' ? colors.role.seller : colors.status.warning,
                      marginLeft: 8,
                      fontWeight: '500',
                    }}
                  >
                    {order.statusText}
                  </Text>
                </View>
              )}

              {/* Actions for pending orders */}
              {activeTab === 'pending' && (
                <View
                  style={{
                    flexDirection: 'row',
                    borderTopWidth: 1,
                    borderTopColor: colors.border.subtle,
                  }}
                >
                  <TouchableOpacity
                    style={{
                      flex: 1,
                      flexDirection: 'row',
                      alignItems: 'center',
                      justifyContent: 'center',
                      paddingVertical: 14,
                      backgroundColor: colors.status.errorLight,
                    }}
                  >
                    <X size={18} color={colors.status.error} />
                    <Text style={{ color: colors.status.error, marginLeft: 8, fontWeight: '600' }}>
                      Decline
                    </Text>
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={{
                      flex: 1,
                      flexDirection: 'row',
                      alignItems: 'center',
                      justifyContent: 'center',
                      paddingVertical: 14,
                      backgroundColor: colors.status.success,
                    }}
                  >
                    <Check size={18} color="#FFFFFF" />
                    <Text style={{ color: '#FFFFFF', marginLeft: 8, fontWeight: '600' }}>Accept</Text>
                  </TouchableOpacity>
                </View>
              )}

              {/* Actions for active orders */}
              {activeTab === 'active' && order.status === 'awaiting_delivery' && (
                <TouchableOpacity
                  style={{
                    backgroundColor: colors.role.delivery,
                    paddingVertical: 14,
                    alignItems: 'center',
                  }}
                >
                  <Text style={{ color: '#FFFFFF', fontWeight: '600' }}>Mark as Ready</Text>
                </TouchableOpacity>
              )}
            </View>
          ))
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
