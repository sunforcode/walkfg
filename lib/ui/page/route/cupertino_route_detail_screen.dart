import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/model/route/route_model.dart';
import '../../../service/service_manager.dart';
import '../trip/trip_planning_detail_screen.dart';
import '../map/route_map_widget.dart';
import 'widgets/common_views.dart';
import 'widgets/route_detail_content.dart';

/// iOS风格的路线详情页面
class RouteDetailScreen extends StatefulWidget {
  /// 路线ID
  final String routeId;

  /// 路线数据（可选，如果提供则不需要加载）
  final RouteModel? route;

  /// 构造函数
  const RouteDetailScreen({
    super.key,
    required this.routeId,
    this.route,
  });

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late Future<RouteModel> _routeFuture;
  MapType _currentMapType = MapType.standard;

  @override
  void initState() {
    super.initState();
    _loadRouteDetail();
  }

  /// 加载路线详情
  void _loadRouteDetail() {
    if (widget.route != null) {
      _routeFuture = Future.value(widget.route!);
    } else {
      final apiService = ServiceLocator.instance.getRouteService();
      _routeFuture = apiService.getRouteById(widget.routeId);
    }
  }

  /// 处理地图类型变更
  void _handleMapTypeChanged(MapType mapType) {
    setState(() {
      _currentMapType = mapType;
    });
  }

  /// 开始规划行程
  void _startPlanning(RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TripPlanningDetailScreen(route: route),
      ),
    );
  }

  /// 显示功能开发中对话框
  void _showFeatureInDevelopmentDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: const Text('该功能正在开发中'),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('路线详情'),
      ),
      child: SafeArea(
        child: FutureBuilder<RouteModel>(
          future: _routeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }

            if (snapshot.hasError) {
              return ErrorView(
                error: snapshot.error,
                onRetry: () {
                  setState(() {
                    _loadRouteDetail();
                  });
                },
              );
            }

            final route = snapshot.data!;
            // print(
                // '路线详情页 - 加载路线: ${route.name}, 轨迹点数量: ${route..length ?? 0}');
            return RouteDetailContent(
              route: route,
              currentMapType: _currentMapType,
              onMapTypeChanged: _handleMapTypeChanged,
              onViewMap: _showFeatureInDevelopmentDialog,
              onPlanTrip: () => _startPlanning(route),
              onFavorite: _showFeatureInDevelopmentDialog,
            );
          },
        ),
      ),
    );
  }
}
