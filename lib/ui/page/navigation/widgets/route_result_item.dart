import 'package:flutter/cupertino.dart';
import 'package:walk/theme/tokens/tokens.dart';

import '../../../../model/route/route_model.dart';
import '../../common/network_image_with_fallback.dart';

/// 路线结果卡片组件（用于推荐路线和搜索结果列表）
class RouteResultItem extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  /// 点击回调
  final VoidCallback onTap;

  /// 构造函数
  const RouteResultItem({
    super.key,
    required this.route,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: route.coverUrl != null
                    ? NetworkImageWithFallback(
                        url: route.coverUrl!,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        borderRadius: 8,
                      )
                    : Container(
                        height: 80,
                        width: 80,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.photo,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    route.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoTag(
                        '${route.distance}km',
                        CupertinoIcons.arrow_right,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoTag(
                        '${route.elevationGain}m爬升',
                        CupertinoIcons.arrow_up,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoTag(
                        route.difficulty.name,
                        CupertinoIcons.flag,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
