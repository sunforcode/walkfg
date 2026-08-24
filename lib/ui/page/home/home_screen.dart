import 'package:flutter/cupertino.dart';

import '../../../model/map/marker_point_model.dart';
import '../../../model/map/track_point_model.dart';
import '../../../model/route/route_model.dart';
import '../../../model/weather/weather_model.dart';
import '../../../service/kml_cache_service.dart';
import '../../../service/route/current_route_selection_service.dart';
import '../../../service/route_service.dart';
import '../../../service/weather/weather_manager.dart';
import '../../routes/app_navigator.dart';
import '../common/immersive_components.dart';
import '../common/immersive_page_scaffold.dart';
import 'widgets/empty_home.dart';
import 'widgets/error_home.dart';
import 'widgets/loading_home.dart';
import 'widgets/route_home.dart';

typedef HomeDataLoader = Future<HomeData?> Function({RouteModel? routeHint});

/// Walk v1 home.
///
/// P1 空状态 / P2 有行程，由 _homeFuture 数据驱动。
/// 顶部右侧小汉堡按钮 → P14 抽屉，日历入口已移至抽屉内。
class HomeScreen extends StatefulWidget {
  /// 打开抽屉回调（由 MainLayout 提供）
  final VoidCallback? onOpenDrawer;

  /// 可替换的数据加载入口；生产环境默认沿用现有加载流程。
  final HomeDataLoader? dataLoader;

  const HomeScreen({super.key, this.onOpenDrawer, this.dataLoader});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final WeatherManager _weatherManager = WeatherManager();
  final CurrentRouteSelectionService _selectionService =
      CurrentRouteSelectionService.instance;

  Future<HomeData?>? _homeFuture;
  RouteModel? _selectedRouteHint;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectionService.selectedRouteId.addListener(_onSelectedRouteChanged);
    _homeFuture = _loadHomeData();
  }

  @override
  void dispose() {
    _selectionService.selectedRouteId.removeListener(_onSelectedRouteChanged);
    _weatherManager.dispose();
    super.dispose();
  }

  void _onSelectedRouteChanged() {
    if (!mounted) return;
    setState(() {
      _homeFuture = _loadHomeData(routeHint: _selectedRouteHint);
    });
  }

  DateTime _upcomingHikingDate() {
    final now = DateTime.now();
    var days = DateTime.saturday - now.weekday;
    if (days < 0) days += 7;
    return DateTime(now.year, now.month, now.day).add(Duration(days: days));
  }

  Future<HomeData?> _loadHomeData({RouteModel? routeHint}) async {
    final injectedLoader = widget.dataLoader;
    if (injectedLoader != null) return injectedLoader(routeHint: routeHint);

    final routeId = await _selectionService.getSelectedRouteId();
    if (routeId == null || routeId.isEmpty) return null;

    RouteModel route;
    try {
      route = await RouteService.getRouteDetail(routeId);
    } catch (e) {
      if (routeHint == null || routeHint.id != routeId) rethrow;
      route = routeHint;
    }

    final trackPoints = await _loadTrackPoints(route);
    final forecasts = await _loadForecasts(route, trackPoints);

    return HomeData(
      route: route,
      forecasts: forecasts,
      hikingDate: _upcomingHikingDate(),
    );
  }

  Future<List<TrackPointVO>> _loadTrackPoints(RouteModel route) async {
    if (route.trackPoints.isNotEmpty) return route.trackPoints;
    final mapPoints = route.defaultMap?.trackPoints;
    if (mapPoints != null && mapPoints.isNotEmpty) return mapPoints;
    final kmlUrl = route.kmlUrl;
    if (kmlUrl != null && kmlUrl.isNotEmpty) {
      try {
        final mapData = await KmlCacheService.instance
            .getMapData(kmlUrl, routeId: route.id);
        return mapData.trackPoints;
      } catch (_) {}
    }
    return const [];
  }

  Future<List<WeatherModel>> _loadForecasts(
    RouteModel route,
    List<TrackPointVO> trackPoints,
  ) async {
    MarkerPointModel? point;
    if (trackPoints.isNotEmpty) {
      final s = trackPoints.first;
      point = MarkerPointModel(
        id: 'start-${route.id}',
        latitude: s.latitude,
        longitude: s.longitude,
        elevation: s.elevation,
        name: route.name,
        markerType: MarkerPointType.infoPoint,
      );
    } else if (route.markerPoints?.isNotEmpty ?? false) {
      point = route.markerPoints!.first;
    } else if (route.poiPoints.isNotEmpty) {
      final p = route.poiPoints.first;
      point = MarkerPointModel(
        id: 'poi-${p.id}',
        latitude: p.latitude,
        longitude: p.longitude,
        elevation: p.elevation ?? 0,
        name: p.name,
        markerType: MarkerPointType.infoPoint,
      );
    }
    if (point == null) return const [];
    try {
      return _weatherManager.getMarkerPointForecast(point, days: 15);
    } catch (_) {
      return const [];
    }
  }

  void _reload({RouteModel? routeHint}) {
    setState(() {
      _selectedRouteHint = routeHint ?? _selectedRouteHint;
      _homeFuture = _loadHomeData(routeHint: _selectedRouteHint);
    });
  }

  Future<void> _openRoutePicker() async {
    final selected = await AppNavigator.pushRouteDiscovery<RouteModel>(context);
    if (!mounted || selected == null) return;
    _reload(routeHint: selected);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ImmersivePageScaffold(
      body: FutureBuilder<HomeData?>(
        future: _homeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingHome();
          }
          if (snapshot.hasError) {
            return ErrorHome(onRetry: _reload, onChange: _openRoutePicker);
          }
          final data = snapshot.data;
          if (data == null) {
            return EmptyHome(onFindRoute: _openRoutePicker);
          }
          return RouteHome(data: data, onChangeRoute: _openRoutePicker);
        },
      ),
      trailingAction: GlassIconAction(
        semanticLabel: '打开菜单',
        icon: CupertinoIcons.bars,
        onPressed: widget.onOpenDrawer,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class HomeData {
  final RouteModel route;
  final List<WeatherModel> forecasts;
  final DateTime hikingDate;

  const HomeData({
    required this.route,
    required this.forecasts,
    required this.hikingDate,
  });

  WeatherModel? weatherFor(DateTime date) {
    for (final f in forecasts) {
      final d = f.forecastDate;
      if (d == null) continue;
      if (d.year == date.year && d.month == date.month && d.day == date.day) {
        return f;
      }
    }
    return null;
  }
}
