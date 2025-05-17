import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 行程调整页面
class TripAdjustmentScreen extends StatelessWidget {
  /// 构造函数
  const TripAdjustmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行程调整'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.edit_calendar,
                size: 80,
                color: Colors.purple,
              ),
              const SizedBox(height: 24),
              Text(
                '行程调整功能开发中',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '此功能将在未来版本中提供，敬请期待！',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.go('/home');
                },
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}