/// 应用程序的主入口文件
///
/// 包含应用程序初始化、主题设置和路由配置

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'ui/app.dart';
import 'service/service_manager.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化服务定位器
  ServiceLocator.instance.initialize(useMock: true);

  // 预加载JSON数据
  await _preloadJsonData();

  runApp(const App());
}

/// 预加载JSON数据文件
Future<void> _preloadJsonData() async {
  final jsonFiles = [
    'assets/mock_data/guides.json',
    'assets/mock_data/routes.json',
    'assets/mock_data/users.json',
    'assets/mock_data/weather.json',
    'assets/mock_data/hot_searches.json',
    'assets/mock_data/recommended_routes.json',
  ];

  // 预加载所有JSON文件
  for (final file in jsonFiles) {
    try {
      await rootBundle.loadString(file);
      debugPrint('预加载成功: $file');
    } catch (e) {
      debugPrint('预加载失败: $file - $e');
    }
  }
}
