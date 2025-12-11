/// Auth Provider - Smart Digital Tourism
/// State management for authentication

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import '../data/models/models.dart';
import '../data/services/services.dart';

/// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabaseService;
  final StorageService _storageService;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthNotifier(this._supabaseService, this._storageService)
    : super(const AuthState()) {
    _init();
  }

  void _init() {
    // Check for cached user first
    final cachedUser = _storageService.getCurrentUser();
    if (cachedUser != null) {
      state = AuthState(user: cachedUser);
    }

    // Listen to auth state changes
    _authSubscription = _supabaseService.authStateStream.listen((event) async {
      if (event.session != null) {
        await _loadUserProfile(event.session!.user.id);
      } else {
        state = const AuthState();
        await _storageService.clearCurrentUser();
      }
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final user = await _supabaseService.getUserProfile(userId);
      if (user != null) {
        state = AuthState(user: user);
        await _storageService.saveCurrentUser(user);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    }
  }

  /// Sign in
  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        state = state.copyWith(isLoading: false);
        return true;
      }

      state = state.copyWith(isLoading: false, error: 'Login gagal');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _supabaseService.signOut();
      await _storageService.clearCurrentUser();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _supabaseService.resetPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  String _parseAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Email atau password salah';
        case 'Email not confirmed':
          return 'Email belum dikonfirmasi';
        case 'User already registered':
          return 'Email sudah terdaftar';
        default:
          return error.message;
      }
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(supabaseServiceProvider),
    ref.watch(storageServiceProvider),
  );
});

/// Current user provider
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
