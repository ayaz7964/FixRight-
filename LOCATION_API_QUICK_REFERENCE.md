# Quick Reference: Location System API

## 🎯 Quick Start

### Import LocationService
```dart
import '../../services/location_service.dart';
```

---

## 📍 Core Methods

### 1. Get Address from Coordinates
```dart
// Converts latitude/longitude to readable address
final address = await LocationService.getAddressFromCoordinates(
  27.7243556,  // latitude
  68.8220514,  // longitude
);

// Returns:
// {
//   'address': '123 Main St, Sukkur, Pakistan',
//   'city': 'Sukkur',
//   'country': 'Pakistan',
//   'street': '123 Main St',
//   'postalCode': '65200',
//   'administrativeArea': 'Sindh'
// }
```

### 2. Get Coordinates from Address
```dart
// Converts address text to latitude/longitude
final coords = await LocationService.getCoordinatesFromAddress(
  'Sukkur, Pakistan'
);

// Returns:
// {
//   'latitude': 27.7243556,
//   'longitude': 68.8220514
// }
```

### 3. Get Current User Location
```dart
// Gets user's current GPS location with permission handling
final location = await LocationService.getCurrentLocation();

// Returns:
// {
//   'latitude': 27.7243556,
//   'longitude': 68.8220514
// }
```

### 4. Calculate Distance
```dart
// Calculates distance between two points in kilometers
final distance = await LocationService.calculateDistance(
  27.7243556,  // from latitude
  68.8220514,  // from longitude
  27.7300000,  // to latitude
  68.8300000,  // to longitude
);

// Returns: 0.75 (km)
```

### 5. Format Address
```dart
// Formats address details into readable string
final formatted = LocationService.formatAddress({
  'street': '123 Main St',
  'city': 'Sukkur',
  'country': 'Pakistan',
});

// Returns: '123 Main St, Sukkur, Pakistan'
```

### 6. Format Coordinates
```dart
// Formats coordinates nicely
final formatted = LocationService.formatCoordinates(
  27.7243556,  // latitude
  68.8220514,  // longitude
);

// Returns: '27.7243556, 68.8220514'
```

---

## 🗺️ Using LocationMapScreen

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LocationMapScreen(
      latitude: 27.7243556,
      longitude: 68.8220514,
      userName: 'Ahmed Malik',
      userRole: 'seller',  // 'seller' or 'buyer'
      address: '123 Main St, Sukkur, Pakistan',
      phoneUID: 'user_phone_uid',
    ),
  ),
);
```

---

## 📋 Using SellerDirectoryScreen

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SellerDirectoryScreen(
      phoneUID: UserSession().phoneUID,
    ),
  ),
);
```

---

## 🔍 Common Use Cases

### Load User Profile with Location
```dart
Future<void> _loadUserProfile() async {
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(phoneUID)
      .get();
  
  final data = userDoc.data();
  final lat = (data?['latitude'] ?? 0).toDouble();
  final lng = (data?['longitude'] ?? 0).toDouble();
  
  // Geocode to get readable address
  if (lat != 0 && lng != 0) {
    final locationDetails = 
        await LocationService.getAddressFromCoordinates(lat, lng);
    final city = locationDetails['city'];
    final country = locationDetails['country'];
    final address = LocationService.formatAddress(locationDetails);
  }
}
```

### Display Sellers Sorted by Distance
```dart
Future<void> _loadSellers() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('Role', isEqualTo: 'Seller')
      .get();
  
  final sellers = [];
  for (var doc in snapshot.docs) {
    final data = doc.data();
    final distance = await LocationService.calculateDistance(
      myLat, myLng,
      data['latitude'], data['longitude'],
    );
    
    sellers.add({
      ...data,
      'distance': distance,
    });
  }
  
  // Sort by distance
  sellers.sort((a, b) => a['distance'].compareTo(b['distance']));
}
```

### Handle Location Permissions
```dart
try {
  final location = await LocationService.getCurrentLocation();
  // Use location
} on Exception catch (e) {
  if (e.toString().contains('Permission')) {
    // User denied permission
    showPermissionDialog();
  } else {
    // Other error
    showErrorMessage(e.toString());
  }
}
```

---

## ⚠️ Error Handling

```dart
// All methods return meaningful data on error:

// Method returns Map with 'Unknown' values
final address = await LocationService.getAddressFromCoordinates(0, 0);
// {'city': 'Unknown', 'country': 'Unknown', ...}

// Method returns null on error
final coords = await LocationService.getCoordinatesFromAddress('invalid');
// null

// Method throws exception
try {
  await LocationService.getCurrentLocation();
} catch (e) {
  print('Location error: $e');
  // Handle error gracefully
}
```

---

## 🎨 UI Components

### Show Location Info
```dart
Card(
  child: Column(
    children: [
      Text('📍 ${locationDetails['address']}'),
      Text('🏙️ ${locationDetails['city']}'),
      Text('🌍 ${locationDetails['country']}'),
      ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationMapScreen(...),
          ),
        ),
        icon: Icon(Icons.map),
        label: Text('View on Map'),
      ),
    ],
  ),
)
```

### Show Distance Badge
```dart
Chip(
  label: Text(
    distance < 1 
      ? '${(distance * 1000).toStringAsFixed(0)} m'
      : '${distance.toStringAsFixed(2)} km',
  ),
  avatar: Icon(Icons.location_on),
)
```

---

## 📊 Data Flow

```
Firebase (lat, lng)
    ↓
LocationService.getAddressFromCoordinates()
    ↓
Geocoding API (converts to address)
    ↓
Returns: {city, country, address, ...}
    ↓
Display in UI
    ↓
User taps "View on Map"
    ↓
LocationMapScreen displays
    ↓
User chooses: Google Maps / Apple Maps / Copy
```

---

## 🔧 Configuration

### Add Dependencies (already added)
```yaml
dependencies:
  geolocator: ^10.1.0
  geocoding: ^3.0.0
  url_launcher: ^6.2.0
```

### Add Google Maps API Key
In `LocationMapScreen.dart` line ~120:
```dart
'&key=YOUR_GOOGLE_MAPS_API_KEY'
```

### Add Permissions

**Android** (`android/app/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby sellers</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to find nearby sellers</string>
```

---

## 🧪 Testing

### Test Geocoding
```dart
// Should work with real coordinates
final address = await LocationService.getAddressFromCoordinates(
  27.7243556,  // Sukkur, Pakistan
  68.8220514,
);
expect(address['city'], 'Sukkur');
expect(address['country'], 'Pakistan');
```

### Test Distance Calculation
```dart
// Sukkur to nearby location
final distance = await LocationService.calculateDistance(
  27.7243556, 68.8220514,  // Sukkur
  27.7300000, 68.8300000,  // Nearby
);
expect(distance, greaterThan(0));
expect(distance, lessThan(10));  // Should be < 10 km
```

---

## 📚 File Locations

- **LocationService**: `lib/services/location_service.dart`
- **LocationMapScreen**: `lib/src/pages/LocationMapScreen.dart`
- **SellerDirectoryScreen**: `lib/src/pages/SellerDirectoryScreen.dart`
- **Docs**: 
  - `GOOGLE_MAPS_SETUP.md`
  - `LOCATION_IMPLEMENTATION_GUIDE.md`
  - `PROFESSIONAL_LOCATION_IMPLEMENTATION_SUMMARY.md`

---

## 💡 Tips & Tricks

1. **Cache location data** to avoid repeated API calls
2. **Validate coordinates** before using (check if not 0,0)
3. **Use error boundaries** in UI to prevent crashes
4. **Handle permission denial** gracefully
5. **Show loading states** for async operations
6. **Retry failed operations** with user confirmation
7. **Use static maps** for preview before opening full maps
8. **Format data** before display for better UX

---

**Last Updated**: 2026-01-17
**Status**: Production Ready ✅
