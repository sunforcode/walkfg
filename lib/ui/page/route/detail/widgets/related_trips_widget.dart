import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 相关规划组件 - 展示该路线别人的规划行程
class RelatedTripsWidget extends StatelessWidget {
  /// 路线ID
  final String routeId;

  /// 相关行程列表
  final List<TripModel> relatedTrips;

  /// 点击行程的回调
  final Function(TripModel trip)? onTripTap;

  const RelatedTripsWidget({
    super.key,
    required this.routeId,
    required this.relatedTrips,
    this.onTripTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedTrips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar_badge_plus,
                size: 20,
                color: CupertinoColors.systemIndigo,
              ),
              const SizedBox(width: 8),
              const Text(
                '相关规划',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              Text(
                '${relatedTrips.length}个行程',
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 行程列表
          ...relatedTrips.asMap().entries.map((entry) {
            final index = entry.key;
            final trip = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < relatedTrips.length - 1 ? 12 : 0),
              child: _buildTripCard(trip),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建行程卡片
  Widget _buildTripCard(TripModel trip) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onTripTap?.call(trip),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 行程标题和作者
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
                // 作者头像和名称
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          trip.organizerId[0].toUpperCase(),
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      trip.organizerId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 行程时间和天数
            Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${trip.startDate.month}/${trip.startDate.day}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  CupertinoIcons.time,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${trip.endDate.difference(trip.startDate).inDays + 1}天',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 行程描述
            if (trip.description.isNotEmpty) ...[
              Text(
                trip.description.length > 80
                    ? '${trip.description.substring(0, 80)}...'
                    : trip.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 行程统计信息
            Row(
              children: [
                // 参与人数
                _buildTripStat(
                  icon: CupertinoIcons.person_2,
                  value: '${trip.participantCount}人',
                  color: CupertinoColors.systemBlue,
                ),
                const SizedBox(width: 16),
                // 预算
                if (trip.budget != null) ...[
                  _buildTripStat(
                    icon: CupertinoIcons.money_yen_circle,
                    value: '¥${trip.budget!.toInt()}',
                    color: CupertinoColors.systemGreen,
                  ),
                  const SizedBox(width: 16),
                ],

                // 状态
                _buildTripStat(
                  icon: _getTripStatusIcon(trip.status),
                  value: trip.getStatusName(),
                  color: _getTripStatusColor(trip.status),
                ),

                const Spacer(),

                // 查看详情
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建行程统计项
  Widget _buildTripStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 获取行程状态图标
  IconData _getTripStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.planning:
        return CupertinoIcons.clock;
      case TripStatus.inProgress:
        return CupertinoIcons.play_circle;
      case TripStatus.completed:
        return CupertinoIcons.checkmark_circle_fill;
      case TripStatus.cancelled:
        return CupertinoIcons.xmark_circle;
      default:
        return CupertinoIcons.clock;
    }
  }

  /// 获取行程状态颜色
  Color _getTripStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.planning:
        return CupertinoColors.systemOrange;
      case TripStatus.inProgress:
        return CupertinoColors.systemBlue;
      case TripStatus.completed:
        return CupertinoColors.systemGreen;
      case TripStatus.cancelled:
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}
