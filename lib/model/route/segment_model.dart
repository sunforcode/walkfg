import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/map/track_point_model.dart';

part 'segment_model.g.dart';

/// 道路类型枚举
enum RouteType {
  @JsonValue(0)
  mudRoad, // 泥路

  @JsonValue(1)
  farmRoad, // 机耕路

  @JsonValue(2)
  stoneRoad, // 石路

  @JsonValue(3)
  concreteRoad, // 水泥路

  @JsonValue(4)
  asphaltRoad, // 柏油路

  @JsonValue(5)
  trail, // 小径

  @JsonValue(6)
  boardwalk, // 栈道
}

/// RouteType 扩展方法
extension RouteTypeExtension on RouteType {
  /// 转换为整数值
  int get intValue {
    switch (this) {
      case RouteType.mudRoad:
        return 0;
      case RouteType.farmRoad:
        return 1;
      case RouteType.stoneRoad:
        return 2;
      case RouteType.concreteRoad:
        return 3;
      case RouteType.asphaltRoad:
        return 4;
      case RouteType.trail:
        return 5;
      case RouteType.boardwalk:
        return 6;
    }
  }

  /// 转换为字符串
  String get value {
    switch (this) {
      case RouteType.mudRoad:
        return 'mud_road';
      case RouteType.farmRoad:
        return 'farm_road';
      case RouteType.stoneRoad:
        return 'stone_road';
      case RouteType.concreteRoad:
        return 'concrete_road';
      case RouteType.asphaltRoad:
        return 'asphalt_road';
      case RouteType.trail:
        return 'trail';
      case RouteType.boardwalk:
        return 'boardwalk';
    }
  }

  /// 从整数创建
  static RouteType fromInt(int value) {
    switch (value) {
      case 0:
        return RouteType.mudRoad;
      case 1:
        return RouteType.farmRoad;
      case 2:
        return RouteType.stoneRoad;
      case 3:
        return RouteType.concreteRoad;
      case 4:
        return RouteType.asphaltRoad;
      case 5:
        return RouteType.trail;
      case 6:
        return RouteType.boardwalk;
      default:
        return RouteType.trail; // 默认值
    }
  }

  /// 从字符串创建
  static RouteType fromString(String value) {
    switch (value) {
      case 'mud_road':
        return RouteType.mudRoad;
      case 'farm_road':
        return RouteType.farmRoad;
      case 'stone_road':
        return RouteType.stoneRoad;
      case 'concrete_road':
        return RouteType.concreteRoad;
      case 'asphalt_road':
        return RouteType.asphaltRoad;
      case 'trail':
        return RouteType.trail;
      case 'boardwalk':
        return RouteType.boardwalk;
      default:
        return RouteType.trail; // 默认值
    }
  }

  /// 获取中文名称
  String get displayName {
    switch (this) {
      case RouteType.mudRoad:
        return '泥路';
      case RouteType.farmRoad:
        return '机耕路';
      case RouteType.stoneRoad:
        return '石路';
      case RouteType.concreteRoad:
        return '水泥路';
      case RouteType.asphaltRoad:
        return '柏油路';
      case RouteType.trail:
        return '小径';
      case RouteType.boardwalk:
        return '栈道';
    }
  }
}

/// 路线分段模型
@JsonSerializable()
class SegmentModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String? description;

  /// 距离（公里）
  final double distance;

  /// 预计时长（分钟）
  @JsonKey(name: 'estimated_time')
  final double estimatedTime;

  /// 爬升（米）
  @JsonKey(name: 'elevation_gain')
  final int elevationGain;

  /// 下降（米）
  @JsonKey(name: 'elevation_loss')
  final int? elevationLoss;

  /// 起点
  @JsonKey(name: 'start_point')
  final TrackPointVO? startWaypoint;

  /// 终点
  @JsonKey(name: 'end_point')
  final TrackPointVO? endWaypoint;

  /// 路径点列表
  @JsonKey(name: 'keypoints', defaultValue: <TrackPointVO>[])
  final List<TrackPointVO> keyPoints;

  /// 备注
  final String? notes;

  /// 道路类型
  @JsonKey(
    name: 'route_type',
    defaultValue: RouteType.trail,
    fromJson: _routeTypeFromJson,
    toJson: _routeTypeToJson,
  )
  final RouteType type;

  /// 构造函数
  SegmentModel({
    required this.id,
    required this.name,
    this.description,
    required this.distance,
    required this.estimatedTime,
    required this.elevationGain,
    this.elevationLoss,
    this.startWaypoint,
    this.endWaypoint,
    this.keyPoints = const <TrackPointVO>[],
    this.notes,
    this.type = RouteType.trail,
  });

  /// 从JSON创建
  factory SegmentModel.fromJson(Map<String, dynamic> json) =>
      _$SegmentModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$SegmentModelToJson(this);

  /// 复制并修改
  SegmentModel copyWith({
    String? id,
    String? name,
    String? description,
    double? distance,
    double? duration,
    int? elevationGain,
    int? elevationLoss,
    TrackPointVO? startWaypoint,
    TrackPointVO? endWaypoint,
    List<TrackPointVO>? keyPoints,
    String? note,
    RouteType? type,
  }) {
    return SegmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      distance: distance ?? this.distance,
      estimatedTime: duration ?? this.estimatedTime,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      startWaypoint: startWaypoint ?? this.startWaypoint,
      endWaypoint: endWaypoint ?? this.endWaypoint,
      keyPoints: keyPoints ?? this.keyPoints,
      notes: note ?? this.notes,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'SegmentModel(id: $id, name: $name, distance: $distance, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SegmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// 自定义RouteType从JSON转换
  static RouteType _routeTypeFromJson(int? value) {
    if (value == null) return RouteType.trail;
    return RouteTypeExtension.fromInt(value);
  }

  /// 自定义RouteType转JSON
  static int _routeTypeToJson(RouteType type) {
    return type.intValue;
  }
}
