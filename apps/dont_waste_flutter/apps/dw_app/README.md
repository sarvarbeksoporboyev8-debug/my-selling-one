# Don't Waste - Flutter App

B2B surplus food marketplace mobile application.

## Architecture

```
lib/
├── main.dart              # App entry point
├── providers/             # Riverpod state management
│   ├── api_provider.dart
│   ├── auth_provider.dart
│   ├── filters_provider.dart
│   ├── listings_provider.dart
│   ├── location_provider.dart
│   ├── reservations_provider.dart
│   └── watchlist_provider.dart
├── routing/               # go_router navigation
│   ├── app_router.dart
│   └── app_routes.dart
└── screens/               # UI screens
    ├── auth/              # Login, Register, Onboarding
    ├── discover/          # Browse listings
    ├── home/              # Home feed
    ├── listing/           # Detail, Reserve, Offer
    ├── map/               # Map view with clustering
    ├── profile/           # User profile, settings
    ├── reservations/      # User reservations
    ├── search/            # Search and filters
    ├── seller/            # Seller listing management
    └── watchlist/         # Saved items
```

## Dependencies

- **State Management**: flutter_riverpod
- **Navigation**: go_router
- **Maps**: flutter_map, flutter_map_marker_cluster
- **Storage**: hive_flutter, flutter_secure_storage
- **Location**: geolocator, geocoding

## Running

```bash
# From monorepo root
melos bootstrap
melos run build_runner

# Run app
cd apps/dw_app
flutter run
```

## Testing

```bash
flutter test
```
