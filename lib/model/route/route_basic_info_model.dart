import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'route_basic_info_model.g.dart';

/// 路线基本信息值对象模型
///
/// 作为路径模型的嵌套对象，不需要独立的ID和时间戳
@JsonSerializable()
class RouteBasicInfoVO {
  /// 距离(公里)
  final double distance;

  /// 累计爬升(米)
  final int elevation;

  /// 预计总时长(小时)
  final double duration;

  /// 难度等级(1-5)
  final int difficulty;

  /// 路线类型
  @JsonKey(fromJson: _parseRouteType, toJson: _routeTypeToJson)
  final RouteType type;

  /// 方向
  @JsonKey(fromJson: _parseRouteDirection, toJson: _routeDirectionToJson)
  final RouteDirection direction;

  /// 推荐天数
  final int days;

  /// 最佳季节
  final List<String> bestSeason;

  /// 构造函数
  RouteBasicInfoVO({
    required this.distance,
    required this.elevation,
    required this.duration,
    required this.difficulty,
    required this.type,
    required this.direction,
    required this.days,
    required this.bestSeason,
  });

  /// 从JSON创建
  factory RouteBasicInfoVO.fromJson(Map<String, dynamic> json) =>
      _$RouteBasicInfoVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$RouteBasicInfoVOToJson(this);

  /// 解析路线类型
  static RouteType _parseRouteType(dynamic type) {
    if (type is int && type >= 0 && type < RouteType.values.length) {
      return RouteType.values[type];
    } else if (type is String) {
      switch (type.toLowerCase()) {
        case 'circular':
          return RouteType.circular;
        case 'oneway':
          return RouteType.oneWay;
        case 'roundtrip':
          return RouteType.roundTrip;
        default:
          return RouteType.circular;
      }
    }
    return RouteType.circular;
  }

  /// 路线类型转JSON
  static int _routeTypeToJson(RouteType type) {
    return type.index;
  }

  /// 解析路线方向
  static RouteDirection _parseRouteDirection(dynamic direction) {
    if (direction is int &&
        direction >= 0 &&
        direction < RouteDirection.values.length) {
      return RouteDirection.values[direction];
    } else if (direction is String) {
      switch (direction.toLowerCase()) {
        case 'clockwise':
          return RouteDirection.clockwise;
        case 'counterclockwise':
          return RouteDirection.counterClockwise;
        default:
          return RouteDirection.clockwise;
      }
    }
    return RouteDirection.clockwise;
  }

  /// 路线方向转JSON
  static int _routeDirectionToJson(RouteDirection direction) {
    return direction.index;
  }

  /// 获取路线类型名称
  String getRouteTypeName() {
    switch (type) {
      case RouteType.circular:
        return '环线';
      case RouteType.oneWay:
        return '单向';
      case RouteType.roundTrip:
        return '往返';
    }
  }

  /// 获取路线方向名称
  String getRouteDirectionName() {
    switch (direction) {
      case RouteDirection.clockwise:
        return '顺时针';
      case RouteDirection.counterClockwise:
        return '逆时针';
    }
  }
}
