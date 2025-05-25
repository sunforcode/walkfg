import 'package:flutter/material.dart';

/// 错误视图组件
class ErrorView extends StatelessWidget {
  /// 错误信息
  final String message;
  
  /// 错误标题
  final String title;
  
  /// 重试回调
  final VoidCallback? onRetry;

  /// 构造函数
  const ErrorView({
    super.key,
    required this.message,
    this.title = '出错了',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(message),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }
}