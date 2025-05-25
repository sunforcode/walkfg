import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/page/trip_plan/trip_planning_page.dart';
import '../../../model/model/route/route_model.dart';
import '../../../model/model/map/map_bounds.dart';
import '../../../model/model/map/track_point_model.dart';
import '../../../service/service_manager.dart';
import '../../../service/map_service.dart';
import '../../../ui/map/unified_map_widget.dart';
import '../../../ui/map/utils/kml_parser.dart';
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
  late MapService _mapService;
  bool _isFavorite = false;

  /// KML轨迹点
  List<TrackPointVO> _kmlTrackPoints = [];

  /// KML路标点
  List<TrackPointVO> _kmlWaypoints = [];

  @override
  void initState() {
    super.initState();
    _mapService = ServiceLocator.instance.getMapService();
    _loadRouteDetail();
    _loadKmlData(); // 加载KML数据
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

  /// 从KML文件加载轨迹数据
  Future<void> _loadKmlData() async {
    try {
      print('开始加载KML文件: assets/maps/wutai.kml');

      // 解析KML文件
      final mapData = await KmlParser.parseFromAsset('assets/maps/wutai.kml');

      print(
          'KML解析成功，轨迹点数量: ${mapData.trackPoints.length}，路标点数量: ${mapData.waypoints.length}');
      if (mapData.trackPoints.isNotEmpty) {
        print('第一个轨迹点: ${mapData.trackPoints.first}');
        print('最后一个轨迹点: ${mapData.trackPoints.last}');
      }

      if (mapData.waypoints.isNotEmpty) {
        print('第一个路标点: ${mapData.waypoints.first}');
      }

      // 设置KML轨迹点和路标点
      setState(() {
        _kmlTrackPoints = mapData.trackPoints;
        _kmlWaypoints = mapData.waypoints;
      });

      print('设置KML轨迹点，数量: ${_kmlTrackPoints.length}');
      print('设置KML路标点，数量: ${_kmlWaypoints.length}');
    } catch (e) {
      print('KML解析失败: $e');
      print('错误堆栈: ${StackTrace.current}');

      // 尝试创建一些测试轨迹点
      setState(() {
        _kmlTrackPoints = [
          TrackPointVO(
            latitude: 39.9042,
            longitude: 116.4074,
            elevation: 100,
            name: '测试点1',
          ),
          TrackPointVO(
            latitude: 39.9142,
            longitude: 116.4174,
            elevation: 110,
            name: '测试点2',
          ),
          TrackPointVO(
            latitude: 39.9242,
            longitude: 116.4274,
            elevation: 120,
            name: '测试点3',
          ),
        ];

        _kmlWaypoints = [
          TrackPointVO(
            latitude: 39.9042,
            longitude: 116.4074,
            elevation: 100,
            name: '起点',
            type: '起点',
          ),
          TrackPointVO(
            latitude: 39.9242,
            longitude: 116.4274,
            elevation: 120,
            name: '终点',
            type: '终点',
          ),
        ];
      });

      print('创建测试轨迹点，数量: ${_kmlTrackPoints.length}');
      print('创建测试路标点，数量: ${_kmlWaypoints.length}');
    }
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

  /// 开始规划行程
  void _startPlanning(RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TripPlanningPage2(route: route),
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

  /// 处理离线地图下载
  void _handleDownloadOfflineMap(
      MapBoundsVO bounds, MapType mapType, MapProviderType mapProvider) {
    // _mapService.downloadOfflineMap(
    //   bounds,
    //   mapType,
    //   mapProvider,
    //   (message) => _showToast(message),
    //   (error) => _showToast(error),
    // );
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
    return ChangeNotifierProvider.value(
      value: _mapService,
      child: CupertinoPageScaffold(
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
                trackPoints: _kmlTrackPoints, // 传递KML轨迹点
                waypoints: _kmlWaypoints, // 传递KML路标点
                isFavorite: _isFavorite,
                onViewMap: _showFeatureInDevelopmentDialog,
                onPlanTrip: () => _startPlanning(route),
                onFavorite: _handleFavorite,
                onDownloadOfflineMap: _handleDownloadOfflineMap,
              );
            },
          ),
        ),
      ),
    );
  }
}
