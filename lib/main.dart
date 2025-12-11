/// Smart Digital Tourism - Main Entry Point
/// DesaExplore: Aplikasi Pariwisata Desa dengan Geofencing

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await StorageService.initialize();

  // Initialize Supabase
  await initializeSupabase();

  runApp(const ProviderScope(child: App()));
}
