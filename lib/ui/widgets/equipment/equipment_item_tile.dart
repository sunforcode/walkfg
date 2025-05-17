import 'package:flutter/material.dart';
import '../../../model/equipment/equipment_model.dart';
import 'equipment_item_detail_dialog.dart';

/// 装备项目列表项组件
class EquipmentItemTile extends StatelessWidget {
  /// 装备项目
  final EquipmentItem item;

  /// 构造函数
  const EquipmentItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(item.name),
      subtitle: item.description != null ? Text(
        item.description!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Color(item.getNecessityColor()).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.getNecessityName(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Color(item.getNecessityColor()),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.getTotalWeightText(),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => EquipmentItemDetailDialog(item: item),
        );
      },
    );
  }
}