/// Attraction Model - Smart Digital Tourism
/// Based on Database Design Document - Table attractions
/// Point of Interest (POI) within a village

import 'package:latlong2/latlong.dart';

/// Attraction category matching database attraction_category_enum
enum AttractionCategory {
  nature,
  culture,
  artificial,
  culinary;

  String get displayName {
    switch (this) {
      case AttractionCategory.nature:
        return 'Wisata Alam';
      case AttractionCategory.culture:
        return 'Wisata Budaya';
      case AttractionCategory.artificial:
        return 'Wisata Buatan';
      case AttractionCategory.culinary:
        return 'Wisata Kuliner';
    }
  }

  String get icon {
    switch (this) {
      case AttractionCategory.nature:
        return '🌿';
      case AttractionCategory.culture:
        return '🏛️';
      case AttractionCategory.artificial:
        return '🎡';
      case AttractionCategory.culinary:
        return '🍜';
    }
  }

  static AttractionCategory fromString(String value) {
    switch (value) {
      case 'nature':
        return AttractionCategory.nature;
      case 'culture':
        return AttractionCategory.culture;
      case 'artificial':
        return AttractionCategory.artificial;
      case 'culinary':
        return AttractionCategory.culinary;
      default:
        return AttractionCategory.nature;
    }
  }
}

/// Attraction model representing objek wisata
class AttractionModel {
  final String id;
  final String villageId;
  final String name;
  final String? description;
  final AttractionCategory category;
  final double price;
  final LatLng locationPoint;
  final String? thumbnailUrl;
  final List<String> galleryUrls;
  final double rating;
  final DateTime createdAt;

  // Optional: Distance from user (for nearby feature)
  final double? distanceMeters;

  // Optional: Village name for display
  final String? villageName;

  AttractionModel({
    required this.id,
    required this.villageId,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    required this.locationPoint,
    this.thumbnailUrl,
    this.galleryUrls = const [],
    this.rating = 0,
    required this.createdAt,
    this.distanceMeters,
    this.villageName,
  });

  /// Formatted price string
  String get priceString {
    if (price <= 0) return 'Gratis';
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  /// Formatted distance string
  String get distanceString {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.toStringAsFixed(0)} m';
    }
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} km';
  }

  /// Factory constructor from Supabase JSON
  factory AttractionModel.fromJson(Map<String, dynamic> json) {
    return AttractionModel(
      id: json['id'] as String,
      villageId: json['village_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: AttractionCategory.fromString(json['category'] as String),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      locationPoint: _parsePoint(json['location_point']),
      thumbnailUrl: json['thumbnail_url'] as String?,
      galleryUrls:
          (json['gallery_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
      villageName: json['village_name'] as String?,
    );
  }

  /// Parse GeoJSON Point to LatLng
  static LatLng _parsePoint(dynamic geoJson) {
    if (geoJson == null) return const LatLng(0, 0);

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
    return const LatLng(0, 0);
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'village_id': villageId,
      'name': name,
      'description': description,
      'category': category.name,
      'price': price,
      'location_point': {
        'type': 'Point',
        'coordinates': [locationPoint.longitude, locationPoint.latitude],
      },
      'thumbnail_url': thumbnailUrl,
      'gallery_urls': galleryUrls,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AttractionModel copyWith({
    String? id,
    String? villageId,
    String? name,
    String? description,
    AttractionCategory? category,
    double? price,
    LatLng? locationPoint,
    String? thumbnailUrl,
    List<String>? galleryUrls,
    double? rating,
    DateTime? createdAt,
    double? distanceMeters,
    String? villageName,
  }) {
    return AttractionModel(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      locationPoint: locationPoint ?? this.locationPoint,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      villageName: villageName ?? this.villageName,
    );
  }

  @override
  String toString() => 'AttractionModel(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttractionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
