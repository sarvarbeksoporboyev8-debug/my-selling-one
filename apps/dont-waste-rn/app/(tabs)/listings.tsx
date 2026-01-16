import { View, Text, ScrollView, TouchableOpacity, Image } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme } from '../../src/contexts';
import { Plus, Eye, Edit2, Trash2, MoreVertical } from 'lucide-react-native';
import { useState } from 'react';

type ListingTab = 'active' | 'sold' | 'expired';

const mockListings = {
  active: [
    {
      id: '1',
      title: 'iPhone 13 Pro - Like New',
      image: 'https://picsum.photos/seed/iphone/200/200',
      price: 699,
      originalPrice: 999,
      views: 234,
      inquiries: 12,
      quantity: 1,
      createdAt: '2 days ago',
    },
    {
      id: '2',
      title: 'Organic Vegetables Bundle',
      image: 'https://picsum.photos/seed/veggies/200/200',
      price: 15,
      originalPrice: 30,
      views: 89,
      inquiries: 5,
      quantity: 10,
      expiresIn: '3 hours',
      createdAt: '5 hours ago',
    },
    {
      id: '3',
      title: 'Vintage Leather Jacket',
      image: 'https://picsum.photos/seed/jacket/200/200',
      price: 89,
      originalPrice: 150,
      views: 156,
      inquiries: 8,
      quantity: 1,
      createdAt: '1 week ago',
    },
  ],
  sold: [
    {
      id: '4',
      title: 'Gaming Console Bundle',
      image: 'https://picsum.photos/seed/gaming/200/200',
      price: 350,
      soldAt: 'Jan 15, 2024',
      buyer: 'John D.',
    },
    {
      id: '5',
      title: 'Designer Handbag',
      image: 'https://picsum.photos/seed/bag/200/200',
      price: 120,
      soldAt: 'Jan 12, 2024',
      buyer: 'Sarah M.',
    },
  ],
  expired: [
    {
      id: '6',
      title: 'Fresh Bakery Items',
      image: 'https://picsum.photos/seed/bakery/200/200',
      price: 8,
      expiredAt: 'Jan 10, 2024',
    },
  ],
};

export default function ListingsScreen() {
  const { colors } = useTheme();
  const [activeTab, setActiveTab] = useState<ListingTab>('active');

  const tabs: { key: ListingTab; label: string; count: number }[] = [
    { key: 'active', label: 'Active', count: mockListings.active.length },
    { key: 'sold', label: 'Sold', count: mockListings.sold.length },
    { key: 'expired', label: 'Expired', count: mockListings.expired.length },
  ];

  const listings = mockListings[activeTab];

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
      {/* Header */}
      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'space-between',
          alignItems: 'center',
          paddingHorizontal: 16,
          paddingTop: 16,
        }}
      >
        <View>
          <Text style={{ color: colors.text.primary, fontSize: 28, fontWeight: '700' }}>Listings</Text>
          <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>Manage your products</Text>
        </View>
        <TouchableOpacity
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            backgroundColor: colors.brand.primary,
            paddingHorizontal: 16,
            paddingVertical: 10,
            borderRadius: 12,
          }}
        >
          <Plus size={20} color="#FFFFFF" />
          <Text style={{ color: '#FFFFFF', fontWeight: '600', marginLeft: 8 }}>Add</Text>
        </TouchableOpacity>
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
              {tab.label} ({tab.count})
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Listings */}
      <ScrollView
        style={{ flex: 1, marginTop: 16 }}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 100 }}
        showsVerticalScrollIndicator={false}
      >
        {listings.length === 0 ? (
          <View style={{ alignItems: 'center', paddingTop: 60 }}>
            <Text style={{ fontSize: 48, marginBottom: 16 }}>📦</Text>
            <Text style={{ color: colors.text.primary, fontSize: 18, fontWeight: '600' }}>
              No {activeTab} listings
            </Text>
            <Text style={{ color: colors.text.tertiary, marginTop: 8, textAlign: 'center' }}>
              {activeTab === 'active'
                ? 'Create your first listing to start selling'
                : `Your ${activeTab} listings will appear here`}
            </Text>
          </View>
        ) : (
          listings.map((listing: any) => (
            <View
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
              <View style={{ flexDirection: 'row', padding: 16 }}>
                <Image
                  source={{ uri: listing.image }}
                  style={{ width: 80, height: 80, borderRadius: 12 }}
                />
                <View style={{ flex: 1, marginLeft: 12 }}>
                  <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
                    <Text
                      style={{ color: colors.text.primary, fontSize: 16, fontWeight: '500', flex: 1 }}
                      numberOfLines={1}
                    >
                      {listing.title}
                    </Text>
                    <TouchableOpacity style={{ padding: 4 }}>
                      <MoreVertical size={20} color={colors.text.tertiary} />
                    </TouchableOpacity>
                  </View>

                  <Text style={{ color: colors.brand.primary, fontSize: 18, fontWeight: '700', marginTop: 4 }}>
                    ${listing.price}
                    {listing.originalPrice && (
                      <Text
                        style={{
                          color: colors.text.muted,
                          fontSize: 14,
                          fontWeight: '400',
                          textDecorationLine: 'line-through',
                        }}
                      >
                        {' '}
                        ${listing.originalPrice}
                      </Text>
                    )}
                  </Text>

                  {activeTab === 'active' && (
                    <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 8, gap: 12 }}>
                      <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                        <Eye size={14} color={colors.text.tertiary} />
                        <Text style={{ color: colors.text.tertiary, fontSize: 12, marginLeft: 4 }}>
                          {listing.views}
                        </Text>
                      </View>
                      <Text style={{ color: colors.text.tertiary, fontSize: 12 }}>
                        {listing.inquiries} inquiries
                      </Text>
                      {listing.expiresIn && (
                        <View
                          style={{
                            backgroundColor: colors.status.warningLight,
                            paddingHorizontal: 6,
                            paddingVertical: 2,
                            borderRadius: 4,
                          }}
                        >
                          <Text style={{ color: colors.status.warning, fontSize: 10, fontWeight: '500' }}>
                            Expires in {listing.expiresIn}
                          </Text>
                        </View>
                      )}
                    </View>
                  )}

                  {activeTab === 'sold' && (
                    <Text style={{ color: colors.text.tertiary, fontSize: 12, marginTop: 8 }}>
                      Sold to {listing.buyer} • {listing.soldAt}
                    </Text>
                  )}

                  {activeTab === 'expired' && (
                    <Text style={{ color: colors.status.error, fontSize: 12, marginTop: 8 }}>
                      Expired on {listing.expiredAt}
                    </Text>
                  )}
                </View>
              </View>

              {/* Actions for active listings */}
              {activeTab === 'active' && (
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
                      paddingVertical: 12,
                      borderRightWidth: 1,
                      borderRightColor: colors.border.subtle,
                    }}
                  >
                    <Edit2 size={16} color={colors.text.secondary} />
                    <Text style={{ color: colors.text.secondary, marginLeft: 8, fontWeight: '500' }}>
                      Edit
                    </Text>
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={{
                      flex: 1,
                      flexDirection: 'row',
                      alignItems: 'center',
                      justifyContent: 'center',
                      paddingVertical: 12,
                    }}
                  >
                    <Trash2 size={16} color={colors.status.error} />
                    <Text style={{ color: colors.status.error, marginLeft: 8, fontWeight: '500' }}>
                      Remove
                    </Text>
                  </TouchableOpacity>
                </View>
              )}

              {/* Relist button for expired */}
              {activeTab === 'expired' && (
                <TouchableOpacity
                  style={{
                    backgroundColor: colors.brand.primary,
                    paddingVertical: 12,
                    alignItems: 'center',
                  }}
                >
                  <Text style={{ color: '#FFFFFF', fontWeight: '600' }}>Relist Item</Text>
                </TouchableOpacity>
              )}
            </View>
          ))
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
