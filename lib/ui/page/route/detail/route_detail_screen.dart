import 'package:flutter/cupertino.dart';
import 'package:walk/core/constants/spacing_constants.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/service/service_manager.dart';
import 'package:walk/ui/map/components/enhanced_daily_map_widget.dart';
import 'package:walk/ui/map/utils/kml_business_parser.dart';
import 'package:walk/ui/page/common/error_view.dart';
import 'package:walk/ui/page/common/loading_view.dart';
import 'package:walk/ui/page/common/floating_back_button.dart';
import 'package:walk/ui/page/route/detail/widgets/route_overview_widget.dart';
import 'package:walk/ui/page/trip/trip_detail_screen.dart';
import 'package:walk/utils/toast_utils.dart';

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

  /// 当前地图显示模式
  MapDisplayMode _mapDisplayMode = MapDisplayMode.standard;

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
    _loadRouteDetail();
    _loadRouteData();
    _loadKmlData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载路线详情
  void _loadRouteDetail() {
    final apiService = ServiceLocator.instance.getRouteService();

    // 如果传入了route参数，从route中获取routeId请求详情
    if (widget.route != null) {
      _routeFuture = apiService.getRouteDetail(widget.route!.id);
    } else {
      // 如果没有传入route参数，使用传入的routeId请求详情
      _routeFuture = apiService.getRouteDetail(widget.routeId);
    }
    _checkIfFavorite();
  }

  /// 从KML文件加载轨迹数据
  Future<void> _loadKmlData() async {
    try {
      print('开始加载KML数据...');
      // 使用新的parseFromPath方法替代已废弃的parseFromAsset
      final mapData =
          await KmlBusinessParser.parseFromPath('assets/maps/wutai.kml');
      print(
          'KML数据加载成功: 轨迹点${mapData.trackPoints.length}个, 路标点${mapData.waypoints.length}个');

      setState(() {
        _kmlTrackPoints = mapData.trackPoints;
        _kmlWaypoints = mapData.waypoints;
      });
    } catch (e) {
      print('KML文件加载失败: $e');
    }
  }

  /// 加载路线相关数据
  Future<void> _loadRouteData() async {
    try {
      final results = await Future.wait([
        // routeDataService.getRelatedRoutes(widget.routeId),
        // tripService.getRelatedTrips(widget.routeId),
      ]);
      setState(() {
        _relatedRoutes =
            results.isNotEmpty ? results[0] as List<RouteModel> : [];
        _relatedTrips = results.length > 1 ? results[1] as List<TripModel> : [];
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

  /// 获取当前模式的地图高度
  double _getMapHeight() {
    switch (_mapDisplayMode) {
      case MapDisplayMode.compact:
        return 300.0;
      case MapDisplayMode.standard:
        return 400.0;
      case MapDisplayMode.immersive:
        return MediaQuery.of(context).size.height;
    }
  }

  /// 获取当前模式是否固定显示
  bool _isMapFixed() {
    return _mapDisplayMode != MapDisplayMode.standard; // 只有标准模式可以跟随滚动
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
                    // 地图占位区域（只有在地图固定时才需要占位）
                    if (_isMapFixed())
                      SliverToBoxAdapter(
                        child: SizedBox(height: _getMapHeight()),
                      )
                    else
                      // 地图跟随滚动时，直接放在滚动列表中
                      SliverToBoxAdapter(
                        child: EnhancedDailyMapWidget(
                          trackPoints: _kmlTrackPoints,
                          markers: route.markerPoints,
                          days: route.dailyPlans?.length ?? 1,
                          height: _getMapHeight(),
                          displayMode: _mapDisplayMode,
                          onDisplayModeChanged: (mode) {
                            setState(() {
                              _mapDisplayMode = mode;
                            });
                          },
                        ),
                      ),

                    // 路线标题和简短信息
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PaddingConstants.pageHorizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              route.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // 间距
                    const SliverToBoxAdapter(
                      child: Spacing.lg,
                    ),

                    // 路线概览
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PaddingConstants.pageHorizontal,
                        child: RouteOverviewWidget(route: route),
                      ),
                    ),

                    // 间距
                    const SliverToBoxAdapter(
                      child: Spacing.component,
                    ),

                    // 每日行程列表
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PaddingConstants.pageHorizontal,
                        child: DailyItineraryListWidget(
                          dailyPlans: route.dailyPlans ?? [],
                          onDayTap: _handleDayTap,
                        ),
                      ),
                    ),

                    // 间距
                    const SliverToBoxAdapter(
                      child: Spacing.component,
                    ),

                    // 当季出行装备推荐
                    if (currentTrack != null) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: PaddingConstants.pageHorizontal,
                          child: SeasonalEquipmentWidget(
                            currentSeason: '春季',
                            difficulty: route.difficulty.name,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: Spacing.component,
                      ),
                    ],

                    // 水源点详解
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PaddingConstants.pageHorizontal,
                        child: WaterSourcesWidget(
                          waterSources: route.waterSources ?? [],
                        ),
                      ),
                    ),

                    // 间距
                    const SliverToBoxAdapter(
                      child: Spacing.component,
                    ),

                    // 补给点详解
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PaddingConstants.pageHorizontal,
                        child: SupplyPointsWidget(
                          supplyPoints: route.supplyPoints ?? [],
                        ),
                      ),
                    ),

                    // 间距
                    const SliverToBoxAdapter(
                      child: Spacing.component,
                    ),

                    // 营地资源
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PaddingConstants.pageHorizontal,
                        child: CampsitesWidget(
                          campsites: route.campsites ?? [],
                        ),
                      ),
                    ),

                    // 间距
                    const SliverToBoxAdapter(
                      child: Spacing.component,
                    ),

                    // 路线分段介绍
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PaddingConstants.pageHorizontal,
                        child: RouteSegmentsWidget(
                          segments: route.segments ?? [],
                        ),
                      ),
                    ),

                    // 间距
                    const SliverToBoxAdapter(
                      child: Spacing.component,
                    ),

                    // 搭车联系方式
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PaddingConstants.pageHorizontal,
                        child: HitchhikeContactsWidget(
                          contacts: route.hitchhikeContacts ?? [],
                        ),
                      ),
                    ),

                    // 间距
                    const SliverToBoxAdapter(
                      child: Spacing.component,
                    ),

                    // 相关路线推荐
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PaddingConstants.pageHorizontal,
                        child: RelatedRoutesWidget(
                          relatedRoutes: _relatedRoutes,
                          onRouteTap: _handleRelatedRouteTap,
                        ),
                      ),
                    ),

                    // 间距
                    const SliverToBoxAdapter(
                      child: Spacing.component,
                    ),

                    // 相关行程推荐
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PaddingConstants.pageHorizontal,
                        child: RelatedTripsWidget(
                          routeId: route.id,
                          relatedTrips: _relatedTrips,
                          onTripTap: _handleRelatedTripTap,
                        ),
                      ),
                    ),

                    // 间距
                    const SliverToBoxAdapter(
                      child: Spacing.component,
                    ),

                    // 路线图片推荐
                    SliverToBoxAdapter(
                      child: RouteGalleryWidget(
                        imageUrls: route.imageUrls ?? [],
                        onImageTap: _handleImageTap,
                      ),
                    ),

                    // 间距
                    const SliverToBoxAdapter(
                      child: Spacing.page,
                    ),

                    // 操作按钮
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: PaddingConstants.pageHorizontal,
                        child: RouteActionButtons(
                          route: route,
                          isFavorite: _isFavorite,
                          onPlanTrip: () => _startPlanning(route),
                          onToggleFavorite: _handleFavorite,
                          onMapAction: () =>
                              ToastUtils.showFeatureInDevelopmentDialog(
                                  context),
                        ),
                      ),
                    ),

                    // 底部安全间距
                    const SliverToBoxAdapter(
                      child: Spacing.safe,
                    ),
                  ],
                ),

                // 固定的地图组件（只有在固定模式下才显示）
                if (_isMapFixed())
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom:
                        _mapDisplayMode == MapDisplayMode.immersive ? 0 : null,
                    child: Container(
                      height: _mapDisplayMode == MapDisplayMode.immersive
                          ? null
                          : _getMapHeight(),
                      child: EnhancedDailyMapWidget(
                        trackPoints: _kmlTrackPoints,
                        markers: route.markerPoints,
                        days: route.dailyPlans?.length ?? 1,
                        height: _getMapHeight(),
                        displayMode: _mapDisplayMode,
                        onDisplayModeChanged: (mode) {
                          setState(() {
                            _mapDisplayMode = mode;
                          });
                        },
                      ),
                    ),
                  ),

                // 悬浮返回按钮
                Positioned(
                  top: 16,
                  left: 16,
                  child: FloatingBackButton(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
