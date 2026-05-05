import 'package:flutter/cupertino.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/ui/map/map_widget.dart';

/// 地图头部部分
class MapHeaderSection extends StatelessWidget {
  /// 路线
  final RouteModel route;

  /// 轨迹点
  final List<TrackPointVO> trackPoints;

  /// 地图类型
  final MapType mapType;

  /// 地图提供商
  final MapProviderType mapProvider;

  /// 地图高度
  final double height;

  /// 构造函数
  const MapHeaderSection({
    Key? key,
    required this.route,
    required this.trackPoints,
    this.mapType = MapType.standard,
    this.mapProvider = MapProviderType.osm,
    this.height = 200.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: MapWidget(
        trackPoints: trackPoints,
        markers: route.markerPoints ?? [],
        config: MapWidgetConfig(
          height: height,
          mapType: mapType,
          mapProvider: mapProvider,
          enabledFeatures: {
            MapFeature.track,
            MapFeature.startEndMarkers,
            MapFeature.poiMarkers,
            MapFeature.routeInfo,
          },
        ),
        routeName: route.name,
        routeDistance: route.distance,
        routeElevationGain: route.elevationGain,
        routeDifficulty: route.difficulty.getName(),
      ),
    );
  }
}
