import 'package:flutter/cupertino.dart';

import 'theme/main_layout.dart';
import 'theme/app_theme.dart';
import 'ui/page/debug/debug_menu_page.dart';
import 'ui/page/route/route_discovery_screen.dart';
import 'ui/routes/app_routes.dart';

/// 应用入口组件
class App extends StatelessWidget {
  /// 构造函数
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Walk - 徒步旅行助手',
      theme: AppTheme.cupertino,
      builder: AppTheme.buildMaterialTheme,
      home: const MainLayout(),
      routes: {
        AppRoutes.debug: (context) => const DebugMenuPage(),
        AppRoutes.routeDiscovery: (context) => const RouteDiscoveryScreen(),
      },
    );
  }
}
