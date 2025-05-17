import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../page/common/splash_screen.dart';
import '../page/home/home_screen.dart';
import '../page/route/route_list_screen.dart';
import '../page/route/route_detail_screen.dart';
import '../page/route/route_map_screen.dart';
import '../page/equipment/equipment_list_screen.dart';
import '../page/equipment/equipment_detail_screen.dart';
import '../page/auth/login_screen.dart';
import '../page/auth/register_screen.dart';
import '../page/auth/forgot_password_screen.dart';
import '../../state/equipment/equipment_providers.dart';

/// 路由提供者
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      // 启动页
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // 首页
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),

      // 路线列表
      GoRoute(
        path: '/routes',
        builder: (context, state) => const RouteListScreen(),
      ),

      // 路线详情
      GoRoute(
        path: '/routes/:id',
        builder: (context, state) {
          final routeId = state.pathParameters['id']!;
          return RouteDetailScreen(routeId: routeId);
        },
      ),

      // 路线地图
      GoRoute(
        path: '/routes/:id/map',
        builder: (context, state) {
          final routeId = state.pathParameters['id']!;
          return RouteMapScreen(routeId: routeId);
        },
      ),

      // 装备列表
      GoRoute(
        path: '/equipment',
        builder: (context, state) => const EquipmentListScreen(),
      ),

      // 装备详情
      GoRoute(
        path: '/equipment/:id',
        builder: (context, state) {
          final equipmentId = state.pathParameters['id']!;
          return EquipmentDetailScreen(equipmentId: equipmentId);
        },
      ),

      // 登录
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 注册
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // 忘记密码
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // 发现页
      GoRoute(
        path: '/discover',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('发现')),
          body: const Center(child: Text('发现页面 - 功能开发中')),
        ),
      ),

      // 收藏页
      GoRoute(
        path: '/favorites',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('我的收藏')),
          body: const Center(child: Text('收藏页面 - 功能开发中')),
        ),
      ),

      // 个人资料页
      GoRoute(
        path: '/profile',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('个人资料')),
          body: const Center(child: Text('个人资料页面 - 功能开发中')),
        ),
      ),

      // 食物页
      GoRoute(
        path: '/food',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('徒步食物')),
          body: const Center(child: Text('徒步食物页面 - 功能开发中')),
        ),
      ),

      // 社区页
      GoRoute(
        path: '/community',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('徒步社区')),
          body: const Center(child: Text('徒步社区页面 - 功能开发中')),
        ),
      ),

      // 功能页
      GoRoute(
        path: '/features',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('全部功能')),
          body: const Center(child: Text('全部功能页面 - 功能开发中')),
        ),
      ),

      // 旅行计划页
      GoRoute(
        path: '/trips',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('我的旅行计划')),
          body: const Center(child: Text('旅行计划页面 - 功能开发中')),
        ),
      ),

      // 攻略页
      GoRoute(
        path: '/guides',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('徒步攻略')),
          body: const Center(child: Text('徒步攻略页面 - 功能开发中')),
        ),
      ),

      // 设置页
      GoRoute(
        path: '/settings',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('设置')),
          body: const Center(child: Text('设置页面 - 功能开发中')),
        ),
      ),
    ],

    // 错误页面
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面不存在')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('页面不存在', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text('路径: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}); 