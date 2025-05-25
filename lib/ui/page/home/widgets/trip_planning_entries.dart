import 'package:flutter/cupertino.dart';
import 'package:walk/ui/page/trip/trip_detail_screen.dart';
import '../../../../theme/theme/app_colors.dart';
import '../../trip/my_trip_plans_screen.dart';
import '../../../../service/service_manager.dart';

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
              _navigateToMyTripPlans(context);
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
  void _navigateToTripPlanning(BuildContext context) async {
    // 获取默认路线
    final routeService = ServiceLocator.instance.getRecommendationService();
    try {
      final route = await routeService.getPersonalizedRecommendations();
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => TripDetailScreen(
            routeId: route.first.regionId,
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

  /// 导航到我的行程规划页面
  void _navigateToMyTripPlans(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const MyTripPlansScreen(),
      ),
    );
  }
}
