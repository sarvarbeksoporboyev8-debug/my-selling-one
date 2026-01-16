import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

export type UserRole = 'buyer' | 'seller' | 'delivery';

export type User = {
  id: string;
  name: string;
  email: string;
  phone?: string;
  avatarUrl?: string;
  role: UserRole;
  isVerified: boolean;
  rating?: number;
  reviewCount?: number;
  // Seller specific
  storeName?: string;
  storeDescription?: string;
  // Delivery specific
  vehicleType?: string;
  licensePlate?: string;
  totalDeliveries?: number;
  earnings?: number;
};

type AuthContextType = {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (name: string, email: string, password: string, role: UserRole) => Promise<void>;
  logout: () => Promise<void>;
  updateUser: (updates: Partial<User>) => Promise<void>;
  switchRole: (role: UserRole) => Promise<void>;
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const AUTH_STORAGE_KEY = '@dont_waste_auth';

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Load saved auth state
  useEffect(() => {
    AsyncStorage.getItem(AUTH_STORAGE_KEY).then((saved) => {
      if (saved) {
        try {
          setUser(JSON.parse(saved));
        } catch (e) {
          // Invalid data
        }
      }
      setIsLoading(false);
    });
  }, []);

  const login = async (email: string, password: string) => {
    // Mock login - replace with actual API call
    setIsLoading(true);
    await new Promise((resolve) => setTimeout(resolve, 1000));

    const mockUser: User = {
      id: '1',
      name: 'John Doe',
      email,
      role: 'buyer',
      isVerified: true,
      rating: 4.8,
      reviewCount: 24,
    };

    setUser(mockUser);
    await AsyncStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(mockUser));
    setIsLoading(false);
  };

  const register = async (name: string, email: string, password: string, role: UserRole) => {
    setIsLoading(true);
    await new Promise((resolve) => setTimeout(resolve, 1000));

    const mockUser: User = {
      id: Date.now().toString(),
      name,
      email,
      role,
      isVerified: false,
      rating: 0,
      reviewCount: 0,
    };

    setUser(mockUser);
    await AsyncStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(mockUser));
    setIsLoading(false);
  };

  const logout = async () => {
    setUser(null);
    await AsyncStorage.removeItem(AUTH_STORAGE_KEY);
  };

  const updateUser = async (updates: Partial<User>) => {
    if (!user) return;
    const updatedUser = { ...user, ...updates };
    setUser(updatedUser);
    await AsyncStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(updatedUser));
  };

  const switchRole = async (role: UserRole) => {
    if (!user) return;
    await updateUser({ role });
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isLoading,
        isAuthenticated: !!user,
        login,
        register,
        logout,
        updateUser,
        switchRole,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
