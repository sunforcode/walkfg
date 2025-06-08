import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/ui/page/trip/widget/trip_section_placeholder.dart';

/// 装备清单section组件
class TripEquipmentSection extends StatelessWidget {
  /// 行程数据
  final TripModel? trip;

  /// 是否处于编辑模式
  final bool isEditMode;

  /// 编辑回调
  final VoidCallback? onEdit;

  const TripEquipmentSection({
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
            '🎒 装备规划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),

          // 装备清单内容
          if (trip?.equipmentList != null)
            const Text('装备清单已配置') // 这里应该是实际的装备组件
          else
            TripSectionPlaceholder(
              icon: CupertinoIcons.bag_fill,
              title: '制定装备清单',
              subtitle: '根据路线和天气准备合适的装备',
              buttonText: '开始装备规划',
              onPressed: onEdit ?? () {},
            ),
        ],
      ),
    );
  }
}
