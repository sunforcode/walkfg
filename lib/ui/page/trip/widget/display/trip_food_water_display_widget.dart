import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 食物饮水展示组件
class TripFoodWaterDisplayWidget extends StatelessWidget {
  final TripModel trip;

  const TripFoodWaterDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final hasMealPlan = trip.mealPlan != null;
    final hasWaterPlan = trip.waterPlan != null;

    if (!hasMealPlan && !hasWaterPlan) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.bag,
                size: 20,
                color: CupertinoColors.systemGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                '食物饮水',
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
                  '已规划',
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

          // 食物饮水信息卡片
          Container(
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
                if (hasMealPlan) ...[
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.square_favorites_alt,
                        size: 16,
                        color: CupertinoColors.systemOrange,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '餐食计划',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '已设置',
                          style: TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.systemOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '餐食计划详情展示区域',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],

                if (hasMealPlan && hasWaterPlan) const SizedBox(height: 16),

                if (hasWaterPlan) ...[
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.drop,
                        size: 16,
                        color: CupertinoColors.systemBlue,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '饮水计划',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '已设置',
                          style: TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.systemBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '饮水计划详情展示区域',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],

                // 提醒信息
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.info_circle,
                        size: 14,
                        color: CupertinoColors.systemYellow,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '请根据行程天数和人数合理规划食物和饮水，确保营养均衡',
                          style: TextStyle(
                            fontSize: 11,
                            color: CupertinoColors.label,
                          ),
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
}
