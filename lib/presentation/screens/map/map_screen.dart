/// Map Screen - Smart Digital Tourism
/// Interactive map with village polygons and POI markers

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/config/env_config.dart';
import '../../../core/config/app_constants.dart';
import '../../../providers/providers.dart';
import '../../../data/services/services.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _isFollowingUser = true;

  @override
  Widget build(BuildContext context) {
    final villagesState = ref.watch(villagesProvider);
    final positionAsync = ref.watch(currentPositionProvider);

    // Center on user when position updates
    ref.listen(currentPositionProvider, (prev, next) {
      if (_isFollowingUser) {
        next.whenData((position) {
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            AppConstants.defaultZoom,
          );
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta'),
        actions: [
          IconButton(
            icon: Icon(
              _isFollowingUser ? Icons.gps_fixed : Icons.gps_not_fixed,
            ),
            onPressed: () {
              setState(() => _isFollowingUser = !_isFollowingUser);
              if (_isFollowingUser) {
                positionAsync.whenData((position) {
                  _mapController.move(
                    LatLng(position.latitude, position.longitude),
                    AppConstants.defaultZoom,
                  );
                });
              }
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: positionAsync.maybeWhen(
            data: (p) => LatLng(p.latitude, p.longitude),
            orElse: () => const LatLng(-7.2575, 112.7521), // Default: Surabaya
          ),
          initialZoom: AppConstants.defaultZoom,
          minZoom: AppConstants.minZoom,
          maxZoom: AppConstants.maxZoom,
          onPositionChanged: (position, hasGesture) {
            if (hasGesture && _isFollowingUser) {
              setState(() => _isFollowingUser = false);
            }
          },
        ),
        children: [
          // Map Tiles
          TileLayer(
            urlTemplate: EnvConfig.mapTileUrl,
            userAgentPackageName: 'com.desaexplore.smart_dt',
          ),
          // Village Polygons
          if (villagesState.villages.isNotEmpty)
            PolygonLayer(
              polygons: villagesState.villages
                  .where((v) => v.areaPolygon.isNotEmpty)
                  .map((village) {
                    final isCurrentVillage =
                        village.id == villagesState.currentVillage?.id;
                    return Polygon(
                      points: village.areaPolygon,
                      color: isCurrentVillage
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.geofenceArea,
                      borderColor: isCurrentVillage
                          ? AppColors.primary
                          : AppColors.geofenceBorder,
                      borderStrokeWidth: isCurrentVillage ? 3 : 2,
                      isFilled: true,
                    );
                  })
                  .toList(),
            ),
          // Village Center Markers
          if (villagesState.villages.isNotEmpty)
            MarkerLayer(
              markers: villagesState.villages
                  .where((v) => v.centerPoint != null)
                  .map((village) {
                    return Marker(
                      point: village.centerPoint!,
                      width: 120,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showVillageInfo(context, village),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            village.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          // User Location Marker
          positionAsync.maybeWhen(
            data: (position) => MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(position.latitude, position.longitude),
                  width: 40,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.userLocation,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.userLocation.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      // Current Village Info
      bottomSheet: villagesState.currentVillage != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Gap(12),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Anda di',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                villagesState.currentVillage!.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigate to village detail
                          },
                          child: const Text('Jelajahi'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _showVillageInfo(BuildContext context, dynamic village) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(16),
              Text(
                village.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Gap(8),
              if (village.description != null)
                Text(
                  village.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to village
                  },
                  child: const Text('Lihat Detail'),
                ),
              ),
              const Gap(8),
            ],
          ),
        );
      },
    );
  }
}
