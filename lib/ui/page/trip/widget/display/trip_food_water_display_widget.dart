import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/theme/tokens/colors.dart';

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
          _buildSectionHeader(),
          const SizedBox(height: 16),

          // 食物饮水信息卡片
          _buildFoodWaterCard(hasMealPlan, hasWaterPlan),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Icon(
          CupertinoIcons.bag,
          size: 20,
          color: AppColors.statusCompletedText,
        ),
        const SizedBox(width: 8),
        const Text(
          '食物饮水',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.statusCompletedBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '已规划',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.statusCompletedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodWaterCard(bool hasMealPlan, bool hasWaterPlan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sheetCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.sheetDivider,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasMealPlan) ...[
            _buildMealPlanSection(),
          ],

          if (hasMealPlan && hasWaterPlan) const SizedBox(height: 16),

          if (hasWaterPlan) ...[
            _buildWaterPlanSection(),
          ],

          // 提醒信息
          const SizedBox(height: 12),
          _buildInfoTip(),
        ],
      ),
    );
  }

  Widget _buildMealPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.square_favorites_alt,
              size: 16,
              color: AppColors.statusPlanningText,
            ),
            const SizedBox(width: 8),
            const Text(
              '餐食计划',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.statusPlanningBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '已设置',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.statusPlanningText,
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
            color: AppColors.textWeak,
          ),
        ),
      ],
    );
  }

  Widget _buildWaterPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.drop,
              size: 16,
              color: AppColors.interactiveAccent,
            ),
            const SizedBox(width: 8),
            const Text(
              '饮水计划',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.interactiveAccentBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '已设置',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.interactiveAccent,
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
            color: AppColors.textWeak,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTip() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.statusPlanningBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.info_circle,
            size: 14,
            color: AppColors.statusPlanningText,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              '请根据行程天数和人数合理规划食物和饮水，确保营养均衡',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
