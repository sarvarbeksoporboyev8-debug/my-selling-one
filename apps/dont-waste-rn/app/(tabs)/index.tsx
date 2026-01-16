import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { FoodItemCard, StatCard } from '../../src/components';

// Mock data - would come from state management in production
const mockItems = [
  { id: '1', name: 'Milk', category: 'Dairy', quantity: '1L', emoji: '🥛', daysUntilExpiry: 2 },
  { id: '2', name: 'Apples', category: 'Fruits', quantity: '6 pcs', emoji: '🍎', daysUntilExpiry: 1 },
  { id: '3', name: 'Spinach', category: 'Vegetables', quantity: '200g', emoji: '🥬', daysUntilExpiry: 3 },
  { id: '4', name: 'Chicken Breast', category: 'Meat', quantity: '500g', emoji: '🍗', daysUntilExpiry: 0 },
  { id: '5', name: 'Greek Yogurt', category: 'Dairy', quantity: '500g', emoji: '🥄', daysUntilExpiry: 5 },
];

function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

export default function HomeScreen() {
  const router = useRouter();
  const expiringItems = mockItems.filter((item) => item.daysUntilExpiry <= 3);
  const totalItems = mockItems.length;
  const expiringSoonCount = mockItems.filter((item) => item.daysUntilExpiry <= 2).length;

  return (
    <SafeAreaView className="flex-1 bg-background">
      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View className="flex-row items-center justify-between px-4 py-4">
          <View>
            <Text className="text-text-tertiary text-sm">{getGreeting()}</Text>
            <Text className="text-white text-2xl font-bold">Dashboard</Text>
          </View>
          <TouchableOpacity
            onPress={() => router.push('/profile')}
            className="w-11 h-11 rounded-full bg-surface border border-border items-center justify-center"
          >
            <Text className="text-white font-semibold">JD</Text>
          </TouchableOpacity>
        </View>

        {/* Stats Cards */}
        <View className="flex-row gap-3 px-4 mt-2">
          <StatCard
            label="Items Tracked"
            value={totalItems}
            subtitle="+3 this week"
            valueColor="default"
          />
          <StatCard
            label="Expiring Soon"
            value={expiringSoonCount}
            subtitle="Next 3 days"
            valueColor="warning"
          />
        </View>

        {/* Quick Actions */}
        <View className="px-4 mt-6">
          <View className="flex-row gap-3">
            <TouchableOpacity
              onPress={() => router.push('/add')}
              className="flex-1 bg-brand rounded-2xl py-4 items-center"
            >
              <Text className="text-white font-semibold">+ Add Item</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={() => router.push('/search')}
              className="flex-1 bg-surface border border-border rounded-2xl py-4 items-center"
            >
              <Text className="text-white font-semibold">View All</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Expiring Items Section */}
        <View className="mt-8 px-4">
          <View className="flex-row items-center justify-between mb-4">
            <Text className="text-white text-lg font-semibold">Expiring Soon</Text>
            <TouchableOpacity>
              <Text className="text-brand text-sm font-medium">See all</Text>
            </TouchableOpacity>
          </View>

          {expiringItems.length > 0 ? (
            expiringItems.map((item) => (
              <FoodItemCard
                key={item.id}
                name={item.name}
                category={item.category}
                quantity={item.quantity}
                emoji={item.emoji}
                daysUntilExpiry={item.daysUntilExpiry}
                onPress={() => {
                  // Navigate to item detail
                }}
              />
            ))
          ) : (
            <View className="bg-surface rounded-2xl p-8 border border-border items-center">
              <Text className="text-4xl mb-3">🎉</Text>
              <Text className="text-white font-medium text-center">No items expiring soon!</Text>
              <Text className="text-text-tertiary text-sm text-center mt-1">
                Great job managing your food
              </Text>
            </View>
          )}
        </View>

        {/* Tips Section */}
        <View className="mt-8 px-4 mb-8">
          <Text className="text-white text-lg font-semibold mb-4">Tips</Text>
          <View className="bg-gradient-to-r from-emerald-500/10 to-blue-500/10 bg-surface rounded-2xl p-4 border border-emerald-500/20">
            <View className="flex-row items-start">
              <Text className="text-2xl mr-3">💡</Text>
              <View className="flex-1">
                <Text className="text-white font-medium">Store apples separately</Text>
                <Text className="text-text-secondary text-sm mt-1">
                  Apples release ethylene gas which can cause other fruits and vegetables to ripen
                  faster.
                </Text>
              </View>
            </View>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
