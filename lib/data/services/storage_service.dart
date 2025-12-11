/// Storage Service - Smart Digital Tourism
/// Handles local storage using Hive for offline mode

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Storage box names
class StorageBoxes {
  static const String user = 'user_box';
  static const String villages = 'villages_box';
  static const String attractions = 'attractions_box';
  static const String tickets = 'tickets_box';
  static const String settings = 'settings_box';
}

/// Storage keys
class StorageKeys {
  static const String currentUser = 'current_user';
  static const String isFirstLaunch = 'is_first_launch';
  static const String lastSyncTime = 'last_sync_time';
  static const String selectedVillageId = 'selected_village_id';
  static const String isDarkMode = 'is_dark_mode';
}

/// Storage Service class
class StorageService {
  /// Initialize Hive and open boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    // Note: Run build_runner to generate adapters for Hive
    // Hive.registerAdapter(UserModelAdapter());

    // Open boxes
    await Hive.openBox(StorageBoxes.user);
    await Hive.openBox(StorageBoxes.villages);
    await Hive.openBox(StorageBoxes.attractions);
    await Hive.openBox(StorageBoxes.tickets);
    await Hive.openBox(StorageBoxes.settings);
  }

  // ============ USER STORAGE ============

  /// Save current user
  Future<void> saveCurrentUser(UserModel user) async {
    final box = Hive.box(StorageBoxes.user);
    await box.put(StorageKeys.currentUser, user.toJson());
  }

  /// Get current user
  UserModel? getCurrentUser() {
    final box = Hive.box(StorageBoxes.user);
    final data = box.get(StorageKeys.currentUser);
    if (data == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// Clear current user
  Future<void> clearCurrentUser() async {
    final box = Hive.box(StorageBoxes.user);
    await box.delete(StorageKeys.currentUser);
  }

  // ============ TICKETS STORAGE (Offline Access) ============

  /// Save active tickets
  Future<void> saveActiveTickets(List<TransactionItemModel> tickets) async {
    final box = Hive.box(StorageBoxes.tickets);
    final ticketsJson = tickets.map((t) => t.toJson()).toList();
    await box.put('active_tickets', ticketsJson);
  }

  /// Get active tickets
  List<TransactionItemModel> getActiveTickets() {
    final box = Hive.box(StorageBoxes.tickets);
    final data = box.get('active_tickets');
    if (data == null) return [];
    return (data as List)
        .map((e) => TransactionItemModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ============ VILLAGES CACHE ============

  /// Cache villages
  Future<void> cacheVillages(List<VillageModel> villages) async {
    final box = Hive.box(StorageBoxes.villages);
    final villagesJson = villages.map((v) => v.toJson()).toList();
    await box.put('cached_villages', villagesJson);
    await box.put(StorageKeys.lastSyncTime, DateTime.now().toIso8601String());
  }

  /// Get cached villages
  List<VillageModel> getCachedVillages() {
    final box = Hive.box(StorageBoxes.villages);
    final data = box.get('cached_villages');
    if (data == null) return [];
    return (data as List)
        .map((e) => VillageModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ============ SETTINGS ============

  /// Check if first launch
  bool isFirstLaunch() {
    final box = Hive.box(StorageBoxes.settings);
    return box.get(StorageKeys.isFirstLaunch, defaultValue: true);
  }

  /// Set first launch completed
  Future<void> setFirstLaunchCompleted() async {
    final box = Hive.box(StorageBoxes.settings);
    await box.put(StorageKeys.isFirstLaunch, false);
  }

  /// Get dark mode setting
  bool isDarkMode() {
    final box = Hive.box(StorageBoxes.settings);
    return box.get(StorageKeys.isDarkMode, defaultValue: false);
  }

  /// Set dark mode
  Future<void> setDarkMode(bool value) async {
    final box = Hive.box(StorageBoxes.settings);
    await box.put(StorageKeys.isDarkMode, value);
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    final box = Hive.box(StorageBoxes.villages);
    final data = box.get(StorageKeys.lastSyncTime);
    if (data == null) return null;
    return DateTime.parse(data);
  }

  // ============ CLEAR ALL ============

  /// Clear all storage
  Future<void> clearAll() async {
    await Hive.box(StorageBoxes.user).clear();
    await Hive.box(StorageBoxes.villages).clear();
    await Hive.box(StorageBoxes.attractions).clear();
    await Hive.box(StorageBoxes.tickets).clear();
    // Don't clear settings
  }
}
