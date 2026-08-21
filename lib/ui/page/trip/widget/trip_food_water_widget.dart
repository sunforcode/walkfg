import 'package:flutter/cupertino.dart';
import 'package:walk/model/food/meal_plan_model.dart';
import 'package:walk/model/water/water_plan_model.dart';

/// 食物和饮水规划组件
class TripFoodWaterWidget extends StatelessWidget {
  final MealPlanModel? mealPlan;
  final WaterPlanModel? waterPlan;
  final int days;
  final int participantCount;
  final Function() onManage;

  const TripFoodWaterWidget({
    super.key,
    required this.mealPlan,
    required this.waterPlan,
    required this.days,
    required this.participantCount,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    if (mealPlan == null && waterPlan == null) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 食物规划
          if (mealPlan != null) ...[
            Row(
              children: [
                const Icon(
                  CupertinoIcons.flame,
                  size: 20,
                  color: CupertinoColors.systemOrange,
                ),
                const SizedBox(width: 8),
                const Text(
                  '餐食安排',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildMealPlanItems(),
            const SizedBox(height: 16),
          ],

          // 饮水规划
          if (waterPlan != null) ...[
            Row(
              children: [
                const Icon(
                  CupertinoIcons.drop,
                  size: 20,
                  color: CupertinoColors.systemBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  '饮水计划',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildWaterPlanItems(),
          ],
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
            CupertinoIcons.flame,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无食物饮水规划',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '制定合理的食物和饮水计划，确保行程安全',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            child: const Text('制定计划'),
            onPressed: onManage,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMealPlanItems() {
    // 模拟餐食数据
    final meals = [
      {'day': 1, 'type': '早餐', 'content': '燕麦粥 + 坚果', 'icon': '🌅'},
      {'day': 1, 'type': '午餐', 'content': '自热米饭 + 牛肉', 'icon': '☀️'},
      {'day': 1, 'type': '晚餐', 'content': '山寨晚餐 + 热汤', 'icon': '🌙'},
      {'day': 2, 'type': '早餐', 'content': '酒店早餐', 'icon': '🌅'},
      {'day': 2, 'type': '午餐', 'content': '能量棒 + 干果', 'icon': '☀️'},
    ];

    return meals.map((meal) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  meal['icon'] as String,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '第${meal['day']}天 ${meal['type']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meal['content'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel,
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

  List<Widget> _buildWaterPlanItems() {
    // 模拟饮水数据
    final waterInfo = [
      {
        'title': '每人每天需水量',
        'value': '3L',
        'icon': CupertinoIcons.drop_fill,
        'color': CupertinoColors.systemBlue,
      },
      {
        'title': '总需水量',
        'value': '${3 * days * participantCount}L',
        'icon': CupertinoIcons.drop_triangle,
        'color': CupertinoColors.systemTeal,
      },
      {
        'title': '补水点',
        'value': '半山寺、光明顶',
        'icon': CupertinoIcons.location_solid,
        'color': CupertinoColors.systemGreen,
      },
    ];

    return [
      // 统计信息
      Row(
        children: waterInfo.map((info) {
          final isLast = info == waterInfo.last;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (info['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    info['icon'] as IconData,
                    size: 20,
                    color: info['color'] as Color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info['value'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: info['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info['title'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),

      // 注意事项
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemYellow.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              CupertinoIcons.info_circle,
              size: 16,
              color: CupertinoColors.systemYellow,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '建议携带净水片或过滤器，确保水源安全',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
