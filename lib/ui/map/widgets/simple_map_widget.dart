import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/ui/map/core/unified_map_core.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/layers/track_layer.dart';
import 'package:walk/ui/map/layers/marker_layer.dart';

/// 简单地图配置
class SimpleMapConfig {
  /// 地图高度
  final double height;

  /// 地图类型
  final MapType mapType;

  /// 地图提供商
  final MapProviderType mapProvider;

  /// 是否显示轨迹
  final bool showTrack;

  /// 是否显示起点终点
  final bool showStartEnd;

  /// 是否显示兴趣点
  final bool showPointsOfInterest;

  /// 是否显示公里标记
  final bool showKilometerMarkers;

  /// 是否显示当前位置
  final bool showCurrentLocation;

  /// 轨迹渲染模式
  final TrackRenderMode trackRenderMode;

  /// 轨迹线颜色
  final Color trackColor;

  /// 轨迹线宽度
  final double trackWidth;

  const SimpleMapConfig({
    this.height = 300.0,
    this.mapType = MapType.standard,
    this.mapProvider = MapProviderType.osm,
    this.showTrack = true,
    this.showStartEnd = true,
    this.showPointsOfInterest = true,
    this.showKilometerMarkers = false,
    this.showCurrentLocation = false,
    this.trackRenderMode = TrackRenderMode.normal,
    this.trackColor = const Color(0xFF2196F3),
    this.trackWidth = 3.0,
  });
}

/// 简单地图事件
class SimpleMapEvents {
  /// 地图点击
  final void Function(LatLng position)? onMapTap;

  /// 标记点击
  final void Function(TrackPointVO point)? onMarkerTap;

  /// 地图准备就绪
  final VoidCallback? onMapReady;

  const SimpleMapEvents({
    this.onMapTap,
    this.onMarkerTap,
    this.onMapReady,
  });
}

/// 简单地图组件 - 对外统一接口
///
/// 这是一个高级封装的地图组件，提供简单易用的API：
/// 1. 简化的配置选项
/// 2. 自动处理常见场景
/// 3. 隐藏复杂的内部实现
/// 4. 提供合理的默认值
/// 5. 使用统一的地图核心
class SimpleMapWidget extends StatefulWidget {
  /// 轨迹点数据
  final List<TrackPointVO> trackPoints;

  /// 地图配置
  final SimpleMapConfig config;

  /// 事件回调
  final SimpleMapEvents events;

  /// 初始中心点（如果没有轨迹数据）
  final LatLng? initialCenter;

  /// 当前位置
  final LatLng? currentLocation;

  const SimpleMapWidget({
    super.key,
    this.trackPoints = const [],
    this.config = const SimpleMapConfig(),
    this.events = const SimpleMapEvents(),
    this.initialCenter,
    this.currentLocation,
  });

  @override
  State<SimpleMapWidget> createState() => _SimpleMapWidgetState();
}

class _SimpleMapWidgetState extends State<SimpleMapWidget> {
  /// 计算地图边界
  LatLngBounds? _calculateBounds() {
    if (widget.trackPoints.isEmpty) return null;

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final point in widget.trackPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // 添加边距
    const padding = 0.01;
    return LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );
  }

  /// 构建标记数据
  List<MarkerData> _buildMarkers() {
    final markers = <MarkerData>[];

    // 起点终点标记
    if (widget.config.showStartEnd) {
      markers.addAll(
        MarkerLayerBuilder.buildStartEndMarkers(widget.trackPoints),
      );
    }

    // 兴趣点标记
    if (widget.config.showPointsOfInterest) {
      markers.addAll(
        MarkerLayerBuilder.buildPointsOfInterest(widget.trackPoints),
      );
    }

    // 公里标记
    if (widget.config.showKilometerMarkers) {
      markers.addAll(
        MarkerLayerBuilder.buildKilometerMarkers(widget.trackPoints),
      );
    }

    // 当前位置标记
    if (widget.config.showCurrentLocation) {
      final currentLocationMarker =
          MarkerLayerBuilder.buildCurrentLocationMarker(
        widget.currentLocation,
      );
      if (currentLocationMarker != null) {
        markers.add(currentLocationMarker);
      }
    }

    return markers;
  }

  /// 处理标记点击
  void _handleMarkerTap(MarkerData marker) {
    widget.events.onMarkerTap?.call(marker.point);
  }

  /// 构建地图图层
  List<Widget> _buildMapLayers() {
    final layers = <Widget>[];

    // 轨迹图层
    if (widget.config.showTrack && widget.trackPoints.isNotEmpty) {
      layers.add(
        TrackLayer(
          trackPoints: widget.trackPoints,
          config: TrackRenderConfig(
            renderMode: widget.config.trackRenderMode,
            strokeWidth: widget.config.trackWidth,
            defaultColor: widget.config.trackColor,
          ),
        ),
      );
    }

    // 标记图层
    final markers = _buildMarkers();
    if (markers.isNotEmpty) {
      layers.add(
        CustomMarkerLayer(
          markers: markers,
          onMarkerTap: _handleMarkerTap,
        ),
      );
    }

    return layers;
  }

  @override
  Widget build(BuildContext context) {
    final bounds = _calculateBounds();

    return SizedBox(
      height: widget.config.height,
      child: UnifiedMapCore(
        config: UnifiedMapConfig(
          mapType: widget.config.mapType,
          mapProvider: widget.config.mapProvider,
          enableInteraction: true,
          initialCenter: widget.initialCenter,
          initialBounds: bounds,
        ),
        events: UnifiedMapEvents(
          onTap: widget.events.onMapTap,
          onReady: widget.events.onMapReady,
        ),
        layers: _buildMapLayers(),
      ),
    );
  }
}

/// 预设配置 - 提供常用的配置组合
class SimpleMapPresets {
  /// 基础轨迹地图
  static const SimpleMapConfig basicTrack = SimpleMapConfig(
    height: 300.0,
    showTrack: true,
    showStartEnd: true,
    showPointsOfInterest: false,
    showKilometerMarkers: false,
  );

  /// 详细轨迹地图
  static const SimpleMapConfig detailedTrack = SimpleMapConfig(
    height: 400.0,
    showTrack: true,
    showStartEnd: true,
    showPointsOfInterest: true,
    showKilometerMarkers: true,
    trackRenderMode: TrackRenderMode.elevation,
  );

  /// 简单预览地图
  static const SimpleMapConfig preview = SimpleMapConfig(
    height: 200.0,
    showTrack: true,
    showStartEnd: false,
    showPointsOfInterest: false,
    showKilometerMarkers: false,
  );

  /// 导航地图
  static const SimpleMapConfig navigation = SimpleMapConfig(
    height: 500.0,
    showTrack: true,
    showStartEnd: true,
    showPointsOfInterest: true,
    showCurrentLocation: true,
    trackColor: Color(0xFF4CAF50),
    trackWidth: 4.0,
  );
}
