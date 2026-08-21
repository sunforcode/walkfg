import 'package:flutter/material.dart';

import '../../../../model/route/route_model.dart';
import '../../common/error_widget.dart';
import '../../common/loading_indicator.dart';
import 'route_result_item.dart';

/// 导航页面推荐路线组件
class NavRecommendedRoutesSection extends StatelessWidget {
  /// 推荐路线列表 Future
  final Future<List<RouteModel>> recommendedRoutesFuture;

  /// 点击路线的回调
  final ValueChanged<RouteModel> onRouteTap;

  /// 重试回调
  final VoidCallback onRetry;

  /// 构造函数
  const NavRecommendedRoutesSection({
    super.key,
    required this.recommendedRoutesFuture,
    required this.onRouteTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '推荐路线',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        FutureBuilder<List<RouteModel>>(
          future: recommendedRoutesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingIndicator());
            }

            if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: '无法加载推荐路线',
                onRetry: onRetry,
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('暂无推荐路线'),
              );
            }

            final routes = snapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routes.length > 3 ? 3 : routes.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final route = routes[index];
                return RouteResultItem(
                  route: route,
                  onTap: () => onRouteTap(route),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
