/// Home Screen - Smart Digital Tourism
/// Main dashboard with geofencing status and quick actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/providers.dart';
import '../../../data/services/services.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Start location tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentPositionProvider.notifier).startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final villagesState = ref.watch(villagesProvider);
    final positionAsync = ref.watch(currentPositionProvider);

    // Listen for position changes and check geofence
    ref.listen(currentPositionProvider, (prev, next) {
      next.whenData((position) {
        ref
            .read(villagesProvider.notifier)
            .checkGeofence(position.latitude, position.longitude);
      });
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(villagesProvider.notifier).loadVillages();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    villagesState.currentVillage != null
                        ? 'Selamat Datang di ${villagesState.currentVillage!.name}'
                        : 'DesaExplore',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3)],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          bottom: -50,
                          child: Icon(
                            Icons.explore,
                            size: 200,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // TODO: Notifications
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => context.push(AppRoutes.profile),
                  ),
                ],
              ),
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Geofencing Status Card
                    if (villagesState.currentVillage != null) ...[
                      _GeofenceCard(village: villagesState.currentVillage!),
                      const Gap(16),
                    ],
                    // Quick Actions
                    _SectionTitle(title: 'Menu Utama'),
                    const Gap(12),
                    _QuickActions(),
                    const Gap(24),
                    // Featured Villages
                    _SectionTitle(
                      title: 'Desa Wisata',
                      action: TextButton(
                        onPressed: () => context.push(AppRoutes.villages),
                        child: const Text('Lihat Semua'),
                      ),
                    ),
                    const Gap(12),
                    if (villagesState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (villagesState.villages.isEmpty)
                      const Center(child: Text('Belum ada desa wisata'))
                    else
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: villagesState.villages.length.clamp(0, 5),
                          separatorBuilder: (_, __) => const Gap(12),
                          itemBuilder: (context, index) {
                            final village = villagesState.villages[index];
                            return _VillageCard(
                              village: village,
                              onTap: () {
                                context.push('/village/${village.slug}');
                              },
                            );
                          },
                        ),
                      ),
                    const Gap(24),
                    // Location Status
                    positionAsync.when(
                      data: (position) => _LocationStatus(
                        latitude: position.latitude,
                        longitude: position.longitude,
                      ),
                      loading: () => const _LocationStatus(isLoading: true),
                      error: (e, _) => _LocationStatus(error: e.toString()),
                    ),
                    const Gap(100), // Bottom padding for nav bar
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              // Already home
              break;
            case 1:
              context.push(AppRoutes.villages);
              break;
            case 2:
              context.push(AppRoutes.map);
              break;
            case 3:
              context.push(AppRoutes.profile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Jelajahi',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Peta',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionTitle({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (action != null) action!,
      ],
    );
  }
}

class _GeofenceCard extends StatelessWidget {
  final dynamic village;

  const _GeofenceCard({required this.village});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 28,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anda berada di',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    village.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (village.description != null)
                    Text(
                      village.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _QuickActionItem(
          icon: Icons.confirmation_number,
          label: 'Tiket',
          color: AppColors.categoryNature,
          onTap: () {
            // TODO: Tickets
          },
        ),
        _QuickActionItem(
          icon: Icons.hotel,
          label: 'Homestay',
          color: AppColors.categoryCulture,
          onTap: () {
            // TODO: Homestay
          },
        ),
        _QuickActionItem(
          icon: Icons.restaurant,
          label: 'Kuliner',
          color: AppColors.categoryCulinary,
          onTap: () {
            // TODO: Culinary
          },
        ),
        _QuickActionItem(
          icon: Icons.qr_code_scanner,
          label: 'Scan',
          color: AppColors.categoryArtificial,
          onTap: () {
            // TODO: QR Scanner
          },
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const Gap(8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VillageCard extends StatelessWidget {
  final dynamic village;
  final VoidCallback onTap;

  const _VillageCard({required this.village, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.landscape,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      village.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    if (village.district != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const Gap(4),
                          Expanded(
                            child: Text(
                              village.district!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationStatus extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final String? error;

  const _LocationStatus({
    this.latitude,
    this.longitude,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isLoading
                  ? Icons.location_searching
                  : error != null
                  ? Icons.location_off
                  : Icons.my_location,
              color: error != null ? AppColors.error : AppColors.primary,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                isLoading
                    ? 'Mencari lokasi...'
                    : error != null
                    ? 'Lokasi tidak tersedia'
                    : 'Lat: ${latitude?.toStringAsFixed(4)}, Lng: ${longitude?.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
