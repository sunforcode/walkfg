import 'package:flutter/cupertino.dart';
import '../../../../model/model/route/route_model.dart';

/// 路线概览标签页
class RouteOverviewTab extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  /// 评分数据Future
  final Future<Map<String, dynamic>> ratingsFuture;

  /// 构造函数
  const RouteOverviewTab({
    super.key,
    required this.route,
    required this.ratingsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 路线描述
          _buildDescriptionSection(),

          const SizedBox(height: 24),

          // 详细信息
          _buildDetailedInfoSection(),

          const SizedBox(height: 24),

          // 评分详情
          _buildRatingsSection(),

          const SizedBox(height: 24),

          // 操作按钮
          _buildActionButtons(context),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 构建描述部分
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '路线描述',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          route.description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: CupertinoColors.black,
          ),
        ),
      ],
    );
  }

  /// 构建详细信息部分
  Widget _buildDetailedInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '详细信息',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey5.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow('最高点', '${route.basicInfo.elevationGain} m'),
              _buildDivider(),
              _buildInfoRow('最低点', '${route.basicInfo.elevationGain} m'),
              _buildDivider(),
              _buildInfoRow('累计上升', '${route.basicInfo.elevationGain} m'),
              _buildDivider(),
              _buildInfoRow('累计下降', '${route.basicInfo.elevationGain} m'),
              _buildDivider(),
              _buildInfoRow('地区', route.region!),
              _buildDivider(),
              _buildInfoRow('最佳季节', route.basicInfo.bestSeason.join(',')),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建评分部分
  Widget _buildRatingsSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ratingsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final ratings = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '评分详情',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey5.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildRatingRow('总体评分', ratings['overall'] ?? 0.0),
                  const SizedBox(height: 12),
                  _buildRatingRow('景色评分', ratings['scenery'] ?? 0.0),
                  const SizedBox(height: 12),
                  _buildRatingRow('难度评分', ratings['difficulty'] ?? 0.0),
                  const SizedBox(height: 12),
                  _buildRatingRow('设施评分', ratings['facilities'] ?? 0.0),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          CupertinoIcons.map,
          '查看地图',
          CupertinoColors.activeBlue,
          () {
            // 切换到地图标签页
          },
        ),
        _buildActionButton(
          CupertinoIcons.calendar_badge_plus,
          '规划行程',
          CupertinoColors.activeGreen,
          () {
            // 导航到行程规划页面
          },
        ),
        _buildActionButton(
          CupertinoIcons.heart,
          '收藏',
          CupertinoColors.systemPink,
          () {
            // 收藏功能
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('提示'),
                content: const Text('收藏功能正在开发中'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('确定'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建评分行
  Widget _buildRatingRow(String label, double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 15,
          ),
        ),
        Row(
          children: [
            _buildRatingStars(rating),
            const SizedBox(width: 8),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: CupertinoColors.systemYellow,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建评分星星
  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(CupertinoIcons.star_fill,
              size: 16, color: CupertinoColors.systemYellow);
        } else if (index < rating.ceil() && rating.floor() != rating.ceil()) {
          return const Icon(CupertinoIcons.star_lefthalf_fill,
              size: 16, color: CupertinoColors.systemYellow);
        } else {
          return const Icon(CupertinoIcons.star,
              size: 16, color: CupertinoColors.systemYellow);
        }
      }),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 1,
      color: CupertinoColors.systemGrey5,
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
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
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
