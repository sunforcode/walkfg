/// Mapbox 地图样式枚举
enum MapboxStyle {
  outdoors,
  satellite,
  standardSatellite,
  standard;

  String get uri {
    switch (this) {
      case MapboxStyle.outdoors:
        return 'mapbox://styles/mapbox/outdoors-v12';
      case MapboxStyle.satellite:
        return 'mapbox://styles/mapbox/satellite-streets-v12';
      case MapboxStyle.standardSatellite:
        return 'mapbox://styles/mapbox/standard-satellite';
      case MapboxStyle.standard:
        return 'mapbox://styles/mapbox/standard';
    }
  }

  String get label {
    switch (this) {
      case MapboxStyle.outdoors:
        return '等高线';
      case MapboxStyle.satellite:
        return '卫星';
      case MapboxStyle.standardSatellite:
        return '卫星+';
      case MapboxStyle.standard:
        return '标准';
    }
  }
}
