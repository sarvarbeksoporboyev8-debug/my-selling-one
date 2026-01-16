# Don't Waste - React Native App

Food expiry tracking app built with Expo SDK 54, Expo Router, and NativeWind.

## Stack

- **Expo SDK 54** - React Native framework
- **Expo Router v6** - File-based navigation with typed routes
- **NativeWind v4** - Tailwind CSS for React Native
- **TypeScript** - Type safety
- **Lucide React Native** - Icons

## Project Structure

```
app/                    # Expo Router file-based routes
  _layout.tsx           # Root layout with Stack navigator
  (tabs)/               # Tab navigation group
    _layout.tsx         # Tab bar configuration
    index.tsx           # Home screen
    search.tsx          # Search screen
    add.tsx             # Add item screen
    notifications.tsx   # Notifications screen
    profile.tsx         # Profile screen

src/
  components/           # Reusable UI components
    ui/                 # Base UI primitives (Card, Badge, Button)
    FoodItemCard.tsx    # Food item display component
    StatCard.tsx        # Statistics card component
  theme/                # Design tokens
    colors.ts           # Color palette
    spacing.ts          # Spacing and radius scales
    typography.ts       # Font sizes and text styles
```

## Development

```bash
# Install dependencies
npm install

# Start development server
npx expo start

# Run on web
npx expo start --web

# Run on iOS simulator
npx expo start --ios

# Run on Android emulator
npx expo start --android
```

## Building

```bash
# Build preview APK (Android)
npm run build:android

# Build preview IPA (iOS)
npm run build:ios

# Export static web build
npx expo export --platform web
```

## Design System

The app uses a dark theme with the following key colors:

- Background: `#0A0A0B`
- Surface: `#1A1A1B`
- Brand (emerald): `#10B981`
- Text primary: `#FFFFFF`
- Text secondary: `#A1A1AA`

Expiry status colors:
- Fresh (5+ days): Emerald
- Medium (3-5 days): Amber
- Soon (1-2 days): Amber/Red
- Expired: Red
