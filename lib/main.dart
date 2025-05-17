/// 应用程序的主入口文件
///
/// 包含应用程序初始化、主题设置和路由配置

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'ui/router/app_router.dart';
import 'ui/theme/app_theme.dart';
import 'resource/services/service_locator.dart';

/// 主题模式提供者
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置首选设备方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 初始化服务定位器
  await ServiceLocator.init();

  // 运行应用
  runApp(
    const ProviderScope(
      child: WalkApp(),
    ),
  );
}

/// 应用程序主类
class WalkApp extends ConsumerWidget {
  /// 构造函数
  const WalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取主题模式
    final themeMode = ref.watch(themeModeProvider);
    // 获取路由配置
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // 应用标题
      title: 'Walk - 徒步旅行助手',

      // 调试标志
      debugShowCheckedModeBanner: false,

      // 主题设置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // 路由配置
      routerConfig: router,

      // 本地化设置
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文
        Locale('en', 'US'), // 英文
      ],
      locale: const Locale('zh', 'CN'),
    );
  }
}
