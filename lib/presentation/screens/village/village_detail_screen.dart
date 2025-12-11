/// Village Detail Screen - Smart Digital Tourism

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/providers.dart';
import '../../../data/models/models.dart';

class VillageDetailScreen extends ConsumerWidget {
  final String slug;

  const VillageDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villageAsync = ref.watch(villageBySlugProvider(slug));

    return villageAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const Gap(16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
      data: (village) {
        if (village == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Desa tidak ditemukan')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Hero Image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    village.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3)],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.landscape,
                        size: 100,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: Share
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      // TODO: Favorite
                    },
                  ),
                ],
              ),
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const Gap(8),
                        Text(
                          village.locationString,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const Gap(16),
                    // Description
                    if (village.description != null) ...[
                      Text(
                        'Tentang Desa',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Gap(8),
                      Text(
                        village.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Gap(24),
                    ],
                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/map'),
                            icon: const Icon(Icons.map),
                            label: const Text('Lihat Peta'),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Navigation
                            },
                            icon: const Icon(Icons.navigation),
                            label: const Text('Navigasi'),
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),
                    // Attractions Section
                    _AttractionsSection(villageId: village.id),
                    const Gap(24),
                    // Homestays Section
                    _HomestaysSection(villageId: village.id),
                    const Gap(100),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AttractionsSection extends ConsumerWidget {
  final String villageId;

  const _AttractionsSection({required this.villageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attractionsAsync = ref.watch(attractionsByVillageProvider(villageId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Objek Wisata', style: Theme.of(context).textTheme.titleLarge),
        const Gap(12),
        attractionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (attractions) {
            if (attractions.isEmpty) {
              return const Text('Belum ada objek wisata');
            }
            return SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: attractions.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (context, index) {
                  final attraction = attractions[index];
                  return _AttractionCard(attraction: attraction);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AttractionCard extends StatelessWidget {
  final AttractionModel attraction;

  const _AttractionCard({required this.attraction});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/attraction/${attraction.id}'),
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 90,
                color: _getCategoryColor(
                  attraction.category,
                ).withValues(alpha: 0.1),
                child: Center(
                  child: Text(
                    attraction.category.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attraction.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              attraction.category,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            attraction.category.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: _getCategoryColor(attraction.category),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      attraction.priceString,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
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

  Color _getCategoryColor(AttractionCategory category) {
    switch (category) {
      case AttractionCategory.nature:
        return AppColors.categoryNature;
      case AttractionCategory.culture:
        return AppColors.categoryCulture;
      case AttractionCategory.artificial:
        return AppColors.categoryArtificial;
      case AttractionCategory.culinary:
        return AppColors.categoryCulinary;
    }
  }
}

class _HomestaysSection extends ConsumerWidget {
  final String villageId;

  const _HomestaysSection({required this.villageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homestaysAsync = ref.watch(homestaysByVillageProvider(villageId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Homestay', style: Theme.of(context).textTheme.titleLarge),
        const Gap(12),
        homestaysAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (homestays) {
            if (homestays.isEmpty) {
              return const Text('Belum ada homestay');
            }
            return Column(
              children: homestays.map((homestay) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.hotel,
                        color: AppColors.secondary,
                      ),
                    ),
                    title: Text(homestay.name),
                    subtitle: Text(homestay.priceRangeString),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push('/homestay/${homestay.id}');
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
