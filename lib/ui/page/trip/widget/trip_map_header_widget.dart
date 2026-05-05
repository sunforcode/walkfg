import 'package:flutter/cupertino.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/ui/map/map_widget.dart';

/// 行程地图头部组件
class TripMapHeaderWidget extends StatelessWidget {
  final RouteModel? route;
  final List<TrackPointVO> trackPoints;
  final double height;

  const TripMapHeaderWidget({
    super.key,
    this.route,
    this.trackPoints = const [],
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: MapWidget(
        trackPoints: trackPoints,
        markers: route?.markerPoints ?? [],
        config: MapWidgetConfig(
          height: height,
          enabledFeatures: {
            MapFeature.track,
            MapFeature.startEndMarkers,
            MapFeature.poiMarkers,
            MapFeature.routeInfo,
          },
        ),
        routeName: route?.name,
        routeDistance: route?.distance,
        routeElevationGain: route?.elevationGain,
        routeDifficulty: route?.difficulty.getName(),
      ),
    );
  }
}
