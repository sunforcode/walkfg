import 'package:json_annotation/json_annotation.dart';

part 'waypoint_model.g.dart';

/// 途经点类型
enum WaypointType {
  /// 起点
  start,

  /// 终点
  end,

  /// 景点
  scenic,

  /// 休息点
  rest,

  /// 水源
  water,

  /// 营地
  camp,

  /// 其他
  other,
}

/// 途经点模型
@JsonSerializable()
class WaypointModel {
  /// 名称
  final String name;

  /// 描述
  final String? description;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 海拔
  final double elevation;

  /// 距起点距离(公里)
  @JsonKey(name: 'distance_from_start')
  final double distanceFromStart;

  /// 距起点预计时间(小时)
  @JsonKey(name: 'estimated_time_from_start')
  final double estimatedTimeFromStart;

  /// 类型
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final WaypointType type;

  /// 构造函数
  WaypointModel({
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.distanceFromStart,
    required this.estimatedTimeFromStart,
    required this.type,
  });

  /// 从JSON创建
  factory WaypointModel.fromJson(Map<String, dynamic> json) =>
      _$WaypointModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WaypointModelToJson(this);

  /// 解析类型
  static WaypointType _typeFromJson(dynamic type) {
    if (type is int && type >= 0 && type < WaypointType.values.length) {
      return WaypointType.values[type];
    } else if (type is String) {
      switch (type.toLowerCase()) {
        case 'start':
          return WaypointType.start;
        case 'end':
          return WaypointType.end;
        case 'scenic':
          return WaypointType.scenic;
        case 'rest':
          return WaypointType.rest;
        case 'water':
          return WaypointType.water;
        case 'camp':
          return WaypointType.camp;
        default:
          return WaypointType.other;
      }
    }
    return WaypointType.other;
  }

  /// 类型转JSON
  static String _typeToJson(WaypointType type) {
    switch (type) {
      case WaypointType.start:
        return 'start';
      case WaypointType.end:
        return 'end';
      case WaypointType.scenic:
        return 'scenic';
      case WaypointType.rest:
        return 'rest';
      case WaypointType.water:
        return 'water';
      case WaypointType.camp:
        return 'camp';
      case WaypointType.other:
        return 'other';
    }
  }
}
