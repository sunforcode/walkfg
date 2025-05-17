/// 应用程序的主入口文件
///
/// 包含应用程序初始化、主题设置和路由配置

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'service/service_locator.dart';
import 'ui/page/main_layout.dart';
import 'ui/theme/app_colors.dart';

void main() {
  // 初始化服务定位器
  ServiceLocator.instance.setup();

  runApp(const MyApp());
}

/// 应用入口
class MyApp extends StatelessWidget {
  /// 构造函数
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Walk - 徒步旅行助手',
      theme: const CupertinoThemeData(
        primaryColor: AppColors.primary,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.primary,
        ),
      ),
      home: const MainLayout(),
      routes: {
        '/settings': (context) => const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('设置'),
          ),
          child: SafeArea(
            child: Center(
              child: Text('设置页面'),
            ),
          ),
        ),
      },
    );
  }
}
