import 'package:flutter/material.dart';

/// 空视图组件
class EmptyView extends StatelessWidget {
  /// 提示信息
  final String message;
  
  /// 标题
  final String title;
  
  /// 图标
  final IconData icon;
  
  /// 操作按钮文本
  final String? actionText;
  
  /// 操作按钮回调
  final VoidCallback? onAction;

  /// 构造函数
  const EmptyView({
    super.key,
    required this.message,
    this.title = '暂无数据',
    this.icon = Icons.inbox,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(message),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
}