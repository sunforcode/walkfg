import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/model/map/map_bounds.dart';
import 'package:walk/model/model/map/track_point_model.dart';
import 'package:walk/model/model/route/route_model.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/elevation_chart_painter.dart';
import 'package:walk/ui/map/widgets/map_toolbars.dart';
import 'package:walk/ui/map/widgets/map_selectors.dart';
import 'package:walk/ui/map/widgets/map_markers.dart';
import 'package:walk/ui/map/widgets/elevation_chart_widget.dart';
import 'package:walk/ui/map/widgets/offline_map_dialog.dart';

/// 统一地图组件
class UnifiedMapWidget extends StatefulWidget {
  /// 路线
  final RouteModel? route;

  /// 轨迹点
  final List<TrackPointVO>? trackPoints;

  /// 路标点
  final List<TrackPointVO>? waypoints;

  /// 地图高度
  final double height;

  /// 是否显示当前位置
  final bool showCurrentLocation;

  /// 是否显示地图类型工具栏
  final bool showMapTypeToolbar;

  /// 是否显示增强工具栏
  final bool showEnhancedToolbar;

  /// 地图类型
  final MapType mapType;

  /// 地图提供商
  final MapProviderType mapProvider;

  /// 轨迹渲染模式
  final TrackRenderMode trackRenderMode;

  /// 是否显示公里标记
  final bool showKilometerMarkers;

  /// 是否显示兴趣点
  final bool showPointsOfInterest;

  /// 是否显示海拔图表
  final bool showElevationChart;

  /// 是否支持离线地图
  final bool supportOfflineMap;

  /// 地图类型变更回调
  final ValueChanged<MapType>? onMapTypeChanged;

  /// 地图提供商变更回调
  final ValueChanged<MapProviderType>? onMapProviderChanged;

  /// 轨迹渲染模式变更回调
  final ValueChanged<TrackRenderMode>? onTrackRenderModeChanged;

  /// 公里标记显示状态变更回调
  final ValueChanged<bool>? onKilometerMarkersVisibilityChanged;

  /// 兴趣点显示状态变更回调
  final ValueChanged<bool>? onPointsOfInterestVisibilityChanged;

  /// 海拔图表显示状态变更回调
  final ValueChanged<bool>? onElevationChartVisibilityChanged;

  /// 离线地图下载回调
  final Function(
          MapBoundsVO bounds, MapType mapType, MapProviderType mapProvider)?
      onDownloadOfflineMap;

  /// 构造函数
  const UnifiedMapWidget({
    super.key,
    this.route,
    this.trackPoints,
    this.waypoints,
    required this.height,
    this.showCurrentLocation = true,
    this.showMapTypeToolbar = true,
    this.showEnhancedToolbar = true,
    this.mapType = MapType.standard,
    this.mapProvider = MapProviderType.apple,
    this.trackRenderMode = TrackRenderMode.normal,
    this.showKilometerMarkers = false,
    this.showPointsOfInterest = true,
    this.showElevationChart = false,
    this.supportOfflineMap = false,
    this.onMapTypeChanged,
    this.onMapProviderChanged,
    this.onTrackRenderModeChanged,
    this.onKilometerMarkersVisibilityChanged,
    this.onPointsOfInterestVisibilityChanged,
    this.onElevationChartVisibilityChanged,
    this.onDownloadOfflineMap,
  });

  @override
  State<UnifiedMapWidget> createState() => _UnifiedMapWidgetState();
}

class _UnifiedMapWidgetState extends State<UnifiedMapWidget> {
  /// 地图控制器
  final MapController _mapController = MapController();

  /// 当前位置
  LatLng? _currentLocation;

  /// 是否正在加载离线地图
  bool _isLoadingOfflineMap = false;

  /// 是否显示地图类型选择器
  bool _showMapTypeSelector = false;

  /// 是否显示地图提供商选择器
  bool _showMapProviderSelector = false;

  /// 是否显示轨迹渲染模式选择器
  bool _showTrackRenderModeSelector = false;

  /// 是否显示工具栏
  bool _showToolbar = true;

  /// 是否显示离线地图下载对话框
  bool _showOfflineMapDownloadDialog = false;

  /// 离线地图下载进度
  double _offlineMapDownloadProgress = 0.0;

  /// 轨迹点
  List<TrackPointVO> _trackPoints = [];

  /// 公里标记点
  List<TrackPointVO> _kilometerMarkers = [];

  /// 兴趣点
  List<TrackPointVO> _pointsOfInterest = [];

  @override
  void initState() {
    super.initState();
    _initTrackPoints();
    _calculateKilometerMarkers();
    _extractPointsOfInterest();
    _getCurrentLocation();
  }

  @override
  void didUpdateWidget(UnifiedMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trackPoints != oldWidget.trackPoints ||
        widget.route != oldWidget.route) {
      _initTrackPoints();
      _calculateKilometerMarkers();
      _extractPointsOfInterest();
    }
  }

  /// 初始化轨迹点
  void _initTrackPoints() {
    if (widget.trackPoints != null && widget.trackPoints!.isNotEmpty) {
      _trackPoints = widget.trackPoints!;
      print('UnifiedMapWidget - 使用传入的轨迹点数据，数量: ${_trackPoints.length}');
    } else {
      _trackPoints = [];
      print('UnifiedMapWidget - 没有可用的轨迹点数据');
    }
  }

  /// 计算公里标记点
  void _calculateKilometerMarkers() {
    if (_trackPoints.isEmpty) return;

    _kilometerMarkers = [];
    double accumulatedDistance = 0.0;
    int kilometerCount = 0;

    for (int i = 1; i < _trackPoints.length; i++) {
      final prevPoint = _trackPoints[i - 1];
      final currentPoint = _trackPoints[i];

      final distance = _calculateDistance(
        prevPoint.latitude,
        prevPoint.longitude,
        currentPoint.latitude,
        currentPoint.longitude,
      );

      accumulatedDistance += distance;

      // 每公里添加一个标记
      if (accumulatedDistance >= 1000.0 * (kilometerCount + 1)) {
        kilometerCount++;

        // 计算插值点
        final ratio =
            (1000.0 * kilometerCount - (accumulatedDistance - distance)) /
                distance;
        final lat = prevPoint.latitude +
            (currentPoint.latitude - prevPoint.latitude) * ratio;
        final lng = prevPoint.longitude +
            (currentPoint.longitude - prevPoint.longitude) * ratio;
        final ele = prevPoint.elevation +
            (currentPoint.elevation - prevPoint.elevation) * ratio;

        _kilometerMarkers.add(TrackPointVO(
          latitude: lat,
          longitude: lng,
          elevation: ele,
          name: '$kilometerCount km',
          type: 'kilometer',
        ));
      }
    }
  }

  /// 提取兴趣点
  void _extractPointsOfInterest() {
    if (_trackPoints.isEmpty) return;

    _pointsOfInterest = _trackPoints
        .where((point) =>
            point.name != null || point.type == '最高点' || point.type == '最低点')
        .toList();
  }

  /// 获取当前位置
  Future<void> _getCurrentLocation() async {
    if (!widget.showCurrentLocation) return;

    try {
      // 这里应该使用定位插件获取当前位置
      // 例如：final position = await Geolocator.getCurrentPosition();
      // _currentLocation = LatLng(position.latitude, position.longitude);

      // 模拟当前位置（北京）
      _currentLocation = LatLng(39.9042, 116.4074);
      setState(() {});
    } catch (e) {
      print('获取当前位置失败: $e');
    }
  }

  /// 计算两点之间的距离（米）
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // 地球半径（米）
    final phi1 = lat1 * (pi / 180);
    final phi2 = lat2 * (pi / 180);
    final deltaPhi = (lat2 - lat1) * (pi / 180);
    final deltaLambda = (lon2 - lon1) * (pi / 180);

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  /// 获取地图瓦片URL
  String _getTileUrl(MapType mapType, MapProviderType mapProvider) {
    switch (mapProvider) {
      case MapProviderType.apple:
        // 使用 OpenStreetMap 作为备用
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

      case MapProviderType.amap:
        switch (mapType) {
          case MapType.amapSatellite:
            return 'https://webst01.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}';
          case MapType.amapNight:
            return 'https://webst01.is.autonavi.com/appmaptile?style=3&x={x}&y={y}&z={z}';
          case MapType.amapStandard:
          default:
            return 'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}';
        }

      case MapProviderType.tianditu:
        // 需要添加天地图密钥
        const tiandituKey = 'your_tianditu_key';
        switch (mapType) {
          case MapType.tiandituSatellite:
            return 'https://t0.tianditu.gov.cn/img_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=img&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$tiandituKey';
          case MapType.tiandituTerrain:
            return 'https://t0.tianditu.gov.cn/ter_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=ter&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$tiandituKey';
          case MapType.tiandituVector:
          default:
            return 'https://t0.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$tiandituKey';
        }

      case MapProviderType.osm:
        switch (mapType) {
          case MapType.osmHumanitarian:
            return 'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';
          case MapType.osmStandard:
          default:
            return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
        }

      case MapProviderType.google:
        switch (mapType) {
          case MapType.googleSatellite:
            return 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';
          case MapType.googleTerrain:
            return 'https://mt1.google.com/vt/lyrs=p&x={x}&y={y}&z={z}';
          case MapType.googleStandard:
          default:
            return 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
        }
    }
  }

  /// 获取轨迹颜色
  Color _getTrackColor(TrackPointVO point, TrackPointVO? nextPoint) {
    switch (widget.trackRenderMode) {
      case TrackRenderMode.speed:
        // 根据速度渲染颜色
        if (nextPoint == null ||
            point.timestamp == null ||
            nextPoint.timestamp == null) {
          return AppColors.primary;
        }

        final distance = _calculateDistance(
          point.latitude,
          point.longitude,
          nextPoint.latitude,
          nextPoint.longitude,
        );

        final duration =
            nextPoint.timestamp!.difference(point.timestamp!).inSeconds;
        if (duration <= 0) return AppColors.primary;

        final speed = distance / duration; // 米/秒

        // 速度范围：0-5 m/s
        if (speed < 1.0) return Colors.blue;
        if (speed < 2.0) return Colors.green;
        if (speed < 3.0) return Colors.yellow;
        if (speed < 4.0) return Colors.orange;
        return Colors.red;

      case TrackRenderMode.elevation:
        // 根据海拔渲染颜色
        // 假设海拔范围：0-5000米
        final normalizedElevation = point.elevation / 5000.0;

        if (normalizedElevation < 0.2) return Colors.blue;
        if (normalizedElevation < 0.4) return Colors.green;
        if (normalizedElevation < 0.6) return Colors.yellow;
        if (normalizedElevation < 0.8) return Colors.orange;
        return Colors.red;

      case TrackRenderMode.gradient:
        // 根据坡度渲染颜色
        if (nextPoint == null) return AppColors.primary;

        final distance = _calculateDistance(
          point.latitude,
          point.longitude,
          nextPoint.latitude,
          nextPoint.longitude,
        );

        if (distance <= 0) return AppColors.primary;

        final elevationDiff = nextPoint.elevation - point.elevation;
        final gradient = elevationDiff / distance * 100; // 坡度百分比

        // 坡度范围：-30% 到 30%
        if (gradient < -15) return Colors.red;
        if (gradient < -5) return Colors.orange;
        if (gradient < 5) return Colors.green;
        if (gradient < 15) return Colors.orange;
        return Colors.red;
      case TrackRenderMode.normal:
        return AppColors.primary;
    }
  }

  /// 构建核心地图组件
  Widget _buildMapCore() {
    if (_trackPoints.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text('没有轨迹数据'),
        ),
      );
    }

    // 计算地图边界
    final bounds = _calculateMapBounds();

    return SizedBox(
      height: widget.height,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          bounds: LatLngBounds(
            LatLng(bounds.south, bounds.west),
            LatLng(bounds.north, bounds.east),
          ),
          interactiveFlags: InteractiveFlag.all,
        ),
        children: [
          // 地图瓦片层
          TileLayer(
            urlTemplate: _getTileUrl(widget.mapType, widget.mapProvider),
            userAgentPackageName: 'com.example.walk',
            tileProvider: CancellableNetworkTileProvider(),
            fallbackUrl:
                'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png', // 备用URL
            errorImage:
                const AssetImage('assets/images/map_error_tile.png'), // 错误图片
            tileBuilder: (context, tileWidget, tile) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey[200], // 瓦片背景色
                ),
                position: DecorationPosition.background,
                child: tileWidget,
              );
            },
            maxZoom: 18,
            minZoom: 3,
            backgroundColor: Colors.grey[300],
            keepBuffer: 5,
            evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
          ),

          // 轨迹线层
          PolylineLayer(
            polylines: _buildTrackPolylines(),
          ),

          // 公里标记层
          if (widget.showKilometerMarkers)
            MarkerLayer(
              markers: KilometerMarkers.build(_kilometerMarkers),
            ),
          // 兴趣点层
          if (widget.showPointsOfInterest)
            MarkerLayer(
              markers: PointsOfInterestMarkers.build(
                _pointsOfInterest,
                onTap: _showPointDetails,
              ),
            ),
          // 当前位置层
          if (widget.showCurrentLocation && _currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 计算地图边界
  MapBoundsVO _calculateMapBounds() {
    if (_trackPoints.isEmpty) {
      // 默认边界（中国）
      return const MapBoundsVO(
        north: 53.55,
        south: 3.86,
        east: 135.05,
        west: 73.66,
      );
    }

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final point in _trackPoints) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    // 添加边距
    const padding = 0.01; // 约1公里
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    return MapBoundsVO(
      north: maxLat,
      south: minLat,
      east: maxLng,
      west: minLng,
    );
  }

  /// 构建轨迹折线
  List<Polyline> _buildTrackPolylines() {
    if (_trackPoints.length < 2) return [];

    final List<Polyline> polylines = [];
    final List<List<LatLng>> segments = [];
    List<LatLng> currentSegment = [];

    // 根据渲染模式分段
    for (int i = 0; i < _trackPoints.length; i++) {
      final point = _trackPoints[i];
      final nextPoint =
          i < _trackPoints.length - 1 ? _trackPoints[i + 1] : null;

      currentSegment.add(LatLng(point.latitude, point.longitude));

      // 如果是最后一个点或者颜色变化，则结束当前段
      if (nextPoint == null ||
          (i > 0 &&
              _getTrackColor(point, nextPoint) !=
                  _getTrackColor(_trackPoints[i - 1], point))) {
        if (currentSegment.length > 1) {
          segments.add(List.from(currentSegment));
        }
        currentSegment = [LatLng(point.latitude, point.longitude)];
      }
    }

    // 添加最后一段
    if (currentSegment.length > 1) {
      segments.add(currentSegment);
    }

    // 创建折线
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      if (segment.length < 2) continue;

      final startPoint = _trackPoints[i > 0 ? i - 1 : 0];
      final nextPoint =
          i < _trackPoints.length - 1 ? _trackPoints[i + 1] : null;

      polylines.add(Polyline(
        points: segment,
        strokeWidth: 4.0,
        color: _getTrackColor(startPoint, nextPoint),
      ));
    }
    return polylines;
  }

  /// 构建公里标记
  List<Marker> _buildKilometerMarkers() {
    return _kilometerMarkers.map((point) {
      return Marker(
        point: LatLng(point.latitude, point.longitude),
        width: 30,
        height: 30,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              point.name!.split(' ')[0],
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  /// 构建兴趣点标记
  List<Marker> _buildPointsOfInterestMarkers() {
    return _pointsOfInterest.map((point) {
      IconData icon;
      Color color;

      if (point.type == '最高点') {
        icon = Icons.arrow_upward;
        color = Colors.red;
      } else if (point.type == '最低点') {
        icon = Icons.arrow_downward;
        color = Colors.blue;
      } else {
        icon = Icons.place;
        color = Colors.green;
      }
      return Marker(
        point: LatLng(point.latitude, point.longitude),
        width: 30,
        height: 30,
        child: GestureDetector(
          onTap: () => _showPointDetails(point),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      );
    }).toList();
  }

  /// 显示点详情
  void _showPointDetails(TrackPointVO point) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(point.name ?? '兴趣点'),
        content: Column(
          children: [
            if (point.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(point.description!),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('海拔: ${point.elevation.toStringAsFixed(1)}米'),
            ),
            if (point.type != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('类型: ${point.type}'),
              ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('关闭'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// 构建地图类型工具栏
  Widget _buildMapTypeToolbar() {
    return Positioned(
      top: 10,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 地图类型按钮
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.map,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            onPressed: () {
              setState(() {
                _showMapTypeSelector = !_showMapTypeSelector;
                _showMapProviderSelector = false;
                _showTrackRenderModeSelector = false;
              });
            },
          ),

          // 地图类型选择器
          if (_showMapTypeSelector)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '地图类型',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _buildMapTypeOption(MapType.standard, '标准'),
                  _buildMapTypeOption(MapType.satellite, '卫星'),
                  _buildMapTypeOption(MapType.hybrid, '混合'),
                  _buildMapTypeOption(MapType.terrain, '地形'),
                  const Divider(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.globe,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '更多地图源',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        _showMapTypeSelector = false;
                        _showMapProviderSelector = true;
                      });
                    },
                  ),
                ],
              ),
            ),

          // 地图提供商选择器
          if (_showMapProviderSelector)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '地图提供商',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _buildMapProviderOption(MapProviderType.apple, '苹果地图'),
                  _buildMapProviderOption(MapProviderType.amap, '高德地图'),
                  _buildMapProviderOption(MapProviderType.tianditu, '天地图'),
                  _buildMapProviderOption(MapProviderType.osm, 'OpenStreetMap'),
                  _buildMapProviderOption(MapProviderType.google, '谷歌地图'),
                  const Divider(),
                  if (widget.mapProvider == MapProviderType.amap)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '高德地图样式',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildMapTypeOption(MapType.amapStandard, '标准'),
                        _buildMapTypeOption(MapType.amapSatellite, '卫星'),
                        _buildMapTypeOption(MapType.amapNight, '夜间'),
                      ],
                    ),
                  if (widget.mapProvider == MapProviderType.tianditu)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '天地图样式',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildMapTypeOption(MapType.tiandituVector, '矢量'),
                        _buildMapTypeOption(MapType.tiandituSatellite, '卫星'),
                        _buildMapTypeOption(MapType.tiandituTerrain, '地形'),
                      ],
                    ),
                  if (widget.mapProvider == MapProviderType.osm)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'OpenStreetMap样式',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildMapTypeOption(MapType.osmStandard, '标准'),
                        _buildMapTypeOption(MapType.osmHumanitarian, '人道主义'),
                      ],
                    ),
                  if (widget.mapProvider == MapProviderType.google)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '谷歌地图样式',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildMapTypeOption(MapType.googleStandard, '标准'),
                        _buildMapTypeOption(MapType.googleSatellite, '卫星'),
                        _buildMapTypeOption(MapType.googleTerrain, '地形'),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建地图类型选项
  Widget _buildMapTypeOption(MapType mapType, String label) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.mapType == mapType
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            color: widget.mapType == mapType
                ? AppColors.primary
                : CupertinoColors.systemGrey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: widget.mapType == mapType
                  ? AppColors.primary
                  : CupertinoColors.label,
              fontSize: 14,
            ),
          ),
        ],
      ),
      onPressed: () {
        if (widget.onMapTypeChanged != null) {
          widget.onMapTypeChanged!(mapType);
        }
        setState(() {
          _showMapTypeSelector = false;
          _showMapProviderSelector = false;
        });
      },
    );
  }

  /// 构建地图提供商选项
  Widget _buildMapProviderOption(MapProviderType provider, String label) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.mapProvider == provider
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            color: widget.mapProvider == provider
                ? AppColors.primary
                : CupertinoColors.systemGrey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: widget.mapProvider == provider
                  ? AppColors.primary
                  : CupertinoColors.label,
              fontSize: 14,
            ),
          ),
        ],
      ),
      onPressed: () {
        if (widget.onMapProviderChanged != null) {
          widget.onMapProviderChanged!(provider);
        }
      },
    );
  }

  /// 构建增强工具栏
  Widget _buildEnhancedToolbar() {
    return Positioned(
      bottom: 10,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 轨迹渲染模式
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.color_filter,
                    color: _showTrackRenderModeSelector
                        ? AppColors.primary
                        : CupertinoColors.systemGrey,
                    size: 24,
                  ),
                  const Text(
                    '渲染模式',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                setState(() {
                  _showTrackRenderModeSelector = !_showTrackRenderModeSelector;
                  _showMapTypeSelector = false;
                  _showMapProviderSelector = false;
                });
              },
            ),

            // 公里标记
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.location,
                    color: widget.showKilometerMarkers
                        ? AppColors.primary
                        : CupertinoColors.systemGrey,
                    size: 24,
                  ),
                  const Text(
                    '公里标记',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                if (widget.onKilometerMarkersVisibilityChanged != null) {
                  widget.onKilometerMarkersVisibilityChanged!(
                      !widget.showKilometerMarkers);
                }
              },
            ),

            // 兴趣点
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.map_pin,
                    color: widget.showPointsOfInterest
                        ? AppColors.primary
                        : CupertinoColors.systemGrey,
                    size: 24,
                  ),
                  const Text(
                    '兴趣点',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                if (widget.onPointsOfInterestVisibilityChanged != null) {
                  widget.onPointsOfInterestVisibilityChanged!(
                      !widget.showPointsOfInterest);
                }
              },
            ),

            // 海拔图表
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.chart_bar,
                    color: widget.showElevationChart
                        ? AppColors.primary
                        : CupertinoColors.systemGrey,
                    size: 24,
                  ),
                  const Text(
                    '海拔图表',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                if (widget.onElevationChartVisibilityChanged != null) {
                  widget.onElevationChartVisibilityChanged!(
                      !widget.showElevationChart);
                }
              },
            ),

            // 离线地图
            if (widget.supportOfflineMap)
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.cloud_download,
                      color: _isLoadingOfflineMap
                          ? AppColors.primary
                          : CupertinoColors.systemGrey,
                      size: 24,
                    ),
                    const Text(
                      '离线地图',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  setState(() {
                    _showOfflineMapDownloadDialog = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  /// 构建轨迹渲染模式选择器
  Widget _buildTrackRenderModeSelector() {
    return Positioned(
      bottom: 80,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                '轨迹渲染模式',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            _buildTrackRenderModeOption(TrackRenderMode.normal, '普通'),
            _buildTrackRenderModeOption(TrackRenderMode.speed, '速度'),
            _buildTrackRenderModeOption(TrackRenderMode.elevation, '海拔'),
            _buildTrackRenderModeOption(TrackRenderMode.gradient, '坡度'),
          ],
        ),
      ),
    );
  }

  /// 构建轨迹渲染模式选项
  Widget _buildTrackRenderModeOption(TrackRenderMode mode, String label) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.trackRenderMode == mode
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            color: widget.trackRenderMode == mode
                ? AppColors.primary
                : CupertinoColors.systemGrey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: widget.trackRenderMode == mode
                  ? AppColors.primary
                  : CupertinoColors.label,
              fontSize: 14,
            ),
          ),
        ],
      ),
      onPressed: () {
        if (widget.onTrackRenderModeChanged != null) {
          widget.onTrackRenderModeChanged!(mode);
        }
        setState(() {
          _showTrackRenderModeSelector = false;
        });
      },
    );
  }

  /// 构建离线地图下载对话框
  Widget _buildOfflineMapDownloadDialog() {
    return CupertinoAlertDialog(
      title: const Text('下载离线地图'),
      content: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('下载当前显示区域的离线地图，以便在无网络环境下使用。'),
          ),
          if (_isLoadingOfflineMap)
            Column(
              children: [
                const SizedBox(height: 16),
                const CupertinoActivityIndicator(),
                const SizedBox(height: 8),
                Text(
                    '下载中... ${(_offlineMapDownloadProgress * 100).toStringAsFixed(0)}%'),
              ],
            ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('取消'),
          onPressed: () {
            setState(() {
              _showOfflineMapDownloadDialog = false;
            });
          },
        ),
        if (!_isLoadingOfflineMap)
          CupertinoDialogAction(
            child: const Text('下载'),
            onPressed: () {
              _downloadOfflineMap();
            },
          ),
      ],
    );
  }

  /// 下载离线地图
  void _downloadOfflineMap() {
    if (widget.onDownloadOfflineMap == null) return;

    setState(() {
      _isLoadingOfflineMap = true;
      _offlineMapDownloadProgress = 0.0;
    });

    // 获取当前地图边界
    final bounds = _calculateMapBounds();

    // 模拟下载进度
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _offlineMapDownloadProgress += 0.1;
        if (_offlineMapDownloadProgress >= 1.0) {
          _isLoadingOfflineMap = false;
          _showOfflineMapDownloadDialog = false;
          timer.cancel();

          // 显示下载完成提示
          _showDownloadCompleteDialog();
        }
      });
    });

    // 调用下载回调
    widget.onDownloadOfflineMap!(bounds, widget.mapType, widget.mapProvider);
  }

  /// 显示下载完成对话框
  void _showDownloadCompleteDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('下载完成'),
        content: const Text('离线地图已下载完成，现在可以在无网络环境下使用。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// 构建海拔图表
  Widget _buildElevationChart() {
    if (_trackPoints.isEmpty) return const SizedBox.shrink();

    // 提取海拔数据
    final elevations = _trackPoints.map((p) => p.elevation).toList();
    final maxElevation = elevations.reduce((a, b) => a > b ? a : b);
    final minElevation = elevations.reduce((a, b) => a < b ? a : b);

    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '海拔图表',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                '最高: ${maxElevation.toStringAsFixed(0)}m 最低: ${minElevation.toStringAsFixed(0)}m',
                style: const TextStyle(
                  fontSize: 10,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: ElevationChartPainter(
                elevations: elevations,
                maxElevation: maxElevation,
                minElevation: minElevation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 核心地图组件
        _buildMapCore(),

        // 地图类型工具栏
        if (widget.showMapTypeToolbar)
          MapTypeToolbar(
            mapType: widget.mapType,
            mapProvider: widget.mapProvider,
            showMapTypeSelector: _showMapTypeSelector,
            showMapProviderSelector: _showMapProviderSelector,
            onMapTypeChanged: widget.onMapTypeChanged,
            onMapProviderChanged: widget.onMapProviderChanged,
            onMapTypeSelectorToggle: () {
              setState(() {
                _showMapTypeSelector = !_showMapTypeSelector;
                _showMapProviderSelector = false;
                _showTrackRenderModeSelector = false;
              });
            },
            onMapProviderSelectorToggle: () {
              setState(() {
                _showMapTypeSelector = false;
                _showMapProviderSelector = !_showMapProviderSelector;
                _showTrackRenderModeSelector = false;
              });
            },
          ),

        // 增强工具栏
        if (widget.showEnhancedToolbar && _showToolbar)
          EnhancedToolbar(
            showTrackRenderModeSelector: _showTrackRenderModeSelector,
            showKilometerMarkers: widget.showKilometerMarkers,
            showPointsOfInterest: widget.showPointsOfInterest,
            showElevationChart: widget.showElevationChart,
            supportOfflineMap: widget.supportOfflineMap,
            isLoadingOfflineMap: _isLoadingOfflineMap,
            onTrackRenderModeSelectorToggle: () {
              setState(() {
                _showTrackRenderModeSelector = !_showTrackRenderModeSelector;
                _showMapTypeSelector = false;
                _showMapProviderSelector = false;
              });
            },
            onKilometerMarkersToggle:
                widget.onKilometerMarkersVisibilityChanged,
            onPointsOfInterestToggle:
                widget.onPointsOfInterestVisibilityChanged,
            onElevationChartToggle: widget.onElevationChartVisibilityChanged,
            onOfflineMapDownload: () {
              setState(() {
                _showOfflineMapDownloadDialog = true;
              });
            },
          ),

        // 轨迹渲染模式选择器
        if (_showTrackRenderModeSelector)
          TrackRenderModeSelector(
            trackRenderMode: widget.trackRenderMode,
            onTrackRenderModeChanged: (mode) {
              if (widget.onTrackRenderModeChanged != null) {
                widget.onTrackRenderModeChanged!(mode);
              }
              setState(() {
                _showTrackRenderModeSelector = false;
              });
            },
          ),

        // 海拔图表
        if (widget.showElevationChart && _trackPoints.isNotEmpty)
          Positioned(
            bottom: widget.showEnhancedToolbar ? 80 : 10,
            left: 10,
            right: 10,
            child: ElevationChartWidget(
              trackPoints: _trackPoints,
            ),
          ),

        // 离线地图下载对话框
        if (_showOfflineMapDownloadDialog)
          OfflineMapDownloadDialog(
            isLoading: _isLoadingOfflineMap,
            progress: _offlineMapDownloadProgress,
            onCancel: () {
              setState(() {
                _showOfflineMapDownloadDialog = false;
              });
            },
            onDownload: _downloadOfflineMap,
          ),
      ],
    );
  }
}
