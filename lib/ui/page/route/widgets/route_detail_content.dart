import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:walk/model/model/map/map_bounds.dart';
import 'package:walk/model/model/map/track_point_model.dart';
import 'package:walk/model/model/route/route_model.dart';
import 'package:walk/service/map_service.dart';
import 'package:walk/ui/map/unified_map_widget.dart';
import 'package:walk/ui/page/route/widgets/route_info_section.dart';
import 'package:walk/ui/page/route/widgets/route_action_buttons.dart';

/// 路线详情内容组件
class RouteDetailContent extends StatelessWidget {
  /// 路线
  final RouteModel route;

  /// 轨迹点
  final List<TrackPointVO> trackPoints;

  /// 路标点
  final List<TrackPointVO> waypoints;

  /// 是否已收藏
  final bool isFavorite;

  /// 查看地图回调
  final VoidCallback? onViewMap;

  /// 规划行程回调
  final VoidCallback? onPlanTrip;

  /// 收藏回调
  final VoidCallback? onFavorite;

  /// 离线地图下载回调
  final Function(MapBoundsVO bounds, MapType mapType, MapProvider mapProvider)?
      onDownloadOfflineMap;

  /// 构造函数
  const RouteDetailContent({
    super.key,
    required this.route,
    this.trackPoints = const [],
    this.waypoints = const [],
    this.isFavorite = false,
    this.onViewMap,
    this.onPlanTrip,
    this.onFavorite,
    this.onDownloadOfflineMap,
  });

  @override
  Widget build(BuildContext context) {
    final mapService = Provider.of<MapService>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统一地图组件
          UnifiedMapWidget(
            route: route,
            trackPoints: trackPoints,
            waypoints: waypoints,
            height: MediaQuery.of(context).size.height * 0.4,
            showCurrentLocation: true,
            showMapTypeToolbar: true,
            showEnhancedToolbar: true,
            mapType: mapService.currentMapType,
            mapProvider: mapService.currentMapProvider,
            trackRenderMode: mapService.currentTrackRenderMode,
            showKilometerMarkers: mapService.showKilometerMarkers,
            showPointsOfInterest: mapService.showPointsOfInterest,
            showElevationChart: mapService.showElevationChart,
            supportOfflineMap: mapService.supportOfflineMap,
            onMapTypeChanged: mapService.setMapType,
            onMapProviderChanged: mapService.setMapProvider,
            onTrackRenderModeChanged: mapService.setTrackRenderMode,
            onKilometerMarkersVisibilityChanged:
                mapService.setShowKilometerMarkers,
            onPointsOfInterestVisibilityChanged:
                mapService.setShowPointsOfInterest,
            onElevationChartVisibilityChanged: mapService.setShowElevationChart,
            onDownloadOfflineMap: onDownloadOfflineMap,
          ),

          // 操作按钮
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RouteActionButtons(
              onViewMap: onViewMap,
              onPlanTrip: onPlanTrip,
              onFavorite: onFavorite,
              isFavorite: isFavorite,
            ),
          ),

          // 路线信息
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: RouteInfoSection(route: route),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
