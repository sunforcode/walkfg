import 'package:flutter/material.dart';
import '../../../../model/equipment/equipment_model.dart';

/// 装备项目详情对话框组件
class EquipmentItemDetailDialog extends StatelessWidget {
  /// 装备项目
  final EquipmentItem item;

  /// 构造函数
  const EquipmentItemDetailDialog({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(item.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description != null) ...[
              Text(
                '描述',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(item.description!),
              const SizedBox(height: 16),
            ],
            
            _buildInfoRow(context, '重量', item.getWeightText()),
            _buildInfoRow(context, '数量', '${item.quantity}个'),
            _buildInfoRow(context, '总重量', item.getTotalWeightText()),
            _buildInfoRow(context, '必要性', item.getNecessityName(),
              textColor: Color(item.getNecessityColor())),
            
            if (item.brand != null)
              _buildInfoRow(context, '品牌', item.brand!),
            
            if (item.model != null)
              _buildInfoRow(context, '型号', item.model!),

            if (item.price != null)
              _buildInfoRow(context, '价格', item.getPriceText()!),

            if (item.notes != null) ...[
              const SizedBox(height: 16),
              Text(
                '备注',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(item.notes!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(BuildContext context, String label, String value, {Color? textColor}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: textColor != null ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}