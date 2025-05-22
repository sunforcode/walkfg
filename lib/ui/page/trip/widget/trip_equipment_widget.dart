import 'package:flutter/cupertino.dart';
import 'package:walk/model/equipment/equipment_model.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/equipment/equipment_necessity.dart';

class TripEquipmentWidget extends StatelessWidget {
  final EquipmentListModel listModel;

  const TripEquipmentWidget({
    super.key,
    required this.listModel,
  });

  @override
  Widget build(BuildContext context) {
    // 获取所有装备项目
    final allItems = <EquipmentItemModel>[];
    for (final category in listModel.categories) {
      allItems.addAll(category.items);
    }

    if (allItems.isEmpty) {
      return const Text(
        '暂无装备清单',
        style: TextStyle(
          fontSize: 16,
          color: CupertinoColors.systemGrey,
        ),
      );
    }

    return Column(
      children: allItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.necessity == EquipmentNecessity.essential
                  ? CupertinoColors.systemRed.withOpacity(0.3)
                  : CupertinoColors.systemGrey5,
            ),
          ),
          child: Row(
            children: [
              // 装备图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.cube_box,
                  color: CupertinoColors.systemGrey,
                ),
              ),

              const SizedBox(width: 12),

              // 装备信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.necessity == EquipmentNecessity.essential) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.getNecessityText(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: CupertinoColors.systemRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.category} · 数量: ${item.quantity} · 重量: ${item.getWeightText()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.notes!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
