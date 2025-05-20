import 'package:flutter/material.dart';
import '../../../../model/equipment/equipment_model.dart';
import 'equipment_item_tile.dart';

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
                  if (category.icon != null) ...[
                    Icon(
                      IconData(
                        int.parse(category.icon!),
                        fontFamily: 'MaterialIcons',
                      ),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${category.itemCount}件',
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