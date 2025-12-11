/// Homestay Model - Smart Digital Tourism
/// Based on Database Design Document - Tables homestays & rooms

import 'package:latlong2/latlong.dart';

/// Homestay model representing akomodasi
class HomestayModel {
  final String id;
  final String villageId;
  final String? ownerId;
  final String name;
  final String? description;
  final String? address;
  final LatLng? locationPoint;
  final String? contactNumber;
  final bool isActive;
  final DateTime createdAt;

  // Additional fields
  final String? thumbnailUrl;
  final List<String> galleryUrls;
  final double? minPrice;
  final double? maxPrice;
  final int? totalRooms;
  final double? rating;
  final String? villageName;

  HomestayModel({
    required this.id,
    required this.villageId,
    this.ownerId,
    required this.name,
    this.description,
    this.address,
    this.locationPoint,
    this.contactNumber,
    this.isActive = true,
    required this.createdAt,
    this.thumbnailUrl,
    this.galleryUrls = const [],
    this.minPrice,
    this.maxPrice,
    this.totalRooms,
    this.rating,
    this.villageName,
  });

  /// Price range string
  String get priceRangeString {
    if (minPrice == null && maxPrice == null) return 'Harga tidak tersedia';
    if (minPrice == maxPrice) return _formatPrice(minPrice!);
    return '${_formatPrice(minPrice!)} - ${_formatPrice(maxPrice!)}';
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  factory HomestayModel.fromJson(Map<String, dynamic> json) {
    return HomestayModel(
      id: json['id'] as String,
      villageId: json['village_id'] as String,
      ownerId: json['owner_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      locationPoint: _parsePoint(json['location_point']),
      contactNumber: json['contact_number'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      thumbnailUrl: json['thumbnail_url'] as String?,
      galleryUrls:
          (json['gallery_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      totalRooms: json['total_rooms'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      villageName: json['village_name'] as String?,
    );
  }

  static LatLng? _parsePoint(dynamic geoJson) {
    if (geoJson == null) return null;
    try {
      if (geoJson is Map<String, dynamic>) {
        final coords = geoJson['coordinates'] as List<dynamic>;
        return LatLng(
          (coords[1] as num).toDouble(),
          (coords[0] as num).toDouble(),
        );
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'village_id': villageId,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'location_point': locationPoint != null
          ? {
              'type': 'Point',
              'coordinates': [
                locationPoint!.longitude,
                locationPoint!.latitude,
              ],
            }
          : null,
      'contact_number': contactNumber,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'HomestayModel(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomestayModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Room model representing tipe kamar
class RoomModel {
  final String id;
  final String homestayId;
  final String name;
  final double pricePerNight;
  final int capacity;
  final List<String> amenities;
  final int stock;

  // Additional fields
  final String? thumbnailUrl;
  final List<String> galleryUrls;
  final int? availableStock;

  RoomModel({
    required this.id,
    required this.homestayId,
    required this.name,
    required this.pricePerNight,
    this.capacity = 2,
    this.amenities = const [],
    this.stock = 1,
    this.thumbnailUrl,
    this.galleryUrls = const [],
    this.availableStock,
  });

  String get priceString {
    return 'Rp ${pricePerNight.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}/malam';
  }

  String get capacityString => '$capacity tamu';

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      homestayId: json['homestay_id'] as String,
      name: json['name'] as String,
      pricePerNight: (json['price_per_night'] as num).toDouble(),
      capacity: json['capacity'] as int? ?? 2,
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      stock: json['stock'] as int? ?? 1,
      thumbnailUrl: json['thumbnail_url'] as String?,
      galleryUrls:
          (json['gallery_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      availableStock: json['available_stock'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homestay_id': homestayId,
      'name': name,
      'price_per_night': pricePerNight,
      'capacity': capacity,
      'amenities': amenities,
      'stock': stock,
    };
  }

  @override
  String toString() => 'RoomModel(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
