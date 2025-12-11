/// Environment Configuration - Smart Digital Tourism
/// Flexible configuration for Supabase credentials
///
/// IMPORTANT: Untuk production, gunakan environment variables atau .env file
library;

class EnvConfig {
  EnvConfig._();

  // Supabase Configuration
  // TODO: Ganti dengan kredensial Anda
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ndxsbvkwjgteqbsavyml.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5keHNidmt3amd0ZXFic2F2eW1sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU0NDI5MjUsImV4cCI6MjA4MTAxODkyNX0.XczXNaRE9ueba8a0Tale6kK0Y6UMqUg09_dVcTuOCSI',
  );

  // Backend API Configuration (Node.js - separate project)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api',
  );

  // Map Tile Server (OpenStreetMap for development)
  static const String mapTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Firebase Configuration
  // Akan otomatis terkonfigurasi via google-services.json / GoogleService-Info.plist
}
