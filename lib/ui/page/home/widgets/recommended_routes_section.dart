import 'package:flutter/cupertino.dart';
import 'package:walk/theme/tokens/tokens.dart';
import 'package:walk/ui/page/common/network_image_with_fallback.dart';
import '../../../../model/route/route_model.dart';
import '../../route/route_discovery_screen.dart';
import '../../route/detail/route_detail_screen.dart';
import '../../common/section_header.dart';
import '../../common/loading_indicator.dart';
import '../../common/error_widget.dart';
import '../../common/empty_content_widget.dart';

/// 当季推荐路线部分组件
class RecommendedRoutesSection extends StatelessWidget {
  /// 推荐路线列表Future
  final Future<List<RouteModel>> recommendedRoutesFuture;

  /// 构造函数
  const RecommendedRoutesSection({
    super.key,
    required this.recommendedRoutesFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 当季推荐路线标题
        SectionHeader(
          title: '当季推荐路线',
          actionText: '查看全部',
          onAction: () => _navigateToAllRoutes(context),
        ),

        const SizedBox(height: 16),

        // 推荐路线列表
        FutureBuilder<List<RouteModel>>(
          future: recommendedRoutesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator(height: 200);
            }

            if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: snapshot.error.toString(),
                onRetry: () {}, // 提供一个空函数而不是null
              );
            }

            final recommendedRoutes = snapshot.data;
            if (recommendedRoutes == null || recommendedRoutes.isEmpty) {
              return const EmptyContentWidget(
                icon: CupertinoIcons.map,
                title: '暂无推荐路线',
                subtitle: '敬请期待更多精彩路线',
              );
            }

            return _buildRecommendedRoutesList(context, recommendedRoutes);
          },
        ),
      ],
    );
  }

  /// 构建推荐路线列表
  Widget _buildRecommendedRoutesList(BuildContext context, List<RouteModel> recommendedRoutes) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendedRoutes.length,
        itemBuilder: (context, index) {
          final route = recommendedRoutes[index];
          final color = AppColors.getBlueColor(index);

          return Padding(
            padding: EdgeInsets.only(
              right: index == recommendedRoutes.length - 1 ? 0 : AppSpacing.md,
            ),
            child: _buildRouteCard(context, route, color),
          );
        },
      ),
    );
  }

  /// 构建路线卡片
  Widget _buildRouteCard(BuildContext context, RouteModel route, Color color) {
    return GestureDetector(
      onTap: () => _navigateToRouteDetail(context, route),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderLg,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 路线图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
              child: route.coverUrl != null
                  ? NetworkImageWithFallback(
                      url: route.coverUrl!,
                      height: 140,
                      width: 280,
                      fit: BoxFit.cover,
                      fallbackColor: color,
                    )
                  : Container(
                      height: 140,
                      width: 280,
                      color: color.withOpacity(0.1),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.photo,
                          size: 40,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
            ),

            // 路线信息
            Container(
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.lg),
                ),
              ),
              padding: AppSpacing.allSm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        size: 12,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        route.region,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.arrow_up_right_square,
                        size: 12,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${route.distance} km',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
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

  /// 导航到所有路线页面
  void _navigateToAllRoutes(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => const RouteDiscoveryScreen(),
      ),
    );
  }

  /// 导航到路线详情页面
  void _navigateToRouteDetail(BuildContext context, RouteModel route) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => RouteDetailScreen(
          routeId: route.id,
        ),
      ),
    );
  }
}
