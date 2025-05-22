import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/model/route/route_model.dart';
import '../../../../theme/theme/app_colors.dart';
import '../../../../common/utils/trip_utils.dart';
import '../../../widgets/common/loading_indicator.dart';

/// 路线显示类型
enum RouteDisplayType {
  /// 精选（大卡片）
  featured,

  /// 水平列表
  horizontal,

  /// 垂直列表
  vertical,
}

/// 路线列表部分组件
class RouteListSection extends StatelessWidget {
  /// 标题
  final String title;

  /// 路线列表Future
  final Future<List<RouteModel>> routesFuture;

  /// 显示类型
  final RouteDisplayType displayType;

  /// 查看全部回调
  final VoidCallback? onViewAll;

  /// 路线点击回调
  final Function(BuildContext, RouteModel) onRouteTap;

  /// 构造函数
  const RouteListSection({
    super.key,
    required this.title,
    required this.routesFuture,
    required this.displayType,
    this.onViewAll,
    required this.onRouteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (onViewAll != null)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('查看全部'),
                  onPressed: onViewAll,
                ),
            ],
          ),
        ),

        // 路线列表
        _buildRouteList(context),
      ],
    );
  }

  /// 构建路线列表
  Widget _buildRouteList(BuildContext context) {
    final double height = displayType == RouteDisplayType.featured ? 280 : 120;

    return SizedBox(
      height: height,
      child: FutureBuilder<List<RouteModel>>(
        future: routesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LoadingIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('加载失败: ${snapshot.error}'),
            );
          }

          final routes = snapshot.data;
          if (routes == null || routes.isEmpty) {
            return const Center(
              child: Text('暂无路线'),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: routes.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final route = routes[index];
              switch (displayType) {
                case RouteDisplayType.featured:
                  return _buildFeaturedRouteCard(context, route);
                case RouteDisplayType.horizontal:
                case RouteDisplayType.vertical:
                  return _buildHorizontalRouteCard(context, route);
              }
            },
          );
        },
      ),
    );
  }

  /// 构建精选路线卡片
  Widget _buildFeaturedRouteCard(BuildContext context, RouteModel route) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => onRouteTap(context, route),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线图片
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 180,
                width: double.infinity,
                color: AppColors.primary.withOpacity(0.1),
                child: route.coverUrl == null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            route.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                CupertinoIcons.photo,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: route.getDifficultyColor()!.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                route.getDifficultyName(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Icon(
                          CupertinoIcons.photo,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),

            // 路线名称
            Text(
              route.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // 路线信息
            Row(
              children: [
                const Icon(
                  CupertinoIcons.star_fill,
                  size: 14,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  "",
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${route.basicInfo.duration}天',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  route.region!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // 最佳季节
            Text(
              '最佳季节: ${route.basicInfo.bestSeason.join(", ")}',
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建水平路线卡片
  Widget _buildHorizontalRouteCard(BuildContext context, RouteModel route) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => onRouteTap(context, route),
        child: Row(
          children: [
            // 路线图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 80,
                width: 80,
                color: AppColors.primary.withOpacity(0.1),
                child: route.coverUrl == null
                    ? Image.network(
                        route.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            CupertinoIcons.photo,
                            size: 24,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          CupertinoIcons.photo,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 8),

            // 路线信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 路线名称
                  Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // 评分
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.star_fill,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        route.ratings.overall.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // 时长和难度
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: route.getDifficultyColor()!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          route.getDifficultyName(),
                          style: TextStyle(
                            fontSize: 10,
                            color: route.getDifficultyColor(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${route.basicInfo.duration}天',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
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
}