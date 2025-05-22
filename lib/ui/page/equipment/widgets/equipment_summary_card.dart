import 'package:flutter/material.dart';
import '../../../../model/equipment/equipment_model.dart';
import '../../../../model/equipment/equipment_necessity.dart';

/// 装备摘要卡片组件
class EquipmentSummaryCard extends StatelessWidget {
  /// 装备清单
  final EquipmentListModel equipmentList;

  /// 构造函数
  const EquipmentSummaryCard({
    super.key,
    required this.equipmentList,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '行程天数',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${equipmentList.tripDays}天',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '总重量',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${(equipmentList.totalWeight / 1000).toStringAsFixed(2)}kg',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 重量详情
            Text(
              '重量详情',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildWeightRow(
              context,
              '基础重量',
              equipmentList.baseWeight,
              equipmentList.totalWeight,
              theme.colorScheme.primary,
            ),
            const SizedBox(height: 4),
            _buildWeightRow(
              context,
              '消耗品重量',
              equipmentList.consumableWeight,
              equipmentList.totalWeight,
              theme.colorScheme.secondary,
            ),
            const SizedBox(height: 4),
            _buildWeightRow(
              context,
              '穿着重量',
              equipmentList.wornWeight,
              equipmentList.totalWeight,
              theme.colorScheme.tertiary,
            ),

            const SizedBox(height: 16),

            // 装备统计
            Text(
              '装备统计',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatItem(
                  context,
                  '必需',
                  equipmentList.essentialItems,
                  equipmentList.totalItems,
                  Color(getNecessityColor(EquipmentNecessity.essential)),
                ),
                const SizedBox(width: 8),
                _buildStatItem(
                  context,
                  '推荐',
                  equipmentList.recommendedItems,
                  equipmentList.totalItems,
                  Color(getNecessityColor(EquipmentNecessity.recommended)),
                ),
                const SizedBox(width: 8),
                _buildStatItem(
                  context,
                  '可选',
                  equipmentList.optionalItems,
                  equipmentList.totalItems,
                  Color(getNecessityColor(EquipmentNecessity.optional)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 季节标签
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: equipmentList.getSeasonNames().map((season) {
                return Chip(
                  label: Text(season),
                  avatar: const Icon(Icons.wb_sunny, size: 16),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  labelStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建重量行
  Widget _buildWeightRow(
    BuildContext context,
    String label,
    double weight,
    double totalWeight,
    Color color,
  ) {
    final theme = Theme.of(context);
    final percentage = (weight / totalWeight * 100).toStringAsFixed(1);

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: weight / totalWeight,
              backgroundColor: color.withOpacity(0.2),
              color: color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            '${(weight / 1000).toStringAsFixed(2)}kg ($percentage%)',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final theme = Theme.of(context);
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$percentage%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
