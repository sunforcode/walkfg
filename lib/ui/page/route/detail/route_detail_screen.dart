import 'package:flutter/cupertino.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/segment_model.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/service/service_manager.dart';
import 'package:walk/ui/map/components/enhanced_daily_map_widget.dart';
import 'package:walk/ui/map/utils/kml_parser.dart';
import 'package:walk/ui/page/common/error_view.dart';
import 'package:walk/ui/page/common/loading_view.dart';
import 'package:walk/ui/page/route/detail/widgets/route_overview_widget.dart';
import 'package:walk/ui/page/trip/trip_detail_screen.dart';
import 'package:walk/utils/toast_utils.dart';
import 'widgets/route_detail_info_widget.dart';
import 'widgets/route_action_buttons.dart';
import 'widgets/daily_itinerary_list_widget.dart';
import 'widgets/seasonal_equipment_widget.dart';
import 'widgets/water_sources_widget.dart';
import 'widgets/supply_points_widget.dart';
import 'widgets/campsites_widget.dart';
import 'widgets/related_routes_widget.dart';
import 'widgets/related_trips_widget.dart';
import 'widgets/route_gallery_widget.dart';
import 'widgets/hitchhike_contacts_widget.dart';
import 'widgets/route_segments_widget.dart';
import '../my_favorite_routes_screen.dart';

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
  late ScrollController _scrollController;
  bool _isFavorite = false;
  bool _isMapFloating = false;

  /// 轨迹点数据
  List<TrackPointVO> _kmlTrackPoints = [];

  /// 路标点数据
  List<TrackPointVO> _kmlWaypoints = [];

  /// 相关路线列表
  List<RouteModel> _relatedRoutes = [];

  /// 相关行程列表
  List<TripModel> _relatedTrips = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadRouteDetail();
    _loadRouteData();
    _loadKmlData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 监听滚动事件
  void _onScroll() {
    const threshold = 200.0;
    final shouldFloat = _scrollController.offset > threshold;

    if (shouldFloat != _isMapFloating) {
      setState(() {
        _isMapFloating = shouldFloat;
      });
    }
  }

  /// 加载路线详情
  void _loadRouteDetail() {
    if (widget.route != null) {
      _routeFuture = Future.value(widget.route!);
    } else {
      final apiService = ServiceLocator.instance.getRouteService();
      _routeFuture = apiService.getRouteById(widget.routeId);
    }
    _checkIfFavorite();
  }

  /// 从KML文件加载轨迹数据
  Future<void> _loadKmlData() async {
    try {
      print('开始加载KML数据...');
      // 使用新的parseFromPath方法替代已废弃的parseFromAsset
      final mapData = await KmlParser.parseFromPath('assets/maps/wutai.kml');
      print(
          'KML数据加载成功: 轨迹点${mapData.trackPoints.length}个, 路标点${mapData.waypoints.length}个');

      setState(() {
        _kmlTrackPoints = mapData.trackPoints;
        _kmlWaypoints = mapData.waypoints;
      });

      // 验证数据是否正确加载
      if (_kmlTrackPoints.isNotEmpty) {
        print(
            '第一个轨迹点: lat=${_kmlTrackPoints.first.latitude}, lng=${_kmlTrackPoints.first.longitude}');
      }
      if (_kmlWaypoints.isNotEmpty) {
        print(
            '第一个路标点: lat=${_kmlWaypoints.first.latitude}, lng=${_kmlWaypoints.first.longitude}');
      }
    } catch (e, stackTrace) {
      // 如果KML文件加载失败，使用模拟数据
      print('KML文件加载失败: $e');
      print('堆栈跟踪: $stackTrace');
      print(
          '使用模拟数据: 轨迹点${_kmlTrackPoints.length}个, 路标点${_kmlWaypoints.length}个');
    }
  }

  /// 加载路线相关数据
  Future<void> _loadRouteData() async {
    final routeDataService = ServiceLocator.instance.getRouteService();
    final tripService = ServiceLocator.instance.getTripService();
    try {
      final results = await Future.wait([
        routeDataService.getRelatedRoutes(widget.routeId),
        tripService.getRelatedTrips(widget.routeId),
      ]);
      setState(() {
        _relatedRoutes = results[0] as List<RouteModel>;
        _relatedTrips = results[1] as List<TripModel>;
      });
    } catch (e) {
      print('加载路线数据失败: $e');
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
        builder: (context) => TripDetailScreen(
          routeId: route.id,
        ),
      ),
    );
  }

  /// 处理收藏操作
  void _handleFavorite() {
    final apiService = ServiceLocator.instance.getRouteService();

    if (_isFavorite) {
      apiService.removeFavorite(widget.routeId).then((_) {
        setState(() {
          _isFavorite = false;
        });
        ToastUtils.showToast(context, '已取消收藏');
      });
    } else {
      apiService.addFavorite(widget.routeId).then((_) {
        setState(() {
          _isFavorite = true;
        });
        ToastUtils.showToast(context, '已添加到收藏');

        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const MyFavoriteRoutesScreen(),
          ),
        );
      });
    }
  }

  /// 处理日程点击
  void _handleDayTap(int dayIndex) {
    print('点击第${dayIndex + 1}天');
  }

  /// 处理图片点击
  void _handleImageTap(int index) {
    print('点击图片: $index');
  }

  /// 处理相关路线点击
  void _handleRelatedRouteTap(RouteModel route) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => RouteDetailScreen(
          routeId: route.id,
          route: route,
        ),
      ),
    );
  }

  /// 处理相关行程点击
  void _handleRelatedTripTap(TripModel trip) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TripDetailScreen(
          tripModel: trip,
        ),
      ),
    );
  }

  /// 处理悬浮地图点击
  void _handleFloatingMapTap() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() {
      _isMapFloating = false;
    });
  }

  /// 关闭悬浮地图
  void _closeFloatingMap() {
    setState(() {
      _isMapFloating = false;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
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
                message: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    _loadRouteDetail();
                  });
                },
              );
            }

            final route = snapshot.data!;
            final currentTrack = route.defaultMap;

            return Stack(
              children: [
                // 主要内容
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // 地图区域
                    SliverToBoxAdapter(
                      child: EnhancedDailyMapWidget(
                        trackPoints: _kmlTrackPoints,
                        markers: [],
                        days: 3,
                        height: 400,
                      ),
                    ),

                    // 路线概览
                    SliverToBoxAdapter(
                      child: RouteOverviewWidget(route: route),
                    ),

                    // 详细地图参数信息
                    if (currentTrack != null)
                      SliverToBoxAdapter(
                        child: RouteDetailInfoWidget(
                          currentTrack: currentTrack,
                        ),
                      ),

                    // 每日行程列表
                    SliverToBoxAdapter(
                      child: DailyItineraryListWidget(
                        dailyPlans: route.dailyPlans,
                        onDayTap: _handleDayTap,
                      ),
                    ),

                    // 当季出行装备推荐
                    if (currentTrack != null)
                      SliverToBoxAdapter(
                        child: SeasonalEquipmentWidget(
                          currentSeason: '春季',
                          difficulty: route.difficulty.name,
                        ),
                      ),

                    // 水源点详解
                    SliverToBoxAdapter(
                      child: WaterSourcesWidget(
                        waterSources: route.waterSources,
                      ),
                    ),

                    // 补给点详解
                    SliverToBoxAdapter(
                      child: SupplyPointsWidget(
                        supplyPoints: route.supplyPoints,
                      ),
                    ),

                    // 营地资源
                    SliverToBoxAdapter(
                      child: CampsitesWidget(
                        campsites: route.campsites,
                      ),
                    ),

                    // 路线分段介绍
                    SliverToBoxAdapter(
                      child: RouteSegmentsWidget(
                        segments: route.segments,
                      ),
                    ),

                    // 搭车联系方式
                    SliverToBoxAdapter(
                      child: HitchhikeContactsWidget(
                        contacts: route.hitchhikeContacts,
                      ),
                    ),

                    // 相关路线推荐
                    SliverToBoxAdapter(
                      child: RelatedRoutesWidget(
                        relatedRoutes: _relatedRoutes,
                        onRouteTap: _handleRelatedRouteTap,
                      ),
                    ),

                    // 相关行程推荐
                    SliverToBoxAdapter(
                      child: RelatedTripsWidget(
                        routeId: route.id,
                        relatedTrips: _relatedTrips,
                        onTripTap: _handleRelatedTripTap,
                      ),
                    ),
                    // 路线图片推荐
                    SliverToBoxAdapter(
                      child: RouteGalleryWidget(
                        imageUrls: route.imageUrls,
                        onImageTap: _handleImageTap,
                      ),
                    ),

                    // 操作按钮
                    SliverToBoxAdapter(
                      child: RouteActionButtons(
                        route: route,
                        isFavorite: _isFavorite,
                        onPlanTrip: () => _startPlanning(route),
                        onToggleFavorite: _handleFavorite,
                        onMapAction: () =>
                            ToastUtils.showFeatureInDevelopmentDialog(context),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
