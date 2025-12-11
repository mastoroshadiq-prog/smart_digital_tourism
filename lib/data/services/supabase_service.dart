/// Supabase Service - Smart Digital Tourism
/// Handles all Supabase operations (Auth, Database, Storage)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../../core/config/env_config.dart';

/// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Supabase service provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(ref.watch(supabaseClientProvider));
});

/// Supabase Service class
class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  // ============ AUTH METHODS ============

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Auth state stream
  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone_number': phoneNumber},
    );
    return response;
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ============ USER METHODS ============

  /// Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    await _client.from('users').update(user.toJson()).eq('id', user.id);
  }

  /// Update FCM token
  Future<void> updateFcmToken(String userId, String token) async {
    await _client.from('users').update({'fcm_token': token}).eq('id', userId);
  }

  // ============ VILLAGE METHODS ============

  /// Get all villages
  Future<List<VillageModel>> getVillages() async {
    final response = await _client.from('villages').select().order('name');

    return (response as List).map((e) => VillageModel.fromJson(e)).toList();
  }

  /// Get village by ID
  Future<VillageModel?> getVillageById(String id) async {
    final response = await _client
        .from('villages')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return VillageModel.fromJson(response);
  }

  /// Get village by slug
  Future<VillageModel?> getVillageBySlug(String slug) async {
    final response = await _client
        .from('villages')
        .select()
        .eq('slug', slug)
        .maybeSingle();

    if (response == null) return null;
    return VillageModel.fromJson(response);
  }

  /// Check if user is inside a village (Geofencing)
  /// Uses PostGIS ST_Contains via RPC function
  Future<VillageModel?> checkGeofence(double latitude, double longitude) async {
    final response = await _client.rpc(
      'check_geofence',
      params: {'user_lat': latitude, 'user_lon': longitude},
    );

    if (response == null || (response as List).isEmpty) return null;
    return VillageModel.fromJson(response[0]);
  }

  // ============ ATTRACTION METHODS ============

  /// Get attractions by village
  Future<List<AttractionModel>> getAttractionsByVillage(
    String villageId,
  ) async {
    final response = await _client
        .from('attractions')
        .select()
        .eq('village_id', villageId)
        .order('name');

    return (response as List).map((e) => AttractionModel.fromJson(e)).toList();
  }

  /// Get attraction by ID
  Future<AttractionModel?> getAttractionById(String id) async {
    final response = await _client
        .from('attractions')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return AttractionModel.fromJson(response);
  }

  /// Get nearby attractions
  /// Uses PostGIS ST_DWithin via RPC function
  Future<List<AttractionModel>> getNearbyAttractions({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) async {
    final response = await _client.rpc(
      'get_nearby_attractions',
      params: {
        'user_lat': latitude,
        'user_lon': longitude,
        'radius_meters': radiusMeters,
      },
    );

    return (response as List).map((e) => AttractionModel.fromJson(e)).toList();
  }

  // ============ HOMESTAY METHODS ============

  /// Get homestays by village
  Future<List<HomestayModel>> getHomestaysByVillage(String villageId) async {
    final response = await _client
        .from('homestays')
        .select()
        .eq('village_id', villageId)
        .eq('is_active', true)
        .order('name');

    return (response as List).map((e) => HomestayModel.fromJson(e)).toList();
  }

  /// Get homestay by ID with rooms
  Future<HomestayModel?> getHomestayById(String id) async {
    final response = await _client
        .from('homestays')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return HomestayModel.fromJson(response);
  }

  /// Get rooms by homestay
  Future<List<RoomModel>> getRoomsByHomestay(String homestayId) async {
    final response = await _client
        .from('rooms')
        .select()
        .eq('homestay_id', homestayId)
        .order('price_per_night');

    return (response as List).map((e) => RoomModel.fromJson(e)).toList();
  }

  // ============ TRANSACTION METHODS ============

  /// Get user transactions
  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    final response = await _client
        .from('transactions')
        .select('*, items:transaction_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    final response = await _client
        .from('transactions')
        .select('*, items:transaction_items(*)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return TransactionModel.fromJson(response);
  }

  /// Create transaction
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    final response = await _client
        .from('transactions')
        .insert(transaction.toJson())
        .select()
        .single();

    return TransactionModel.fromJson(response);
  }

  /// Verify ticket code (for admin)
  Future<TransactionItemModel?> verifyTicket(String ticketCode) async {
    final response = await _client
        .from('transaction_items')
        .select()
        .eq('ticket_code', ticketCode)
        .maybeSingle();

    if (response == null) return null;
    return TransactionItemModel.fromJson(response);
  }

  /// Redeem ticket
  Future<void> redeemTicket(String itemId) async {
    await _client
        .from('transaction_items')
        .update({
          'is_redeemed': true,
          'redeemed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', itemId);
  }
}

/// Initialize Supabase
Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );
}
