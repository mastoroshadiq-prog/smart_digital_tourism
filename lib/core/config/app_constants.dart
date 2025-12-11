/// App Constants - Smart Digital Tourism
/// Konfigurasi aplikasi yang dapat disesuaikan

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'DesaExplore';
  static const String appVersion = '1.0.0';

  // Geofencing Settings
  static const double nearbyRadiusMeters = 5000; // 5 KM untuk fitur nearby
  static const int locationUpdateIntervalMs = 10000; // 10 detik

  // API Settings
  static const Duration apiTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Cache Settings
  static const Duration cacheExpiry = Duration(hours: 24);

  // Map Settings
  static const double defaultZoom = 14.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 5.0;
}
