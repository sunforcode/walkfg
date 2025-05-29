import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/daily_plan_model.dart';

/// 多日行程时间轴组件
class DailyPlanTimelineWidget extends StatelessWidget {
  /// 每日计划列表
  final List<DailyPlanModel> dailyPlans;

  /// 点击日程回调
  final Function(int dayIndex)? onDayTap;

  const DailyPlanTimelineWidget({
    super.key,
    required this.dailyPlans,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyPlans.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              const Icon(
                CupertinoIcons.calendar,
                size: 20,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(width: 8),
              const Text(
                '行程安排',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '共${dailyPlans.length}天',
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 时间轴
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dailyPlans.length,
              itemBuilder: (context, index) {
                final plan = dailyPlans[index];
                final isLast = index == dailyPlans.length - 1;

                return Row(
                  children: [
                    // 日程节点
                    GestureDetector(
                      onTap: () => onDayTap?.call(index),
                      child: _buildDayNode(index + 1, plan),
                    ),

                    // 连接线
                    if (!isLast) _buildConnector(),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 详细信息（可展开）
          _buildDailyDetails(),
        ],
      ),
    );
  }

  /// 构建日程节点
  Widget _buildDayNode(int dayNumber, DailyPlanModel plan) {
    return Column(
      children: [
        // 圆形节点
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: CupertinoColors.activeBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'D$dayNumber',
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 距离信息
        Text(
          '${plan.distance.toStringAsFixed(1)}km',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.activeBlue,
          ),
        ),

        // 爬升信息
        if (plan.elevationGain > 0)
          Text(
            '+${plan.elevationGain.toInt()}m',
            style: const TextStyle(
              fontSize: 10,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
      ],
    );
  }

  /// 构建连接线
  Widget _buildConnector() {
    return Container(
      width: 40,
      height: 3,
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: CupertinoColors.separator,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  /// 构建每日详情
  Widget _buildDailyDetails() {
    return Column(
      children: dailyPlans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日程标题
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: CupertinoColors.activeBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      plan.title.isNotEmpty ? plan.title : '第${index + 1}天',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${plan.estimatedTime}小时',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 路线信息
              Row(
                children: [
                  _buildInfoChip(
                    icon: CupertinoIcons.location,
                    label: '${plan.distance.toStringAsFixed(1)}km',
                    color: CupertinoColors.systemBlue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: CupertinoIcons.arrow_up,
                    label: '+${plan.elevationGain.toInt()}m',
                    color: CupertinoColors.systemGreen,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: CupertinoIcons.clock,
                    label: '${plan.estimatedTime}h',
                    color: CupertinoColors.systemOrange,
                  ),
                ],
              ),

              // 描述信息
              if (plan.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  plan.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],

              // 关键点信息
              if (plan.keyPoints.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: plan.keyPoints.map((point) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CupertinoColors.separator),
                      ),
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.label,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.calendar,
              size: 32,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: 8),
            Text(
              '暂无行程安排',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
