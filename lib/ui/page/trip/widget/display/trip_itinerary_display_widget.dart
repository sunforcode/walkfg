import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/model/route/daily_plan_model.dart';

/// 每日行程展示组件
class TripItineraryDisplayWidget extends StatelessWidget {
  final TripModel trip;

  const TripItineraryDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: const Text(
              '📅 每日行程',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ),

          // 行程内容
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trip.itinerary.isNotEmpty)
                  ..._buildItineraryItems()
                else
                  _buildEmptyState(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItineraryItems() {
    final itinerary = trip.itinerary;
    if (itinerary.isEmpty) {
      return [];
    }

    return itinerary.asMap().entries.map((entry) {
      final index = entry.key;
      final plan = entry.value;
      final isLast = index == itinerary.length - 1;

      return Column(
        children: [
          _buildDayPlan(plan),
          if (!isLast) const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _buildDayPlan(DailyPlanModel plan) {
    return Container(
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
                        if (plan.startPoint != null &&
                            plan.endPoint != null) ...[
                          Text(
                            '${plan.startPoint} → ${plan.endPoint}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
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
                        plan.duration,
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
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Column(
        children: [
          Icon(
            CupertinoIcons.calendar,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无详细行程安排',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '行程规划完成后将显示详细的每日安排',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
