import 'package:flutter/cupertino.dart';

import '../ui/page/drawer/walk_drawer.dart';
import '../ui/page/home/home_screen.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/motion.dart';
import '../theme/tokens/sizes.dart';

/// Walk v1 主壳层
///
/// PRD 导航模型：
/// - 无底部导航、无 Tab 栏
/// - 首页 P1/P2 是中心枢纽
/// - 汉堡按钮触发左侧抽屉 P14
/// - 各页面通过 AppNavigator push
class MainLayout extends StatefulWidget {
  /// Preserved for callers that still pass an initial tab index.
  final int initialIndex;

  /// Constructor.
  const MainLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  bool _drawerOpen = false;

  /// 打开抽屉
  void openDrawer() {
    setState(() => _drawerOpen = true);
  }

  /// 关闭抽屉
  void closeDrawer() {
    setState(() => _drawerOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ─── 首页内容 ───
        HomeScreen(
          onOpenDrawer: openDrawer,
        ),

        // ─── 遮罩层 ───
        if (_drawerOpen)
          GestureDetector(
            onTap: closeDrawer,
            child: AnimatedContainer(
              duration: AppMotion.slow,
              curve: AppMotion.spring,
              color: AppColors.surfaceOverlay,
            ),
          ),

        // ─── 抽屉 ───
        AnimatedPositioned(
          duration: AppMotion.slow,
          curve: AppMotion.spring,
          left: _drawerOpen ? 0 : -AppSizes.drawer,
          top: 0,
          bottom: 0,
          width: AppSizes.drawer,
          child: WalkDrawer(onClose: closeDrawer),
        ),
      ],
    );
  }
}
