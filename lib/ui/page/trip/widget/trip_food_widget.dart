import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:walk/model/model/food/day_meal_plan_model.dart';
import 'package:walk/model/model/food/meal_plan_model.dart';
import 'package:walk/model/model/food/food_item_model.dart';
import 'package:walk/model/model/food/food_type.dart';

class TripFoodWidget extends StatelessWidget {
  final MealPlanModel? mealPlan;
  const TripFoodWidget({
    super.key,
    required this.mealPlan,
  });

  @override
  Widget build(BuildContext context) {
    if (mealPlan == null || mealPlan!.dayMealPlans.isEmpty) {
      return const Text(
        '暂无膳食计划',
        style: TextStyle(
          fontSize: 16,
          color: CupertinoColors.systemGrey,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 膳食计划基本信息
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mealPlan!.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mealPlan!.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoItem(
                    icon: CupertinoIcons.person_2_fill,
                    label: '${mealPlan!.personCount}人',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: CupertinoIcons.calendar,
                    label: '${mealPlan!.tripDays}天',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: CupertinoIcons.flame_fill,
                    label:
                        '${mealPlan!.caloriesPerPersonPerDay.toStringAsFixed(0)}卡/人/天',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoItem(
                    icon: CupertinoIcons.arrow_up_right_square_fill,
                    label: '总重量: ${_formatWeight(mealPlan!.totalWeight)}',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: CupertinoIcons.bag_fill,
                    label:
                        '人均: ${_formatWeight(mealPlan!.weightPerPersonPerDay)}/天',
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 每日膳食计划
        ...mealPlan!.dayMealPlans
            .map((dayPlan) => _buildDayMealPlan(dayPlan))
            .toList(),
      ],
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: CupertinoColors.activeOrange,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  String _formatWeight(double weight) {
    if (weight >= 1000) {
      return '${(weight / 1000).toStringAsFixed(1)}kg';
    } else {
      return '${weight.toStringAsFixed(0)}g';
    }
  }

  Widget _buildDayMealPlan(DayMealPlanModel dayPlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '第${dayPlan.dayNumber}天膳食计划',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 早餐
        if (dayPlan.breakfast.isNotEmpty)
          _buildMealSection(
              '早餐', dayPlan.breakfast, CupertinoIcons.sunrise_fill),

        // 午餐
        if (dayPlan.lunch.isNotEmpty)
          _buildMealSection('午餐', dayPlan.lunch, CupertinoIcons.sun_max_fill),

        // 晚餐
        if (dayPlan.dinner.isNotEmpty)
          _buildMealSection('晚餐', dayPlan.dinner, CupertinoIcons.sunset_fill),

        // 零食
        if (dayPlan.snacks.isNotEmpty)
          _buildMealSection('零食', dayPlan.snacks, CupertinoIcons.gift_fill),

        // 饮料
        if (dayPlan.drinks.isNotEmpty)
          _buildMealSection('饮料', dayPlan.drinks, CupertinoIcons.drop_fill),

        const SizedBox(height: 8),

        // 每日统计
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CupertinoColors.systemGrey5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionInfo('总重量', _formatWeight(dayPlan.totalWeight)),
              _buildNutritionInfo(
                  '卡路里', '${dayPlan.totalCalories.toStringAsFixed(0)}卡'),
              _buildNutritionInfo(
                  '蛋白质', '${dayPlan.totalProtein.toStringAsFixed(0)}g'),
              _buildNutritionInfo(
                  '脂肪', '${dayPlan.totalFat.toStringAsFixed(0)}g'),
              _buildNutritionInfo(
                  '碳水', '${dayPlan.totalCarbs.toStringAsFixed(0)}g'),
            ],
          ),
        ),

        const Divider(height: 32),
      ],
    );
  }

  Widget _buildMealSection(
      String title, List<FoodItemModel> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: CupertinoColors.activeOrange,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildFoodItem(item)).toList(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFoodItem(FoodItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 食物图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.activeOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.cart,
              color: CupertinoColors.activeOrange,
            ),
          ),

          const SizedBox(width: 12),

          // 食物信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatWeight(item.weight)} × ${item.quantity} · 热量: ${item.totalCalories.toStringAsFixed(0)}卡',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
