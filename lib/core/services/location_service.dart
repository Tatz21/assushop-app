import 'dart:math';

class LocationService {
  LocationService._();

  static const double earthRadiusMeters = 6371000.0;
  static const double defaultGeofenceThresholdMeters = 100.0;

  /// Haversine Formula for distance between two points in meters
  static double calculateDistanceInMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _degToRad(double degrees) {
    return degrees * (pi / 180.0);
  }

  /// Evaluates whether location is within valid geofence radius (<= 100m by default)
  static bool isWithinGeofence({
    required double distanceMeters,
    double thresholdMeters = defaultGeofenceThresholdMeters,
  }) {
    return distanceMeters <= thresholdMeters;
  }

  /// Calculates offset coordinates given a distance in meters and bearing
  static (double lat, double lng) calculateSimulatedCoordinate({
    required double originLat,
    required double originLng,
    required double distanceMeters,
    double bearingDegrees = 45.0,
  }) {
    final double distRatio = distanceMeters / earthRadiusMeters;
    final double bearingRad = _degToRad(bearingDegrees);
    final double lat1Rad = _degToRad(originLat);
    final double lon1Rad = _degToRad(originLng);

    final double lat2Rad = asin(sin(lat1Rad) * cos(distRatio) +
        cos(lat1Rad) * sin(distRatio) * cos(bearingRad));

    final double lon2Rad = lon1Rad +
        atan2(sin(bearingRad) * sin(distRatio) * cos(lat1Rad),
            cos(distRatio) - sin(lat1Rad) * sin(lat2Rad));

    return (lat2Rad * (180.0 / pi), lon2Rad * (180.0 / pi));
  }

  /// Verifies mock location flags
  static bool verifyAntiMock({
    required bool isMockProvider,
    required double accuracyMeters,
  }) {
    // If Android reports mock location or accuracy is unrealistically 0.0 or > 200m
    if (isMockProvider) return false;
    if (accuracyMeters <= 0.0 || accuracyMeters > 150.0) return false;
    return true;
  }
}
