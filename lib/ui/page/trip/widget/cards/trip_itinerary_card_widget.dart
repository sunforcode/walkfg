import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/model/route/daily_plan_model.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/ui/page/trip/widget/cards/trip_card_template.dart';

/// 行程安排卡片组件
///
/// 用于显示行程的每日安排
class TripItineraryCardWidget extends StatelessWidget {
  /// 行程数据
  final TripModel trip;

  /// 行程安排列表
  final List<DailyPlanModel> itinerary;

  /// 是否处于编辑模式
  final bool isEditMode;

  /// 当前正在编辑的部分ID
  final String? editingSectionId;

  /// 编辑按钮点击回调
  final Function(String) onEdit;

  /// 保存按钮点击回调
  final Function(String) onSave;

  /// 构造函数
  const TripItineraryCardWidget({
    Key? key,
    required this.trip,
    required this.itinerary,
    required this.isEditMode,
    required this.editingSectionId,
    required this.onEdit,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 创建编辑按钮
    final editButton = isEditMode && editingSectionId != 'itinerary'
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.interactiveAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '编辑',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
              ),
            ),
            onPressed: () => onEdit('itinerary'),
          )
        : null;

    // 创建保存按钮
    final saveButton = isEditMode && editingSectionId == 'itinerary'
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.interactiveAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '保存',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
              ),
            ),
            onPressed: () => onSave('itinerary'),
          )
        : null;

    return TripCardTemplate(
      title: '行程安排',
      icon: CupertinoIcons.calendar,
      usePrimaryHeader: false,
      actionButton: isEditMode
          ? (editingSectionId == 'itinerary' ? saveButton : editButton)
          : null,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 行程天数
          Text(
            '共${itinerary.length}天行程',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          // 行程列表
          ...itinerary.map((day) => _buildDaySummary(day)).toList(),

          // 编辑模式下的添加按钮
          if (isEditMode && editingSectionId == 'itinerary') ...[
            const SizedBox(height: 16),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              color: AppColors.interactiveAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.add,
                    color: AppColors.interactiveAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '添加行程日',
                    style: TextStyle(
                      color: AppColors.interactiveAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                // TODO: 显示添加行程日对话框
              },
            ),
          ],
        ],
      ),
      buttonText: isEditMode ? null : '查看详细行程',
      onButtonPressed: isEditMode
          ? null
          : () {
              // TODO: 跳转到详细行程页面
            },
    );
  }

  /// 构建日程概要
  Widget _buildDaySummary(DailyPlanModel day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.interactiveAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '第${day.day}天',
              style: TextStyle(
                color: AppColors.interactiveAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '徒步${day.distance}km，爬升${day.elevationGain}m',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
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
