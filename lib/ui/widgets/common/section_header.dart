import 'package:flutter/material.dart';

/// 通用部分标题组件
class SectionHeader extends StatelessWidget {
  /// 标题
  final String title;
  
  /// 操作按钮文本
  final String? actionText;
  
  /// 操作按钮回调
  final VoidCallback? onAction;
  
  /// 构造函数
  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionText != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionText!),
          ),
      ],
    );
  }
}