import { View, Text, TextInput, TouchableOpacity, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Camera, Barcode, Calendar } from 'lucide-react-native';

export default function AddScreen() {
  return (
    <SafeAreaView className="flex-1 bg-[#0A0A0B]">
      <ScrollView className="flex-1 px-4">
        {/* Header */}
        <View className="py-4">
          <Text className="text-white text-2xl font-bold">Add Item</Text>
          <Text className="text-gray-400 mt-1">Track a new food item</Text>
        </View>

        {/* Quick Actions */}
        <View className="flex-row gap-3 mt-4">
          <TouchableOpacity className="flex-1 bg-[#1A1A1B] rounded-2xl p-4 border border-gray-800 items-center">
            <View className="w-12 h-12 rounded-full bg-emerald-500/20 items-center justify-center mb-2">
              <Camera size={24} color="#10B981" />
            </View>
            <Text className="text-white font-medium">Scan Label</Text>
            <Text className="text-gray-500 text-xs mt-1">Use camera</Text>
          </TouchableOpacity>
          <TouchableOpacity className="flex-1 bg-[#1A1A1B] rounded-2xl p-4 border border-gray-800 items-center">
            <View className="w-12 h-12 rounded-full bg-blue-500/20 items-center justify-center mb-2">
              <Barcode size={24} color="#3B82F6" />
            </View>
            <Text className="text-white font-medium">Scan Barcode</Text>
            <Text className="text-gray-500 text-xs mt-1">Quick add</Text>
          </TouchableOpacity>
        </View>

        {/* Manual Entry */}
        <View className="mt-8">
          <Text className="text-gray-400 text-sm uppercase tracking-wider mb-4">Or add manually</Text>
          
          {/* Item Name */}
          <View className="mb-4">
            <Text className="text-gray-400 text-sm mb-2">Item Name</Text>
            <TextInput
              placeholder="e.g., Milk, Eggs, Bread..."
              placeholderTextColor="#6B7280"
              className="bg-[#1A1A1B] rounded-xl px-4 py-3 text-white border border-gray-800"
            />
          </View>

          {/* Category */}
          <View className="mb-4">
            <Text className="text-gray-400 text-sm mb-2">Category</Text>
            <View className="flex-row flex-wrap gap-2">
              {['Dairy', 'Fruits', 'Vegetables', 'Meat', 'Beverages', 'Other'].map((cat) => (
                <TouchableOpacity
                  key={cat}
                  className="px-4 py-2 rounded-full bg-[#1A1A1B] border border-gray-800"
                >
                  <Text className="text-gray-400">{cat}</Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          {/* Expiry Date */}
          <View className="mb-4">
            <Text className="text-gray-400 text-sm mb-2">Expiry Date</Text>
            <TouchableOpacity className="flex-row items-center bg-[#1A1A1B] rounded-xl px-4 py-3 border border-gray-800">
              <Calendar size={20} color="#6B7280" />
              <Text className="text-gray-500 ml-3">Select date</Text>
            </TouchableOpacity>
          </View>

          {/* Quantity */}
          <View className="mb-6">
            <Text className="text-gray-400 text-sm mb-2">Quantity</Text>
            <TextInput
              placeholder="e.g., 1L, 6 pcs, 500g..."
              placeholderTextColor="#6B7280"
              className="bg-[#1A1A1B] rounded-xl px-4 py-3 text-white border border-gray-800"
            />
          </View>

          {/* Add Button */}
          <TouchableOpacity className="bg-emerald-500 rounded-xl py-4 items-center">
            <Text className="text-white font-semibold text-base">Add Item</Text>
          </TouchableOpacity>
        </View>

        {/* Bottom Spacing */}
        <View className="h-8" />
      </ScrollView>
    </SafeAreaView>
  );
}
