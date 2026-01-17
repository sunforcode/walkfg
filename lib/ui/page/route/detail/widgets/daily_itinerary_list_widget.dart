import 'package:flutter/cupertino.dart';
import '../../../../../model/route/daily_plan_model.dart';

/// 每日行程列表组件
class DailyItineraryListWidget extends StatelessWidget {
  /// 每日行程计划
  final List<DailyPlanModel> dailyPlans;

  /// 点击某天的回调
  final Function(int dayIndex)? onDayTap;

  const DailyItineraryListWidget({
    super.key,
    required this.dailyPlans,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyPlans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Text(
            '每日行程',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),

          // 每日行程列表
          ...dailyPlans.asMap().entries.map((entry) {
            final index = entry.key;
            final plan = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDayCard(context, index, plan),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建每日卡片
  Widget _buildDayCard(
      BuildContext context, int dayIndex, DailyPlanModel plan) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onDayTap?.call(dayIndex),
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
            // 标题行
            _buildDayHeader(dayIndex, plan),

            const SizedBox(height: 12),

            // 起止点信息
            _buildRouteInfo(plan),

            const SizedBox(height: 12),

            // 统计信息
            _buildStatsInfo(plan),

            const SizedBox(height: 12),

            // 关键点信息
            _buildKeyPointsInfo(plan),

            // 住宿信息
            if (plan.accommodation != null &&
                plan.accommodation!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildAccommodationInfo(plan),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建日期标题
  Widget _buildDayHeader(int dayIndex, DailyPlanModel plan) {
    return Row(
      children: [
        // 天数标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Day ${dayIndex + 1}',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 标题
        Expanded(
          child: Text(
            plan.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
        ),

        // 预计时间
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${plan.estimatedTime.toStringAsFixed(1)}h',
            style: const TextStyle(
              color: CupertinoColors.systemGreen,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建路线信息
  Widget _buildRouteInfo(DailyPlanModel plan) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 起点
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.location,
                      size: 14,
                      color: CupertinoColors.systemGreen,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '起点',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),

          // 箭头
          Icon(
            CupertinoIcons.arrow_right,
            size: 16,
            color: CupertinoColors.systemGrey,
          ),

          // 终点
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      '终点',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.location_fill,
                      size: 14,
                      color: CupertinoColors.systemRed,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计信息
  Widget _buildStatsInfo(DailyPlanModel plan) {
    return Row(
      children: [
        // 距离
        Expanded(
          child: _buildStatItem(
            icon: CupertinoIcons.location,
            label: '距离',
            value: '${(plan.distance ?? 0).toStringAsFixed(1)}km',
            color: CupertinoColors.systemBlue,
          ),
        ),

        // 上升
        Expanded(
          child: _buildStatItem(
            icon: CupertinoIcons.arrow_up,
            label: '上升',
            value: '${plan.elevationGain ?? 0}m',
            color: CupertinoColors.systemGreen,
          ),
        ),

        // 下降
        Expanded(
          child: _buildStatItem(
            icon: CupertinoIcons.arrow_down,
            label: '下降',
            value: '${plan.elevationLoss ?? 0}m',
            color: CupertinoColors.systemOrange,
          ),
        ),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: CupertinoColors.systemGrey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建关键点信息
  Widget _buildKeyPointsInfo(DailyPlanModel plan) {
    final keyPoints = <Map<String, dynamic>>[];

    if (keyPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: keyPoints
          .map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      point['icon'],
                      size: 14,
                      color: point['color'],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${point['label']}：',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point['value'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  /// 构建住宿信息
  Widget _buildAccommodationInfo(DailyPlanModel plan) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.house,
            size: 14,
            color: CupertinoColors.systemYellow,
          ),
          const SizedBox(width: 6),
          const Text(
            '住宿：',
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
          Expanded(
            child: Text(
              plan.accommodation!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
