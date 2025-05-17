import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 通用详情页面
class DetailScreen extends StatelessWidget {
  /// 页面标题
  final String title;

  /// 页面内容
  final String content;

  /// 图标
  final IconData icon;

  /// 构造函数
  const DetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // 使用GoRouter返回
                  context.pop();
                },
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}