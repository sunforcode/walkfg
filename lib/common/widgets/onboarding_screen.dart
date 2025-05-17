import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 引导屏幕
class OnboardingScreen extends StatelessWidget {
  /// 构造函数
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                children: const [
                  _OnboardingPage(
                    title: '探索徒步路线',
                    description: '浏览和搜索全球各地的徒步路线，获取详细的路线信息和导航指引。',
                    icon: Icons.map_outlined,
                    color: Color(0xFF4CAF50),
                  ),
                  _OnboardingPage(
                    title: '查看天气预报',
                    description: '获取路线沿途的实时天气预报和预警信息，帮助您做好准备。',
                    icon: Icons.wb_sunny_outlined,
                    color: Color(0xFF2196F3),
                  ),
                  _OnboardingPage(
                    title: '装备推荐',
                    description: '根据路线、天气和个人偏好，获取智能装备推荐清单。',
                    icon: Icons.backpack_outlined,
                    color: Color(0xFFFF9800),
                  ),
                  _OnboardingPage(
                    title: '食物计划',
                    description: '根据行程长度和难度，获取合理的食物计划建议。',
                    icon: Icons.restaurant_outlined,
                    color: Color(0xFFF44336),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('开始使用'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 引导页面
class _OnboardingPage extends StatelessWidget {
  /// 标题
  final String title;
  
  /// 描述
  final String description;
  
  /// 图标
  final IconData icon;
  
  /// 颜色
  final Color color;

  /// 构造函数
  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: color,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}