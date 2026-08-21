import 'package:flutter/cupertino.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';
import '../../../../model/route/route_model.dart';

/// 路线卡片组件
///
/// 用于水平滚动列表中显示路线信息
class RouteCard extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  /// 点击回调
  final VoidCallback onTap;

  /// 构造函数
  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16, bottom: 4),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线图片
            _buildRouteImage(),

            // 路线信息
            _buildRouteInfo(),
          ],
        ),
      ),
    );
  }

  /// 构建路线图片
  Widget _buildRouteImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12),
          ),
          child: route.coverUrl != null
              ? NetworkImageWithFallback(
                  url: route.coverUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 150,
                  width: double.infinity,
                  color: CupertinoColors.systemGrey5,
                  child: Icon(
                    CupertinoIcons.photo,
                    size: 48,
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
        ),

        // 收藏按钮
        Positioned(
          top: 8,
          right: 8,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CupertinoColors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.heart,
                size: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
            onPressed: () {
              // TODO: 实现收藏功能
            },
          ),
        ),

        // 难度标签
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  size: 12,
                  color: CupertinoColors.activeBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  _getDifficultyText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.activeBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建路线信息
  Widget _buildRouteInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                CupertinoIcons.location_solid,
                size: 14,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  route.region,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip(
                CupertinoIcons.arrow_right_arrow_left,
                '${route.distance} km',
              ),
              _buildInfoChip(
                CupertinoIcons.time,
                route.durationText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  /// 获取难度文本
  String _getDifficultyText() {
    switch (route.difficulty.index) {
      case 0:
        return '简单';
      case 1:
        return '中等';
      case 2:
        return '困难';
      case 3:
        return '极难';
      default:
        return '中等';
    }
  }
}
