import { Tabs } from 'expo-router';
import { View, Text } from 'react-native';
import { Home, Search, PlusCircle, Bell, User } from 'lucide-react-native';

type TabIconProps = {
  focused: boolean;
  icon: React.ReactNode;
  label: string;
};

function TabIcon({ focused, icon, label }: TabIconProps) {
  return (
    <View className="items-center justify-center pt-2">
      <View className={focused ? 'opacity-100' : 'opacity-50'}>
        {icon}
      </View>
      <Text
        className={`text-[10px] mt-1 ${
          focused ? 'text-white font-medium' : 'text-gray-500'
        }`}
      >
        {label}
      </Text>
    </View>
  );
}

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: '#0A0A0B',
          borderTopColor: '#1A1A1B',
          borderTopWidth: 1,
          height: 80,
          paddingBottom: 20,
        },
        tabBarShowLabel: false,
        tabBarActiveTintColor: '#FFFFFF',
        tabBarInactiveTintColor: '#6B7280',
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<Home size={24} color={focused ? '#FFFFFF' : '#6B7280'} />}
              label="Home"
            />
          ),
        }}
      />
      <Tabs.Screen
        name="search"
        options={{
          title: 'Search',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<Search size={24} color={focused ? '#FFFFFF' : '#6B7280'} />}
              label="Search"
            />
          ),
        }}
      />
      <Tabs.Screen
        name="add"
        options={{
          title: 'Add',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<PlusCircle size={28} color={focused ? '#10B981' : '#10B981'} />}
              label="Add"
            />
          ),
        }}
      />
      <Tabs.Screen
        name="notifications"
        options={{
          title: 'Alerts',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<Bell size={24} color={focused ? '#FFFFFF' : '#6B7280'} />}
              label="Alerts"
            />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              focused={focused}
              icon={<User size={24} color={focused ? '#FFFFFF' : '#6B7280'} />}
              label="Profile"
            />
          ),
        }}
      />
    </Tabs>
  );
}
