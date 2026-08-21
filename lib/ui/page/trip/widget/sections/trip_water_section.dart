import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/ui/page/trip/widget/sections/trip_section_placeholder.dart';

/// 饮水计划section组件
class TripWaterSection extends StatelessWidget {
  /// 行程数据
  final TripModel? trip;

  /// 是否处于编辑模式
  final bool isEditMode;

  /// 编辑回调
  final VoidCallback? onEdit;

  const TripWaterSection({
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
            '💧 饮水规划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),

          // 饮水计划内容
          if (trip?.waterPlan != null)
            const Text('饮水计划已配置') // 这里应该是实际的饮水组件
          else
            TripSectionPlaceholder(
              icon: CupertinoIcons.drop_fill,
              title: '制定饮水计划',
              subtitle: '计算用水需求，规划水源补给',
              buttonText: '开始饮水规划',
              onPressed: onEdit ?? () {},
            ),
        ],
      ),
    );
  }
}
