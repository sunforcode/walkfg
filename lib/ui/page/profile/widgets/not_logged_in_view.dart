import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 未登录视图组件
class NotLoggedInView extends StatelessWidget {
  /// 点击登录的回调
  final VoidCallback onLoginPressed;

  /// 点击注册的回调
  final VoidCallback onRegisterPressed;

  /// 构造函数
  const NotLoggedInView({
    super.key,
    required this.onLoginPressed,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.hiking,
            size: 80,
            color: Color(0xFF4CAF50),
          ),
          const SizedBox(height: 40),
          Text(
            'Walk',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '徒步旅行助手',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          CupertinoButton(
            color: CupertinoColors.activeBlue,
            child: const Text('登录'),
            onPressed: onLoginPressed,
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            color: CupertinoColors.systemGrey5,
            child: const Text(
              '注册',
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
            onPressed: onRegisterPressed,
          ),
          const SizedBox(height: 40),
          const Text(
            '登录后可以使用更多功能',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
