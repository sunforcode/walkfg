/// KML 2.2标准数据模型
/// 
/// 严格按照KML标准定义的数据结构，不包含任何业务逻辑

/// KML文档模型
class KmlDocument {
  final String? id;
  final String? name;
  final String? description;
  final String? snippet;
  final String? author;
  final Map<String, String> extendedData;
  final List<KmlStyle> styles;
  final List<KmlStyleMap> styleMaps;
  final List<KmlFolder> folders;
  final List<KmlPlacemark> placemarks;
  final List<KmlNetworkLink> networkLinks;
  final List<KmlGroundOverlay> groundOverlays;

  KmlDocument({
    this.id,
    this.name,
    this.description,
    this.snippet,
    this.author,
    this.extendedData = const {},
    this.styles = const [],
    this.styleMaps = const [],
    this.folders = const [],
    this.placemarks = const [],
    this.networkLinks = const [],
    this.groundOverlays = const [],
  });
}

/// KML样式模型
class KmlStyle {
  final String id;
  final KmlLineStyle? lineStyle;
  final KmlPolyStyle? polyStyle;
  final KmlIconStyle? iconStyle;
  final KmlLabelStyle? labelStyle;
  final KmlBalloonStyle? balloonStyle;

  KmlStyle({
    required this.id,
    this.lineStyle,
    this.polyStyle,
    this.iconStyle,
    this.labelStyle,
    this.balloonStyle,
  });
}

/// KML线条样式
class KmlLineStyle {
  final String? color;
  final double? width;
  final int? colorMode;

  KmlLineStyle({this.color, this.width, this.colorMode});
}

/// KML多边形样式
class KmlPolyStyle {
  final String? color;
  final int? colorMode;
  final bool? fill;
  final bool? outline;

  KmlPolyStyle({this.color, this.colorMode, this.fill, this.outline});
}

/// KML图标样式
class KmlIconStyle {
  final String? color;
  final int? colorMode;
  final double? scale;
  final double? heading;
  final KmlIcon? icon;
  final KmlHotSpot? hotSpot;

  KmlIconStyle({
    this.color,
    this.colorMode,
    this.scale,
    this.heading,
    this.icon,
    this.hotSpot,
  });
}

/// KML图标
class KmlIcon {
  final String? href;
  final int? refreshMode;
  final double? refreshInterval;

  KmlIcon({this.href, this.refreshMode, this.refreshInterval});
}

/// KML热点
class KmlHotSpot {
  final double x;
  final double y;
  final String xunits;
  final String yunits;

  KmlHotSpot({
    required this.x,
    required this.y,
    required this.xunits,
    required this.yunits,
  });
}

/// KML标签样式
class KmlLabelStyle {
  final String? color;
  final int? colorMode;
  final double? scale;

  KmlLabelStyle({this.color, this.colorMode, this.scale});
}

/// KML气球样式
class KmlBalloonStyle {
  final String? bgColor;
  final String? textColor;
  final String? text;
  final String? displayMode;

  KmlBalloonStyle({this.bgColor, this.textColor, this.text, this.displayMode});
}

/// KML样式映射
class KmlStyleMap {
  final String id;
  final List<KmlPair> pairs;

  KmlStyleMap({required this.id, required this.pairs});
}

/// KML样式对
class KmlPair {
  final String key;
  final String styleUrl;

  KmlPair({required this.key, required this.styleUrl});
}

/// KML文件夹
class KmlFolder {
  final String? id;
  final String? name;
  final String? description;
  final String? snippet;
  final bool? visibility;
  final bool? open;
  final String? styleUrl;
  final List<KmlFolder> folders;
  final List<KmlPlacemark> placemarks;
  final Map<String, String> extendedData;

  KmlFolder({
    this.id,
    this.name,
    this.description,
    this.snippet,
    this.visibility,
    this.open,
    this.styleUrl,
    this.folders = const [],
    this.placemarks = const [],
    this.extendedData = const {},
  });
}

/// KML地标
class KmlPlacemark {
  final String? id;
  final String? name;
  final String? description;
  final String? snippet;
  final bool? visibility;
  final bool? open;
  final String? styleUrl;
  final KmlGeometry? geometry;
  final KmlTimeStamp? timeStamp;
  final KmlTimeSpan? timeSpan;
  final Map<String, String> extendedData;

  KmlPlacemark({
    this.id,
    this.name,
    this.description,
    this.snippet,
    this.visibility,
    this.open,
    this.styleUrl,
    this.geometry,
    this.timeStamp,
    this.timeSpan,
    this.extendedData = const {},
  });
}

/// KML几何体基类
abstract class KmlGeometry {}

/// KML点
class KmlPoint extends KmlGeometry {
  final bool? extrude;
  final String? altitudeMode;
  final KmlCoordinates coordinates;

  KmlPoint({
    this.extrude,
    this.altitudeMode,
    required this.coordinates,
  });
}

/// KML线串
class KmlLineString extends KmlGeometry {
  final bool? extrude;
  final bool? tessellate;
  final String? altitudeMode;
  final List<KmlCoordinates> coordinates;

  KmlLineString({
    this.extrude,
    this.tessellate,
    this.altitudeMode,
    required this.coordinates,
  });
}

/// KML多边形
class KmlPolygon extends KmlGeometry {
  final bool? extrude;
  final bool? tessellate;
  final String? altitudeMode;
  final KmlLinearRing? outerBoundaryIs;
  final List<KmlLinearRing> innerBoundaryIs;

  KmlPolygon({
    this.extrude,
    this.tessellate,
    this.altitudeMode,
    this.outerBoundaryIs,
    this.innerBoundaryIs = const [],
  });
}

/// KML线性环
class KmlLinearRing {
  final bool? extrude;
  final bool? tessellate;
  final String? altitudeMode;
  final List<KmlCoordinates> coordinates;

  KmlLinearRing({
    this.extrude,
    this.tessellate,
    this.altitudeMode,
    required this.coordinates,
  });
}

/// KML多重几何体
class KmlMultiGeometry extends KmlGeometry {
  final List<KmlGeometry> geometries;

  KmlMultiGeometry({required this.geometries});
}

/// KML轨迹（Google扩展）
class KmlTrack extends KmlGeometry {
  final bool? extrude;
  final bool? tessellate;
  final String? altitudeMode;
  final List<DateTime> when;
  final List<KmlCoordinates> coord;
  final Map<String, String> extendedData;

  KmlTrack({
    this.extrude,
    this.tessellate,
    this.altitudeMode,
    required this.when,
    required this.coord,
    this.extendedData = const {},
  });
}

/// KML坐标
class KmlCoordinates {
  final double longitude;
  final double latitude;
  final double altitude;

  KmlCoordinates({
    required this.longitude,
    required this.latitude,
    this.altitude = 0.0,
  });
}

/// KML时间戳
class KmlTimeStamp {
  final DateTime when;

  KmlTimeStamp({required this.when});
}

/// KML时间跨度
class KmlTimeSpan {
  final DateTime? begin;
  final DateTime? end;

  KmlTimeSpan({this.begin, this.end});
}

/// KML网络链接
class KmlNetworkLink {
  final String? id;
  final String? name;
  final String? description;
  final bool? visibility;
  final bool? open;
  final bool? refreshVisibility;
  final bool? flyToView;
  final KmlLink? link;

  KmlNetworkLink({
    this.id,
    this.name,
    this.description,
    this.visibility,
    this.open,
    this.refreshVisibility,
    this.flyToView,
    this.link,
  });
}

/// KML链接
class KmlLink {
  final String href;
  final String? refreshMode;
  final double? refreshInterval;
  final String? viewRefreshMode;
  final double? viewRefreshTime;

  KmlLink({
    required this.href,
    this.refreshMode,
    this.refreshInterval,
    this.viewRefreshMode,
    this.viewRefreshTime,
  });
}

/// KML地面覆盖
class KmlGroundOverlay {
  final String? id;
  final String? name;
  final String? description;
  final bool? visibility;
  final KmlIcon? icon;
  final KmlLatLonBox? latLonBox;
  final double? altitude;
  final String? altitudeMode;

  KmlGroundOverlay({
    this.id,
    this.name,
    this.description,
    this.visibility,
    this.icon,
    this.latLonBox,
    this.altitude,
    this.altitudeMode,
  });
}

/// KML经纬度框
class KmlLatLonBox {
  final double north;
  final double south;
  final double east;
  final double west;
  final double? rotation;

  KmlLatLonBox({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    this.rotation,
  });
}