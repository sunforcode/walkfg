import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'route/cupertino_route_list_screen.dart';
import 'equipment/cupertino_equipment_list_screen.dart';
import 'profile/profile_screen.dart';
import '../theme/app_colors.dart';

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
        currentIndex: _currentIndex,
        activeColor: AppColors.primary,
        inactiveColor: AppColors.textSecondary,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map),
            activeIcon: Icon(CupertinoIcons.map_fill),
            label: '路线',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bag),
            activeIcon: Icon(CupertinoIcons.bag_fill),
            label: '装备',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_fill),
            label: '我的',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        // 根据索引返回对应的页面
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

/// 路线页面（占位）
class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('路线'),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            '路线页面',
            style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
          ),
        ),
      ),
    );
  }
}

/// 装备页面（占位）
class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('装备'),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            '装备页面',
            style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
          ),
        ),
      ),
    );
  }
}

/// 个人页面（占位）
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('我的'),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            '个人页面',
            style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
          ),
        ),
      ),
    );
  }
}