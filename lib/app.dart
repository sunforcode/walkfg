import 'package:flutter/cupertino.dart';
import 'theme/main_layout.dart';
import 'theme/app_theme.dart';
import 'ui/map/examples/opensource_map_test_page.dart';
import 'ui/page/debug/debug_menu_page.dart';

/// 应用入口组件
class App extends StatelessWidget {
  /// 构造函数
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Walk - 徒步旅行助手',
      theme: AppTheme.cupertinoLight,
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
        '/map-test': (context) => const OpenSourceMapTestPage(),
        '/debug': (context) => const DebugMenuPage(),
      },
    );
  }
}
