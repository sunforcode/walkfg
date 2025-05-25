import 'package:flutter/material.dart';
import '../../../../model/equipment/equipment_list_model.dart';

/// 装备列表卡片组件
class EquipmentListCard extends StatelessWidget {
  /// 装备清单
  final EquipmentListModel equipmentList;
  
  /// 点击回调
  final VoidCallback onTap;

  /// 构造函数
  const EquipmentListCard({
    super.key,
    required this.equipmentList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 卡片顶部
            Container(
              height: 100,
              color: theme.colorScheme.primary.withOpacity(0.1),
              child: Center(
                child: Icon(
                  Icons.inventory_2,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            
            // 卡片内容
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和官方标签
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          equipmentList.name,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      if (equipmentList.isOfficial)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '官方推荐',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 描述
                  Text(
                    equipmentList.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 信息标签
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.calendar_today,
                        '${equipmentList.tripDays}天',
                      ),
                      _buildInfoChip(
                        context,
                        Icons.scale,
                        '${(equipmentList.totalWeight / 1000).toStringAsFixed(2)}kg',
                      ),
                      _buildInfoChip(
                        context,
                        Icons.inventory_2,
                        '${equipmentList.totalItems}件装备',
                      ),
                      ...equipmentList.getSeasonNames().map(
                            (season) => _buildInfoChip(
                              context,
                              Icons.wb_sunny,
                              season,
                            ),
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}