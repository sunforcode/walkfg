import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/equipment/equipment_necessity.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/page/trip_plan/components/trip_plan_card.dart';

/// 装备清单卡片
class EquipmentCard extends StatelessWidget {
  /// 装备清单
  final List<EquipmentItemModel> equipmentList;

  /// 编辑回调
  final VoidCallback onEdit;

  /// 构造函数
  const EquipmentCard({
    Key? key,
    required this.equipmentList,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 必备装备
    final essentialEquipment = equipmentList
        .where((item) => item.necessity == EquipmentNecessity.essential)
        .toList();

    return TripPlanCard(
      title: '装备清单',
      onEdit: onEdit,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 必备装备标题
          Text(
            '必备装备 (${essentialEquipment.length}件)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // 必备装备列表
          if (essentialEquipment.isEmpty)
            const Center(
              child: Text('暂无必备装备'),
            )
          else
            Table(
              columnWidths: const {
                0: FixedColumnWidth(30),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                // 表头
                const TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.systemGrey5,
                        width: 1,
                      ),
                    ),
                  ),
                  children: [
                    SizedBox(height: 30),
                    Text(
                      '装备名称',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '重要性',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '状态',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                // 装备项
                ...essentialEquipment
                    .take(4)
                    .map((item) => TableRow(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: CupertinoColors.systemGrey5,
                                width: 1,
                              ),
                            ),
                          ),
                          children: [
                            // 选择框
                            SizedBox(
                              height: 40,
                              child: Center(
                                child: Icon(
                                  item.prepared
                                      ? CupertinoIcons.checkmark_square_fill
                                      : CupertinoIcons.square,
                                  color: item.prepared
                                      ? AppColors.primary
                                      : CupertinoColors.systemGrey,
                                  size: 20,
                                ),
                              ),
                            ),

                            // 装备名称
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            // 重要性
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                item.necessity == EquipmentNecessity.essential
                                    ? '必备'
                                    : '推荐',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: item.necessity ==
                                          EquipmentNecessity.essential
                                      ? AppColors.primary
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ),

                            // 状态
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                item.isOwned ? '已拥有' : '需购买',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: item.isOwned
                                      ? CupertinoColors.activeGreen
                                      : CupertinoColors.systemOrange,
                                ),
                              ),
                            ),
                          ],
                        ))
                    .toList(),
              ],
            ),

          const SizedBox(height: 16),

          // 查看全部按钮
          if (essentialEquipment.length > 4)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onEdit,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('查看全部装备'),
                  Icon(CupertinoIcons.chevron_right, size: 14),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
