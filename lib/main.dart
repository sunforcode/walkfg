/// 应用程序的主入口文件
///
/// 包含应用程序初始化、主题设置和路由配置

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'core/config/app_config.dart';
import 'core/network/network_manager.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日期格式化
  await initializeDateFormatting('zh_CN', null);
  await initializeDateFormatting('en_US', null);

  // 初始化 Hive
  await Hive.initFlutter();

  // 初始化应用配置
  AppConfig.instance.initialize();
  await NetworkManager.instance.initialize();

  // 初始化 ApiClient（包含缓存）
  await ApiClient.instance.initialize(
    baseUrl: AppConfig.instance.baseUrl,
  );

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
