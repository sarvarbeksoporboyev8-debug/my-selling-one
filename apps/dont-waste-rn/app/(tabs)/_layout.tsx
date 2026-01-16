import { Tabs } from 'expo-router';
import { View, Text, StyleSheet } from 'react-native';
import {
  Home,
  Search,
  Map,
  ShoppingBag,
  User,
  Package,
  Truck,
  DollarSign,
} from 'lucide-react-native';
import { useTheme, useAuth } from '../../src/contexts';

type TabIconProps = {
  focused: boolean;
  icon: React.ReactNode;
  label: string;
  colors: ReturnType<typeof useTheme>['colors'];
};

function TabIcon({ focused, icon, label, colors }: TabIconProps) {
  return (
    <View style={styles.tabIcon}>
      <View style={{ opacity: focused ? 1 : 0.5 }}>{icon}</View>
      <Text
        style={[
          styles.tabLabel,
          {
            color: focused ? colors.tabBar.active : colors.tabBar.inactive,
            fontWeight: focused ? '600' : '400',
          },
        ]}
      >
        {label}
      </Text>
    </View>
  );
}

export default function TabLayout() {
  const { colors } = useTheme();
  const { user } = useAuth();
  const role = user?.role || 'buyer';

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: colors.tabBar.background,
          borderTopColor: colors.tabBar.border,
          borderTopWidth: 1,
          height: 85,
          paddingBottom: 25,
          paddingTop: 10,
        },
        tabBarShowLabel: false,
        tabBarActiveTintColor: colors.tabBar.active,
        tabBarInactiveTintColor: colors.tabBar.inactive,
      }}
    >
      {/* Home/Dashboard - visible to all */}
      <Tabs.Screen
        name="index"
        options={{
          title: role === 'seller' ? 'Dashboard' : role === 'delivery' ? 'Available' : 'Home',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<Home size={24} color={focused ? colors.tabBar.active : colors.tabBar.inactive} />}
              label={role === 'seller' ? 'Dashboard' : role === 'delivery' ? 'Available' : 'Home'}
              colors={colors}
            />
          ),
        }}
      />

      {/* Discover - Buyer only */}
      <Tabs.Screen
        name="discover"
        options={{
          title: 'Discover',
          href: role === 'buyer' ? ('/(tabs)/discover' as any) : null,
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<Search size={24} color={focused ? colors.tabBar.active : colors.tabBar.inactive} />}
              label="Discover"
              colors={colors}
            />
          ),
        }}
      />

      {/* Listings - Seller only */}
      <Tabs.Screen
        name="listings"
        options={{
          title: 'Listings',
          href: role === 'seller' ? ('/(tabs)/listings' as any) : null,
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<Package size={24} color={focused ? colors.tabBar.active : colors.tabBar.inactive} />}
              label="Listings"
              colors={colors}
            />
          ),
        }}
      />

      {/* Active Delivery - Delivery only */}
      <Tabs.Screen
        name="active-delivery"
        options={{
          title: 'Active',
          href: role === 'delivery' ? ('/(tabs)/active-delivery' as any) : null,
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<Truck size={24} color={focused ? colors.tabBar.active : colors.tabBar.inactive} />}
              label="Active"
              colors={colors}
            />
          ),
        }}
      />

      {/* Map - visible to all */}
      <Tabs.Screen
        name="map"
        options={{
          title: 'Map',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<Map size={24} color={focused ? colors.tabBar.active : colors.tabBar.inactive} />}
              label="Map"
              colors={colors}
            />
          ),
        }}
      />

      {/* Orders - Buyer only */}
      <Tabs.Screen
        name="orders"
        options={{
          title: 'Orders',
          href: role === 'buyer' ? ('/(tabs)/orders' as any) : null,
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<ShoppingBag size={24} color={focused ? colors.tabBar.active : colors.tabBar.inactive} />}
              label="Orders"
              colors={colors}
            />
          ),
        }}
      />

      {/* Seller Orders - Seller only */}
      <Tabs.Screen
        name="seller-orders"
        options={{
          title: 'Orders',
          href: role === 'seller' ? ('/(tabs)/seller-orders' as any) : null,
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<ShoppingBag size={24} color={focused ? colors.tabBar.active : colors.tabBar.inactive} />}
              label="Orders"
              colors={colors}
            />
          ),
        }}
      />

      {/* Earnings - Delivery only */}
      <Tabs.Screen
        name="earnings"
        options={{
          title: 'Earnings',
          href: role === 'delivery' ? ('/(tabs)/earnings' as any) : null,
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<DollarSign size={24} color={focused ? colors.tabBar.active : colors.tabBar.inactive} />}
              label="Earnings"
              colors={colors}
            />
          ),
        }}
      />

      {/* Profile - visible to all */}
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<User size={24} color={focused ? colors.tabBar.active : colors.tabBar.inactive} />}
              label="Profile"
              colors={colors}
            />
          ),
        }}
      />
    </Tabs>
  );
}

const styles = StyleSheet.create({
  tabIcon: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingTop: 4,
  },
  tabLabel: {
    fontSize: 10,
    marginTop: 4,
  },
});
