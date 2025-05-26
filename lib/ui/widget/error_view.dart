import 'package:flutter/cupertino.dart';

/// 错误视图组件
class ErrorView extends StatelessWidget {
  /// 错误信息
  final String error;
  
  /// 重试回调
  final VoidCallback onRetry;
  
  /// 构造函数
  const ErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 50,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            child: const Text('重试'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}