import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 装备展示组件
class TripEquipmentDisplayWidget extends StatelessWidget {
  final TripModel trip;

  const TripEquipmentDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '🎒 装备清单',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const Spacer(),
                Text(
                  _getEquipmentSummary(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),

          // 装备内容
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (trip.equipmentList != null && trip.equipmentList!.equipments.isNotEmpty)
                  ..._buildEquipmentList()
                else
                  _buildEmptyState(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEquipmentList() {
    // 模拟装备数据
    final mockEquipments = [
      {'name': '登山包', 'category': '背包', 'weight': '2.5kg', 'status': '已准备', 'icon': '🎒'},
      {'name': '登山鞋', 'category': '鞋类', 'weight': '1.2kg', 'status': '已准备', 'icon': '👟'},
      {'name': '冲锋衣', 'category': '服装', 'weight': '0.8kg', 'status': '已准备', 'icon': '🧥'},
      {'name': '睡袋', 'category': '睡眠', 'weight': '1.5kg', 'status': '未准备', 'icon': '🛏️'},
      {'name': '头灯', 'category': '照明', 'weight': '0.2kg', 'status': '已准备', 'icon': '🔦'},
    ];

    return [
      // 统计信息
      Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: '总重量',
              value: '${_getTotalWeight()}kg',
              color: CupertinoColors.systemBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: '已准备',
              value: '${_getPreparedCount()}/20',
              color: CupertinoColors.systemGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: '完成度',
              value: '${_getCompletionRate()}%',
              color: CupertinoColors.systemOrange,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // 装备列表
      ...mockEquipments.asMap().entries.map((entry) {
        final index = entry.key;
        final equipment = entry.value;
        final isLast = index == mockEquipments.length - 1;
        final isPrepared = equipment['status'] == '已准备';

        return Column(
          children: [
            Row(
              children: [
                Text(
                  equipment['icon'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            equipment['category'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            equipment['weight'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.tertiaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPrepared
                        ? CupertinoColors.systemGreen.withOpacity(0.1)
                        : CupertinoColors.systemRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    equipment['status'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isPrepared
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemRed,
                    ),
                  ),
                ),
              ],
            ),
            if (!isLast) const SizedBox(height: 12),
          ],
        );
      }).toList(),
    ];
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Column(
        children: [
          Icon(
            CupertinoIcons.bag,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无装备清单',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '制定装备清单，确保行程安全',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getEquipmentSummary() {
    if (trip.equipmentList == null || trip.equipmentList!.totalItems == 0) {
      return '暂无装备';
    }
    final prepared = trip.equipmentList!.equipments.where((e) => e.isOwned).length;
    final total = trip.equipmentList!.totalItems;
    return '$prepared/$total 已准备';
  }

  String _getTotalWeight() {
    if (trip.equipmentList == null) return '0';
    return trip.equipmentList!.totalWeight.toStringAsFixed(1);
  }

  int _getPreparedCount() {
    return 15; // 模拟数据
  }

  int _getCompletionRate() {
    return 75; // 模拟数据
  }
}