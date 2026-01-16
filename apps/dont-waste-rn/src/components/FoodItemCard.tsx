import { View, Text, TouchableOpacity } from 'react-native';
import { Badge } from './ui/Badge';

type ExpiryStatus = 'expired' | 'expiring-soon' | 'expiring-medium' | 'fresh';

type FoodItemCardProps = {
  name: string;
  category: string;
  quantity: string;
  emoji: string;
  daysUntilExpiry: number;
  onPress?: () => void;
};

function getExpiryStatus(days: number): ExpiryStatus {
  if (days < 0) return 'expired';
  if (days <= 1) return 'expiring-soon';
  if (days <= 3) return 'expiring-medium';
  return 'fresh';
}

function getExpiryLabel(days: number): string {
  if (days < 0) return 'Expired';
  if (days === 0) return 'Today';
  if (days === 1) return 'Tomorrow';
  return `${days} days`;
}

function getExpiryBadgeVariant(status: ExpiryStatus): 'error' | 'warning' | 'success' {
  switch (status) {
    case 'expired':
    case 'expiring-soon':
      return 'error';
    case 'expiring-medium':
      return 'warning';
    case 'fresh':
      return 'success';
  }
}

function getCategoryColor(category: string): string {
  const colors: Record<string, string> = {
    dairy: 'bg-blue-500/20',
    fruits: 'bg-red-500/20',
    vegetables: 'bg-emerald-500/20',
    meat: 'bg-orange-500/20',
    beverages: 'bg-purple-500/20',
    grains: 'bg-amber-500/20',
    other: 'bg-gray-500/20',
  };
  return colors[category.toLowerCase()] || colors.other;
}

export function FoodItemCard({
  name,
  category,
  quantity,
  emoji,
  daysUntilExpiry,
  onPress,
}: FoodItemCardProps) {
  const status = getExpiryStatus(daysUntilExpiry);
  const label = getExpiryLabel(daysUntilExpiry);
  const badgeVariant = getExpiryBadgeVariant(status);
  const categoryBg = getCategoryColor(category);

  return (
    <TouchableOpacity
      onPress={onPress}
      activeOpacity={0.7}
      className="bg-surface rounded-2xl p-4 border border-border mb-3"
    >
      <View className="flex-row items-center justify-between">
        <View className="flex-row items-center flex-1">
          <View className={`w-12 h-12 rounded-xl ${categoryBg} items-center justify-center`}>
            <Text className="text-2xl">{emoji}</Text>
          </View>
          <View className="ml-3 flex-1">
            <Text className="text-white font-medium text-base">{name}</Text>
            <Text className="text-text-tertiary text-sm">
              {category} • {quantity}
            </Text>
          </View>
        </View>
        <Badge label={label} variant={badgeVariant} size="md" />
      </View>
    </TouchableOpacity>
  );
}
