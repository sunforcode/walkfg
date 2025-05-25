import 'package:flutter/material.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/map/map_bounds.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/unified_map_widget.dart';

/// 增强版地图组件
///
/// @deprecated 此组件已废弃，请使用 [UnifiedMapWidget] 代替
class EnhancedMapWidget extends StatelessWidget {
  /// 路线
  final RouteModel? route;

  /// 轨迹点
  final List<TrackPointVO>? trackPoints;

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
  const EnhancedMapWidget({
    super.key,
    this.route,
    this.trackPoints,
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
  Widget build(BuildContext context) {
    // 显示废弃警告
    debugPrint('警告：EnhancedMapWidget 已废弃，请使用 UnifiedMapWidget 代替');

    // 使用 UnifiedMapWidget 代替
    return UnifiedMapWidget(
      route: route,
      trackPoints: trackPoints,
      height: height,
      showCurrentLocation: showCurrentLocation,
      showMapTypeToolbar: showMapTypeToolbar,
      showEnhancedToolbar: showEnhancedToolbar,
      mapType: mapType,
      mapProvider: mapProvider,
      trackRenderMode: trackRenderMode,
      showKilometerMarkers: showKilometerMarkers,
      showPointsOfInterest: showPointsOfInterest,
      showElevationChart: showElevationChart,
      supportOfflineMap: supportOfflineMap,
      onMapTypeChanged: onMapTypeChanged,
      onMapProviderChanged: onMapProviderChanged,
      onTrackRenderModeChanged: onTrackRenderModeChanged,
      onKilometerMarkersVisibilityChanged: onKilometerMarkersVisibilityChanged,
      onPointsOfInterestVisibilityChanged: onPointsOfInterestVisibilityChanged,
      onElevationChartVisibilityChanged: onElevationChartVisibilityChanged,
      onDownloadOfflineMap: onDownloadOfflineMap,
    );
  }
}
