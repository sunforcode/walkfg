import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/model/route/route_model.dart';
import '../../../service/service_manager.dart';
import '../trip/trip_planning_detail_screen.dart';
import '../map/route_map_widget.dart';
import 'widgets/common_views.dart';
import 'widgets/route_detail_content.dart';
import 'my_favorite_routes_screen.dart';

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
  bool _isFavorite = false;

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

    // 检查路线是否已收藏
    _checkIfFavorite();
  }

  /// 检查路线是否已收藏
  void _checkIfFavorite() {
    final apiService = ServiceLocator.instance.getRouteService();
    apiService.checkIfFavorite(widget.routeId).then((isFavorite) {
      setState(() {
        _isFavorite = isFavorite;
      });
    });
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

  /// 处理收藏操作
  void _handleFavorite() {
    final apiService = ServiceLocator.instance.getRouteService();

    if (_isFavorite) {
      // 如果已收藏，则取消收藏
      apiService.removeFavorite(widget.routeId).then((_) {
        setState(() {
          _isFavorite = false;
        });
        _showToast('已取消收藏');
      });
    } else {
      // 如果未收藏，则添加收藏
      apiService.addFavorite(widget.routeId).then((_) {
        setState(() {
          _isFavorite = true;
        });
        _showToast('已添加到收藏');

        // 导航到收藏路线页面
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const MyFavoriteRoutesScreen(),
          ),
        );
      });
    }
  }

  /// 显示提示信息
  void _showToast(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
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
            return RouteDetailContent(
              route: route,
              currentMapType: _currentMapType,
              onMapTypeChanged: _handleMapTypeChanged,
              onViewMap: _showFeatureInDevelopmentDialog,
              onPlanTrip: () => _startPlanning(route),
              onFavorite: _handleFavorite,
              isFavorite: _isFavorite,
            );
          },
        ),
      ),
    );
  }
}
