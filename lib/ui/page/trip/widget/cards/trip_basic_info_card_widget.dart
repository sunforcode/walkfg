import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/ui/page/trip/widget/trip_info_row_widget.dart';

/// 行程基本信息卡片组件
/// 
/// 用于显示行程的基本信息，包括名称、日期、人数等
class TripBasicInfoCardWidget extends StatelessWidget {
  /// 行程数据
  final TripModel trip;
  
  /// 是否处于编辑模式
  final bool isEditMode;
  
  /// 当前正在编辑的部分ID
  final String? editingSectionId;
  
  /// 编辑按钮点击回调
  final Function(String) onEdit;
  
  /// 保存按钮点击回调
  final Function(String) onSave;
  
  /// 切换编辑模式回调
  final VoidCallback onToggleEditMode;
  
  /// 名称变更回调
  final ValueChanged<String>? onNameChanged;
  
  /// 开始日期选择回调
  final Function(DateTime) onStartDateSelected;
  
  /// 结束日期选择回调
  final Function(DateTime) onEndDateSelected;
  
  /// 日期选择器显示回调
  final Function(DateTime, Function(DateTime)) onShowDatePicker;
  
  /// 构造函数
  const TripBasicInfoCardWidget({
    Key? key,
    required this.trip,
    required this.isEditMode,
    required this.editingSectionId,
    required this.onEdit,
    required this.onSave,
    required this.onToggleEditMode,
    required this.onNameChanged,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
    required this.onShowDatePicker,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 计算行程天数
    final tripDays = trip.endDate.difference(trip.startDate).inDays + 1;
    
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey5.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.doc_text_search,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '行程概览',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // 卡片内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TripInfoRowWidget(
                  label: '行程名称',
                  value: trip.name,
                  icon: CupertinoIcons.doc_text,
                  color: AppColors.primary,
                  isEditing: isEditMode && editingSectionId == 'basic_info',
                  onChanged: onNameChanged,
                ),
                
                const SizedBox(height: 16),
                
                TripInfoRowWidget(
                  label: '出发日期',
                  value: '${trip.startDate.year}年${trip.startDate.month}月${trip.startDate.day}日',
                  icon: CupertinoIcons.calendar,
                  color: AppColors.primary,
                  isEditing: isEditMode && editingSectionId == 'basic_info',
                  onTap: isEditMode && editingSectionId == 'basic_info'
                      ? () => onShowDatePicker(trip.startDate, onStartDateSelected)
                      : null,
                ),
                
                const SizedBox(height: 16),
                
                TripInfoRowWidget(
                  label: '结束日期',
                  value: '${trip.endDate.year}年${trip.endDate.month}月${trip.endDate.day}日',
                  icon: CupertinoIcons.calendar,
                  color: AppColors.primary,
                  isEditing: isEditMode && editingSectionId == 'basic_info',
                  onTap: isEditMode && editingSectionId == 'basic_info'
                      ? () => onShowDatePicker(trip.endDate, onEndDateSelected)
                      : null,
                ),
                
                const SizedBox(height: 16),
                
                TripInfoRowWidget(
                  label: '参与人数',
                  value: '${trip.participants.length} 人',
                  icon: CupertinoIcons.person_2_fill,
                  color: AppColors.primary,
                ),
                
                const SizedBox(height: 16),
                
                TripInfoRowWidget(
                  label: '行程天数',
                  value: '$tripDays 天',
                  icon: CupertinoIcons.time,
                  color: AppColors.primary,
                ),
                
                if (isEditMode && editingSectionId != 'basic_info' || !isEditMode) ...[
                  const SizedBox(height: 16),

                  // 编辑按钮
                  Center(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.pencil,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '编辑基本信息',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onPressed: isEditMode
                          ? () => onEdit('basic_info')
                          : onToggleEditMode,
                    ),
                  ),
                ],
                
                if (isEditMode && editingSectionId == 'basic_info') ...[
                  const SizedBox(height: 16),

                  // 完成编辑按钮
                  Center(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.check_mark,
                            color: CupertinoColors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '完成编辑',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () => onSave('basic_info'),
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
}