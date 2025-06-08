import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/ui/page/trip/widget/trip_section_placeholder.dart';

/// 食物计划section组件
class TripFoodSection extends StatelessWidget {
  /// 行程数据
  final TripModel? trip;

  /// 是否处于编辑模式
  final bool isEditMode;

  /// 编辑回调
  final VoidCallback? onEdit;

  const TripFoodSection({
    super.key,
    required this.trip,
    required this.isEditMode,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🍽️ 食物规划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),

          // 食物计划内容
          if (trip?.mealPlan != null)
            const Text('膳食计划已配置') // 这里应该是实际的食物组件
          else
            TripSectionPlaceholder(
              icon: CupertinoIcons.bag_badge_plus,
              title: '规划膳食计划',
              subtitle: '计算营养需求，准备合适的食物',
              buttonText: '开始食物规划',
              onPressed: onEdit ?? () {},
            ),
        ],
      ),
    );
  }
}
