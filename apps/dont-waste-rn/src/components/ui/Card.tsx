import { View, ViewProps } from 'react-native';
import { ReactNode } from 'react';

type CardProps = ViewProps & {
  children: ReactNode;
  variant?: 'default' | 'elevated' | 'outlined';
};

export function Card({ children, variant = 'default', className = '', ...props }: CardProps) {
  const variants = {
    default: 'bg-surface rounded-2xl p-4 border border-border',
    elevated: 'bg-surface rounded-2xl p-4 border border-border shadow-lg',
    outlined: 'bg-transparent rounded-2xl p-4 border border-border-strong',
  };

  return (
    <View className={`${variants[variant]} ${className}`} {...props}>
      {children}
    </View>
  );
}
