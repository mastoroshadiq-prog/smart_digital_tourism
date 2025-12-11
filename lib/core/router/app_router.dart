/// App Router - Smart Digital Tourism
/// Navigation configuration using GoRouter

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/village/village_list_screen.dart';
import '../../presentation/screens/village/village_detail_screen.dart';
import '../../presentation/screens/attraction/attraction_detail_screen.dart';
import '../../presentation/screens/map/map_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../data/services/supabase_service.dart';

/// Route names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String villages = '/villages';
  static const String villageDetail = '/village/:slug';
  static const String attractionDetail = '/attraction/:id';
  static const String homestayDetail = '/homestay/:id';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String tickets = '/tickets';
  static const String ticketDetail = '/ticket/:id';
  static const String booking = '/booking';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = supabaseService.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;
      final isSplashRoute = state.matchedLocation == AppRoutes.splash;

      // Allow splash screen
      if (isSplashRoute) {
        return null;
      }

      // Redirect to login if not authenticated
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      // Redirect to home if authenticated and trying to access auth routes
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.villages,
        builder: (context, state) => const VillageListScreen(),
      ),
      GoRoute(
        path: AppRoutes.villageDetail,
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return VillageDetailScreen(slug: slug);
        },
      ),
      GoRoute(
        path: AppRoutes.attractionDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AttractionDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Unknown error'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    ),
  );
});
