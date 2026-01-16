/**
 * Premium theme color palette for Don't Waste app
 * Supports both light and dark modes
 */

export const lightColors = {
  // Background colors
  background: {
    primary: '#FFFFFF',
    secondary: '#F8F9FA',
    tertiary: '#F1F3F5',
    elevated: '#FFFFFF',
  },

  // Surface colors for cards
  surface: {
    primary: '#FFFFFF',
    secondary: '#F8F9FA',
    tertiary: '#F1F3F5',
  },

  // Text colors
  text: {
    primary: '#09090B',
    secondary: '#52525B',
    tertiary: '#71717A',
    muted: '#A1A1AA',
    inverse: '#FFFFFF',
  },

  // Border colors
  border: {
    default: '#E4E4E7',
    subtle: '#F4F4F5',
    strong: '#D4D4D8',
  },

  // Brand colors
  brand: {
    primary: '#10B981',
    primaryLight: '#34D399',
    primaryDark: '#059669',
    secondary: '#3B82F6',
  },

  // Status colors
  status: {
    success: '#10B981',
    successLight: 'rgba(16, 185, 129, 0.1)',
    warning: '#F59E0B',
    warningLight: 'rgba(245, 158, 11, 0.1)',
    error: '#EF4444',
    errorLight: 'rgba(239, 68, 68, 0.1)',
    info: '#3B82F6',
    infoLight: 'rgba(59, 130, 246, 0.1)',
  },

  // Role colors
  role: {
    seller: '#8B5CF6',
    sellerLight: 'rgba(139, 92, 246, 0.1)',
    buyer: '#3B82F6',
    buyerLight: 'rgba(59, 130, 246, 0.1)',
    delivery: '#F59E0B',
    deliveryLight: 'rgba(245, 158, 11, 0.1)',
  },

  // Category colors
  category: {
    food: '#10B981',
    electronics: '#3B82F6',
    clothing: '#EC4899',
    furniture: '#F59E0B',
    other: '#6B7280',
  },

  // Order status colors
  orderStatus: {
    pending: '#F59E0B',
    confirmed: '#3B82F6',
    readyForPickup: '#8B5CF6',
    inDelivery: '#F97316',
    delivered: '#10B981',
    cancelled: '#EF4444',
  },

  // Tab bar
  tabBar: {
    background: '#FFFFFF',
    border: '#E4E4E7',
    active: '#10B981',
    inactive: '#71717A',
  },

  // Overlay
  overlay: {
    light: 'rgba(0, 0, 0, 0.05)',
    medium: 'rgba(0, 0, 0, 0.1)',
    dark: 'rgba(0, 0, 0, 0.5)',
  },
} as const;

export const darkColors = {
  // Background colors
  background: {
    primary: '#0A0A0B',
    secondary: '#1A1A1B',
    tertiary: '#2A2A2B',
    elevated: '#1F1F20',
  },

  // Surface colors for cards
  surface: {
    primary: '#1A1A1B',
    secondary: '#242428',
    tertiary: '#2E2E32',
  },

  // Text colors
  text: {
    primary: '#FFFFFF',
    secondary: '#A1A1AA',
    tertiary: '#71717A',
    muted: '#52525B',
    inverse: '#0A0A0B',
  },

  // Border colors
  border: {
    default: '#27272A',
    subtle: '#1F1F23',
    strong: '#3F3F46',
  },

  // Brand colors
  brand: {
    primary: '#10B981',
    primaryLight: '#34D399',
    primaryDark: '#059669',
    secondary: '#3B82F6',
  },

  // Status colors
  status: {
    success: '#10B981',
    successLight: 'rgba(16, 185, 129, 0.2)',
    warning: '#F59E0B',
    warningLight: 'rgba(245, 158, 11, 0.2)',
    error: '#EF4444',
    errorLight: 'rgba(239, 68, 68, 0.2)',
    info: '#3B82F6',
    infoLight: 'rgba(59, 130, 246, 0.2)',
  },

  // Role colors
  role: {
    seller: '#8B5CF6',
    sellerLight: 'rgba(139, 92, 246, 0.2)',
    buyer: '#3B82F6',
    buyerLight: 'rgba(59, 130, 246, 0.2)',
    delivery: '#F59E0B',
    deliveryLight: 'rgba(245, 158, 11, 0.2)',
  },

  // Category colors
  category: {
    food: '#10B981',
    electronics: '#3B82F6',
    clothing: '#EC4899',
    furniture: '#F59E0B',
    other: '#6B7280',
  },

  // Order status colors
  orderStatus: {
    pending: '#F59E0B',
    confirmed: '#3B82F6',
    readyForPickup: '#8B5CF6',
    inDelivery: '#F97316',
    delivered: '#10B981',
    cancelled: '#EF4444',
  },

  // Tab bar
  tabBar: {
    background: '#0A0A0B',
    border: '#1A1A1B',
    active: '#FFFFFF',
    inactive: '#6B7280',
  },

  // Overlay
  overlay: {
    light: 'rgba(255, 255, 255, 0.05)',
    medium: 'rgba(255, 255, 255, 0.1)',
    dark: 'rgba(0, 0, 0, 0.5)',
  },
} as const;

export type ThemeColors = typeof lightColors;
export type ColorScheme = 'light' | 'dark' | 'system';
