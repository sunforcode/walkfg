import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/route/route_model.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/empty_content_widget.dart';
import 'route_card.dart';

/// 路线列表视图组件
class RoutesListView extends StatelessWidget {
  /// 路线列表Future
  final Future<List<RouteModel>> routesFuture;

  /// 路线点击回调
  final Function(RouteModel route)? onRouteTap;

  /// 规划按钮点击回调
  final Function(RouteModel route)? onPlanningTap;

  /// 重试回调
  final VoidCallback? onRetry;

  /// 空内容提示文本
  final String emptyText;

  /// 构造函数
  const RoutesListView({
    super.key,
    required this.routesFuture,
    this.onRouteTap,
    this.onPlanningTap,
    this.onRetry,
    this.emptyText = '暂无路线',
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RouteModel>>(
      future: routesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: LoadingIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 200,
            child: Center(
              child: ErrorMessageWidget(
                errorMessage: snapshot.error.toString(),
                onRetry: onRetry ?? () {},
              ),
            ),
          );
        }

        final routes = snapshot.data!;
        if (routes.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: EmptyContentWidget(
                icon: Icons.hiking,
                title: emptyText,
              ),
            ),
          );
        }

        return Column(
          children: routes.map((route) => _buildRouteCard(route)).toList(),
        );
      },
    );
  }

  /// 构建路线卡片
  Widget _buildRouteCard(RouteModel route) {
    return RouteCard(
      route: route,
      onTap: onRouteTap != null ? () => onRouteTap!(route) : null,
      onPlanningTap: onPlanningTap != null ? () => onPlanningTap!(route) : null,
    );
  }
}
