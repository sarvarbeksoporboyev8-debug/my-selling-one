import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useColorScheme } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { lightColors, darkColors, ColorScheme } from '../theme/colors';

// Use a union type for colors that works with both themes
type ThemeColors = typeof lightColors | typeof darkColors;

type ThemeContextType = {
  colors: ThemeColors;
  colorScheme: ColorScheme;
  isDark: boolean;
  setColorScheme: (scheme: ColorScheme) => void;
};

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

const THEME_STORAGE_KEY = '@dont_waste_theme';

export function ThemeProvider({ children }: { children: ReactNode }) {
  const systemColorScheme = useColorScheme();
  const [colorScheme, setColorSchemeState] = useState<ColorScheme>('system');
  const [isLoaded, setIsLoaded] = useState(false);

  // Load saved theme preference
  useEffect(() => {
    AsyncStorage.getItem(THEME_STORAGE_KEY).then((saved) => {
      if (saved && ['light', 'dark', 'system'].includes(saved)) {
        setColorSchemeState(saved as ColorScheme);
      }
      setIsLoaded(true);
    });
  }, []);

  // Save theme preference
  const setColorScheme = (scheme: ColorScheme) => {
    setColorSchemeState(scheme);
    AsyncStorage.setItem(THEME_STORAGE_KEY, scheme);
  };

  // Determine actual theme
  const isDark =
    colorScheme === 'system' ? systemColorScheme === 'dark' : colorScheme === 'dark';

  const colors = isDark ? darkColors : lightColors;

  if (!isLoaded) {
    return null; // Or a loading screen
  }

  return (
    <ThemeContext.Provider value={{ colors, colorScheme, isDark, setColorScheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
}
