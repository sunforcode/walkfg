import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../main.dart';

/// 启动屏幕
class SplashScreen extends ConsumerWidget {
  /// 构造函数
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hiking,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'Walk',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '徒步旅行助手',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                // 切换主题模式
                ref.read(themeModeProvider.notifier).state =
                    isDarkMode ? ThemeMode.light : ThemeMode.dark;

                // 显示主题切换消息
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已切换到${isDarkMode ? '浅色' : '深色'}主题'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              label: Text('切换到${isDarkMode ? '浅色' : '深色'}主题'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // 导航到主页，使用GoRouter
                context.go('/home');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('进入应用'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
