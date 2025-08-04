# Google API Setup for BusUI

This document explains how the Google API is configured in your Flutter bus application.

## Current Configuration

### 1. Google Maps API Key
- **API Key**: `AIzaSyB1Rx7qJcw0_jWH0p5rVP6mfNmCjjWIClY`
- **Project ID**: `yemenbus-2c9e3`
- **Project Number**: `1051040199369`

### 2. Android Configuration
The Google Maps API key is configured in:
- `android/app/src/main/AndroidManifest.xml` - API key meta-data
- `android/app/google-services.json` - Firebase configuration

### 3. Permissions Added
The following permissions are required for Google Maps functionality:
- `INTERNET` - For map tiles and API calls
- `ACCESS_FINE_LOCATION` - For precise location
- `ACCESS_COARSE_LOCATION` - For approximate location

## Files Created/Modified

### Core Files
1. **`lib/core/constants.dart`** - Centralized API configuration
2. **`lib/core/services/maps_service.dart`** - Maps functionality service
3. **`lib/core/widgets/map_widget.dart`** - Reusable map widget
4. **`lib/features/home/map_screen.dart`** - Sample map screen

### Android Configuration
1. **`android/app/src/main/AndroidManifest.xml`** - Added API key and permissions
2. **`android/app/google-services.json`** - Firebase configuration (already existed)

## How to Use

### 1. Basic Map Widget
```dart
import 'package:your_app/core/widgets/map_widget.dart';

BusMapWidget(
  initialLatitude: 24.7136,
  initialLongitude: 46.6753,
  initialZoom: 12.0,
  onMapTap: (location) {
    print('Tapped at: ${location.latitude}, ${location.longitude}');
  },
)
```

### 2. Maps Service
```dart
import 'package:your_app/core/services/maps_service.dart';

// Get current location
Position? position = await MapsService.getCurrentLocation();

// Create camera position
CameraPosition cameraPosition = MapsService.createCameraPosition(
  latitude, 
  longitude, 
  zoom: 15.0
);

// Calculate distance
double distance = MapsService.calculateDistance(
  startLat, startLng, endLat, endLng
);
```

### 3. Constants
```dart
import 'package:your_app/core/constants.dart';

String apiKey = AppConstants.googleMapsApiKey;
String appName = AppConstants.appName;
```

## API Key Security

⚠️ **Important**: The current API key is exposed in the code. For production:

1. **Use environment variables** or **secure storage**
2. **Restrict API key** in Google Cloud Console
3. **Enable billing** for Google Maps API
4. **Set up API quotas** to prevent abuse

## Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `yemenbus-2c9e3`
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API (if needed)
   - Directions API (if needed)
4. Set up billing
5. Configure API restrictions

## Testing

To test the Google Maps integration:

1. Run the app: `flutter run`
2. Navigate to the map screen
3. Grant location permissions when prompted
4. Test map interactions (tap, zoom, pan)

## Troubleshooting

### Common Issues:

1. **Map not loading**: Check internet connection and API key
2. **Location not working**: Ensure location permissions are granted
3. **API key errors**: Verify the key is correct and APIs are enabled
4. **Billing issues**: Set up billing in Google Cloud Console

### Debug Commands:
```bash
flutter clean
flutter pub get
flutter run --verbose
```

## Next Steps

1. **Add route planning** using Directions API
2. **Implement bus stop markers** with real data
3. **Add real-time tracking** features
4. **Integrate with backend** for bus schedules
5. **Add offline map support**

## Support

For Google Maps API issues, refer to:
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Google Cloud Console](https://console.cloud.google.com/)