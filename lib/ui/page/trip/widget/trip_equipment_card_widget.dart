import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/model/equipment/equipment_necessity.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/page/trip/widget/trip_card_template.dart';

/// 行程装备卡片组件
///
/// 用于显示行程的装备清单和准备进度
class TripEquipmentCardWidget extends StatefulWidget {
  /// 装备清单
  final EquipmentListModel listModel;

  /// 是否处于编辑模式
  final bool isEditMode;

  /// 当前正在编辑的部分ID
  final String? editingSectionId;

  /// 编辑按钮点击回调
  final Function(String) onEdit;

  /// 保存按钮点击回调
  final Function(String) onSave;

  /// 构造函数
  const TripEquipmentCardWidget({
    Key? key,
    required this.listModel,
    required this.isEditMode,
    required this.editingSectionId,
    required this.onEdit,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TripEquipmentCardWidget> createState() =>
      _TripEquipmentCardWidgetState();
}

class _TripEquipmentCardWidgetState extends State<TripEquipmentCardWidget> {
  /// 当前选中的分类索引
  int _currentCategory = 0;

  @override
  Widget build(BuildContext context) {
    // 获取所有装备项
    final allItems = widget.listModel.allItems;

    // 根据分类筛选装备
    final filteredItems = _filterEquipmentByCategory(allItems);

    // 计算已准备的装备数量
    final preparedCount = allItems.where((item) => item.prepared).length;
    final totalCount = allItems.length;
    final progressPercentage =
        totalCount > 0 ? preparedCount / totalCount : 0.0;

    // 创建编辑按钮
    final editButton = widget.isEditMode &&
            widget.editingSectionId != 'equipment'
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
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
            onPressed: () => widget.onEdit('equipment'),
          )
        : null;

    // 创建保存按钮
    final saveButton = widget.isEditMode &&
            widget.editingSectionId == 'equipment'
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
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
            onPressed: () => widget.onSave('equipment'),
          )
        : null;

    return Column(
      children: [
        // 装备准备进度卡片
        TripCardTemplate(
          title: '装备准备进度',
          icon: CupertinoIcons.chart_bar_fill,
          usePrimaryHeader: false,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 进度文本
              Text(
                '已准备: $preparedCount/$totalCount (${(progressPercentage * 100).toInt()}%)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),

              // 进度条
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.8 *
                          progressPercentage,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 分类进度
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryProgress(
                    '必备',
                    allItems
                        .where((item) =>
                            item.necessity == EquipmentNecessity.essential)
                        .toList(),
                    CupertinoColors.systemRed,
                  ),
                  _buildCategoryProgress(
                    '推荐',
                    allItems
                        .where((item) =>
                            item.necessity == EquipmentNecessity.recommended)
                        .toList(),
                    CupertinoColors.activeOrange,
                  ),
                  _buildCategoryProgress(
                    '可选',
                    allItems
                        .where((item) =>
                            item.necessity == EquipmentNecessity.optional)
                        .toList(),
                    CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ],
          ),
          infoText: '建议背包总重量不超过${widget.listModel.totalWeight}kg，可以考虑减轻一些非必要装备',
        ),

        const SizedBox(height: 16),

        // 装备清单卡片
        TripCardTemplate(
          title: '装备清单',
          icon: CupertinoIcons.bag,
          usePrimaryHeader: true,
          actionButton: widget.isEditMode
              ? (widget.editingSectionId == 'equipment'
                  ? saveButton
                  : editButton)
              : null,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 分类选择器
              Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildCategoryTab('全部', 0),
                    _buildCategoryTab('必备', 1),
                    _buildCategoryTab('推荐', 2),
                    _buildCategoryTab('可选', 3),
                  ],
                ),
              ),

              // 装备列表
              if (filteredItems.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('暂无装备'),
                  ),
                )
              else
                Column(
                  children: [
                    // 表头
                    Row(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: Text(
                            '装备名称',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '重要性',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '状态',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(),

                    // 装备项
                    ...filteredItems
                        .map((item) => _buildEquipmentItem(item))
                        .toList(),
                  ],
                ),

              // 编辑模式下的添加按钮
              if (widget.isEditMode &&
                  widget.editingSectionId == 'equipment') ...[
                const SizedBox(height: 16),
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.add,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '添加装备',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    // TODO: 显示添加装备对话框
                  },
                ),
              ],
            ],
          ),
          buttonText: widget.isEditMode ? null : '查看完整装备清单',
          onButtonPressed: widget.isEditMode
              ? null
              : () {
                  // TODO: 跳转到完整装备清单页面
                },
        ),
      ],
    );
  }

  /// 构建分类标签
  Widget _buildCategoryTab(String label, int index) {
    final isSelected = _currentCategory == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentCategory = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? CupertinoColors.white : CupertinoColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建装备项
  Widget _buildEquipmentItem(EquipmentItemModel item) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              item.necessity == EquipmentNecessity.essential
                  ? '必备'
                  : item.necessity == EquipmentNecessity.recommended
                      ? '推荐'
                      : '可选',
              style: TextStyle(
                fontSize: 14,
                color: item.necessity == EquipmentNecessity.essential
                    ? CupertinoColors.systemRed
                    : item.necessity == EquipmentNecessity.recommended
                        ? CupertinoColors.activeOrange
                        : CupertinoColors.systemGrey,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              item.prepared ? '已准备' : '未准备',
              style: TextStyle(
                fontSize: 14,
                color: item.prepared
                    ? CupertinoColors.activeGreen
                    : CupertinoColors.systemGrey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建分类进度
  Widget _buildCategoryProgress(
      String name, List<EquipmentItemModel> items, Color color) {
    final preparedCount = items.where((item) => item.prepared).length;
    final totalCount = items.length;
    final progressPercentage =
        totalCount > 0 ? preparedCount / totalCount : 0.0;

    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$preparedCount/$totalCount',
          style: TextStyle(
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          height: 4,
          child: LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: CupertinoColors.systemGrey5,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// 根据分类筛选装备
  List<EquipmentItemModel> _filterEquipmentByCategory(
      List<EquipmentItemModel> equipment) {
    print("object");
    print(equipment.length);
    if (_currentCategory == 0) {
      return equipment;
    }

    // 根据必要性筛选
    return equipment.where((item) {
      switch (_currentCategory) {
        case 1: // 必备
          return item.necessity == EquipmentNecessity.essential;
        case 2: // 推荐
          return item.necessity == EquipmentNecessity.recommended;
        case 3: // 可选
          return item.necessity == EquipmentNecessity.optional;
        default:
          return true;
      }
    }).toList();
  }
}
