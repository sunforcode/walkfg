import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/main_layout.dart';

/// 应用入口组件
class App extends StatelessWidget {
  /// 构造函数
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Walk - 徒步旅行助手',
      theme: const CupertinoThemeData(
        primaryColor: Color(0xFF2196F3),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        textTheme: CupertinoTextThemeData(
          primaryColor: Color(0xFF2196F3),
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