import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Service for handling location, geocoding, and address resolution
class LocationService {
  static final LocationService _instance = LocationService._internal();

  LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  /// Get human-readable address from latitude and longitude
  static Future<Map<String, String>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Validate coordinates
      if (latitude == 0 || longitude == 0) {
        return _getUnknownLocation();
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return _getUnknownLocation();
      }

      final place = placemarks.first;

      // Build address with fallbacks
      final street = place.street ?? place.thoroughfare ?? '';
      final locality = place.locality ?? place.subAdministrativeArea ?? '';
      final country = place.country ?? '';

      // Build formatted address
      final parts = [
        street,
        locality,
        country,
      ].where((p) => p.isNotEmpty).toList();
      final formattedAddress = parts.join(', ');

      return {
        'address': formattedAddress.isNotEmpty
            ? formattedAddress
            : '$latitude, $longitude',
        'city': locality.isNotEmpty ? locality : 'Unknown',
        'country': country.isNotEmpty ? country : 'Unknown',
        'street': street.isNotEmpty ? street : 'Unknown',
        'postalCode': place.postalCode ?? 'Unknown',
        'administrativeArea': place.administrativeArea ?? 'Unknown',
      };
    } catch (e) {
      print(
        'Error getting address from coordinates ($latitude, $longitude): $e',
      );
      return _getUnknownLocation();
    }
  }

  /// Get unknown location response
  static Map<String, String> _getUnknownLocation() {
    return {
      'address': 'Location Unknown',
      'city': 'Unknown',
      'country': 'Unknown',
      'street': 'Unknown',
      'postalCode': 'Unknown',
      'administrativeArea': 'Unknown',
    };
  }

  /// Get coordinates from address
  static Future<Map<String, double>?> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        return null;
      }

      final location = locations.first;
      return {'latitude': location.latitude, 'longitude': location.longitude};
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  /// Get current user location
  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied ||
            result == LocationPermission.deniedForever) {
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {'latitude': position.latitude, 'longitude': position.longitude};
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Get current location with address details
  static Future<Map<String, dynamic>?> getCurrentLocationWithAddress() async {
    try {
      final coords = await getCurrentLocation();
      if (coords == null) return null;

      final address = await getAddressFromCoordinates(
        coords['latitude']!,
        coords['longitude']!,
      );

      return {
        'latitude': coords['latitude'],
        'longitude': coords['longitude'],
        ...address,
      };
    } catch (e) {
      print('Error getting location with address: $e');
      return null;
    }
  }

  /// Expose a position stream for live updates (wrapper around Geolocator)
  static Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    final settings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// Calculate distance between two coordinates in kilometers
  static Future<double> calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    try {
      final distanceInMeters = await Geolocator.distanceBetween(
        lat1,
        lon1,
        lat2,
        lon2,
      );

      return distanceInMeters / 1000; // Convert to kilometers
    } catch (e) {
      print('Error calculating distance: $e');
      return 0;
    }
  }

  /// Format address nicely
  static String formatAddress(Map<String, String> addressMap) {
    final street = addressMap['street'] ?? '';
    final city = addressMap['city'] ?? '';
    final country = addressMap['country'] ?? '';

    final parts = [street, city, country].where((s) => s.isNotEmpty).toList();
    return parts.join(', ');
  }

  /// Format coordinates as readable location
  static String formatCoordinates(double latitude, double longitude) {
    return '$latitude, $longitude';
  }

  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permission
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
