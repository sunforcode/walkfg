import 'package:flutter/cupertino.dart';

/// 加载视图
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }
}

/// 错误视图
class ErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

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
          const Text(
            '加载失败',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(error.toString()),
          const SizedBox(height: 16),
          CupertinoButton(
            child: const Text('重试'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}