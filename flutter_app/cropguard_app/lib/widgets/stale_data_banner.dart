import 'package:flutter/material.dart';

import '../services/data_cache_service.dart';
import '../utils/colors.dart';

/// A compact banner shown when the app is rendering from a local cache
/// instead of a live stream.
///
/// It displays the cache's [lastUpdatedLabel] and a refresh action so users
/// understand the data may be slightly stale and can pull a fresh copy when
/// connectivity is available.
class StaleDataBanner extends StatelessWidget {
  final DataCacheService cache;
  final VoidCallback onRefresh;
  final bool visible;

  const StaleDataBanner({
    super.key,
    required this.cache,
    required this.onRefresh,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final label = cache.lastUpdatedLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xFFB45309).withOpacity(0.92),
      child: Row(
        children: [
          const Icon(Icons.timer_off, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Using cached data — last refreshed $label',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onRefresh,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text(
              'Refresh',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tiny "last refreshed X" chip suitable for placing under a screen header.
class LastRefreshedChip extends StatelessWidget {
  final DataCacheService cache;
  final bool show;

  const LastRefreshedChip({super.key, required this.cache, this.show = true});

  @override
  Widget build(BuildContext context) {
    if (!show || !cache.cacheExists) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: 11,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            'Last refreshed ${cache.lastUpdatedLabel()}',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
