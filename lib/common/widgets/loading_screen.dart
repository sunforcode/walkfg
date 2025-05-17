import 'package:flutter/material.dart';

/// 通用加载屏幕
class LoadingScreen extends StatelessWidget {
  /// 加载消息
  final String message;

  /// 构造函数
  const LoadingScreen({
    super.key,
    this.message = '加载中...',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}