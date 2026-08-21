import 'package:flutter/cupertino.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';
import '../../../../model/route/route_model.dart';

/// 列表式路线卡片组件
///
/// 用于垂直列表中显示路线信息
class RouteListCard extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  /// 点击回调
  final VoidCallback onTap;

  /// 构造函数
  const RouteListCard({
    super.key,
    required this.route,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 路线图片
            _buildRouteImage(),

            // 路线信息
            Expanded(
              child: _buildRouteInfo(),
            ),

            // 收藏按钮
            _buildFavoriteButton(),
          ],
        ),
      ),
    );
  }

  /// 构建路线图片
  Widget _buildRouteImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(
        left: Radius.circular(12),
      ),
      child: route.coverUrl != null
          ? NetworkImageWithFallback(
              url: route.coverUrl!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
          : Container(
              height: 100,
              width: 100,
              color: CupertinoColors.systemGrey5,
              child: Icon(
                CupertinoIcons.photo,
                size: 32,
                color: CupertinoColors.systemGrey2,
              ),
            ),
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
            children: [
              _buildInfoChip(
                CupertinoIcons.arrow_right_arrow_left,
                '${route.distance} km',
              ),
              const SizedBox(width: 12),
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

  /// 构建收藏按钮
  Widget _buildFavoriteButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Icon(
        CupertinoIcons.heart,
        size: 22,
        color: CupertinoColors.systemGrey,
      ),
      onPressed: () {
        // TODO: 实现收藏功能
      },
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
}
