import 'package:flutter/cupertino.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/segment_model.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/service/kml_cache_service.dart';
import 'package:walk/service/route_service.dart';
import 'package:walk/ui/map/map_widget.dart';
import 'package:walk/ui/map/utils/kml_business_parser.dart';
import 'package:walk/ui/map/utils/map_data_helper.dart';
import 'package:walk/ui/page/common/error_view.dart';
import 'package:walk/ui/page/common/loading_view.dart';
import 'package:walk/ui/page/route/detail/widgets/route_overview_widget.dart';
import 'package:walk/ui/page/route/detail/map_info_coordinator.dart';
import 'package:walk/ui/page/trip/trip_detail_screen.dart';
import 'package:walk/utils/toast_utils.dart';

import 'widgets/route_action_buttons.dart';
import 'widgets/route_info_sheet_widget.dart';
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
import 'widgets/route_stats_card_widget.dart';
import '../my_favorite_routes_screen.dart';

/// 路线详情页面（地图全屏 + 悬浮导航栏 + 底部可上滑抽屉）
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
  late MapInfoCoordinator _mapCoordinator;
  bool _isFavorite = false;

  /// 轨迹点数据
  List<TrackPointVO> _kmlTrackPoints = [];

  /// 完整的地图数据模型（包含segments）
  MapDataModel? _mapData;

  /// 当前选中的分段ID
  String? _selectedSegmentId;

  /// 相关路线列表
  List<RouteModel> _relatedRoutes = [];

  /// 相关行程列表
  List<TripModel> _relatedTrips = [];

  /// 抽屉是否完全隐藏（用于显示底部触发区）
  bool _sheetHidden = false;

  /// 抽屉当前占屏幕高度比例（用于动态调整地图聚焦偏移）
  double _sheetSize = 0.40;

  /// 抽屉 GlobalKey，用于调用 openToHalf()
  final GlobalKey<RouteInfoSheetWidgetState> _sheetKey = GlobalKey();

  /// 触发区上划起始 Y 坐标
  double? _triggerDragStartY;

  @override
  void initState() {
    super.initState();
    _mapCoordinator = MapInfoCoordinator();
    _loadRouteDetail();
    _loadRouteData();
  }

  @override
  void dispose() {
    _mapCoordinator.dispose();
    super.dispose();
  }

  /// 加载路线详情
  void _loadRouteDetail() {
    // 如果传入了route参数，从route中获取routeId请求详情
    if (widget.route != null) {
      _routeFuture = RouteService.getRouteDetail(widget.route!.id);
    } else {
      // 如果没有传入route参数，使用传入的routeId请求详情
      _routeFuture = RouteService.getRouteDetail(widget.routeId);
    }
    _checkIfFavorite();
    
    // 等待路线详情加载完成后再加载KML数据
    _routeFuture.then((route) {
      _loadKmlData(route);
    }).catchError((e) {
      debugPrint('路线详情加载错误: $e');
    });
  }

  /// 从路线数据或KML文件加载轨迹数据
  ///
  /// 注意：API 返回的 trackpoints 暂时不处理，优先使用 KML 数据
  void _loadKmlData(RouteModel route) async {
    try {
      // 1. 使用 KmlCacheService 从缓存或网络获取 KML（自动处理缓存逻辑）
      // 注意：API 返回的 trackpoints 暂时不处理
      if (route.kmlUrl != null && route.kmlUrl!.isNotEmpty) {
        try {
          // 获取 MapDataModel（内部会缓存 KML 原始字符串）
          final mapData = await KmlCacheService.instance.getMapData(
            route.kmlUrl!,
            routeId: route.id,
          );

          setState(() {
            _mapData = mapData;
            _kmlTrackPoints = mapData.trackPoints;
          });
          return;
        } catch (e) {
          // 网络下载失败，继续回退到本地 assets
          debugPrint('KML缓存/网络加载失败: $e，将尝试回退到本地 assets');
        }
      }

      // 2. 最后使用本地 assets KML 文件作为最终回退
      final mapData =
          await KmlBusinessParser.parseFromPath('assets/maps/wutai.kml');

      setState(() {
        _mapData = mapData;
        _kmlTrackPoints = mapData.trackPoints;
      });
    } catch (e) {
      debugPrint('轨迹点加载失败: $e');
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
      debugPrint('加载路线数据失败: $e');
    }
  }

  /// 检查路线是否已收藏
  void _checkIfFavorite() {
    RouteService.checkIfFavorite(widget.routeId).then((isFavorite) {
      if (!mounted) return;
      setState(() {
        _isFavorite = isFavorite;
      });
    }).catchError((e) {
      debugPrint('检查收藏状态失败: $e');
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
  Future<void> _handleFavorite() async {
    final wasFavorite = _isFavorite;
    setState(() {
      _isFavorite = !wasFavorite;
    });

    try {
      if (wasFavorite) {
        await RouteService.removeFavorite(widget.routeId);
        if (!mounted) return;
        ToastUtils.showToast(context, '已取消收藏');
      } else {
        await RouteService.addFavorite(widget.routeId);
        if (!mounted) return;
        ToastUtils.showToast(context, '已添加到收藏');

        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const MyFavoriteRoutesScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFavorite = wasFavorite;
      });
      ToastUtils.showToast(context, '操作失败，请稍后重试');
    }
  }

  /// 处理日程点击
  void _handleDayTap(int dayIndex) {}

  /// 处理分段点击
  void _handleSegmentTap(SegmentModel segment) {
    setState(() {
      // 如果点击的是当前选中的分段，则取消选中
      if (_selectedSegmentId == segment.id) {
        _selectedSegmentId = null;
      } else {
        _selectedSegmentId = segment.id;
      }
    });
  }

  /// 获取分段数据（使用统一优先级逻辑，仅使用远端数据）
  List<SegmentModel> _getSegments(RouteModel route) {
    return MapDataHelper.resolveSegments(route, _mapData);
  }

  /// 构建分段Widget
  Widget _buildSegmentsWidget(RouteModel route) {
    final segments = _getSegments(route);

    if (segments.isEmpty) return const SizedBox.shrink();

    // 为每个分段添加选中状态
    final segmentsWithSelection = segments.map((s) {
      return s.copyWith(isSelected: _selectedSegmentId == s.id);
    }).toList();

    return GestureDetector(
      onTap: () {
        // 点击空白区域取消选中
        if (_selectedSegmentId != null) {
          setState(() {
            _selectedSegmentId = null;
          });
        }
      },
      child: RouteSegmentsWidget(
        segments: segmentsWithSelection,
        onSegmentTap: _handleSegmentTap,
      ),
    );
  }

  /// 处理图片点击
  void _handleImageTap(int index) {}

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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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

          return SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 第 1 层：地图全屏底层
                Positioned.fill(
                  child: _buildMapSection(route),
                ),

                // 第 2 层：底部可拖拽抽屉（覆盖全屏，但内容在底部）
                Positioned.fill(
                  child: RouteInfoSheetWidget(
                    key: _sheetKey,
                    route: route,
                    onHiddenChanged: (hidden) {
                      if (hidden != _sheetHidden) {
                        setState(() => _sheetHidden = hidden);
                      }
                    },
                    onSizeChanged: (size) {
                      if ((size - _sheetSize).abs() > 0.01) {
                        setState(() => _sheetSize = size);
                      }
                    },
                    sections: [
                      // Section 1: 路线统计卡片（撑满抽屉默认 40% 高度）
                      Builder(builder: (context) {
                        final screenH = MediaQuery.of(context).size.height;
                        // 抽屉默认高度 - SliverPadding top(4) - 卡片 margin bottom(12)
                        final cardH = screenH * 0.40 - 4 - 12;
                        return RouteStatsCardWidget(
                          route: route,
                          height: cardH,
                        );
                      }),
                      // Section 2: 路线概览
                      RouteOverviewWidget(route: route),
                      // Section 3: 每日行程
                      if (route.dailyPlans?.isNotEmpty ?? false)
                        DailyItineraryListWidget(
                          dailyPlans: route.dailyPlans ?? [],
                          onDayTap: _handleDayTap,
                        ),
                      // Section 4: 营地
                      if (route.campsites?.isNotEmpty ?? false)
                        CampsitesWidget(
                          campsites: route.campsites ?? [],
                        ),
                      // Section 5: 水源
                      if (route.waterSources?.isNotEmpty ?? false)
                        WaterSourcesWidget(
                          waterSources: route.waterSources ?? [],
                        ),
                      // Section 6: 补给点
                      if (route.supplyPoints?.isNotEmpty ?? false)
                        SupplyPointsWidget(
                          supplyPoints: route.supplyPoints ?? [],
                        ),
                      // Section 7: 路线分段
                      _buildSegmentsWidget(route),
                      // Section 8: 装备建议
                      if (currentTrack != null)
                        SeasonalEquipmentWidget(
                          currentSeason: '春季',
                          difficulty: route.difficulty.name,
                        ),
                      // Section 9: 搭车联系
                      if (route.hitchhikeContacts?.isNotEmpty ?? false)
                        HitchhikeContactsWidget(
                          contacts: route.hitchhikeContacts ?? [],
                        ),
                      // Section 10: 相关路线
                      if (_relatedRoutes.isNotEmpty)
                        RelatedRoutesWidget(
                          relatedRoutes: _relatedRoutes,
                          onRouteTap: _handleRelatedRouteTap,
                        ),
                      // Section 11: 相关行程
                      if (_relatedTrips.isNotEmpty)
                        RelatedTripsWidget(
                          routeId: route.id,
                          relatedTrips: _relatedTrips,
                          onTripTap: _handleRelatedTripTap,
                        ),
                      // Section 12: 图片库
                      if (route.imageUrls?.isNotEmpty ?? false)
                        RouteGalleryWidget(
                          imageUrls: route.imageUrls ?? [],
                          onImageTap: _handleImageTap,
                        ),
                      // Section 13: 操作按钮
                      RouteActionButtons(
                        route: route,
                        isFavorite: _isFavorite,
                        onPlanTrip: () => _startPlanning(route),
                        onToggleFavorite: _handleFavorite,
                        onMapAction: () =>
                            ToastUtils.showFeatureInDevelopmentDialog(context),
                      ),
                    ],
                  ),
                ),

                // 第 3 层：悬浮透明导航栏
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildNavigationBar(route),
                ),

                // 第 4 层：底部触发区（最顶层，抽屉隐藏时吃掉上划手势）
                if (_sheetHidden)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: _buildTriggerZone(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建导航栏（仅左侧返回按钮，悬浮透明）
  Widget _buildNavigationBar(RouteModel route) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 44,
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CupertinoColors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: CupertinoColors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建地图区域
  Widget _buildMapSection(RouteModel route) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: _build2DMap(route, constraints.maxHeight),
        );
      },
    );
  }

  /// 构建地图（统一使用 UnifiedMapWidget）
  Widget _build2DMap(RouteModel route, [double? height]) {
    final segments = _getSegments(route);
    // 根据抽屉占屏幕高度比例计算额外底部 padding
    // 抽屉展开时，底部复原空间大，轨迹聚焦将向屏幕上方偏移
    // 屏幕高度 * sheetSize 即为抽屉占据的像素高度
    final screenH = MediaQuery.of(context).size.height;
    final bottomExtra = screenH * _sheetSize * 0.75; // 0.75 系数用于缩小偏移幅度

    return UnifiedMapWidget(
      trackPoints: _kmlTrackPoints,
      markers: MapDataHelper.resolveMarkers(route),
      days: route.dailyPlans?.length,
      segments: segments,
      selectedSegmentId: _selectedSegmentId,
      config: MapWidgetConfig(
        height: height ?? double.infinity,
        enabledFeatures: {
          MapFeature.track,
          MapFeature.startEndMarkers,
          MapFeature.poiMarkers,
          MapFeature.elevationChart,
          MapFeature.mapControls,
          MapFeature.routeInfo,
        },
      ),
      routeName: route.name,
      routeDistance: route.distance,
      routeElevationGain: route.elevationGain,
      routeDifficulty: route.difficulty.getName(),
      bottomPaddingExtra: bottomExtra,
    );
  }

  /// 构建底部触发区（抽屉隐藏时显示，上划可重新打开）
  Widget _buildTriggerZone() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        _triggerDragStartY = details.globalPosition.dy;
      },
      onPanUpdate: (details) {
        if (_triggerDragStartY == null) return;
        final dy = details.globalPosition.dy - _triggerDragStartY!;
        if (dy < -10) {
          _triggerDragStartY = null;
          _sheetKey.currentState?.openToHalf();
        }
      },
      onPanEnd: (_) {
        _triggerDragStartY = null;
      },
      child: const ColoredBox(color: Color(0x00000000)),
    );
  }
}
