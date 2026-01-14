import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/widgets/maplibre_3d_widget_fixed.dart';

/// 3D地图配置
class Map3DConfig {
  /// 地图高度
  final double height;

  /// 地图类型
  final MapType mapType;

  /// 初始倾斜角度
  final double initialPitch;

  /// 初始旋转角度
  final double initialBearing;

  /// 是否显示轨迹
  final bool showTrack;

  /// 轨迹颜色
  final Color trackColor;

  /// 轨迹宽度
  final double trackWidth;

  /// 是否启用3D建筑
  final bool enable3DBuildings;

  /// 是否启用地形
  final bool enableTerrain;

  const Map3DConfig({
    this.height = 400.0,
    this.mapType = MapType.threeD,
    this.initialPitch = 45.0,
    this.initialBearing = 0.0,
    this.showTrack = true,
    this.trackColor = const Color(0xFF2196F3),
    this.trackWidth = 3.0,
    this.enable3DBuildings = true,
    this.enableTerrain = true,
  });

  /// 创建副本
  Map3DConfig copyWith({
    double? height,
    MapType? mapType,
    double? initialPitch,
    double? initialBearing,
    bool? showTrack,
    Color? trackColor,
    double? trackWidth,
    bool? enable3DBuildings,
    bool? enableTerrain,
  }) {
    return Map3DConfig(
      height: height ?? this.height,
      mapType: mapType ?? this.mapType,
      initialPitch: initialPitch ?? this.initialPitch,
      initialBearing: initialBearing ?? this.initialBearing,
      showTrack: showTrack ?? this.showTrack,
      trackColor: trackColor ?? this.trackColor,
      trackWidth: trackWidth ?? this.trackWidth,
      enable3DBuildings: enable3DBuildings ?? this.enable3DBuildings,
      enableTerrain: enableTerrain ?? this.enableTerrain,
    );
  }
}

/// 3D地图事件
class Map3DEvents {
  /// 地图点击
  final void Function(LatLng position)? onMapTap;

  /// 地图长按
  final void Function(LatLng position)? onMapLongPress;

  /// 地图移动
  final void Function(LatLng center, double zoom, double pitch, double bearing)?
      onCameraMove;

  /// 地图准备就绪
  final VoidCallback? onMapReady;

  const Map3DEvents({
    this.onMapTap,
    this.onMapLongPress,
    this.onCameraMove,
    this.onMapReady,
  });
}

/// 3D地图组件 - 基于MapLibre GL的真正3D实现
///
/// 特性：
/// 1. 使用MapLibre GL实现真正的3D效果
/// 2. 支持3D轨迹显示和地形
/// 3. 兼容现有的数据模型
/// 4. 提供完整的3D配置接口
class Map3DWidget extends StatefulWidget {
  /// 轨迹点数据
  final List<TrackPointVO> trackPoints;

  /// 3D地图配置
  final Map3DConfig config;

  /// 事件回调
  final Map3DEvents events;

  /// 初始中心点
  final LatLng? initialCenter;

  const Map3DWidget({
    super.key,
    this.trackPoints = const [],
    this.config = const Map3DConfig(),
    this.events = const Map3DEvents(),
    this.initialCenter,
  });

  @override
  State<Map3DWidget> createState() => _Map3DWidgetState();
}

class _Map3DWidgetState extends State<Map3DWidget> {
  @override
  Widget build(BuildContext context) {
    // 转换配置为MapLibre格式
    final mapLibreConfig = MapLibre3DConfig(
      mapType: widget.config.mapType,
      initialCenter: widget.initialCenter,
      initialZoom: 10.0,
      initialPitch: widget.config.initialPitch,
      initialBearing: widget.config.initialBearing,
      enable3DBuildings: widget.config.enable3DBuildings,
      enableTerrain: widget.config.enableTerrain,
      trackColor: widget.config.trackColor,
      trackWidth: widget.config.trackWidth,
    );

    final mapLibreEvents = MapLibre3DEvents(
      onTap: (position) => widget.events.onMapTap?.call(position),
      onLongPress: (position) => widget.events.onMapLongPress?.call(position),
      onMove: (center, zoom, pitch, bearing) =>
          widget.events.onCameraMove?.call(center, zoom, pitch, bearing),
      onReady: () => widget.events.onMapReady?.call(),
    );

    return MapLibre3DWidgetFixed(
      config: mapLibreConfig,
      events: mapLibreEvents,
      trackPoints: widget.trackPoints,
      showTrack: widget.config.showTrack,
      height: widget.config.height,
    );
  }
}

/// 3D地图预设配置
class Map3DPresets {
  /// 基础3D轨迹
  static const Map3DConfig basic3DTrack = Map3DConfig(
    height: 400.0,
    mapType: MapType.threeD,
    initialPitch: 45.0,
    showTrack: true,
    enable3DBuildings: true,
    enableTerrain: false,
  );

  /// 3D地形轨迹
  static const Map3DConfig terrain3DTrack = Map3DConfig(
    height: 500.0,
    mapType: MapType.threeDTerrain,
    initialPitch: 60.0,
    showTrack: true,
    enable3DBuildings: false,
    enableTerrain: true,
    trackColor: Color(0xFFFF6B35),
    trackWidth: 4.0,
  );

  /// 3D卫星轨迹
  static const Map3DConfig satellite3DTrack = Map3DConfig(
    height: 450.0,
    mapType: MapType.threeDSatellite,
    initialPitch: 50.0,
    showTrack: true,
    enable3DBuildings: true,
    enableTerrain: true,
    trackColor: Color(0xFF00BCD4),
    trackWidth: 3.5,
  );
}
