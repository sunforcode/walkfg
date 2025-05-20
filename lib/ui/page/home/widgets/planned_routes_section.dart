import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/route/route_model.dart';
import '../../route/cupertino_route_list_screen.dart';
import '../../route/cupertino_route_detail_screen.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/empty_content_widget.dart';

/// 规划路线部分组件
class PlannedRoutesSection extends StatelessWidget {
  /// 规划路线列表Future
  final Future<List<PlannedRouteModel>> plannedRoutesFuture;

  /// 构造函数
  const PlannedRoutesSection({
    super.key,
    required this.plannedRoutesFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 规划路线标题
        SectionHeader(
          title: '我的规划路线',
          actionText: '查看全部',
          onAction: () => _navigateToAllRoutes(context),
        ),

        const SizedBox(height: 16),

        // 规划路线列表
        FutureBuilder<List<PlannedRouteModel>>(
          future: plannedRoutesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator(height: 120);
            }

            if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: snapshot.error.toString(),
                onRetry: () {}, // 提供一个空函数而不是null
              );
            }

            final plannedRoutes = snapshot.data;
            if (plannedRoutes == null || plannedRoutes.isEmpty) {
              return const EmptyContentWidget(
                icon: CupertinoIcons.map,
                title: '暂无规划路线',
                subtitle: '开始规划你的第一条路线吧',
              );
            }

            return _buildPlannedRoutesList(context, plannedRoutes);
          },
        ),
      ],
    );
  }

  /// 构建规划路线列表
  Widget _buildPlannedRoutesList(
      BuildContext context, List<PlannedRouteModel> plannedRoutes) {
    // 蓝色系颜色列表
    final List<Color> blueColors = [
      const Color(0xFF1976D2), // 深蓝色
      const Color(0xFF2196F3), // 蓝色
      const Color(0xFF42A5F5), // 浅蓝色
      const Color(0xFF64B5F6), // 更浅的蓝色
      const Color(0xFF0D47A1), // 深邃蓝色
      const Color(0xFF0288D1), // 亮蓝色
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: plannedRoutes.length,
        itemBuilder: (context, index) {
          final route = plannedRoutes[index];
          final color = blueColors[index % blueColors.length];

          return Padding(
            padding: EdgeInsets.only(
              right: index == plannedRoutes.length - 1 ? 0 : 12,
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _navigateToRouteDetail(context, route),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.map,
                            color: color,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            route.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      route.notes ?? '暂无描述',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey.darkColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${route.days} 天',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          route.getStatusName(),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(route.getStatusName()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case '已完成':
        return CupertinoColors.systemGreen;
      case '进行中':
      case '规划中':
        return CupertinoColors.systemBlue;
      case '已取消':
      case '未开始':
        return CupertinoColors.systemGrey;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  /// 导航到所有路线页面
  void _navigateToAllRoutes(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => const RouteListScreen(),
      ),
    );
  }

  /// 导航到路线详情页面
  void _navigateToRouteDetail(BuildContext context, PlannedRouteModel route) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => RouteDetailScreen(
          routeId: route.routeId,
        ),
      ),
    );
  }
}
