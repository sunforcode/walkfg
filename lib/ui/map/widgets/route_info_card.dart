import 'package:flutter/cupertino.dart';

/// 路线信息卡片（地图左上角覆盖层）
class RouteInfoCard extends StatelessWidget {
  final String? routeName;
  final double? routeDistance;
  final double? routeElevationGain;
  final String? routeDifficulty;

  const RouteInfoCard({
    super.key,
    this.routeName,
    this.routeDistance,
    this.routeElevationGain,
    this.routeDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (routeName != null)
              Text(
                routeName!,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (routeDistance != null || routeElevationGain != null)
              const SizedBox(height: 4),
            if (routeDistance != null || routeElevationGain != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (routeDistance != null) ...[
                    const Icon(
                      CupertinoIcons.location,
                      size: 12,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${routeDistance!.toStringAsFixed(1)}km',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (routeDistance != null && routeElevationGain != null)
                    const SizedBox(width: 8),
                  if (routeElevationGain != null) ...[
                    const Icon(
                      CupertinoIcons.arrow_up,
                      size: 12,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${routeElevationGain!.toString()}m',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (routeDifficulty != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      routeDifficulty!,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
