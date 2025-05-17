import 'package:flutter/material.dart';

/// 信息卡片组件
class InfoCard extends StatelessWidget {
  /// 标题
  final String title;
  
  /// 图标
  final IconData? icon;
  
  /// 操作按钮
  final List<Widget>? actions;
  
  /// 内容
  final Widget child;
  
  /// 外边距
  final EdgeInsetsGeometry? margin;
  
  /// 内边距
  final EdgeInsetsGeometry? padding;
  
  /// 构造函数
  const InfoCard({
    super.key,
    required this.title,
    this.icon,
    this.actions,
    required this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          
          // 卡片内容
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}