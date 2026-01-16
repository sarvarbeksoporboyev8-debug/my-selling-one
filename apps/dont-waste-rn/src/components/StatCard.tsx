import { View, Text } from 'react-native';

type StatCardProps = {
  label: string;
  value: string | number;
  subtitle?: string;
  valueColor?: 'default' | 'success' | 'warning' | 'error';
};

export function StatCard({ label, value, subtitle, valueColor = 'default' }: StatCardProps) {
  const valueColors = {
    default: 'text-white',
    success: 'text-emerald-500',
    warning: 'text-amber-500',
    error: 'text-red-500',
  };

  const subtitleColors = {
    default: 'text-text-tertiary',
    success: 'text-emerald-500',
    warning: 'text-text-tertiary',
    error: 'text-text-tertiary',
  };

  return (
    <View className="flex-1 bg-surface rounded-2xl p-4 border border-border">
      <Text className="text-text-tertiary text-xs uppercase tracking-wider">{label}</Text>
      <Text className={`${valueColors[valueColor]} text-3xl font-bold mt-1`}>{value}</Text>
      {subtitle && (
        <Text className={`${subtitleColors[valueColor]} text-xs mt-1`}>{subtitle}</Text>
      )}
    </View>
  );
}
