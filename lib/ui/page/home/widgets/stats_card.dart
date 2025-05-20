import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/user_model.dart';
import '../../../widgets/common/async_content_builder.dart';

/// 统计信息卡片组件
class StatsCard extends StatelessWidget {
  /// 用户统计数据Future
  final Future<UserModel> userStatsFuture;

  /// 点击已完成路线的回调
  final VoidCallback onCompletedRoutesPressed;

  /// 点击装备清单的回调
  final VoidCallback onEquipmentListPressed;

  /// 点击收藏路线的回调
  final VoidCallback onFavoriteRoutesPressed;

  /// 点击刷新的回调
  final VoidCallback onRefreshPressed;

  /// 构造函数
  const StatsCard({
    super.key,
    required this.userStatsFuture,
    required this.onCompletedRoutesPressed,
    required this.onEquipmentListPressed,
    required this.onFavoriteRoutesPressed,
    required this.onRefreshPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AsyncContentBuilder<UserModel>(
      future: userStatsFuture,
      builder: (context, userStats) => _buildStatsCard(context, userStats),
      loadingBuilder: (context) => _buildLoadingCard(),
      errorBuilder: (context, error) => _buildErrorCard(error.toString()),
    );
  }

  /// 构建加载中卡片
  Widget _buildLoadingCard() {
    return _buildBaseCard(
      child: const Center(
        child: CupertinoActivityIndicator(radius: 15),
      ),
    );
  }

  /// 构建错误卡片
  Widget _buildErrorCard(String errorMessage) {
    return _buildBaseCard(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.exclamationmark_circle,
                color: CupertinoColors.systemRed,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '加载失败',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建基础卡片
  Widget _buildBaseCard({required Widget child, double height = 180}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  /// 构建统计卡片
  Widget _buildStatsCard(BuildContext context, UserModel userStats) {
    // 主题颜色
    final List<Color> themeColors = const [
      Color(0xFF3498DB), // 蓝色
      Color(0xFF2ECC71), // 绿色
      Color(0xFFF39C12), // 橙色
    ];

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStatItem(
                  context,
                  icon: CupertinoIcons.map_fill,
                  label: '已完成路线',
                  value: userStats.completedRoutes.toString(),
                  color: themeColors[0],
                  onTap: onCompletedRoutesPressed,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  context,
                  icon: CupertinoIcons.square_list_fill,
                  label: '装备清单',
                  value: userStats.equipmentLists.toString(),
                  color: themeColors[1],
                  onTap: onEquipmentListPressed,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  context,
                  icon: CupertinoIcons.heart_fill,
                  label: '收藏路线',
                  value: userStats.favoriteRoutes.toString(),
                  color: themeColors[2],
                  onTap: onFavoriteRoutesPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建卡片头部
  Widget _buildHeader() {
    const Color headerColor = Color(0xFF3498DB);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: headerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            CupertinoIcons.chart_bar_alt_fill,
            color: headerColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          '我的统计',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onRefreshPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              CupertinoIcons.refresh,
              color: headerColor,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child!,
          );
        },
        child: GestureDetector(
          onTap: onTap,
          child: _buildStatItemContent(icon, label, value, color),
        ),
      ),
    );
  }

  /// 构建统计项内容
  Widget _buildStatItemContent(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
