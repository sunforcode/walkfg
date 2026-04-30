import 'package:flutter/cupertino.dart';
import '../../../../../model/route/daily_plan_model.dart';

/// 每日行程列表组件（横向滑动）
class DailyItineraryListWidget extends StatelessWidget {
  final List<DailyPlanModel> dailyPlans;
  final Function(int dayIndex)? onDayTap;

  const DailyItineraryListWidget({
    super.key,
    required this.dailyPlans,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyPlans.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Text(
                '每日行程',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${dailyPlans.length}天',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.activeBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 横向列表
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: dailyPlans.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  _buildDayCard(context, index, dailyPlans[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, int dayIndex, DailyPlanModel plan) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onDayTap?.call(dayIndex),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day 标签 + 时间
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Day ${dayIndex + 1}',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${plan.estimatedTime.toStringAsFixed(1)}h',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 标题
            Text(
              plan.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // 统计数据行
            Row(
              children: [
                _miniStat(
                  CupertinoIcons.location,
                  '${plan.distance.toStringAsFixed(1)}km',
                  CupertinoColors.systemBlue,
                ),
                const SizedBox(width: 8),
                _miniStat(
                  CupertinoIcons.arrow_up,
                  '${plan.elevationGain}m',
                  CupertinoColors.systemGreen,
                ),
                const SizedBox(width: 8),
                _miniStat(
                  CupertinoIcons.arrow_down,
                  '${plan.elevationLoss}m',
                  CupertinoColors.systemOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
