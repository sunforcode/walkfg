import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/ui/map/core/map_enum.dart';

/// 地图渲染模式
enum MapMode {
  /// 2D 地图（flutter_map，OSM/卫星底图）
  map2d,

  /// 3D 地图（Mapbox，真实 3D 地形）
  map3d,
}

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
