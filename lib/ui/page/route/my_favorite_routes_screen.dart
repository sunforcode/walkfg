import 'package:flutter/cupertino.dart';
import '../../../model/route/route_model.dart';
import '../../../service/route_service.dart';
import '../common/loading_indicator.dart';
import '../common/error_widget.dart';
import '../common/empty_content_widget.dart';
import 'detail/route_detail_screen.dart';

/// 我的收藏路线页面
class MyFavoriteRoutesScreen extends StatefulWidget {
  /// 构造函数
  const MyFavoriteRoutesScreen({super.key});

  @override
  State<MyFavoriteRoutesScreen> createState() => _MyFavoriteRoutesScreenState();
}

class _MyFavoriteRoutesScreenState extends State<MyFavoriteRoutesScreen> {
  /// 收藏路线列表Future
  late Future<List<RouteModel>> _favoriteRoutesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavoriteRoutes();
  }

  /// 加载收藏路线
  void _loadFavoriteRoutes() {
    _favoriteRoutesFuture = RouteService.getFavoriteRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('我的收藏路线'),
      ),
      child: SafeArea(
        child: FutureBuilder<List<RouteModel>>(
          future: _favoriteRoutesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }

            if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    _loadFavoriteRoutes();
                  });
                },
              );
            }

            final routes = snapshot.data;
            if (routes == null || routes.isEmpty) {
              return const EmptyContentWidget(
                icon: CupertinoIcons.heart,
                title: '暂无收藏路线',
                subtitle: '浏览路线并收藏你喜欢的路线',
              );
            }

            return _buildRoutesList(routes);
          },
        ),
      ),
    );
  }

  /// 构建路线列表
  Widget _buildRoutesList(List<RouteModel> routes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return _buildRouteCard(route);
      },
    );
  }

  /// 构建路线卡片
  Widget _buildRouteCard(RouteModel route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToRouteDetail(route),
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 路线图片
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: route.coverUrl != null
                    ? Image.network(
                        route.coverUrl!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 150,
                        width: double.infinity,
                        color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
                        child: const Icon(
                          CupertinoIcons.photo,
                          size: 48,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
              ),
              
              // 路线信息
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          CupertinoIcons.location_solid,
                          route.region,
                        ),
                        const SizedBox(width: 12),
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
                    const SizedBox(height: 8),
                    Text(
                      route.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey.darkColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  /// 导航到路线详情页面
  void _navigateToRouteDetail(RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteDetailScreen(
          routeId: route.id,
        ),
      ),
    );
  }
}