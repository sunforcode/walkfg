import 'package:flutter/material.dart';
import '../../../../model/equipment/equipment_model.dart';
import '../../../../model/equipment/equipment_item_model.dart';
import 'equipment_item_tile.dart';

/// 装备列表组件
class EquipmentCategoryList extends StatelessWidget {
  /// 装备列表
  final List<EquipmentItemModel> equipments;

  /// 构造函数
  const EquipmentCategoryList({
    super.key,
    required this.equipments,
  });

  @override
  Widget build(BuildContext context) {
    // 按分类对装备进行分组
    final Map<String, List<EquipmentItemModel>> categoryMap = {};
    for (final item in equipments) {
      if (!categoryMap.containsKey(item.category)) {
        categoryMap[item.category] = [];
      }
      categoryMap[item.category]!.add(item);
    }

    // 将分组后的装备转换为列表
    final categories = categoryMap.entries.map((entry) {
      return EquipmentCategory(
        name: entry.key,
        items: entry.value,
      );
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return EquipmentCategoryCard(
          category: category,
        );
      },
    );
  }
}

/// 装备分类卡片组件
class EquipmentCategoryCard extends StatefulWidget {
  /// 装备分类
  final EquipmentCategory category;

  /// 构造函数
  const EquipmentCategoryCard({
    super.key,
    required this.category,
  });

  @override
  State<EquipmentCategoryCard> createState() => _EquipmentCategoryCardState();
}

class _EquipmentCategoryCardState extends State<EquipmentCategoryCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = widget.category;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${category.items.length}件',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          // 分类内容
          if (_isExpanded)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: category.items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = category.items[index];
                return EquipmentItemTile(item: item);
              },
            ),
        ],
      ),
    );
  }
}
