import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui/page/home/home_screen.dart';
import '../ui/page/route/cupertino_route_list_screen.dart';
import '../ui/page/equipment/cupertino_equipment_list_screen.dart';
import '../ui/page/profile/profile_screen.dart';
import '../ui/page/trip_plan/trip_planning_page.dart';
import '../service/service_manager.dart';
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

  /// 导航到行程规划页面
  void _navigateToTripPlanning(BuildContext context) async {
    // 获取默认路线
    final routeService = ServiceLocator.instance.getRecommendationService();
    try {
      final route = await routeService.getPersonalizedRecommendations();
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => TripPlanningPage2(
            route: route.first,
          ),
        ),
      );
    } catch (e) {
      print('获取推荐路线失败: $e');
      _showNoRoutesAlert(context);
    }
  }

  /// 显示没有路线的提示
  void _showNoRoutesAlert(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('无法加载路线'),
        content: const Text('暂时无法获取推荐路线，请稍后再试。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CupertinoTabScaffold(
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
              // 中间的加号按钮占位
              BottomNavigationBarItem(
                icon: Icon(null),
                label: '',
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
              // 如果点击的是中间的加号按钮
              if (index == 2) {
                _navigateToTripPlanning(context);
                return;
              }

              setState(() {
                _currentIndex = index;
              });
            },
          ),
          tabBuilder: (context, index) {
            // 调整索引，跳过中间的加号按钮
            int actualIndex = index;
            if (index > 2) {
              actualIndex = index - 1;
            }

            switch (actualIndex) {
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
        ),

        // 添加浮动的加号按钮
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => _navigateToTripPlanning(context),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.add,
                  color: CupertinoColors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
