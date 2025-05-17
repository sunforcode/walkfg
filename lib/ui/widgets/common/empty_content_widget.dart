import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 通用空内容提示组件
class EmptyContentWidget extends StatelessWidget {
  /// 图标
  final IconData icon;
  
  /// 标题
  final String title;
  
  /// 副标题
  final String? subtitle;
  
  /// 操作按钮文本
  final String? actionText;
  
  /// 操作按钮回调
  final VoidCallback? onAction;
  
  /// 颜色
  final Color? color;
  
  /// 构造函数
  const EmptyContentWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? AppColors.secondary;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: displayColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: displayColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: displayColor.withOpacity(0.8),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: displayColor.withOpacity(0.6),
              ),
            ),
          ],
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: displayColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
}