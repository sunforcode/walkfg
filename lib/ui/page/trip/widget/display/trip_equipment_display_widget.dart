import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 装备展示组件
class TripEquipmentDisplayWidget extends StatefulWidget {
  final TripModel trip;

  const TripEquipmentDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  State<TripEquipmentDisplayWidget> createState() =>
      _TripEquipmentDisplayWidgetState();
}

class _TripEquipmentDisplayWidgetState
    extends State<TripEquipmentDisplayWidget> {
  bool _showAll = false;
  static const int _maxDisplayCount = 3;

  @override
  Widget build(BuildContext context) {
    // 模拟装备数据
    final mockEquipments = _getMockEquipments();
    final displayEquipments = _showAll
        ? mockEquipments
        : mockEquipments.take(_maxDisplayCount).toList();
    final hasMore = mockEquipments.length > _maxDisplayCount;
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.bag,
                size: 20,
                color: CupertinoColors.systemPurple,
              ),
              const SizedBox(width: 8),
              const Text(
                '装备清单',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getEquipmentSummary(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 统计信息卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CupertinoColors.separator,
                width: 0.5,
              ),
            ),
            child: Row(
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
          ),

          const SizedBox(height: 16),

          // 装备列表
          if (mockEquipments.isNotEmpty) ...[
            ...displayEquipments.map((equipment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEquipmentCard(equipment),
              );
            }).toList(),

            // 更多按钮
            if (hasMore && !_showAll)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _showAll = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '查看更多装备',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${mockEquipments.length - _maxDisplayCount}个)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: CupertinoColors.systemPurple,
                      ),
                    ],
                  ),
                ),
              ),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockEquipments() {
    return [
      {
        'name': '登山包',
        'category': '背包',
        'weight': '2.5kg',
        'status': '已准备',
        'icon': '🎒'
      },
      {
        'name': '登山鞋',
        'category': '鞋类',
        'weight': '1.2kg',
        'status': '已准备',
        'icon': '👟'
      },
      {
        'name': '冲锋衣',
        'category': '服装',
        'weight': '0.8kg',
        'status': '已准备',
        'icon': '🧥'
      },
      {
        'name': '睡袋',
        'category': '睡眠',
        'weight': '1.5kg',
        'status': '未准备',
        'icon': '🛏️'
      },
      {
        'name': '头灯',
        'category': '照明',
        'weight': '0.2kg',
        'status': '已准备',
        'icon': '🔦'
      },
    ];
  }

  Widget _buildEquipmentCard(Map<String, dynamic> equipment) {
    final isPrepared = equipment['status'] == '已准备';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Row(
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
    );
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
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
    if (widget.trip.equipmentList == null ||
        widget.trip.equipmentList!.totalItems == 0) {
      return '暂无装备';
    }
    final prepared =
        widget.trip.equipmentList!.equipments.where((e) => e.isOwned).length;
    final total = widget.trip.equipmentList!.totalItems;
    return '$prepared/$total 已准备';
  }

  String _getTotalWeight() {
    if (widget.trip.equipmentList == null) return '0';
    return widget.trip.equipmentList!.totalWeight.toStringAsFixed(1);
  }

  int _getPreparedCount() {
    return 15; // 模拟数据
  }

  int _getCompletionRate() {
    return 75; // 模拟数据
  }
}
