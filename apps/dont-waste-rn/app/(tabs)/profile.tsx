import { View, Text, ScrollView, TouchableOpacity, Switch } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme, useAuth, ColorScheme } from '../../src/contexts';
import {
  User,
  Moon,
  Sun,
  Monitor,
  Bell,
  Shield,
  HelpCircle,
  LogOut,
  ChevronRight,
  Star,
  Package,
  Truck,
  ShoppingBag,
  Check,
} from 'lucide-react-native';
import { useState } from 'react';

type MenuItemProps = {
  icon: React.ReactNode;
  title: string;
  subtitle?: string;
  onPress?: () => void;
  rightElement?: React.ReactNode;
  colors: ReturnType<typeof useTheme>['colors'];
};

function MenuItem({ icon, title, subtitle, onPress, rightElement, colors }: MenuItemProps) {
  return (
    <TouchableOpacity
      onPress={onPress}
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        paddingVertical: 14,
        borderBottomWidth: 1,
        borderBottomColor: colors.border.subtle,
      }}
    >
      <View
        style={{
          width: 40,
          height: 40,
          borderRadius: 20,
          backgroundColor: colors.surface.secondary,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        {icon}
      </View>
      <View style={{ flex: 1, marginLeft: 12 }}>
        <Text style={{ color: colors.text.primary, fontSize: 16, fontWeight: '500' }}>{title}</Text>
        {subtitle && (
          <Text style={{ color: colors.text.tertiary, fontSize: 13, marginTop: 2 }}>{subtitle}</Text>
        )}
      </View>
      {rightElement || <ChevronRight size={20} color={colors.text.tertiary} />}
    </TouchableOpacity>
  );
}

export default function ProfileScreen() {
  const { colors, colorScheme, setColorScheme, isDark } = useTheme();
  const { user, logout, switchRole } = useAuth();
  const [showThemeOptions, setShowThemeOptions] = useState(false);
  const [showRoleOptions, setShowRoleOptions] = useState(false);

  const role = user?.role || 'buyer';

  const themeOptions: { key: ColorScheme; label: string; icon: React.ReactNode }[] = [
    { key: 'light', label: 'Light', icon: <Sun size={18} color={colors.text.secondary} /> },
    { key: 'dark', label: 'Dark', icon: <Moon size={18} color={colors.text.secondary} /> },
    { key: 'system', label: 'System', icon: <Monitor size={18} color={colors.text.secondary} /> },
  ];

  const roleOptions: { key: 'buyer' | 'seller' | 'delivery'; label: string; icon: React.ReactNode; color: string }[] = [
    { key: 'buyer', label: 'Buyer', icon: <ShoppingBag size={18} color={colors.role.buyer} />, color: colors.role.buyer },
    { key: 'seller', label: 'Seller', icon: <Package size={18} color={colors.role.seller} />, color: colors.role.seller },
    { key: 'delivery', label: 'Delivery', icon: <Truck size={18} color={colors.role.delivery} />, color: colors.role.delivery },
  ];

  const getRoleColor = () => {
    switch (role) {
      case 'seller':
        return colors.role.seller;
      case 'delivery':
        return colors.role.delivery;
      default:
        return colors.role.buyer;
    }
  };

  const getRoleBgColor = () => {
    switch (role) {
      case 'seller':
        return colors.role.sellerLight;
      case 'delivery':
        return colors.role.deliveryLight;
      default:
        return colors.role.buyerLight;
    }
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background.primary }}>
      <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={{ paddingHorizontal: 16, paddingTop: 16 }}>
          <Text style={{ color: colors.text.primary, fontSize: 28, fontWeight: '700' }}>Profile</Text>
        </View>

        {/* Profile Card */}
        <View
          style={{
            marginHorizontal: 16,
            marginTop: 20,
            backgroundColor: colors.surface.primary,
            borderRadius: 20,
            padding: 20,
            borderWidth: 1,
            borderColor: colors.border.default,
          }}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center' }}>
            <View
              style={{
                width: 72,
                height: 72,
                borderRadius: 36,
                backgroundColor: getRoleBgColor(),
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Text style={{ color: getRoleColor(), fontSize: 28, fontWeight: '700' }}>
                {user?.name?.charAt(0) || 'U'}
              </Text>
            </View>
            <View style={{ flex: 1, marginLeft: 16 }}>
              <Text style={{ color: colors.text.primary, fontSize: 20, fontWeight: '600' }}>
                {user?.name || 'Guest User'}
              </Text>
              <Text style={{ color: colors.text.tertiary, marginTop: 4 }}>
                {user?.email || 'Sign in to continue'}
              </Text>
              <View
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  marginTop: 8,
                  backgroundColor: getRoleBgColor(),
                  paddingHorizontal: 10,
                  paddingVertical: 4,
                  borderRadius: 12,
                  alignSelf: 'flex-start',
                }}
              >
                {role === 'seller' && <Package size={14} color={getRoleColor()} />}
                {role === 'delivery' && <Truck size={14} color={getRoleColor()} />}
                {role === 'buyer' && <ShoppingBag size={14} color={getRoleColor()} />}
                <Text style={{ color: getRoleColor(), marginLeft: 6, fontWeight: '600', fontSize: 12 }}>
                  {role.charAt(0).toUpperCase() + role.slice(1)}
                </Text>
              </View>
            </View>
          </View>

          {/* Stats */}
          <View
            style={{
              flexDirection: 'row',
              marginTop: 20,
              paddingTop: 20,
              borderTopWidth: 1,
              borderTopColor: colors.border.subtle,
            }}
          >
            <View style={{ flex: 1, alignItems: 'center' }}>
              <Text style={{ color: colors.text.primary, fontSize: 20, fontWeight: '700' }}>
                {role === 'delivery' ? '156' : role === 'seller' ? '48' : '24'}
              </Text>
              <Text style={{ color: colors.text.tertiary, fontSize: 12, marginTop: 4 }}>
                {role === 'delivery' ? 'Deliveries' : role === 'seller' ? 'Sales' : 'Orders'}
              </Text>
            </View>
            <View style={{ width: 1, backgroundColor: colors.border.subtle }} />
            <View style={{ flex: 1, alignItems: 'center' }}>
              <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                <Star size={16} color="#F59E0B" fill="#F59E0B" />
                <Text style={{ color: colors.text.primary, fontSize: 20, fontWeight: '700', marginLeft: 4 }}>
                  4.9
                </Text>
              </View>
              <Text style={{ color: colors.text.tertiary, fontSize: 12, marginTop: 4 }}>Rating</Text>
            </View>
            <View style={{ width: 1, backgroundColor: colors.border.subtle }} />
            <View style={{ flex: 1, alignItems: 'center' }}>
              <Text style={{ color: colors.text.primary, fontSize: 20, fontWeight: '700' }}>
                {role === 'delivery' ? '$1.2k' : role === 'seller' ? '$3.4k' : '$890'}
              </Text>
              <Text style={{ color: colors.text.tertiary, fontSize: 12, marginTop: 4 }}>
                {role === 'delivery' ? 'Earned' : role === 'seller' ? 'Revenue' : 'Saved'}
              </Text>
            </View>
          </View>
        </View>

        {/* Switch Role */}
        <View style={{ paddingHorizontal: 16, marginTop: 24 }}>
          <Text style={{ color: colors.text.tertiary, fontSize: 12, fontWeight: '600', marginBottom: 12 }}>
            SWITCH ROLE
          </Text>
          <View
            style={{
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              borderWidth: 1,
              borderColor: colors.border.default,
              overflow: 'hidden',
            }}
          >
            {roleOptions.map((option, index) => (
              <TouchableOpacity
                key={option.key}
                onPress={() => switchRole(option.key)}
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  padding: 16,
                  borderBottomWidth: index < roleOptions.length - 1 ? 1 : 0,
                  borderBottomColor: colors.border.subtle,
                  backgroundColor: role === option.key ? `${option.color}10` : 'transparent',
                }}
              >
                <View
                  style={{
                    width: 40,
                    height: 40,
                    borderRadius: 20,
                    backgroundColor: `${option.color}20`,
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  {option.icon}
                </View>
                <Text
                  style={{
                    flex: 1,
                    marginLeft: 12,
                    color: role === option.key ? option.color : colors.text.primary,
                    fontWeight: role === option.key ? '600' : '400',
                    fontSize: 16,
                  }}
                >
                  {option.label}
                </Text>
                {role === option.key && <Check size={20} color={option.color} />}
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Appearance */}
        <View style={{ paddingHorizontal: 16, marginTop: 24 }}>
          <Text style={{ color: colors.text.tertiary, fontSize: 12, fontWeight: '600', marginBottom: 12 }}>
            APPEARANCE
          </Text>
          <View
            style={{
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              borderWidth: 1,
              borderColor: colors.border.default,
              overflow: 'hidden',
            }}
          >
            {themeOptions.map((option, index) => (
              <TouchableOpacity
                key={option.key}
                onPress={() => setColorScheme(option.key)}
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  padding: 16,
                  borderBottomWidth: index < themeOptions.length - 1 ? 1 : 0,
                  borderBottomColor: colors.border.subtle,
                  backgroundColor: colorScheme === option.key ? colors.brand.primary + '10' : 'transparent',
                }}
              >
                <View
                  style={{
                    width: 40,
                    height: 40,
                    borderRadius: 20,
                    backgroundColor: colors.surface.secondary,
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  {option.icon}
                </View>
                <Text
                  style={{
                    flex: 1,
                    marginLeft: 12,
                    color: colorScheme === option.key ? colors.brand.primary : colors.text.primary,
                    fontWeight: colorScheme === option.key ? '600' : '400',
                    fontSize: 16,
                  }}
                >
                  {option.label}
                </Text>
                {colorScheme === option.key && <Check size={20} color={colors.brand.primary} />}
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Settings */}
        <View style={{ paddingHorizontal: 16, marginTop: 24 }}>
          <Text style={{ color: colors.text.tertiary, fontSize: 12, fontWeight: '600', marginBottom: 12 }}>
            SETTINGS
          </Text>
          <View
            style={{
              backgroundColor: colors.surface.primary,
              borderRadius: 16,
              paddingHorizontal: 16,
              borderWidth: 1,
              borderColor: colors.border.default,
            }}
          >
            <MenuItem
              icon={<Bell size={20} color={colors.text.secondary} />}
              title="Notifications"
              subtitle="Manage alerts and sounds"
              colors={colors}
            />
            <MenuItem
              icon={<Shield size={20} color={colors.text.secondary} />}
              title="Privacy & Security"
              subtitle="Password, 2FA, data"
              colors={colors}
            />
            <MenuItem
              icon={<HelpCircle size={20} color={colors.text.secondary} />}
              title="Help & Support"
              subtitle="FAQ, contact us"
              colors={colors}
            />
          </View>
        </View>

        {/* Logout */}
        <View style={{ paddingHorizontal: 16, marginTop: 24, marginBottom: 120 }}>
          <TouchableOpacity
            onPress={logout}
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: colors.status.errorLight,
              paddingVertical: 16,
              borderRadius: 12,
            }}
          >
            <LogOut size={20} color={colors.status.error} />
            <Text style={{ color: colors.status.error, marginLeft: 8, fontWeight: '600', fontSize: 16 }}>
              Sign Out
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
