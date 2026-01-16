import { TouchableOpacity, Text, ActivityIndicator, TouchableOpacityProps } from 'react-native';
import { ReactNode } from 'react';

type ButtonProps = TouchableOpacityProps & {
  children: ReactNode;
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  icon?: ReactNode;
};

export function Button({
  children,
  variant = 'primary',
  size = 'md',
  loading = false,
  icon,
  disabled,
  className = '',
  ...props
}: ButtonProps) {
  const variants = {
    primary: 'bg-brand',
    secondary: 'bg-surface border border-border',
    outline: 'bg-transparent border border-border-strong',
    ghost: 'bg-transparent',
  };

  const textVariants = {
    primary: 'text-white',
    secondary: 'text-white',
    outline: 'text-white',
    ghost: 'text-text-secondary',
  };

  const sizes = {
    sm: 'py-2 px-3',
    md: 'py-3 px-4',
    lg: 'py-4 px-6',
  };

  const textSizes = {
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-md',
  };

  return (
    <TouchableOpacity
      className={`${variants[variant]} ${sizes[size]} rounded-xl flex-row items-center justify-center ${
        disabled || loading ? 'opacity-50' : ''
      } ${className}`}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? (
        <ActivityIndicator color="#FFFFFF" size="small" />
      ) : (
        <>
          {icon && <>{icon}</>}
          <Text
            className={`${textVariants[variant]} ${textSizes[size]} font-semibold ${
              icon ? 'ml-2' : ''
            }`}
          >
            {children}
          </Text>
        </>
      )}
    </TouchableOpacity>
  );
}
