import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/equipment/equipment_category.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';

/// 装备清单概览组件
class TripEquipmentSummaryWidget extends StatelessWidget {
  final EquipmentListModel? equipmentList;
  final Function() onManage;

  const TripEquipmentSummaryWidget({
    super.key,
    required this.equipmentList,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    if (equipmentList == null) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 重量统计
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.gauge,
                  label: '总重量',
                  value: '${equipmentList!.totalWeight.toStringAsFixed(1)}kg',
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.bag,
                  label: '基础重量',
                  value: '${equipmentList!.baseWeight.toStringAsFixed(1)}kg',
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 进度条
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '准备进度',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.label,
                    ),
                  ),
                  Text(
                    '${(_getProgressPercentage() * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _getProgressPercentage(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getProgressColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 分类统计
          if (equipmentList!.equipments.isNotEmpty) ...[
            const Divider(height: 1),
            const SizedBox(height: 16),
            ..._buildCategoryStats(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.bag_badge_plus,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无装备清单',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI将为您推荐合适的装备清单',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            child: const Text('生成装备清单'),
            onPressed: onManage,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryStats() {
    final categoryStats = <EquipmentCategory, Map<String, int>>{};

    // 统计各分类的装备数量
    for (final equipment in equipmentList!.equipments) {
      final category = equipment.category;
      if (!categoryStats.containsKey(category)) {
        categoryStats[category] = {'total': 0, 'prepared': 0};
      }
      categoryStats[category]!['total'] =
          categoryStats[category]!['total']! + 1;
      if (equipment.isOwned) {
        categoryStats[category]!['prepared'] =
            categoryStats[category]!['prepared']! + 1;
      }
    }

    return categoryStats.entries.map((entry) {
      final category = entry.key;
      final total = entry.value['total']!;
      final prepared = entry.value['prepared']!;
      final progress = total > 0 ? prepared / total : 0.0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 20,
              color: _getCategoryColor(category),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getCategoryName(category),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                      ),
                      Text(
                        '$prepared/$total',
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: progress == 1.0
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.systemOrange,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (progress == 1.0)
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                size: 16,
                color: CupertinoColors.systemGreen,
              )
            else
              const Icon(
                CupertinoIcons.clock_fill,
                size: 16,
                color: CupertinoColors.systemOrange,
              ),
          ],
        ),
      );
    }).toList();
  }

  int _getPreparedCount() {
    if (equipmentList == null) return 0;
    return equipmentList!.equipments.where((e) => e.isOwned).length;
  }

  double _getProgressPercentage() {
    if (equipmentList == null || equipmentList!.totalItems == 0) return 0.0;
    return _getPreparedCount() / equipmentList!.totalItems;
  }

  Color _getProgressColor() {
    final progress = _getProgressPercentage();
    if (progress == 1.0) return CupertinoColors.systemGreen;
    if (progress >= 0.7) return CupertinoColors.systemBlue;
    if (progress >= 0.3) return CupertinoColors.systemOrange;
    return CupertinoColors.systemRed;
  }

  IconData _getCategoryIcon(EquipmentCategory category) {
    switch (category) {
      case EquipmentCategory.shelter:
        return CupertinoIcons.house;
      case EquipmentCategory.food:
        return CupertinoIcons.flame;
      case EquipmentCategory.clothing:
        return CupertinoIcons.person_crop_circle; // 替换tshirt
      case EquipmentCategory.backpack:
        return CupertinoIcons.bag;
      case EquipmentCategory.navigation:
        return CupertinoIcons.compass;
      case EquipmentCategory.lighting:
        return CupertinoIcons.lightbulb;
      case EquipmentCategory.firstAid:
        return CupertinoIcons.heart;
      case EquipmentCategory.tools:
        return CupertinoIcons.wrench;
      case EquipmentCategory.electronics:
        return CupertinoIcons.device_phone_portrait;
      case EquipmentCategory.personalCare:
        return CupertinoIcons.person;
      case EquipmentCategory.other:
        return CupertinoIcons.ellipsis;
    }
  }

  Color _getCategoryColor(EquipmentCategory category) {
    switch (category) {
      case EquipmentCategory.shelter:
        return CupertinoColors.systemGreen;
      case EquipmentCategory.food:
        return CupertinoColors.systemOrange;
      case EquipmentCategory.clothing:
        return CupertinoColors.systemBlue;
      case EquipmentCategory.backpack:
        return CupertinoColors.systemPurple;
      case EquipmentCategory.navigation:
        return CupertinoColors.systemTeal;
      case EquipmentCategory.lighting:
        return CupertinoColors.systemYellow;
      case EquipmentCategory.firstAid:
        return CupertinoColors.systemRed;
      case EquipmentCategory.tools:
        return CupertinoColors.systemGrey;
      case EquipmentCategory.electronics:
        return CupertinoColors.systemIndigo;
      case EquipmentCategory.personalCare:
        return CupertinoColors.systemPink;
      case EquipmentCategory.other:
        return CupertinoColors.systemGrey2;
    }
  }
}
