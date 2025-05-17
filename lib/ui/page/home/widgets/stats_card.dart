import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../model/user_model.dart';
import '../../../../service/service_locator.dart';
import '../../route/cupertino_route_list_screen.dart';
import '../../equipment/cupertino_equipment_list_screen.dart';

/// 统计信息卡片组件
class StatsCard extends StatefulWidget {
  /// 构造函数
  const StatsCard({super.key});

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> with AutomaticKeepAliveClientMixin {
  /// 用户统计数据Future
  late Future<UserModel> _userStatsFuture;

  /// 蓝色系颜色列表
  final List<Color> _blueColors = [
    const Color(0xFF1976D2), // 深蓝色
    const Color(0xFF2196F3), // 蓝色
    const Color(0xFF42A5F5), // 浅蓝色
    const Color(0xFF64B5F6), // 更浅的蓝色
    const Color(0xFF0D47A1), // 深邃蓝色
    const Color(0xFF0288D1), // 亮蓝色
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _userStatsFuture = _loadData();
  }

  /// 加载数据
  Future<UserModel> _loadData() async {
    final apiService = ServiceLocator.instance.getApiService();
    return apiService.getUserStats();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build

    return FutureBuilder<UserModel>(
      future: _userStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(context);
        }

        if (snapshot.hasError) {
          return _buildErrorCard(context, snapshot.error.toString());
        }

        final userStats = snapshot.data!;
        return _buildCard(context, userStats);
      },
    );
  }

  /// 构建加载中的卡片
  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 120,
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      ),
    );
  }

  /// 构建错误卡片
  Widget _buildErrorCard(BuildContext context, String errorMessage) {
    final color = _blueColors[0];
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: color.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            CupertinoButton(
              onPressed: () {
                setState(() {
                  _userStatsFuture = _loadData();
                });
              },
              color: color,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              borderRadius: BorderRadius.circular(8),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建数据卡片
  Widget _buildCard(BuildContext context, UserModel userStats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.chart_bar,
                  size: 24,
                  color: _blueColors[0],
                ),
                const SizedBox(width: 8),
                Text(
                  '我的统计',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  userStats.completedRoutes.toString(),
                  '已完成路线',
                  CupertinoIcons.flag,
                  _blueColors[0],
                  () => _navigateToCompletedRoutes(context),
                ),
                _buildStatItem(
                  context,
                  userStats.equipmentLists.toString(),
                  '装备清单',
                  CupertinoIcons.bag,
                  _blueColors[2],
                  () => _navigateToEquipment(context),
                ),
                _buildStatItem(
                  context,
                  userStats.favoriteRoutes.toString(),
                  '收藏路线',
                  CupertinoIcons.heart,
                  _blueColors[4],
                  () => _navigateToFavorites(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 导航到已完成路线页面
  void _navigateToCompletedRoutes(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => const RouteListScreen(),
      ),
    );
  }

  /// 导航到装备页面
  void _navigateToEquipment(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => const EquipmentListScreen(),
      ),
    );
  }

  /// 导航到收藏路线页面
  void _navigateToFavorites(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => const RouteListScreen(),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}