/// Attraction Detail Screen - Smart Digital Tourism

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/services.dart';
import '../../../data/models/models.dart';

class AttractionDetailScreen extends ConsumerWidget {
  final String id;

  const AttractionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseService = ref.watch(supabaseServiceProvider);

    return FutureBuilder<AttractionModel?>(
      future: supabaseService.getAttractionById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final attraction = snapshot.data;
        if (attraction == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Wisata tidak ditemukan')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    attraction.name,
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
                        colors: [
                          _getCategoryColor(attraction.category),
                          _getCategoryColor(
                            attraction.category,
                          ).withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        attraction.category.icon,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Category & Rating
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              attraction.category,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                attraction.category.icon,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const Gap(4),
                              Text(
                                attraction.category.displayName,
                                style: TextStyle(
                                  color: _getCategoryColor(attraction.category),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (attraction.rating > 0) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const Gap(4),
                          Text(
                            attraction.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ],
                    ),
                    const Gap(24),
                    // Price
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Harga Tiket',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                attraction.priceString,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Buy ticket
                            },
                            child: const Text('Beli Tiket'),
                          ),
                        ],
                      ),
                    ),
                    const Gap(24),
                    // Description
                    if (attraction.description != null) ...[
                      Text(
                        'Deskripsi',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Gap(8),
                      Text(
                        attraction.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Gap(24),
                    ],
                    // Location
                    Text(
                      'Lokasi',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Gap(8),
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.map,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          'Lat: ${attraction.locationPoint.latitude.toStringAsFixed(4)}, Lng: ${attraction.locationPoint.longitude.toStringAsFixed(4)}',
                        ),
                        trailing: const Icon(Icons.navigation),
                        onTap: () {
                          // TODO: Open navigation
                        },
                      ),
                    ),
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
