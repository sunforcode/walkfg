import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/model/route/daily_plan_model.dart';

/// 每日行程展示组件
class TripItineraryDisplayWidget extends StatefulWidget {
  final TripModel trip;

  const TripItineraryDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  State<TripItineraryDisplayWidget> createState() =>
      _TripItineraryDisplayWidgetState();
}

class _TripItineraryDisplayWidgetState
    extends State<TripItineraryDisplayWidget> {
  bool _showAll = false;
  static const int _maxDisplayCount = 3;

  @override
  Widget build(BuildContext context) {
    final itinerary = widget.trip.itinerary;
    final displayItinerary =
        _showAll ? itinerary : itinerary.take(_maxDisplayCount).toList();
    final hasMore = itinerary.length > _maxDisplayCount;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.calendar,
                size: 20,
                color: CupertinoColors.systemGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                '每日行程',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${itinerary.length}天',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 行程内容
          if (itinerary.isNotEmpty) ...[
            ...displayItinerary.map((plan) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDayPlan(plan),
              );
            }).toList(),
            // 更多按钮
            if (hasMore && !_showAll)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _showAll = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '查看更多行程',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${itinerary.length - _maxDisplayCount}天)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: CupertinoColors.systemGreen,
                      ),
                    ],
                  ),
                ),
              ),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildDayPlan(DailyPlanModel plan) {
    return Container(
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
                        Text(
                          '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(width: 16),
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
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
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
