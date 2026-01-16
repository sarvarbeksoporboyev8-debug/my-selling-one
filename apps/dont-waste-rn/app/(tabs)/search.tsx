import { View, Text, TextInput } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Search as SearchIcon } from 'lucide-react-native';

export default function SearchScreen() {
  return (
    <SafeAreaView className="flex-1 bg-[#0A0A0B]">
      <View className="flex-1 px-4">
        {/* Header */}
        <View className="py-4">
          <Text className="text-white text-2xl font-bold">Search</Text>
        </View>

        {/* Search Input */}
        <View className="flex-row items-center bg-[#1A1A1B] rounded-xl px-4 py-3 border border-gray-800">
          <SearchIcon size={20} color="#6B7280" />
          <TextInput
            placeholder="Search items..."
            placeholderTextColor="#6B7280"
            className="flex-1 ml-3 text-white text-base"
          />
        </View>

        {/* Categories */}
        <View className="mt-6">
          <Text className="text-gray-400 text-sm uppercase tracking-wider mb-4">Categories</Text>
          <View className="flex-row flex-wrap gap-2">
            {['All', 'Dairy', 'Fruits', 'Vegetables', 'Meat', 'Beverages'].map((cat) => (
              <View
                key={cat}
                className={`px-4 py-2 rounded-full ${
                  cat === 'All' ? 'bg-white' : 'bg-[#1A1A1B] border border-gray-800'
                }`}
              >
                <Text className={cat === 'All' ? 'text-black font-medium' : 'text-gray-400'}>
                  {cat}
                </Text>
              </View>
            ))}
          </View>
        </View>

        {/* Empty State */}
        <View className="flex-1 items-center justify-center">
          <Text className="text-gray-500 text-center">
            Start typing to search your items
          </Text>
        </View>
      </View>
    </SafeAreaView>
  );
}
