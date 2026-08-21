import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/map/marker_point_model.dart';
import 'package:walk/model/route/segment_model.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/core/unified_map_core.dart';
import 'package:walk/ui/map/layers/track_layer.dart';
import 'package:walk/ui/map/layers/marker_layer.dart';
import 'package:walk/ui/map/map_widget_models.dart';
import 'package:walk/ui/map/mapbox/mapbox_map_widget.dart';
import 'package:walk/ui/map/widgets/day_selector_widget.dart';
import 'package:walk/ui/map/widgets/elevation_chart_overlay.dart';
import 'package:walk/ui/map/widgets/map_controls_overlay.dart';
import 'package:walk/ui/map/widgets/route_info_card.dart';
export 'package:walk/ui/map/core/map_enum.dart';
export 'package:walk/ui/map/map_widget_models.dart';

// ─────────────────────────────────────────────
// UnifiedMapWidget：对外统一地图组件
// 通过 mapMode 参数切换 2D（flutter_map）或 3D（Mapbox）渲染
// ─────────────────────────────────────────────

/// 统一地图组件
///
/// 通过 [mapMode] 参数选择渲染引擎：
/// - [MapMode.map2d]：基于 flutter_map 的 2D 地图（默认）
/// - [MapMode.map3d]：基于 Mapbox 的 3D 地形地图
class UnifiedMapWidget extends StatelessWidget {
  /// 地图渲染模式
  final MapMode mapMode;

  final List<TrackPointVO> trackPoints;
  final List<MarkerPointModel> markers;
  final MapWidgetConfig config;
  final MapWidgetEvents events;
  final int? days;
  final int? selectedDay;
  final MapDisplayMode? displayMode;
  final LatLng? currentLocation;
  final String? routeName;
  final double? routeDistance;
  final double? routeElevationGain;
  final String? routeDifficulty;

  /// 分段数据（来自 API 或 KML 解析）
  final List<SegmentModel> segments;

  /// 当前选中的分段 ID
  final String? selectedSegmentId;

  /// 2D 模式下地图控制器就绪回调
  final void Function(MapController controller)? onControllerReady;

  /// 额外底部 padding（用于抽屉展开时将轨迹聚焦推向屏幕上方）
  final double bottomPaddingExtra;

  const UnifiedMapWidget({
    super.key,
    this.mapMode = MapMode.map2d,
    this.trackPoints = const [],
    this.markers = const [],
    this.config = const MapWidgetConfig(),
    this.events = const MapWidgetEvents(),
    this.days,
    this.selectedDay,
    this.displayMode,
    this.currentLocation,
    this.routeName,
    this.routeDistance,
    this.routeElevationGain,
    this.routeDifficulty,
    this.segments = const <SegmentModel>[],
    this.selectedSegmentId,
    this.onControllerReady,
    this.bottomPaddingExtra = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    switch (mapMode) {
      case MapMode.map3d:
        return MapboxMapWidget(
          trackPoints: trackPoints,
          markers: markers,
          segments: segments,
          selectedSegmentId: selectedSegmentId,
          height: config.height,
        );
      case MapMode.map2d:
        return _Map2DWidget(
          trackPoints: trackPoints,
          markers: markers,
          config: config,
          events: events,
          days: days,
          selectedDay: selectedDay,
          displayMode: displayMode,
          currentLocation: currentLocation,
          routeName: routeName,
          routeDistance: routeDistance,
          routeElevationGain: routeElevationGain,
          routeDifficulty: routeDifficulty,
          segments: segments,
          selectedSegmentId: selectedSegmentId,
          onControllerReady: onControllerReady,
          bottomPaddingExtra: bottomPaddingExtra,
        );
    }
  }
}

// ─────────────────────────────────────────────
// _Map2DWidget：内部 2D 地图实现（原 MapWidget）
// ─────────────────────────────────────────────

class _Map2DWidget extends StatefulWidget {
  final List<TrackPointVO> trackPoints;
  final List<MarkerPointModel> markers;
  final MapWidgetConfig config;
  final MapWidgetEvents events;
  final int? days;
  final int? selectedDay;
  final MapDisplayMode? displayMode;
  final LatLng? currentLocation;
  final String? routeName;
  final double? routeDistance;
  final double? routeElevationGain;
  final String? routeDifficulty;

  /// 分段数据（来自KML解析或API）
  final List<SegmentModel> segments;

  /// 当前选中的分段ID
  final String? selectedSegmentId;

  /// 地图控制器就绪回调，可用于外部缩放等操作
  final void Function(MapController controller)? onControllerReady;

  /// 额外底部 padding（用于抽屉展开时将轨迹聚焦推向屏幕上方）
  final double bottomPaddingExtra;

  const _Map2DWidget({
    this.trackPoints = const [],
    this.markers = const [],
    this.config = const MapWidgetConfig(),
    this.events = const MapWidgetEvents(),
    this.days,
    this.selectedDay,
    this.displayMode,
    this.currentLocation,
    this.routeName,
    this.routeDistance,
    this.routeElevationGain,
    this.routeDifficulty,
    this.segments = const <SegmentModel>[],
    this.selectedSegmentId,
    this.onControllerReady,
    this.bottomPaddingExtra = 0.0,
  });

  @override
  State<_Map2DWidget> createState() => _Map2DWidgetState();
}

class _Map2DWidgetState extends State<_Map2DWidget> {
  int? _selectedDay;
  bool _showElevationChart = false;
  MapType _currentMapType = MapType.standard;
  bool _isFollowingLocation = false;
  MapController? _mapController;
  bool _hasTrackPoints = false;
  final List<Color> _dailyColors = [
    const Color(0xFF4CAF50),
    const Color(0xFFFF9800),
    const Color(0xFF9C27B0),
    const Color(0xFFE91E63),
    const Color(0xFF00BCD4),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
    _currentMapType = widget.config.mapType;
    _hasTrackPoints = widget.trackPoints.isNotEmpty;

    // 若初始化时已有轨迹点，在下一帧延迟调用 fitBounds（确保 UnifiedMapCore._initializeMap 已执行）
    // 修复场景：KML 缓存命中时，_hasTrackPoints=true，但 bottomPaddingExtra 未生效于初始 fitBounds
    if (_hasTrackPoints) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 再延迟一帧，确保 UnifiedMapCore 的 postFrameCallback 已执行
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _fitBoundsToTrackPoints();
          }
        });
      });
    }
  }

  @override
  void didUpdateWidget(_Map2DWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDay != oldWidget.selectedDay) {
      setState(() {
        _selectedDay = widget.selectedDay;
      });
    }

    // 检测 selectedSegmentId 变化，定位到选中的分段
    if (widget.selectedSegmentId != null &&
        widget.selectedSegmentId != oldWidget.selectedSegmentId) {
      _fitBoundsToSelectedSegment();
    }

    // 检测 trackPoints 从空变有的情况，定位地图
    if (!_hasTrackPoints && widget.trackPoints.isNotEmpty) {
      _hasTrackPoints = true;
      _fitBoundsToTrackPoints();
    }

    // 检测抽屉高度变化，重新定位轨迹
    if ((widget.bottomPaddingExtra - oldWidget.bottomPaddingExtra).abs() > 1.0 &&
        widget.trackPoints.isNotEmpty) {
      _fitBoundsToTrackPoints();
    }
  }

  /// 定位地图到选中的分段
  void _fitBoundsToSelectedSegment() {
    if (widget.selectedSegmentId == null ||
        widget.trackPoints.isEmpty ||
        _mapController == null) {
      return;
    }

    // 找到对应的分段
    final segment = widget.segments.firstWhere(
      (s) => s.id == widget.selectedSegmentId,
      orElse: () => SegmentModel(id: '', name: ''),
    );

    if (segment.id.isEmpty) return;

    // 获取分段的轨迹点范围
    final start = segment.trackStartIndex ?? 0;
    final end = segment.trackEndIndex ?? widget.trackPoints.length - 1;

    if (start < 0 || end >= widget.trackPoints.length || start >= end) {
      return;
    }

    // 获取分段的轨迹点
    final segmentPoints = widget.trackPoints.sublist(start, end + 1);

    // 计算边界
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final point in segmentPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    const padding = 0.01;
    final bounds = LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );

    _mapController!.fitBounds(
      bounds,
      options: FitBoundsOptions(
        padding: widget.config.padding,
        maxZoom: 16.0,
      ),
    );
  }

  /// 定位地图到轨迹点边界
  void _fitBoundsToTrackPoints() {
    final bounds = _calculateBounds();
    if (bounds != null && _mapController != null) {
      // 根据 bottomPaddingExtra 动态调整边距
      // 抽屉展开时：底部边距增大，使轨迹聚焦点发圆屏幕上 1/4 处
      final effectivePadding = EdgeInsets.only(
        left: widget.config.padding.left,
        top: widget.config.padding.top,
        right: widget.config.padding.right,
        bottom: widget.config.padding.bottom + widget.bottomPaddingExtra,
      );
      _mapController!.fitBounds(
        bounds,
        options: FitBoundsOptions(
          padding: effectivePadding,
          maxZoom: 18.0,
        ),
      );
    }
  }

  List<List<TrackPointVO>> _splitTrackByDays() {
    if (widget.trackPoints.isEmpty || (widget.days ?? 1) <= 1) {
      return [widget.trackPoints];
    }

    final pointsPerDay = (widget.trackPoints.length / widget.days!).ceil();
    final result = <List<TrackPointVO>>[];

    for (int i = 0; i < widget.days!; i++) {
      final start = i * pointsPerDay;
      final end = (i == widget.days! - 1)
          ? widget.trackPoints.length
          : (i + 1) * pointsPerDay;

      if (start < widget.trackPoints.length) {
        result.add(widget.trackPoints
            .sublist(start, end.clamp(0, widget.trackPoints.length)));
      }
    }

    return result;
  }

  List<TrackPointVO> _getCurrentTrackPoints() {
    if (widget.days == null || widget.days! <= 1) {
      return widget.trackPoints;
    }

    final dailyTracks = _splitTrackByDays();
    if (_selectedDay == null) {
      return widget.trackPoints;
    } else if (_selectedDay! >= 0 && _selectedDay! < dailyTracks.length) {
      return dailyTracks[_selectedDay!];
    }
    return widget.trackPoints;
  }

  Color _getTrackColor() {
    if (widget.days == null || widget.days! <= 1 || _selectedDay == null) {
      return widget.config.trackColor;
    }
    return _dailyColors[_selectedDay! % _dailyColors.length];
  }

  LatLngBounds? _calculateBounds() {
    final currentTrackPoints = _getCurrentTrackPoints();
    final visibleMarkers = widget.markers.where((m) => m.isVisible).toList();

    final allPoints = <TrackPointVO>[];
    allPoints.addAll(currentTrackPoints);
    allPoints.addAll(visibleMarkers);

    if (allPoints.isEmpty) return null;

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final point in allPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    const padding = 0.01;
    return LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );
  }

  List<Widget> _buildMapLayers() {
    final currentTrackPoints = _getCurrentTrackPoints();
    final visibleMarkers = widget.markers.where((m) => m.isVisible).toList();
    final layers = <Widget>[];

    if (widget.config.hasFeature(MapFeature.track) &&
        currentTrackPoints.isNotEmpty) {
      layers.add(
        TrackLayer(
          trackPoints: currentTrackPoints,
          segments: widget.segments,
          selectedSegmentId: widget.selectedSegmentId,
          config: TrackRenderConfig(
            renderMode: widget.config.trackRenderMode,
            strokeWidth: widget.config.trackWidth,
            defaultColor: _getTrackColor(),
            showDirectionArrows: widget.config.showDirectionArrows,
            arrowSpacing: widget.config.arrowSpacing,
          ),
        ),
      );
    }

    final allMarkers = <MarkerData>[];

    if (widget.config.hasFeature(MapFeature.startEndMarkers) &&
        currentTrackPoints.isNotEmpty) {
      allMarkers.addAll(MarkerLayerBuilder.buildStartEndMarkers(currentTrackPoints));
    }

    if (widget.config.hasFeature(MapFeature.poiMarkers)) {
      for (final marker in visibleMarkers) {
        allMarkers.add(MarkerData(
          point: marker,
          type: _mapMarkerType(marker.markerType),
          displayText: marker.displayTitle,
        ));
      }
    }

    if (widget.config.hasFeature(MapFeature.kilometerMarkers)) {
      allMarkers.addAll(MarkerLayerBuilder.buildKilometerMarkers(currentTrackPoints));
    }

    if (widget.config.hasFeature(MapFeature.currentLocation) &&
        widget.currentLocation != null) {
      final currentLocMarker = MarkerLayerBuilder.buildCurrentLocationMarker(
        widget.currentLocation,
      );
      if (currentLocMarker != null) {
        allMarkers.add(currentLocMarker);
      }
    }

    if (allMarkers.isNotEmpty) {
      layers.add(
        CustomMarkerLayer(
          markers: allMarkers,
          onMarkerTap: (marker) {
            widget.events.onMarkerTap?.call(marker.point);
          },
        ),
      );
    }

    return layers;
  }

  MarkerType _mapMarkerType(MarkerPointType type) {
    switch (type) {
      case MarkerPointType.poi:
        return MarkerType.pointOfInterest;
      case MarkerPointType.landmark:
        return MarkerType.pointOfInterest;
      case MarkerPointType.viewpoint:
        return MarkerType.photoPoint;
      case MarkerPointType.restPoint:
        return MarkerType.restPoint;
      case MarkerPointType.dangerPoint:
        return MarkerType.dangerPoint;
      case MarkerPointType.infoPoint:
        return MarkerType.pointOfInterest;
      case MarkerPointType.other:
        return MarkerType.custom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTrackPoints = _getCurrentTrackPoints();
    final bounds = _calculateBounds();

    return SizedBox(
      height: widget.config.height,
      child: Stack(
        children: [
          UnifiedMapCore(
            config: UnifiedMapConfig(
              mapType: _currentMapType,
              mapProvider: widget.config.mapProvider,
              enableInteraction: widget.config.enableInteraction,
              initialCenter: widget.config.initialCenter,
              initialBounds: bounds,
              initialZoom: widget.config.initialZoom,
              // 初始化时也加入 bottomPaddingExtra，确保首次 fitBounds 就有正确的偏移
              padding: EdgeInsets.only(
                left: widget.config.padding.left,
                top: widget.config.padding.top,
                right: widget.config.padding.right,
                bottom: widget.config.padding.bottom + widget.bottomPaddingExtra,
              ),
            ),
            events: UnifiedMapEvents(
              onTap: widget.events.onMapTap,
              onLongPress: widget.events.onMapLongPress,
              onMove: widget.events.onMapMove,
              onReady: widget.events.onMapReady,
            ),
            layers: _buildMapLayers(),
            onControllerCreated: (controller) {
              _mapController = controller;
              widget.onControllerReady?.call(controller);
            },
          ),
          if (widget.config.hasFeature(MapFeature.mapControls))
            ...MapControlsOverlay.buildMapControls(
              hasCurrentLocation: widget.config.hasFeature(MapFeature.currentLocation),
              isFollowingLocation: _isFollowingLocation,
              showElevationChart: _showElevationChart,
              onToggleFollowLocation: () {
                setState(() => _isFollowingLocation = !_isFollowingLocation);
              },
              onShowMapTypeSelector: () {
                showMapTypeSelectorSheet(
                  context: context,
                  onMapTypeSelected: (mapType) {
                    setState(() => _currentMapType = mapType);
                  },
                );
              },
              onLayersPressed: () {},
              onScopePressed: () {},
            ),
          if (widget.config.hasFeature(MapFeature.routeInfo) &&
              widget.routeName != null)
            RouteInfoCard(
              routeName: widget.routeName,
              routeDistance: widget.routeDistance,
              routeElevationGain: widget.routeElevationGain,
              routeDifficulty: widget.routeDifficulty,
            ),
          if (widget.days != null && widget.days! > 1)
            DaySelectorWidget(
              selectedDay: _selectedDay,
              dayCount: _splitTrackByDays().length,
              showElevationChart: _showElevationChart,
              onDayChanged: (day) {
                setState(() => _selectedDay = day);
                widget.events.onDayChanged?.call(day);
              },
            ),
          if (widget.config.hasFeature(MapFeature.elevationChart) &&
              currentTrackPoints.isNotEmpty)
            ...ElevationChartOverlay.buildElevationChart(
              trackPoints: currentTrackPoints,
              showElevationChart: _showElevationChart,
              onToggle: () {
                setState(() => _showElevationChart = !_showElevationChart);
              },
              onClose: () {
                setState(() => _showElevationChart = false);
              },
            ),
        ],
      ),
    );
  }
}
