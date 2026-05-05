import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/map/marker_point_model.dart';
import 'package:walk/model/route/segment_model.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/core/unified_map_core.dart';
import 'package:walk/ui/map/layers/track_layer.dart';
import 'package:walk/ui/map/layers/marker_layer.dart';
import 'package:walk/ui/map/widgets/elevation_chart_widget.dart';
export 'package:walk/ui/map/core/map_enum.dart';

enum MapDisplayMode {
  compact,
  standard,
  immersive,
}

enum MapFeature {
  track,
  startEndMarkers,
  poiMarkers,
  kilometerMarkers,
  currentLocation,
  elevationChart,
  mapControls,
  routeInfo,
}

class MapWidgetConfig {
  final double height;
  final MapType mapType;
  final MapProviderType mapProvider;
  final Set<MapFeature> enabledFeatures;
  final TrackRenderMode trackRenderMode;
  final Color trackColor;
  final double trackWidth;
  final double initialZoom;
  final LatLng? initialCenter;
  final EdgeInsets padding;
  final bool enableInteraction;
  final bool showDirectionArrows;
  final double arrowSpacing;

  const MapWidgetConfig({
    this.height = 400.0,
    this.mapType = MapType.standard,
    this.mapProvider = MapProviderType.osm,
    this.enabledFeatures = const {
      MapFeature.track,
      MapFeature.startEndMarkers,
    },
    this.trackRenderMode = TrackRenderMode.normal,
    this.trackColor = const Color(0xFF2196F3),
    this.trackWidth = 3.0,
    this.initialZoom = 12.0,
    this.initialCenter,
    this.padding = const EdgeInsets.all(50),
    this.enableInteraction = true,
    this.showDirectionArrows = false,
    this.arrowSpacing = 1000.0,
  });

  MapWidgetConfig copyWith({
    double? height,
    MapType? mapType,
    MapProviderType? mapProvider,
    Set<MapFeature>? enabledFeatures,
    TrackRenderMode? trackRenderMode,
    Color? trackColor,
    double? trackWidth,
    double? initialZoom,
    LatLng? initialCenter,
    EdgeInsets? padding,
    bool? enableInteraction,
    bool? showDirectionArrows,
    double? arrowSpacing,
  }) {
    return MapWidgetConfig(
      height: height ?? this.height,
      mapType: mapType ?? this.mapType,
      mapProvider: mapProvider ?? this.mapProvider,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      trackRenderMode: trackRenderMode ?? this.trackRenderMode,
      trackColor: trackColor ?? this.trackColor,
      trackWidth: trackWidth ?? this.trackWidth,
      initialZoom: initialZoom ?? this.initialZoom,
      initialCenter: initialCenter ?? this.initialCenter,
      padding: padding ?? this.padding,
      enableInteraction: enableInteraction ?? this.enableInteraction,
      showDirectionArrows: showDirectionArrows ?? this.showDirectionArrows,
      arrowSpacing: arrowSpacing ?? this.arrowSpacing,
    );
  }

  bool hasFeature(MapFeature feature) {
    return enabledFeatures.contains(feature);
  }
}

class MapWidgetEvents {
  final void Function(LatLng position)? onMapTap;
  final void Function(LatLng position)? onMapLongPress;
  final void Function(LatLng center, double zoom)? onMapMove;
  final VoidCallback? onMapReady;
  final void Function(TrackPointVO point)? onMarkerTap;
  final void Function(int? day)? onDayChanged;
  final void Function(MapDisplayMode mode)? onDisplayModeChanged;

  const MapWidgetEvents({
    this.onMapTap,
    this.onMapLongPress,
    this.onMapMove,
    this.onMapReady,
    this.onMarkerTap,
    this.onDayChanged,
    this.onDisplayModeChanged,
  });
}

class MapWidgetPresets {
  static const MapWidgetConfig basicTrack = MapWidgetConfig(
    height: 300.0,
    enabledFeatures: {
      MapFeature.track,
      MapFeature.startEndMarkers,
    },
  );

  static const MapWidgetConfig detailedTrack = MapWidgetConfig(
    height: 400.0,
    enabledFeatures: {
      MapFeature.track,
      MapFeature.startEndMarkers,
      MapFeature.poiMarkers,
      MapFeature.kilometerMarkers,
      MapFeature.mapControls,
    },
    trackRenderMode: TrackRenderMode.elevation,
  );

  static const MapWidgetConfig preview = MapWidgetConfig(
    height: 200.0,
    enabledFeatures: {
      MapFeature.track,
    },
    enableInteraction: false,
  );

  static const MapWidgetConfig navigation = MapWidgetConfig(
    height: 500.0,
    enabledFeatures: {
      MapFeature.track,
      MapFeature.startEndMarkers,
      MapFeature.poiMarkers,
      MapFeature.currentLocation,
      MapFeature.mapControls,
    },
    trackColor: Color(0xFF4CAF50),
    trackWidth: 4.0,
  );

  static const MapWidgetConfig dailyPlan = MapWidgetConfig(
    height: 400.0,
    enabledFeatures: {
      MapFeature.track,
      MapFeature.startEndMarkers,
      MapFeature.poiMarkers,
      MapFeature.elevationChart,
      MapFeature.mapControls,
      MapFeature.routeInfo,
    },
  );

  static const MapWidgetConfig immersive = MapWidgetConfig(
    height: 500.0,
    enabledFeatures: {
      MapFeature.track,
      MapFeature.startEndMarkers,
      MapFeature.poiMarkers,
      MapFeature.kilometerMarkers,
      MapFeature.elevationChart,
      MapFeature.mapControls,
    },
    trackRenderMode: TrackRenderMode.elevation,
  );
}

class MapWidget extends StatefulWidget {
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

  const MapWidget({
    super.key,
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
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
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
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
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

    debugPrint('MapWidget: 定位地图到选中分段: ${segment.name}, bounds: $bounds');
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
      debugPrint('MapWidget: 定位地图到轨迹点，bounds: $bounds');
      _mapController!.fitBounds(
        bounds,
        options: FitBoundsOptions(
          padding: widget.config.padding,
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

  void _showMarkerInfo(TrackPointVO point) {
    if (point is MarkerPointModel) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(point.displayTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('类型: ${point.markerTypeText}'),
              Text('海拔: ${point.elevation.toStringAsFixed(1)}m'),
              Text(
                  '坐标: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}'),
              if (point.description != null && point.description!.isNotEmpty)
                Text('描述: ${point.description}'),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('轨迹点'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('海拔: ${point.elevation.toStringAsFixed(1)}m'),
              Text(
                  '坐标: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}'),
              if (point.timestamp != null)
                Text(
                    '时间: ${point.timestamp!.toLocal().toString().substring(0, 19)}'),
              if (point.distanceFromStart != null)
                Text(
                    '距离起点: ${(point.distanceFromStart! / 1000).toStringAsFixed(2)}km'),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  void _showMapTypeSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('选择地图类型'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _currentMapType = MapType.standard);
              Navigator.pop(context);
            },
            child: const Text('标准地图'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _currentMapType = MapType.satellite);
              Navigator.pop(context);
            },
            child: const Text('卫星地图'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _currentMapType = MapType.terrain);
              Navigator.pop(context);
            },
            child: const Text('地形地图'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
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
              padding: widget.config.padding,
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
            },
          ),
          if (widget.config.hasFeature(MapFeature.mapControls))
            ..._buildMapControls(),
          if (widget.config.hasFeature(MapFeature.routeInfo) &&
              widget.routeName != null)
            _buildRouteInfoCard(),
          if (widget.days != null && widget.days! > 1)
            _buildDaySelector(),
          if (widget.config.hasFeature(MapFeature.elevationChart) &&
              currentTrackPoints.isNotEmpty)
            ..._buildElevationChart(currentTrackPoints),
        ],
      ),
    );
  }

  List<Widget> _buildMapControls() {
    return [
      Positioned(
        top: 16,
        right: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.config.hasFeature(MapFeature.currentLocation))
              _buildMapButton(
                icon: _isFollowingLocation
                    ? CupertinoIcons.location_fill
                    : CupertinoIcons.location,
                isActive: _isFollowingLocation,
                onPressed: () {
                  setState(() => _isFollowingLocation = !_isFollowingLocation);
                },
              ),
            const SizedBox(height: 8),
            _buildMapButton(
              icon: CupertinoIcons.map,
              onPressed: _showMapTypeSelector,
            ),
            const SizedBox(height: 8),
            _buildMapButton(
              icon: CupertinoIcons.layers_alt,
              onPressed: () {
                print('图层控制');
              },
            ),
          ],
        ),
      ),
      Positioned(
        bottom: _showElevationChart ? 200 : 16,
        left: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMapButton(
              icon: CupertinoIcons.scope,
              onPressed: () {
                print('回到轨迹中心');
              },
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildRouteInfoCard() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.routeName != null)
              Text(
                widget.routeName!,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (widget.routeDistance != null || widget.routeElevationGain != null)
              const SizedBox(height: 4),
            if (widget.routeDistance != null || widget.routeElevationGain != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.routeDistance != null) ...[
                    const Icon(
                      CupertinoIcons.location,
                      size: 12,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.routeDistance!.toStringAsFixed(1)}km',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (widget.routeDistance != null && widget.routeElevationGain != null)
                    const SizedBox(width: 8),
                  if (widget.routeElevationGain != null) ...[
                    const Icon(
                      CupertinoIcons.arrow_up,
                      size: 12,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.routeElevationGain!.toString()}m',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (widget.routeDifficulty != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.routeDifficulty!,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final dailyTracks = _splitTrackByDays();
    return Positioned(
      bottom: _showElevationChart ? 180 : 16,
      left: 16,
      right: 16,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildDayChip(null, '全部'),
            ...dailyTracks.asMap().entries.map((entry) {
              return _buildDayChip(entry.key, '第${entry.key + 1}天');
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(int? day, String label) {
    final isSelected = _selectedDay == day;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedDay = day);
          widget.events.onDayChanged?.call(day);
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? CupertinoColors.activeBlue
                : CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? CupertinoColors.white
                    : CupertinoColors.label,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildElevationChart(List<TrackPointVO> trackPoints) {
    return [
      Positioned(
        bottom: 16,
        right: 16,
        child: _buildMapButton(
          icon: _showElevationChart
              ? CupertinoIcons.chart_bar_square_fill
              : CupertinoIcons.chart_bar_square,
          isActive: _showElevationChart,
          onPressed: () {
            setState(() => _showElevationChart = !_showElevationChart);
          },
        ),
      ),
      if (_showElevationChart)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildFloatingElevationChart(trackPoints),
        ),
    ];
  }

  Widget _buildFloatingElevationChart(List<TrackPointVO> trackPoints) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '海拔图表',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () {
                    setState(() => _showElevationChart = false);
                  },
                  child: const Icon(
                    CupertinoIcons.xmark,
                    size: 18,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          ElevationChartWidget(
            trackPoints: trackPoints,
            config: const ElevationChartConfig(
              height: 120.0,
              showLabels: false,
              enableInteraction: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
    Color? activeColor,
  }) {
    final buttonColor = isActive
        ? (activeColor ?? CupertinoColors.systemBlue)
        : CupertinoColors.systemGrey4;
    final iconColor = isActive ? CupertinoColors.white : CupertinoColors.label;

    return CupertinoButton(
      padding: const EdgeInsets.all(12),
      color: buttonColor.withOpacity(0.9),
      borderRadius: BorderRadius.circular(25),
      minSize: 0,
      onPressed: onPressed,
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }
}
