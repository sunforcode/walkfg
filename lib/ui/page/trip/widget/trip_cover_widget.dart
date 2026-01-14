import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';

class TripCoverWidget extends StatelessWidget {
  final TripModel trip;
  final int tripDays;

  const TripCoverWidget({
    super.key,
    required this.trip,
    required this.tripDays,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 封面图片
            trip.coverUrl != null
                ? NetworkImageWithFallback(
                    url: trip.coverUrl!,
                    fit: BoxFit.cover,
                    fallbackColor: AppColors.primary,
                  )
                : Container(
                    color: CupertinoColors.systemGrey5,
                    child: const Icon(
                      CupertinoIcons.photo,
                      color: CupertinoColors.systemGrey,
                      size: 48,
                    ),
                  ),

            // 渐变遮罩
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // 行程名称
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildInfoChip(
                        CupertinoIcons.calendar,
                        '${trip.startDate.year}/${trip.startDate.month}/${trip.startDate.day}',
                        light: true,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        CupertinoIcons.clock,
                        '$tripDays 天',
                        light: true,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(trip.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {bool light = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: light
            ? CupertinoColors.white.withOpacity(0.2)
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: light ? CupertinoColors.white : CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: light ? CupertinoColors.white : CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TripStatus status) {
    Color color;
    String label = '';

    switch (status) {
      case TripStatus.planning:
        color = CupertinoColors.activeOrange;
        label = '计划中';
        break;
      case TripStatus.inProgress:
        color = CupertinoColors.activeBlue;
        label = '进行中';
        break;
      case TripStatus.completed:
        color = CupertinoColors.activeGreen;
        label = '已完成';
        break;
      case TripStatus.cancelled:
        color = CupertinoColors.systemGrey;
        label = '已取消';
        break;
      case TripStatus.confirmed:
        color = CupertinoColors.systemGrey;
        label = '已确认';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
