import 'package:json_annotation/json_annotation.dart';
part 'map_bounds.g.dart';

/// 地图边界值对象
@JsonSerializable()
class MapBoundsVO {
  /// 北纬（最大纬度）
  final double north;

  /// 南纬（最小纬度）
  final double south;

  /// 东经（最大经度）
  final double east;

  /// 西经（最小经度）
  final double west;

  /// 构造函数
  const MapBoundsVO({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  /// 从JSON创建
  factory MapBoundsVO.fromJson(Map<String, dynamic> json) =>
      _$MapBoundsVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$MapBoundsVOToJson(this);

  /// 获取中心点纬度
  double get centerLatitude => (north + south) / 2;

  /// 获取中心点经度
  double get centerLongitude => (east + west) / 2;

  /// 获取纬度跨度
  double get latitudeSpan => north - south;

  /// 获取经度跨度
  double get longitudeSpan => east - west;

  /// 检查点是否在边界内
  bool contains(double latitude, double longitude) {
    return latitude <= north &&
        latitude >= south &&
        longitude <= east &&
        longitude >= west;
  }

  /// 扩展边界
  MapBoundsVO extend(double latitude, double longitude) {
    return MapBoundsVO(
      north: latitude > north ? latitude : north,
      south: latitude < south ? latitude : south,
      east: longitude > east ? longitude : east,
      west: longitude < west ? longitude : west,
    );
  }

  /// 添加边距
  MapBoundsVO addPadding(double latPadding, double lngPadding) {
    return MapBoundsVO(
      north: north + latPadding,
      south: south - latPadding,
      east: east + lngPadding,
      west: west - lngPadding,
    );
  }

  @override
  String toString() {
    return 'MapBoundsVO(north: $north, south: $south, east: $east, west: $west)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapBoundsVO &&
        other.north == north &&
        other.south == south &&
        other.east == east &&
        other.west == west;
  }

  @override
  int get hashCode => Object.hash(north, south, east, west);
}
