import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Settings, Bell, Moon, HelpCircle, LogOut, ChevronRight } from 'lucide-react-native';

type MenuItemProps = {
  icon: React.ReactNode;
  title: string;
  subtitle?: string;
  showChevron?: boolean;
};

function MenuItem({ icon, title, subtitle, showChevron = true }: MenuItemProps) {
  return (
    <TouchableOpacity className="flex-row items-center py-4 border-b border-gray-800">
      <View className="w-10 h-10 rounded-full bg-[#1A1A1B] items-center justify-center">
        {icon}
      </View>
      <View className="flex-1 ml-3">
        <Text className="text-white font-medium">{title}</Text>
        {subtitle && <Text className="text-gray-500 text-sm">{subtitle}</Text>}
      </View>
      {showChevron && <ChevronRight size={20} color="#6B7280" />}
    </TouchableOpacity>
  );
}

export default function ProfileScreen() {
  return (
    <SafeAreaView className="flex-1 bg-[#0A0A0B]">
      <ScrollView className="flex-1 px-4">
        {/* Header */}
        <View className="py-4">
          <Text className="text-white text-2xl font-bold">Profile</Text>
        </View>

        {/* Profile Card */}
        <View className="bg-[#1A1A1B] rounded-2xl p-6 border border-gray-800 items-center mt-4">
          <View className="w-20 h-20 rounded-full bg-emerald-500/20 items-center justify-center">
            <Text className="text-emerald-500 text-2xl font-bold">JD</Text>
          </View>
          <Text className="text-white text-xl font-semibold mt-4">John Doe</Text>
          <Text className="text-gray-400 mt-1">john.doe@example.com</Text>
          
          {/* Stats */}
          <View className="flex-row mt-6 w-full">
            <View className="flex-1 items-center">
              <Text className="text-white text-2xl font-bold">156</Text>
              <Text className="text-gray-500 text-sm">Items Saved</Text>
            </View>
            <View className="w-px bg-gray-800" />
            <View className="flex-1 items-center">
              <Text className="text-white text-2xl font-bold">$234</Text>
              <Text className="text-gray-500 text-sm">Money Saved</Text>
            </View>
            <View className="w-px bg-gray-800" />
            <View className="flex-1 items-center">
              <Text className="text-white text-2xl font-bold">12kg</Text>
              <Text className="text-gray-500 text-sm">Waste Reduced</Text>
            </View>
          </View>
        </View>

        {/* Menu Items */}
        <View className="mt-8">
          <Text className="text-gray-400 text-sm uppercase tracking-wider mb-2">Settings</Text>
          
          <MenuItem
            icon={<Bell size={20} color="#6B7280" />}
            title="Notifications"
            subtitle="Manage alerts and reminders"
          />
          <MenuItem
            icon={<Moon size={20} color="#6B7280" />}
            title="Appearance"
            subtitle="Dark mode enabled"
          />
          <MenuItem
            icon={<Settings size={20} color="#6B7280" />}
            title="Preferences"
            subtitle="Default expiry alerts, categories"
          />
        </View>

        <View className="mt-6">
          <Text className="text-gray-400 text-sm uppercase tracking-wider mb-2">Support</Text>
          
          <MenuItem
            icon={<HelpCircle size={20} color="#6B7280" />}
            title="Help & FAQ"
          />
        </View>

        {/* Logout */}
        <TouchableOpacity className="flex-row items-center justify-center py-4 mt-8">
          <LogOut size={20} color="#EF4444" />
          <Text className="text-red-500 font-medium ml-2">Sign Out</Text>
        </TouchableOpacity>

        {/* Bottom Spacing */}
        <View className="h-8" />
      </ScrollView>
    </SafeAreaView>
  );
}
