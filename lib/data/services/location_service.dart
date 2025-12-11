/// Location Service - Smart Digital Tourism
/// Handles GPS location, geofencing, and distance calculations

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/config/app_constants.dart';

/// Current position provider
final currentPositionProvider =
    StateNotifierProvider<CurrentPositionNotifier, AsyncValue<Position>>((ref) {
      return CurrentPositionNotifier();
    });

/// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Current position state notifier
class CurrentPositionNotifier extends StateNotifier<AsyncValue<Position>> {
  StreamSubscription<Position>? _positionSubscription;

  CurrentPositionNotifier() : super(const AsyncValue.loading());

  /// Start tracking location
  Future<void> startTracking() async {
    try {
      // Check permission
      final hasPermission = await LocationService.checkAndRequestPermission();
      if (!hasPermission) {
        state = AsyncValue.error(
          'Location permission denied',
          StackTrace.current,
        );
        return;
      }

      // Get current position first
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      state = AsyncValue.data(position);

      // Start listening to position updates
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 50, // Update setiap 50 meter
              timeLimit: Duration(
                milliseconds: AppConstants.locationUpdateIntervalMs,
              ),
            ),
          ).listen(
            (position) {
              state = AsyncValue.data(position);
            },
            onError: (error) {
              state = AsyncValue.error(error, StackTrace.current);
            },
          );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Stop tracking location
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}

/// Location Service class
class LocationService {
  /// Check and request location permission
  static Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Calculate distance between two points in meters
  static double calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Check if a point is inside a polygon (Ray Casting Algorithm)
  /// Used for client-side geofencing when offline
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    int intersections = 0;
    final int n = polygon.length;

    for (int i = 0; i < n; i++) {
      final LatLng p1 = polygon[i];
      final LatLng p2 = polygon[(i + 1) % n];

      if (point.latitude > math.min(p1.latitude, p2.latitude) &&
          point.latitude <= math.max(p1.latitude, p2.latitude) &&
          point.longitude <= math.max(p1.longitude, p2.longitude)) {
        final double xIntersection =
            (point.latitude - p1.latitude) *
                (p2.longitude - p1.longitude) /
                (p2.latitude - p1.latitude) +
            p1.longitude;

        if (p1.longitude == p2.longitude || point.longitude <= xIntersection) {
          intersections++;
        }
      }
    }

    return intersections % 2 == 1;
  }

  /// Get bearing between two points
  static double getBearing(LatLng from, LatLng to) {
    final double lat1 = from.latitude * math.pi / 180;
    final double lat2 = to.latitude * math.pi / 180;
    final double dLon = (to.longitude - from.longitude) * math.pi / 180;

    final double y = math.sin(dLon) * math.cos(lat2);
    final double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final double bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  /// Format distance for display
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Get compass direction from bearing
  static String getDirectionFromBearing(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}
