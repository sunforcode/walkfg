import 'package:flutter/material.dart';

/// 章节标题组件
class SectionHeader extends StatelessWidget {
  /// 标题
  final String title;
  
  /// 副标题
  final String? subtitle;
  
  /// 操作按钮
  final Widget? action;
  
  /// 底部间距
  final double bottomPadding;
  
  /// 构造函数
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.bottomPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (action != null) action!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}