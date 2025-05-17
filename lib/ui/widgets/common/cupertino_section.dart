import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 通用iOS风格分区组件
class CupertinoSection extends StatelessWidget {
  /// 标题
  final String title;
  
  /// 子组件
  final Widget child;
  
  /// 操作按钮文本
  final String? actionText;
  
  /// 操作按钮回调
  final VoidCallback? onAction;
  
  /// 底部间距
  final double bottomPadding;
  
  /// 构造函数
  const CupertinoSection({
    super.key,
    required this.title,
    required this.child,
    this.actionText,
    this.onAction,
    this.bottomPadding = 24,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (actionText != null && onAction != null)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onAction,
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 内容
        child,
        
        // 底部间距
        SizedBox(height: bottomPadding),
      ],
    );
  }
}