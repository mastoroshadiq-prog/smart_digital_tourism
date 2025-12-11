/// Village Provider - Smart Digital Tourism
/// State management for villages and geofencing

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

/// Villages state
class VillagesState {
  final List<VillageModel> villages;
  final VillageModel? currentVillage; // Current geofenced village
  final bool isLoading;
  final String? error;

  const VillagesState({
    this.villages = const [],
    this.currentVillage,
    this.isLoading = false,
    this.error,
  });

  VillagesState copyWith({
    List<VillageModel>? villages,
    VillageModel? currentVillage,
    bool? isLoading,
    String? error,
    bool clearCurrentVillage = false,
  }) {
    return VillagesState(
      villages: villages ?? this.villages,
      currentVillage: clearCurrentVillage
          ? null
          : (currentVillage ?? this.currentVillage),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Villages notifier
class VillagesNotifier extends StateNotifier<VillagesState> {
  final SupabaseService _supabaseService;
  final StorageService _storageService;

  VillagesNotifier(this._supabaseService, this._storageService)
    : super(const VillagesState()) {
    _init();
  }

  void _init() {
    // Load cached villages first
    final cached = _storageService.getCachedVillages();
    if (cached.isNotEmpty) {
      state = state.copyWith(villages: cached);
    }
    // Then fetch fresh data
    loadVillages();
  }

  /// Load all villages
  Future<void> loadVillages() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final villages = await _supabaseService.getVillages();
      state = state.copyWith(villages: villages, isLoading: false);

      // Cache for offline
      await _storageService.cacheVillages(villages);
    } catch (e) {
      // Keep cached data on error
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Check geofence with user position
  Future<void> checkGeofence(double latitude, double longitude) async {
    try {
      // Try server-side check first (more accurate with PostGIS)
      final village = await _supabaseService.checkGeofence(latitude, longitude);

      if (village != null) {
        if (state.currentVillage?.id != village.id) {
          // New village entered!
          state = state.copyWith(currentVillage: village);
        }
      } else {
        // Not in any village
        if (state.currentVillage != null) {
          // Just left a village
          state = state.copyWith(clearCurrentVillage: true);
        }
      }
    } catch (e) {
      // Fallback to client-side check with cached data
      final userPoint = LatLng(latitude, longitude);

      for (final village in state.villages) {
        if (LocationService.isPointInPolygon(userPoint, village.areaPolygon)) {
          if (state.currentVillage?.id != village.id) {
            state = state.copyWith(currentVillage: village);
          }
          return;
        }
      }

      // Not in any village
      if (state.currentVillage != null) {
        state = state.copyWith(clearCurrentVillage: true);
      }
    }
  }

  /// Clear current village
  void clearCurrentVillage() {
    state = state.copyWith(clearCurrentVillage: true);
  }
}

/// Villages provider
final villagesProvider = StateNotifierProvider<VillagesNotifier, VillagesState>(
  (ref) {
    return VillagesNotifier(
      ref.watch(supabaseServiceProvider),
      ref.watch(storageServiceProvider),
    );
  },
);

/// Single village provider (by ID or slug)
final villageBySlugProvider = FutureProvider.family<VillageModel?, String>((
  ref,
  slug,
) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.getVillageBySlug(slug);
});

/// Attractions by village provider
final attractionsByVillageProvider =
    FutureProvider.family<List<AttractionModel>, String>((
      ref,
      villageId,
    ) async {
      final supabaseService = ref.watch(supabaseServiceProvider);
      return supabaseService.getAttractionsByVillage(villageId);
    });

/// Homestays by village provider
final homestaysByVillageProvider =
    FutureProvider.family<List<HomestayModel>, String>((ref, villageId) async {
      final supabaseService = ref.watch(supabaseServiceProvider);
      return supabaseService.getHomestaysByVillage(villageId);
    });
