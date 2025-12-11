/// User Model - Smart Digital Tourism
/// Based on Database Design Document - Table users

/// User role enumeration matching database user_role_enum
enum UserRole {
  tourist,
  villageAdmin,
  homestayOwner,
  superAdmin;

  String get displayName {
    switch (this) {
      case UserRole.tourist:
        return 'Wisatawan';
      case UserRole.villageAdmin:
        return 'Admin Desa';
      case UserRole.homestayOwner:
        return 'Pemilik Homestay';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  String get databaseValue {
    switch (this) {
      case UserRole.tourist:
        return 'tourist';
      case UserRole.villageAdmin:
        return 'village_admin';
      case UserRole.homestayOwner:
        return 'homestay_owner';
      case UserRole.superAdmin:
        return 'super_admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'tourist':
        return UserRole.tourist;
      case 'village_admin':
        return UserRole.villageAdmin;
      case 'homestay_owner':
        return UserRole.homestayOwner;
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        return UserRole.tourist;
    }
  }
}

/// User model class
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String role;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
  });

  UserRole get userRole => UserRole.fromString(role);

  /// Factory constructor from Supabase JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String? ?? 'tourist',
      fcmToken: json['fcm_token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }

  /// Copy with method for immutability
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? role,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, fullName: $fullName, email: $email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
