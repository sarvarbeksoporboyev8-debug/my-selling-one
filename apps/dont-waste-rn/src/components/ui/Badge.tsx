import { View, Text } from 'react-native';

type BadgeProps = {
  label: string;
  variant?: 'success' | 'warning' | 'error' | 'info' | 'neutral';
  size?: 'sm' | 'md';
};

export function Badge({ label, variant = 'neutral', size = 'sm' }: BadgeProps) {
  const variants = {
    success: {
      bg: 'bg-emerald-500/20',
      text: 'text-emerald-500',
    },
    warning: {
      bg: 'bg-amber-500/20',
      text: 'text-amber-500',
    },
    error: {
      bg: 'bg-red-500/20',
      text: 'text-red-500',
    },
    info: {
      bg: 'bg-blue-500/20',
      text: 'text-blue-500',
    },
    neutral: {
      bg: 'bg-gray-500/20',
      text: 'text-gray-400',
    },
  };

  const sizes = {
    sm: 'px-2 py-0.5',
    md: 'px-3 py-1',
  };

  const textSizes = {
    sm: 'text-[10px]',
    md: 'text-xs',
  };

  const { bg, text } = variants[variant];

  return (
    <View className={`${bg} ${sizes[size]} rounded-full`}>
      <Text className={`${text} ${textSizes[size]} font-medium`}>{label}</Text>
    </View>
  );
}
