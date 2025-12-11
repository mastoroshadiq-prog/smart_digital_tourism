/// Village List Screen - Smart Digital Tourism

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/providers.dart';

class VillageListScreen extends ConsumerWidget {
  const VillageListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villagesState = ref.watch(villagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Desa Wisata'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filter
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(villagesProvider.notifier).loadVillages();
        },
        child: villagesState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : villagesState.villages.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.explore_off,
                      size: 80,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const Gap(16),
                    Text(
                      'Belum ada desa wisata',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Gap(8),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(villagesProvider.notifier).loadVillages();
                      },
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: villagesState.villages.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (context, index) {
                  final village = villagesState.villages[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        context.push('/village/${village.slug}');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image placeholder
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.landscape,
                                size: 60,
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  village.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Gap(4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const Gap(4),
                                    Text(
                                      village.locationString,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                if (village.description != null) ...[
                                  const Gap(8),
                                  Text(
                                    village.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
