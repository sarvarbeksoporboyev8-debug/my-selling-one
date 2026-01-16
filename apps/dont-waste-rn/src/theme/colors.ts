/**
 * Premium dark theme color palette for Don't Waste app
 */

export const colors = {
  // Background colors
  background: {
    primary: '#0A0A0B',
    secondary: '#1A1A1B',
    tertiary: '#2A2A2B',
    elevated: '#1F1F20',
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
    primary: '#10B981', // Emerald
    primaryLight: '#34D399',
    primaryDark: '#059669',
    secondary: '#3B82F6', // Blue
  },

  // Status colors
  status: {
    // Expiry urgency levels
    expired: '#EF4444',
    expiringSoon: '#F59E0B', // 1-2 days
    expiringMedium: '#FBBF24', // 3-5 days
    fresh: '#10B981', // 5+ days

    // General status
    success: '#10B981',
    warning: '#F59E0B',
    error: '#EF4444',
    info: '#3B82F6',
  },

  // Category colors (with opacity variants)
  category: {
    dairy: {
      base: '#3B82F6',
      light: 'rgba(59, 130, 246, 0.2)',
    },
    fruits: {
      base: '#EF4444',
      light: 'rgba(239, 68, 68, 0.2)',
    },
    vegetables: {
      base: '#10B981',
      light: 'rgba(16, 185, 129, 0.2)',
    },
    meat: {
      base: '#F97316',
      light: 'rgba(249, 115, 22, 0.2)',
    },
    beverages: {
      base: '#8B5CF6',
      light: 'rgba(139, 92, 246, 0.2)',
    },
    grains: {
      base: '#F59E0B',
      light: 'rgba(245, 158, 11, 0.2)',
    },
    other: {
      base: '#6B7280',
      light: 'rgba(107, 114, 128, 0.2)',
    },
  },

  // Overlay colors
  overlay: {
    light: 'rgba(255, 255, 255, 0.05)',
    medium: 'rgba(255, 255, 255, 0.1)',
    dark: 'rgba(0, 0, 0, 0.5)',
  },
} as const;

export type Colors = typeof colors;
