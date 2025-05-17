import 'package:flutter/material.dart';

/// 功能卡片组件
class FeatureCard extends StatelessWidget {
  /// 功能标题
  final String title;
  
  /// 功能图标
  final IconData icon;
  
  /// 功能描述
  final String? description;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 背景色
  final Color? backgroundColor;
  
  /// 图标颜色
  final Color? iconColor;
  
  /// 是否显示箭头
  final bool showArrow;
  
  /// 构造函数
  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    this.description,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor ?? theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (showArrow && onTap != null) ...[
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}