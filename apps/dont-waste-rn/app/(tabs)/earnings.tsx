import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme } from '../../src/contexts';
import { TrendingUp, Calendar, ChevronRight, Truck, DollarSign, Clock } from 'lucide-react-native';
import { useState } from 'react';

type TimeRange = 'today' | 'week' | 'month';

const earningsData = {
  today: {
    total: 48,
    deliveries: 6,
    hours: 4.5,
    perHour: 10.67,
    transactions: [
      { id: '1', time: '2:30 PM', pickup: 'Green Farm', amount: 8 },
      { id: '2', time: '1:15 PM', pickup: 'Tech Store', amount: 12 },
      { id: '3', time: '11:45 AM', pickup: 'Fashion Hub', amount: 6 },
      { id: '4', time: '10:30 AM', pickup: 'Local Bakery', amount: 5 },
      { id: '5', time: '9:15 AM', pickup: 'Home Goods', amount: 10 },
      { id: '6', time: '8:00 AM', pickup: 'Coffee Shop', amount: 7 },
    ],
  },
  week: {
    total: 312,
    deliveries: 42,
    hours: 28,
    perHour: 11.14,
    transactions: [],
  },
  month: {
    total: 1248,
    deliveries: 156,
    hours: 112,
    perHour: 11.14,
    transactions: [],
  },
};

export default function EarningsScreen() {
  const { colors } = useTheme();
  const [timeRange, setTimeRange] = useState<TimeRange>('today');

  const data = earningsData[timeRange];

  const timeRanges: { key: TimeRange; label: string }[] = [
    { key: 'today', label: 'Today' },
    { key: 'week', label: 'This Week' },
    { key: 'month', label: 'This Month' },
  ];

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
      <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={{ paddingHorizontal: 16, paddingTop: 16 }}>
          <Text style={{ color: colors.text.primary, fontSize: 28, fontWeight: '700' }}>Earnings</Text>
          <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>Track your income</Text>
        </View>

        {/* Time Range Selector */}
        <View
          style={{
            flexDirection: 'row',
            marginHorizontal: 16,
            marginTop: 20,
            backgroundColor: colors.surface.primary,
            borderRadius: 12,
            padding: 4,
            borderWidth: 1,
            borderColor: colors.border.default,
          }}
        >
          {timeRanges.map((range) => (
            <TouchableOpacity
              key={range.key}
              onPress={() => setTimeRange(range.key)}
              style={{
                flex: 1,
                paddingVertical: 10,
                borderRadius: 8,
                backgroundColor: timeRange === range.key ? colors.role.delivery : 'transparent',
                alignItems: 'center',
              }}
            >
              <Text
                style={{
                  color: timeRange === range.key ? '#FFFFFF' : colors.text.secondary,
                  fontWeight: '600',
                }}
              >
                {range.label}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Total Earnings Card */}
        <View
          style={{
            marginHorizontal: 16,
            marginTop: 20,
            backgroundColor: colors.role.delivery,
            borderRadius: 20,
            padding: 24,
          }}
        >
          <Text style={{ color: 'rgba(255,255,255,0.8)', fontSize: 14 }}>Total Earnings</Text>
          <Text style={{ color: '#FFFFFF', fontSize: 48, fontWeight: '700', marginTop: 8 }}>
            ${data.total.toFixed(2)}
          </Text>
          <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 12 }}>
            <TrendingUp size={16} color="#FFFFFF" />
            <Text style={{ color: '#FFFFFF', marginLeft: 8 }}>
              +12% from last {timeRange === 'today' ? 'day' : timeRange === 'week' ? 'week' : 'month'}
            </Text>
          </View>
        </View>

        {/* Stats Grid */}
        <View style={{ flexDirection: 'row', paddingHorizontal: 16, marginTop: 20, gap: 12 }}>
          <View
            style={{
              flex: 1,
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              padding: 16,
              borderWidth: 1,
              borderColor: colors.border.default,
            }}
          >
            <View
              style={{
                width: 40,
                height: 40,
                borderRadius: 20,
                backgroundColor: colors.status.infoLight,
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: 12,
              }}
            >
              <Truck size={20} color={colors.status.info} />
            </View>
            <Text style={{ color: colors.text.primary, fontSize: 24, fontWeight: '700' }}>
              {data.deliveries}
            </Text>
            <Text style={{ color: colors.text.tertiary, fontSize: 12, marginTop: 4 }}>Deliveries</Text>
          </View>

          <View
            style={{
              flex: 1,
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              padding: 16,
              borderWidth: 1,
              borderColor: colors.border.default,
            }}
          >
            <View
              style={{
                width: 40,
                height: 40,
                borderRadius: 20,
                backgroundColor: colors.role.sellerLight,
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: 12,
              }}
            >
              <Clock size={20} color={colors.role.seller} />
            </View>
            <Text style={{ color: colors.text.primary, fontSize: 24, fontWeight: '700' }}>
              {data.hours}h
            </Text>
            <Text style={{ color: colors.text.tertiary, fontSize: 12, marginTop: 4 }}>Hours Online</Text>
          </View>

          <View
            style={{
              flex: 1,
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              padding: 16,
              borderWidth: 1,
              borderColor: colors.border.default,
            }}
          >
            <View
              style={{
                width: 40,
                height: 40,
                borderRadius: 20,
                backgroundColor: colors.status.successLight,
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: 12,
              }}
            >
              <DollarSign size={20} color={colors.status.success} />
            </View>
            <Text style={{ color: colors.text.primary, fontSize: 24, fontWeight: '700' }}>
              ${data.perHour.toFixed(0)}
            </Text>
            <Text style={{ color: colors.text.tertiary, fontSize: 12, marginTop: 4 }}>Per Hour</Text>
          </View>
        </View>

        {/* Recent Transactions */}
        {timeRange === 'today' && data.transactions.length > 0 && (
          <View style={{ paddingHorizontal: 16, marginTop: 24 }}>
            <View
              style={{
                flexDirection: 'row',
                justifyContent: 'space-between',
                alignItems: 'center',
                marginBottom: 12,
              }}
            >
              <Text style={{ color: colors.text.primary, fontSize: 18, fontWeight: '600' }}>
                Today's Deliveries
              </Text>
              <TouchableOpacity style={{ flexDirection: 'row', alignItems: 'center' }}>
                <Text style={{ color: colors.role.delivery, fontSize: 14 }}>See all</Text>
                <ChevronRight size={16} color={colors.role.delivery} />
              </TouchableOpacity>
            </View>

            {data.transactions.map((tx) => (
              <View
                key={tx.id}
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  backgroundColor: colors.surface.primary,
                  borderRadius: 12,
                  padding: 16,
                  marginBottom: 8,
                  borderWidth: 1,
                  borderColor: colors.border.default,
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                  <View
                    style={{
                      width: 40,
                      height: 40,
                      borderRadius: 20,
                      backgroundColor: colors.status.successLight,
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    <Truck size={18} color={colors.status.success} />
                  </View>
                  <View style={{ marginLeft: 12 }}>
                    <Text style={{ color: colors.text.primary, fontWeight: '500' }}>{tx.pickup}</Text>
                    <Text style={{ color: colors.text.tertiary, fontSize: 12, marginTop: 2 }}>
                      {tx.time}
                    </Text>
                  </View>
                </View>
                <Text style={{ color: colors.status.success, fontSize: 16, fontWeight: '700' }}>
                  +${tx.amount}
                </Text>
              </View>
            ))}
          </View>
        )}

        {/* Payout Info */}
        <View style={{ paddingHorizontal: 16, marginTop: 24, marginBottom: 120 }}>
          <TouchableOpacity
            style={{
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              padding: 16,
              borderWidth: 1,
              borderColor: colors.border.default,
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              <View
                style={{
                  width: 44,
                  height: 44,
                  borderRadius: 22,
                  backgroundColor: colors.role.deliveryLight,
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <Calendar size={22} color={colors.role.delivery} />
              </View>
              <View style={{ marginLeft: 12 }}>
                <Text style={{ color: colors.text.primary, fontWeight: '600' }}>Next Payout</Text>
                <Text style={{ color: colors.text.tertiary, fontSize: 13, marginTop: 2 }}>
                  Friday, Jan 19 • $312.00
                </Text>
              </View>
            </View>
            <ChevronRight size={20} color={colors.text.tertiary} />
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
