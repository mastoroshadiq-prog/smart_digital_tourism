/// Village Model - Smart Digital Tourism
/// Based on Database Design Document - Table villages
/// Core spatial entity for Geofencing feature

import 'package:latlong2/latlong.dart';

/// Village model representing desa wisata with spatial data
class VillageModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? district; // Kecamatan
  final String? province;
  final List<LatLng> areaPolygon; // Geofencing boundary
  final LatLng? centerPoint;
  final DateTime createdAt;

  // Additional fields for display
  final String? thumbnailUrl;
  final int? attractionCount;
  final int? homestayCount;

  VillageModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.district,
    this.province,
    required this.areaPolygon,
    this.centerPoint,
    required this.createdAt,
    this.thumbnailUrl,
    this.attractionCount,
    this.homestayCount,
  });

  /// Full location string (District, Province)
  String get locationString {
    final parts = <String>[];
    if (district != null) parts.add(district!);
    if (province != null) parts.add(province!);
    return parts.join(', ');
  }

  /// Factory constructor from Supabase JSON
  /// Note: PostGIS geometry data comes in GeoJSON format
  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      district: json['district'] as String?,
      province: json['province'] as String?,
      areaPolygon: _parsePolygon(json['area_polygon']),
      centerPoint: _parsePoint(json['center_point']),
      createdAt: DateTime.parse(json['created_at'] as String),
      thumbnailUrl: json['thumbnail_url'] as String?,
      attractionCount: json['attraction_count'] as int?,
      homestayCount: json['homestay_count'] as int?,
    );
  }

  /// Parse GeoJSON Point to LatLng
  static LatLng? _parsePoint(dynamic geoJson) {
    if (geoJson == null) return null;

    try {
      if (geoJson is Map<String, dynamic>) {
        // GeoJSON format: {"type": "Point", "coordinates": [lon, lat]}
        final coords = geoJson['coordinates'] as List<dynamic>;
        return LatLng(
          (coords[1] as num).toDouble(), // latitude
          (coords[0] as num).toDouble(), // longitude
        );
      }
    } catch (e) {
      // ignore parsing errors
    }
    return null;
  }

  /// Parse GeoJSON Polygon to List<LatLng>
  static List<LatLng> _parsePolygon(dynamic geoJson) {
    if (geoJson == null) return [];

    try {
      if (geoJson is Map<String, dynamic>) {
        // GeoJSON format: {"type": "Polygon", "coordinates": [[[lon, lat], ...]]}
        final coordinates = geoJson['coordinates'] as List<dynamic>;
        if (coordinates.isNotEmpty) {
          final ring = coordinates[0] as List<dynamic>;
          return ring.map((coord) {
            final c = coord as List<dynamic>;
            return LatLng(
              (c[1] as num).toDouble(), // latitude
              (c[0] as num).toDouble(), // longitude
            );
          }).toList();
        }
      }
    } catch (e) {
      // ignore parsing errors
    }
    return [];
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'district': district,
      'province': province,
      'area_polygon': _polygonToGeoJson(areaPolygon),
      'center_point': centerPoint != null
          ? _pointToGeoJson(centerPoint!)
          : null,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert LatLng to GeoJSON Point
  static Map<String, dynamic> _pointToGeoJson(LatLng point) {
    return {
      'type': 'Point',
      'coordinates': [point.longitude, point.latitude],
    };
  }

  /// Convert List<LatLng> to GeoJSON Polygon
  static Map<String, dynamic> _polygonToGeoJson(List<LatLng> polygon) {
    final coordinates = polygon.map((p) => [p.longitude, p.latitude]).toList();
    // Close the polygon
    if (coordinates.isNotEmpty && coordinates.first != coordinates.last) {
      coordinates.add(coordinates.first);
    }
    return {
      'type': 'Polygon',
      'coordinates': [coordinates],
    };
  }

  VillageModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? district,
    String? province,
    List<LatLng>? areaPolygon,
    LatLng? centerPoint,
    DateTime? createdAt,
    String? thumbnailUrl,
    int? attractionCount,
    int? homestayCount,
  }) {
    return VillageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      district: district ?? this.district,
      province: province ?? this.province,
      areaPolygon: areaPolygon ?? this.areaPolygon,
      centerPoint: centerPoint ?? this.centerPoint,
      createdAt: createdAt ?? this.createdAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      attractionCount: attractionCount ?? this.attractionCount,
      homestayCount: homestayCount ?? this.homestayCount,
    );
  }

  @override
  String toString() => 'VillageModel(id: $id, name: $name, slug: $slug)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VillageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
