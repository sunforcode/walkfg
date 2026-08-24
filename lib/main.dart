// 应用程序主入口与启动初始化流程。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'app_bootstrap.dart';
import 'app_initializer.dart';
import 'core/config/app_config.dart';
import 'core/network/network_manager.dart';
import 'core/state/auth_notifier.dart';

final AppInitializer _appInitializer = AppInitializer(
  loadEnvironment: () => dotenv.load(fileName: '.env'),
  initializeLocales: () async {
    await Future.wait([
      initializeDateFormatting('zh_CN', null),
      initializeDateFormatting('en_US', null),
    ]);
  },
  initializeStorage: Hive.initFlutter,
  initializeConfiguration: () {
    AppConfig.instance.initialize(useMockServices: false);
  },
  initializeNetwork: NetworkManager.instance.initialize,
  restoreAuthentication: () => AuthNotifier().initializeFromStorage(),
  preloadMockData: _preloadJsonData,
  useMockServices: () => AppConfig.instance.useMockServices,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AppBootstrap(
      initialize: _appInitializer.initialize,
      app: const App(),
    ),
  );
}

/// 预加载JSON数据文件（仅在使用 mock 服务时）
Future<void> _preloadJsonData() async {
  if (!AppConfig.instance.useMockServices) return;

  final jsonFiles = [
    'assets/mock_data/guides.json',
    'assets/mock_data/routes.json',
    'assets/mock_data/users.json',
  ];

  // 预加载所有JSON文件
  for (final file in jsonFiles) {
    try {
      await rootBundle.loadString(file);
    } catch (e) {
      debugPrint('预加载失败: $file - $e');
    }
  }
}
