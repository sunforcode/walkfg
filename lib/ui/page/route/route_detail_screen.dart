import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:walk/model/route/track_model.dart';
import 'package:walk/model/route/water_source_model.dart';
import 'package:walk/model/route/supply_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/ui/page/common/error_view.dart';
import 'package:walk/ui/page/common/loading_view.dart';
import 'package:walk/ui/page/trip/trip_detail_screen.dart';
import '../../../model/map/track_point_model.dart';
import '../../../service/service_manager.dart';
import '../../../service/map_service.dart';
import '../../../ui/map/utils/kml_parser.dart';
import 'widgets/route_map_section.dart';
import 'widgets/route_detail_info_widget.dart';
import 'widgets/floating_map_widget.dart';
import 'widgets/route_action_buttons.dart';
import 'widgets/route_utils.dart';
import 'widgets/elevation_profile_widget.dart';
import 'widgets/daily_itinerary_list_widget.dart';
import 'widgets/seasonal_equipment_widget.dart';
import 'widgets/map_resources_widget.dart';
import 'widgets/related_routes_widget.dart';
import 'widgets/related_trips_widget.dart';
import 'widgets/route_overview_widget.dart';
import 'widgets/route_gallery_widget.dart';
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
  late ScrollController _scrollController;
  bool _isFavorite = false;
  bool _showElevationProfile = false;
  bool _isMapFloating = false;

  /// KML轨迹点
  List<TrackPointVO> _kmlTrackPoints = [];

  /// KML路标点
  List<TrackPointVO> _kmlWaypoints = [];

  /// 可用轨迹列表
  List<TrackModel> _availableTracks = [];

  /// 当前选中的轨迹索引
  int _selectedTrackIndex = 0;

  /// 水源点列表
  List<WaterSourceModel> _waterSources = [];

  /// 补给点列表
  List<SupplyPointModel> _supplyPoints = [];

  /// 相关路线列表
  List<RouteModel> _relatedRoutes = [];

  /// 相关行程列表
  List<TripModel> _relatedTrips = [];

  @override
  void initState() {
    super.initState();
    _mapService = ServiceLocator.instance.getMapService();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadRouteDetail();
    _loadKmlData();
    _loadRouteData();
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

  /// 加载路线相关数据
  Future<void> _loadRouteData() async {
    final routeDataService = ServiceLocator.instance.getRouteDataService();
    try {
      final results = await Future.wait([
        routeDataService.getAvailableTracks(widget.routeId),
        routeDataService.getWaterSources(widget.routeId),
        routeDataService.getSupplyPoints(widget.routeId),
        routeDataService.getRelatedRoutes(widget.routeId),
        routeDataService.getRelatedTrips(widget.routeId),
      ]);
      setState(() {
        _availableTracks = results[0] as List<TrackModel>;
        _waterSources = results[1] as List<WaterSourceModel>;
        _supplyPoints = results[2] as List<SupplyPointModel>;
        _relatedRoutes = results[3] as List<RouteModel>;
        _relatedTrips = results[4] as List<TripModel>;
      });
    } catch (e) {
      print('加载路线数据失败: $e');
    }
  }

  /// 从KML文件加载轨迹数据
  Future<void> _loadKmlData() async {
    try {
      final mapData = await KmlParser.parseFromAsset('assets/maps/wutai.kml');
      setState(() {
        _kmlTrackPoints = mapData.trackPoints;
        _kmlWaypoints = mapData.waypoints;
      });
    } catch (e) {
      final routeDataService = ServiceLocator.instance.getRouteDataService();
      final testData = await routeDataService.getTestTrackData(widget.routeId);
      setState(() {
        _kmlTrackPoints = (testData['trackPoints'] as List)
            .map((data) => TrackPointVO(
                  latitude: data['latitude'],
                  longitude: data['longitude'],
                  elevation: data['elevation']?.toDouble(),
                  name: data['name'],
                ))
            .toList();

        _kmlWaypoints = (testData['waypoints'] as List)
            .map((data) => TrackPointVO(
                  latitude: data['latitude'],
                  longitude: data['longitude'],
                  elevation: data['elevation']?.toDouble(),
                  name: data['name'],
                  type: data['type'],
                ))
            .toList();
      });
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
          routeId: route.regionId,
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
        RouteUtils.showToast(context, '已取消收藏');
      });
    } else {
      apiService.addFavorite(widget.routeId).then((_) {
        setState(() {
          _isFavorite = true;
        });
        RouteUtils.showToast(context, '已添加到收藏');

        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const MyFavoriteRoutesScreen(),
          ),
        );
      });
    }
  }

  /// 处理轨迹选择
  void _handleTrackSelection(int index) {
    setState(() {
      _selectedTrackIndex = index;
    });
    print('选择轨迹: ${_availableTracks[index].name}');
  }

  /// 处理海拔剖面图点击
  void _handleElevationProfileTap(double percentage) {
    print('点击海拔剖面图位置: ${(percentage * 100).toStringAsFixed(1)}%');
  }

  /// 切换海拔剖面图显示
  void _toggleElevationProfile() {
    setState(() {
      _showElevationProfile = !_showElevationProfile;
    });
  }

  /// 处理日程点击
  void _handleDayTap(int dayIndex) {
    print('点击第${dayIndex + 1}天');
  }

  /// 处理地图点击
  void _handleMapTap() {
    RouteUtils.showFeatureInDevelopmentDialog(context);
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
    print('点击行程: ${trip.name}');
    RouteUtils.showFeatureInDevelopmentDialog(context);
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
                  message: snapshot.error.toString(),
                  onRetry: () {
                    setState(() {
                      _loadRouteDetail();
                    });
                  },
                );
              }

              final route = snapshot.data!;
              final currentTrack = _availableTracks.isNotEmpty
                  ? _availableTracks[_selectedTrackIndex]
                  : null;

              return Stack(
                children: [
                  // 主要内容
                  CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // 地图区域
                      SliverToBoxAdapter(
                        child: RouteMapSection(
                          route: route,
                          trackPoints: _kmlTrackPoints,
                          waypoints: _kmlWaypoints,
                          availableTracks: _availableTracks,
                          selectedTrackIndex: _selectedTrackIndex,
                          showElevationProfile: _showElevationProfile,
                          onMapTap: _handleMapTap,
                          onToggleElevationProfile: _toggleElevationProfile,
                          onTrackSelection: _handleTrackSelection,
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
                            trackPoints: _kmlTrackPoints,
                          ),
                        ),

                      // 海拔剖面图
                      if (_showElevationProfile && currentTrack != null)
                        SliverToBoxAdapter(
                          child: ElevationProfileWidget(
                            trackPoints: _kmlTrackPoints,
                            totalDistance: currentTrack.distance,
                            elevationGain:
                                currentTrack.elevationGain.toDouble(),
                            onTap: _handleElevationProfileTap,
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
                            currentSeason: RouteUtils.getCurrentSeason(),
                            difficulty: currentTrack.getDifficultyName(),
                          ),
                        ),

                      // 地图水源补给点详解
                      SliverToBoxAdapter(
                        child: MapResourcesWidget(
                          waterSources: _waterSources,
                          supplyPoints: _supplyPoints,
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
                              RouteUtils.showFeatureInDevelopmentDialog(
                                  context),
                        ),
                      ),
                    ],
                  ),

                  // 悬浮地图
                  if (_isMapFloating)
                    FloatingMapWidget(
                      route: route,
                      trackPoints: _kmlTrackPoints,
                      waypoints: _kmlWaypoints,
                      availableTracks: _availableTracks,
                      selectedTrackIndex: _selectedTrackIndex,
                      showElevationProfile: _showElevationProfile,
                      onMapTap: _handleFloatingMapTap,
                      onClose: _closeFloatingMap,
                      onToggleElevationProfile: _toggleElevationProfile,
                      onTrackSelection: _handleTrackSelection,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
