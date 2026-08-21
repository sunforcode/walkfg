import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:walk/model/map/marker_point_model.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/segment_model.dart';
import 'package:walk/ui/map/mapbox/mapbox_style.dart';
import 'package:walk/ui/map/mapbox/widgets/mapbox_map_controls.dart';
import 'package:walk/ui/map/mapbox/widgets/mapbox_token_placeholder.dart';

/// Mapbox 3D 地图组件
///
/// 基于 Mapbox GL 实现真实 3D 地形渲染：
/// - 底图：多种样式可切换（等高线/卫星图/标准）
/// - 地形：Mapbox Terrain DEM（真实 3D 地形，夸张系数 1.5）
/// - 轨迹：GeoJSON LineLayer 贴地显示
/// - 分段：每段用独立颜色渲染
/// - POI：标记点用圆点显示
/// - 相机：初始化后自动 flyTo 完整轨迹，pitch = 45°
///
/// 坐标要求：传入的 trackPoints 必须是 WGS-84 坐标（已由 KmlCacheService 完成转换）
class MapboxMapWidget extends StatefulWidget {
  final List<TrackPointVO> trackPoints;
  final List<MarkerPointModel> markers;

  /// 路线分段（可选），每段带独立颜色，通过 trackStartIndex/trackEndIndex 切片轨迹
  final List<SegmentModel> segments;

  /// 当前选中的分段 ID，选中时高亮显示
  final String? selectedSegmentId;

  final double height;

  const MapboxMapWidget({
    super.key,
    required this.trackPoints,
    this.markers = const [],
    this.segments = const [],
    this.selectedSegmentId,
    this.height = double.infinity,
  });

  @override
  State<MapboxMapWidget> createState() => _MapboxMapWidgetState();
}

class _MapboxMapWidgetState extends State<MapboxMapWidget> {
  mapbox.MapboxMap? _mapboxMap;
  bool _trackLayerAdded = false;

  static const String _trackSourceId = 'walk-track-source';
  static const String _trackLayerId = 'walk-track-layer';
  static const String _highlightLayerId = 'walk-track-highlight-layer';
  static const String _terrainSourceId = 'mapbox-dem';
  static const String _poiSourceId = 'walk-poi-source';
  static const String _poiLayerId = 'walk-poi-layer';

  static const String _demTilesetId = 'mapbox://mapbox.mapbox-terrain-dem-v1';

  /// 当前地图样式
  MapboxStyle _currentStyle = MapboxStyle.satellite;

  /// 获取 Mapbox token
  static String get _token =>
      dotenv.env['MAPBOX_TOKEN'] ?? '';

  /// 判断 token 是否有效
  static bool get _hasValidToken =>
      _token.isNotEmpty && _token.startsWith('pk.');

  @override
  void didUpdateWidget(MapboxMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 选中分段变化时，更新高亮图层
    if (oldWidget.selectedSegmentId != widget.selectedSegmentId &&
        _trackLayerAdded) {
      _updateHighlight();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidToken) {
      return MapboxTokenPlaceholder(height: widget.height);
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          mapbox.MapWidget(
            key: ValueKey('mapbox-3d-widget-${_currentStyle.name}'),
            styleUri: _currentStyle.uri,
            cameraOptions: mapbox.CameraOptions(
              center: _getInitialCenter(),
              zoom: 10.0,
              pitch: 45.0,
            ),
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onStyleLoaded,
          ),
          // 缩放按钮
          Positioned(
            right: 12,
            bottom: 80,
            child: MapboxZoomButtons(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
            ),
          ),
          // 样式切换工具栏
          Positioned(
            bottom: 24,
            right: 12,
            child: MapboxStyleSwitcher(
              currentStyle: _currentStyle,
              onStyleChanged: _switchStyle,
            ),
          ),
        ],
      ),
    );
  }

  /// 放大
  Future<void> _zoomIn() async {
    if (_mapboxMap == null) return;
    try {
      final state = await _mapboxMap!.getCameraState();
      await _mapboxMap!.flyTo(
        mapbox.CameraOptions(zoom: (state.zoom + 1).clamp(2.0, 20.0)),
        mapbox.MapAnimationOptions(duration: 300),
      );
    } catch (e) {
      debugPrint('MapboxMapWidget: zoomIn 失败: $e');
    }
  }

  /// 缩小
  Future<void> _zoomOut() async {
    if (_mapboxMap == null) return;
    try {
      final state = await _mapboxMap!.getCameraState();
      await _mapboxMap!.flyTo(
        mapbox.CameraOptions(zoom: (state.zoom - 1).clamp(2.0, 20.0)),
        mapbox.MapAnimationOptions(duration: 300),
      );
    } catch (e) {
      debugPrint('MapboxMapWidget: zoomOut 失败: $e');
    }
  }

  /// 切换地图样式
  void _switchStyle(MapboxStyle style) {
    if (_currentStyle == style) return;
    setState(() {
      _currentStyle = style;
      _mapboxMap = null; // 重置，等待新 MapWidget 回调
    });
  }

  /// 计算初始中心点（轨迹中点）
  mapbox.Point _getInitialCenter() {
    if (widget.trackPoints.isEmpty) {
      return mapbox.Point(
        coordinates: mapbox.Position(116.4074, 39.9042),
      );
    }
    double totalLat = 0;
    double totalLng = 0;
    for (final p in widget.trackPoints) {
      totalLat += p.latitude;
      totalLng += p.longitude;
    }
    return mapbox.Point(
      coordinates: mapbox.Position(
        totalLng / widget.trackPoints.length,
        totalLat / widget.trackPoints.length,
      ),
    );
  }

  void _onMapCreated(mapbox.MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    // 设置 token
    mapbox.MapboxOptions.setAccessToken(_token);
  }

  void _onStyleLoaded(mapbox.StyleLoadedEventData eventData) {
    _trackLayerAdded = false;
    _setupTerrain();
    if (widget.trackPoints.isNotEmpty) {
      // 如果有分段数据，渲染分段彩色线；否则渲染整体轨迹
      if (widget.segments.isNotEmpty) {
        _addSegmentLayers();
      } else {
        _addTrackLayer();
      }
      _fitCameraToTrack();
    }
    // 渲染 POI 标记点
    if (widget.markers.isNotEmpty) {
      _addPoiLayer();
    }
  }

  /// 添加 Terrain DEM 图层，启用 3D 地形
  Future<void> _setupTerrain() async {
    if (_mapboxMap == null) return;
    try {
      // 添加 DEM 数据源
      await _mapboxMap!.style.addSource(mapbox.RasterDemSource(
        id: _terrainSourceId,
        url: _demTilesetId,
        tileSize: 512,
      ));
      // 启用 3D 地形，exaggeration=1.5 让山形更立体
      await _mapboxMap!.style.setStyleTerrain(
        jsonEncode({'source': _terrainSourceId, 'exaggeration': 1.5}),
      );
    } catch (e) {
      debugPrint('MapboxMapWidget: 地形设置失败: $e');
    }
  }

  /// 将轨迹点转换为 GeoJSON，添加轨迹线图层（贴地）
  Future<void> _addTrackLayer() async {
    if (_mapboxMap == null || widget.trackPoints.isEmpty) return;
    try {
      // 构建 GeoJSON LineString
      final coordinates = widget.trackPoints
          .map((p) => [p.longitude, p.latitude, p.elevation])
          .toList();

      final geoJson = jsonEncode({
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              'coordinates': coordinates,
            },
            'properties': {},
          }
        ],
      });

      // 添加 GeoJSON 数据源
      await _mapboxMap!.style.addSource(
        mapbox.GeoJsonSource(id: _trackSourceId, data: geoJson),
      );

      // 添加 LineLayer，lineElevationReference=road 使轨迹线贴合地形
      await _mapboxMap!.style.addLayer(
        mapbox.LineLayer(
          id: _trackLayerId,
          sourceId: _trackSourceId,
          lineColor: const Color(0xFF2196F3).toARGB32(),
          lineWidth: 3.5,
          lineOpacity: 0.9,
          lineCap: mapbox.LineCap.ROUND,
          lineJoin: mapbox.LineJoin.ROUND,
          lineElevationReference: mapbox.LineElevationReference.NONE,
        ),
      );
    } catch (e) {
      debugPrint('MapboxMapWidget: 添加轨迹线失败: $e');
    }
  }

  /// 黄金角旋转颜色，返回 '#RRGGBB' 字符串，供 Mapbox 表达式使用
  static String _segmentHexColor(int seq) {
    final h = (seq * 137.508) % 360;
    final color = HSVColor.fromAHSV(1.0, h, 0.8, 0.9).toColor();
    // ignore: deprecated_member_use
    return '#${(color.r * 255).round().toRadixString(16).padLeft(2, '0')}'
        '${(color.g * 255).round().toRadixString(16).padLeft(2, '0')}'
        '${(color.b * 255).round().toRadixString(16).padLeft(2, '0')}';
  }

  /// 按分段分色渲染轨迹线
  ///
  /// 每个分段用独立的 GeoJSON Feature，通过 segment-color 属性驱动颜色。
  Future<void> _addSegmentLayers() async {
    if (_mapboxMap == null || widget.trackPoints.isEmpty) return;
    try {
      final pts = widget.trackPoints;

      // 构建每个分段的 Feature
      final features = <Map<String, dynamic>>[];

      // 先按 sequenceNumber 排序分段
      final sortedSegs = List<SegmentModel>.from(widget.segments)
        ..sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));

      // 收集所有已覆盖的点索引范围
      int coveredEnd = -1;
      for (final seg in sortedSegs) {
        final start = seg.trackStartIndex;
        final end = seg.trackEndIndex;
        if (start == null || end == null) continue;
        if (start < 0 || end >= pts.length || start > end) continue;

        final segCoords = pts
            .sublist(start, end + 1)
            .map((p) => [p.longitude, p.latitude, p.elevation])
            .toList();

        if (segCoords.length < 2) continue;

        features.add({
          'type': 'Feature',
          'geometry': {'type': 'LineString', 'coordinates': segCoords},
          'properties': {
            'seg-color': _segmentHexColor(seg.sequenceNumber),
            'seg-id': seg.id,
          },
        });

        if (end > coveredEnd) coveredEnd = end;
      }

      // 如果有轨迹点但分段覆盖不完整，把剩余部分用灰色补上
      if (pts.isNotEmpty && (coveredEnd < 0 || coveredEnd < pts.length - 1)) {
        final remaining = pts
            .sublist(coveredEnd + 1)
            .map((p) => [p.longitude, p.latitude, p.elevation])
            .toList();
        if (remaining.length >= 2) {
          features.add({
            'type': 'Feature',
            'geometry': {'type': 'LineString', 'coordinates': remaining},
            'properties': {'seg-color': '#9E9E9E'},
          });
        }
      }

      if (features.isEmpty) {
        // 降级：无有效分段，直接画整条轨迹
        await _addTrackLayer();
        return;
      }

      final geoJson = jsonEncode({
        'type': 'FeatureCollection',
        'features': features,
      });

      await _mapboxMap!.style.addSource(
        mapbox.GeoJsonSource(id: _trackSourceId, data: geoJson),
      );

      // 用表达式从 Feature properties 读颜色
      await _mapboxMap!.style.addLayer(
        mapbox.LineLayer(
          id: _trackLayerId,
          sourceId: _trackSourceId,
          lineColorExpression: ['get', 'seg-color'],
          lineWidth: 4.0,
          lineOpacity: 0.92,
          lineCap: mapbox.LineCap.ROUND,
          lineJoin: mapbox.LineJoin.ROUND,
          lineElevationReference: mapbox.LineElevationReference.NONE,
        ),
      );

      // 高亮图层（选中段白色描边），初始透明
      await _mapboxMap!.style.addLayer(
        mapbox.LineLayer(
          id: _highlightLayerId,
          sourceId: _trackSourceId,
          lineColorExpression: ['get', 'seg-color'],
          lineWidth: 7.0,
          lineOpacity: 0.0, // 初始不可见，_updateHighlight 会更新
          lineCap: mapbox.LineCap.ROUND,
          lineJoin: mapbox.LineJoin.ROUND,
          lineElevationReference: mapbox.LineElevationReference.NONE,
          filter: ['==', ['get', 'seg-id'], ''],
        ),
      );

      _trackLayerAdded = true;
      _updateHighlight(); // 应用初始选中状态
    } catch (e) {
      debugPrint('MapboxMapWidget: 添加分段轨迹线失败: $e，降级为整体轨迹');
      await _addTrackLayer();
    }
  }

  /// 更新高亮图层，突出选中分段
  Future<void> _updateHighlight() async {
    if (_mapboxMap == null) return;
    final selId = widget.selectedSegmentId;
    try {
      if (selId == null || selId.isEmpty) {
        // 无选中：隐藏高亮，所有段恢复正常透明度
        await _mapboxMap!.style.setStyleLayerProperty(
            _highlightLayerId, 'line-opacity', jsonEncode(0.0));
        await _mapboxMap!.style.setStyleLayerProperty(
            _trackLayerId, 'line-opacity', jsonEncode(0.92));
      } else {
        // 有选中：未选中段降低透明度，高亮层 filter 到选中段
        await _mapboxMap!.style.setStyleLayerProperty(
            _trackLayerId, 'line-opacity', jsonEncode(0.35));
        await _mapboxMap!.style.setStyleLayerProperty(
            _highlightLayerId,
            'filter',
            jsonEncode(['==', ['get', 'seg-id'], selId]));
        await _mapboxMap!.style.setStyleLayerProperty(
            _highlightLayerId, 'line-opacity', jsonEncode(1.0));
        // 飞到选中分段区域
        _fitCameraToSegment(selId);
      }
    } catch (e) {
      debugPrint('MapboxMapWidget: 更新高亮失败: $e');
    }
  }

  /// 相机飞到选中分段区域
  Future<void> _fitCameraToSegment(String segId) async {
    if (_mapboxMap == null) return;
    try {
      final seg = widget.segments.firstWhere(
        (s) => s.id == segId,
        orElse: () => widget.segments.first,
      );
      final start = seg.trackStartIndex;
      final end = seg.trackEndIndex;
      if (start == null || end == null) return;
      if (start < 0 || end >= widget.trackPoints.length || start > end) return;

      final pts = widget.trackPoints.sublist(start, end + 1);
      double minLat = pts.first.latitude, maxLat = pts.first.latitude;
      double minLng = pts.first.longitude, maxLng = pts.first.longitude;
      for (final p in pts) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }
      const pad = 0.005;
      final bounds = mapbox.CoordinateBounds(
        southwest: mapbox.Point(
            coordinates: mapbox.Position(minLng - pad, minLat - pad)),
        northeast: mapbox.Point(
            coordinates: mapbox.Position(maxLng + pad, maxLat + pad)),
        infiniteBounds: false,
      );
      final cam = await _mapboxMap!.cameraForCoordinateBounds(
        bounds,
        mapbox.MbxEdgeInsets(top: 80, left: 60, bottom: 80, right: 60),
        45.0,
        null,
        null,
        null,
      );
      await _mapboxMap!.flyTo(
          cam, mapbox.MapAnimationOptions(duration: 800));
    } catch (e) {
      debugPrint('MapboxMapWidget: 飞到分段失败: $e');
    }
  }

  /// 根据 MarkerPointType 获取 POI 颜色
  String _poiColor(MarkerPointType type) {
    switch (type) {
      case MarkerPointType.poi:
        return '#2196F3'; // 蓝色 - 兴趣点
      case MarkerPointType.landmark:
        return '#4CAF50'; // 绿色 - 地标
      case MarkerPointType.viewpoint:
        return '#FF9800'; // 橙色 - 观景点
      case MarkerPointType.restPoint:
        return '#9C27B0'; // 紫色 - 休息点
      case MarkerPointType.dangerPoint:
        return '#F44336'; // 红色 - 危险点
      case MarkerPointType.infoPoint:
        return '#00BCD4'; // 青色 - 信息点
      case MarkerPointType.other:
        return '#757575'; // 灰色 - 其他
    }
  }

  /// 添加 POI 标记点（圆点，按类型着色）
  Future<void> _addPoiLayer() async {
    if (_mapboxMap == null || widget.markers.isEmpty) return;
    try {
      final features = widget.markers.map((m) => {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [m.longitude, m.latitude],
            },
            'properties': {
              'name': m.name ?? '',
              'poi-color': m.color ?? _poiColor(m.markerType),
              'poi-type': m.markerType.name,
            },
          }).toList();

      if (features.isEmpty) return;

      final geoJson = jsonEncode({
        'type': 'FeatureCollection',
        'features': features,
      });

      await _mapboxMap!.style.addSource(
        mapbox.GeoJsonSource(id: _poiSourceId, data: geoJson),
      );

      // 按类型着色的圆点 + 白色描边
      await _mapboxMap!.style.addLayer(
        mapbox.CircleLayer(
          id: _poiLayerId,
          sourceId: _poiSourceId,
          circleRadius: 6.0,
          circleColorExpression: ['get', 'poi-color'],
          circleStrokeWidth: 2.0,
          circleStrokeColor: const Color(0xFFFFFFFF).toARGB32(),
        ),
      );
    } catch (e) {
      debugPrint('MapboxMapWidget: 添加 POI 失败: $e');
    }
  }

  /// 相机飞到完整轨迹区域，pitch=45°
  Future<void> _fitCameraToTrack() async {
    if (_mapboxMap == null || widget.trackPoints.isEmpty) return;
    try {
      double minLat = widget.trackPoints.first.latitude;
      double maxLat = widget.trackPoints.first.latitude;
      double minLng = widget.trackPoints.first.longitude;
      double maxLng = widget.trackPoints.first.longitude;

      for (final p in widget.trackPoints) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }

      // 添加边距
      const padding = 0.01;
      final bounds = mapbox.CoordinateBounds(
        southwest: mapbox.Point(
            coordinates: mapbox.Position(minLng - padding, minLat - padding)),
        northeast: mapbox.Point(
            coordinates: mapbox.Position(maxLng + padding, maxLat + padding)),
        infiniteBounds: false,
      );

      final cameraOptions = await _mapboxMap!.cameraForCoordinateBounds(
        bounds,
        mapbox.MbxEdgeInsets(top: 60, left: 40, bottom: 60, right: 40),
        45.0, // pitch
        null, // bearing
        null,
        null,
      );

      await _mapboxMap!.flyTo(
        cameraOptions,
        mapbox.MapAnimationOptions(duration: 1500),
      );
    } catch (e) {
      debugPrint('MapboxMapWidget: 相机定位失败: $e');
    }
  }

  @override
  void dispose() {
    _mapboxMap = null;
    super.dispose();
  }
}
