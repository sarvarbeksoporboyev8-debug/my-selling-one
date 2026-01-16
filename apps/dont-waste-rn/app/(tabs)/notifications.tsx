import { View, Text, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { AlertTriangle, Clock, CheckCircle } from 'lucide-react-native';

type NotificationItemProps = {
  icon: React.ReactNode;
  title: string;
  message: string;
  time: string;
  type: 'warning' | 'info' | 'success';
};

function NotificationItem({ icon, title, message, time, type }: NotificationItemProps) {
  const bgColors = {
    warning: 'bg-amber-500/20',
    info: 'bg-blue-500/20',
    success: 'bg-emerald-500/20',
  };

  return (
    <View className="bg-[#1A1A1B] rounded-2xl p-4 border border-gray-800 mb-3">
      <View className="flex-row">
        <View className={`w-10 h-10 rounded-full ${bgColors[type]} items-center justify-center`}>
          {icon}
        </View>
        <View className="flex-1 ml-3">
          <Text className="text-white font-medium">{title}</Text>
          <Text className="text-gray-400 text-sm mt-1">{message}</Text>
          <Text className="text-gray-600 text-xs mt-2">{time}</Text>
        </View>
      </View>
    </View>
  );
}

export default function NotificationsScreen() {
  return (
    <SafeAreaView className="flex-1 bg-[#0A0A0B]">
      <ScrollView className="flex-1 px-4">
        {/* Header */}
        <View className="flex-row items-center justify-between py-4">
          <Text className="text-white text-2xl font-bold">Notifications</Text>
          <View className="bg-emerald-500 px-2 py-1 rounded-full">
            <Text className="text-white text-xs font-medium">3 new</Text>
          </View>
        </View>

        {/* Today */}
        <View className="mt-4">
          <Text className="text-gray-400 text-sm uppercase tracking-wider mb-4">Today</Text>
          
          <NotificationItem
            icon={<AlertTriangle size={20} color="#F59E0B" />}
            title="Milk expiring soon"
            message="Your milk will expire in 2 days. Consider using it soon!"
            time="2 hours ago"
            type="warning"
          />
          
          <NotificationItem
            icon={<AlertTriangle size={20} color="#EF4444" />}
            title="Apples expire tomorrow"
            message="6 apples in your fridge expire tomorrow."
            time="5 hours ago"
            type="warning"
          />
        </View>

        {/* Yesterday */}
        <View className="mt-6">
          <Text className="text-gray-400 text-sm uppercase tracking-wider mb-4">Yesterday</Text>
          
          <NotificationItem
            icon={<CheckCircle size={20} color="#10B981" />}
            title="Item consumed"
            message="You marked 'Yogurt' as consumed. Great job reducing waste!"
            time="Yesterday at 6:30 PM"
            type="success"
          />
          
          <NotificationItem
            icon={<Clock size={20} color="#3B82F6" />}
            title="Weekly summary"
            message="You saved 3 items from going to waste this week!"
            time="Yesterday at 9:00 AM"
            type="info"
          />
        </View>

        {/* Bottom Spacing */}
        <View className="h-8" />
      </ScrollView>
    </SafeAreaView>
  );
}
