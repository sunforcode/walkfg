import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/daily_plan_model.dart';

/// 每日行程组件
class TripDailyItineraryWidget extends StatelessWidget {
  final List<DailyPlanModel>? itinerary;
  final Function() onEdit;

  const TripDailyItineraryWidget({
    super.key,
    required this.itinerary,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (itinerary == null || itinerary!.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildDailyItems(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.calendar,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无行程安排',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI将为您规划详细的每日行程',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            child: const Text('规划行程'),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDailyItems() {
    if (itinerary == null || itinerary!.isEmpty) {
      return [];
    }

    return itinerary!.map((plan) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期标题
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'D${plan.dayNumber}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.location,
                            size: 12,
                            color: CupertinoColors.secondaryLabel,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${plan.distance.toStringAsFixed(1)}km',
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            CupertinoIcons.arrow_up_arrow_down,
                            size: 12,
                            color: CupertinoColors.secondaryLabel,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${plan.elevationGain}m',
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 描述信息
            if (plan.description.isNotEmpty) ...[
              Text(
                plan.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.label,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 统计信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          CupertinoIcons.time,
                          size: 16,
                          color: CupertinoColors.systemBlue,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.estimatedTime.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                        const Text(
                          '预计时长',
                          style: TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          CupertinoIcons.location,
                          size: 16,
                          color: CupertinoColors.systemGreen,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${plan.distance.toStringAsFixed(1)}km',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.systemGreen,
                          ),
                        ),
                        const Text(
                          '徒步距离',
                          style: TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          CupertinoIcons.arrow_up,
                          size: 16,
                          color: CupertinoColors.systemOrange,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${plan.elevationGain}m',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.systemOrange,
                          ),
                        ),
                        const Text(
                          '爬升高度',
                          style: TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
