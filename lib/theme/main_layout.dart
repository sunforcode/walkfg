import 'package:flutter/cupertino.dart';
import '../ui/page/home/home_screen.dart';
import '../ui/page/route/cupertino_route_list_screen.dart';
import '../ui/page/equipment/cupertino_equipment_list_screen.dart';
import '../ui/page/profile/profile_screen.dart';
import 'theme/app_colors.dart';

/// 主布局页面，包含底部导航栏和内容区域
class MainLayout extends StatefulWidget {
  /// 初始选中的标签页索引
  final int initialIndex;

  /// 构造函数
  const MainLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  /// 当前选中的标签页索引
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map),
            label: '路线',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_list),
            label: '装备',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: '我的',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => const HomeScreen(),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => const RouteListScreen(),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => const EquipmentListScreen(),
            );
          case 3:
            return CupertinoTabView(
              builder: (context) => const ProfileScreen(),
            );
          default:
            return CupertinoTabView(
              builder: (context) => const HomeScreen(),
            );
        }
      },
    );
  }
}
