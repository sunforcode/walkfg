import 'package:flutter/material.dart';

/// 路线信息标签组件
class RouteInfoChip extends StatelessWidget {
  /// 图标
  final IconData icon;
  
  /// 标签文本
  final String label;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 文本颜色
  final Color? textColor;
  
  /// 图标颜色
  final Color? iconColor;
  
  /// 构造函数
  const RouteInfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 16,
            color: iconColor ?? theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor ?? theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}