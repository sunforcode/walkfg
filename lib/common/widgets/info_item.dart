import 'package:flutter/material.dart';

/// 信息项组件
class InfoItem extends StatelessWidget {
  /// 标签
  final String label;
  
  /// 值
  final String value;
  
  /// 标签宽度
  final double? labelWidth;
  
  /// 标签样式
  final TextStyle? labelStyle;
  
  /// 值样式
  final TextStyle? valueStyle;
  
  /// 底部间距
  final double bottomPadding;
  
  /// 构造函数
  const InfoItem({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth,
    this.labelStyle,
    this.valueStyle,
    this.bottomPadding = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth ?? 80,
            child: Text(
              label,
              style: labelStyle ?? 
                  theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}