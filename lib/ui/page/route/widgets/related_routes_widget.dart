import 'package:flutter/cupertino.dart';
import '../../../../model/route/route_model.dart';

/// 相关路线推荐组件 - 横滑形式
class RelatedRoutesWidget extends StatelessWidget {
  /// 相关路线列表
  final List<RouteModel> relatedRoutes;

  /// 点击路线的回调
  final Function(RouteModel route)? onRouteTap;

  const RelatedRoutesWidget({
    super.key,
    required this.relatedRoutes,
    this.onRouteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedRoutes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.map_pin_ellipse,
                  size: 18,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 8),
                const Text(
                  '相关路线',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const Spacer(),
                Text(
                  '${relatedRoutes.length}条',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 横滑路线列表
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: relatedRoutes.length,
              itemBuilder: (context, index) {
                final route = relatedRoutes[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < relatedRoutes.length - 1 ? 12 : 0,
                  ),
                  child: _buildRouteCard(route),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建路线卡片 - 简化版本
  Widget _buildRouteCard(RouteModel route) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onRouteTap?.call(route),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线标题和评分
            Row(
              children: [
                Expanded(
                  child: Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // 评分
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.star_fill,
                      size: 12,
                      color: CupertinoColors.systemYellow,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      route.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 地区信息
            Row(
              children: [
                Icon(
                  CupertinoIcons.location,
                  size: 10,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    route.region,
                    style: const TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.systemGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 路线参数 - 简化显示
            Row(
              children: [
                // 天数
                _buildRouteParam(
                  icon: CupertinoIcons.calendar,
                  value: '${route.dailyPlans.length}天',
                  color: CupertinoColors.systemOrange,
                ),

                const SizedBox(width: 12),

                // 难度
                _buildRouteParam(
                  icon: CupertinoIcons.chart_bar,
                  value: route.difficulty.getName(),
                  color: CupertinoColors.systemRed,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 标签 - 最多显示2个
            if (route.tags.isNotEmpty) ...[
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    route.tags.take(2).map((tag) => _buildTag(tag)).toList(),
              ),
              const SizedBox(height: 4),
            ],

            const Spacer(),

            // 简短描述
            Text(
              route.description.length > 40
                  ? '${route.description.substring(0, 40)}...'
                  : route.description,
              style: const TextStyle(
                fontSize: 11,
                color: CupertinoColors.secondaryLabel,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建路线参数 - 简化版本
  Widget _buildRouteParam({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 10,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 构建标签 - 简化版本
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: CupertinoColors.systemBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
