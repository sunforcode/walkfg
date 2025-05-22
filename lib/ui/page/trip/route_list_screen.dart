import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/model/route/route_model.dart';
import '../../../theme/theme/app_colors.dart';
import '../route/cupertino_route_detail_screen.dart';

/// 路线列表页面
class RouteListScreen extends StatefulWidget {
  /// 页面标题
  final String title;

  /// 路线列表Future
  final Future<List<RouteModel>> routesFuture;

  /// 构造函数
  const RouteListScreen({
    super.key,
    required this.title,
    required this.routesFuture,
  });

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: SafeArea(
        child: FutureBuilder<List<RouteModel>>(
          future: widget.routesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 50,
                      color: CupertinoColors.systemRed,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      child: const Text('重试'),
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              );
            }

            final routes = snapshot.data;
            if (routes == null || routes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.map,
                      size: 50,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '暂无路线',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('没有找到符合条件的路线'),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: routes.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final route = routes[index];
                return _buildRouteCard(context, route);
              },
            );
          },
        ),
      ),
    );
  }

  /// 构建路线卡片
  Widget _buildRouteCard(BuildContext context, RouteModel route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          _navigateToRouteDetail(context, route);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线图片
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: route.coverUrl != null
                    ? Image.network(
                        route.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.photo,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.photo,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ),

            // 路线信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 路线名称
                  Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 路线基本信息
                  Row(
                    children: [
                      _buildInfoChip(
                        CupertinoIcons.star_fill,
                        '${route.ratings.overall}分',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        CupertinoIcons.arrow_right_arrow_left,
                        '${route.basicInfo.distance}公里',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        CupertinoIcons.time,
                        route.basicInfo.duration,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        CupertinoIcons.chart_bar,
                        route.getDifficultyName(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 最佳季节
                  Text(
                    '最佳季节: ${route.basicInfo.bestSeason.join(", ")}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 规划按钮
                  CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    minSize: 30,
                    onPressed: () {
                      _navigateToRouteDetail(context, route);
                    },
                    child: const Text(
                      '规划此行程',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
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
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.primary,
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
  void _navigateToRouteDetail(BuildContext context, RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteDetailScreen(
          routeId: route.id,
          route: route,
        ),
      ),
    );
  }
}
