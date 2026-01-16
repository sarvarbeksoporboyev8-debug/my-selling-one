/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./App.{js,jsx,ts,tsx}",
    "./app/**/*.{js,jsx,ts,tsx}",
    "./src/**/*.{js,jsx,ts,tsx}",
    "./components/**/*.{js,jsx,ts,tsx}",
  ],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        // Premium dark theme backgrounds
        background: {
          DEFAULT: '#0A0A0B',
          secondary: '#1A1A1B',
          tertiary: '#2A2A2B',
          elevated: '#1F1F20',
        },
        // Surface colors for cards and containers
        surface: {
          DEFAULT: '#1A1A1B',
          secondary: '#242428',
          tertiary: '#2E2E32',
        },
        // Border colors
        border: {
          DEFAULT: '#27272A',
          subtle: '#1F1F23',
          strong: '#3F3F46',
        },
        // Text colors
        text: {
          primary: '#FFFFFF',
          secondary: '#A1A1AA',
          tertiary: '#71717A',
          muted: '#52525B',
          inverse: '#0A0A0B',
        },
        // Brand colors
        brand: {
          DEFAULT: '#10B981',
          light: '#34D399',
          dark: '#059669',
        },
        // Status colors - expiry urgency
        expired: '#EF4444',
        expiring: {
          soon: '#F59E0B',
          medium: '#FBBF24',
        },
        fresh: '#10B981',
        // General status
        success: {
          DEFAULT: '#10B981',
          light: 'rgba(16, 185, 129, 0.2)',
        },
        warning: {
          DEFAULT: '#F59E0B',
          light: 'rgba(245, 158, 11, 0.2)',
        },
        error: {
          DEFAULT: '#EF4444',
          light: 'rgba(239, 68, 68, 0.2)',
        },
        info: {
          DEFAULT: '#3B82F6',
          light: 'rgba(59, 130, 246, 0.2)',
        },
        // Category colors
        category: {
          dairy: '#3B82F6',
          fruits: '#EF4444',
          vegetables: '#10B981',
          meat: '#F97316',
          beverages: '#8B5CF6',
          grains: '#F59E0B',
          other: '#6B7280',
        },
      },
      borderRadius: {
        'sm': '4px',
        'md': '8px',
        'lg': '12px',
        'xl': '16px',
        '2xl': '20px',
        '3xl': '24px',
      },
      spacing: {
        '18': '4.5rem',
        '22': '5.5rem',
      },
      fontFamily: {
        sans: ['System', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
      },
      fontSize: {
        'xs': ['10px', { lineHeight: '1.4' }],
        'sm': ['12px', { lineHeight: '1.5' }],
        'base': ['14px', { lineHeight: '1.5' }],
        'md': ['16px', { lineHeight: '1.5' }],
        'lg': ['18px', { lineHeight: '1.4' }],
        'xl': ['20px', { lineHeight: '1.3' }],
        '2xl': ['24px', { lineHeight: '1.25' }],
        '3xl': ['30px', { lineHeight: '1.2' }],
        '4xl': ['36px', { lineHeight: '1.1' }],
      },
    },
  },
  plugins: [],
};
