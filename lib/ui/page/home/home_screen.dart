import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/welcome_weather_card.dart';
import 'widgets/stats_card.dart';
import 'widgets/planned_routes_section.dart';
import 'widgets/recommended_routes_section.dart';
import 'widgets/hiking_guides_section.dart';

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

  /// 蓝色系渐变色
  final List<Color> _blueGradient = const [
    Color(0xFF1976D2), // 深蓝色
    Color(0xFF42A5F5), // 浅蓝色
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 自定义App Bar
          _buildAppBar(context),
            
          // 内容区域
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // 欢迎卡片与天气预报结合
                  const RepaintBoundary(
                    child: WelcomeWeatherCard(),
                  ),
            
                  const SizedBox(height: 24),
            
                  // 统计信息卡片
                  const RepaintBoundary(
                    child: StatsCard(),
                  ),

                  const SizedBox(height: 24),

                  // 规划路线部分
                  const RepaintBoundary(
                    child: PlannedRoutesSection(),
                  ),
            
                  const SizedBox(height: 24),
            
                  // 当季推荐路线部分
                  const RepaintBoundary(
                    child: RecommendedRoutesSection(),
                  ),

                  const SizedBox(height: 24),

                  // 徒步攻略部分
                  const RepaintBoundary(
                    child: HikingGuidesSection(),
                  ),

                  const SizedBox(height: 24),
                ],
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
              ),
            ),
          ),
        ],
      ),
      // 底部导航栏
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// 构建App Bar
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Walk - 徒步旅行助手'),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _blueGradient,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('通知功能尚未实现')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            context.go('/settings');
          },
        ),
      ],
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: '路线',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.backpack_outlined),
          activeIcon: Icon(Icons.backpack),
          label: '装备',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '我的',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/routes');
            break;
          case 2:
            context.go('/equipment');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
    );
  }
}