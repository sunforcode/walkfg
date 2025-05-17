import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../service/service_locator.dart';
import '../../theme/app_colors.dart';
import 'widgets/welcome_weather_card.dart';
import 'widgets/stats_card.dart';
import 'widgets/planned_routes_section.dart';
import 'widgets/recommended_routes_section.dart';
import 'widgets/hiking_guides_section.dart';
import '../trip/my_trip_plans_screen.dart';
import '../trip/trip_planning_home_screen.dart';

/// 首页
class HomeScreen extends StatefulWidget {
  /// 构造函数
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('首页'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 天气卡片
              const Padding(
                padding: EdgeInsets.all(16),
                child: WelcomeWeatherCard(),
              ),

              // 行程规划入口
              _buildTripPlanningEntries(),

              // 用户统计卡片
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StatsCard(),
              ),

              const SizedBox(height: 24),

              // 规划路线部分
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: PlannedRoutesSection(),
              ),

              const SizedBox(height: 24),

              // 当季推荐路线部分
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: RecommendedRoutesSection(),
              ),

              const SizedBox(height: 24),

              // 徒步攻略部分
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: HikingGuidesSection(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建行程规划入口
  Widget _buildTripPlanningEntries() {
    final apiService = ServiceLocator.instance.getApiService();
    final unfinishedPlansCount = apiService.getUnfinishedTripPlansCount();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // 开始规划行程
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _navigateToTripPlanning();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.map,
                    size: 32,
                    color: CupertinoColors.white,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '开始规划行程',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '规划你的下一次徒步旅行',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.white,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 继续我的规划
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _navigateToMyTripPlans();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.doc_text,
                    size: 32,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '继续我的规划',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          unfinishedPlansCount > 0
                              ? '你有$unfinishedPlansCount个未完成的行程规划'
                              : '查看你的所有行程规划',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 导航到行程规划页面
  void _navigateToTripPlanning() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const TripPlanningHomeScreen(),
      ),
    );
  }

  /// 导航到我的行程规划页面
  void _navigateToMyTripPlans() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const MyTripPlansScreen(),
      ),
    );
  }
}
