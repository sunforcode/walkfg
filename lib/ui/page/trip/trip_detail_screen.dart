import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/service/route_service.dart';
import 'package:walk/ui/map/map_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_map_header_widget.dart';
import 'package:walk/ui/page/trip/widget/display/trip_overview_display_widget.dart';
import 'package:walk/ui/page/trip/widget/display/trip_itinerary_display_widget.dart';
import 'package:walk/ui/page/trip/widget/display/trip_participants_display_widget.dart';
import 'package:walk/ui/page/trip/widget/display/trip_equipment_display_widget.dart';
import 'package:walk/ui/page/trip/widget/display/trip_budget_display_widget.dart';
import 'package:walk/ui/page/trip/widget/display/trip_food_water_display_widget.dart';
import 'package:walk/ui/page/trip/widget/display/trip_transportation_display_widget.dart';
import 'package:walk/ui/page/trip/widget/display/trip_weather_safety_display_widget.dart';
import 'package:walk/ui/page/trip/trip_edit_screen.dart';
import 'package:walk/ui/page/common/error_widget.dart';
import 'package:walk/ui/page/common/loading_indicator.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/utils/toast_utils.dart';

/// 行程详情展示页面
class TripDetailScreen extends StatefulWidget {
  /// 行程ID（可选）
  final String? tripId;

  /// 路线ID（可选）
  final String? routeId;

  /// 行程模型（可选）
  final TripModel? tripModel;

  /// 是否为只读模式（查看他人行程）
  final bool isReadOnly;

  /// 构造函数
  const TripDetailScreen({
    super.key,
    this.tripId,
    this.routeId,
    this.tripModel,
    this.isReadOnly = false,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  /// 当前展示的TripModel
  TripModel? _trip;

  /// 关联的路线数据
  List<RouteModel> _relatedRoutes = [];

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  /// 当前用户ID（模拟）
  // TODO: 替换为真实用户ID from AuthService
  final String _currentUserId = 'current_user';

  /// 页面加载状态
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 初始化数据，根据入口参数加载TripModel或RouteModel
  Future<void> _initData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (widget.tripModel != null) {
        // 直接用传入的TripModel
        _trip = widget.tripModel;
        await _loadRelatedRoutes(_trip!);
      } else if (widget.routeId != null) {
        // 通过routeId加载RouteModel并构造临时TripModel
        try {
          final route = await RouteService.getRouteById(widget.routeId!);
          _relatedRoutes = [route];
          _trip = _buildTripModelFromRoute(route);
        } catch (e) {
          // 如果路线不存在，创建一个空白行程
          debugPrint('路线不存在，创建空白行程: $e');
          _trip = _buildNewTripModel();
        }
      } else {
        // 没有指定任何参数，创建一个全新的空白行程
        _trip = _buildNewTripModel();
      }
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// 加载关联的路线
  Future<void> _loadRelatedRoutes(TripModel trip) async {
    if (trip.routeIds.isEmpty) return;
    final routes = <RouteModel>[];
    for (final routeId in trip.routeIds) {
      try {
        final route = await RouteService.getRouteById(routeId);
        routes.add(route);
      } catch (e) {
        // 路线缺失时忽略
      }
    }
    _relatedRoutes = routes;
  }

  /// 根据RouteModel构造临时TripModel
  TripModel _buildTripModelFromRoute(RouteModel route) {
    return TripModel(
      id: 'temp_${route.id}',
      name: route.name,
      description: route.description,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      status: TripStatus.planning,
      routeIds: [route.id],
      primaryRouteId: route.id,
      participants: [],
      participantCount: 1,
      organizerId: _currentUserId,
      equipmentListId: null,
      mealPlanId: null,
      mealPlan: null,
      waterPlanId: null,
      waterPlan: null,
      itinerary: [],
      coverUrl: route.coverUrl,
      imageUrls: route.imageUrls,
      budget: null,
      actualCost: null,
      notes: null,
      privacySetting: 'private',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 创建一个全新的空白行程
  TripModel _buildNewTripModel() {
    final now = DateTime.now();
    return TripModel(
      id: 'new_trip_${now.millisecondsSinceEpoch}',
      name: '新行程',
      description: '开始规划你的新行程',
      startDate: now,
      endDate: now.add(const Duration(days: 1)),
      status: TripStatus.planning,
      routeIds: [],
      primaryRouteId: null,
      participants: [],
      participantCount: 1,
      organizerId: _currentUserId,
      equipmentListId: null,
      mealPlanId: null,
      mealPlan: null,
      waterPlanId: null,
      waterPlan: null,
      itinerary: [],
      coverUrl: null,
      imageUrls: [],
      budget: null,
      actualCost: null,
      notes: null,
      privacySetting: 'private',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 跳转到编辑页面
  Future<void> _navigateToEdit() async {
    if (_trip == null) return;
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (context) => TripEditScreen(tripId: _trip!.id),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      _initData();
    }
  }

  /// 收藏行程
  void _favoriteTrip() {
    ToastUtils.showToast(context, '已收藏到我的行程');
  }

  /// 显示提示信息

  /// 判断是否为自己的行程
  bool _isOwnTrip(TripModel trip) {
    return trip.organizerId == _currentUserId && !widget.isReadOnly;
  }

  /// 判断是否可以编辑
  bool _canEdit(TripModel trip) {
    return _isOwnTrip(trip) &&
        (trip.status == TripStatus.planning ||
            trip.status == TripStatus.confirmed);
  }

  /// 获取页面标题
  String _getPageTitle(TripModel trip) {
    if (widget.isReadOnly || !_isOwnTrip(trip)) {
      return '行程详情';
    }
    switch (trip.status) {
      case TripStatus.planning:
        return '行程规划';
      case TripStatus.confirmed:
        return '行程详情';
      case TripStatus.inProgress:
        return '进行中的行程';
      case TripStatus.completed:
        return '行程记录';
      case TripStatus.cancelled:
        return '已取消的行程';
    }
  }

  /// 构建导航栏尾部按钮
  Widget? _buildTrailingButton(TripModel trip) {
    if (widget.isReadOnly || !_isOwnTrip(trip)) {
      // 他人的行程，显示收藏按钮
      return CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Text(
          '收藏',
          style: TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
        onPressed: _favoriteTrip,
      );
    }
    if (_canEdit(trip)) {
      // 可编辑状态，显示编辑按钮
      return CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Text(
          '编辑',
          style: TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
        onPressed: _navigateToEdit,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingIndicator();
    }
    if (_error != null) {
      return ErrorMessageWidget(
        errorMessage: _error!,
        onRetry: _initData,
      );
    }
    final trip = _trip;
    if (trip == null) {
      return const Center(child: Text('未找到行程信息'));
    }
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.interactiveAccent,
        middle: Text(
          _getPageTitle(trip),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: _buildTrailingButton(trip),
      ),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 地图头部
          SliverToBoxAdapter(
            child: _relatedRoutes.isNotEmpty &&
                    _relatedRoutes.first.defaultMap != null
                ? UnifiedMapWidget(
                    trackPoints: _relatedRoutes.first.defaultMap!.trackPoints,
                    markers: _relatedRoutes.first.markerPoints ?? [],
                    days: 3,
                    config: MapWidgetConfig(
                      height: 400,
                      enabledFeatures: {
                        MapFeature.track,
                        MapFeature.startEndMarkers,
                        MapFeature.poiMarkers,
                        MapFeature.elevationChart,
                        MapFeature.mapControls,
                        MapFeature.routeInfo,
                      },
                    ),
                    routeName: _relatedRoutes.first.name,
                    routeDistance: _relatedRoutes.first.distance,
                    routeElevationGain: _relatedRoutes.first.elevationGain,
                    routeDifficulty: _relatedRoutes.first.difficulty.getName(),
                  )
                : TripMapHeaderWidget(
                    route:
                        _relatedRoutes.isNotEmpty ? _relatedRoutes.first : null,
                    height: 220,
                  ),
          ),
          // 行程概览
          SliverToBoxAdapter(
            child: TripOverviewDisplayWidget(
              trip: trip,
              relatedRoutes: _relatedRoutes,
              isReadOnly: widget.isReadOnly || !_isOwnTrip(trip),
            ),
          ),
          // 每日行程
          SliverToBoxAdapter(
            child: TripItineraryDisplayWidget(
              trip: trip,
            ),
          ),
          // 参与者信息
          SliverToBoxAdapter(
            child: TripParticipantsDisplayWidget(
              trip: trip,
            ),
          ),
          // 装备清单
          SliverToBoxAdapter(
            child: TripEquipmentDisplayWidget(
              trip: trip,
            ),
          ),
          // 预算信息
          SliverToBoxAdapter(
            child: TripBudgetDisplayWidget(
              trip: trip,
            ),
          ),
          // 食物饮水
          SliverToBoxAdapter(
            child: TripFoodWaterDisplayWidget(
              trip: trip,
            ),
          ),
          // 交通住宿
          SliverToBoxAdapter(
            child: TripTransportationDisplayWidget(
              trip: trip,
            ),
          ),
          // 天气安全
          SliverToBoxAdapter(
            child: TripWeatherSafetyDisplayWidget(
              trip: trip,
            ),
          ),
          // 底部间距
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }
}
