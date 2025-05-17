import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'widgets/welcome_weather_card.dart';
import 'widgets/stats_card.dart';
import 'widgets/planned_routes_section.dart';
import 'widgets/recommended_routes_section.dart';
import 'widgets/hiking_guides_section.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_color_palette.dart';
import '../../widgets/common/cupertino_app_bar.dart';

/// 首页
class HomeScreen extends StatefulWidget {
  /// 构造函数
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Walk - 徒步旅行助手'),
        backgroundColor: AppColorPalette.blueColors[0],
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.bell, color: CupertinoColors.white),
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('提示'),
                    content: const Text('通知功能尚未实现'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('确定'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.settings, color: CupertinoColors.white),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(
                    builder: (context) => const CupertinoPageScaffold(
                      navigationBar: CupertinoNavigationBar(
                        middle: Text('设置'),
                      ),
                      child: SafeArea(
                        child: Center(
                          child: Text('设置页面正在开发中...'),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: const [
            // 欢迎卡片与天气预报结合
            RepaintBoundary(
              child: WelcomeWeatherCard(),
            ),
            
            SizedBox(height: 24),
            
            // 统计信息卡片
            RepaintBoundary(
              child: StatsCard(),
            ),

            SizedBox(height: 24),

            // 规划路线部分
            RepaintBoundary(
              child: PlannedRoutesSection(),
            ),
            
            SizedBox(height: 24),
            
            // 当季推荐路线部分
            RepaintBoundary(
              child: RecommendedRoutesSection(),
            ),

            SizedBox(height: 24),

            // 徒步攻略部分
            RepaintBoundary(
              child: HikingGuidesSection(),
            ),

            // 底部额外空间
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
