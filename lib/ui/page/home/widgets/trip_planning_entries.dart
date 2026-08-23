import 'package:flutter/cupertino.dart';
import 'package:walk/ui/page/trip/trip_detail_screen.dart';
import 'package:walk/theme/tokens/colors.dart';
import '../../trip/my_trip_plans_screen.dart';
import '../../../../service/route_service.dart';

/// 行程规划入口组件
class TripPlanningEntries extends StatelessWidget {
  /// 未完成行程计划数量
  final int unfinishedPlansCount;

  /// 构造函数
  const TripPlanningEntries({
    super.key,
    required this.unfinishedPlansCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // 开始规划行程
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _navigateToTripPlanning(context);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.interactiveAccent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.interactiveAccent.withValues(alpha: 0.3),
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
                    color: AppColors.bgLight,
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
                            color: AppColors.bgLight,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '规划你的下一次徒步旅行',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.bgLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    color: AppColors.bgLight,
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
              _navigateToMyTripPlans(context);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.interactiveAccent.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textWeak.withValues(alpha: 0.1),
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
                    color: AppColors.interactiveAccent,
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
                            color: AppColors.textWeak,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    color: AppColors.textWeak,
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
  void _navigateToTripPlanning(BuildContext context) async {
    // 获取默认路线
    try {
      final routes = await RouteService.getPopularRoutes(limit: 5);
      if (!context.mounted) return;
      if (routes.isEmpty) {
        // 如果没有推荐路线，直接创建空白行程
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const TripDetailScreen(),
          ),
        );
        return;
      }
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => TripDetailScreen(
            routeId: routes.first.id,
          ),
        ),
      );
    } catch (e) {
      debugPrint('获取推荐路线失败: $e');
      if (!context.mounted) return;
      // 如果获取路线失败，直接创建空白行程
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => const TripDetailScreen(),
        ),
      );
    }
  }

  /// 导航到我的行程规划页面
  void _navigateToMyTripPlans(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const MyTripPlansScreen(),
      ),
    );
  }
}
